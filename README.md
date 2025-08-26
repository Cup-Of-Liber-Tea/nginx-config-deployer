# Nginx Config Management Suite

## 🚀 Project Overview

`nginx-config-deployer` is a collection of shell scripts designed to efficiently and safely manage and deploy Nginx configuration files from a Git repository to the `/etc/nginx` path on your server. This suite automates the process of synchronizing configuration files, resetting essential file ownership and permissions, testing Nginx configuration syntax, and performing graceful service reloads.

It aims to reduce the manual effort and potential errors associated with frequent Nginx configuration changes, such as adding new sites or renewing SSL certificates.

## ✨ Key Features

This repository includes the following utility scripts:

### 1. `nginx-config-deployer.sh` (Nginx Configuration Deployment Script)
-   **`rsync` based synchronization**: Efficiently synchronizes Nginx configuration files from your Git repository to `/etc/nginx`. It only copies changed files, excluding `.git/`, `.gitignore`, the scripts themselves, and the `backups/` directory.
-   **Robust permissions and ownership management**: Automatically resets the ownership of deployed Nginx configuration files and Let's Encrypt certificate files to `root:root`, and sets permissions to standard values (`755`, `644`, `600` for private keys) required for Nginx operation, ensuring security and stability.
-   **Configuration syntax testing**: Pre-validates Nginx configuration files using `nginx -t` before applying them to the service, preventing syntax errors.
-   **Zero-downtime service reload**: Utilizes `systemctl reload nginx` to apply configuration changes without interrupting the Nginx service.

### 2. `backup_etc_nginx.sh` (`/etc/nginx` Backup Script)
-   Backs up the entire `/etc/nginx` directory with `sudo` privileges to the `[YOUR_NGINX_CONFIG_REPO_PATH]/backups/` directory, named with a timestamp (e.g., `nginx_backup_YYYYMMDD_HHMMSS`).
-   Uses the `-rp` option to preserve file permissions, ownership, and timestamps.

### 3. `test_git_nginx_config.sh` (Git Repository Nginx Config Test Script)
-   Tests the syntactic validity of Nginx configuration files located in your local Git repository (`[YOUR_NGINX_CONFIG_REPO_PATH]/nginx.conf`).
-   Provides quick feedback during the development phase without affecting the actual `/etc/nginx` service.

## 🛠️ Prerequisites

-   Nginx server must be installed.
-   `rsync` utility must be installed.
-   `systemd` based operating system (e.g., Ubuntu, CentOS).
-   **It is assumed that Nginx configuration files are managed in a separate Git repository, not directly within the system path (`/etc/nginx`).**

## 📦 Installation and Setup

1.  **Clone the repository**: Clone this repository to your desired path on the server (e.g., `[YOUR_NGINX_CONFIG_REPO_PATH]`).
    ```bash
    git clone [this-repo-url] [YOUR_NGINX_CONFIG_REPO_PATH]
    cd [YOUR_NGINX_CONFIG_REPO_PATH]
    ```
2.  **Place Nginx configuration files in your Git repository**: Copy your Nginx configuration files from `/etc/nginx` into the `[YOUR_NGINX_CONFIG_REPO_PATH]` directory to manage them with Git.
    ```bash
    sudo cp -rp /etc/nginx/* [YOUR_NGINX_CONFIG_REPO_PATH]/
    # If necessary, create .git and .gitignore files in [YOUR_NGINX_CONFIG_REPO_PATH]
    cd [YOUR_NGINX_CONFIG_REPO_PATH]
    git init
    git add .
    git commit -m "Initial Nginx config"
    ```
    (If `.git` remains in `/etc/nginx` itself, you should delete it with `sudo rm -rf /etc/nginx/.git`.)
3.  **Grant execute permissions to the scripts**:
    ```bash
    chmod +x [YOUR_NGINX_CONFIG_REPO_PATH]/*.sh
    ```

## 🚀 Usage

