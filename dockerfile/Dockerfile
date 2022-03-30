FROM debian:stable-slim

RUN apt-get update -y

RUN apt-get install -y \
    curl \
    wget \
    git \
    ssh \
    dirmngr \
    gpg \
    gawk \
    make \
    build-essential \
    llvm
RUN curl -fsSL https://code-server.dev/install.sh | sh -s -- --version 4.2.0

ENV HOME=/user_home
ARG UID=1000
ARG GID=1000
RUN chown -R $UID:$GID /usr/lib/code-server
RUN mkdir $HOME && chown $UID:$GID $HOME || true
USER $UID:$GID
RUN mkdir $HOME/.local $HOME/.config $HOME/data || true

USER 0:0
RUN useradd -m -d $HOME -u $UID -s /bin/bash code
USER code
RUN echo 'export PS1="\033[1;92m[\033[1;94m\w\033[1;92m]~:\033[1;97m\$ "' >> $HOME/.bashrc

# Fonts
USER 0:0
RUN apt-get install -y --no-install-recommends fontconfig
USER code
RUN mkdir $HOME/.fonts || true
RUN cd $HOME/.fonts && \
    curl -sSL -o iosevka.tar.gz https://github.com/joxcat/Iosevka-custom-conf/releases/download/v1.2.0/iosevka.tar.gz && \
    tar -xf iosevka.tar.gz && \
    rm iosevka.tar.gz && \
    fc-cache -f

# asdf
RUN git clone https://github.com/asdf-vm/asdf.git $HOME/.asdf --branch v0.9.0
RUN echo ". $HOME/.asdf/asdf.sh" >> $HOME/.bashrc && \
    echo ". $HOME/.asdf/completions/asdf.bash" >> $HOME/.bashrc
ENV PATH=$PATH:$HOME/.asdf/bin
ENV PATH=$PATH:$HOME/.asdf/shims

# Python
USER 0:0
RUN apt-get install -y --no-install-recommends \
    libssl-dev \
    zlib1g-dev \
    libbz2-dev \
    libreadline-dev \
    libsqlite3-dev \
    libncursesw5-dev \
    xz-utils \
    tk-dev \
    libxml2-dev \
    libxmlsec1-dev \
    libffi-dev \
    liblzma-dev
USER code
RUN asdf plugin add python
RUN asdf install python latest
RUN asdf global python latest

# Node
RUN asdf plugin add nodejs https://github.com/asdf-vm/asdf-nodejs.git
RUN asdf install nodejs latest
RUN asdf global nodejs latest

# Rust
USER 0:0
RUN apt-get install -y --no-install-recommends \
    lld \
    binaryen
USER code
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
ENV PATH=$PATH:$HOME/.cargo/bin
# Rust-analyser
RUN mkdir $HOME/apps/ || true
RUN git clone https://github.com/rust-analyzer/rust-analyzer.git $HOME/apps/rust-analyzer --branch 2022-03-28
RUN cd $HOME/apps/rust-analyzer && cargo xtask install --server
# targets
RUN rustup target add wasm32-unknown-unknown

# Fix typescript language server
# https://github.com/coder/code-server/issues/5019
RUN cd /usr/lib/code-server/lib/vscode/extensions && \
    npm init -y && \
    npm i typescript

USER 0:0
RUN apt-get clean && rm -rf /var/lib/apt/lists/*
USER code
WORKDIR $HOME
ENTRYPOINT code-server
