FROM ubuntu:20.04

WORKDIR /workspace

# Install python3.8 & pip3.8
RUN apt update && apt install -y curl python3.8 python3-distutils
RUN curl https://bootstrap.pypa.io/get-pip.py -o /tmp/get-pip.py
RUN python3.8 /tmp/get-pip.py
RUN ln -s /usr/bin/python3.8 /usr/local/bin/python
RUN ln -s /usr/bin/python3.8 /usr/local/bin/python3

# Install Redis
RUN apt update && DEBIAN_FRONTEND=noninteractive apt install -y software-properties-common
RUN add-apt-repository ppa:redislabs/redis
RUN apt update && apt install -y redis-server

# Copy source code to workspace
COPY core .

# Install core commands
RUN SETUPTOOLS_USE_DISTUTILS=stdlib pip install -e server

# Clean up
RUN rm -rf /tmp/*
RUN rm -rf /var/lib/apt/lists/*

ENTRYPOINT ["./entrypoint.sh"]
CMD ["python", "server/test.py"]
