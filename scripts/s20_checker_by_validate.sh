#!/bin/bash
#set -x

# check arguments
if [ "$#" -lt 1 ];
then
    echo ""
    echo " CREATOR checker"
    echo "  Usage: ./s30_checker.sh <reduced group>"
    echo ""
    exit -1
fi

# set initial values
GROUP=$1                                             # Group identification (e.g., gr-1, gr-2, etc.).
ARCH_PATH="/creator/architecture/RISCV/RV32IMFD.yml" # Architecture path for CREATOR.

TXTFILE="/workspace/submissions/${GROUP}/submissions.txt"


# If the text file already exists, use it.
# Otherwise, create it from the current directory list.
if [ -f "$TXTFILE" ]; then
    echo "Using existing list: $TXTFILE"
else
    echo "Creating new list: $TXTFILE"
    ls -1 "/workspace/submissions/$GROUP" | sed 's/.zip$//' | grep -v index_$GROUP.html | sort | uniq > "$TXTFILE"
fi


# Results directory setup
rm    -rf /workspace/results/$GROUP
mkdir -p  /workspace/results/$GROUP
touch     /workspace/results/$GROUP/grades_$GROUP.csv
#####
touch             /workspace/results/$GROUP/index_$GROUP.html
echo "<html>" >>  /workspace/results/$GROUP/index_$GROUP.html
#####


# Read directories to process
SUBMISSIONS=$(cat "$TXTFILE" | tr -d '\r' | grep -v '^$')
EXERCISES=$(ls -1 /workspace/tests)


# Header for CSV file
echo -n "Group;" >> /workspace/results/$GROUP/grades_$GROUP.csv

for E in $EXERCISES; do
    TEST=$(ls -1 /workspace/tests/$E | grep -v "\.o" | grep -v "\.yml") # TODO: generic

    for T in $TEST; do
        echo -n $E"_"$T";" >> /workspace/results/$GROUP/grades_$GROUP.csv
    done
done

echo "" >> /workspace/results/$GROUP/grades_$GROUP.csv


# Grades
for S in $SUBMISSIONS; do

    echo "### $S ###################### "
    echo -n $S";" >> /workspace/results/$GROUP/grades_$GROUP.csv

    mkdir -p /workspace/results/$GROUP/$S
    mkdir -p /workspace/results/$GROUP/$S/test
    mkdir -p /workspace/results/$GROUP/$S/test_output
    #######
    echo "<table>"           >> /workspace/results/$GROUP/index_$GROUP.html
    echo "<tr>"              >> /workspace/results/$GROUP/index_$GROUP.html
    echo "<td>Group</td>"    >> /workspace/results/$GROUP/index_$GROUP.html
    echo "<td>Test</td>"     >> /workspace/results/$GROUP/index_$GROUP.html
    echo "<td>OK</td>"       >> /workspace/results/$GROUP/index_$GROUP.html
    echo "<td>Output</td>"   >> /workspace/results/$GROUP/index_$GROUP.html
    echo "<td>Src</td>"      >> /workspace/results/$GROUP/index_$GROUP.html
    echo "</tr>"             >> /workspace/results/$GROUP/index_$GROUP.html
    #######


    for E in $EXERCISES; do
        TEST=$(ls -1 /workspace/tests/$E | grep -v "\.o" | grep -v "\.yml") # TODO: generic

        for T in $TEST; do

            echo "${E}_${T}"

            # Build test code
            cat /workspace/submissions/$GROUP/$S/${E}.s | \
            sed 's/\.text/ /gi'     | \
            sed 's/\.data/ /gi'     | \
            sed 's/\bmain:/main_student:/gi' > /tmp/$$.txt

            cat /workspace/tests/$E/$T /tmp/$$.txt  >  /workspace/results/$GROUP/$S/test/test_${E}_${T} # TODO: generic

            # CREATOR checker execution
            /creator/creator.sh -a $ARCH_PATH -s /workspace/results/$GROUP/$S/test/test_${E}_${T} --validate /workspace/tests/$E/${T%.s}_solution.yml > /tmp/$$.txt

            if [ $? -eq 0 ]
            then
                echo -n "1;" >> /workspace/results/$GROUP/grades_$GROUP.csv
                OK=1
            else
                echo -n "0;" >> /workspace/results/$GROUP/grades_$GROUP.csv
                OK=0

                mkdir -p /workspace/results/$GROUP/$S/test_problems

                /creator/creator.sh -a $ARCH_PATH -s /workspace/results/$GROUP/$S/test/test_${E}_${T} --validate /workspace/tests/$E/${T%.s}_solution.yml &> /workspace/results/$GROUP/$S/test_problems/problem_${E}_${T}.txt

                #/creator/creator.sh -a "/creator/architecture/RISC_V_RV32IMFD.json" -s /workspace/results/$GROUP/$S/test/test_${E}_${T} | aha > /workspace/results/$GROUP/$S/test_problems/problem_${E}_${T}.html
                #wkhtmltopdf /workspace/results/$GROUP/$S/test_problems/problem_${E}_${T}.html /workspace/results/$GROUP/$S/test_problems/problem_${E}_${T}.pdf &> /dev/null
            fi

            cp /tmp/$$.txt /workspace/results/$GROUP/$S/test_output/test_${E}_${T}_output.txt

            echo "#####  ${E}_${T}  #####" >> /workspace/results/$GROUP/$S/logs.txt
            cat /tmp/$$.txt >> /workspace/results/$GROUP/$S/logs.txt
            echo "" >> /workspace/results/$GROUP/$S/logs.txt
            echo "" >> /workspace/results/$GROUP/$S/logs.txt

            cat /tmp/$$.txt
            echo ""
            rm  /tmp/$$.txt

            #######
            echo ""                                                                        >> /workspace/results/$GROUP/index_$GROUP.html
            echo "<tr>"                                                                    >> /workspace/results/$GROUP/index_$GROUP.html
            echo "<td>$E</td>"                                                             >> /workspace/results/$GROUP/index_$GROUP.html
            echo "<td>$T</td>"                                                             >> /workspace/results/$GROUP/index_$GROUP.html
            echo "<td>$OK</td>"                                                            >> /workspace/results/$GROUP/index_$GROUP.html
            echo "<td><a href=\"./$E/test_output/test_${E}_${T}_output.txt\">link</a></td>"  >> /workspace/results/$GROUP/index_$GROUP.html
            echo "</tr>"                                                                   >> /workspace/results/$GROUP/index_$GROUP.html
            #######
        done
    done


    #######
    echo "<tr>"              >> /workspace/results/$GROUP/index_$GROUP.html
    echo "<td>Group</td>"    >> /workspace/results/$GROUP/index_$GROUP.html
    echo "<td>Test</td>"     >> /workspace/results/$GROUP/index_$GROUP.html
    echo "<td>OK</td>"       >> /workspace/results/$GROUP/index_$GROUP.html
    echo "<td>Output</td>"   >> /workspace/results/$GROUP/index_$GROUP.html
    echo "<td>Src</td>"      >> /workspace/results/$GROUP/index_$GROUP.html
    echo "</tr>"             >> /workspace/results/$GROUP/index_$GROUP.html
    #######


    #######
    echo "</table>"        >> /workspace/results/$GROUP/index_$GROUP.html
    echo "</html>"         >> /workspace/results/$GROUP/index_$GROUP.html
    #######

    echo ""
    echo ""
    echo "" >> /workspace/results/$GROUP/grades_$GROUP.csv
done