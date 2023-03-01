#! /bin/bash -p

export LANG=en_US.UTF-8

# Borramos fichero temporal
rm -f /home/mdearri2/vodafone.sh


funcion ()
{


sistema=$(uname)

if [ "${sistema}" == "SunOS" ]
    then
      echo "${1}"           
fi

}

tele2 ()
{
ssh ADMUNIX << EOF 
ssh ${serv}  'bash' 
$(typeset -f funcion)
funcion ${serv} ${red}
EOF
}

vodafone ()
{
ssh hmc << EOF
ssh ${serv} 'bash'
$(typeset -f funcion)
funcion ${serv} ${red}
EOF
}

ono ()
{
ssh "${serv}" 'bash'<< EOF
$(typeset -f funcion)
funcion ${serv} ${user}
EOF
}

f_master="ficheros/master_maquinas.txt"
f_uso="busca_solaris.txt"

if [ ! -f ${f_master} ]
    then
        echo "No existe el fichero ${f_master}"
        exit 0
fi

if [ ! -f ${f_uso} ]
    then
        echo "No existe el fichero ${f_uso}"
        exit 0
fi

clear

while IFS=';' read -r serv user <&3 
do
 {
    red=$(gawk -v a="${serv}" '$2==a {print $3}' 'FS=;' ficheros/master_maquinas.txt)
    #identificador=$(gawk -v a="${serv}" '$2==a {print $1}' 'FS=;' ficheros/master_maquinas.txt)
    
    if [ "${red}" == "VODAFONE" ]
        then
            vodafone
    fi

    if [ "${red}" == "TELE2" ]
        then
            tele2
    fi

    if [ "${red}" == "ONO" ]
        then
            ono
    fi
 } 3<&-
done 3< busca_solaris.txt
continua
clear

# Borramos fichero temporal
rm -f /home/mdearri2/vodafone.sh

