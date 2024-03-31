#!/usr/bin/bash

usuario=pepramon

echo "\n\n ATENCIÓN --> Si no estas logueado en Docker Hub, \n\n"\ 
"no se subiran las imagenes automaticamente \n\n"


## Simple-samba, consturcción y push
docker build -t $usuario/simple-samba ./simple-samba/.
docker push $usuario/simple-samba
