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

CLIENT_APP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BUILDER_DIR="$CLIENT_APP_DIR/project_builder"
BUILD_ROOT_DIR="$CLIENT_APP_DIR/build"
DASHBOARD_BUILD_DIR="$BUILD_ROOT_DIR/web_dashboard"
ADMIN_BUILD_DIR="$BUILD_ROOT_DIR/web_admin"

CLIENT=""
ACTION=""
APP_MODE=""

VALID_ACTIONS=("config" "run" "build-run" "deploy" "clean")
VALID_APPS=("dashboard" "admin" "both")

is_valid_action() {
    local value="$1"
    for action in "${VALID_ACTIONS[@]}"; do
        if [ "$action" == "$value" ]; then
            return 0
        fi
    done
    return 1
}

is_valid_app() {
    local value="$1"
    for app in "${VALID_APPS[@]}"; do
        if [ "$app" == "$value" ]; then
            return 0
        fi
    done
    return 1
}

if is_valid_action "$1"; then
    ACTION="$1"
    if is_valid_app "$2"; then
        APP_MODE="$2"
    fi
else
    if [ -n "$1" ]; then
        CLIENT="$1"
    fi
    if is_valid_action "$2"; then
        ACTION="$2"
    fi
    if is_valid_app "$3"; then
        APP_MODE="$3"
    elif is_valid_app "$2" && [ -z "$ACTION" ]; then
        APP_MODE="$2"
    fi
fi

if [ -z "$CLIENT" ]; then
    if [ -f "$BUILDER_DIR/config.yaml" ]; then
        CLIENT=$(grep -E "^activeClient:" "$BUILDER_DIR/config.yaml" | sed -E "s/activeClient:[[:space:]]*['\"]?([^'\"]+)['\"]?/\1/")
    fi
fi

if [ -z "$CLIENT" ]; then
    echo -e "${RED}❌ Error: No client specified! Please set it in config.yaml or pass it as an argument.${NC}"
    exit 1
fi

CLIENT_YAML="$BUILDER_DIR/clients/$CLIENT.yaml"
if [ ! -f "$CLIENT_YAML" ]; then
    echo -e "${RED}❌ Error: Client file not found at ${CLIENT_YAML}${NC}"
    exit 1
fi

yaml_read() {
    local key_path="$1"
    python3 - "$CLIENT_YAML" "$key_path" <<'PY'
import sys

filepath = sys.argv[1]
key_path = sys.argv[2].split(".")

def parse_simple_yaml(filepath):
    data = {}
    stack = [(0, data)]
    with open(filepath, "r", encoding="utf-8") as f:
        for line in f:
            stripped = line.strip()
            if not stripped or stripped.startswith("#"):
                continue
            if ":" not in stripped:
                continue
            indent = len(line) - len(line.lstrip())
            key, val = stripped.split(":", 1)
            key = key.strip()
            val = val.strip()

            if val.startswith('"') and val.endswith('"'):
                val = val[1:-1]
            elif val.startswith("'") and val.endswith("'"):
                val = val[1:-1]

            while stack and indent <= stack[-1][0] and len(stack) > 1:
                stack.pop()

            current = stack[-1][1]
            if val == "":
                child = {}
                current[key] = child
                stack.append((indent, child))
            else:
                current[key] = val
    return data

data = parse_simple_yaml(filepath)
current = data
for part in key_path:
    if isinstance(current, dict) and part in current:
        current = current[part]
    else:
        print("")
        sys.exit(0)

if isinstance(current, dict):
    print("")
else:
    print(current)
PY
}

DASHBOARD_TARGET="$(yaml_read "apps.dashboard.buildTarget")"
ADMIN_TARGET="$(yaml_read "apps.admin.buildTarget")"
DASHBOARD_SITE="$(yaml_read "apps.dashboard.hostingSite")"
ADMIN_SITE="$(yaml_read "apps.admin.hostingSite")"
TARGET_VERSION="$(yaml_read "appVersion")"
TARGET_BUILD="$(yaml_read "appBuildIndex")"

if [ -z "$DASHBOARD_TARGET" ]; then DASHBOARD_TARGET="lib/main_dashboard.dart"; fi
if [ -z "$ADMIN_TARGET" ]; then ADMIN_TARGET="lib/main_admin.dart"; fi

if [ -z "$DASHBOARD_SITE" ]; then
    DASHBOARD_SITE="$(yaml_read "firebase.hosting.dashboard")"
fi
if [ -z "$ADMIN_SITE" ]; then
    ADMIN_SITE="$(yaml_read "firebase.hosting.admin")"
