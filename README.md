# Kerberos to Samba 4
Baseado no artigo [Syncing passwords from MIT Kerberos to Samba 4](https://pi.math.cornell.edu/~gaarder/mit-samba-sync.html) e usa o código do [od2samba4](https://github.com/physcip/od2samba4), mas atualizado para Python 3.

## Como usar?
É necessário dispor de uma instalação de Samba 4 com algumas configurações extras.

### Lado do servidor samba

```bash
# dada como pronta a instalação do Samba 4
apt install ldb-tools

# trocar passwd age no samba
samba-tool domain passwordsettings set --min-pwd-age=0
samba-tool domain passwordsettings set --max-pwd-age=0

# criar usuário no samba com unixattrs uid
samba-tool user create foo FooBar1 --uid=foo

# ou modificar o usuário no samba para que contenha uid
samba-tool user addunixattrs foo 31415 --gid=31415

# proceder com os passos da migração (abaixo) até gerar o sethashes.ldif

# o oid abaixo é para permitir sobrescrita de senha
ldbmodify sethashes.ldif -H /var/lib/samba/private/sam.ldb --controls=local_oid:1.3.6.1.4.1.7165.4.3.12:0 -vvvv
 
```

### Lado do migrador
O migrador pode ser rodado em conjunto do Samba, mas é preferível deixá-lo de fora dado que há a necessidade de instalar o `heimdal`.
```bash
apt install git heimdal-clients heimdal-kdc python3-ldap python3-samba

# não queremos rodar o kdc do heimdal
systemctl disable heimdal-kdc
systemctl stop heimdal-kdc
 
# clonar o krb2samba
git clone https://github.com/wgnann/krb2samba
 
# configurar o od2samba4.conf de acordo com o exemplo
 
# obter a chave do kerberos localizada em /etc/krb5kdc/stash
# colocá-la em krb2samba/in/kdc_master_key
# OBS: parâmetro master_key na configuração
 
# gerar o dump de usuário no servidor kerberos
kdb5_util dump -b7 foo.mit foo@IME.USP.BR

# também é possível gerar o dump de todos os usuários com o gen_dump.sh
 
# colocar o dump em krb2samba/in/kdc_dump.mit
# OBS: parâmetro mit_dump na configuração
 
# converter as hashes, que ficarão em out/sethashes.ldif
python3 extract_hashes.py
python3 convert_hashes.py
 
# copiar o sethashes.ldif para o samba
```
