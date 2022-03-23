FROM debian:stable-slim

# Update repos
RUN apt-get update -y

RUN apt-get install -y \
    curl \
    git \
    ssh
RUN curl -fsSL https://code-server.dev/install.sh | sh -s -- --version 4.0.2

ENV HOME=/user_home
ARG UID=1000
ARG GID=1000
RUN chown -R $UID:$GID /usr/lib/code-server/vendor
RUN mkdir $HOME && chown $UID:$GID $HOME || true
USER $UID:$GID
RUN mkdir $HOME/.local $HOME/.config $HOME/data || true

USER 0:0
RUN useradd -m -d $HOME -u $UID -s /bin/bash code
USER code
RUN echo 'export PS1="\033[1;92m[\033[1;94m\w\033[1;92m]~:\033[1;97m\$ "' >> $HOME/.bashrc

# Fonts
USER 0:0
RUN apt-get install -y fontconfig
USER code
RUN mkdir $HOME/.fonts || true
RUN cd $HOME/.fonts && \
    curl -sSL -o iosevka.tar.gz https://github.com/joxcat/Iosevka-custom-conf/releases/download/v1.2.0/iosevka.tar.gz && \
    tar -xf iosevka.tar.gz && \
    rm iosevka.tar.gz && \
    fc-cache -f

# Rust
USER 0:0
RUN apt-get install -y \
    build-essential \
    lld
USER code
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
ENV PATH=$PATH:$HOME/.cargo/bin
# Rust-analyser
RUN mkdir $HOME/apps/ || true
RUN git clone https://github.com/rust-analyzer/rust-analyzer.git $HOME/apps/rust-analyzer
RUN cd $HOME/apps/rust-analyzer && cargo xtask install --server
# targets
RUN rustup target add wasm32-unknown-unknown

# TODO add to deps
USER 0:0
RUN apt-get install -y dirmngr gpg gawk
USER code

# asdf
RUN git clone https://github.com/asdf-vm/asdf.git $HOME/.asdf --branch v0.9.0
RUN echo ". $HOME/.asdf/asdf.sh" >> $HOME/.bashrc && \
    echo ". $HOME/.asdf/completions/asdf.bash" >> $HOME/.bashrc
ENV PATH=$PATH:$HOME/.asdf/bin
ENV PATH=$PATH:$HOME/.asdf/shims

# Node
RUN asdf plugin add nodejs https://github.com/asdf-vm/asdf-nodejs.git
RUN asdf install nodejs latest

WORKDIR $HOME
ENTRYPOINT code-server