fi

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

if [ -z "$APP_MODE" ] && [ "$ACTION" != "clean" ] && [ "$ACTION" != "config" ]; then
    echo -e "${YELLOW}🧩 Select app mode:${NC}"
    echo -e "  [${CYAN}1${NC}] Dashboard"
    echo -e "  [${CYAN}2${NC}] Admin"
    echo -e "  [${CYAN}3${NC}] Both"
    read -p "Option Number: " APP_INDEX
    case $APP_INDEX in
        1) APP_MODE="dashboard";;
        2) APP_MODE="admin";;
        3) APP_MODE="both";;
        *) echo -e "${RED}❌ Invalid app option${NC}"; exit 1;;
    esac
fi

if [ -z "$APP_MODE" ]; then
    APP_MODE="both"
fi

if ! is_valid_app "$APP_MODE"; then
    echo -e "${RED}❌ Error: Invalid app mode [$APP_MODE]. Use: dashboard | admin | both${NC}"
    exit 1
fi

echo -e "${CYAN}⚙️  Active Client: ${BOLD}${CLIENT}${NC}"
echo -e "${CYAN}🏃 Action: ${BOLD}${ACTION}${NC}"
echo -e "${CYAN}🧩 App Mode: ${BOLD}${APP_MODE}${NC}"
echo -e "${PURPLE}📦 Dashboard target: ${DASHBOARD_TARGET}${NC}"
echo -e "${PURPLE}📦 Admin target: ${ADMIN_TARGET}${NC}"
echo -e "${PURPLE}☁️  Dashboard hosting: ${DASHBOARD_SITE}${NC}"
echo -e "${PURPLE}☁️  Admin hosting: ${ADMIN_SITE}${NC}"

if [ "$ACTION" == "run" ]; then
    if [ "$APP_MODE" == "dashboard" ] && [ ! -d "$DASHBOARD_BUILD_DIR" ]; then
        echo -e "${RED}❌ Error: $DASHBOARD_BUILD_DIR not found! Build dashboard first.${NC}"
        exit 1
    fi
    if [ "$APP_MODE" == "admin" ] && [ ! -d "$ADMIN_BUILD_DIR" ]; then
        echo -e "${RED}❌ Error: $ADMIN_BUILD_DIR not found! Build admin first.${NC}"
        exit 1
    fi
    if [ "$APP_MODE" == "both" ] && { [ ! -d "$DASHBOARD_BUILD_DIR" ] || [ ! -d "$ADMIN_BUILD_DIR" ]; }; then
        echo -e "${RED}❌ Error: Missing one or both pre-built folders ($DASHBOARD_BUILD_DIR, $ADMIN_BUILD_DIR).${NC}"
        exit 1
    fi
else
    if [ -f "$CLIENT_APP_DIR/pubspec.yaml" ] && [ -f "$BUILDER_DIR/clients/$CLIENT.yaml" ]; then
        CURRENT_VERSION=$(grep -E "^version:" "$CLIENT_APP_DIR/pubspec.yaml" | sed -E "s/version:[[:space:]]*//")
        TARGET_FULL="${TARGET_VERSION}+${TARGET_BUILD}"

        if [ "$CURRENT_VERSION" != "$TARGET_FULL" ]; then
            echo -e "\n${YELLOW}⚠️  Warning: Current version in pubspec.yaml ($CURRENT_VERSION) differs from client version ($TARGET_FULL)!${NC}"
            echo -e "${YELLOW}Synchronizing versions automatically and proceeding...${NC}\n"
            sleep 2
        fi
    fi

    python3 "$BUILDER_DIR/configure.py" "$CLIENT" "$ACTION"
    if [ $? -ne 0 ]; then
        echo -e "${RED}❌ Configuration failed!${NC}"
        exit 1
    fi
fi

if [ "$ACTION" == "config" ]; then
    echo -e "\n${GREEN}${BOLD}✅ Configurations for client [${CLIENT}] successfully generated!${NC}\n"
    exit 0
fi

if [ "$ACTION" == "clean" ]; then
    echo -e "\n${BLUE}🧹 Cleaning project and clearing Flutter cache...${NC}"
    cd "$CLIENT_APP_DIR"
    flutter clean
    echo -e "\n${GREEN}${BOLD}✅ Project successfully cleaned!${NC}\n"
    exit 0
fi

