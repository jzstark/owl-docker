FROM ioft/armhf-ubuntu:16.04
Maintainer Roger Stark <rho.ajax@gmail.com>

RUN apt-get update
RUN apt-get -y install git build-essential ocaml wget unzip aspcud m4 pkg-config
RUN apt-get -y install camlp4-extra libshp-dev libplplot-dev
RUN apt-get -y install libopenblas-dev liblapacke-dev

RUN wget https://github.com/ocaml/opam/archive/2.0.0-beta4.tar.gz && tar xzvf 2.0.0-beta4.tar.gz
RUN cd opam-2.0.0-beta4 && ./configure && make lib-ext && make && make install
# 404 not found error at `make lib-ext`
RUN yes | opam init && eval $(opam env) && opam update && opam switch create 4.04.0

RUN opam install -y oasis jbuilder ocaml-compiler-libs ctypes plplot utop

