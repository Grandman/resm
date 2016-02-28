FROM ubuntu:14.04

RUN useradd -m resm
ADD _build/prod/rel/resm /home/resm
WORKDIR /home/resm
RUN chown -R resm:resm .
USER resm

EXPOSE 8080

CMD ["bin/resm", "foreground"]
