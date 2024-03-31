#!/usr/bin/bash

usuario=pepramon

logeado=`jq '.auths | length' ~/.docker/config.json`

[ $docker_login_info -eq 0 ] && echo '\n\n No estas logueado en Docker Hub!!!!!\ 
no se subiran las imagenes automaticamente \n\n'


## Simple-samba, consturcción y push
docker build -t $usuario/simple-samba ./simple-samba/.
[ $docker_login_info -ne 0 ] && docker push $usuario/simple-samba
