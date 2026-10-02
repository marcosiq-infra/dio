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
