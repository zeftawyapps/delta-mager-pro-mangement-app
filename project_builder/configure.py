#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
🚀 Delta Matger Pro - Multi-Tenant Configuration Generator
This script parses the selected client's YAML configuration directly from
`project_builder/clients/<client>.yaml` and dynamically generates `config.yaml`,
`.firebaserc`, and `firebase.json` independently for both projects.
"""

import os
import sys
import json

def parse_simple_yaml(filepath):
    """
    A lightweight, zero-dependency YAML parser.
    """
    if not os.path.exists(filepath):
        print(f"❌ Error: Config file not found at {filepath}")
        sys.exit(1)
        
    data = {}
    stack = [(0, data)] # (indentation, current_dict)
    
    with open(filepath, 'r', encoding='utf-8') as f:
        for line in f:
            stripped = line.strip()
            if not stripped or stripped.startswith('#'):
                continue
                
            indent = len(line) - len(line.lstrip())
            
            if ':' not in stripped:
                continue
            
            key, val = stripped.split(':', 1)
            key = key.strip()
            val = val.strip()
            
            if val.startswith('"') and val.endswith('"'):
                val = val[1:-1]
            elif val.startswith("'") and val.endswith("'"):
                val = val[1:-1]
                
            while stack and indent <= stack[-1][0] and len(stack) > 1:
                stack.pop()
                
            current_dict = stack[-1][1]
            
            if val == "":
                new_dict = {}
                current_dict[key] = new_dict
                stack.append((indent, new_dict))
            else:
                current_dict[key] = val
                
    return data

def main():
    script_dir = os.path.dirname(os.path.abspath(__file__))
    parent_dir = os.path.abspath(os.path.join(script_dir, ".."))
    
    # Check if we are running from the shared/external project_builder folder
    if os.path.basename(parent_dir) == "matger-pro" or not os.path.exists(os.path.join(parent_dir, "pubspec.yaml")):
        client_app_dir = os.path.join(parent_dir, "delta-mager-pro-client-app")
        mgmt_app_dir = os.path.join(parent_dir, "delta-mager-pro-mangement-app")
    else:
        if "mangement-app" in parent_dir:
            mgmt_app_dir = parent_dir
            client_app_dir = os.path.abspath(os.path.join(parent_dir, "..", "delta-mager-pro-client-app"))
        else:
            client_app_dir = parent_dir
            mgmt_app_dir = os.path.abspath(os.path.join(parent_dir, "..", "delta-mager-pro-mangement-app"))

    # Determine active client and action
    client_name = None
    action = "config"

    if len(sys.argv) >= 2:
        client_name = sys.argv[1].lower()
    else:
        # Fallback to reading from config.yaml
        config_path = os.path.join(script_dir, "config.yaml")
        if os.path.exists(config_path):
            with open(config_path, 'r', encoding='utf-8') as f:
                for line in f:
                    stripped = line.strip()
                    if stripped.startswith("activeClient:"):
                        val = stripped.split(":", 1)[1].strip()
                        if val.startswith('"') and val.endswith('"'):
                            val = val[1:-1]
                        elif val.startswith("'") and val.endswith("'"):
                            val = val[1:-1]
                        client_name = val.strip().lower()
                        break

    if len(sys.argv) >= 3:
        action = sys.argv[2].lower()

    if not client_name:
        print("❌ Error: No client specified. Please provide as argument or set 'activeClient' in project_builder/config.yaml")
        sys.exit(1)

    client_yaml_path = os.path.join(script_dir, "clients", f"{client_name}.yaml")
    if not os.path.exists(client_yaml_path):
        print(f"❌ Error: Client configuration file '{client_name}.yaml' not found in project_builder/clients/!")
        sys.exit(1)
        
    client_config = parse_simple_yaml(client_yaml_path)
    
    app_version = client_config.get("appVersion", "1.0.0")
    app_build_index = client_config.get("appBuildIndex", "1")
    
    # Extract firebase configurations
    firebase_cfg = client_config.get("firebase", {})
    firebase_project = firebase_cfg.get("project", "domansy-dev")
    hosting_cfg = firebase_cfg.get("hosting", {})
    hosting_admin = hosting_cfg.get("admin", "")
    hosting_dashboard = hosting_cfg.get("dashboard", "")
    
    # Active environment ('local', 'dev', 'prod' - default to prod)
    active_env = client_config.get("env", "local" if client_name == "local" else "prod")
    
    print(f"\n⚙️  Configuring environment for client: \033[1;32m{client_name.upper()}\033[0m...")
    print(f"  Firebase Project: {firebase_project}")
    print(f"  Hosting Site Admin: {hosting_admin}")
    print(f"  Hosting Site Dashboard: {hosting_dashboard}")
    print(f"  Active Env: {active_env}")
    print(f"  App Version: {app_version} (Build: {app_build_index})")
    
    # Base Dynamic .firebaserc with no complex targets
    firebaserc_content = {
        "projects": {
            "default": firebase_project
        }
    }

    def apply_configs_to_project(project_dir, project_name, is_admin_app=False):
        if not os.path.exists(project_dir):
            print(f"⚠️  Skipping {project_name}: Directory does not exist.")
            return
            
        print(f"📦 Applying configs to {project_name}...")
        
        # 1. Write dynamic .firebaserc to root
        with open(os.path.join(project_dir, ".firebaserc"), 'w', encoding='utf-8') as f:
            json.dump(firebaserc_content, f, indent=2)
            
        # 2. Write dynamic firebase.json pointing to the SPECIFIC site directly!
        active_site = hosting_admin if is_admin_app else hosting_dashboard
        firebase_json_content = {
            "hosting": {
                "site": active_site,
                "public": "build/web",
                "ignore": ["firebase.json", "**/.*", "**/node_modules/**"],
                "rewrites": [{"source": "**", "destination": "/index.html"}]
            }
        }
        with open(os.path.join(project_dir, "firebase.json"), 'w', encoding='utf-8') as f:
            json.dump(firebase_json_content, f, indent=2)
            
        # 3. Write/Sync client YAML file
        builder_dir = os.path.join(project_dir, "project_builder")
        clients_dir = os.path.join(builder_dir, "clients")
        os.makedirs(clients_dir, exist_ok=True)
        
        dest_client_yaml = os.path.join(clients_dir, f"{client_name}.yaml")
        if os.path.abspath(client_yaml_path) != os.path.abspath(dest_client_yaml):
            import shutil
            shutil.copy2(client_yaml_path, dest_client_yaml)
            
        # 4. Write config.yaml (Active client pointer)
        config_yaml_content = f"""# 🌐 Active Client Configuration
