FROM amd64/ubuntu:22.04

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
# COPY --chmod=0755 wine_bdsx.deb /root/wine_bdsx.deb
RUN wget -NP /etc/apt/sources.list.d/ https://dl.winehq.org/wine-builds/ubuntu/dists/jammy/winehq-jammy.sources
RUN dpkg --add-architecture i386 
RUN apt-get update

# Stage 5
WORKDIR /root
RUN dos2unix entrypoint.sh
RUN dos2unix bdsx.sh
RUN apt-get install wine64 wine32
# RUN dpkg -i wine_bdsx.deb
# RUN rm -f wine_bdsx.deb

# Stage 6
EXPOSE 19132
RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/*

ENTRYPOINT /bin/sh -c "sh /root/entrypoint.sh"