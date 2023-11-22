#! /bin/bash

psql_host=$1
psql_port=$2
db_name=$3
psql_user=$4
psql_password=$5

if [ $# -ne 5 ]; then
  echo "Illegal number of parameters"
  exit 1
fi

vmstat_mb=$(vmstat --unit M)
specs=$(lscpu)

hostname=$(hostname -f)
cpu_number=$(echo "$specs" | egrep "^CPU\(s\):" | awk '{print $2}' | xargs)
cpu_architecture=$(echo "$specs" | egrep "Architecture:" | awk '{print $2}' | xargs)
cpu_model=$(echo "$specs" | egrep "Model name:" | awk '{print $1=""; $2=""; print $0}' | xargs)
cpu_mhz=$(echo "$specs" | egrep "CPU MHz" | awk '{print $3}' | xargs)
l2_cache=$(echo "$specs" | egrep "L2 cache" | awk '{gsub(/K/, "", $3); print $3}' | xargs)
timestamp=$(vmstat -t | awk 'NR==3 {print $18, $19}' | xargs)
total_mem=$(echo "$vmstat_mb" | awk '{print $4}' | tail -n1 | xargs)

insert_stmt="INSERT INTO host_info(hostname, cpu_number, cpu_architecture, cpu_model, cpu_mhz, l2_cache, timestamp, total_mem)
    VALUES('$hostname', '$cpu_number', '$cpu_architecture', '$cpu_model', '$cpu_mhz', '$l2_cache', '$timestamp', '$total_mem')"

export PGPASSWORD=$psql_password

psql -h $psql_host -p $psql_port -d $db_name -U $psql_user -c "$insert_stmt"

exit $?