build_app() {
    local app_name="$1"
    local target_path="$2"
    local output_dir="$3"

    echo -e "\n${BLUE}📦 Building ${app_name} using target [${target_path}]...${NC}"
    cd "$CLIENT_APP_DIR" || exit 1
    flutter build web --release --target "$target_path"
    if [ $? -ne 0 ]; then
        echo -e "${RED}❌ Build failed for ${app_name}!${NC}"
        exit 1
    fi
    rm -rf "$output_dir"
    cp -R "$CLIENT_APP_DIR/build/web" "$output_dir"
    echo -e "${GREEN}✅ ${app_name} build saved at: ${output_dir}${NC}"
}

deploy_app() {
    local app_name="$1"
    local hosting_site="$2"
    local output_dir="$3"
    local tmp_firebase_json

    if [ -z "$hosting_site" ]; then
        echo -e "${RED}❌ Hosting site missing for ${app_name} in client yaml.${NC}"
        exit 1
    fi

    if [ ! -d "$output_dir" ]; then
        echo -e "${RED}❌ Build output missing for ${app_name} at ${output_dir}.${NC}"
        exit 1
    fi

    tmp_firebase_json="$(mktemp)"
    cat > "$tmp_firebase_json" <<EOF
{
  "hosting": {
    "site": "${hosting_site}",
    "public": "${output_dir}",
    "ignore": ["firebase.json", "**/.*", "**/node_modules/**"],
    "rewrites": [
      { "source": "**", "destination": "/index.html" }
    ]
  }
}
EOF

    echo -e "\n${YELLOW}🚀 Deploying ${app_name} to Firebase site [${hosting_site}]...${NC}"
    cd "$CLIENT_APP_DIR" || exit 1
    firebase deploy --only hosting --config "$tmp_firebase_json"
    local deploy_exit_code=$?
    rm -f "$tmp_firebase_json"
    if [ $deploy_exit_code -ne 0 ]; then
        echo -e "${RED}❌ Deploy failed for ${app_name}.${NC}"
        exit 1
    fi
    echo -e "${GREEN}✅ ${app_name} deployed to ${hosting_site}.${NC}"
}

if [ "$ACTION" != "run" ]; then
    if [ "$APP_MODE" == "dashboard" ] || [ "$APP_MODE" == "both" ]; then
        build_app "dashboard" "$DASHBOARD_TARGET" "$DASHBOARD_BUILD_DIR"
    fi
    if [ "$APP_MODE" == "admin" ] || [ "$APP_MODE" == "both" ]; then
        build_app "admin" "$ADMIN_TARGET" "$ADMIN_BUILD_DIR"
    fi
fi

if [ "$ACTION" == "run" ] || [ "$ACTION" == "build-run" ]; then
    echo -e "\n${GREEN}🖥️  Starting local server(s) for client [$CLIENT]...${NC}"
    echo -e "${YELLOW}Press Ctrl+C to stop.${NC}\n"

    SERVER_PID_DASH=""
    SERVER_PID_ADMIN=""

    if [ "$APP_MODE" == "dashboard" ] || [ "$APP_MODE" == "both" ]; then
        python3 -m http.server 8085 --directory "$DASHBOARD_BUILD_DIR" >/dev/null 2>&1 &
        SERVER_PID_DASH=$!
        echo -e "${GREEN}🔗 dashboard: http://localhost:8085${NC}"
    fi
    if [ "$APP_MODE" == "admin" ] || [ "$APP_MODE" == "both" ]; then
        python3 -m http.server 8086 --directory "$ADMIN_BUILD_DIR" >/dev/null 2>&1 &
        SERVER_PID_ADMIN=$!
        echo -e "${GREEN}🔗 admin: http://localhost:8086${NC}"
    fi

    trap 'kill $SERVER_PID_DASH 2>/dev/null; kill $SERVER_PID_ADMIN 2>/dev/null; echo -e "\n${YELLOW}🔌 Local server(s) stopped.${NC}\n"; exit 0' INT TERM EXIT
    wait
elif [ "$ACTION" == "deploy" ]; then
    if [ "$APP_MODE" == "dashboard" ] || [ "$APP_MODE" == "both" ]; then
        deploy_app "dashboard" "$DASHBOARD_SITE" "$DASHBOARD_BUILD_DIR"
    fi
    if [ "$APP_MODE" == "admin" ] || [ "$APP_MODE" == "both" ]; then
        deploy_app "admin" "$ADMIN_SITE" "$ADMIN_BUILD_DIR"
    fi

    echo -e "\n${GREEN}${BOLD}🎉 Deploy completed successfully for client [${CLIENT}] in mode [${APP_MODE}]!${NC}\n"
fi




