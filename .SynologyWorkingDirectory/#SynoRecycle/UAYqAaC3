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

carp_log=$(egrep ^[^:]+:[^\!*] /etc/shadow | cut -d: -f1 | grep carp_log | wc -l)
carp_lts=$(egrep ^[^:]+:[^\!*] /etc/shadow | cut -d: -f1 | grep carp_lts | wc -l)
cyberark=$(egrep ^[^:]+:[^\!*] /etc/shadow | cut -d: -f1 | grep cyberark | wc -l)
cyberlog=$(egrep ^[^:]+:[^\!*] /etc/shadow | cut -d: -f1 | grep cyberlog | wc -l)

## Borrado usuario carp_log
if [ ${carp_log} -eq 1 ] && [ ${cyberlog} -eq 1 ]
    then
        echo "Borramos usuario carp_log en ${1}"
        userdel carp_log
        echo "${1};Vodafone-IT;Borrado usuario carp_log"
fi

## Borrado usuario carp_lts
if [ ${carp_lts} -eq 1 ] && [ ${cyberark} -eq 1 ]
    then
        echo "Borramos usuario carp_lts en ${1}"
        userdel carp_lts
        echo "${1};Vodafone-IT;Borrado usuario carp_lts"
fi

## Renombrado usuario carp_log a cyberlog
if [ ${carp_log} -eq 1 ] && [ ${cyberlog} -eq 0 ]
    then
        echo "Renombramos usuario carp_log a cyberlog en ${1}"
        usermod -l  cyberlog carp_log
        echo "${1};Vodafone-IT;Renombrado usuario carp_log a CYBERLOG"
fi

## Renombrado usuario carp_lts a cyberark
if [ ${carp_lts} -eq 1 ] && [ ${cyberark} -eq 0 ]
    then
        echo "Renombramos usuario carp_lts a cyberark en ${1}"
        usermod -l  cyberark carp_lts
        echo "${1};Vodafone-IT;Renombrado usuario carp_lts a CYBERARK"
fi

## Crear usuario cyberlog
if [ ${carp_log} -eq 0 ] && [ ${cyberlog} -eq 0 ]
    then
        echo "Creamos usuario cyberlog en ${1}"
        useradd -c 'Usuario de logon CYBERARK' cyberlog
        echo "${1};Vodafone-IT;Creado usuario CYBERLOG"
fi

## Crear usuario cyberark
if [ ${carp_lts} -eq 0 ] && [ ${cyberark} -eq 0 ]
    then
        echo "Creamos usuario cyberark en ${1}"
        useradd -c 'Usuario de proceso cyberark' cyberark
        echo "${1};Vodafone-IT;Creado usuario CYBERARK"
fi

}

## FUNCIONES EN DESUSO AL EJECUTAR TODO EN BUCLE INICIAL
saca_cyberark_tele2 ()
{
ssh ADMUNIX << EOF 
ssh ${serv}  'bash' 
$(typeset -f funcion)
funcion ${serv}
EOF
}

saca_cyberark_vodafone ()
{
ssh hmc << EOF
ssh ${serv} 'bash'
$(typeset -f funcion)
funcion ${serv}
EOF
}

saca_cyberark_ono ()
{
ssh ${serv} 'bash'<< EOF
$(typeset -f funcion)
funcion ${serv}
EOF
}

#################### FUNCION MAIN ####################

f_master="ficheros/master_maquinas.txt"
f_uso="servidores_cyberark.txt"

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
            NORMALIZACION CYBERARK (CYBERARK CYBERLOG)
       ==========================================================
     
     NOTA: Se usaran los ficheros ficheros/master_maquinas.txt y servidores_cyberark.txt
           ficheros/master_maquinas.txt -> Listado de maquinas (unicas) y red con formato: MAQUINA;RED
           servidores_cyberark.txt -> Listado de maquinas a tratar
       
EOF

continua
############################################################
############################################################

# Creamos cabecera CSV
echo "SERVIDOR;ENTORNO;ACCION"

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
done 3< servidores_cyberark.txt
continua
clear

# Borramos fichero temporal
rm -f /home/mdearri2/vodafone.sh

sed $'s/[^[:print:]\t]//g' change_cyberark_users.log | grep -Ei "ENTORNO|Vodafone-IT" > change_cyberark_users.csv
perl -npi -e "s/Press ENTER to continue ...//g" change_cyberark_users.csv