#!/usr/bin/env bash
set -euo pipefail

BASE_DIR="$(cd "$(dirname "$0")" && pwd)"
PLAYBOOK="$BASE_DIR/playbooks/site.yml"

read -rp "타겟 서버ip: " TARGET_IP
read -rp "SSH port 입력: " SSH_PORT
SSH_PORT=${SSH_PORT:-22}
read -rp "SSH user 입력 [root]: " SSH_USER
SSH_USER=${SSH_USER:-root}
read -rp "SSH 접근시 패스워드 인증이 설정되어있나요?[y]: " USE_PASSWORD
read -rp "시간동기화를 설정할까요? [y/n]: " APPLY_TIME_SYNC
read -rp "history 설정할까요?? [y/n]: " APPLY_HISTORY
read -rp "업데이트를 할까요? [y/n]: " APPLY_KERNEL_UPDATE
read -rp "vim 셋팅할까요?? [y/n]: " APPLY_VIM
read -rp "sudo 권한 일반사용자를 생성할까요? [y/n]: " APPLY_PRIVILEGED
PRIVILEGED_USERNAME=""
if [[ "${APPLY_PRIVILEGED,,}" == "y" ]]; then
  read -rp "생성할 일반사용자 이름을 입력해주세요: " PRIVILEGED_USERNAME
fi
read -rp "SSH root접근을 허용할까요? [y/n]: " APPLY_SSHD_ROOT_DISABLE
read -rp "SELinux를 비활성화할까요? (Rocky only) [y/n]: " APPLY_SELINUX
read -rp "iptables 설치할까요? (Rocky 10은 미지원) [y/n]: " APPLY_IPTABLES
read -rp "vsftpd 설치할까요? [y/n]: " APPLY_VSFTPD

bool() {
  case "${1,,}" in
    y|yes|true|1) echo true ;;
    *) echo false ;;
  esac
}

EXTRA_VARS=$(cat <<JSON
{
  "ansible_port": ${SSH_PORT},
  "apply_time_sync": $(bool "$APPLY_TIME_SYNC"),
  "apply_history": $(bool "$APPLY_HISTORY"),
  "apply_kernel_update": $(bool "$APPLY_KERNEL_UPDATE"),
  "apply_vim": $(bool "$APPLY_VIM"),
  "apply_privileged_account": $(bool "$APPLY_PRIVILEGED"),
  "privileged_username": "${PRIVILEGED_USERNAME}",
  "apply_sshd_root_disable": $(bool "$APPLY_SSHD_ROOT_DISABLE"),
  "apply_selinux_disable": $(bool "$APPLY_SELINUX"),
  "apply_iptables": $(bool "$APPLY_IPTABLES"),
  "apply_vsftpd": $(bool "$APPLY_VSFTPD")
}
JSON
)

ssh-keygen -f "$HOME/.ssh/known_hosts" -R "$TARGET_IP" 2>/dev/null

CMD=(ansible-playbook "$PLAYBOOK" -i "${TARGET_IP}," -u "$SSH_USER" -e "$EXTRA_VARS")


if [[ "${USE_PASSWORD,,}" == "y" ]]; then
  CMD+=(--ask-pass --ask-become-pass)
fi

echo
echo "Running: ${CMD[*]}"
echo
"${CMD[@]}"
