#!/bin/bash

TEST_KEY=%TEST_KEY%
LOG_DIR=/logs/${TEST_KEY}
TEMP_FILE=${LOG_DIR}/${TEST_KEY}_temp.csv
RESULTS_FILE=${LOG_DIR}/${TEST_KEY}_results.csv

echo "Counting number of files in test directory minus 1"
COUNT=$(expr $(ls -1 | wc -l) - 1)

echo "Merging all results together and output to new file"
sort -n -k 1,1.13 -o ${TEMP_FILE} ${LOG_DIR}/*.csv

echo "Removing duplicate headers"
sed -e "1,${COUNT}d" < ${TEMP_FILE} > ${RESULTS_FILE}

echo "Removing temp file"
rm -f ${TEMP_FILE}

echo "Generating report"
/var/lib/apache-jmeter/bin/jmeter -g ${RESULTS_FILE} -o report

echo "Finished"
