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
    llvm \
    cmake
RUN curl -fsSL https://code-server.dev/install.sh | sh -s -- --version 4.5.0

ENV HOME=/user_home
ARG UID=1000
ARG GID=1000
RUN chown -R $UID:$GID --verbose /usr/lib/code-server
RUN mkdir $HOME && chown $UID:$GID $HOME || true
USER $UID:$GID
RUN mkdir $HOME/.local $HOME/.config $HOME/data || true

USER 0:0
RUN useradd -m -d $HOME -u $UID -s /bin/bash code

# Add code to docker group
ARG DOCKER_GID=998
RUN groupadd -g $DOCKER_GID docker
RUN usermod -aG docker code

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

ARG GIT_NAME
RUN if test ! -z "$GIT_NAME"; then git config --global user.name "$GIT_NAME"; echo "Configured github name"; fi
ARG GIT_EMAIL
RUN if test ! -z "$GIT_EMAIL"; then git config --global user.email "$GIT_EMAIL"; echo "Configured github email"; fi

# asdf
RUN git clone https://github.com/asdf-vm/asdf.git $HOME/.asdf --branch v0.10.2
RUN echo ". $HOME/.asdf/asdf.sh" >> $HOME/.bashrc && \
    echo ". $HOME/.asdf/completions/asdf.bash" >> $HOME/.bashrc
ENV PATH=$HOME/.asdf/bin:$PATH
ENV PATH=$HOME/.asdf/shims:$PATH

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
RUN asdf install python 3.9.7 && \
    asdf global python 3.9.7 && \
    asdf reshim python

# Node
RUN asdf plugin add nodejs https://github.com/asdf-vm/asdf-nodejs.git
RUN asdf install nodejs latest && \
    asdf global nodejs latest && \
    asdf reshim nodejs

# Rust
USER 0:0
RUN apt-get install -y --no-install-recommends \
    lld \
    binaryen \
    sqlite3 \
    clang
# Build and install mold linker
# building mold require `cmake`
RUN git clone https://github.com/rui314/mold.git --depth 1 --branch v1.3.1 && \
    cd mold && \
    make -j$(nproc) CXX=g++ && \
    make install && \
    cd .. && \
    rm -rf mold
USER code
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
ENV PATH=$PATH:$HOME/.cargo/bin
# Rust-analyser
RUN git clone https://github.com/rust-lang/rust-analyzer.git $HOME/rust-analyzer --depth 1 --branch 2022-05-02 && \
    cd $HOME/rust-analyzer && \
    cargo xtask install --server && \
    cd .. \
    rm -rf rust-analyzer
# Targets
RUN rustup target add wasm32-unknown-unknown
# Kani tests
RUN cargo install --locked kani-verifier && \
    cargo-kani setup
# Add Cranelift compiler
RUN mkdir $HOME/.apps
RUN git clone https://github.com/bjorn3/rustc_codegen_cranelift.git $HOME/rustc_codegen_cranelift --depth 1 && \
    cd $HOME/rustc_codegen_cranelift && \
    ./y.rs prepare && \
    ./y.rs build --target-dir "$HOME/.apps"
RUN ln -s $HOME/.apps/cargo-clif $HOME/.cargo/bin/cargo-clif && \
    rm -rf $HOME/rustc_codegen_cranelift

# Add nim-lang
USER 0:0
USER code
ENV NIM_VERSION=1.6.6
RUN asdf plugin add nim
RUN asdf install nim $NIM_VERSION && \
    asdf global nim $NIM_VERSION

# Add zig-lang
WORKDIR /tmp
ENV ZIG_VERSION=0.9.1
RUN asdf plugin add zig
RUN asdf install zig $ZIG_VERSION && \
    asdf global zig $ZIG_VERSION
WORKDIR /

USER 0:0

RUN apt-get clean && rm -rf /var/lib/apt/lists/*
USER code
WORKDIR $HOME

ENTRYPOINT code-server
