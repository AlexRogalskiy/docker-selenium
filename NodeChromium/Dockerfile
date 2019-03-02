# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
# NOTE: DO *NOT* EDIT THIS FILE.  IT IS GENERATED.
# PLEASE UPDATE Dockerfile.txt INSTEAD OF THIS FILE
# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
FROM rbonghi/selenium-node-base:3.141.59-iron-x86_64
LABEL authors=raffaello_bonghi

USER root

#=========
# Chromium browser & Chromium webdriver
#=========

RUN apt-get update \
  && apt-get -y install chromium-browser \
  && rm -rf /var/lib/apt/lists/* /var/cache/apt/*
  
#=================================
# Chrome Launch Script Wrapper
#=================================
COPY wrap_chrome_binary /opt/bin/wrap_chrome_binary
RUN /opt/bin/wrap_chrome_binary

#==================
# Chrome webdriver
#==================
RUN apt-get update \
  && apt-get -y install chromium-chromedriver \
  && rm -rf /var/lib/apt/lists/* /var/cache/apt/*

RUN ln -fs /usr/lib/chromium-browser/chromedriver /usr/bin/chromedriver

USER seluser

#========================
# Selenium Configuration
#========================

COPY generate_config /opt/bin/generate_config

# Generating a default config during build time
RUN /opt/bin/generate_config > /opt/selenium/config.json

