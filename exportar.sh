#!/bin/bash

# EXPORTAR

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
  echo "Especifica la ruta de WordPress [/home/bitnami/apps/wordpress/htdocs]"
  read wp_absolute_path
  [ -z "$wp_absolute_path" ] && wp_absolute_path=/home/bitnami/apps/wordpress/htdocs
  [ ! -d "$wp_absolute_path" ] && echo "${red}La ruta no existe${reset}" && exit 1
  echo "Ruta seleccionada: ${green}$wp_absolute_path${reset}"
}

backup_content() {
  echo "Creando respaldo"
  zip -r $wp_absolute_path/wp-content.zip -d $wp_absolute_path
  echo "${green}Contenido respaldado correctamente${reset}"
}

show_settings() {
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
backup_content
separator
show_settings