#!/bin/bash
#
# Used to launch jmeter on a Docker instance:
# docker run --rm \
#  -e "P12PWD=password" \
#  -v /home/ec2-user/TEST_NAME/log-dir:/logs \
#  -v /home/ec2-user/TEST_NAME/data-dir:/input_data \
#  -v /home/ec2-user/TEST_NAME/conf-dir:/jmconf \
#  --entrypoint "/input_data/run.sh" \
#  ordnancesurvey/jmeter:v1.0
#
# The ability to use a P12 certificate for mutual SSL is available, the password
# must be passed to Docker on launching the instance and it will be picked up by
# this script in an attempt to reduce risk of exposing said password in a file
# that can be found.

# if the java_libraries folder exists in input_data then add it to the LD_LIBRARY_PATH
if [ -d "/input_data/java_libraries" ]; then
    export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:"/input_data/java_libraries"
fi

# if the lib folder exists in input_data then copy all plugins to the jmeter lib folder
if [ -d "/input_data/lib" ]; then
    yes | cp -rf /input_data/lib/* /var/lib/apache-jmeter/lib
fi

JARGS=""
if [[ ${JMETER_ARGS} ]]; then
    JARGS=${JMETER_ARGS}
fi

SYSP=""
if [[ ! -z ${P12PWD} ]]; then
    SYSP="-Djavax.net.ssl.keyStore=/input_data/%P12_FILE% -Djavax.net.ssl.keyStorePassword=${P12PWD} -Djavax.net.ssl.keyStoreType=pkcs12"
fi

if [[ -z ${JMX_FILE} ]]; then
    TEST_PLAN=/input_data/%JMX_FILE%
else
    TEST_PLAN=/input_data/${JMX_FILE}
fi

PROPERTIES=/jmconf/jmeter.properties
RESULTS=/logs/%TEST_NAME%_results_%TIMESTAMP%.log
LOG=/logs/%TEST_NAME%_log_%TIMESTAMP%.log

/var/lib/apache-jmeter/bin/jmeter -n -t ${TEST_PLAN} -p ${PROPERTIES} -l ${RESULTS} -j ${LOG} ${SYSP} ${JARGS}
