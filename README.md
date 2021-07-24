# docker_redmine_passenger
Docker-compose for quick setup redmine service with https access and time_logger and kanban plugins (ssl certificate required) 

Uses Postgres 10 container to store data (tested only with this container)

<<<<<<<<<<<<<<-------Instalation------->>>>>>>>>>>>>>
Download to /
Drop your ssl files in to a ssl directory (read manual)
change your user to super user
make needed changes in docker-compose directory
go to /redmine path
do "docker-compose build"
do "docker-compose up -d"
congrats - you have a working redmine server

<<<<<<<<<<<<<<-------Plugins Included------->>>>>>>>>>>>>>
Included 2 modificated for this version of redmine, plugins:
1. time_logger - for timelogging in tickets
2. kanban - dynamic dashboard module
Author of modifications Alisa Rudenko


<<<<<<<<<<<<<<-------SSL------->>>>>>>>>>>>>>
Drop your ssl files in to a directory 
/redmine/storage/docker_redmine-data/ssl/
after - add .crt and .key files in docker-composer.yml in command to start passenger


<<<<<<<<<<<<<<-------Ports------->>>>>>>>>>>>>>
As default redmine started on ports:
external port / internal container port
            80:3000
           443:3443
Optionality can be changed


<<<<<<<<<<<<<<-------Installing plugins and themes------->>>>>>>>>>>>>>
Best practice:
1. do - docker exec -it conainer_name_or_id bash
2. go to the plugin path
3. do gitclone of plugin needed in plugin path
4. do "rake redmine:plugins:migrate RAILS_ENV=production"
5. restart container 
6. after, you can delete container - plugins have been saved in plugin_volume
7. if after re-creation container - plugins doe's work - do steps 1,4,5
