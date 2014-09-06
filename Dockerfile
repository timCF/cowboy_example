FROM ubuntu

RUN apt-get update
RUN apt-get -y install wget
RUN wget http://packages.erlang-solutions.com/erlang-solutions_1.0_all.deb; dpkg -i erlang-solutions_1.0_all.deb
RUN apt-get update; apt-get -y install esl-erlang
RUN apt-get -y install git make
RUN apt-get -y install g++
RUN cd /opt; git clone https://github.com/elixir-lang/elixir.git;cd elixir; git checkout v1.0.0-rc1; make clean install; cd /opt; rm -rf elixir
ADD . /opt/cowboy_example
RUN apt-get -y install npm
RUN npm install -g iced-coffee-script
RUN cd /opt/cowboy_example;  mix local.hex --force; mix local.rebar --force; mix compile.protocols 

EXPOSE 8184

CMD cd /opt/cowboy_example; ./dockstart.sh 
