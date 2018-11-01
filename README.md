# README

Scraper examples using Selenium, Mechanize and Typhoeus gems.

## Docker
You can use the included docker-compose file for both development and production.

Every change perform on the current code at the host will be reflected on the
app container created by this docker-compose.

### Initial Configuration

Create an **".env"** file using **".env.dist"** file as template to configure
the docker project to fit your needs. Look at the template file for more details
about each configuration parameter.

Now the initial configuration should be ready, so you can start the docker
compose project by using the included automated **"/deploy.sh"** script or by
doing manually using docker-compose command.

### Using the automated deploy script (recommended)

This project provides a basic automated deployment script **"deploy.sh"** that
can be use to easily manage this docker compose project. To do so, just execute
it on the terminal (assuming you are located on the project's root directory):

* To build the project's images:

    ./deploy.sh build-image

* To rebuild the project's containers:

    ./deploy.sh rebuild

* To start/restart the project's containers:

    ./deploy.sh start

* To destory the project's containers:

    ./deploy.sh destroy

That's it! it will do the rest for you, including attaching the started
containers logs to the current terminal so you can monitor all it's
containers activities. To stop the containers, just hit **"ctrl + c"** and it will
gracefully stop the containers for you.

For more information and commands, execute the deployment script with *"--help"*
option:

    ./deploy.sh --help

### Deploying manullay with docker-compose

Remember to check the "Initial Configuration" section before you execute the
docker project and to execute a **"down"** command before switching between
**dev** and **prod** environments within the same project directory.

**"PWD"** parameter is required to execute docker-compose commands since it is
used to specify host relative paths. The automated deployment script already does
this internally, but you will have to explicitly do it since you are deploying the
project manually. Another option is to add **"PWD"** param inside **"/.env"**
file with an absolute path of the project so you don't need to add it everytime
you want to execute a docker compose command.

#### Build the containers

To build the contianers without startint it, use the following command:

    env PWD="$PWD" docker-compose up --no-start

Once the containers are initialized, we can use "start" command.

#### Start the existing containers
To build the contianers without starting it, use the following command:

    env PWD="$PWD" docker-compose start && env PWD="$PWD" docker-compose logs -f

#### Stop the existing containers
To build the contianers without starting it, use the following command:

    env PWD="$PWD" docker-compose stop

#### Destroy the existing containers
To build the contianers without starting it, use the following command:

    env PWD="$PWD" docker-compose down
