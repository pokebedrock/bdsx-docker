FROM ubuntu:22.04

RUN apt update -y
RUN apt upgrade -y
RUN apt install -y \
                git \
                dos2unix \
                curl \
                libfreetype6 \
                libfreetype-dev \
                libunwind8 \
                wget
RUN curl -sL https://deb.nodesource.com/setup_20.x -o /tmp/nodesource_setup.sh
RUN bash /tmp/nodesource_setup.sh
RUN apt-get install nodejs -y

# Stage 2
WORKDIR /root/bdsx
RUN git init
RUN git config pull.ff only
RUN git remote add upstream https://github.com/pokebedrock/bdsx

# Stage 3
ENV node_env=production
ENV WINEARCH=win64
ENV WINEDLLOVERRIDES="VCRUNTIME140_1=n,=b" 
ENV WINEDEBUG=fixme-all 

# Stage 4
COPY --chmod=0755 ./entrypoint.sh /root/entrypoint.sh
COPY --chmod=0755 ./bdsx.sh /root/bdsx.sh

# Stage 5
RUN mkdir -pm755 /etc/apt/keyrings && \
wget -NP /etc/apt/keyrings https://dl.winehq.org/wine-builds/winehq.key && \
wget -O /etc/apt/sources.list.d/winehq-jammy.sources https://dl.winehq.org/wine-builds/ubuntu/dists/jammy/winehq-jammy.sources && \
dpkg --add-architecture i386
RUN sudo apt update -y 
RUN sudo apt install --install-recommends -y winehq-stable

# Stage 6
WORKDIR /root
RUN dos2unix entrypoint.sh
RUN dos2unix bdsx.sh
# RUN dpkg -i wine_bdsx.deb
# RUN rm -f wine_bdsx.deb

# Stage 7
EXPOSE 19132
RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/*

ENTRYPOINT /bin/sh -c "sh /root/entrypoint.sh"