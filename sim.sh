# Usage: $0 <prefix> <file> (-d) [dependency1] [dependency2] ...
# Description: This script is used to run the simulator.

# It takes the following arguments: 
# The prefix of the file to be simulated 
# The file to be simulated
# optional dependencies
# The dependencies of the file to be simulated



if [ $# -lt 2 ]; then
    echo "Usage: $0 <prefix> <file> (-d) [dependency1] [dependency2] ..."
    echo "Example: $0 path test -d dep1.sv dep2.sv"
    # num args:
    echo "Number of arguments: $#"
    exit 1
fi 

prefix=$1
file=$2


deps=""
if [ "$3" == "-d" ]; then
    for i in "${@:4}"; do
        deps="$deps $prefix/src/$i"
    done
fi

echo "Dependencies: $deps"

iverilog -g2012 -DMKWAVEFORM -o  $prefix/sim/$file.out $deps  $prefix/src/$file.sv $prefix/sim/$file\_tb.sv \
&& cd $1/sim \
&& vvp ./$2.out \
&& cd - \
&& open $1/sim/$2.vcd

