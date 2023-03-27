#! /bin/bash -p

export LANG=en_US.UTF-8

# VARIABLES GLOBALES

FECHA=$(date +%d%m%y)
RUTA=$(pwd)
HORA=$(date +%H:%M)



#########################################
#        SCRIPT HARDENIZACION           #
#########################################

#########################################
#                Funciones              #
#########################################
continua()
{
  printf "\n\n\nPress ENTER to continue ..."
  read enter
}

 
#########################################
#                 MAIN                  #
#########################################

clear
if [ -f $0.flag ]
     then
        clear
        echo ""
        echo " Ya hay un usuario usando este menu "
        echo ""
        continua
        exit 0
        else
        touch  $0.flag 
fi
     trap 'rm -f $0.flag' EXIT


while true
do

  printf "\f"
  cat <<EOF
 
#######################################################
#                                                     #
#            Mini Menu Hardenizacion                  #
#                                                     #
#              Fecha -> 28/03/2023                    #
#                                                     #
#     v1.0  -- Miguel Angel de Arriba Gutierrez       #
#                                                     #
#######################################################

NOTAS: 
        - Para todas las opciones se usa el fichero ficheros/master_maquinas.txt -> Listado de maquinas (unicas) y red con formato: ID;MAQUINA;RED;ENTORNO;APLICATIVOS 
        - Para la opcion 1 ademas -> unlock_users.txt -> Listado de maquinas y usuarios a tratar con formato: MAQUINA;USUARIO
        - Para la opcion 2 ademas -> workaround_shadow.txt -> Listado de maquinas y usuarios a tratar con formato: MAQUINA;USUARIO


=========================================
               MAIN MENU
=========================================



 1.  DESBLOQUEO USUARIOS
 2.  WORKAROUND SHADOW USUARIOS

    q.  Salir

EOF

  printf "Introduce una opcion: "
  read OPTION
  
 case ${OPTION} in               
  1) ${RUTA}/unlock_users.sh | tee unlock_users.log;;
  2) ${RUTA}/workaround_shadow.sh | tee workaround_shadow.log;;


   q)  rm -f $0.flag;echo; echo; exit 0;;

  esac
done 
