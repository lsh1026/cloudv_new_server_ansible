# 신규 서버 초기 설정 Ansible 구조

이 프로젝트는 아래 항목만 자동화하도록 구성되어 있습니다.

- 시간 동기화
- history 관련 설정
- 커널 업데이트
- vim 작업
- 루트권한 계정 설정
- sshd root 로그인 제한
- SELinux 설정 (Rocky 전용)
- iptables 설정
- vsftpd 설정

지원 대상:
- Ubuntu 22.04 ~ 26.04
- Rocky Linux 8 ~ 10
- Rocky 10에서는 iptables role을 자동 제외

문서 기준으로 필수/요청 항목은 다음과 같습니다: 매시간 동기화, history 시간/사용자/IP 표시, 커널 업데이트, vim 설정, 루트 권한 계정 설정, root SSH 접속 제한, Red Hat 계열 SELinux disabled, 요청 시 iptables/vsftpd 설치.

## 실행

```bash
cd ansible_new_server_baseline
./run_setup.sh
```

스크립트가 아래를 프롬프트로 받습니다.

- 대상 서버 IP
- SSH 포트
- SSH 접속 계정
- 패스워드 인증 여부
- 각 설정 항목 적용 여부
- 루트 권한 계정 설정 시 생성/관리할 사용자명

## 주의

1. 시간 동기화는 최신 OS에 맞춰 chrony 기반으로 구현했습니다.
2. 커널 업데이트 role은 Rocky에서만 동작합니다.
3. SELinux role은 Rocky에서만 동작합니다.
4. iptables role은 Rocky 10에서 자동 스킵됩니다.
5. root SSH 접속 제한을 먼저 적용하면 이후 root 직접 접속은 막힐 수 있으니, 대체 관리자 계정이 준비된 뒤 적용하는 것이 안전합니다.
6. 루트 권한 계정 설정은 `wheel` 기반 `su` 제한까지 포함합니다. Ubuntu에서는 문서에 맞춰 `wheel` 그룹을 별도로 생성합니다.

## 구조

```text
ansible_new_server_baseline/
├── ansible.cfg
├── inventory.ini
├── playbooks/
│   └── site.yml
├── roles/
│   ├── time_sync/
│   ├── history_profile/
│   ├── kernel_update/
│   ├── vim_setup/
│   ├── privileged_account/
│   ├── sshd_root_login_disable/
│   ├── selinux_disable/
│   ├── iptables_setup/
│   └── vsftpd_setup/
└── run_setup.sh
```
