# Use apache hadoop as the base image
FROM apache/hadoop:3.3.6

# Set environment variables for Spark and Sqoop

ENV SPARK_HOME=/opt/spark
ENV SQOOP_HOME=/opt/sqoop
ENV PATH=$PATH:$SPARK_HOME/bin:$SPARK_HOME/sbin:$SQOOP_HOME/bin

# Install Spark
RUN wget https://downloads.apache.org/spark/spark-3.5.3/spark-3.5.3-bin-hadoop3.tgz && \
    tar -xzf spark-3.5.3-bin-hadoop3.tgz && \
    mv spark-3.5.3-bin-hadoop3 /home/hadoop/spark && \
    rm spark-3.5.3-bin-hadoop3.tgz

# Install Sqoop
RUN  wget https://archive.apache.org/dist/sqoop/1.4.7/sqoop-1.4.7.bin__hadoop-2.6.0.tar.gz && \
    tar -xzf sqoop-1.4.7.bin__hadoop-2.6.0.tar.gz && \
    mv sqoop-1.4.7.bin__hadoop-2.6.0 /home/hadoop/sqoop && \
    rm sqoop-1.4.7.bin__hadoop-2.6.0.tar.gz

# Install Python for Spark Streaming
RUN apt-get update && apt-get install -y python3 python3-pip && \
    pip3 install pyspark

# Configure Spark for Hadoop
RUN echo "export SPARK_DIST_CLASSPATH=$(hadoop classpath)" >> $SPARK_HOME/conf/spark-env.sh && \
    echo "export SPARK_MASTER_HOST='localhost'" >> $SPARK_HOME/conf/spark-env.sh && \
    chmod +x $SPARK_HOME/conf/spark-env.sh

# Expose necessary ports
EXPOSE 8088 9870 7077 8080

# Start Hadoop services and Spark master
COPY start-cluster.sh /opt/start-cluster.sh
RUN chmod +x /opt/start-cluster.sh
CMD ["/opt/start-cluster.sh"]
