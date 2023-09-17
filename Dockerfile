FROM openjdk:11.0.11-jre-slim-buster as builder

# Add Dependencies for PySpark
RUN apt-get update && apt-get install -y curl vim wget software-properties-common ssh net-tools ca-certificates \
    python3 python3-pip python3-numpy python3-matplotlib \
    python3-scipy python3-pandas python3-simpy \
    libffi-dev

RUN update-alternatives --install "/usr/bin/python" "python" "$(which python3)" 1
# HADOOP_VERSION=3.3.4 \
# Fix the value of PYTHONHASHSEED
# Note: this is needed when you use Python 3.3 or greater
ENV SPARK_VERSION=3.2.1 \
    SPARK_HOME=/opt/spark \
    HADOOP_HOME=/opt/hadoop \
    PYTHONHASHSEED=1 \
    SCALA_VERSION=2.13.0 \
    SCALA_HOME=/opt/scala \
    PYTHON_HOME=/opt/python3.9 \
    PATH=$PATH:$SPARK_HOME/bin:$SPARK_HOME/sbin \
    PATH=$PATH:$HADOOP_HOME/bin \
    PYSPARK_PYTHON=/usr/bin/python3 
ENV SPARK_OPTS --driver-java-options=-Xms1024M --driver-java-options=-Xmx4096M --driver-java-options=-Dlog4j.logLevel=info
RUN mkdir -p /opt/hudi_test
RUN apt-get update && apt-get install -y wget && rm -rf /var/lib/apt/lists/* \
    && mkdir -p "$SPARK_HOME" "$HADOOP_HOME" "$SCALA_HOME" "$PYTHON_HOME" \
    && wget -qO - https://archive.apache.org/dist/spark/spark-3.3.1/spark-3.3.1-bin-hadoop2.tgz | tar -xz -C $SPARK_HOME --strip-components=1 \
    && wget -qO - https://archive.apache.org/dist/hadoop/common/hadoop-2.7.7/hadoop-2.7.7.tar.gz | tar -xz -C $HADOOP_HOME --strip-components=1 \
    # && wget -qO - https://downloads.lightbend.com/scala/${SCALA_VERSION}/scala-${SCALA_VERSION}.tgz | tar -xz -C $SCALA_HOME --strip-components=1 \
    && wget -qO - https://www.python.org/ftp/python/3.9.16/Python-3.9.16.tgz  | tar -xz -C $PYTHON_HOME --strip-components=1 
# RUN cd $PYTHON_HOME | ./configure --enable-optimizations | make altinstall 
# Let's change to  "$NB_USER" command so the image runs as a non root user by default
USER $NB_UID

# RUN ln -s "${SCALA_HOME}/bin/"* "/usr/bin/"



# RUN export PATH="/usr/local/sbt/bin:$PATH"
# RUN wget --no-verbose -O apache-spark.tgz "https://dlcdn.apache.org/spark/spark-${SPARK_VERSION}/spark-${SPARK_VERSION}-bin-hadoop3.tgz" \
#     && mkdir -p "$SPARK_HOME" "$HADOOP_HOME" \
#     && tar -xf apache-spark.tgz -C /opt/spark --strip-components=1 \
#     && rm apache-spark.tgz
# RUN  wget -qO - https://dlcdn.apache.org/hadoop/common/hadoop-${HADOOP_VERSION}/hadoop-${HADOOP_VERSION}-src.tar.gz | tar -xz -C $HADOOP_HOME --strip-components=1

FROM builder as apache-spark

WORKDIR /opt/spark

# ENV SPARK_MASTER_PORT=7077 \
#     SPARK_MASTER_WEBUI_PORT=8080 \
ENV  SPARK_LOG_DIR=/opt/spark/logs \
    SPARK_MASTER_LOG=/opt/spark/logs/spark-master.out \
    SPARK_WORKER_LOG=/opt/spark/logs/spark-worker.out \
    # SPARK_WORKER_WEBUI_PORT=8080 \
    # SPARK_WORKER_PORT=7000 \
    # SPARK_MASTER="spark://spark-master-local:7077" \
    SPARK_WORKLOAD="master"

EXPOSE 8080 7077 7000 9090

RUN mkdir -p $SPARK_LOG_DIR && \
    touch $SPARK_MASTER_LOG && \
    touch $SPARK_WORKER_LOG && \
    ln -sf /dev/stdout $SPARK_MASTER_LOG && \
    ln -sf /dev/stdout $SPARK_WORKER_LOG

COPY start-spark-1.sh /

COPY data/hive-site.xml $SPARK_HOME/conf/
COPY apps/mysql-connector-java-8.0.14.jar $SPARK_HOME/jars/
COPY apps/ojdbc8-21.5.0.0.jar $SPARK_HOME/jars/
COPY apps/hadoop-aws-2.7.4.jar $SPARK_HOME/jars/
#COPY apps/jarfiles/hudi-spark3.3-bundle_2.12-0.12.0.jar $SPARK_HOME/jars/

CMD ["/bin/bash", "/start-spark-1.sh"]
