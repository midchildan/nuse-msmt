
OUTPUT=$1
mkdir -p ${OUTPUT}/out

PKG_SIZES="64 128 256 512 1024 1500 2048"


# parse outputs

grep -E -h Latency ${OUTPUT}/nginx*-musl-[0-9].*  \
 | awk '{print $2 " " $3}' | sed "s/ms/ 1000/g" | sed "s/us/ 1/g" | awk '{print $1*$2 " " $3*$4}'  > ${OUTPUT}/nginx-musl.dat
grep -E -h Latency ${OUTPUT}/nginx*-native-[0-9]* \
 | awk '{print $2 " " $3}' | sed "s/ms/ 1000/g" | sed "s/us/ 1/g" | awk '{print $1*$2 " " $3*$4}'  > ${OUTPUT}/nginx-native.dat

gnuplot  << EndGNUPLOT
set terminal postscript eps lw 3 "Helvetica" 24
set output "${OUTPUT}/out/nginx-wrk.eps"
set yrange [0:]
#set xtics font "Helvetica,14"
set pointsize 2
set xzeroaxis
set grid ytics

set boxwidth 0.45
set style fill pattern
set key top left
set size 1.0,0.6

set ylabel "Latency (usec)"
set xtics ("64" 0, "128" 1, "256" 2, "512" 3, "1024" 4, "1500" 5, "2048" 6)
set xlabel "File size (bytes)"
set xrange [-1:7]
set terminal postscript eps lw 3 "Helvetica" 24
set output "${OUTPUT}/out/nginx-wrk.eps"

plot \
   '${OUTPUT}/nginx-musl.dat' usin (\$0-0.225):1:2 w boxerrorbar  title "LKL", \
   '${OUTPUT}/nginx-native.dat' usin (\$0+0.225):1:2 w boxerrorbar  title "Linux"

set terminal png lw 3 14
set xtics nomirror rotate by -45 font ",14"
set output "${OUTPUT}/out/nginx-wrk.png"
replot


set terminal dumb
unset output
replot

quit
EndGNUPLOT