# Dynamic generated from clients/{client_name}.yaml. Do not edit directly.

activeClient: "{client_name}"

appVersion: "{app_version}"
appBuildIndex: {app_build_index}

# 🌍 Active environment (local, dev, prod)
env: "{active_env}"

# ⚙️ Admin / Management mode
isAdminMode: {"true" if is_admin_app else "false"}
"""
        with open(os.path.join(builder_dir, "config.yaml"), 'w', encoding='utf-8') as f:
            f.write(config_yaml_content)
            
        # 5. Sync and update pubspec.yaml version and buildIndix automatically
        pubspec_path = os.path.join(project_dir, "pubspec.yaml")
        if os.path.exists(pubspec_path):
            with open(pubspec_path, 'r', encoding='utf-8') as f:
                content = f.read()
            
            import re
            new_version_line = f"version: {app_version}+{app_build_index}"
            # Match 'version:' pattern and replace it
            content_updated = re.sub(r'^version:\s*.*$', new_version_line, content, flags=re.MULTILINE)
            
            # Also match and update custom 'buildIndix:' pattern if it exists
            new_build_indix_line = f"buildIndix: {app_build_index}"
            content_updated = re.sub(r'^buildIndix:\s*.*$', new_build_indix_line, content_updated, flags=re.MULTILINE)
            
            with open(pubspec_path, 'w', encoding='utf-8') as f:
                f.write(content_updated)
            print(f"  📝 Synchronized pubspec.yaml version to: {app_version}+{app_build_index} and buildIndix to: {app_build_index}")


        print(f"  ✅ Configured successfully!")

    # Apply to Client App
    apply_configs_to_project(client_app_dir, "Client App (Dashboard)", is_admin_app=False)
    
    # Apply to Management App
    apply_configs_to_project(mgmt_app_dir, "Management App (Admin)", is_admin_app=True)

    # 6. Log configuration and deployment details to version_history.md
    import datetime
    history_path = os.path.join(script_dir, "version_history.md")
    
    if not os.path.exists(history_path):
        with open(history_path, 'w', encoding='utf-8') as f:
            f.write("# 📜 سجل تحديثات وإصدارات العملاء (Deployment & Version History)\n\n")
            f.write("يحتوي هذا الملف على سجل تاريخي لجميع عمليات البناء والنشر والتهيئة التي تمت لكل عميل في النظام.\n\n")
            f.write("| التاريخ والوقت | اسم العميل | رقم الإصدار (Version) | رقم البناء (Build) | نوع العملية (Action) | الحالة (Status) |\n")
            f.write("| :--- | :--- | :--- | :--- | :--- | :--- |\n")
            
    now = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    action_labels = {
        "run": "💻 تشغيل محلي (Local Serve)",
        "build-run": "💻 بناء وتشغيل محلي (Build & Run Locally)",
        "deploy": "🚀 رفع للاستضافة (Firebase Deploy)",
        "config": "⚙️ تهيئة ملفات (Configure Only)"
    }
    action_label = action_labels.get(action, f"⚙️ {action}")
    status = "✅ ناجح"
    
    row = f"| {now} | **{client_name.upper()}** | {app_version} | {app_build_index} | {action_label} | {status} |\n"
    
    with open(history_path, 'a', encoding='utf-8') as f:
        f.write(row)
    
    print(f"\n\033[1;32m🎉 Configuration successfully generated for '{client_name}'!\033[0m\n")

if __name__ == '__main__':
    main()