### 1. Test Git Repository Configuration

After modifying Nginx configuration files in your Git repository (`[YOUR_NGINX_CONFIG_REPO_PATH]`), check for syntax errors before deployment.

```bash
sudo [YOUR_NGINX_CONFIG_REPO_PATH]/test_git_nginx_config.sh
```

### 2. Backup `/etc/nginx`

Before deploying Nginx configurations, back up the current state of `/etc/nginx`.

```bash
sudo [YOUR_NGINX_CONFIG_REPO_PATH]/backup_etc_nginx.sh
```

### 3. Deploy Nginx Configuration

After successful testing and backup, deploy the changes to your server:

```bash
sudo [YOUR_NGINX_CONFIG_REPO_PATH]/nginx-config-deployer.sh
```

The script will automatically perform the following steps:

1.  Synchronize configuration files from the Git repository to `/etc/nginx`.
2.  Reset ownership and permissions of all configuration files and certificates to standard values.
3.  Test Nginx configuration for syntax errors.
4.  If no errors are found, gracefully reload the Nginx service to apply changes without downtime.

## ⚠️ Important Notes

-   **`--delete` Option**: The `rsync` command within `nginx-config-deployer.sh` includes the `--delete` option. This will **delete** files or directories that exist in the destination path (`/etc/nginx`) but are not present in the Git repository (source). **Ensure that the `/etc/nginx` directory does not contain any critical files not managed by your Git repository.**
-   **`sudo` Privileges**: All scripts require `sudo` privileges to access Nginx configuration and system files.
-   **Let's Encrypt Paths**: The scripts assume Let's Encrypt certificate paths are `/etc/letsencrypt/live/` and `/etc/letsencrypt/archive/`. If you use different paths, you must modify the variables (`LE_LIVE_PATH`, `LE_ARCHIVE_PATH`) within the scripts.

## 📄 License

This project is distributed under the MIT License. See the `LICENSE` file for more details.



# nginx-config-deployer
A robust shell script for safely and efficiently deploying Nginx configuration files from a Git repository to the /etc/nginx directory, ensuring proper permissions and seamless reloads.

# Nginx Config Deployer

## 🚀 프로젝트 소개

`nginx-config-deployer`는 Git 저장소에서 관리되는 Nginx 설정 파일들을 서버의 `/etc/nginx` 경로로 안전하고 효율적으로 배포하기 위한 셸 스크립트입니다. 이 스크립트는 설정 파일 동기화, 필수적인 파일 소유권 및 권한 재설정, Nginx 설정 문법 테스트, 그리고 서비스 무중단 재로드(reload) 과정을 자동화합니다.

잦은 Nginx 설정 변경(예: 새 사이트 추가, SSL 인증서 갱신) 시 발생할 수 있는 수동 작업의 번거로움과 실수를 줄여줍니다.

## ✨ 주요 기능

-   **`rsync` 기반 동기화**: Git 저장소의 Nginx 설정 파일들을 `/etc/nginx`로 효율적으로 동기화합니다. 변경된 파일만 복사하며, `.git/`, `.gitignore`, 스크립트 자신, `backups/` 디렉토리는 제외됩니다.
-   **강력한 권한 및 소유권 관리**: 배포된 Nginx 설정 파일과 Let's Encrypt 인증서 파일들의 소유권을 `root:root`로, 권한을 Nginx 운영에 필요한 표준 값(`755`, `644`, 개인 키는 `600`)으로 자동 재설정하여 보안과 안정성을 확보합니다.
-   **설정 문법 테스트**: Nginx 설정 파일을 서비스에 적용하기 전에 `nginx -t` 명령어로 문법적 오류를 사전에 검사합니다.
-   **무중단 서비스 재로드**: `systemctl reload nginx`를 사용하여 Nginx 서비스를 중단 없이 재시작하여 변경된 설정을 적용합니다.

## 🛠️ 필수 요구 사항

