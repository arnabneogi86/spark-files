#!/bin/bash

. "/opt/spark/bin/load-spark-env.sh"

if [ "$SPARK_WORKLOAD" == "master" ];
then

    export SPARK_MASTER_HOST=`hostname`

    echo $SPARK_WORKLOAD>>/opt/spark/logs/master.log
    echo $SPARK_MASTER_HOST>>/opt/spark/logs/master.log
    echo $SPARK_MASTER_PORT>>/opt/spark/logs/master.log
    echo $SPARK_MASTER_WEBUI_PORT>>/opt/spark/logs/master.log
    echo $SPARK_MASTER_LOG>>/opt/spark/logs/master.log

    cd /opt/spark/bin && ./spark-class org.apache.spark.deploy.master.Master \
    --ip $SPARK_MASTER_HOST \
    --port $SPARK_MASTER_PORT \
    --webui-port $SPARK_MASTER_WEBUI_PORT >> $SPARK_MASTER_LOG

elif [ "$SPARK_WORKLOAD" == "worker" ];
then

    echo $SPARK_WORKLOAD>>/opt/spark/logs/worker.log
    echo $SPARK_WORKER_WEBUI_PORT>>/opt/spark/logs/worker.log
    echo $SPARK_WORKER_WEBUI_PORT>>/opt/spark/logs/worker.log
    echo $SPARK_WORKER_LOG>>/opt/spark/logs/worker.log

    cd /opt/spark/bin && ./spark-class org.apache.spark.deploy.worker.Worker --webui-port $SPARK_WORKER_WEBUI_PORT $SPARK_MASTER >> $SPARK_WORKER_LOG

elif [ "$SPARK_WORKLOAD" == "submit" ];
then
	echo $SPARK_WORKLOAD>>/opt/spark/logs/error.log
    echo "SPARK SUBMIT"
    echo "pyspark"
    cd /opt
    pyspark
    #  $SPARK_HOME/bin/spark-shell --conf spark.executor.memory=2G --conf spark.executor.cores=1 --master  local[*]
    #  $SPARK_HOME/bin/spark-shell --conf spark.executor.memory=2G --conf spark.executor.cores=1 --master spark://spark-master:7077
    # cd /opt/spark/bin && ./spark-submit --class your.class.Name /path/to/your/app.jar arg1 arg2
    tail -f /dev/null

    # /bin/bash -c "spark-submit --master local[*] /opt/spark/jobs/your_spark_job.py"
    # cp -r ./examples/ /home/examples/
	# cp -r ./resources/log4j.properties ./resources/spark-defaults.conf $SPARK_HOME/conf/
else
	echo $SPARK_WORKLOAD>>/opt/spark/logs/error.log
    echo "Undefined Workload Type $SPARK_WORKLOAD, must specify: master, worker, submit"
fi