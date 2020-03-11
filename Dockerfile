FROM alpine:latest as stage

WORKDIR /opt/stage

RUN \
  apk update \
  && apk add wget \
  && wget https://raw.githubusercontent.com/rfns/dotenv/fix/white-lines/cls/DotEnv/Parser.cls --quiet --output-document /opt/stage/dotenv-parser.cls \
  && wget https://raw.githubusercontent.com/rfns/dotenv/fix/white-lines/cls/DotEnv/Command.cls --quiet --output-document /opt/stage/dotenv-command.cls

COPY scripts/setup-iris.sh scripts/entrypoint.sh /opt/stage/scripts/
COPY ci ./

FROM store/intersystems/iris-community:2019.4.0.383.0

WORKDIR /opt/ci
COPY --from=stage /opt/stage /opt/ci

USER root

RUN mkdir -p /var/log/ci \
  && chmod -R +x /opt/ci/scripts \
  && chown -R irisowner:irisowner /var/log/ci /opt/ci

USER irisowner
SHELL ["/opt/ci/scripts/setup-iris.sh"]

RUN \
  do $System.OBJ.Load("/opt/ci/TestRunner/Configuration.cls", "ck") \
  do $System.OBJ.Load("/opt/ci/TestRunner/Orchestrator.cls", "ck") \
  do $System.OBJ.Load("/opt/ci/TestRunner/Logger.cls", "ck") \
  do $System.OBJ.Load("/opt/ci/dotenv-parser.cls", "ck") \
  do $System.OBJ.Load("/opt/ci/dotenv-command.cls", "ck")

CMD ["-l", "/usr/irissys/mgr/messages.log"]
ENTRYPOINT ["/opt/ci/scripts/entrypoint.sh"]
