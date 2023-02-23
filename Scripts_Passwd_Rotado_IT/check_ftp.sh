#/bin/bash -p

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

log_existe=$(ls -ltr /var/log/*xferlog*|wc -l)
if [ ${log_existe} -eq 0 ]
    then
        sistema1=$(uname)
        if [ "${sistema1}" == "SunOS" ]
            then
            servicioSUN=$(inetadm | grep ftp)
            echo "${1};Vodafone-IT;No tiene uso de FTP;N/A;Estado del servicio: ${servicioSUN}"
        fi
        if [ "${sistema1}" == "Linux" ]
            then
                servicioRH=$(rpm -q  vsftpd)
                echo "${1};Vodafone-IT;No tiene uso de FTP;N/A;Estado del servicio: ${servicioRH}"
        fi 
    else
        #ultimo=$(ls -ltr /var/log/xferlog* | tail -1 | awk '{print $9}')
        #fecha_ftp=$(ls -ltr /var/log/*xferlog* | tail -1 | awk '{print $9}' | xargs -I {} stat -c %y {} | awk '{print $1}')
        #diff_dias=$(echo $(( ($(date -d $(date +%Y-%m-%d) +%s) - $(date -d ${fecha_ftp} +%s)) / 86400)))
        #usuarios=$(cat ${ultimo}| awk '{print $14}' | sort -u)
        
        dato1=$(cat /var/log/*xferlog* | tail -1 | awk '{print $1,$2,$3,$4,$5}')
        dato2=$(cat /var/log/*xferlog* | tail -1 | awk '{print $14}')
        verif=$(cat /var/log/*xferlog* | tail -1| wc -l)
        fecha=$(date -d "${dato1}" "+%d/%m/%Y %T")
        sistema2=$(uname)

        if [ ${verif} -eq 0 ]
            then
                if [ "${sistema2}" == "SunOS" ]
                    then
                        servicioSUN=$(inetadm | grep ftp)
                        echo "${1};Vodafone-IT;No tiene uso de FTP;N/A;Estado del servicio: ${servicioSUN}"
                fi
                if [ "${sistema2}" == "Linux" ]
                    then
                        servicioRH=$(rpm -q  vsftpd)
                        echo "${1};Vodafone-IT;No tiene uso de FTP;N/A;Estado del servicio: ${servicioRH}"
                fi 
            else
                sistema3=$(uname)
                 if [ "${sistema3}" == "SunOS" ]
                    then
                        servicioSUN=$(inetadm | grep ftp)
                        echo "${1};Vodafone-IT;${fecha};${dato2};Estado del servicio: ${servicioSUN}"
                fi
                if [ "${sistema3}" == "Linux" ]
                    then
                        servicioRH=$(rpm -q  vsftpd)
                        echo "${1};Vodafone-IT;${fecha};${dato2};Estado del servicio: ${servicioRH}"
                fi                
        fi  
fi
}

saca_fecha_tele2 ()
{
ssh ADMUNIX << EOF 
ssh ${serv}  'bash' 
$(typeset -f funcion)
funcion ${serv}
EOF
}

saca_fecha_vodafone ()
{
ssh hmc << EOF
ssh ${serv} 'bash'
$(typeset -f funcion)
funcion ${serv}
EOF
}

saca_fecha_ono ()
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
#              Fecha -> 06/02/2023                    #
#                                                     #
#     v1.4  -- Miguel Angel de Arriba Gutierrez       #
#                                                     #
#######################################################

 
    ==========================================================
                        CHEQUEO FTP
    ==========================================================
     
     NOTA: Se usaran los ficheros ficheros/master_maquinas.txt y servidores_ftp.txt 
           ficheros/master_maquinas.txt -> Listado de maquinas (unicas) y red con formato: MAQUINA;RED
           servidores_ftp.txt  -> Listado de maquinas a tratar
       
EOF

continua
############################################################
############################################################


# Creamos cabecera CSV

echo "SERVIDOR;ENTORNO;FECHA_ULTIMO_ACCESO;USUARIO;NOTAS"
while IFS='' read -r serv <&3 
do
 {
    red=$(gawk -v a="${serv}" '$2==a {print $3}' 'FS=;' ficheros/master_maquinas.txt)
    id=$(gawk -v a="${serv}" '$2==a {print $1}' 'FS=;' ficheros/master_maquinas.txt)
     
    if [ ${red} == "VODAFONE" ]
        then
            saca_fecha_vodafone
    fi

    if [ ${red} == "TELE2" ]
        then
            saca_fecha_tele2
    fi

    if [ ${red} == "ONO" ]
        then
            saca_fecha_ono
    fi
 } 3<&-
done 3< servidores_ftp.txt
continua
clear

# Borramos fichero temporal
rm -f /home/mdearri2/vodafone.sh

sed $'s/[^[:print:]\t]//g' check_ftp.log | grep -Ei "ENTORNO|Vodafone-IT" > check_ftp.csv
perl -npi -e "s/Press ENTER to continue ...//g" check_ftp.csv