-   Nginx 서버가 설치되어 있어야 합니다.
-   `rsync` 유틸리티가 설치되어 있어야 합니다.
-   `systemd` 기반 시스템 (Ubuntu, CentOS 등)
-    **Nginx 설정 파일이 시스템 경로(`/etc/nginx`)가 아닌 별도의 Git 저장소에서 관리되고 있다는 가정하에 스크립트가 작동합니다.**

## 📦 설치 및 설정

1.  **스크립트 복제**: 이 저장소를 서버의 원하는 경로(예: `[YOUR_NGINX_CONFIG_REPO_PATH]`)에 클론합니다.
    ```bash
    git clone [this-repo-url] [YOUR_NGINX_CONFIG_REPO_PATH]
    cd [YOUR_NGINX_CONFIG_REPO_PATH]
    ```
2.  **Git 저장소에 Nginx 설정 파일 배치**: `/etc/nginx`의 설정 파일들을 `[YOUR_NGINX_CONFIG_REPO_PATH]` 디렉토리에 복사하여 Git으로 관리합니다.
    ```bash
    sudo cp -rp /etc/nginx/* [YOUR_NGINX_CONFIG_REPO_PATH]/
    # 필요한 경우, .git 및 .gitignore 파일을 [YOUR_NGINX_CONFIG_REPO_PATH] 에 생성
    cd [YOUR_NGINX_CONFIG_REPO_PATH]
    git init
    git add .
    git commit -m "Initial Nginx config"
    ```
    (만약 `/etc/nginx` 자체에 .git이 남아있다면, `sudo rm -rf /etc/nginx/.git`으로 삭제해야 합니다.)
3.  **스크립트 실행 권한 부여**:
    ```bash
    chmod +x [YOUR_NGINX_CONFIG_REPO_PATH]/deploy_nginx_config.sh
    ```

## 🚀 사용법

Nginx 설정 파일을 Git 저장소(`[YOUR_NGINX_CONFIG_REPO_PATH]`)에서 변경하고 Git에 커밋한 후, 다음 명령어를 사용하여 서버에 배포합니다:

```bash
sudo [YOUR_NGINX_CONFIG_REPO_PATH]/deploy_nginx_config.sh
```

스크립트가 실행되면 다음 단계들을 자동으로 수행합니다:

1.  Git 저장소의 설정 파일을 `/etc/nginx`로 동기화합니다.
2.  모든 설정 파일과 인증서의 소유권 및 권한을 표준에 맞게 재설정합니다.
3.  Nginx 설정에 문법적 오류가 없는지 테스트합니다.
4.  오류가 없으면 Nginx 서비스를 중단 없이 재로드하여 변경사항을 적용합니다.

## ⚠️ 중요 사항

-   **`--delete` 옵션**: 스크립트 내 `rsync` 명령에는 `--delete` 옵션이 포함되어 있습니다. 이는 대상 경로(`/etc/nginx`)에는 있지만 Git 저장소에는 없는 파일이나 디렉토리를 **삭제**합니다. `/etc/nginx` 디렉토리에는 Git 저장소에서 관리하지 않는 중요한 파일이 없는지 **반드시 확인**하십시오.
-   **`sudo` 권한**: Nginx 설정은 시스템 영역이므로 스크립트는 반드시 `sudo` 권한으로 실행해야 합니다.
-   **Let's Encrypt 경로**: 스크립트는 Let's Encrypt 인증서 경로를 `/etc/letsencrypt/live/` 및 `/etc/letsencrypt/archive/`로 가정합니다. 다른 경로를 사용한다면 스크립트 내 변수(`LE_LIVE_PATH`, `LE_ARCHIVE_PATH`)를 수정해야 합니다.
-   **실행하기전에 backup_etc_nginx.sh로 백업을 진행하고 하세요.

## 📄 라이선스

이 프로젝트는 MIT 라이선스에 따라 배포됩니다. 자세한 내용은 `LICENSE` 파일을 참조하십시오.





