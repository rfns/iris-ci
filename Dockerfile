FROM alpine:latest as stage

WORKDIR /opt/stage

RUN \
  apk update \
  && apk add wget \
  && wget https://raw.githubusercontent.com/rfns/dotenv/master/cls/DotEnv/Parser.cls --quiet --output-document /opt/stage/dotenv-parser.cls \
  && wget https://raw.githubusercontent.com/rfns/dotenv/master/cls/DotEnv/Command.cls --quiet --output-document /opt/stage/dotenv-command.cls

COPY scripts/setup-iris.sh scripts/entrypoint.sh /opt/stage/scripts/
COPY ci ./

FROM docker.io/intersystemsdc/iris-community:latest

WORKDIR /opt/ci
COPY --from=stage /opt/stage /opt/ci

USER root

RUN mkdir -p /var/log/ci \
  && chmod -R +x /opt/ci/scripts \
  && chown -R irisowner:irisowner /var/log/ci /opt/ci

USER irisowner
SHELL ["/opt/ci/scripts/setup-iris.sh"]

RUN \
  set f = ##class(%Stream.FileCharacter).%New() \
  do f.LinkToFile("/opt/ci/ci.inc") \
  set r = ##class(%RoutineMgr).%New("ci.inc") \
  do r.Code.CopyFrom(f) \
  do r.%Save() \
  set (f, r) = "" \
  do $System.OBJ.Load("/opt/ci/Configuration.cls", "c") \
  do $System.OBJ.Load("/opt/ci/Orchestrator.cls", "c") \
  do $System.OBJ.Load("/opt/ci/dotenv-parser.cls", "c") \
  do $System.OBJ.Load("/opt/ci/dotenv-command.cls", "c")

CMD ["-l", "/usr/irissys/mgr/messages.log"]
ENTRYPOINT ["/opt/ci/scripts/entrypoint.sh"]
