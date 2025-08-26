#!/bin/bash

# ==============================================================================
# Nginx 설정 자동 백업 스크립트 (v1.0 - 일반용)
#
# 기능:
# 1. /etc/nginx 디렉토리 전체를 타임스탬프가 찍힌 .tar.gz 압축 파일로 백업
# 2. 지정된 기간이 지난 오래된 백업 파일은 자동으로 삭제
# ==============================================================================

# 스크립트는 반드시 sudo 권한으로 실행되어야 합니다.
if [ "$EUID" -ne 0 ]; then
    echo "🚨 이 스크립트는 sudo 권한으로 실행해야 합니다."
    echo "   예: sudo ./backup_nginx_config.sh"
    exit 1
fi

# --- 변수 설정 (!!! 사용 전 이 부분을 자신의 환경에 맞게 수정하세요 !!!) ---
# 백업을 저장할 디렉토리 경로
BACKUP_DIR="/path/to/your/backup/location/"
# 백업 대상 디렉토리 (대부분의 시스템에서 이 값은 수정할 필요 없음)
NGINX_CONFIG_PATH="/etc/nginx"
# 백업 보관 기간 (일 단위, 예: 7일이 지난 파일은 삭제)
RETENTION_DAYS=7

# ==============================================================================
# STEP 1: 백업 디렉토리 확인 및 생성
# ==============================================================================
echo "📂 STEP 1: 백업 디렉토리를 확인합니다..."
echo "   - 경로: ${BACKUP_DIR}"

mkdir -p "${BACKUP_DIR}"
if [ $? -ne 0 ]; then
    echo "❌ 백업 디렉토리 생성 실패. 경로와 권한을 확인하세요."
    exit 1
fi

# ==============================================================================
# STEP 2: Nginx 설정 백업 실행
# ==============================================================================
# 날짜 및 시간 형식 지정 (예: nginx_backup_20250826_183000.tar.gz)
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_FILENAME="nginx_backup_${DATE}.tar.gz"
BACKUP_FILE_PATH="${BACKUP_DIR}/${BACKUP_FILENAME}"

echo "🚀 STEP 2: Nginx 설정 백업을 시작합니다..."
echo "   - 원본: ${NGINX_CONFIG_PATH}"
echo "   - 대상 파일: ${BACKUP_FILE_PATH}"

# tar 명령어로 디렉토리를 하나의 압축 파일로 백업
# c: 새로운 아카이브 생성, z: gzip으로 압축, f: 파일명 지정, p: 권한 보존
tar -czpf "${BACKUP_FILE_PATH}" -C "$(dirname "${NGINX_CONFIG_PATH}")" "$(basename "${NGINX_CONFIG_PATH}")"

if [ $? -ne 0 ]; then
    echo "❌ Nginx 설정 백업 실패!"
    exit 1
fi

echo "   - 백업 파일 생성 완료!"

# ==============================================================================
# STEP 3: 오래된 백업 파일 정리
# ==============================================================================
echo "🧹 STEP 3: 오래된 백업 파일(${RETENTION_DAYS}일 경과)을 정리합니다..."

# find 명령어로 지정된 기간이 지난 백업 파일 검색 후 삭제
find "${BACKUP_DIR}" -type f -name "nginx_backup_*.tar.gz" -mtime +${RETENTION_DAYS} -exec echo "   - 삭제: {}" \; -exec rm {} \;

echo "✅✨ Nginx 설정 백업이 성공적으로 완료되었습니다!"
