############################################################
# Dockerfile to build Owl docker image
# Based on owlbarn/owl master branch
# By Liang Wang <liang.wang@cl.cam.ac.uk>
############################################################

FROM ocaml/opam2:4.06
USER opam

##################### PREREQUISITES ########################

RUN sudo apt-get update
RUN sudo apt-get -y install git wget unzip aspcud m4 pkg-config gfortran
RUN sudo apt-get -y install camlp4-extra libshp-dev libplplot-dev
RUN sudo apt-get -y install libopenblas-dev liblapacke-dev

RUN opam update && opam switch create 4.06.0 && eval $(opam config env)
RUN opam install -y oasis dune ocaml-compiler-libs ctypes utop plplot base stdio configurator alcotest sexplib

#################### SET UP ENV VARS #######################

ENV PATH /home/opam/.opam/4.06.0/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:$PATH
ENV CAML_LD_LIBRARY_PATH /home/opam/.opam/4.06.0/lib/stublibs

################# INSTALL EIGEN LIBRARY ####################

ENV EIGENPATH /home/opam/eigen
RUN cd /home/opam/ && git clone https://github.com/owlbarn/eigen.git

RUN sed -i -- 's/-Wno-extern-c-compat -Wno-c++11-long-long -Wno-invalid-partial-specialization/-Wno-ignored-attributes/g' $EIGENPATH/lib/Makefile \
    && sed -i -- 's/-flto/ /g' $EIGENPATH/lib/Makefile \
    && sed -i -- 's/-flto/ /g' $EIGENPATH/_oasis 

RUN cd $EIGENPATH \
    && make oasis && make && make install 
RUN sudo cp $EIGENPATH/_build/include/libeigen.a /usr/local/lib/

################## INSTALL OWL LIBRARY #####################

ENV OWLPATH /home/opam/owl
RUN cd /home/opam && git clone https://github.com/owlbarn/owl.git
RUN make -C $OWLPATH && make -C $OWLPATH install && make -C $OWLPATH clean

############## SET UP DEFAULT CONTAINER VARS ##############

RUN echo "#require \"owl-top\";; open Owl;;" >> /home/opam/.ocamlinit
WORKDIR $OWLPATH
ENTRYPOINT /bin/bash
