![let's encrypt](https://letsencrypt.org/images/letsencrypt-logo-horizontal.svg)
# Atualização automática de certificados SSL wildcard (*.dominio.com.br) com Let's Encrypt #

O documento a seguir, tem como objetivo demonstrar uma automação do processo de renovação de certificados SSL Wildcard da Let's Encrypt. No exemplo, estou usando como servidor de Job o Jenkins para renovar o certificado *.techroute.com.br semanalmente, esse job é responsável por executar o processo de renovação na let's encrypt, criar um registro do tipo TXT no DNS (Route 53), receber os certificados e enviá-los para uma bucket S3.

## Pré-requisitos:

* Bucket S3 - será utilizada para armazenar os certificados gerado a partir do job do jenkins
* Usuário IAM na AWS
* Policy com permissão de mudanças na zona de DNS do Route 53 
* Policy com permissão de escrita (Put) na bucket S3 criada
* Servidor do Jenkins
* Zona de DNS no Route 53

#### Passo 1
Crie uma bucket S3, para demonstração criamos a bucket "certificados-ssl.techroute.com.br"

![alt text](https://s3.amazonaws.com/imagens.techroute.com.br/certificado-1.png)

#### Passo 2
- Crie um usuário IAM na AWS, criei como demonstração o usuário `svc.letsencrypt`
#### Passo 2.1
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
#### Passo 3
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
#### Passo 4
Crie um job `Freestyle project` no Jenkins, para fins de demonstração, definimos o nome `auto-renew-wildcard-ssl-techroute.com.br` defina um nome da sua preferência, clique em [OK] para salvar.
![alt text](https://s3.amazonaws.com/imagens.techroute.com.br/job-1.png)

#### Passo 5
Abra o job criado no passo anterior, no campo `description` insira uma descrição que corresponda com o propósito do job, marque a opção "This project is parameterized", do tipo `String Parameter`, ou seja, job que recebe parâmetros do tipo string, exemplo abaixo:
![alt text](https://s3.amazonaws.com/imagens.techroute.com.br/passo2-job.png)




```shell


```