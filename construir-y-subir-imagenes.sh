#!/usr/bin/bash

usuario=pepramon

echo -e "\n\nATENCIÓN --> Si no estas logueado en Docker Hub,\nno se subiran las imagenes automaticamente \n\n"
sleep 1

## Simple-samba, consturcción y push
docker build -t $usuario/simple-samba:latest ./simple-samba/.
docker push $usuario/simple-samba:latest
