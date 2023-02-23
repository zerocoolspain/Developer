# Quitamos saltos y caracteres
 sed $'s/[^[:print:]\t]//g' IN_SCOPE.csv > tmp1
 mv tmp1 IN_SCOPE.csv
 
sed $'s/[^[:print:]\t]//g' HOJA_OUT_SCOPE.csv > tmp2
 mv tmp2 HOJA_OUT_SCOPE.csv

# Cabecera si entra en Scope
echo "ID;SERVIDOR;ENTORNO;USUARIO;BLOQUEADO;ROTADO;MIN_DAYS;MAX_DAYS;WARN_DAYS;OS;HARDENIZADO;EJECUTADO;ACCION" > HOJA_IN_SCOPE.csv

# Revisamos cuales se han bloqueado o rotado

cat IN_SCOPE.csv | while read line
do
match=$(echo "${line}" | awk -F";" '{print $2";"$4}')
buscarB=$(grep -w "${match}" bloqueos_scope.txt | wc -l)
buscarR=$(grep -w "${match}" rotados_scope.txt | wc -l)

if [ ${buscarB} -gt 0 ]
    then
        echo "${line};SI;BLOQUEO" >> HOJA_IN_SCOPE.csv
    else
        A="NO"
fi

if [ ${buscarR} -gt 0 ]
    then
        echo "${line};SI;ROTADO" >> HOJA_IN_SCOPE.csv
    else
        B="NO"
fi

if [ "${A}" = "NO" ] && [ "${B}" = "NO" ]
    then
        echo "${line};NO;N/A" >> HOJA_IN_SCOPE.csv
fi

done  



sed $'s/[^[:print:]\t]//g' HOJA_IN_SCOPE.csv > tmp3
mv tmp3 HOJA_IN_SCOPE.csv
