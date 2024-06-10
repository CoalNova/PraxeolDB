cp ./clientsrc/* ./serversrc/build_assets/ &&\
zig build &&\
cp ./zig-out/bin/praxeoldb ./praxeoldb