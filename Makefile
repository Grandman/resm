compile:
	./rebar3 compile

tests:
	./rebar3 eunit

clean:
	./rebar3 clean --all
	rm _build -rf

run:
	./rebar3 shell
