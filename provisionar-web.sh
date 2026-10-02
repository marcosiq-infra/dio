#!/usr/bin/env bash
set -euo pipefail

# Provisionamento de servidor web Apache em Ubuntu/Debian.
if [[ ${EUID} -ne 0 ]]; then
    echo 'Execute: sudo bash provisionar-web.sh' >&2
    exit 1
fi

command -v apt-get >/dev/null || { echo 'Este script requer Ubuntu ou Debian.' >&2; exit 1; }
export DEBIAN_FRONTEND=noninteractive

echo 'Instalando Apache e curl...'
apt-get update
apt-get install -y apache2 curl

# Publica em um diretorio dedicado, preservando outros sites existentes.
install -d -o root -g root -m 0755 /var/www/dio-web
cat > /var/www/dio-web/index.html <<'HTML'
<!doctype html>
<html lang="pt-BR">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Servidor Web — DIO</title>
  <style>
    body { margin: 0; padding: 3rem 1rem; font-family: system-ui, sans-serif; background: #101827; color: #edf3ff; }
    main { max-width: 720px; margin: auto; padding: 2rem; border: 1px solid #354660; border-radius: 16px; }
    h1 { color: #78d8ff; } p { line-height: 1.7; }
  </style>
</head>
<body><main>
  <h1>Servidor web provisionado!</h1>
  <p>Projeto de Infraestrutura como Código da DIO.</p>
  <p>O Apache foi instalado e esta página foi publicada automaticamente por um script Bash.</p>
</main></body>
</html>
HTML
chmod 0644 /var/www/dio-web/index.html

cat > /etc/apache2/sites-available/dio-web.conf <<'APACHE'
<VirtualHost *:80>
    ServerName dio.local
    DocumentRoot /var/www/dio-web
    <Directory /var/www/dio-web>
        Options -Indexes
        AllowOverride None
        Require all granted
    </Directory>
    ErrorLog ${APACHE_LOG_DIR}/dio-web-error.log
    CustomLog ${APACHE_LOG_DIR}/dio-web-access.log combined
</VirtualHost>
APACHE

a2ensite dio-web.conf
apache2ctl configtest

if [[ -d /run/systemd/system ]]; then
    systemctl enable apache2
    systemctl restart apache2
else
    # WSL sem systemd: inicia pelo script de servico.
    service apache2 restart
fi

echo 'Verificando resposta HTTP do site...'
curl --fail --silent --show-error --retry 5 --retry-connrefused --retry-delay 1 \
    -H 'Host: dio.local' http://127.0.0.1/ | grep -q 'Servidor web provisionado!'
echo 'Provisionamento concluido e resposta HTTP validada.'
echo 'Acesse http://dio.local (mapeie dio.local para o IP do servidor no arquivo hosts).'
