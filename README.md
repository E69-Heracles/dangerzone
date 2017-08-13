# Dangerzone 2.0

## Introduction

Dangerzone 2.0 is a dynamic campaign generator for *Il-2 Sturmovik 1946* based on Bourne Again Dynamic Campaign (B.A.D.C) originally developed by JG10r_Dutertre in 2003. Obviously DZ, as it was BADC, is an ongoing effort. So as JG10r_Dutertre used to write:

> Know-Bugs: NaN... err many many:)
> Unknown-Bugs: the double of the Known ones :)

## Development environment

You need [Docker](https://docs.docker.com/engine/installation/) to install the development environment.

After installing Docker, clone this repository into a working directory and set the following environment variable in a Docker enabled terminal:

```bash
$> export DANGERZONE_WD=__your_path_to_dangerzone_working_directory__
```

To launch development environment, change directory to the development directory, make your docker image and run it:

```bash
$> cd "$DANGERZONE_WD"/development
$> docker build --no-cache -t e69/dangerzone .
$> ./launch_dz.sh
```
After launching the application you should be able to point your browser to wherever your container network address is listening to (it depends on using docker machine or not) and you should get the DangerZone home page on port 80.

You will find created two squadrons and two pilots per squadron in order to easy testing features and page navigation:

  * rEd69 (Red squadron): with pilots rEd69_Red1 and rEd69_Red2
  * E69 (Blue squadron): with pilots E69_Blue1 and E69_Blue2

Superuser for administrative task is rEd69_Red1.

Installed software versions for development environment:

  * Apache : 2.4.7
  * PHP    : 5.5.9
  * MySQL  : 5.5.57
  * Perl   : 5.18.2
  * OS     : Ubuntu 14.04.5 LTS Trusty

## Credits

You will find JG10r_Dutertre's BADC 1.0 credits [here](./install.txt).

Also I would like to thanks *Mertons* for his great generosity giving up his original server and the source code to evolve the original DangerZone 1.0 to the current DangerZone 2.0. Credits for he original DangerZone 1.0 (in spanish):

>Bueno, pues en primer lugar quiero dar las gracias a Dutrerte por su inmensa generosidad al liberar el código del a BADC para que todos podamos usarlo. También quiero dar las gracias a AA_Hawkman y AA_Pilón por su ayuda y su apoyo, sin ellos no habría sido posible poner en marcha la Danger Zone.

>Y, por último, gracias a todo el Ala13 por su entusiasmo, ayuda y facilidades. Y ahora, los agradecimientos de Dutrerte, a los que me sumo:

And finally the credits for DangerZone 2.0 (also in spanish):

>Además de reiterar el agradecimiento a "E69_Heracles" quiero hacerlo extensivo a otros muchos pilotos virtuales que, en mayor o menor medida, han contribuído a hacer posible este proyecto: unos con sus conocimientos, consejos y sugerencias, otros con su apoyo, otros con sus gestiones, y muchos como "sufridos probadores":

>E69_cvchavo
E69_metaliving
E69_Patrel
E69_chapas
FAE_Cazador
FAE_Cormorán
RedEye_Tumu

>Y, por supuesto, a quienes como "E69_vgilsoler" comenzaron este proyecto desde sus inicios.

>La Danger Zone 2.0 diseñada por e E69_espiral, E69_cvchavo, E69_Patrel, E69_Metaliving y implementada por E69_Heracles, es una adaptación del motor B.A.D.C.

## License

Original BADC 1.0 License [here](./install.txt)

DangerZone 2.0  - License
Copyright (c) 2010, 2017, E69_Heracles  - 22sas.heracles@gmail.com
All rights reserved. Licenced under Non-copyleft - see Aditional Notes.

Redistribution and use in source and binary forms, with or without modification,
are permitted provided that the following conditions are met:

1. Redistributions of source code must retain the above copyright notice, this
list of conditions and the following disclaimer.

2. Redistributions in binary form must reproduce the above copyright notice,
this list of conditions and the following disclaimer in the documentation and/or
other materials provided with the distribution.

Disclaimer:

THIS SOFTWARE IS PROVIDED BY E69_Heracles "AS IS" AND ANY EXPRESS OR IMPLIED
WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL E69_Heracles BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

END OF TERMS AND CONDITIONS

