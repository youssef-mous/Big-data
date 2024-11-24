# Use Ubuntu as the base image
FROM ubuntu:22.04

# Install necessary packages
RUN apt-get update && apt-get install -y \
    openjdk-8-jdk \
    wget \
    python3 \
    python3-pip \
    ssh \
    net-tools \
    vim \
    && apt-get clean

# Set environment variables for Java
ENV JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
ENV PATH=$PATH:$JAVA_HOME/bin

# Install Hadoop
RUN wget https://downloads.apache.org/hadoop/common/hadoop-3.3.6/hadoop-3.3.6.tar.gz && \
    tar -xzf hadoop-3.3.6.tar.gz && \
    mv hadoop-3.3.6 /usr/local/hadoop && \
    rm hadoop-3.3.6.tar.gz
ENV HADOOP_HOME=/usr/local/hadoop
ENV PATH=$PATH:$HADOOP_HOME/bin:$HADOOP_HOME/sbin

# Install Spark
RUN wget https://downloads.apache.org/spark/spark-3.5.3/spark-3.5.3-bin-hadoop3.tgz && \
    tar -xzf spark-3.5.3-bin-hadoop3.tgz && \
    mv spark-3.5.3-bin-hadoop3 /usr/local/spark && \
    rm spark-3.5.3-bin-hadoop3.tgz
ENV SPARK_HOME=/usr/local/spark
ENV PATH=$PATH:$SPARK_HOME/bin:$SPARK_HOME/sbin

# Install Sqoop
RUN wget https://archive.apache.org/dist/sqoop/1.4.7/sqoop-1.4.7.bin__hadoop-2.6.0.tar.gz && \
    tar -xzf sqoop-1.4.7.bin__hadoop-2.6.0.tar.gz && \
    mv sqoop-1.4.7.bin__hadoop-2.6.0 /usr/local/sqoop && \
    rm sqoop-1.4.7.bin__hadoop-2.6.0.tar.gz
ENV SQOOP_HOME=/usr/local/sqoop
ENV PATH=$PATH:$SQOOP_HOME/bin
# Create a Hadoop user and set permissions
RUN useradd -ms /bin/bash hadoop && echo "hadoop:hadoop" | chpasswd && \
    mkdir -p /usr/local/hadoop/logs && \
    chown -R hadoop:hadoop /usr/local/hadoop /usr/local/spark /tmp

# Set environment variables for Hadoop daemons
ENV HDFS_NAMENODE_USER=hadoop
ENV HDFS_DATANODE_USER=hadoop
ENV HDFS_SECONDARYNAMENODE_USER=hadoop
ENV YARN_RESOURCEMANAGER_USER=hadoop
ENV YARN_NODEMANAGER_USER=hadoop

# Switch to the Hadoop user
USER hadoop
WORKDIR /home/hadoop

# Format HDFS (as the Hadoop user)
RUN $HADOOP_HOME/bin/hdfs namenode -format
# Configure Hadoop
COPY core-site.xml $HADOOP_HOME/etc/hadoop/core-site.xml
COPY hdfs-site.xml $HADOOP_HOME/etc/hadoop/hdfs-site.xml
COPY yarn-site.xml $HADOOP_HOME/etc/hadoop/yarn-site.xml
COPY mapred-site.xml $HADOOP_HOME/etc/hadoop/mapred-site.xml

# Format HDFS
RUN $HADOOP_HOME/bin/hdfs namenode -format

# Expose necessary ports
EXPOSE 9870 8088 7077 8080 9000

# Start script
COPY start-cluster.sh /start-cluster.sh
RUN chmod +x /start-cluster.sh
CMD ["/start-cluster.sh"]
