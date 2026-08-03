#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
🚀 Delta Matger Pro - Multi-Tenant Configuration Generator (Management App)
"""

import os
import sys
import json
import shutil
import subprocess
import re

def parse_simple_yaml(filepath):
    """
    A lightweight, zero-dependency YAML parser.
    """
    if not os.path.exists(filepath):
        print(f"❌ Error: Config file not found at {filepath}")
        sys.exit(1)
        
    data = {}
    stack = [(0, data)]
    
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
    mgmt_app_dir = os.path.abspath(os.path.join(script_dir, ".."))

    # Determine active client and action
    client_name = None
    action = "config"

    if len(sys.argv) >= 2:
        client_name = sys.argv[1].lower()
    else:
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
    
    # 0. Primary Version Source: Extract version and build index from pubspec.yaml
    pubspec_path = os.path.join(mgmt_app_dir, "pubspec.yaml")
    pubspec_ver = None
    pubspec_build = None

    if os.path.exists(pubspec_path):
        try:
            with open(pubspec_path, 'r', encoding='utf-8') as f:
                for line in f:
                    stripped = line.strip()
                    if stripped.startswith("version:"):
                        val = stripped.split(":", 1)[1].strip()
                        if (val.startswith('"') and val.endswith('"')) or (val.startswith("'") and val.endswith("'")):
                            val = val[1:-1].strip()
                        if "+" in val:
                            v_parts = val.split("+", 1)
                            pubspec_ver = v_parts[0].strip()
                            pubspec_build = v_parts[1].strip()
                        else:
                            pubspec_ver = val
                            pubspec_build = str(client_config.get("appBuildIndex", "1"))
                        break
        except Exception:
            pass

    if pubspec_ver:
        app_version = pubspec_ver
        app_build_index = pubspec_build
    else:
        app_version = client_config.get("appVersion", "1.0.0")
        app_build_index = client_config.get("appBuildIndex", "1")

    # Sync version from pubspec.yaml across all client YAML configurations in project_builder/clients/
    clients_dir = os.path.join(script_dir, "clients")
    if os.path.exists(clients_dir):
        for fname in os.listdir(clients_dir):
            if fname.endswith(".yaml"):
                fpath = os.path.join(clients_dir, fname)
                try:
                    with open(fpath, 'r', encoding='utf-8') as f:
                        c_text = f.read()
                    c_text = re.sub(r'^appVersion:\s*.*$', f'appVersion: "{app_version}"', c_text, flags=re.MULTILINE)
                    c_text = re.sub(r'^appBuildIndex:\s*.*$', f'appBuildIndex: {app_build_index}', c_text, flags=re.MULTILINE)
                    with open(fpath, 'w', encoding='utf-8') as f:
                        f.write(c_text)
                except Exception:
                    pass

    # Synchronize AppShellLocalConfigs in lib/configs/app_shell_config.dart
    shell_cfg_path = os.path.join(mgmt_app_dir, "lib", "configs", "app_shell_config.dart")
    if os.path.exists(shell_cfg_path):
        try:
            with open(shell_cfg_path, 'r', encoding='utf-8') as f:
                code = f.read()
            code = re.sub(r'static\s+String\s+appVersion\s*=\s*[\'"][^\'"]+[\'"];', f"static String appVersion = '{app_version}';", code)
            code = re.sub(r'static\s+int\s+appBuildIndex\s*=\s*\d+;', f"static int appBuildIndex = {app_build_index};", code)
            with open(shell_cfg_path, 'w', encoding='utf-8') as f:
                f.write(code)
        except Exception:
            pass
    
    # Extract branding configurations
    branding_cfg = client_config.get("appBranding", {})
    seo_cfg = client_config.get("seo", {})
    logo_cfg = client_config.get("logo", {})
    app_title = branding_cfg.get("appTitle", "Management App")
    default_org_name = branding_cfg.get("defaultOrgName", "management")
    app_description = seo_cfg.get("appDescription") or branding_cfg.get("appDescription", "لوحة التحكم لإدارة كافة العمليات والمنتجات والطلبات.")
    theme_color = seo_cfg.get("themeColor") or branding_cfg.get("themeColor", "#D4AF37")
    keywords = seo_cfg.get("keywords") or branding_cfg.get("keywords", "لوحة تحكم, إدارة, متجر")
    logo_path = logo_cfg.get("path") or branding_cfg.get("logo") or "icons/Icon-512.png"
    logo_base_name, logo_ext = os.path.splitext(logo_path)
    if logo_path == "icons/Icon-512.png":
        logo_path_192 = "icons/Icon-192.png"
        logo_path_512 = "icons/Icon-512.png"
    else:
        logo_path_192 = f"{logo_base_name}_192{logo_ext}"
        logo_path_512 = f"{logo_base_name}_512{logo_ext}"

    # Extract firebase configurations
    firebase_cfg = client_config.get("firebase", {})
    firebase_project = firebase_cfg.get("project", "domansy-dev")
    hosting_cfg = firebase_cfg.get("hosting", {})
    hosting_admin = hosting_cfg.get("admin", "")
    hosting_dashboard = (
        hosting_cfg.get("client") or 
        hosting_cfg.get("cleint") or 
        hosting_cfg.get("clientApp") or 
        hosting_cfg.get("cleintApp") or 
        hosting_cfg.get("dashboard") or 
        ""
    )
    
    active_env = client_config.get("env", "local" if client_name == "local" else "prod")
    
    print(f"\n⚙️  Configuring environment for client: \033[1;32m{client_name.upper()}\033[0m...")
    print(f"  Firebase Project: {firebase_project}")
    print(f"  Hosting Site Admin: {hosting_admin}")
    print(f"  Hosting Site Dashboard: {hosting_dashboard}")
    print(f"  Active Env: {active_env}")
    print(f"  App Version: {app_version} (Build: {app_build_index})")
    
    firebaserc_content = {
        "projects": {
            "default": firebase_project
        }
    }

    # 1. Write dynamic .firebaserc to root
    with open(os.path.join(mgmt_app_dir, ".firebaserc"), 'w', encoding='utf-8') as f:
        json.dump(firebaserc_content, f, indent=2)
        
    # 2. Write dynamic firebase.json
    target_site = hosting_dashboard if hosting_dashboard else hosting_admin
    firebase_json_content = {
        "hosting": {
            "site": target_site,
            "public": "build/web",
            "ignore": ["firebase.json", "**/.*", "**/node_modules/**"],
            "rewrites": [{"source": "**", "destination": "/index.html"}]
        }
    }
    with open(os.path.join(mgmt_app_dir, "firebase.json"), 'w', encoding='utf-8') as f:
        json.dump(firebase_json_content, f, indent=2)
        
    # 3. Write config.yaml
    config_yaml_content = f"""# 🌐 Active Client Configuration
