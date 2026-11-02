#!/bin/bash
#set -x

# Check arguments
if [ "$#" -lt 1 ];
then
    echo ""
    echo " CREATOR checker"
    echo "  Usage: ./s20_checker.sh <reduced group>"
    echo ""
    exit -1
fi


# Set initial values
GROUP=$1
TXT_FILE="/workspace/submissions/${GROUP}/submissions.txt"
ARCH_PATH="/creator/architecture/RISCV/RV32IMFD.yml"
LIB_PATH="/workspace/tests/exercises/length.yml"
EXERCISES=$(ls -1 /workspace/tests)
TEST=$(ls -1 /workspace/tests/$E | grep "\.s")


# Submissions
if [ -f "$TXT_FILE" ]; then
    echo "Using existing list: $TXT_FILE"
else
    echo "Creating new list: $TXT_FILE"
    ls -1 "/workspace/submissions/$GROUP" | sed 's/.zip$//' | grep -v submissions | sort | uniq > "$TXT_FILE"
fi
SUBMISSIONS=$(cat "$TXT_FILE" | tr -d '\r' | grep -v '^$')


# Results directory setup
rm    -rf /workspace/results/$GROUP
mkdir -p  /workspace/results/$GROUP


# HTML: header
touch  /workspace/results/$GROUP/index_$GROUP.html
echo "<html>"   >> /workspace/results/$GROUP/index_$GROUP.html
echo "<body>"   >> /workspace/results/$GROUP/index_$GROUP.html
echo "<table border='1' style='border-collapse:collapse; min-width:50%'>" >> /workspace/results/$GROUP/index_$GROUP.html

echo "<tr align=center>"  >> /workspace/results/$GROUP/index_$GROUP.html
echo "<td>&nbsp;</td>"    >> /workspace/results/$GROUP/index_$GROUP.html
echo "<td>&nbsp;</td>"    >> /workspace/results/$GROUP/index_$GROUP.html
for E in $EXERCISES; do
   NTEST=$(ls -1 /workspace/tests/$E | grep "\.s" | wc -l)
   echo "<td colspan="$NTEST">$E</td>"  >> /workspace/results/$GROUP/index_$GROUP.html
done
echo "</tr>" >> /workspace/results/$GROUP/index_$GROUP.html


echo "<tr align=center>"   >> /workspace/results/$GROUP/index_$GROUP.html
echo "<td>Submission</td>" >> /workspace/results/$GROUP/index_$GROUP.html
echo "<td>NIA</td>"        >> /workspace/results/$GROUP/index_$GROUP.html
for E in $EXERCISES; do
   TEST=$(ls -1 /workspace/tests/$E | grep "\.s")
   for T in $TEST; do
       echo "<td><a href=\"../../tests/${E}/${T}\">$T</a></td>"   >> /workspace/results/$GROUP/index_$GROUP.html
   done
done
echo "</tr>" >> /workspace/results/$GROUP/index_$GROUP.html


# Grades
for S in $SUBMISSIONS; do

    echo ""
    echo "### $S"
    echo ""

    mkdir -p /workspace/results/$GROUP/$S
    mkdir -p /workspace/results/$GROUP/$S/test
    mkdir -p /workspace/results/$GROUP/$S/test_check

    ## HTML row
    rm -fr /tmp/html_row.$$
    touch  /tmp/html_row.$$

    ## Log
    echo -e "#####  Submission: ${S}  #####\n" >> /workspace/results/$GROUP/$S/logs.txt

    for E in $EXERCISES; do

        ## Log
        echo -e "#####  Work: ${E}  #####\n" >> /workspace/results/$GROUP/$S/logs.txt

        for T in $TEST; do

            echo "### ${E}_${T}"
            echo "echo silent | /creator/creator.sh -a $ARCH_PATH -l $LIB_PATH -s /workspace/results/$GROUP/$S/test/test_${E}_${T} >& /tmp/output.txt"
	    echo "diff  --strip-trailing-cr   /workspace/tests/${E}/${TID}_output.txt                                                 /tmp/output.txt"
            echo ""

            # Build test code
            cat /workspace/submissions/$GROUP/$S/${E}.s | \
            sed 's/\.text/ /gi'     | \
            sed 's/\.data/ /gi'     | \
            sed 's/\bmain:/main_student:/gi' > /tmp/$$.txt

            cat /workspace/tests/$E/$T /tmp/$$.txt  >  /workspace/results/$GROUP/$S/test/test_${E}_${T}

            # CREATOR checker execution
            echo silent | /creator/creator.sh -a $ARCH_PATH \
			                      -l $LIB_PATH \
		                              -s /workspace/results/$GROUP/$S/test/test_${E}_${T} &> /workspace/results/$GROUP/$S/test_check/output_${T}.txt
            echo "" >> /workspace/results/$GROUP/$S/test_check/output_${T}.txt

            # Check diff
	    TID=$(echo ${T} | sed s/\.s//g)
	    diff  --strip-trailing-cr /workspace/results/$GROUP/$S/test_check/output_${T}.txt \
		                      /workspace/tests/${E}/${TID}_output.txt >& /workspace/results/$GROUP/$S/test_check/diff_${E}_${T}.txt
            if [ $? -eq 0 ]; then
                OK=1
            else
                OK=0
            fi

            ## HTML
            echo "<td><a href=\"./$S/test_check/diff_${E}_${T}.txt\">$OK</a></td>"  >> /tmp/html_row.$$

            ## Log
            echo "#####  Test: ${T}  #####" >> /workspace/results/$GROUP/$S/logs.txt
            if [ $OK -eq 1 ]; then
                 echo " * It meets the expected output." >> /workspace/results/$GROUP/$S/logs.txt
            else
                 echo " * Unexpected output:" >> /workspace/results/$GROUP/$S/logs.txt
                 cat /workspace/results/$GROUP/$S/test_check/diff_${E}_${T}.txt >> /workspace/results/$GROUP/$S/logs.txt
            fi
            echo -e "\n"   >> /workspace/results/$GROUP/$S/logs.txt

	    ## Screen (in case of error)
            if [ $? -ne 0 ]; then
                echo "### Out ##################################"
                cat /workspace/results/$GROUP/$S/test_check/diff_${E}_${T}.txt
                echo "##########################################"
                echo ""
            fi

        done
    done

    ## HTML
    NIAS=$(echo $S| sed "s/ec_p1_//g" | sed "s/_/ /g")
    for NIA in $NIAS; do
        echo "<tr align=center>"                                         >> /workspace/results/$GROUP/index_$GROUP.html
        echo "<td><a href=\"../../submissions/$GROUP/$S/\">$S</a></td>"  >> /workspace/results/$GROUP/index_$GROUP.html
        echo "<td><a href=\"./$S/logs.txt\">$NIA</a></td>"               >> /workspace/results/$GROUP/index_$GROUP.html
        cat  /tmp/html_row.$$                                            >> /workspace/results/$GROUP/index_$GROUP.html
        echo "</tr>"                                                     >> /workspace/results/$GROUP/index_$GROUP.html
    done

    rm -fr /tmp/html_row.$$

done

## HTML
echo "</table>"   >> /workspace/results/$GROUP/index_$GROUP.html
echo "</body>"    >> /workspace/results/$GROUP/index_$GROUP.html
echo "</html>"    >> /workspace/results/$GROUP/index_$GROUP.html

## CSV
sed -e 's/<\/tr>/\n/g' -e 's/<\/td>/,/g' -e 's/<[^>]*>//g' results/$GROUP/index_$GROUP.html | grep -v '^[[:space:]]*$' > results/$GROUP/index_$GROUP.csv

