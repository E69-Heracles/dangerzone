# Dangerzone 2.0

## Introduction

Dangerzone 2.0 is a dynamic campaign generator for *Il-2 Sturmovik 1946* based on Bourne Again Dynamic Campaign (B.A.D.C) originally developed by JG10r_Dutertre in 2003.

## Development environment

Once you clone this repository set the following environment variable:

```bash
$> export DANGERZONE_WD=_your_path_for_dangerzone_repo_
```

To launch development environment, change directory to the development directory, make your docker image and run it:

```bash
$> cd "$DANGERZONE_WD"/development
$> docker build --no-cache -t e69/dangerzone .
$> ./launch_dz.sh
```

Installed software versions for development environment:

  * Apache : 2.4.7
  * PHP    : 5.5.9
  * MySQL  : 5.5.57
  * Perl   : 5.18.2
  * OS     : Ubuntu 14.04.5 LTS Trusty