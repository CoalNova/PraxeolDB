# precleaning
rm -r ./praxeoldata
rm ./praxeoldb

# load necessary packages
bun install

# build typescrypt files
bun build ./clientsrc/*.ts --outfile ./serversrc/buildassets/app.js

# Ancillary 
cp ./assets/favicon.ico ./serversrc/buildassets/favicon.ico
cp ./clientsrc/main.html ./serversrc/buildassets/index.html

# build zig
zig build -Doptimize=ReleaseSafe -freference-trace

# move built exe to current
cp ./zig-out/bin/praxeoldb ./praxeoldb

# clean
# rm ./serversrc/buildassets/*