FROM ubuntu:20.04
RUN apt-get update && apt-get -y upgrade 
RUN apt-get install -y lsb-release net-tools wget git vim curl tcpdump iputils-ping tree jq telnet sudo nano gnupg2
RUN curl -s https://deb.frrouting.org/frr/keys.asc | sudo apt-key add -
ENV FRRVER="frr-stable"
RUN echo deb https://deb.frrouting.org/frr $(lsb_release -s -c) $FRRVER | sudo tee -a /etc/apt/sources.list.d/frr.list
RUN apt update && apt install -y frr frr-pythontools



