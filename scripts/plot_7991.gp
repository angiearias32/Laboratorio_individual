set terminal png size 800,600
set output 'monitor_7991.png'
set title 'Monitoreo del proceso PID 7991'
set xlabel 'Tiempo (s)'
set ylabel 'CPU (%)'
set y2label 'RSS (KB)'
set y2tics
set ytics nomirror
plot 'monitor_7991.log' using 1:3 with lines title 'CPU (%)', 'monitor_7991.log' using 1:5 axes x1y2 with lines title 'RSS (KB)'
