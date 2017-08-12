# Dangerzone 2.0

## Introduction

Dangerzone 2.0 is a dynamic campaign generator for *Il-2 Sturmovik 1946* based on Bourne Again Dynamic Campaign (B.A.D.C) originally developed by JG10r_Dutertre in 2003.

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

Installed software versions for development environment:

  * Apache : 2.4.7
  * PHP    : 5.5.9
  * MySQL  : 5.5.57
  * Perl   : 5.18.2
  * OS     : Ubuntu 14.04.5 LTS Trusty