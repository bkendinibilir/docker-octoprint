FROM python:2.7.15-alpine3.8
EXPOSE 5000
LABEL maintainer "Benjamin Kendinibilir <bkendinibilir@mac.com>"

ENV CURA_VERSION=15.04.6
ARG octoprint_tag=1.3.10
ARG build_packages="git g++ make linux-headers libexecinfo-dev"

WORKDIR /opt/octoprint

RUN sed -i 's#dl-cdn.alpinelinux.org#ftp.halifax.rwth-aachen.de#' /etc/apk/repositories

RUN apk update && apk upgrade \
    && apk add --no-cache $build_packages \
		&& pip install virtualenv

RUN cd /tmp \
  && wget https://github.com/Ultimaker/CuraEngine/archive/${CURA_VERSION}.tar.gz \
  && tar -zxf ${CURA_VERSION}.tar.gz \
	&& cd CuraEngine-${CURA_VERSION} \
	&& mkdir build \
	&& make \
	&& mv -f ./build /opt/cura/ \
  && rm -Rf /tmp/*

RUN git clone --branch $octoprint_tag https://github.com/foosel/OctoPrint.git /opt/octoprint \
  && virtualenv venv \
	&& ./venv/bin/python setup.py install

RUN apk del $build_packages \
  && rm -rf /var/cache/apk/*

RUN adduser -D octoprint
RUN chown -R octoprint: /opt/octoprint
USER octoprint

# This fixes issues with the volume command setting wrong permissions
RUN mkdir /home/octoprint/.octoprint

VOLUME /home/octoprint/.octoprint

CMD ["/opt/octoprint/venv/bin/octoprint", "serve"]
