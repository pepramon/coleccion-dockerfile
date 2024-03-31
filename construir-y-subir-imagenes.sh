#!/usr/bin/bash

usuario=pepramon

logeado=`jq '.auths | length' ~/.docker/config.json`

echo '\n\n ATENCIÓN --> Si no estas logueado en Docker Hub,'\ 
'no se subiran las imagenes automaticamente \n\n'


## Simple-samba, consturcción y push
docker build -t $usuario/simple-samba ./simple-samba/.
docker push $usuario/simple-samba
