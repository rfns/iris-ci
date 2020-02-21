FROM alpine:latest as stage

WORKDIR /opt/stage

COPY scripts/setup-iris.sh scripts/entrypoint.sh TestRunner.xml /opt/stage/helpers/

RUN apk update \
  && apk add wget \
  && wget https://raw.githubusercontent.com/rfns/port/master/port-prod.xml -P /opt/stage/helpers \
  && wget https://raw.githubusercontent.com/rfns/forgery/master/forgery-prod.xml -P /opt/stage/helpers \
  && wget https://raw.githubusercontent.com/rfns/frontier/master/frontier-prod.xml -P /opt/stage/helpers \
  && chmod +x /opt/stage/helpers/setup-iris.sh \
  && chmod +x /opt/stage/helpers/entrypoint.sh

FROM store/intersystems/iris-community:2019.4.0.383.0

WORKDIR /opt/runner
COPY --from=stage /opt/stage/helpers /opt/runner/helpers

VOLUME /opt/runner/app

USER root
RUN chown -R irisowner:irisowner /opt/runner/helpers

USER irisowner

SHELL ["/opt/runner/helpers/setup-iris.sh"]

RUN \
  zn "USER" \
  do $System.OBJ.Load("/opt/runner/helpers/port-prod.xml", "cku") \
  do $System.OBJ.Load("/opt/runner/helpers/forgery-prod.xml", "cku") \
  do $System.OBJ.Load("/opt/runner/helpers/frontier-prod.xml", "cku") \
  do $System.OBJ.Load("/opt/runner/helpers/TestRunner.xml", "cku")

SHELL ["/bin/bash", "-c"]

CMD ["-l", "/usr/irissys/mgr/messages.log"]
ENTRYPOINT ["/opt/runner/helpers/entrypoint.sh"]
