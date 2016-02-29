resm
=====

Resm is a simple resource manager that provides resources on demand.

Requirements
-----
Erlang/OTP 18

Configuration
-----
For configuring port or resources number just edit file `resm.config`.
Default values is:
* port = 8080
* resources number = 3

Compile
-----

    $ make compile

Run tests
-----
    $ make tests
    
Clean folder
-----
    $ make clean
    
Run
-----
    $ make run
    
Run in docker container
-----
    $ make docker-run

Stop docker container
-----
    $ make docker-stop

Remove docker container
-----
    $ make docker-rm
