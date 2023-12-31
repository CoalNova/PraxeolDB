# build typescrypt files
bun build ./src/app/*.ts --outfile ./src/buildassets/app.js

# Ancillary 
copy ./assets/favicon.ico ./src/buildassets/favicon.ico

# build zig
zig build -Doptimize=ReleaseSafe

# clean
del ./src/buildassets/*