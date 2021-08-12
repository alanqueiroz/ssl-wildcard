# Atualização automática de certificados SSL wildcard do Let's Encrypt #

O documento a seguir, tem como objetivo demonstrar uma automação do processo de renovação de certificados SSL Wildcard da Let's Encrypt. No exemplo, estou usando como servidor de Job o Jenkins para renovar o certificado *.techroute.com.br semanalmente, esse job é responsável por executar o processo de renovação na let's encrypt, criar um registro do tipo TXT no DNS (Route 53), receber os certificados e enviá-los para uma bucket S3.

# Pré-requisitos:

* Bucket S3 - será utilizada para armazenar os certificados gerado a partir do job do jenkins
* Usuário IAM com permissão de escrita na bucket S3
* Servidor do Jenkins
* Zona de DNS no Route 53

# Passo 1 
Crie um usuário IAM na AWS com permissão de escrita na bucket S3

