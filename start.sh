
export IMAGE_NAME=spark-2
export STACK_NAME=spark-cluster-2
export VERSION=2.0.1
export DOCKER_IMAGE=$IMAGE_NAME
export network=spark-cluster_public_2
export IMAGE_NAME_SUBMIT=spark-submit

export SPARK_VERSION=3.4.0
export HADOOP_VERSION=3.3.5
export SPARK_HOME=/opt/spark
export HADOOP_HOME=/opt/hadoop

# docker container rm -f $(docker ps -a -f "NAME=docker-spark-cluster-1_spark-submit_1*" -q)
# docker container rm -f $(docker ps -a  -q)
# docker network rm $(docker network ls -q)
# docker volume rm $(docker volume ls -q)
# docker image rm $(docker image ls -q)
# docker run -d --name test-container-jdk openjdk:8u342-jre watch "date >> /var/log/date.log"

# docker container rm -f $(docker ps -a -f "NAME=docker-spark-cluster*" -q)
# docker image rm $(docker image ls -q)
# docker system prune

docker network create $network
docker build -f Dockerfile -t $IMAGE_NAME .
# docker build -f Dockerfile_minio -t minio .
#   docker build -f Dockerfile_blank -t blank .
# docker-compose -f docker-compose-blank.yml up -d

# docker build -f Dockerfile_python -t spark_docker_v1 . 


docker-compose -f docker-compose.yml up -d 
docker wait spark-files_mysql-db
docker build -f Dockerfile_submit_2 -t $IMAGE_NAME_SUBMIT .
docker-compose -f docker-compose-submit.yml up -d 
# docker-compose -f docker-compose.yml up -d
# docker-compose -f docker-compose-minio.yml up -d
# docker-compose -f docker-compose-mysql.yml  up -d

# docker-compose -f docker-compose-thrift.yml up -d
# docker-compose -f docker-compose-submit.yml  up 

# winpty docker run -it $DOCKER_IMAGE
# docker exec -it docker-spark-cluster-1_spark-submit_1 bash

exec $SHELL