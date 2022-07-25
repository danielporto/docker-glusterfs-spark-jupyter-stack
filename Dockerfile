FROM ubuntu:20.04


# install needed packages
RUN apt update && DEBIAN_FRONTEND=noninteractive apt install -y \
               #   ansible require python3
               python3-pip \ 
               sudo \
               openssl \
               # required for build asdf python
               libssl-dev \ 
               curl \
               wget \
               vim \
               zsh \
               openssh-client \
               rsync \
               jq \
               ansible \
               git \
               gnupg \
               unzip \
	       tree \
               # reqired for compile ethereum devtools
               software-properties-common \
               protobuf-compiler \
               # required to compile solc
            #    cmake \
            #    libboost-all-dev \
            #    libz3-dev \
               # required for python scypy
               && rm -rf /var/cache/apt/archives


# ARG UID=1097
# RUN addgroup -S dporto && adduser --uid $UID -g dporto dporto && echo 'dporto ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
ARG UID=501
RUN useradd -m --uid=$UID -U dporto && echo 'dporto ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

# install packages
RUN python3 -m pip install --upgrade pip && python3 -m pip install --upgrade pathlib2 \
                          enum34 \
                          plumbum \
                          eventlet \
                          # sensors
                          futures \
                          requests \
                          numpy \
                          pandas \
                          plumbum \
                          serial \
                          ioctl_opt \
                          pyserial \
                          flask \
                          # pysensors is not yet compatible with alpine version
                        #   pysensors \ 
                          eventlet \
                          # zookeeper
                          kazoo \
                          ;\
    # make sure nothing is on pip cache folder
    rm -rf ~/.cache/pip/

# make default alias for python
# RUN  ln -s /usr/local/lib/pyenv/versions/3.7.3/bin/python /usr/bin/python 
RUN sudo update-alternatives --install /usr/bin/python python /usr/bin/python3 10

# install solidity compiler, dependency to compile go tool - abigen
# does not work for arm64/mac-m1, thus we recompile solc
# RUN add-apt-repository ppa:ethereum/ethereum -y && \
#              apt update && \
#              apt install -y solc 

# compile install solidity compiler
#RUN  git clone --recursive https://github.com/ethereum/solidity.git /opt/solidity
#RUN cd /opt/solidity  && mkdir build && cd build && \
#    cmake .. && make solc && \
#    echo "ok"


USER dporto
# docker commands that run from now works as user $USER above inside the container
# speedup ansible with mitogen
ARG MITOGEN_VERSION=0.3.0rc1
RUN curl -o /tmp/mitogen-${MITOGEN_VERSION}.tar.gz https://codeload.github.com/dw/mitogen/tar.gz/v${MITOGEN_VERSION} \
    && tar xvf /tmp/mitogen-${MITOGEN_VERSION}.tar.gz -C /home/dporto \
    && mv /home/dporto/mitogen-${MITOGEN_VERSION} /home/dporto/mitogen \
    && chown -R dporto.dporto /home/dporto/mitogen 

# install ansible dependencies
RUN ansible-galaxy install git+https://github.com/danielporto/ansible-sdkman.git
RUN ansible-galaxy collection install crivetimihai.virtualization
RUN ansible-galaxy install markosamuli.asdf

# install zsh
RUN curl -fsSL https://raw.githubusercontent.com/zimfw/install/master/install.zsh | zsh

# install asdf
RUN git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.9.0

# install JAVA plugin for asdf - not working for mac m1
# RUN set -ex ;\
#     PATH="$HOME/.asdf/bin:$HOME/.asdf/shims:$PATH" ;\
#     ASDF_DIR=$HOME/.asdf ;\
#     export ASDF_DIR ;\
#     asdf plugin-add java https://github.com/halcyon/asdf-java.git ;\
# for amr64/mac m1
#    asdf install java zulu-11.41.75 ;\
#    asdf global java zulu-11.41.75 ;\
# for amd64
    #  asdf install java zulu-11.48.21 ;\
    #  asdf global java zulu-11.48.21 ;\
    # java 8 is required for compiling source
    #  asdf install java zulu-8.56.0.21 ;\
    #  asdf global java zulu-8.56.0.21 ;\
# adds ant     
    #  asdf plugin add ant  ;\
    #  asdf install ant 1.10.1  ;\
    #  asdf global ant 1.10.1

# install Gradle plugin for asdf - not working for mac m1
# RUN set -ex ;\
#     PATH="$HOME/.asdf/bin:$HOME/.asdf/shims:$PATH" ;\
#     ASDF_DIR=$HOME/.asdf ;\
#     export ASDF_DIR ;\
#     asdf plugin-add gradle https://github.com/rfrancis/asdf-gradle.git ;\
#     asdf install gradle 6.7.1 ;\
#     asdf global gradle 6.7.1

