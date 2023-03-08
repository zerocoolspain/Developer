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
FECHA=$(date +%d_%m_%y)

echo "Tratamos servidor ${1} y usuario ${2}" 

# Creamos grupo PDS para tener localizados usuarios bloqueados
groupadd PDS

# Añadimos usuario al grupo PDS
usermod -G PDS ${2}

# Bloqueamos el usuario
passwd -l ${2}

if [ $? -eq 0 ]
    then 
        echo " Bloqueo usuario ${2} en servidor ${1} -> OK"
        ok="Y"
    else
        echo " Bloqueo usuario ${2} en servidor ${1} -> NOK con error ${$?}"
        ok="N"
fi

# Realizamos comprobacion. Segun SO el parametro cambia

sistema=$(uname)

if [ "${sistema}" == "SunOS" ]
    then
        comp=$(logins -oxl ${2} | awk -F: '{print $8,$9,$10,$11,$12}')
        echo "${FECHA};${1};Vodafone-IT;${2};${ok};${comp};${sistema}"
           
fi

if [ "${sistema}" == "Linux" ]
    then
        comp=$(passwd --status ${2})
        echo "${FECHA};${1};Vodafone-IT;${2};${ok};${comp};${sistema}"
              
fi 

}

## FUNCIONES EN DESUSO AL EJECUTAR TODO EN BUCLE INICIAL
block_user_tele2 ()
{
ssh ADMUNIX << EOF 
ssh ${serv}  'bash' 
$(typeset -f funcion)
funcion ${serv} ${user}
EOF
}

block_user_vodafone ()
{
ssh hmc << EOF
ssh ${serv} 'bash'
$(typeset -f funcion)
funcion ${serv} ${user}
EOF
}

block_user_ono ()
{
ssh ${serv} 'bash'<< EOF
$(typeset -f funcion)
funcion ${serv} ${user}
EOF
}

#################### FUNCION MAIN ####################

f_master="ficheros/master_maquinas.txt"
f_uso="block_users.txt"


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
                       BLOQUEO USUARIOS
    ==========================================================
     
     NOTA: Se usaran los ficheros ficheros/master_maquinas.txt y block_users.txt 
           ficheros/master_maquinas.txt -> Listado de maquinas (unicas) y red con formato: MAQUINA;RED
           block_users.txt -> Listado de maquinas y usuarios a tratar con formato: MAQUINA;USUARIO
       
EOF

continua
############################################################
############################################################

# Creamos cabecera CSV
echo "FECHA;SERVIDOR;ENTORNO;USUARIO;REALIZADO OK;COMPROBACION;SISTEMA;TIPO USUARIO"
rm -f para_CSV_de_ejecutados.csv

while IFS=';' read -r serv user <&3 
do
 {
    red=$(gawk -v a="${serv}" '$2==a {print $3}' 'FS=;' ficheros/master_maquinas.txt)
    identificador=$(gawk -v a="${serv}" '$2==a {print $1}' 'FS=;' ficheros/master_maquinas.txt)
    aplicacion=$(gawk -v a="${serv}" '$2==a {print $5}' 'FS=;' ficheros/master_maquinas.txt)
    entorno=$(gawk -v a="${serv}" '$2==a {print $4}' 'FS=;' ficheros/master_maquinas.txt)


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

    # Sacamos LOG para actualizar CSV de EJECUTADOS

    FECHA=$(date +%d/%m/%y)
    echo "${FECHA};${identificador};${serv};${user};${aplicacion};${entorno};BLOQUEAR" >> para_CSV_de_ejecutados.csv
 } 3<&-
done 3< block_users.txt
continua
clear

# Borramos fichero temporal
rm -f /home/mdearri2/vodafone.sh

sed $'s/[^[:print:]\t]//g' block_users.log | grep -E "COMPROBACION|Vodafone-IT" > block_users.csv
perl -npi -e "s/Press ENTER to continue ...//g" block_users.csv

# Ponemos tipo de usuario

echo "FECHA;SERVIDOR;ENTORNO;USUARIO;REALIZADO OK;COMPROBACION;SISTEMA;TIPO USUARIO" > temporal_script.tmp
cat block_users.csv | awk ' NR != 1'| while read line
do
    usuario=$(echo "${line}" | awk -F";" '{print $4}')
    tipo=$(gawk -v a="${usuario}" '$1==a {print $2}' 'FS=;' ficheros/tipo_listado_usuarios.txt)
    echo "${line};${tipo}" >> temporal_script.tmp
done

mv temporal_script.tmp  block_users.csv