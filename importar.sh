#!/bin/bash

red=$(tput setaf 1)
green=$(tput setaf 2)
reset=$(tput sgr0)

new_line () {
  printf "\n"
}
double_line () {
 printf "\n\n"
}
separator () {
  new_line
  printf "==============================================="
  double_line
}

get_absolute_path () {
  echo "Especifica la ruta de WordPress [/home/bitnami/stack/wordpress/]"
  read wp_absolute_path
  [ -z "$wp_absolute_path" ] && wp_absolute_path=/home/bitnami/stack/wordpress/
  [ ! -d "$wp_absolute_path" ] && echo "${red}La ruta no existe${reset}" && exit 1
  echo "Ruta seleccionada: ${green}$wp_absolute_path${reset}"
}

get_domain () {
  echo "Debes descargar el archivo wp-content.zip previamente generando en el dominio de origen."
  echo "Utiliza solo el dominio. ejemplo:"
  echo "  - lms.servirtual.cl"
  echo "  - otecnia.cl"
  new_line
  echo "Especifica el dominio"
  read domain
  [ -z "$domain" ] && echo "${red}Debes especificar el dominio de donde copiaras wp-content.zip${reset}" && exit 1
  url="https://$domain/wp-content.zip"
  echo "URL de descarga: ${green}$url${reset}"
}

restore_content() {
  echo "Descargando: $url en $wp_absolute_path"
  wget $url --directory-prefix=$wp_absolute_path
  [ ! -f $wp_absolute_path/wp-content.zip ] && echo "${red}Hubo un problema con la descarga. Verifica que la ruta sea correcta${reset}" && exit 1;
  echo "Restaurando archivos"
  unzip $wp_absolute_path/wp-content.zip -d $wp_wp_absolute_path
  echo "Limpiando archivos obsoletos"
  rm -f $wp_absolute_path/wp-content.zip
  echo "${green}Contenido importado correctamente${reset}"
}

set_config() {
  echo "Especifica el servidor de base de datos sin puerto"
  read db_host
  [ -z "$db_host" ] && echo "Debes especificar el DB_HOST" && exit 1

  echo "Epecifica el nombre de la base de datos. [dbmaster]"
  read db_name
  [ -z "$db_name" ] && db_name=dbmaster

  echo "Especifica el usuario de la base de datos. [dbmasteruser]"
  read db_user
  [ -z "$db_user" ] && db_user=dbmasteruser

  echo "Especifica el password de la base de datos"
  read db_password
  [ -z "$db_password" ] && echo "Debes especificar el DB_PASSWORD" && exit 1

  echo "Especifica el prefijo de la base de datos. [wp_]"
  read db_prefix
  [ -z "$db_prefix" ] && db_prefix=wp_


  chmod 664 $wp_absolute_path/wp-config.php
  echo "Configurando el acceso a base de datos"

  wp config set DB_HOST $db_host:3306 --allow-root
  wp config set DB_NAME $db_name --allow-root
  wp config set DB_USER $db_user --allow-root
  wp config set DB_PASSWORD $db_password --allow-root
  wp config set table_prefix $db_prefix --allow-root

  chmod 640 $wp_absolute_path/wp-config.php
  echo "Acceso configurado"
}

set_extra_config() {
  chmod 664 $wp_absolute_path/wp-config.php

  echo "Generando JWT Secret Key"
  wp config set JWT_AUTH_SECRET_KEY $db_password --allow-root

  echo "Configurando Learndash"
  wp config set LEARNDASH_DISABLE_TEMPLATE_CONTENT_OUTSIDE_LOOP false --raw --allow-root

  chmod 640 $wp_absolute_path/wp-config.php
  echo "Asegurando wp-config"

}

set_permissions() {
  echo "Estableciendo permisos a wp-content"

  chown -R bitnami:daemon $wp_absolute_path
  chown -R daemon:daemon $wp_absolute_path/wp-content/plugins/
  chown -R daemon:daemon $wp_absolute_path/wp-content/themes/
  chown -R daemon:daemon $wp_absolute_path/wp-content/uploads/
  chown -R daemon:daemon $wp_absolute_path/wp-content/cache/
  find $wp_absolute_path -type d -exec chmod 775 {} \;
  find $wp_absolute_path -type f -exec chmod 664 {} \;

  echo "Permisos actualizados"
}

set_postman_user() {
  echo "Generando usuario para Postman"
  wp user create postman postman@postman-no.main --role=administrator --user_pass=Ev:K-suEkxnC?z8r --allow-root
  if [ $? -eq 0 ];
  then
    echo "El usuario ya existe"
  else
    echo "Usuario generado"
  fi
}


double_line
get_absolute_path
separator
get_domain
separator
restore_content
separator
set_config
separator
set_extra_config
separator
set_permissions
separator
set_postman_user
separator