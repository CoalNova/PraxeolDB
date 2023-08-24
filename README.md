# PraxeolDB
```
prax·​e·​ol·​o·​gy ˌ[prak-sē-ˈä-lə-jē] 
The study of human action and conduct, based on the notion that humans engage in purposeful behavior.
```
![PraxeolDB Logo](https://github.com/CoalNova/PraxeolDB/blob/main/assets/logosmoll.png?raw=true)
--- 

##### !WORK IN PROGRESS!

PraxeolDB is an in-development twin program solution for asset management and ordering system designed for small impact and wide adoptability. It is designed for small or independent operations as a method of simple inventory requisition by multiple users. PraxeolDB is designed to use as few system resources as it can to achieve its goal.

Progress and project guideline can be found on the [Trello Board here](https://trello.com/b/16MHQEvr/praxeoldb). 

Version numbering is: `MajorRelease.PhaseCompletion.ProgressIncrementor_optionallettersuffix` 

|suffix|description|
|-|-|
| a.. | text or other adjustment with no change to code |
| n | program does not run in the build |
| x | code does not compile |

Suffixes are used sparingly. Phase number denotes which phase has been completed.

&nbsp;

### The Server:
---
The PraxeolDB server program is built in the [Zig](https://ziglang.org/) language, for its focus on performance, ease of use, and safety. It relies on the [Zap](https://github.com/zigzap/zap) library for web connection. It utilizes SQLite3 via [zig-sqlite](https://github.com/vrischmann/zig-sqlite) for database engine. 

Direct interfacing for the server is still being researched. Admin controls are exposed through the client using admin credentials. Ideally CLI will be used for adjusting configuration and items in a headless environment. Current plan is using `[OPTYPE -> OPERATION -> INSTRUCTION]`, examples as follows:

##### !WIP!

|OPTYPE|OPERATION|INSTRUCTION|DATA|
|-|-|-|-|
|sql|add|"user"|"smccarthy" "default" "Samuel" "McCarthy" "01234|
|sql|modify|"location"|"locationcode = 01384" "address" "322 Hummingbird Ln Raleigh, NC 27601"|
|sql|delete|"inventory"|"itemcode = 912384"|
|sql|get|"user"|"username = bhorton"|
|server|set|port|"53098"|
|server|set|workers|2|
|server|restart|||

Design philosophy for installation is that all required elements are internal, and any necessary files are generated automatically. From the executable alone everything should work.

The hardware spec targeted for the server is any run-of-the-mill office workstation as baseline, specific details TBD (intel atom/amd phenom II/3.78 hamsters).

&nbsp;

### The Client:
---
![Client Mockup](https://github.com/CoalNova/PraxeolDB/blob/main/assets/clientmockup.png?raw=true)
The PraxeolDB client uses [TypeScript](https://www.typescriptlang.org/) language for distribution over web connections. It will also allow for standalone execution, though configuration through application interface will be necessary to know which "home" to phone.

A simple, clean, and most of all lite interface. It will facilitate the requisition of inventory items and supplies. It will also allow for administrative and semi-administrative editing of user, site, and inventory information. The layout should focus on a clear, readable, and organically laid out interface. It uses [Bun](https://bun.sh/) as the TypeScript compiler.

The hardware spec for the client is an android we browser for a low to mid range android tablet, details TBD.


#### Building:
---

Current requirements are [Zig](https://ziglang.org/) and [Bun](https://bun.sh/), and utilizes the sqlite3 libc system library.

For building on Windows, either use the provided `build.bat`, or `build.sh` through a configured [MSYS2](https://www.msys2.org/) (or other such utility).
For Linux, use the build script file `build.sh`.
