#!/usr/bin/env bash
set -euo pipefail

# Infraestrutura de usuarios e grupos para o desafio DIO.
# Execute em uma VM de laboratorio dedicada.
if [[ ${EUID} -ne 0 ]]; then
    echo 'Execute como root: sudo bash iac.sh' >&2
    exit 1
fi

for command in getent groupadd useradd usermod install chown chmod; do
    command -v "$command" >/dev/null || { echo "Comando ausente: $command" >&2; exit 1; }
done

for group in GRP_ADM GRP_VEN GRP_SEC; do
    getent group "$group" >/dev/null || groupadd "$group"
done

create_user() {
    local username=$1 group=$2
    if getent passwd "$username" >/dev/null; then
        usermod -aG "$group" "$username"
    else
        # Sem senha padrao: conta criada bloqueada ate definir senha.
        useradd -m -s /bin/bash -G "$group" "$username"
    fi
}

for username in carlos maria joao; do create_user "$username" GRP_ADM; done
for username in debora sebastiana roberto; do create_user "$username" GRP_VEN; done
for username in josefina amanda rogerio; do create_user "$username" GRP_SEC; done

install -d -o root -g root -m 1777 /publico
install -d -o root -g GRP_ADM -m 2770 /adm
install -d -o root -g GRP_VEN -m 2770 /ven
install -d -o root -g GRP_SEC -m 2770 /sec

echo 'Infraestrutura configurada.'
echo 'Para habilitar login de um usuario novo, defina sua senha: sudo passwd <usuario>'
