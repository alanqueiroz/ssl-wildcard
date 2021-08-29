![let's encrypt](https://letsencrypt.org/images/letsencrypt-logo-horizontal.svg)
# Atualização automática de certificados SSL wildcard (*.dominio.com.br) com Let's Encrypt #

O documento a seguir, tem como objetivo demonstrar uma automação do processo de renovação de certificados SSL Wildcard da Let's Encrypt. No exemplo, estou usando como servidor de Job o Jenkins para renovar o certificado *.techroute.com.br semanalmente, esse job é responsável por executar o processo de renovação na let's encrypt, criar um registro do tipo TXT no DNS (Route 53), receber os certificados e enviá-los para uma bucket S3.

## Pré-requisitos:

* Bucket S3 - será utilizada para armazenar os certificados gerado a partir do job do jenkins
* Usuário IAM (acesso apenas programático) na AWS
* Os seguintes pacotes instalados no sistema operacional do Jenkins ( `awscli  python3-certbot-nginx e python3-certbot-dns-route53` )
* Policy com permissão de mudanças na zona de DNS do Route 53 
* Policy com permissão de escrita (Put) na bucket S3 criada
* Servidor do Jenkins
* Zona de DNS no Route 53

#### Passo 1
```shell
sudo apt-get install awscli  python3-certbot-nginx e python3-certbot-dns-route53
```
#### Passo 2
Crie uma bucket S3, para demonstração criamos a bucket "certificados-ssl.techroute.com.br"

![alt text](https://s3.amazonaws.com/imagens.techroute.com.br/certificado-1.png)

#### Passo 3
- Crie um usuário IAM na AWS, criei como demonstração o usuário `svc.letsencrypt`
#### Passo 3.1
Crie uma policy IAM, com permissão de mudanças na zona de DNS do Route 53 e atache essa policy ao usuário criado no passo anterior, lembre-se de alterar o campo $ID_DA_ZONA pelo ID da sua zona de DNS.
```shell
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "route53:ListHostedZones",
                "route53:GetChange"
            ],
            "Resource": [
                "*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "route53:ChangeResourceRecordSets"
            ],
            "Resource": [
                "arn:aws:route53:::hostedzone/$ID_DA_ZONA"
            ]
        }
    ]
}
```
#### Passo 4
Crie uma policy IAM com permissão de escrita (Put) na bucket criada no passo 1 e atache ao usuário IAM `svc.letsencrypt`
```shell
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": "s3:PutObject",
            "Resource": "arn:aws:s3:::certificados-ssl.techroute.com.br/*"
        },
        {
            "Sid": "VisualEditor1",
            "Effect": "Allow",
            "Action": "s3:ListAllMyBuckets",
            "Resource": "*"
        }
    ]
}
```
#### Passo 5
Crie um job `Freestyle project` no Jenkins, para fins de demonstração, definimos o nome `auto-renew-wildcard-ssl-techroute.com.br` defina um nome da sua preferência, clique em [OK] para salvar.
![alt text](https://s3.amazonaws.com/imagens.techroute.com.br/job-1.png)

#### Passo 6
Abra o job criado no passo anterior, no campo `description` insira uma descrição que corresponda com o propósito do job, marque a opção "This project is parameterized", do tipo `String Parameter`, ou seja, job que recebe parâmetros do tipo string, exemplo abaixo:
![alt text](https://s3.amazonaws.com/imagens.techroute.com.br/passo2-job.png)

#### Passo 7
Adicione um novo parâmetro, clicando em `[Add Parameter]` o tipo do parâmetro será `Credentials Parameter`
![alt text](https://s3.amazonaws.com/imagens.techroute.com.br/passo-3-job.png)

#### Passo 7.1
Em `Credential type` selecione `AWS Credentials` em `Default Value` clique em [Add] -> [Jenkins], esse passo é necessário se você ainda não tem a credencial AWS cadastrada no seu Jenkins. Insira um descritivo para credencial que está sendo cadastrada, preencha os campos conforme a imagem e clique em `[Add]`
![alt text](https://s3.amazonaws.com/imagens.techroute.com.br/passo-5-job-atualizada.png)

![alt text](https://s3.amazonaws.com/imagens.techroute.com.br/passo-6-job.png)

#### Passo 8
Desça a barra de rolagem para baixo e na sessão `Build Triggers` marque o item `Build periodically` defina os dias que deseja que o job seja executado, na demonstração, defini a execução todos os sábados às 21:00 
![alt text](https://s3.amazonaws.com/imagens.techroute.com.br/passo-7-job.png)

#### Passo 9
Na sessão `Build`, selecione a opção `Execute Shell` e insira o script abaixo:

```shell
WORKSPACE="/var/lib/jenkins/workspace/update-letsencrypt-route53-techroute.com.br"
ARCHIVE="/var/lib/jenkins/workspace/update-letsencrypt-route53-techroute.com.br/config/archive"
LIVE="/var/lib/jenkins/workspace/update-letsencrypt-route53-techroute.com.br/config/live"

mkdir -p $WORKSPACE $ARCHIVE $LIVE
sudo chown -R jenkins:jenkins $WORKSPACE $ARCHIVE $LIVE
cd $LIVE
sudo rm -rf $DOMINIO_DO_CLIENTE*
cd $ARCHIVE
sudo rm -rf $DOMINIO_DO_CLIENTE* $CLIENTE
sudo /usr/bin/certbot certonly --agree-tos --email alanqueiroz@outlook.com --config-dir $WORKSPACE/config --logs-dir $WORKSPACE/logs --work-dir $WORKSPACE/work --dns-route53 -n -d *.${DOMINIO_DO_CLIENTE} --server https://acme-v02.api.letsencrypt.org/directory
cd $DOMINIO_DO_CLIENTE*
sudo mv privkey* $CLIENTE-private.key
sudo mv fullchain* $CLIENTE-fullchain.pem
sudo mv cert* $CLIENTE-cert.pem
cd -
sudo mv $DOMINIO_DO_CLIENTE* $CLIENTE
sudo chown -R jenkins:jenkins $WORKSPACE
```