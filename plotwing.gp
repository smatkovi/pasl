# Check if the argument is provided
if (ARG1 == "") {
    print "Usage: gnuplot plot_wingprofile.gp <filename>"
    exit
}

# Set the input filename from the first argument
filename = ARG1

# Extract the base name for the output file and title
basename = word(filename, 1, ".")
set title sprintf("Wing Profile: %s", basename)
set terminal pngcairo size 1066, 193
set output sprintf("%s.png", basename)
set xlabel 'X Coordinate'
set ylabel 'Y Coordinate'
set grid
plot filename using 1:2 with linespoints title 'Wing Shape'
