FROM ubuntu:14.04
MAINTAINER Brett Holton	<brett@vreal.io> 

ENV HOME /opt/mongooseim
ENV MONGOOSEIM_VERSION 1.6.2 
ENV MONGOOSEIM_REL_DIR /opt/mongooseim/rel/mongooseim
ENV PATH /opt/mongooseim/rel/mongooseim/bin/:$PATH
ARG DEBIAN_FRONTEND=noninteractive

# Avoid ERROR: invoke-rc.d: policy-rc.d denied execution of start.
RUN echo "#!/bin/sh\nexit 0" > /usr/sbin/policy-rc.d

# install required packages
RUN apt-get update && apt-get install -y   gcc \
                                           g++ \
                                           libc6-dev \
                                           libncurses5-dev \
                                           libssl-dev \
                                           libexpat1-dev \
                                           libpam0g-dev \
					   make \
					   wget

# add esl packages
RUN wget https://packages.erlang-solutions.com/erlang-solutions_1.0_all.deb \
    && dpkg -i erlang-solutions_1.0_all.deb \
    && wget http://packages.erlang-solutions.com/debian/erlang_solutions.asc\
    && apt-key add erlang_solutions.asc \
    && apt-get update \
    && apt-get install -y esl-erlang=1:17.5


COPY . /opt/mongooseim/

ADD ./start.sh start.sh

WORKDIR /opt/mongooseim/ 

RUN make \
    && make rel \
    && rm -rf /opt/mongooseim/rel/mongooseim/log \
    && ln -s /data/log /opt/mongooseim/rel/mongooseim/log


# expose xmpp, rest, s2s, epmd, distributed erlang
EXPOSE 5222 5280 5269 4369 9100

# Define mount points.
VOLUME ["/data/mnesia", "/data/log"]

ENTRYPOINT ["./start.sh"]

