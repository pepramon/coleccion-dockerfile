# Implementación sencilla de Samba

Implementación sencilla de samba, está pensada para que SOLO comparta un directorio para un usuario que se debe incluir en la configuración.

Por defecto asigna los ficheros al usuario con UID=1000 y al grupo GUD=1000, aunque puede cambiarse en la configuración mediante variables de entorno.

Esta basado en [https://github.com/dockur/samba](https://github.com/dockur/samba) donde se han hecho pull request, aunque al final se ha preferido tener repositorio propio.

Repositorio --> [https://github.com/pepramon/coleccion-dockerfile](https://github.com/pepramon/coleccion-dockerfile)

## Como usar

Via `docker-compose`

```yaml
version: "3"
services:
  samba:
    image: pepramon/simple-samba
    restart: on-failure
    environment:
      USER: "samba"
      PASS: "secret"
      UID: 1000    # Opcional, por defecto 1000
      GID: 1000    # Opcional, por defecto 1000
      RW: true     # Opcional, por defecto true
    ports:
      - 445:445
    volumes:
      - ./almacen:/almacen
```

Via `docker run`

```bash
docker run -it --rm -p 445:445 -v "./almacen:/almacen" -e "USER=samba" -e "PASS=secret" pepramon/simple-samba
```

## FAQ

 * ### ¿Como modificar la configuración?

   * #### Usuario y contraseña
   
     Para cambiar y definir el usuario y la contraseña, hay que definir las variables de entorno USER y PASS y automaticamente se cambiarán los permisos de los ficheros para el usuario indicado.
   
   * #### Lugar de la carpeta compartida
   
     Hay que cambiar en volumes en lugar donde apunta.
     
     ATENCIÓN Al arrancar el contenedor cambiará los permisos de todos los ficheros de la carpeta al UID y GID indicados en la variables de entorno o a UID=1000 y GID=1000.

   * #### Modo solo lectura
   
     Si se desea realizar una compartición en modo solo lectura, se debe definir la variable RW a un valor diferente de true, por ejemplo *RW=false*, en tal caso, el usuario configurado solo tendrá derecho de lectura de la carpeta.
   
   * #### Smb.conf personalizado
   
     Para utilizar un smb.conf personalizado, el contenedor vigila que no exista el fichero */etc/samba/smb.custom*, en caso de existir, tomará la configuración de ese fichero en lugar del fichero por defecto.

       ```yaml
       volumes:
          - /example/smb.custom:/etc/samba/smb.custom
       ```
