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
FECHA=$(date +%d_%m_%y)

echo "Tratamos servidor ${1} y usuario ${2}" 


# Desbloqueamos el usuario
passwd -u ${2}

if [ $? -eq 0 ]
    then 
        echo " Desbloqueo usuario ${2} en servidor ${1} -> OK"
        ok="Y"
    else
        echo " Desbloqueo usuario ${2} en servidor ${1} -> NOK con error ${$?}"
        ok="N"
fi

# Realizamos comprobacion. Segun SO el parametro cambia

sistema=$(uname)

if [ "${sistema}" == "SunOS" ]
    then
        comp=$(passwd -s ${2})
        echo "${FECHA};${1};Vodafone-IT;${2};${ok};${comp};${sistema}"
           
fi

if [ "${sistema}" == "Linux" ]
    then
        comp=$(passwd --status ${2})
        echo "${FECHA};${1};Vodafone-IT;${2};${ok};${comp};${sistema}"
              
fi 


}

## FUNCIONES EN DESUSO AL EJECUTAR TODO EN BUCLE INICIAL
unlock_user_tele2 ()
{
ssh ADMUNIX << EOF 
ssh ${serv}  'bash' 
$(typeset -f funcion)
funcion ${serv} ${user}
EOF
}

unlock_user_vodafone ()
{
ssh hmc << EOF
ssh ${serv} 'bash'
$(typeset -f funcion)
funcion ${serv} ${user}
EOF
}

unlock_user_ono ()
{
ssh ${serv} 'bash'<< EOF
$(typeset -f funcion)
funcion ${serv} ${user}
EOF
}

#################### FUNCION MAIN ####################

f_master="ficheros/master_maquinas.txt"
f_uso="unlock_users.txt"

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
                       DESBLOQUEO USUARIOS
    ==========================================================
     
     NOTA: Se usaran los ficheros ficheros/master_maquinas.txt y block_users.txt 
           ficheros/master_maquinas.txt -> Listado de maquinas (unicas) y red con formato: MAQUINA;RED
           unlock_users.txt -> Listado de maquinas y usuarios a tratar con formato: MAQUINA;USUARIO
       
EOF

continua
############################################################
############################################################

# Creamos cabecera CSV
echo "FECHA;SERVIDOR;ENTORNO;USUARIO;REALIZADO OK;COMPROBACION;SISTEMA;TIPO USUARIO"


while IFS=';' read -r serv user <&3 
do
 {
    red=$(gawk -v a="${serv}" '$2==a {print $3}' 'FS=;' ficheros/master_maquinas.txt)
    id=$(gawk -v a="${serv}" '$2==a {print $1}' 'FS=;' ficheros/master_maquinas.txt) 
    
  if [ ${red} == "VODAFONE" ]
        then
            typeset -f funcion > funcion_no_borrar.sh
            echo "funcion \${1} \${2}" >> funcion_no_borrar.sh
            scp -p funcion_no_borrar.sh hmc:/tmp/.
            ssh hmc << EOF
            scp -p /tmp/funcion_no_borrar.sh ${serv}:/tmp/.
            ssh ${serv} 'bash -s' <  /tmp/funcion_no_borrar.sh "${serv}" "${user}"
            ssh ${serv} 'rm -f /tmp/funcion_no_borrar.sh'
EOF
            ssh hmc 'rm -f /tmp/funcion_no_borrar.sh'
            rm -f funcion_no_borrar.sh
    fi 

    if [ ${red} == "TELE2" ]
        then
            typeset -f funcion > funcion_no_borrar.sh
            echo "funcion \${1} \${2}" >> funcion_no_borrar.sh
            ssh hmc 'ssh admunix 'ssh "${serv}" 'bash -s''' <  funcion_no_borrar.sh "${serv}" "${user}"
            rm -f funcion_no_borrar.sh
    fi

    if [ ${red} == "ONO" ]
        then
            typeset -f funcion > funcion_no_borrar.sh
            echo "funcion \${1} \${2}" >> funcion_no_borrar.sh
            ssh "${serv}" 'bash -s' <  funcion_no_borrar.sh "${serv}" "${user}"
            rm -f funcion_no_borrar.sh
    fi
 } 3<&-
done 3< unlock_users.txt
continua
clear

# Borramos fichero temporal
rm -f /home/mdearri2/vodafone.sh

sed $'s/[^[:print:]\t]//g' unlock_users.log | grep -E "COMPROBACION|Vodafone-IT" > unlock_users.csv
perl -npi -e "s/Press ENTER to continue ...//g" unlock_users.csv

# Ponemos tipo de usuario

echo "FECHA;SERVIDOR;ENTORNO;USUARIO;REALIZADO OK;COMPROBACION;SISTEMA;TIPO USUARIO" > temporal_script.tmp
cat unlock_users.csv | awk ' NR != 1'| while read line
do
    usuario=$(echo "${line}" | awk -F";" '{print $4}')
    tipo=$(gawk -v a="${usuario}" '$1==a {print $2}' 'FS=;' ficheros/tipo_listado_usuarios.txt)
    echo "${line};${tipo}" >> temporal_script.tmp
done

mv temporal_script.tmp  unlock_users.csv