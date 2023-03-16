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
#               Menu Hardenizacion                    #
#                                                     #
#              Fecha -> 08/03/2023                    #
#                                                     #
#     v2.0  -- Miguel Angel de Arriba Gutierrez       #
#                                                     #
#######################################################

NOTAS: 
        - Para todas las opciones se usa el fichero ficheros/master_maquinas.txt -> Listado de maquinas (unicas) y red con formato: ID;MAQUINA;RED;ENTORNO;APLICATIVOS 
        - Para la opcion 1 ademas -> servidores_cyberark.txt -> Listado de maquinas a tratar
        - Para la opcion 2 ademas -> servidores_cyberark.txt -> Listado de maquinas a tratar
        - Para la opcion 3 ademas -> servidores_cyberark.txt -> Listado de maquinas a tratar
        - Para la opcion 4 ademas -> servidores_ftp.txt -> Listado de maquinas a tratar
        - Para la opcion 5 ademas -> servidores_ftp.txt -> Listado de maquinas a tratar
        - Para la opcion 6 ademas -> block_users.txt -> Listado de maquinas y usuarios a tratar con formato: MAQUINA;USUARIO
        - Para la opcion 7 ademas -> rotado_password.txt -> Listado de maquinas y usuarios a tratar con formato: MAQUINA;USUARIO
        - Para la opcion 8 ademas -> unlock_users.txt -> Listado de maquinas y usuarios a tratar con formato: MAQUINA;USUARIO
        - Para la opcion 9 ademas -> undo_rotado_password.txt -> Listado de maquinas y usuarios a tratar con formato: MAQUINA;USUARIO
        - Para la opcion 10 ademas -> normalizado_maquinas_solaris.txt -> Listado de maquinas a tratar
        - Para la opcion 11 ademas -> normalizado_todos_usuarios_solaris.txt -> Listado de maquinas a tratar
        - Para la opcion 12 ademas -> saca_info_usuario.txt -> Listado de maquinas a tratar
        - Para la opcion 13 ademas -> escaneo_maquina.txt -> Listado de maquinas a tratar
        - Para la opcion 14 ademas -> workaround_shadow.txt -> Listado de maquinas y usuarios a tratar con formato: MAQUINA;USUARIO
        - Para la opcion 15 ademas -> change_date_shadow.txt -> Listado de maquinas a tratar

=========================================
               MAIN MENU
=========================================


 1.  CHEQUEO CYBERARK (CARP* CYBERARK CYBERLOG) 
 2.  NORMALIZACION CYBERARK (CYBERARK CYBERLOG)
 3.  CAMBIO PASS USUARIOS CYBERARK Y CYBERLOG (NO FUNCIONA CON MAQUINAS SOLARIS)
 4.  CHEQUEO FTP
 5.  HARDENIZACION FTP
 6.  BLOQUEO USUARIOS
 7.  ROTADO PASSWORD USUARIO (R05-PW-05)
 8.  ROLLBACK BLOQUEO USUARIOS (DESBLOQUEO)
 9.  ROLLBACK ROTADO PASSWORD (SE DEJA DIAS EN 9999)
10.  NORMALIZADO DE PARAMETROS (MAXWEEKS, MINWEEKS, WARNWEEKS) EN MAQUINAS SOLARIS
11.  NORMALIZADO DE PARAMETROS Y USUARIOS EN MAQUINAS SOLARIS. OJO!! ESTO TRATA TODOS LOS USUARIOS DE LAS MAQUINAS
12.  SACAR INFORMACION USUARIOS MAQUINAS (BLOQUEADO, ROTADO, HARDENIZADO OK/NOK)
13.  ESCANEO MAQUINAS (USUARIOS, CYBERLOG, CYBEARK, CARP*, CCS_MON, BLOQUEO, ROTADO, HARDENIZADO OK/NOK)
14.  WORKAROUND SHADOW USUARIOS
15.  CAMBIO FECHA ESPECÍFICA SHADOW USUARIOS (SE LE PASA COMO PARAMETROS UNA FECHA A BUSCAR Y OTRA POR LA QUE SE VA A SUSTITUIR)

    q.  Salir

EOF

  printf "Introduce una opcion: "
  read OPTION
  
 case ${OPTION} in               
  1) ${RUTA}/check_cyberark.sh | tee check_cyberark.log;;
  2) ${RUTA}/change_cyberark_users.sh | tee change_cyberark_users.log;;
  3) ${RUTA}/cambio_pass.sh | tee cambio_pass.log;;
  4) ${RUTA}/check_ftp.sh  | tee check_ftp.log;;
  5) ${RUTA}/stop_ftp.sh   | tee stop_ftp.log;;
  6) ${RUTA}/block_users.sh | tee block_users.log;;
  7) ${RUTA}/rotado_password.sh | tee rotado_password.log;;
  8) ${RUTA}/unlock_users.sh | tee unlock_users.log;;
  9) ${RUTA}/undo_rotado_password.sh | tee undo_rotado_password.log;;
 10) ${RUTA}/normalizado_maquinas_solaris.sh | tee normalizado_maquinas_solaris.log;;
 11) ${RUTA}/normalizado_todos_usuarios_solaris.sh | tee normalizado_todos_usuarios_solaris.log;;
 12) ${RUTA}/saca_info_usuarios.sh | tee saca_info_usuario.log;;
 13) ${RUTA}/escaneo_maquinas.sh | tee escaneo_maquina.log;;
 14) ${RUTA}/workaround_shadow.sh | tee workaround_shadow.log;;
 15) clear
     printf "Introduce la fecha a buscar: "
     read FECHA_BUSCAR
     printf "Introduce la fecha por la que se va a sustituir: "
     read FECHA_SUSTITUIR
     printf "La fecha a buscar es: ${FECHA_BUSCAR} y la fecha por la que se va a sustituir es: ${FECHA_SUSTITUIR} \n"
     continua
     ${RUTA}/change_date_shadow.sh ${FECHA_BUSCAR} ${FECHA_SUSTITUIR} | tee change_date_shadow.log;;

   q)  rm -f $0.flag;echo; echo; exit 0;;

  esac
done 
