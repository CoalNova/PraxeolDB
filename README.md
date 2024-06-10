# PraxeolDB
```
prax·​e·​ol·​o·​gy ˌ[prak-sē-ˈä-lə-jē] 
The study of human action and conduct, based on the notion that humans engage in purposeful behavior.
```
![PraxeolDB Logo](https://github.com/CoalNova/PraxeolDB/blob/main/serversrc/build_assets/logosmoll.png?raw=true)
--- 

PraxeolDB is a program dedicated to facilitate warehouse inventory ordering. It is not intended to handle financial transactions. PraxeolDB is designed for use by warehouse inventory managers on small scales and on often slow office computers. It is meant to be easily deployed and maintained, and to be as unobtrusive as possible.


Though many warehouse inventory and ordering solutions do exist, they are often cumbersome, difficult to understand (by use of non-standard verbiage), and often costly. PraxeolDB aims to remove these blockers by singularizing itself around a single, portable executable and database file. This pairing is stored in the same directory location, but can be located anywhere. 

Customization of the system is made possible by building out files to be replaced. Customization in this way is entirely optional. 

The PraxeolDB program aims to be free, with no functions or features blocked behind seemingly arbitrary paywalls.

PraxeolDB is meant to be operated and maintained by onsite personnel, not exclusively IT specialists, systems-level software developers, or SQL gurus with two-dozen years of experience. The language used in the program is plain, straightforward, and purposeful. Options exposed to the user and admins are clear, and plain. A feature is an output pane, which is used to display moment to moment events clearly and transparently.


Access to the server is provided through web access. 

---



##### **!WORK IN PROGRESS!**

PraxeolDB is an in-development fullstack solution for asset management and ordering system, designed for small impact and wide adoptability. It is intended for small or independent operations as a method of simple inventory requisition by multiple users/sites. PraxeolDB is designed to use as few system resources as it can to achieve this goal.

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


PraxeolDB is written in [Zig](https://ziglang.org/), using the [Zap](https://github.com/zigzap/zap) and [Zig-SQLite](https://github.com/nDimensional/zig-sqlite) libraries.


PraxeolDB utilizes selective and hardcoded responses to network requests, keeping website data in memory for rapid web request resolution. Though the Database is located on disk by default, it may be launched with an option to keep the database in memory, for faster operations at the cost of memory footprint. By leveraging the power of modern systems-level language, the program can run easily on older and/or less robust hardware without suffering the expected costs of a full-service web server.

The full hardware spec targeted for the server is to be determined. However, anything running capable of starting Windows 7 should be powerful enough to run this. 

&nbsp;

### The Client:
---
The PraxeolDB client uses [Javascript](https://ecma-international.org/publications-and-standards/standards/ecma-262/) language for application distribution over web connections. 

A simple, clean, and most of all lite interface. It will facilitate the requisition of inventory items and supplies. It will also allow for administrative and semi-administrative editing of user, site, and inventory asset information. The layout should focus on a clear, readable, and organically laid out interface.

The hardware spec for the client is any system powerful enough to run a javascript-capable browser. Specific details are TBD.

&nbsp;

### Building:
---

Current requirements are [Zig](https://ziglang.org/) 0.12.0.

Running `build.sh` in Linux, or on Windows via [WSL2](https://learn.microsoft.com/en-us/windows/wsl/install), will produce the `praxeoldb` executable in the top project directory.

### Using:
---

At this time, the program will launch and generate the `praxeol.db` database in the working directory. The interface may be accessed, by default, via a browser at `https://localhost:4443`. Default login for template user is username: `admin` password: `password`. Most features are not yet implemented.