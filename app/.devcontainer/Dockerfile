FROM mcr.microsoft.com/devcontainers/base:ubuntu-22.04

ENV DEBIAN_FRONTEND=noninteractive

# Instalação de dependências
RUN apt-get update && apt-get install -y \
    curl git unzip xz-utils zip libglu1-mesa \
    openjdk-17-jdk-headless \
    && rm -rf /var/lib/apt/lists/*

ENV FLUTTER_HOME=/opt/flutter
ENV PATH=$PATH:$FLUTTER_HOME/bin

# Clona o Flutter
RUN git clone https://github.com/flutter/flutter.git -b stable $FLUTTER_HOME

# --- O PULO DO GATO ESTÁ AQUI ---
# Dá permissão total para o usuário vscode na pasta do Flutter
RUN chown -R vscode:vscode $FLUTTER_HOME

# Executa o precache como o usuário vscode para baixar as ferramentas da engine
USER vscode
RUN flutter config --no-analytics && \
    flutter precache --web