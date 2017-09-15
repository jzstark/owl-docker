FROM matrixanger/ocaml-4.04:arm
Maintainer Roger Stark <rho.ajax@gmail.com>
 
WORKDIR /root

RUN apt-get -yqq update \
    && DEBIAN_FRONTEND=noninteractive apt-get -yqq --no-install-recommends install \
    libgsl0-dev libblas-dev liblapack-dev  liblapacke-dev pkg-config libplplot-dev libshp-dev libopenblas-dev
 
RUN opam update && opam install -y utop ctypes plplot dolog alcotest gsl lacaml oasis jbuilder atdgen\
    && eval `opam config env`

RUN cd /root && git clone https://github.com/ryanrhymes/eigen.git \
	&& eval `opam config env` \
	&& cd /root/eigen \
    && make oasis \
    && make && make install

RUN git clone https://github.com/ryanrhymes/owl.git \
    && cd owl \
    && eval `opam config env ` \
    && sed -i '20i    -llapacke\n' src/owl/jbuild \
    && make && make install \
    && bash -c 'echo -e "#require \"owl\"\n#require \"owl_zoo\"\nopen Owl\n" >> /root/.ocamlinit' \
    && bash -c 'echo -e "export LD_LIBRARY_PATH=LD_LIBRARY_PATH:/root/.opam/system/lib/stubslibs" >> /root/.bashrc' \
    && source /root/.bashrc

RUN DEBIAN_FRONTEND=noninteractive apt-get -yqq --no-install-recommends install vim

## Set default container command
WORKDIR /root/owl
ENTRYPOINT /bin/bash
