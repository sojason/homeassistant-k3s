# Reasoning behind the choice of base image:
# https://pythonspeed.com/articles/base-image-python-docker-images/
FROM docker.io/python:3.9-slim-buster
LABEL maintainer="Jakob S jakob@roggelid.se"

RUN groupadd -g 1013 homeassistant && \
    useradd -u 1013 -g homeassistant -m -s /bin/bash homeassistant

WORKDIR /opt/homeassistant
RUN chown -R homeassistant:homeassistant /opt/homeassistant

# Installation of Home Assistant Core
# The instructions at https://www.home-assistant.io/installation/linux#install-home-assistant-core
# are more or less disregarded, since we will run in a container, with _one_ process per container, 
# as per OCI. (no, I do not acknowledge the 'one thing'-abomination)

#RUN pip install homeassistant
# So, pip install homeassistant will trigger some builds, requiring gcc. But gcc is removed from slim, so
# this oneliner installs gcc, then pip install, then remove gcc before comitting the layer.

# Install gcc et al as root
RUN apt-get update \
    && apt-get install -y --no-install-recommends gcc python3-dev git\
    && rm -rf /var/lib/apt/lists/* 

USER homeassistant

# Install HomeAssistant as homeassitant using pip's git-integration
#RUN ["/bin/bash", "-c", "python3 -m venv . \
#    && source bin/activate \
#    && python3 -m pip install wheel \
#    && python3 -m pip install git+https://github.com/home-assistant/core.git@2021.9.3 "]

RUN ["/bin/bash", "-c", "python3 -m venv . \
    && source bin/activate \
    && python3 -m pip install wheel \
    && python3 -m pip install git+https://github.com/sojason/home-assistant-core.git@2021.9.3.mod \
    && /opt/homeassistant/bin/hass --only-pip \
    && rm -r /home/homeassistant/.homeassistant "]

#COPY core-2021.9.3_modified ./src
#RUN ["/bin/bash", "-c", "python3 -m venv . \
#    && source bin/activate \
#    && ls -l \
#    && python3 -m pip install wheel \
#    && python3 -m pip install ./src \
#    && /opt/homeassistant/bin/hass --only-pip \
#    && rm -r /home/homeassistant/.homeassistant"]

# Remove gcc et alt to save some precious image space
USER root 
RUN apt-get purge -y --auto-remove gcc python3-dev git

USER homeassistant
COPY entrypoint.sh .
ENTRYPOINT ["./entrypoint.sh"]