.PHONY: compile tests clean run docker-run docker-start docker-stop docker-rm

DOCKER_CONTAINER_NAME=resm

compile:
	./rebar3 compile

tests:
	./rebar3 eunit

clean:
	./rebar3 clean --all
	rm _build -rf

run:
	./rebar3 shell

docker-run:
	./rebar3 as prod release
	docker build -t grandman/resm:1.0.0 .
	docker run -d -p 8080:8080 --name $(DOCKER_CONTAINER_NAME) grandman/resm:1.0.0

docker-start:
	docker start $(DOCKER_CONTAINER_NAME)

docker-stop:
	docker stop $(DOCKER_CONTAINER_NAME)

docker-rm:
	 docker rm $(DOCKER_CONTAINER_NAME)
