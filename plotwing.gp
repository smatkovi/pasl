# Set the input filename from the first argument passed to gnuplot
filename = 'n0012.dat'

# Set the title directly using the filename
set title sprintf("Wing Profile: %s", filename)
set terminal pngcairo size 1066, 193
set output sprintf("%s.png", filename)
set xlabel 'X Coordinate'
set ylabel 'Y Coordinate'
set grid

# Plot the data
plot filename using 1:2 with linespoints title 'Wing Shape'

