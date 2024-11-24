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

# Create a non-root user for Hadoop
RUN useradd -ms /bin/bash hadoop && echo "hadoop:hadoop" | chpasswd && \
    mkdir -p /home/hadoop/.ssh && \
    chown -R hadoop:hadoop /home/hadoop
# copy the start-cluster script
COPY start-cluster.sh /home/hadoop/start-cluster.sh
RUN chmod +x /home/hadoop/start-cluster.sh
# Switch to the Hadoop user
USER hadoop
WORKDIR /home/hadoop

# Configure SSH for Hadoop
RUN ssh-keygen -q -t rsa -N "" -f /home/hadoop/.ssh/id_rsa && \
    cat /home/hadoop/.ssh/id_rsa.pub >> /home/hadoop/.ssh/authorized_keys && \
    chmod 600 /home/hadoop/.ssh/authorized_keys && \
    echo "StrictHostKeyChecking no" >> /home/hadoop/.ssh/config

# Install Hadoop
RUN wget https://downloads.apache.org/hadoop/common/hadoop-3.3.6/hadoop-3.3.6.tar.gz && \
    tar -xzf hadoop-3.3.6.tar.gz && \
    mv hadoop-3.3.6 /home/hadoop/hadoop && \
    rm hadoop-3.3.6.tar.gz
ENV HADOOP_HOME=/home/hadoop/hadoop
ENV PATH=$PATH:$HADOOP_HOME/bin:$HADOOP_HOME/sbin

# Install Spark
RUN wget https://downloads.apache.org/spark/spark-3.5.3/spark-3.5.3-bin-hadoop3.tgz && \
    tar -xzf spark-3.5.3-bin-hadoop3.tgz && \
    mv spark-3.5.3-bin-hadoop3 /home/hadoop/spark && \
    rm spark-3.5.3-bin-hadoop3.tgz
ENV SPARK_HOME=/home/hadoop/spark
ENV PATH=$PATH:$SPARK_HOME/bin:$SPARK_HOME/sbin

# Install Sqoop
RUN wget https://archive.apache.org/dist/sqoop/1.4.7/sqoop-1.4.7.bin__hadoop-2.6.0.tar.gz && \
    tar -xzf sqoop-1.4.7.bin__hadoop-2.6.0.tar.gz && \
    mv sqoop-1.4.7.bin__hadoop-2.6.0 /home/hadoop/sqoop && \
    rm sqoop-1.4.7.bin__hadoop-2.6.0.tar.gz
ENV SQOOP_HOME=/home/hadoop/sqoop
ENV PATH=$PATH:$SQOOP_HOME/bin

# Configure Hadoop for a single-node cluster
COPY core-site.xml $HADOOP_HOME/etc/hadoop/core-site.xml
COPY hdfs-site.xml $HADOOP_HOME/etc/hadoop/hdfs-site.xml
COPY yarn-site.xml $HADOOP_HOME/etc/hadoop/yarn-site.xml
COPY mapred-site.xml $HADOOP_HOME/etc/hadoop/mapred-site.xml

# Format HDFS
RUN $HADOOP_HOME/bin/hdfs namenode -format

# Expose necessary ports
EXPOSE 9870 8088 7077 8080 9000

# Start script
CMD ["/home/hadoop/start-cluster.sh"]
