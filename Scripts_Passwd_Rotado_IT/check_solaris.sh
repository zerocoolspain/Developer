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

max=$(grep "MAXWEEKS=" /etc/default/passwd| sort -u)
min=$(grep "MINWEEKS=" /etc/default/passwd| sort -u)
warn=$(grep "WARNWEEKS=" /etc/default/passwd| sort -u)

echo "${1};${max};${min};${warn}"
}

saca_parametros_tele2 ()
{
ssh ADMUNIX << EOF 
ssh ${serv}  'bash' 
$(typeset -f funcion)
funcion ${serv}
EOF
}

saca_parametros_vodafone ()
{
ssh hmc << EOF
ssh ${serv} 'bash'
$(typeset -f funcion)
funcion ${serv}
EOF
}

saca_parametros_ono ()
{
ssh ${serv} 'bash'<< EOF
$(typeset -f funcion)
funcion ${serv}
EOF
}

#################### FUNCION MAIN ####################

f_master="ficheros/master_maquinas.txt"
f_uso="solaris.txt"

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
 
############################################################
############################################################


# Creamos cabecera CSV

echo "SERVIDOR;MAX;MIN;WARN"
while IFS='' read -r serv <&3 
do
 {
    red=$(gawk -v a="${serv}" '$2==a {print $3}' 'FS=;' ficheros/master_maquinas.txt)
    id=$(gawk -v a="${serv}" '$2==a {print $1}' 'FS=;' ficheros/master_maquinas.txt)
    
    if [ ${red} == "VODAFONE" ]
        then
            saca_parametros_vodafone
    fi

    if [ ${red} == "TELE2" ]
        then
            saca_parametros_tele2
    fi

    if [ ${red} == "ONO" ]
        then
            saca_parametros_ono
    fi
 } 3<&-
done 3< solaris.txt
continua
clear

# Borramos fichero temporal
rm -f /home/mdearri2/vodafone.sh

sed $'s/[^[:print:]\t]//g' check_solaris.log | grep -Ei "ENTORNO|Vodafone-IT" > check_solaris.csv
perl -npi -e "s/Press ENTER to continue ...//g" check_solaris.csv
