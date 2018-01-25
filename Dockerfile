FROM ioft/armhf-ubuntu:16.04
Maintainer Roger Stark <rho.ajax@gmail.com>

#### Prerequisites ####

RUN apt-get update
RUN apt-get -y install git build-essential ocaml wget unzip aspcud m4 pkg-config
RUN apt-get -y install camlp4-extra libshp-dev libplplot-dev
RUN apt-get -y install libopenblas-dev liblapacke-dev

RUN apt-get -y install opam \
    && yes | opam init && eval $(opam config env) 
    
RUN opam update && opam switch 4.06.0 && eval $(opam config env)
RUN opam install -y oasis jbuilder ocaml-compiler-libs ctypes plplot alcotest utop 

#### Set up env vars ####

ENV PATH /root/.opam/4.06.0/bin:/usr/local/sbin/:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:$PATH
ENV CAML_LD_LIBRARY_PATH /root/.opam/4.06.0/lib/stublibs


#### Install Eigen library ####

ENV EIGENPATH /root/eigen
RUN cd /root && git clone https://github.com/ryanrhymes/eigen.git
RUN sed -i -- 's/-march=native -mfpmath=sse/-march=native/g' $EIGENPATH/_oasis $EIGENPATH/lib/Makefile \
    && sed -i -- 's/ar rvs/gcc-ar rvs/g' /root/eigen/lib/Makefile
RUN eval $(opam config env) \
    && make -C $EIGENPATH oasis \
    && make -C $EIGENPATH && make -C $EIGENPATH install

#### Install Owl library ####

ENV OWLPATH /root/owl
RUN cd /root && git clone https://github.com/ryanrhymes/owl.git

# remove unrecognised sse compiler option on arm; add libraries for linking
RUN sed -i -- 's/-lopenblas/-lopenblas -llapacke/g' $OWLPATH/src/owl/jbuild \
    && sed -i -- 's/-march=native -mfpmath=sse/-march=native/g' $OWLPATH/src/owl/jbuild \
    && sed -i -- 's/-DSFMT_MEXP=19937 -msse2/-DSFMT_MEXP=19937/g' $OWLPATH/src/owl/jbuild 

RUN cd $OWLPATH \
    && eval `opam config env ` \
    && make && make install

#### Setup default container vars #### 

RUN echo "#require \"owl_top\";; open Owl;;" >> /root/.ocamlinit \
    && bash -c 'echo -e "export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/root/.opam/4.06.0/lib/stubslibs" >> /root/.bashrc' \
    && opam config env >> /root/.bashrc \
    && bash -c "source /root/.bashrc"

WORKDIR $OWLPATH
ENTRYPOINT /bin/bash
