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

RUN git clone -b arm https://github.com/jzstark/owl.git
RUN sed -i -- 's/-lopenblas/-lopenblas -llapacke/g' /root/owl/src/owl/jbuild
RUN cd owl \
    && eval `opam config env ` \
    && make && make install

RUN bash -c 'echo -e "#require \"owl\"\n#require \"owl_zoo\"\nopen Owl\n" >> /root/.ocamlinit' \
    && bash -c 'echo -e "export LD_LIBRARY_PATH=LD_LIBRARY_PATH:/root/.opam/system/lib/stubslibs" >> /root/.bashrc' \
    && bash -c "source /root/.bashrc"

# RUN DEBIAN_FRONTEND=noninteractive apt-get update && \
#    apt-get -yqq --no-install-recommends install vim
    
WORKDIR /root/owl
RUN eval `opam config env`

ENTRYPOINT /bin/bash
