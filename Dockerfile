ARG IMAGE=intersystemsdc/iris-community:2020.2.0.196.0-zpm
ARG IMAGE=intersystemsdc/iris-community:latest
FROM $IMAGE

USER root

WORKDIR /opt/irisapp
RUN chown ${ISC_PACKAGE_MGRUSER}:${ISC_PACKAGE_IRISGROUP} /opt/irisapp


USER irisowner

 #RUN mkdir -p /tmp/deps \

# && cd /tmp/deps \

# && wget -q https://pm.community.intersystems.com/packages/zpm/latest/installer -O zpm.xml


COPY  Installer.cls .
COPY  src src
COPY irissession.sh /

# running IRIS and open IRIS termninal in USER namespace
SHELL ["/irissession.sh"]
# below is objectscript executed in terminal
# each row is what you type in terminal and Enter
# zpm "install webterminal" 
RUN \
  do $SYSTEM.OBJ.Load("Installer.cls", "ck") \
  set sc = ##class(App.Installer).setup() \
  zn "IRISAPP" 
  

# bringing the standard shell back
SHELL ["/bin/bash", "-c"]
CMD [ "-l", "/usr/irissys/mgr/messages.log" ]
