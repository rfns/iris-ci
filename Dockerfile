FROM alpine:latest as stage

WORKDIR /opt/stage

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
  do $System.OBJ.Load("/opt/ci/TestRunner/Logger.cls", "ck")

CMD ["-l", "/usr/irissys/mgr/messages.log"]
ENTRYPOINT ["/opt/ci/scripts/entrypoint.sh"]
