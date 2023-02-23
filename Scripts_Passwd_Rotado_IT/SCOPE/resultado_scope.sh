#/bin/bash -p

export LANG=en_US.UTF-8

rm -f IN_SCOPE.csv HOJA_OUT_SCOPE.csv HOJA_IN_SCOPE.csv HOJA_RESUMEN_SCOPE.csv HOJA_OUT_SCOPE.csv.tmp

if [ $# -ne 1 ]
    then
        echo "Se debe pasar como parametro el fichero a tratar"
        exit
fi

# Cabecera no entra en Scope
echo "ID;SERVIDOR;ENTORNO;USUARIO;BLOQUEADO;ROTADO;MIN_DAYS;MAX_DAYS;WARN_DAYS;OS;HARDENIZADO" > HOJA_OUT_SCOPE.csv

# Revisar si entra en scope

echo "Revisando lo que entra en el SCOPE"
echo ""

cat $1 | awk ' NR != 1' | while read line
do
usuario=$(echo "${line}" | awk -F";" '{print $4}')
#buscar=$(gawk -v a="${usuario}" '$1==a  {print $1}' 'FS=;' ficheros/listado_usuarios.txt | wc -l)
tipo=$(gawk -v a="${usuario}" '$1==a  {print $2}' 'FS=;' ficheros/tipo_listado_usuarios.txt)
buscar=$(grep -x "${usuario}" ficheros/listado_usuarios.txt | wc -l)
#tipo=$(grep -x "${usuario}"  ficheros/tipo_listado_usuarios.txt| awk -F";" '{print $2}')
d1=$(echo "${line}" | awk -F";" '{print $1";"$2";"$3";"$4}')
d2=$(echo "${line}" | awk -F";" '{print $5";"$6";"$7";"$8";"$9";"$10";"$11}')

if [ ${buscar} -gt 0 ]
    then
        echo "${d1};${tipo};${d2}" >> IN_SCOPE.csv
    else
        echo "${line}" >> HOJA_OUT_SCOPE.csv
fi
done

# Tratamos las OUT SCOPE

head -1 HOJA_OUT_SCOPE.csv > HOJA_OUT_SCOPE.csv.tmp
cat HOJA_OUT_SCOPE.csv | awk ' NR != 1' | while read line
do
    clase1=$(echo ${line} | awk -F";" '{print $11}')
    clase2=$(echo ${line} | awk -F";" '{print $4}')

    if [ "${clase1}" = "NO" ] || [ "${clase2}" = "SCAN FAIL" ] 
        then
            echo "${line}" >> HOJA_OUT_SCOPE.csv.tmp
    fi
done

mv HOJA_OUT_SCOPE.csv.tmp HOJA_OUT_SCOPE.csv

# Quitamos saltos y caracteres
 sed $'s/[^[:print:]\t]//g' IN_SCOPE.csv > tmp1
 mv tmp1 IN_SCOPE.csv

# Cabecera si entra en Scope
echo "ID;SERVIDOR;ENTORNO;USUARIO;TIPO;BLOQUEADO;ROTADO;MIN_DAYS;MAX_DAYS;WARN_DAYS;OS;HARDENIZADO;EJECUTADO;ACCION" > HOJA_IN_SCOPE.csv

# Revisamos cuales se han bloqueado o rotado

echo "Revisando bloqueados y rotados"
echo ""

cat IN_SCOPE.csv | while read line
do
match=$(echo "${line}" | awk -F";" '{print $2";"$4}')
buscarB=$(grep -x "${match}" ficheros/bloqueos_scope.txt | wc -l)
buscarR=$(grep -x "${match}" ficheros/rotados_scope.txt | wc -l)
#tipo=$(grep -w "${usuario}" ficheros/tipo_listado_usuarios.txt| awk -F";" '{print $2}')
#d1=$(echo "${line}" | awk -F";" '{print $1";"$2";"$3";"$4}')
#d2=$(echo "${line}" | awk -F";" '{print $6";"$7";"$8";"$9";"$10";"$11";"$12}')

if [ ${buscarB} -gt 0 ]
    then
        echo "${line};SI;BLOQUEO" >> HOJA_IN_SCOPE.csv
fi

if [ ${buscarR} -gt 0 ]
    then
        echo "${line};SI;ROTADO" >> HOJA_IN_SCOPE.csv
fi

if [ ${buscarB} -eq 0 ] &&  [ ${buscarR} -eq 0 ]
then
        echo "${line};NO;N/A" >> HOJA_IN_SCOPE.csv
fi

done  

# Sacamos el resumen de todo

echo "Generando resumen del SCOPE"
echo ""

## 1- Numero Total Host Scope
n1=$(cat HOJA_IN_SCOPE.csv | awk ' NR != 1' | awk -F";" '{print $2}'|sort -u | wc -l)
## 1.1- Numero Total Host Scope Error
m1=$(cat HOJA_OUT_SCOPE.csv | awk ' NR != 1' | awk -F";" '( $4 == "SCAN FAIL" ) { print $4}'|wc -l)
## 2- Numero total cuentas Scope
n2=$(cat HOJA_IN_SCOPE.csv | awk ' NR != 1' | awk -F";" '{print $4}'|wc -l)
# 2.1- Numero total cuentas FUERA Scope
m2=$(cat HOJA_OUT_SCOPE.csv | awk ' NR != 1' | awk -F";" '( $4 != "SCAN FAIL" ) { print $4}'|wc -l)
## 3- Numero total usuarios unicos Scope
n3=$(cat HOJA_IN_SCOPE.csv | awk ' NR != 1' | awk -F";" '{print $4}'|sort -u | wc -l)
## 3.1- Numero total usuarios unicos FUERA Scope
m3=$(cat HOJA_OUT_SCOPE.csv | awk ' NR != 1' | awk -F";" '( $4 != "SCAN FAIL" ) { print $4}'|sort -u | wc -l)
## 4- Numero Total de cuentas Nominales Scope
n4=$(cat HOJA_IN_SCOPE.csv | awk ' NR != 1' | awk -F";" '( $5 == "N" ) { print $4}' | wc -l)
## 5- Numero total de usuarios unicos Nominales Scope
n5=$(cat HOJA_IN_SCOPE.csv | awk ' NR != 1' | awk -F";" '( $5 == "N" ) { print $4}' | sort -u | wc -l)
## 6- Numero Total de cuentas Funcionales Scope
n6=$(cat HOJA_IN_SCOPE.csv | awk ' NR != 1' | awk -F";" '( $5 != "N" ) { print $4}' | wc -l)
## 7- Numero Total de Usuarios unicos funcionales Scope
n7=$(cat HOJA_IN_SCOPE.csv | awk ' NR != 1' | awk -F";" '( $5 != "N" ) { print $4}' | sort -u | wc -l)
## 8- Numero total de cuentas nominales con PW05 aplicado ( maquina+user)
n8=$(cat HOJA_IN_SCOPE.csv | awk ' NR != 1' | awk -F";" '( $5 == "N" && $13 == "SI") { print $4}' | wc -l)
## 9- Numero total de usuarios unicos nominales con PW05 aplicado ( maquina+user)
n9=$(cat HOJA_IN_SCOPE.csv | awk ' NR != 1' | awk -F";" '( $5 == "N" && $13 == "SI") { print $4}' | sort -u | wc -l)
## 10- Numero total de cuentas funcionales con PW05 aplicado ( maquina+user)
n10=$(cat HOJA_IN_SCOPE.csv | awk ' NR != 1' | awk -F";" '( $5 != "N" && $13 == "SI") { print $4}' | wc -l)
## 11- Numero total de usuarios unicos funcionales con PW05 aplicado ( maquina+user)
n11=$(cat HOJA_IN_SCOPE.csv | awk ' NR != 1' | awk -F";" '( $5 != "N" && $13 == "SI") { print $4}' | sort -u | wc -l)
## 12- Numero Total de cuentas nominales pendientes de aplicar PW05 (Maquina úser)
n12=$(cat HOJA_IN_SCOPE.csv | awk ' NR != 1' | awk -F";" '( $5 == "N" && $13 == "SI") { print $4}' | wc -l)
## 13- Numero Total de usuarios unicos nominales pendientes de aplicar PW05 (Maquina úser)
n13=$(cat HOJA_IN_SCOPE.csv | awk ' NR != 1' | awk -F";" '( $5 == "N" && $13 == "SI") { print $4}' | sort -u | wc -l)
## 14- Numero Total de cuentas Funcionales pendientes de aplicar PW05 (Maquina úser)
n14=$(cat HOJA_IN_SCOPE.csv | awk ' NR != 1' | awk -F";" '( $5 != "N" && $13 == "SI") { print $4}' | wc -l)
## 15- Numero Total de usuarios unicos Funcionales pendientes de aplicar PW05 (Maquina úser)
n15=$(cat HOJA_IN_SCOPE.csv | awk ' NR != 1' | awk -F";" '( $5 != "N" && $13 == "SI") { print $4}' | sort -u | wc -l)

echo "Numero Total Host Scope;${n1}" > HOJA_RESUMEN_SCOPE.csv
echo "Numero Total Host Scope en ERROR;${m1}" >> HOJA_RESUMEN_SCOPE.csv
echo "Numero total cuentas Scope;${n2}" >>  HOJA_RESUMEN_SCOPE.csv
echo "Numero total cuentas FUERA Scope;${m2}" >>  HOJA_RESUMEN_SCOPE.csv
echo "Numero total usuarios unicos Scope;${n3}" >>  HOJA_RESUMEN_SCOPE.csv
echo "Numero total usuarios unicos FUERA Scope;${m3}" >>  HOJA_RESUMEN_SCOPE.csv
echo "Numero Total de cuentas Nominales Scope;${n4}" >>  HOJA_RESUMEN_SCOPE.csv
echo "Numero total de usuarios unicos Nominales Scope;${n5}" >>  HOJA_RESUMEN_SCOPE.csv
echo "Numero Total de cuentas Funcionales Scope;${n6}" >>  HOJA_RESUMEN_SCOPE.csv
echo "Numero Total de Usuarios unicos funcionales Scope;${n7}" >>  HOJA_RESUMEN_SCOPE.csv
echo "Numero total de cuentas nominales con PW05 aplicado ( maquina+user);${n8}" >>  HOJA_RESUMEN_SCOPE.csv
echo "Numero total de usuarios unicos nominales con PW05 aplicado ( maquina+user);${n9}" >>  HOJA_RESUMEN_SCOPE.csv
echo "Numero total de cuentas funcionales con PW05 aplicado ( maquina+user);${n10}" >>  HOJA_RESUMEN_SCOPE.csv
echo "Numero total de usuarios unicos funcionales con PW05 aplicado ( maquina+user);${n11}" >>  HOJA_RESUMEN_SCOPE.csv
echo "Numero Total de cuentas nominales pendientes de aplicar PW05 (Maquina user);${n12}" >>  HOJA_RESUMEN_SCOPE.csv
echo "Numero Total de usuarios unicos nominales pendientes de aplicar PW05 (Maquina user);${n13}" >>  HOJA_RESUMEN_SCOPE.csv
echo "Numero Total de cuentas Funcionales pendientes de aplicar PW05 (Maquina user);${n14}" >>  HOJA_RESUMEN_SCOPE.csv
echo "Numero Total de usuarios unicos Funcionales pendientes de aplicar PW05 (Maquina user);${n15}" >>  HOJA_RESUMEN_SCOPE.csv


# Quitamos saltos y caracteres
sed $'s/[^[:print:]\t]//g' HOJA_OUT_SCOPE.csv > tmp2
mv tmp2 HOJA_OUT_SCOPE.csv

sed $'s/[^[:print:]\t]//g' HOJA_IN_SCOPE.csv > tmp3
mv tmp3 HOJA_IN_SCOPE.csv

sed $'s/[^[:print:]\t]//g' HOJA_RESUMEN_SCOPE.csv > tmp4
mv tmp4 HOJA_RESUMEN_SCOPE.csv