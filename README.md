# Docker for PHP projects, with Apache and MySQL

## Getting Started

### Dockerfile
Configuration for Apache Server and PHP

### DockerfileDB
Configuration for Mysql Server

### docker-compose.yml
Configuration to build the containers

## Commands

`docker-compose build `

Compile and configure the containers based in our dockerfiles and docker-compose.yml.

`docker-compose up `

Create and initialize the containers.

After using the docker-compose up, we can now access our application and also check our dockers running.

If you type on the terminal this command, it will lock your terminal. To stop press `ctrl+c`.

`docker ps`

Shows containers that are running.

`docker images`

Shows the images available on your machine

`docker-compose down`

Ends and removes our containers, networks, images and volumes.

`docker-compose –-help`

Shows how to use docker-compose, it is good.

## Steps to put up our containers.

```
docker-compose build

docker-compose up
```

## Author

* Santiago Benalcazar

## License

This project is licensed under the MIT License

## References

[Docker for PHP projects, with Apache and MySQL](https://medium.com/@eduardobcolombo/docker-for-php-projects-with-apache-and-mysql-1e1a9953463a)