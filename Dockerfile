FROM matrixanger/ocaml-4.04:arm
Maintainer Roger Stark <rho.ajax@gmail.com>
 
WORKDIR /root

RUN apt-get -yqq update \
    && DEBIAN_FRONTEND=noninteractive apt-get -yqq --no-install-recommends install \
    libblas-dev liblapack-dev liblapacke-dev pkg-config libplplot-dev libshp-dev libopenblas-dev
 
RUN opam update && opam install -y utop ctypes plplot alcotest lacaml oasis jbuilder atdgen\
    && eval `opam config env`

RUN cd /root && git clone https://github.com/ryanrhymes/eigen.git \
    && sed -i -- 's/-march=native -mfpmath=sse/-march=native/g' /root/eigen/_oasis /root/eigen/lib/Makefile\
    && sed -i -- 's/ar rvs/gcc-ar rvs/g' /root/eigen/lib/Makefile \
    && eval `opam config env` \
    && cd /root/eigen \
    && make oasis \
    && make && make install

RUN git clone https://github.com/ryanrhymes/owl.git

# remove unrecognised sse compile flag on arm
RUN sed -i -- 's/-lopenblas/-lopenblas -llapacke/g' /root/owl/src/owl/jbuild \
    && sed -i -- 's/-march=native -mfpmath=sse/-march=native/g' /root/owl/src/owl/jbuild \
    && sed -i -- 's/-DSFMT_MEXP=19937 -msse2/-DSFMT_MEXP=19937/g' /root/owl/src/owl/jbuild 

RUN cd owl \
    && eval `opam config env ` \
    && make && make install

RUN bash -c 'echo -e "#require \"owl\"\n#require \"owl_zoo\"\nopen Owl\n" >> /root/.ocamlinit' \
    && bash -c 'echo -e "export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/root/.opam/system/lib/stubslibs" >> /root/.bashrc' \
    && bash -c "source /root/.bashrc"

# RUN DEBIAN_FRONTEND=noninteractive apt-get update && \
#    apt-get -yqq --no-install-recommends install vim
    
WORKDIR /root/owl
RUN opam config env >> /root/.bashrc \
    && bash -c "source /root/.bashrc"

CMD ["/bin/bash"]
