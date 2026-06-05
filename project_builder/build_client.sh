#!/bin/bash

# 🎨 Modern high-intensity colors for maximum readability on all terminals
RED='\033[0;91m'      # High-intensity Red
GREEN='\033[0;92m'    # High-intensity Green
BLUE='\033[0;94m'     # High-intensity Blue (extremely readable)
CYAN='\033[0;96m'     # High-intensity Cyan
YELLOW='\033[0;93m'   # High-intensity Yellow
PURPLE='\033[0;95m'   # High-intensity Purple
BOLD='\033[1m'
NC='\033[0m'          # No Color

echo -e "${CYAN}${BOLD}======================================================${NC}"
echo -e "${BLUE}${BOLD}   🚀 Delta Matger Pro - Project Builder Setup        ${NC}"
echo -e "${CYAN}${BOLD}======================================================${NC}"

# تحديد مسارات المشروع الحالية والتابعة
CLIENT_APP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BUILDER_DIR="$CLIENT_APP_DIR/project_builder"

# 1. تحديد العميل النشط تلقائياً
CLIENT=""
ACTION=""

# التحقق من المدخلات عبر سطر الأوامر (Arguments)
if [ "$1" == "config" ] || [ "$1" == "run" ] || [ "$1" == "build-run" ] || [ "$1" == "deploy" ] || [ "$1" == "clean" ]; then
    ACTION="$1"
else
    if [ -n "$1" ]; then
        CLIENT="$1"
    fi
    if [ "$2" == "config" ] || [ "$2" == "run" ] || [ "$2" == "build-run" ] || [ "$2" == "deploy" ] || [ "$2" == "clean" ]; then
        ACTION="$2"
    fi
fi

# إذا لم يتم تحديد العميل من المعاملات، نقرأه تلقائياً من config.yaml
if [ -z "$CLIENT" ]; then
    if [ -f "$BUILDER_DIR/config.yaml" ]; then
        CLIENT=$(grep -E "^activeClient:" "$BUILDER_DIR/config.yaml" | sed -E "s/activeClient:[[:space:]]*['\"]?([^'\"]+)['\"]?/\1/")
    fi
fi

# Verify client selection
if [ -z "$CLIENT" ]; then
    echo -e "${RED}❌ Error: No client specified! Please set it in config.yaml or pass it as an argument.${NC}"
    exit 1
fi

# If action not specified, show options menu
if [ -z "$ACTION" ]; then
    echo -e "${YELLOW}📝 Select action for client [${BOLD}${CLIENT}${YELLOW}]:${NC}"
    echo -e "  [${CYAN}1${NC}] 💻 Build & Run Locally"
    echo -e "  [${CYAN}2${NC}] 🚀 Build & Deploy to Firebase"
    echo -e "  [${CYAN}3${NC}] ⚙️  Configure Only (No Build)"
    echo -e "  [${CYAN}4${NC}] 🧹 Clean Project (Flutter Clean)"
    read -p "Option Number: " ACTION_INDEX
    case $ACTION_INDEX in
        1) ACTION="build-run";;
        2) ACTION="deploy";;
        3) ACTION="config";;
        4) ACTION="clean";;
        *) echo -e "${RED}❌ Invalid option${NC}"; exit 1;;
    esac
fi

echo -e "${CYAN}⚙️  Active Client: ${BOLD}${CLIENT}${NC}"
echo -e "${CYAN}🏃 Action: ${BOLD}${ACTION}${NC}"

# 2. إجراءات التهيئة والتنبيهات
if [ "$ACTION" == "run" ]; then
    # Verify pre-built web directory
    if [ ! -d "$CLIENT_APP_DIR/build/web" ]; then
        echo -e "${RED}❌ Error: build/web directory not found! Please build the project or configure first.${NC}"
        exit 1
    fi
