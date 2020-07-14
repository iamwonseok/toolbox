# First stage build: install toolchains
FROM ubuntu:18.04

ENV PREFIX 	  /app
ENV PATH_Z3 	  /app/z3
ENV PATH_RVGCC 	  /app/riscv-gcc
ENV PATH_LLVM 	  /app/llvm
ENV PATH_IKOS 	  /app/ikos
ENV PATH_CPPCHECK /app/cppcheck
ENV RISCVGCC 	  riscv64-unknown-elf-gcc-8.3.0-2019.08.0-x86_64-linux-ubuntu14

RUN sed -i 's/archive.ubuntu.com/ftp.daumkakao.com/g' /etc/apt/sources.list
RUN apt-get update

# Install deb for llvm
RUN apt-get -y install \
               binutils build-essential libtool texinfo \
               gzip zip unzip patchutils curl wget git \
               make cmake ninja-build automake bison flex gperf \
               grep sed gawk python bc \
               zlib1g-dev libexpat1-dev libmpc-dev \
               libglib2.0-dev libfdt-dev libpixman-1-dev \
               libxml2-dev

# Install deb for IKOS
RUN apt-get -y install \
               gcc g++ cmake libgmp-dev libboost-dev libboost-filesystem-dev \
               libboost-thread-dev libboost-test-dev python python-pygments libsqlite3-dev libtbb-dev \
               libz-dev libedit-dev

# Download Z3 Prover
WORKDIR /usr/src/z3
RUN git clone https://github.com/Z3Prover/z3.git
WORKDIR /usr/src/z3/z3
RUN git checkout -b z3-llvm-11
RUN python scripts/mk_make.py --prefix=${PATH_Z3}
WORKDIR /usr/src/z3/z3/build
RUN make -j 32
RUN make install

ENV LD_LIBRARY_PATH ${PATH_Z3}/lib:$LD_LIBRARY_PATH

# Install RISC-V toolchian
WORKDIR ${PREFIX}
RUN wget -q -c https://static.dev.sifive.com/dev-tools/${RISCVGCC}.tar.gz -O - | \
    tar xz --transform 's/'${RISCVGCC}'/riscv-gcc/'
ENV PATH ${PATH_RVGCC}/bin:$PATH

# Download LLVM-11 source
WORKDIR /usr/src/llvm/
RUN git clone https://github.com/llvm/llvm-project.git
WORKDIR /usr/src/llvm/llvm-project
RUN git checkout -b llvm-11 aff8c045a225d98ee5fffa914e2493941f8465cd
WORKDIR /usr/src/llvm/build
RUN cmake -G Ninja -DCMAKE_BUILD_TYPE="Release" \
             -DCMAKE_INSTALL_PREFIX=${PATH_LLVM} \
	     -DLLVM_Z3_INSTALL_DIR=${PATH_Z3} \
	     -DLLVM_PARALLEL_COMPILE_JOBS=32 \
	     -DLLVM_PARALLEL_LINK_JOBS=32 \
             -DBUILD_SHARED_LIBS=True -DLLVM_USE_SPLIT_DWARF=True \
             -DLLVM_OPTIMIZED_TABLEGEN=True -DLLVM_BUILD_TESTS=False \
             -DDEFAULT_SYSROOT=${PATH_RVGCC} \
             -DLLVM_DEFAULT_TARGET_TRIPLE="riscv64-unknown-elf" \
             -DLLVM_TARGETS_TO_BUILD="RISCV" \
             -DLLVM_ENABLE_RTTI=ON \
             -DLLVM_INCLUDE_UTILS=ON \
             -DLLVM_ENABLE_PROJECTS="clang;clang-tools-extra" -G "Unix Makefiles" \
             ../llvm-project/llvm
RUN make -j 32
RUN make install

# Install IKOS (patched version for LLVM-11)
WORKDIR /usr/src/ikos
RUN git clone https://github.com/iamwonseok/ikos.git
WORKDIR /usr/src/ikos/ikos
RUN git checkout llvm-11
WORKDIR /usr/src/ikos/build
RUN cmake ../ikos -DCMAKE_INSTALL_PREFIX=${PATH_IKOS} \
	          -DLLVM_CONFIG_EXECUTABLE="/app/llvm/bin/llvm-config"
