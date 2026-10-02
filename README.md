# Infraestrutura como Codigo — DIO

Script Bash que automatiza a criacao de grupos, usuarios, diretorios e permissoes em Linux. Estrutura adotada para o desafio, pois a descricao fornecida nao especifica os nomes.

## Estrutura

| Diretorio | Grupo | Usuarios | Permissao |
| --- | --- | --- | --- |
| `/adm` | `GRP_ADM` | carlos, maria, joao | `2770` |
| `/ven` | `GRP_VEN` | debora, sebastiana, roberto | `2770` |
| `/sec` | `GRP_SEC` | josefina, amanda, rogerio | `2770` |
| `/publico` | root | Todos | `1777` |

O proprietario dos diretorios e root. Nos diretorios departamentais, apenas root e o grupo correspondente possuem acesso. O bit setgid faz novos arquivos herdarem o grupo do diretorio. No diretorio publico, o sticky bit impede que um usuario apague arquivos de outro.

## Executar

Use uma VM Linux de laboratorio dedicada, com Bash e os utilitarios de administracao de usuarios instalados. O script altera usuarios e diretorios reais da maquina, inclusive permissoes de diretorios existentes com os mesmos nomes.

```bash
bash -n iac.sh
sudo bash iac.sh
```

O script pode ser executado novamente: grupos e usuarios existentes nao sao recriados; a associacao aos grupos e as permissoes dos diretorios sao reaplicadas. Grupos adicionais de usuarios existentes sao preservados. Uma falha interrompe a execucao sem desfazer etapas anteriores; corrija a causa e execute novamente.

Usuarios novos possuem diretorio pessoal, shell Bash e senha bloqueada. Nenhuma senha e armazenada no repositorio. Para habilitar login:

```bash
sudo passwd carlos
```

## Verificar apos executar

```bash
getent group GRP_ADM GRP_VEN GRP_SEC
id carlos
id debora
id josefina
stat -c '%a %U %G %n' /publico /adm /ven /sec
sudo -u carlos test -w /adm && echo 'ADM: escrita permitida'
if sudo -u debora test -w /adm; then
    echo 'ERRO: VEN possui acesso ao ADM'
else
    echo 'VEN: acesso ao ADM bloqueado'
fi
```

## Publicar a partir do WSL

```bash
mkdir -p ~/projetos
cd ~/projetos
git clone https://github.com/marcosiq-infra/dio.git
cd dio
cp /mnt/c/Users/MarcoSiqueira/Documents/Codex/2026-10-01/te/outputs/{iac.sh,README.md} .
chmod +x iac.sh
bash -n iac.sh
git add iac.sh README.md
git commit -m "Adiciona infraestrutura de usuarios, grupos e permissoes"
git push
```

Se o repositorio remoto estiver vazio e nao houver upstream, use `git push -u origin HEAD`. A autenticacao no GitHub deve estar configurada no WSL. Confira arquivos existentes antes de copiar, pois a copia substitui arquivos com os mesmos nomes.



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
