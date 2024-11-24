#!/bin/bash

# Start HDFS
$HADOOP_HOME/sbin/start-dfs.sh

# Start YARN
$HADOOP_HOME/sbin/start-yarn.sh

# Start Spark Master
$SPARK_HOME/sbin/start-master.sh

# Start Spark Worker
$SPARK_HOME/sbin/start-worker.sh spark://localhost:7077

# Keep the container running
tail -f /dev/null
