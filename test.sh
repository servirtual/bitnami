#!/bin/bash

# Ask the user for their name
echo De que dominio vas a descargar wp-content.zip?

read wpcontent

[ -z "$wpcontent" ] && echo "Debes especificar el dominio de donde copiaras wp-content.zip" && exit 1

echo Descargando de: $wpcontent/wp-content.zip

wget $wpcontent/wp-content.zip --directory-prefix=/home/bitnami/stack/wordpress/

echo Restaurando wp-content/ desde wp-content.zip

unzip /home/bitnami/stack/wordpress/wp-content.zip -d /home/bitnami/stack/wordpress/

echo Limpiando archivos obsoletos

rm -f /home/bitnami/stack/wordpress/wp-content.zip

echo Especifica el servidor de base de datos sin puerto

read db_host

[ -z "$db_host" ] && echo "Debes especificar el DB_HOST" && exit 1

echo "Epecifica el nombre de la base de datos. Deja en blanco para usar: dbmaster"

read db_name

[ -z "$db_name" ] && db_name=dbmaster

echo Especifica el usuario de la base de datos, Deja en blanco para usar: dbmasteruser

read db_user

[ -z "$db_user" ] && db_user=dbmasteruser

echo Especifica el password de la base de datos

read db_password

[ -z "$db_password" ] && echo "Debes especificar el DB_PASSWORD" && exit 1


echo "Configurando el acceso a base de datos"

sudo wp config set DB_HOST $db_host:3306
sudo wp config set DB_NAME $db_name
sudo wp config set DB_USER $db_user
sudo wp config set DB_PASSWORD $db_password

echo "Acceso configurado"

echo Datos de la base de datos
echo "========================="
echo DB_HOST: $db_host:3306
echo DB_NAME: $db_name
echo DB_USER: $db_user
echo DB_PASSWORD: $db_password

echo "Generando JWT Secret Key"

jwt_secret=md5sum<<<$(date +"%T")

echo Secret generado: $jwt_secret