RUN make -j 32
RUN make install

# Install CPPCHECK
WORKDIR /usr/src/cppcheck
RUN git clone https://github.com/danmar/cppcheck.git
WORKDIR /usr/src/cppcheck/build
RUN cmake -DCLANG_TIDY="/app/llvm/bin/clang-tidy" \
          -DCMAKE_INSTALL_PREFIX=${PATH_CPPCHECK} ../cppcheck
RUN make -j 32
RUN make install

# Second stage build: jenkins + tools (binaries)
FROM ubuntu:18.04

ENV PREFIX 	  /app
ENV PATH_Z3 	  /app/z3
ENV PATH_RVGCC 	  /app/riscv-gcc
ENV PATH_LLVM 	  /app/llvm
ENV PATH_IKOS 	  /app/ikos
ENV PATH_CPPCHECK /app/cppcheck

COPY --from=0 /${PREFIX} ${PREFIX}
CMD ["/bin/bash", "-l", "-c"]

# Configure Environment Variables
ENV PATH ${PATH_RVGCC}/bin:$PATH
ENV PATH ${PATH_LLVM}/bin:$PATH
ENV PATH ${PATH_IKOS}/bin:$PATH
ENV PATH ${PATH_CPPCHECK}/bin:$PATH

ENV LD_LIBRARY_PATH ${PATH_Z3}/lib
ENV LD_LIBRARY_PATH ${PATH_LLVM}/lib:$LD_LIBRARY_PATH
ENV LD_LIBRARY_PATH ${PATH_IKOS}/lib:$LD_LIBRARY_PATH
ENV LD_LIBRARY_PATH ${PATH_CPPCHECK}/lib:$LD_LIBRARY_PATH

RUN sed -i 's/archive.ubuntu.com/ftp.daumkakao.com/g' /etc/apt/sources.list
RUN apt-get update
RUN apt-get -y install make python
RUN apt-get -y install gcc g++ cmake libgmp-dev libboost-dev libboost-filesystem-dev \
		       libboost-thread-dev libboost-test-dev python python-pygments libsqlite3-dev libtbb-dev \
		       libz-dev libedit-dev

# Install Jenkins-CI
RUN apt-get -y install python-pip
RUN pip install --upgrade pip
RUN apt-get install -y wget git curl
RUN apt-get install -y --no-install-recommends openjdk-11-jdk
RUN apt-get install -y maven ant ruby rbenv make

RUN wget -q -O - http://pkg.jenkins-ci.org/debian-stable/jenkins-ci.org.key | apt-key add -
RUN echo deb http://pkg.jenkins-ci.org/debian-stable binary/ >> /etc/apt/sources.list.d/jenkins.list
RUN apt-get update
RUN apt-get install -y jenkins

RUN mkdir -p /var/jenkins_home && chown -R jenkins /var/jenkins_home
RUN mkdir -p /usr/share/jenkins/ref/plugins && chown -R jenkins /usr/share/jenkins/ref/plugins
ADD init.groovy /tmp/WEB-INF/init.groovy
RUN apt-get install -y zip && cd /tmp && zip -g /usr/share/jenkins/jenkins.war WEB-INF/init.groovy

USER jenkins

# VOLUME /var/jenkins_home - bind this in via -v if you want to make this persistent.
ENV JENKINS_HOME /var/jenkins_home
ENV JENKINS_UC https://updates.jenkins.io
ENV JENKINS_UC_EXPERIMENTAL=https://updates.jenkins.io/experimental

# for main web interface:
EXPOSE 8080
# for ikos-view web interface:
EXPOSE 8090
# will be used by attached slave agents:
EXPOSE 50000
CMD ["/usr/bin/java",  "-jar",  "/usr/share/jenkins/jenkins.war"]

# TODO(wonseok): add command for installing jenkins plugins
# Refereced from: https://github.com/jenkinsci/docker.git

#COPY jenkins-support /usr/local/bin/jenkins-support
#COPY install-plugins.sh /usr/local/bin/install-plugins.sh
#COPY plugins.txt /usr/share/jenkins/ref/plugins.txt
#RUN /usr/local/bin/install-plugins.sh < /usr/share/jenkins/ref/plugins.txt
# NOTE(wonseok): install-plugins works but how to enable plugins?
