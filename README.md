# update-ssl-letsencrypt #

O documento a seguir, tem como objetivo demonstrar uma automação do processo de renovação de certificados SSL Wildcard da Let's Encrypt. No exemplo, estou usando como servidor de Job o Jenkins para renovar o certificado *.techroute.com.br semanalmente, esse job é responsável por executar o processo de renovação na let's encrypt, criar um registro do tipo TXT no DNS (Route 53), receber os certificados e enviá-los para uma bucket S3.