activeClient: "{client_name}"

appVersion: "{app_version}"
appBuildIndex: {app_build_index}

env: "{active_env}"
isAdminMode: false
"""
    with open(os.path.join(script_dir, "config.yaml"), 'w', encoding='utf-8') as f:
        f.write(config_yaml_content)
        
    # 4. Sync pubspec.yaml version
    if os.path.exists(pubspec_path):
        with open(pubspec_path, 'r', encoding='utf-8') as f:
            content = f.read()
        
        new_version_line = f"version: {app_version}+{app_build_index}"
        content_updated = re.sub(r'^version:\s*.*$', new_version_line, content, flags=re.MULTILINE)
        new_build_indix_line = f"buildIndix: {app_build_index}"
        content_updated = re.sub(r'^buildIndix:\s*.*$', new_build_indix_line, content_updated, flags=re.MULTILINE)
        
        with open(pubspec_path, 'w', encoding='utf-8') as f:
            f.write(content_updated)
        print(f"  📝 Synchronized pubspec.yaml version to: {app_version}+{app_build_index}")

    # 5. Generate PWA & web files
    web_dir = os.path.join(mgmt_app_dir, "web")
    if os.path.exists(web_dir):
        index_tpl_path = os.path.join(web_dir, "index.html.template")
        manifest_tpl_path = os.path.join(web_dir, "manifest.json.template")

        # Copy logo
        if logo_path and logo_path != "icons/Icon-512.png":
            logo_filename = os.path.basename(logo_path)
            logo_dest_dir = os.path.join(web_dir, os.path.dirname(logo_path))
            logo_dest = os.path.join(web_dir, logo_path)

            logo_sources = [
                os.path.join(script_dir, "clients", "logo", logo_filename),
                os.path.join(script_dir, "clients", "logos", logo_filename),
                os.path.join(script_dir, "clients", "assets", logo_filename),
                os.path.join(mgmt_app_dir, "web", logo_path),
                os.path.join(mgmt_app_dir, "assets", "logos", logo_filename),
                os.path.join(mgmt_app_dir, "assets", logo_filename),
            ]

            logo_found = False
            for src in logo_sources:
                try:
                    if os.path.exists(src) and os.path.abspath(src) != os.path.abspath(logo_dest):
                        os.makedirs(logo_dest_dir, exist_ok=True)
                        shutil.copy2(src, logo_dest)
                        logo_found = True
                        break
                except Exception:
                    pass

            if logo_found or os.path.exists(logo_dest):
                logo_dest_192 = os.path.join(web_dir, logo_path_192)
                logo_dest_512 = os.path.join(web_dir, logo_path_512)
                try:
                    subprocess.run(["sips", "-z", "192", "192", logo_dest, "--out", logo_dest_192], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
                    subprocess.run(["sips", "-z", "512", "512", logo_dest, "--out", logo_dest_512], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
                except Exception:
                    try:
                        shutil.copy2(logo_dest, logo_dest_192)
                        shutil.copy2(logo_dest, logo_dest_512)
                    except Exception:
                        pass

        if os.path.exists(index_tpl_path):
            with open(index_tpl_path, 'r', encoding='utf-8') as f:
                tpl = f.read()
            
            html_content = tpl.replace("{{APP_TITLE}}", app_title) \
                              .replace("{{APP_DESCRIPTION}}", app_description) \
                              .replace("{{APP_KEYWORDS}}", keywords) \
                              .replace("{{THEME_COLOR}}", theme_color) \
                              .replace("{{LOGO_PATH}}", logo_path) \
                              .replace("{{HOSTING_SITE}}", target_site)
            
            with open(os.path.join(web_dir, "index.html"), 'w', encoding='utf-8') as f:
                f.write(html_content)
            print(f"  📝 Generated index.html")
        
        if os.path.exists(manifest_tpl_path):
            with open(manifest_tpl_path, 'r', encoding='utf-8') as f:
                tpl = f.read()
                
            manifest_content = tpl.replace("{{APP_TITLE}}", app_title) \
                                  .replace("{{APP_DESCRIPTION}}", app_description) \
                                  .replace("{{THEME_COLOR}}", theme_color) \
                                  .replace("{{LOGO_PATH_192}}", logo_path_192) \
                                  .replace("{{LOGO_PATH_512}}", logo_path_512) \
                                  .replace("{{LOGO_PATH}}", logo_path)
            
            with open(os.path.join(web_dir, "manifest.json"), 'w', encoding='utf-8') as f:
                f.write(manifest_content)
            print(f"  📝 Generated PWA manifest.json")

    print(f"  ✅ Configured successfully!")

    # Log history
    import datetime
    history_path = os.path.join(script_dir, "version_history.md")
    
    if not os.path.exists(history_path):
        with open(history_path, 'w', encoding='utf-8') as f:
            f.write("# 📜 سجل تحديثات وإصدارات العملاء\n\n")
            f.write("| التاريخ والوقت | اسم العميل | رقم الإصدار (Version) | رقم البناء (Build) | نوع العملية (Action) | الحالة (Status) |\n")
            f.write("| :--- | :--- | :--- | :--- | :--- | :--- |\n")
            
    now = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    action_labels = {
        "run": "💻 تشغيل محلي",
        "build-run": "💻 بناء وتشغيل محلي",
        "deploy": "🚀 رفع للاستضافة",
        "config": "⚙️ تهيئة ملفات"
    }
    action_label = action_labels.get(action, f"⚙️ {action}")
    status = "✅ ناجح"
    
    row = f"| {now} | **{client_name.upper()}** | {app_version} | {app_build_index} | {action_label} | {status} |\n"
    
    with open(history_path, 'a', encoding='utf-8') as f:
        f.write(row)
    
    print(f"\n\033[1;32m🎉 Configuration successfully generated for '{client_name}'!\033[0m\n")

if __name__ == '__main__':
    main()
