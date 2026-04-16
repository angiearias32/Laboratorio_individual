#!/bin/bash

if [ $# -lt 1 ]; then

# el comando $#: son la cantidad de argumentos que se le pasan
# -l 1: dice que es menor que 1, es por si no se le dio ningun comando
# ayuda a verificar que usuario ingrese al menos un comando

echo "Usar: $0 \"comando\" [intervalo]"
exit 1

# este comando si no se le ingreso algo imprime como hacer, y se cierra

fi

# Para guardar argumentos

COMANDO=$1
INTERVALO=${2:-2} # si no se da el intervalo, usa 2 segundos


# Ahora ponemos el comando a ejecutar en backround

eval $COMANDO &

PID=$!
# se guarda el PID del proceso


echo "Se va a monitorear el proceso con el PID: $PID"

# Vamos a registrar un archivo de log

LOG="monitor_${PID}.log"


#Manejar el ctrl+c

trap "echo 'Interrumpido. Finalizando el proceso...'; kill &PID; exit" SIGINT
#este comando logra matar el proceso con su debido PID con un kill

# Empezamos con el monitoreo

START_TIME=$(date +%s)

while kill -0 $PID 2>/dev/null; do
# kill -o $PID verifica si el proceso sigue vivo
    TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")

# Vamos a obtener los datos del preceso

    DATA=$(ps -p $PID -o %cpu,%mem,rss --no-headers)
# al comando anterior genera los porcentajes que estamos solicitando
# el siguiente comando es para el tiempo que transcurrio

    CURRENT_TIME=$(date +%s)
    ELAPSED=$((CURRENT_TIME - START_TIME))

    echo "$ELAPSED $TIMESTAMP $DATA" >> $LOG
    sleep $INTERVALO
done

echo "El proceso ha finalizado. El log se ha guardado en $LOG

#Ahora generamos un comando para poder mostrar una grafica

GNUPLOT_SCRIPT="plot_${PID}.gp"

# Crear archivo gnuplot línea por línea (sin errores de comillas)
echo 'set terminal png size 800,600' > "$GNUPLOT_SCRIPT"
echo "set output 'monitor_${PID}.png'" >> "$GNUPLOT_SCRIPT"
echo "set title 'Monitoreo del proceso PID ${PID}'" >> "$GNUPLOT_SCRIPT"
echo "set xlabel 'Tiempo (s)'" >> "$GNUPLOT_SCRIPT"
echo "set ylabel 'CPU (%)'" >> "$GNUPLOT_SCRIPT"
echo "set y2label 'RSS (KB)'" >> "$GNUPLOT_SCRIPT"
echo 'set y2tics' >> "$GNUPLOT_SCRIPT"
echo 'set ytics nomirror' >> "$GNUPLOT_SCRIPT"

echo "plot '${LOG}' using 1:3 with lines title 'CPU (%)', '${LOG}' using 1:5 axes x1y2 with lines title 'RSS (KB)'" >> "$GNUPLOT_SCRIPT"

# Ejecutar gnuplot
gnuplot "$GNUPLOT_SCRIPT"

echo "Se ha generado la grafica: monitor_${PID}.png"

