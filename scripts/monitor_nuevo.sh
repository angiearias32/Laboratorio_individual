#!/bin/bash

# Verificar argumentos
if [ $# -lt 1 ]; then
    echo "Uso: $0 \"comando\" [intervalo]"
    exit 1
fi

COMANDO=$1
INTERVALO=${2:-2}

# Ejecutar comando en background
eval $COMANDO &
PID=$!

echo "Monitoreando proceso con PID: $PID"

LOG="monitor_${PID}.log"

# Manejar Ctrl+C
trap "echo 'Interrumpido'; kill $PID; exit" SIGINT

START_TIME=$(date +%s)

# Monitoreo
while kill -0 $PID 2>/dev/null; do
    TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")
    DATA=$(ps -p $PID -o %cpu,%mem,rss --no-headers)

    CURRENT_TIME=$(date +%s)
    ELAPSED=$((CURRENT_TIME - START_TIME))

    echo "$ELAPSED $TIMESTAMP $DATA" >> $LOG

    sleep $INTERVALO
done

echo "Proceso finalizado. Log guardado en $LOG"

# =========================
# Graficación
# =========================

GNUPLOT_SCRIPT="plot_${PID}.gp"

echo 'set terminal png size 800,600' > "$GNUPLOT_SCRIPT"
echo "set output 'monitor_${PID}.png'" >> "$GNUPLOT_SCRIPT"
echo "set title 'Monitoreo del proceso PID ${PID}'" >> "$GNUPLOT_SCRIPT"
echo "set xlabel 'Tiempo (s)'" >> "$GNUPLOT_SCRIPT"
echo "set ylabel 'CPU (%)'" >> "$GNUPLOT_SCRIPT"
echo "set y2label 'RSS (KB)'" >> "$GNUPLOT_SCRIPT"
echo 'set y2tics' >> "$GNUPLOT_SCRIPT"
echo 'set ytics nomirror' >> "$GNUPLOT_SCRIPT"

echo "plot '${LOG}' using 1:3 with lines title 'CPU (%)', '${LOG}' using 1:5 axes x1y2 with lines title 'RSS (KB)'" >> "$GNUPLOT_SCRIPT"

gnuplot "$GNUPLOT_SCRIPT"

echo "Gráfica generada: monitor_${PID}.png"
