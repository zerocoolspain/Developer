#! /bin/bash -p

export LANG=en_US.UTF-8

# Borramos fichero temporal
rm -f /home/mdearri2/vodafone.sh

#########################################
#                Funciones              #
#########################################
continua()
{
  printf "\n\n\nPress ENTER to continue ..."
  read enter
}

funcion ()
{
export LANG=en_US.UTF-8

sistema=$(uname)

if [ "${sistema}" == "SunOS" ]
    then
        echo "El sistema de ${1} es Solaris"
        
        echo "Paramos servicio FTP de ${1}"
        svcadm disable -t ftp
        echo "${1};Vodafone-IT;${sistema};Parada servicio"
fi

if [ "${sistema}" == "Linux" ]
    then
        echo "El sistema de ${1} es Linux"
        
        # Comprobamos el servicio
        servicio=$(rpm -q  vsftpd | grep -i installed | wc -l)
        
        if [ ${servicio} -eq 1 ]
            then
                echo "Desinstalamos servicio FTP de ${1}"
                rpm -e vsftpd
                echo "${1};Vodafone-IT;${sistema};Desinstalacion servicio"
            else
                echo "Servicio FTP no instalado en ${1}"
        fi

fi

}

## FUNCIONES EN DESUSO AL EJECUTAR TODO EN BUCLE INICIAL
stop_ftp_tele2 ()
{
ssh ADMUNIX << EOF 
ssh ${serv}  'bash' 
$(typeset -f funcion)
funcion ${serv}
EOF
}

stop_ftp_vodafone ()
{
ssh hmc << EOF
ssh ${serv} 'bash'
$(typeset -f funcion)
funcion ${serv}
EOF
}

stop_ftp_ono ()
{
ssh ${serv} 'bash'<< EOF
$(typeset -f funcion)
funcion ${serv}
EOF
}

#################### FUNCION MAIN ####################

f_master="ficheros/master_maquinas.txt"
f_uso="servidores_ftp.txt"

if [ ! -f ${f_master} ]
    then
        echo "No existe el fichero ${f_master}"
        continua
        clear
        exit 0
fi

if [ ! -f ${f_uso} ]
    then
        echo "No existe el fichero ${f_uso}"
        continua
        clear
        exit 0
fi

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

 
    ==========================================================
                       HARDENIZACION FTP
    ==========================================================
     
     NOTA: Se usaran los ficheros ficheros/master_maquinas.txt y servidores_ftp.txt 
           ficheros/master_maquinas.txt -> Listado de maquinas (unicas) y red con formato: MAQUINA;RED
           servidores_ftp.txt  -> Listado de maquinas a tratar
       
EOF

continua
############################################################
############################################################


# Creamos cabecera CSV

echo "SERVIDOR;ENTORNO;SISTEMA;ACCION"
while IFS=';' read -r serv user <&3 
do
 {
    red=$(gawk -v a="${serv}" '$2==a {print $3}' 'FS=;' ficheros/master_maquinas.txt)
    #identificador=$(gawk -v a="${serv}" '$2==a {print $1}' 'FS=;' ficheros/master_maquinas.txt)

   if [ "${red}" == "VODAFONE" ]
        then
            typeset -f funcion > funcion_no_borrar.sh
            echo "funcion \${1} \${2}" >> funcion_no_borrar.sh
            scp -p funcion_no_borrar.sh hmc:/tmp/.
            ssh hmc << EOF
            scp -p /tmp/funcion_no_borrar.sh ${serv}:/tmp/.
            ssh ${serv} 'bash -s' <  /tmp/funcion_no_borrar.sh "${serv}"
            ssh ${serv} 'rm -f /tmp/funcion_no_borrar.sh'
EOF
            ssh hmc 'rm -f /tmp/funcion_no_borrar.sh'
            rm -f funcion_no_borrar.sh
    fi 

    if [ "${red}" == "TELE2" ]
        then
            typeset -f funcion > funcion_no_borrar.sh
            echo "funcion \${1} \${2}" >> funcion_no_borrar.sh
            ssh hmc 'ssh admunix 'ssh "${serv}" 'bash -s''' <  funcion_no_borrar.sh "${serv}"
            rm -f funcion_no_borrar.sh
    fi

    if [ "${red}" == "ONO" ]
        then
            typeset -f funcion > funcion_no_borrar.sh
            echo "funcion \${1} \${2}" >> funcion_no_borrar.sh
            ssh "${serv}" 'bash -s' <  funcion_no_borrar.sh "${serv}"
            rm -f funcion_no_borrar.sh
    fi
 } 3<&-
done 3< servidores_ftp.txt
continua
clear

# Borramos fichero temporal
rm -f /home/mdearri2/vodafone.sh

sed $'s/[^[:print:]\t]//g' stop_ftp.log | grep -Ei "ENTORNO|Vodafone-IT" > stop_ftp.csv
perl -npi -e "s/Press ENTER to continue ...//g" stop_ftp.csv