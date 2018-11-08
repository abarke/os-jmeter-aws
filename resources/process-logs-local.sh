#!/bin/bash

TEST_NAME=%TEST_NAME%
TEST_KEY=%TEST_KEY%
TEST_DIR=%TEST_DIR%
TEST_AWS_PEM=%AWS_PEM%
TEST_LOCAL_LOG_DIR=${TEST_DIR}/logs/${TEST_KEY}
TEST_REMOTE_LOG=/home/ec2-user/${TEST_NAME}/log-dir/${TEST_NAME}_${TEST_KEY}.log

JMETER_INSTANCES='%JMETER_INSTANCES%'

# create directory for logs
mkdir -p ${TEST_LOCAL_LOG_DIR}

# set permissions on private key
chmod 400 ${TEST_AWS_PEM}

# get log files from all jmeter instances
for IP in ${JMETER_INSTANCES}; do
    echo "Pulling logs from ${IP}"
    IPUL=$(echo ${IP} | tr '.' '_')
    scp -i ${TEST_AWS_PEM} -oStrictHostKeyChecking=no ec2-user@${IP}:${TEST_REMOTE_LOG} ${TEST_LOCAL_LOG_DIR}/${TEST_KEY}-${IPUL}.csv
    chmod 644 ${TEST_LOCAL_LOG_DIR}/${TEST_KEY}-${IPUL}.csv
    echo "Log file saved to ${TEST_LOCAL_LOG_DIR}/${TEST_KEY}-${IPUL}.csv"
done

echo "Finished"
