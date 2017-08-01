FROM matrixanger/ocaml-4.04:arm
Maintainer Roger Stark <rho.ajax@gmail.com>
 
WORKDIR /root

RUN apt-get -yqq update \
    && DEBIAN_FRONTEND=noninteractive apt-get -yqq --no-install-recommends install \
    libgsl0-dev libblas-dev liblapack-dev  liblapacke-dev pkg-config libplplot-dev libshp-dev libopenblas-dev
 
RUN opam install -y utop ctypes plplot dolog alcotest gsl lacaml oasis\
    && eval `opam config env`

RUN cd /root && git clone https://github.com/ryanrhymes/eigen.git \
	&& eval `opam config env` \
	&& cd /root/eigen \
    && make oasis \
    && make && make install

RUN git clone https://github.com/ryanrhymes/owl.git \
    && cd owl \
    && eval `opam config env ` \
    && make oasis \
    && make && make install \
    && bash -c 'echo -e "#require \"owl\"\n#require \"owl_zoo\"\n" >> /root/.ocamlinit'

RUN DEBIAN_FRONTEND=noninteractive apt-get -yqq --no-install-recommends install vim

## Set default container command
WORKDIR /root/owl
ENTRYPOINT /bin/bash
