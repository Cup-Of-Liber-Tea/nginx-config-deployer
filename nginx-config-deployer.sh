#!/bin/bash

# ==============================================================================
# Nginx 설정 배포 스크립트 (v2.1 - 일반용)
#
# 기능:
# 1. Git 저장소의 설정을 /etc/nginx로 동기화 (rsync)
# 2. 배포된 파일들의 소유권 및 권한을 표준에 맞게 재설정
# 3. Nginx 설정 문법 테스트
# 4. Nginx 서비스 무중단 재시작 (reload)
# ==============================================================================

# 스크립트는 반드시 sudo 권한으로 실행되어야 합니다.
if [ "$EUID" -ne 0 ]; then
    echo "🚨 이 스크립트는 sudo 권한으로 실행해야 합니다."
    echo "   예: sudo ./nginx-config-deployer.sh"
    exit 1
fi

# --- 변수 설정 (!!! 사용 전 이 부분을 자신의 환경에 맞게 수정하세요 !!!) ---
# Git으로 관리하는 Nginx 설정 파일이 있는 로컬 디렉토리 경로
CONFIG_SOURCE_PATH="/path/to/your/nginx-config-repo/" 
# Nginx 실제 설정 경로 (대부분의 시스템에서 이 값은 수정할 필요 없음)
NGINX_TARGET_PATH="/etc/nginx/"
# Let's Encrypt 인증서 경로 (대부분의 시스템에서 이 값은 수정할 필요 없음)
LE_LIVE_PATH="/etc/letsencrypt/live/"       
LE_ARCHIVE_PATH="/etc/letsencrypt/archive/"

# ==============================================================================
# STEP 1: 설정 파일 동기화
# ==============================================================================
echo "🚀 STEP 1: Nginx 설정 파일을 동기화합니다..."
echo "   - 원본: ${CONFIG_SOURCE_PATH}"
echo "   - 대상: ${NGINX_TARGET_PATH}"

rsync -av --delete --exclude='.git/' --exclude='.gitignore' --exclude='deploy*.sh' --exclude='backups/' "${CONFIG_SOURCE_PATH}" "${NGINX_TARGET_PATH}"

if [ $? -ne 0 ]; then
    echo "❌ 동기화(rsync) 실패. 배포를 중단합니다."
    exit 1
fi

# ==============================================================================
# STEP 2: 파일 소유권 및 권한 재설정 (가장 중요!)
# ==============================================================================
echo "🛡️ STEP 2: 파일 소유권 및 권한을 재설정합니다..."

# 1. 전체 Nginx 설정 디렉토리 소유권을 root:root로 변경
chown -R root:root "${NGINX_TARGET_PATH}"
if [ $? -ne 0 ]; then
    echo "❌ 소유권 변경 실패. 배포를 중단합니다."
    exit 1
fi

# 2. 일반 파일 및 디렉토리 권한 설정
find "${NGINX_TARGET_PATH}" -type d -exec chmod 755 {} +
find "${NGINX_TARGET_PATH}" -type f -exec chmod 644 {} +

# 3. Let's Encrypt 인증서 관련 권한 재설정 (보안 핵심)
if [ -d "${LE_LIVE_PATH}" ]; then
    echo "   - Let's Encrypt 인증서 권한을 확인 및 재설정합니다..."
    chown -R root:root "${LE_LIVE_PATH}"
    chown -R root:root "${LE_ARCHIVE_PATH}"
    
    find "${LE_LIVE_PATH}" -type d -exec chmod 755 {} +
    find "${LE_LIVE_PATH}" -type f -exec chmod 644 {} +
    # 개인키(privkey.pem)는 root만 읽을 수 있도록 더욱 엄격하게 설정
    find "${LE_LIVE_PATH}" -name "privkey.pem" -exec chmod 600 {} +
fi

# ==============================================================================
# STEP 3: Nginx 설정 구문 테스트
# ==============================================================================
echo "🧪 STEP 3: Nginx 설정 구문 테스트를 실행합니다..."

nginx -t
if [ $? -ne 0 ]; then
    echo "❌ Nginx 설정 테스트 실패. 오류를 수정하고 다시 시도하세요."
    exit 1
fi

# ==============================================================================
# STEP 4: Nginx 서비스 재시작
# ==============================================================================
echo "🔄 STEP 4: Nginx 서비스를 재시작(reload)합니다..."

systemctl reload nginx
if [ $? -ne 0 ]; then
    echo "❌ Nginx 서비스 재시작 실패. 로그를 확인하세요."
    exit 1
fi

echo "✅✨ Nginx 설정이 성공적으로 배포 및 적용되었습니다!"
