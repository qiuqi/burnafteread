PROJECT:=burnafteread
PREFIX:=../
DEST:=$(PREFIX)$(PROJECT)

REBAR=./rebar3

all:
	        @$(REBAR) release 

deps:
	        @$(REBAR) deps
		        @$(REBAR) upgrade

release:
	        @$(REBAR) release

run:
	        ./_build/default/rel/burnafteread/bin/burnafteread start

debug: release
	        ./_build/default/rel/burnafteread/bin/burnafteread foreground 

stop:
	        killall -9 beam.smp

edoc:
	        @$(REBAR) doc

test:
	        @rm -rf .eunit
		        @mkdir -p .eunit
			        @$(REBAR) skip_deps=true eunit

clean:
	        @$(REBAR) clean

