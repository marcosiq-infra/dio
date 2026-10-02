# DIO — Provisionamento automatico de servidor web

O script `provisionar-web.sh` instala o Apache e curl em Ubuntu/Debian, publica uma pagina HTML e configura um site chamado `dio.local` na porta 80. Ao final, valida a configuracao do Apache e a resposta HTTP do site.

## Executar

Use uma VM de laboratorio Ubuntu/Debian ou seu WSL com acesso a internet:

```bash
bash -n provisionar-web.sh
sudo bash provisionar-web.sh
```

O script exige root, instala pacotes e reinicia o Apache. Uma aplicacao que ja ocupe a porta 80 pode impedir a inicializacao. Sites existentes sao preservados; o script gerencia `/var/www/dio-web/index.html` e `/etc/apache2/sites-available/dio-web.conf`, substituindo esses dois arquivos a cada execucao. Pode ser executado novamente.

Com systemd, habilita o Apache para iniciar no boot. No WSL sem systemd, inicia o servico apenas na sessao atual; depois de reiniciar o WSL, execute `sudo service apache2 start`.

## Testar

```bash
curl -H 'Host: dio.local' http://localhost/
sudo apache2ctl configtest
```

Para abrir no navegador do Windows com o WSL local, adicione `127.0.0.1 dio.local` ao arquivo `C:\Windows\System32\drivers\etc\hosts` com permissao de administrador, e acesse `http://dio.local`. Em uma VM remota, use o IP da VM no mapeamento. O firewall e as regras de rede precisam permitir TCP na porta 80 para acesso externo. Sem o nome `dio.local`, outro site Apache existente pode responder a requisicao.

## Publicar no repositorio existente pelo WSL

```bash
cd ~/projetos/dio
cp /mnt/c/Users/MarcoSiqueira/Documents/Codex/2026-10-01/te/outputs/{provisionar-web.sh,README-web.md} .
chmod +x provisionar-web.sh
bash -n provisionar-web.sh
git add provisionar-web.sh README-web.md
git commit -m "Adiciona provisionamento automatico de servidor Apache"
git push
```

A pagina e um exemplo incluido no script. Se a atividade fornecer um site especifico, adapte a publicacao para os arquivos exigidos. Este exemplo usa HTTP para o laboratorio; certificados HTTPS nao sao configurados.