# install NODEJS plugin for asdf
# RUN PATH="$HOME/.asdf/bin:$HOME/.asdf/shims:$PATH" && \
#     asdf plugin-add nodejs https://github.com/asdf-vm/asdf-nodejs.git && \
#     bash -c '${ASDF_DATA_DIR:=$HOME/.asdf}/plugins/nodejs/bin/import-release-team-keyring' && \
#     asdf install nodejs 14.15.4 && \
#     asdf global nodejs 14.15.4

# install quorum-wizard to generate network configurations for quorum
# RUN set -ex ;\
#     PATH="$HOME/.asdf/bin:$HOME/.asdf/shims:$PATH" ;\
#     npm install -g quorum-wizard@1.3.3 ;\
#     echo "ok"

# install GOLANG 1.14.13 or 1.16 
# ENV GO_INSTALL_VERSION=1.14.13 
# RUN PATH="$HOME/.asdf/bin:$HOME/.asdf/shims:$PATH" && \
#     asdf plugin-add golang https://github.com/kennyp/asdf-golang.git && \
#     asdf install golang $GO_INSTALL_VERSION && \
#     asdf global golang $GO_INSTALL_VERSION && \
# # download go-ethereum dependencies
#     export GO111MODULE=on && \
#     go get -u github.com/ethereum/go-ethereum@v1.10.1 && \
#     cd $(go env GOPATH)/pkg/mod/github.com/ethereum/go-ethereum@v1.10.1 && chmod u+rw * -R && make && make devtools && \
#     echo "ok!"

# install istanbul-tools for generating keys and templates
# RUN git clone https://github.com/ConsenSys/istanbul-tools.git $HOME/istanbul-tools &&\
#     PATH="$HOME/.asdf/bin:$HOME/.asdf/shims:$PATH" && \
#     cd $HOME/istanbul-tools && \
#     make

# # install geth (quorum ethereum client) to initialize the nodes, tag v20.10.0 
# RUN git clone https://github.com/ConsenSys/quorum.git $HOME/goquorum &&\
#     PATH="$HOME/.asdf/bin:$HOME/.asdf/shims:$PATH" && \
#     cd $HOME/goquorum && \
#     git checkout af7525189f2cee801ef6673d438b8577c8c5aa34 && \ 
#     make 


# cache quorum-wizard dependencies
# RUN set -ex ;\
#     mkdir -p "$HOME/.quorum-wizard/bin/quorum/21.1.0" ;\
#     mkdir -p "$HOME/.quorum-wizard/bin/tessera/21.1.0" ;\
#     mkdir -p "$HOME/.quorum-wizard/bin/cakeshop/0.12.1" ;\
#     curl -L https://github.com/ConsenSys/cakeshop/releases/download/v0.12.1/cakeshop-0.12.1.war -o "$HOME/.quorum-wizard/bin/cakeshop/0.12.1/cakeshop.war" ;\
#     chmod 755 "$HOME/.quorum-wizard/bin/cakeshop/0.12.1/cakeshop.war" ;\
#     curl -L https://oss.sonatype.org/service/local/repositories/releases/content/net/consensys/quorum/tessera/tessera-app/21.1.0/tessera-app-21.1.0-app.jar -o "$HOME/.quorum-wizard/bin/tessera/21.1.0/tessera-app.jar" ;\
#     chmod 755 "$HOME/.quorum-wizard/bin/tessera/21.1.0/tessera-app.jar" ;\
#     curl -L -s https://artifacts.consensys.net/public/go-quorum/raw/versions/v21.1.0/geth_v21.1.0_linux_amd64.tar.gz | tar xvz -C "$HOME/.quorum-wizard/bin/quorum/21.1.0" ;\
#     echo "ok"


# configure zsh
RUN PATH="$HOME/.asdf/bin:$HOME/.asdf/shims:$PATH" ; \
    echo "alias play='/usr/bin/ansible-playbook -i inventory.cfg'" > ~/.profile ; \
    echo "alias grep='egrep'" >> ~/.profile ; \
    echo "alias ssh='ssh -F ~/.ssh/config_gsd_kaioken_dporto'" >> ~/.profile ; \
    echo "export PATH=/opt/solidity/build/solc:$HOME/.asdf/bin:$HOME/.asdf/shims:$(go env GOPATH)/bin:$HOME/istanbul-tools/build/bin:$HOME/goquorum/build/bin:$PATH" >> ~/.profile ; \
    echo "export GOPATH=$(go env GOPATH)" >> ~/.profile ;\
    echo "export GOROOT=$(go env GOROOT)" >> ~/.profile ;\
    echo "export ASDF_DIR=$HOME/.asdf" >> ~/.profile ;\
    echo ". ~/.profile" >> ~/.zshrc ; \
    echo "export PATH=/opt/solidity/build/solc:$HOME/.asdf/bin:$HOME/.asdf/shims:$(go env GOPATH)/bin:$HOME/istanbul-tools/build/bin:$HOME/goquorum/build/bin:$PATH" >> ~/.zshrc ; \
    echo "Done"

WORKDIR /code

CMD /bin/zsh
