# PowerDNS dnsdist packaged by [Azorian Solutions](https://azorian.solutions)

dnsdist is a highly DNS-, DoS- and abuse-aware loadbalancer. Its goal in life is to route traffic to the best server, delivering top performance to legitimate users while shunting or blocking abusive traffic.

dnsdist is dynamic, its configuration language is Lua and it can be changed at runtime, and its statistics can be queried from a console-like interface or an HTTP API.

[PowerDNS dnsdist Website](https://www.dnsdist.org/index.html)

[PowerDNS dnsdist Documentation](https://www.dnsdist.org/index.html)

## Quick reference

- **Maintained by:** [Matt Scott](https://github.com/AzorianSolutions)
- **Github:** [https://github.com/AzorianSolutions/docker-powerdns-dnsdist](https://github.com/AzorianSolutions/docker-powerdns-dnsdist)
- **Website:** [https://azorian.solutions](https://azorian.solutions)

## TL;DR

    docker run -d -p 12053:53/udp -p 12053:53 -e PDNS_LINE1=newServer({address="1.1.1.1", qps=1}) azoriansolutions/powerdns-dnsdist

## Azorian Solutions Docker image strategy

The goal of creating this image and others alike is to provide a fairly uniform and turn-key implementation for a chosen set of products and solutions. By compiling the server binaries from source code, a greater chain of security is maintained by eliminating unnecessary trusts. This approach also helps assure support of specific features that may otherwise vary from distribution to distribution. A secondary goal of creating this image and others alike is to provide at least two Linux distribution options for any supported product or solution which is why you will often see tags for both Alpine Linux and Debian Linux.

All documentation will be written with the assumption that you are already reasonably familiar with this ecosystem. This includes container concepts, the Docker ecosystem, and more specifically the product or solution that you are deploying. Simply put, I won't be fluffing the docs with content explaining every detail of what is presented.

## Additional features

When building this image, support for the following features have been compiled into the server binaries.

- Lua (luajit)
- Protobuf
- ipcipher
- libsodium
- DNSCrypt
- dnstap
- re2
- SNMP
- DNS over TLS (DoT)
- DNS over HTTP (DoH)
- GnuTLS
- OpenSSL
- lmdb

## Supported tags

\* denotes an image that is planned but has not yet been released.

### Alpine Linux

- 1.6.1, 1.6.1-alpine, 1.6.1-alpine-3.14, alpine, latest

### Debian Linux

- *1.6.1-debian, 1.6.1-debian-11.1-slim, debian

## Deploying this image

### Server configuration

Configuration of the PowerDNS dnsdist server may be achieved through two approaches. With either approach you choose, you will need to be aware of the various settings available for the server.

[PowerDNS dnsdist Settings](https://www.dnsdist.org/quickstart.html#dnsdist-console-and-configuration)

#### Approach #1

You may pass PowerDNS dnsdist server conf file lines as environment variables to the container. These environment variables will be automatically inserted into the /etc/pdns/dnsdist.conf file. Any environment variable that begins with "PDNS_LINE" will have it's value added as a line in the /etc/pdns/dnsdist.conf file.

For example, say you pass the environment variable "PDNS_LINE1" with the value "newServer({address="1.1.1.1", qps=1})" to the container. This will result in the following line being added to the /etc/pdns/dnsdist.conf file;

    newServer({address="1.1.1.1", qps=1})

If you don't want to pass sensitive information in the environment variables, then support has been added for Docker Swarm secrets style configuration. All you have to do is add "_FILE" to the end of any environment variable beginning with "AS_" or "PDNS_". The content of the file will be automatically loaded into a corresponding environment variable using the same name without the "_FILE" suffix. The original environment variable with the "_FILE" suffix will be deleted. Here is an example of how you would add a configuration line using an environment variable that references a Docker Swarm secret named "SECRET-1";

    PDNS_LINE1_FILE=/run/secrets/SECRET-1

This would result in the following line being added to the /etc/pdns/dnsdist.conf file;

    %CONTENTS_OF_/run/secrets/SECRET-1%

#### Approach #2

With this approach, you may create traditional PowerDNS dnsdist server conf files and map them to a specific location inside of the container. This will cause each mapped configuration file to be loaded each time the container is started. For example, say your Docker / Podman host has a PowerDNS dnsdist server conf file stored at /srv/pdns-dnsdist.conf and you want to load that in your PowerDNS dnsdist server container. You will created a volume mapping that will link the conf file on the host to a specific location in the container. The mapping would look something like this;

    /srv/pdns-dnsdist.conf:/etc/pdns/dnsdist.conf

### Deploy with Docker Run

To run a simple container on Docker with this image, execute the following Docker command;

    docker run -d -p 12053:53/udp -p 12053:53 -e PDNS_LINE1=newServer({address="1.1.1.1", qps=1}) azoriansolutions/powerdns-dnsdist

### Deploy with Docker Compose

To run this image using Docker Compose, create a YAML file with a name and place of your choosing and add the following contents to it;

    version: "3.3"
    services:
      proxy:
        image: azoriansolutions/powerdns-dnsdist:latest
        restart: unless-stopped
        environment:
          - PDNS_LINE1=newServer({address="1.1.1.1", qps=1})
          - PDNS_LINE2=webserver("0.0.0.0:8080", "PASSWORD-HERE", "API-KEY-HERE", {}, "0.0.0.0/0")
        ports:
          - "12053:53/udp"
          - "12053:53"
          - "12080:8080"

Then execute the following Docker Compose command;

    docker-compose -u /path/to/yaml/file.yml

## Building this image

If you want to build this image yourself, you can easily do so using the **build-release** command I have included.

The build-release command has the following parameter format;

    build-release IMAGE_TAG_NAME PDNS_VERSION DISTRO_REPO_NAME DISTRO_TAG

So for example, to build the PowerDNS dnsdist server version 1.6.0 on Alpine Linux 3.14, you would execute the following shell command:

    build-release 1.6.0-alpine-3.14 1.6.0 alpine 3.14

The build-realease command assumes the following parameter defaults;

- Image Tag Name: latest
- PDNS Version: 1.6.1
- Distro Name: alpine
- Distro Tag: 3.14

This means that running the build-release command with no parameters would be the equivalent of executing the following shell command:

    build-release latest 1.6.1 alpine 3.14

When the image is tagged during compilation, the repository portion of the image tag is derived from the contents of the .as/docker-registry file and the tag from the first parameter provided to the build-release command.
