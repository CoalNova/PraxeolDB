FROM ubuntu:20.04 
WORKDIR /
COPY ./clientsrc/* ./serversrc/build_assets/
RUN curl -OJ https://ziglang.org/download/0.12.0/zig-linux-x86_64-0.12.0.tar.xz &&\
    tar -xf zig-linux-x86_64-0.12.0.tar.xz &&\
    ./zig-linux-x86_64-0.12.0/zig build -Doptimize=ReleaseSafe