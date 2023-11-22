# 1. Introduction
Linux Cluster Monitoring project aims to collect and manage data from a cluster of Linux servers. It gathers hardware specifications and usage data, and stores this information in a PostgreSQL database. The primary users of this system are Jarvis Linux Cluster Administration (LCA) team who need insights into the health and performance of the servers. Key technologies used include bash scripting, Docker, Git, and PostgreSQL.

# 2. Quick Start
To get started with the Jarvis Cluster Monitoring System, type in these commands to execute the scripts:
1. Initialize a PostgreSQL (psql) instance using the **psql_docker.sh** script:
   
    `./scripts/psql_docker.sh`


2. Create 2 tables by executing **ddl.sql** script:

   `psql -h localhost -U postgres -d host_agent -f sql/ddl.sql`


3. Insert hardware specifications data into the database using **host_info.sh**:

    `.scripts/host_info.sh localhost 5432 host_agent postgres password`


4. Insert hardware usage data into the database using **host_usage.sh**:

    `.scripts/host_usage.sh localhost 5432 host_agent postgres password`


5. Automate data insertion by setting up `crontab`:

    `* * * * * bash /scripts/host_usage.sh localhost 5432 host_agent postgres password &> /tmp/host_usage.log`

# 3. Implementation
## 3.1. Architecture
![Cluster Diagram](../linux_sql/assets/LCM_architecture.svg)

## 3.2. Scripts

- The **psql_docker.sh** script is used to set up a PostgreSQL Docker container on local machine.

    **Usage:**

    `./scripts/psql_docker.sh`


- The **host_info.sh** script is responsible for gathering and inserting hardware specifications into the database.

    **Usage:**

    `./scripts/host_info.sh <psql_host> <psql_port> <db_name> <psql_user> <psql_password>`

- The `host_usage.sh` script continuously collects and inserts real-time hardware usage data into the database.

    **Usage:**

    `./scripts/host_usage.sh <psql_host> <psql_port> <db_name> <psql_user> <psql_password>`
- A cron job is set up with `crontab` for automating the execution of the **host_usage.sh** script every minute, ensuring we always have up-to-date usage data.
## 3.3. Database Modeling
Our `host_agent` database schema comprises two tables, `host_info` to store specification data and `host_usage` to store usage data.

- `host_info`table:

| Column           | Type      | Description                 |
|------------------|-----------|-----------------------------|
| id               | SERIAL    | Unique identifier           |
| hostname         | VARCHAR   | Node's hostname             |
| cpu_number       | INT2      | Number of CPUs              |
| cpu_architecture | VARCHAR   | CPU architecture            |
| cpu_model        | VARCHAR   | CPU model                   |
| cpu_mhz          | FLOAT8    | CPU clock speed (MHz)       |
| l2_cache         | INT4      | L2 cache size (KB)          |
| timestamp        | TIMESTAMP | Timestamp of data insertion |
| total_mem        | INT4      | Total memory (MB)           |

- `host_usage`table:

| Column         | Type      | Description                    |
|----------------|-----------|--------------------------------|
| timestamp      | TIMESTAMP | Timestamp of data insertion    |
| host_id        | SERIAL    | Host identifier                |
| memory_free    | INT4      | Free memory (MB)               |
| cpu_idle       | INT2      | CPU idle percentage            |
| cpu_kernel     | INT2      | CPU kernel usage percentage    |
| disk_io        | INT4      | Disk I/O operations per second |
| disk_available | INT4      | Available disk space (MB)      |

# 4. Test
To verify the functionality of the DDL SQL statements used to create the database tables, I performed the following steps:
1. Ensure that the PostgreSQL database server is running and accessible by running these commands:
    ```
   # Start the docker server if it's not running
   sudo systemctl status docker || sudo systemctl start docker
   
   # Check if psql container is running
   docker ps -f name=jrvs-psql
   
   # Start the psql container if it's not running
   docker container start jrvs-psql
   ```
2. Execute the **ddl.sql** script using the following command:

    `psql -h localhost -U postgres -d host_agent -f sql/ddl.sql`

3. After executing the **ddl.sql** script, the result confirmed that the `host_info` and `host_usage` tables were created in the `host_agent` database.
4. Connect to PSQL instance and inspect the schema of both tables to ensure that the columns and constraints were created as intended with these commands:
    ```
   psql -h localhost -U postgres -W
   \c host_agent
   \d host_info
   \d host_usage
    ```
# 5. Deployment
The agent scripts is automated to run every 1 minute through the `cron` scheduler.

PostgreSQL database server is provisioned using Docker. It is hosted on a local machine and is configured to listen to incoming connections. We specified the database details, such as the hostname, port, database name, username, and password

The project code is pushed to GitHub repository, providing a central location for code storage, collaboration, and version tracking.
# 6. Improvement
Here are some potential areas for improvement:
1. Enhanced error handling to provide clearer error messages and next steps.
2. Create comprehensive documentation to assist users in setting up, configuring, and maintaining system.
3. Develop a feature that automatically detects and incorporates changes in hardware specifications.
