# weather-station-database
Repository with the code to create the Weather Station Database.


## Composition
* **weather-station-database.yml** - Orchestator of the instance. It runs a PostgreSQL node in Alpine. Here, you must configure credentials and IPs to set the security properly during the initialization, otherwise you will not be able to login to the instance.
* **weather-station-database.sh** - Bash script to initialize the instance, it creates the users, databases, indexes and configures the security with the values provided from the .yml file.


## Database scheme
![Scheme](https://github.com/davidleonm/weather-station-database/raw/feature/initial_release/db-scheme.jpeg)


## Changelog
* **First release** - First version with the code to configure the PostgreSQL database.


## License
Use this code as you wish! Totally free to be copied/pasted.