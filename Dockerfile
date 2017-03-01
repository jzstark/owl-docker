FROM matrixanger/ocaml-4.04:arm
Maintainer Roger Stark <rho.ajax@gmail.com>
 
WORKDIR /root

RUN apt-get -yqq update \
    && DEBIAN_FRONTEND=noninteractive apt-get -yqq --no-install-recommends install \
    libgsl0-dev libblas-dev liblapack-dev  pkg-config libplplot-dev libshp-dev
 
RUN opam install -y utop ctypes plplot dolog alcotest gsl lacaml oasis eigen \
    && eval `opam config env`
 
RUN git clone https://github.com/ryanrhymes/owl.git \
    && cd owl \
    && eval `opam config env ` \
    && make oasis \
    && make && make install \
    && bash -c 'echo -e "#require \"owl\"\n#require \"owl_topic\"" >> /root/.ocamlinit'

RUN DEBIAN_FRONTEND=noninteractive apt-get -yqq --no-install-recommends install vim

## Set default container command
WORKDIR /root/owl
ENTRYPOINT /bin/bash
