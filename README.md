README.md
# legends-nginx

## Table of Contents

- [About](#about)
- [Getting Started](#getting_started)
- [Usage](#usage)
- [Contributing](../CONTRIBUTING.md)

## About <a name = "about"></a>
Nginx File Caching System for FiveM

## Getting Started <a name = "getting_started"></a>

These instructions will get you a copy of the project up and running on your local machine for development and testing purposes. See [deployment](#deployment) >

**Build script only compatible with ubuntu systems, should be used on a fresh dedicated box with minimal resources and high bandwidth/throughput**


### Prerequisites

Install curl

```
sudo apt install curl
```
Clone Repository

```
git clone https://github.com/legendsSystems/legendsCaching.git
cd legendsCaching
```

### Installing

Execute build script

```
sudo chmod +x build.sh && sudo ./build.sh
```

Follow the prompts and enter the required info.  Script can be ran multiple times until successful if needed.

Logout and back in to the ssh session to refresh perms or prepend sudo below

## Usage <a name = "usage"></a>

TO check if the conatiner booted properly

```
docker ps -a
```

Check logs

```
docker logs legendscaching-cache-1
```
