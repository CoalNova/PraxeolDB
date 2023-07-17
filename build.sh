
# build typescrypt files
bun build ./clientsrc/*.ts --outfile ./serversrc/buildassets/app.js

# Ancillary 
cp ./assets/favicon.ico ./serversrc/buildassets/favicon.ico

# build zig
zig build -Doptimize=ReleaseSafe

# move built exe to current
cp ./zig-out/bin/PraxeolDB ./PraxeolDB

# clean
rm ./serversrc/buildassets/*