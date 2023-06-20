# PraxeolDB
```
prax·​e·​ol·​o·​gy ˌ[prak-sē-ˈä-lə-jē] 
The study of human action and conduct, based on the notion that humans engage in purposeful behavior.
```
![PraxeolDB Logo](https://github.com/CoalNova/PraxeolDB/blob/main/assets/logosmoll.png?raw=true)
--- 
PraxeolDB is an asset management and ordering system designed for small impact and wide adoptability. PraxeolDB is an in-development twin program solution for small operations as a method of simple inventory requisition by multiple users. It aims to utilize as few network and system resources as possible. 

The Server program is built in the [Zig](https://ziglang.org/) language, for its focus on performance, ease of use, and safety.

The Client program is built in a yet tbd language (selection determined to be likely Typescript).

&nbsp;

The Server:
---
Utilizes SQLite for database engine, TLS for network security, and CoAP(tenuous) for the data transference. It will be accessable through a distributed typescript web interface, or optionally a locally run program. It will manage inventory ordering, user account links to sites, and offer inventory level and storage audit tools.

Various libraries required to facilitate operation are still being researched. This readme will reflect when those sources are onboarded.

Proper interfacing for the server is still being researched. Ideally CLI will be used for adjusting configuration in a headless environment. 

The hardware spec targeted for the server is any run-of-the-mill office workstation as baseline details TBD.

&nbsp;

The Client:
---
A simple, clean, and most of all lite interface. It will facilitate the requesition of inventory items and supplies. It will also allow for administrative and semi-administrative editing of user, site, and inventory information. The layout should focus on a clear, readable, and organically laid out interface.

Research is being performed on achieving desired results. 

The hardware spec for the client is an android we browser for a low-mid range android tablet, details TBD.
