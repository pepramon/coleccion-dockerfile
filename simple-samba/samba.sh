#!/usr/bin/env bash
set -Eeuo pipefail

# Setear la variables para utilizar en el script
grupo="smb"
compartida="/almacen"

# Probar si el grupo smb existe, sino, se crea el grupo
if ! getent group "$grupo" &>/dev/null; then
    groupadd "$grupo" || { echo "Fallo creando el grupo $grupo"; exit 1; }
fi

# Probar si el usuario existe, sino se crea
if ! id "$USER" &>/dev/null; then
    adduser -S -D -H -h /tmp -s /sbin/nologin -G "$grupo" -g 'Usuario Samba' "$USER" || { echo "Fallo creando el usuario $USER"; exit 1; }
fi

# Obtener las ID del usuario actual
UIDvieja=$(id -u "$USER")
GIDvieja=$(getent group "$grupo" | cut -d: -f3)

# Cambiar UID y GID del usuario y el grupo si es necesario
if [[ "$UIDvieja" != "$UID" ]]; then
    usermod -u "$UID" "$USER" || { echo "Fallo cambiando UID para usuario $USER"; exit 1; }
fi

if [[ "$GIDvieja" != "$GID" ]]; then
    groupmod -g "$GID" "$grupo" || { echo "Fallo cambiando UID para grupo $grupo"; exit 1; }
fi

# Se cambian permisos de ficheros a nuevas UID y GID excepto del directorio compartido y /etc/samba/smb.custom
find / -path "$compartida" -o -path "/etc/samba/smb.custom" -prune -o -group "$GIDvieja" -exec chgrp -h "$grupo" {} \;
find / -path "$compartida" -o -path "/etc/samba/smb.custom" -prune -o -user "$UIDvieja" -exec chown -h "$USER" {} \;

# Se cambia el password del usuario en samba
echo -e "$PASS\n$PASS" | smbpasswd -a -s "$USER" || { echo "Fallo cambiando el password para el usuario $USER"; exit 1; }

# Se fuerza el usuario y el grupo en smb.conf mediante sed
sed -i "s/^\(\s*\)force user =.*/\1force user = $USER/" "/etc/samba/smb.conf"
sed -i "s/^\(\s*\)force group =.*/\1force group = $grupo/" "/etc/samba/smb.conf"

# Si la variable RW es diferente de true, se cambia valor de 'writable' a no y de 'read only' a yes
if [[ "$RW" != "true" ]]; then
    sed -i "s/^\(\s*\)writable =.*/\1writable = no/" "/etc/samba/smb.conf"
    sed -i "s/^\(\s*\)read only =.*/\1read only = yes/" "/etc/samba/smb.conf"
fi

# Se crea el directorio compartido si no existe y se cambian permisos y propietario de forma recursiva
mkdir -p "$compartida" || { echo "Fallo crando el directorio  $compartida"; exit 1; }
chmod -R 0770 "$compartida" || { echo "Fllo seteando permiso para el directorio $compartida"; exit 1; }
chown -R "$USER:$grupo" "$compartida" || { echo "Fallo asisnando usuario y grupo en el directorio $compartida"; exit 1; }

echo "Arancando samba después de las configuraciones"
# Se arranca samba con las siguientes opciones
#  --foreground: No convertir en demonio
#  --debug-stdout: Enviar debug a stdout
#  --debuglevel=1: Nivel de debug a 1
#  --no-process-group: No crear nuevos procesos
#  --configfile=/etc/samba/smb.custom: Si el fichero /etc/samba/smb.custom existe, tomarlo como configuración en lugar de por defecto
if [ -e "/etc/samba/smb.custom" ]; then
    echo "Arrancando en custom mode"
    exec smbd --configfile=/etc/samba/smb.custom --foreground --debug-stdout --debuglevel=1 --no-process-group
else
    echo "Arrancando con configuración normal"
    exec smbd --foreground --debug-stdout --debuglevel=1 --no-process-group
fi
