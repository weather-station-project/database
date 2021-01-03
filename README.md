# Weather Station Database
Repository with the code to create the Weather Station Database.


## Composition
* **weather-station-database.yml** - Orchestator of the instance. It runs a PostgreSQL node in Alpine. Here, you must configure credentials and IPs to set the security properly during the initialization, otherwise you will not be able to login to the instance.
* **weather-station-database.sh** - Bash script to initialize the instance, it creates the users, databases, indexes and configures the security with the values provided from the .yml file.


## Usage
The project just run the container to initialize the database, credentials and policies
```bash
docker-compose -f weather-station-database.yml up
```
After this command, you will see on the screen the initialization traces, when the DB is ready for connections, you can kill the container. The created directory is the one for persistent data and configuration.


## Database scheme
![Scheme](https://github.com/davidleonm/weather-station-database/raw/master/db-scheme.jpeg)


## Changelog
* **1.1.0** - Changed direction column from INT to VARCHAR.
* **First release** - First version with the code to configure the PostgreSQL database.


## License
Use this code as you wish! Totally free to be copied/pasted.