else
    # للـ deploy والـ config: نقوم بالتحقق من الإصدار أولاً قبل كتابته وتغييره
    if [ -f "$CLIENT_APP_DIR/pubspec.yaml" ] && [ -f "$BUILDER_DIR/clients/$CLIENT.yaml" ]; then
        CURRENT_VERSION=$(grep -E "^version:" "$CLIENT_APP_DIR/pubspec.yaml" | sed -E "s/version:[[:space:]]*//")
        TARGET_VERSION=$(grep -E "^appVersion:" "$BUILDER_DIR/clients/$CLIENT.yaml" | sed -E "s/appVersion:[[:space:]]*['\"]?([^'\"]+)['\"]?/\1/")
        TARGET_BUILD=$(grep -E "^appBuildIndex:" "$BUILDER_DIR/clients/$CLIENT.yaml" | sed -E "s/appBuildIndex:[[:space:]]*//")
        TARGET_FULL="${TARGET_VERSION}+${TARGET_BUILD}"
        
        if [ "$CURRENT_VERSION" != "$TARGET_FULL" ]; then
            echo -e "\n${YELLOW}⚠️  Warning: Current version in pubspec.yaml ($CURRENT_VERSION) differs from client version ($TARGET_FULL)!${NC}"
            echo -e "${YELLOW}Synchronizing versions automatically and proceeding...${NC}\n"
            sleep 2
        fi
    fi

    # Run configure script
    python3 "$BUILDER_DIR/configure.py" "$CLIENT" "$ACTION"
    if [ $? -ne 0 ]; then
        echo -e "${RED}❌ Configuration failed!${NC}"
        exit 1
    fi
fi

# Exit if config only
if [ "$ACTION" == "config" ]; then
    echo -e "\n${GREEN}${BOLD}✅ Configurations for client [${CLIENT}] successfully generated!${NC}\n"
    exit 0
fi

# Exit if clean only
if [ "$ACTION" == "clean" ]; then
    echo -e "\n${BLUE}🧹 Cleaning project and clearing Flutter cache...${NC}"
    cd "$CLIENT_APP_DIR"
    flutter clean
    echo -e "\n${GREEN}${BOLD}✅ Project successfully cleaned!${NC}\n"
    exit 0
fi

# 3. Build Web App (Skipped if serve only 'run')
if [ "$ACTION" != "run" ]; then
    echo -e "\n${BLUE}📦 Building Release Web App...${NC}"
    cd "$CLIENT_APP_DIR"
    flutter build web --release
    if [ $? -ne 0 ]; then
        echo -e "${RED}❌ Build failed!${NC}"
        exit 1
    fi
fi

# 4. Serve Locally or Deploy to Firebase
if [ "$ACTION" == "run" ] || [ "$ACTION" == "build-run" ]; then
    PORT=8085
    echo -e "\n${GREEN}🖥️  Starting local server for client [$CLIENT]...${NC}"
    echo -e "${GREEN}🔗 Open the following link in browser: ${BOLD}${CYAN}http://localhost:${PORT}${NC}\n"
    echo -e "${YELLOW}Press Ctrl+C to stop the server.${NC}\n"
    
    # Run python server in background silently
    python3 -m http.server $PORT --directory "$CLIENT_APP_DIR/build/web" >/dev/null 2>&1 &
    SERVER_PID=$!
    
    # Graceful cleanup on Ctrl+C
    trap 'kill $SERVER_PID 2>/dev/null; echo -e "\n${YELLOW}🔌 Local server successfully stopped.${NC}\n"; exit 0' INT TERM EXIT
    
    wait $SERVER_PID
elif [ "$ACTION" == "deploy" ]; then
    echo -e "\n${YELLOW}🚀 Deploying to live hosting for client [$CLIENT]...${NC}"
    firebase deploy --only hosting
    echo -e "\n${GREEN}${BOLD}🎉 Deploy completed successfully! Client app [${CLIENT}] is live! 🚀${NC}\n"
fi




