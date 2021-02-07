# vim:syntax=dockerfile
#------------------------------------------------------------------------------
# Dockerfile for building and testing Solidity Compiler on CI
# Target: Ubuntu 19.04 (Disco Dingo) Clang variant
# URL: https://hub.docker.com/r/ethereum/solidity-buildpack-deps
#------------------------------------------------------------------------------

FROM buildpack-deps:focal AS base
LABEL version="5"

ARG DEBIAN_FRONTEND=noninteractive

RUN set -ex; \
	dist=$(grep DISTRIB_CODENAME /etc/lsb-release | cut -d= -f2); \
	echo "deb http://ppa.launchpad.net/ethereum/cpp-build-deps/ubuntu $dist main" >> /etc/apt/sources.list ; \
	apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 1c52189c923f6ca9 ; \
	apt-get update; \
	apt-get install -qqy --no-install-recommends \
		build-essential \
		software-properties-common \
		cmake ninja-build \
		libboost-filesystem-dev libboost-test-dev libboost-system-dev \
		libboost-program-options-dev \
		clang \
		libz3-static-dev \
		; \
	rm -rf /var/lib/apt/lists/*

## 
FROM base AS libraries

ARG DEBIAN_FRONTEND=noninteractive


RUN apt-get update; \
	apt-get -qqy install --no-install-recommends \
		build-essential \
		software-properties-common \
		ninja-build git wget \
		libbz2-dev zlib1g-dev git curl uuid-dev \
		pkg-config openjdk-8-jdk liblzma-dev unzip mlton m4; \
    apt-get install -qy python-pip python-sphinx;

ENV CC clang
ENV CXX clang++
# Install cmake 3.14 (minimum requirement is cmake 3.10)
RUN wget https://github.com/Kitware/CMake/releases/download/v3.14.5/cmake-3.14.5-Linux-x86_64.sh; \
    chmod +x cmake-3.14.5-Linux-x86_64.sh; \
    ./cmake-3.14.5-Linux-x86_64.sh --skip-license --prefix="/usr"


FROM base AS libraries

# Boost
RUN set -ex; \
    cd /usr/src; \
    wget -q 'https://dl.bintray.com/boostorg/release/1.73.0/source/boost_1_73_0.tar.bz2' -O boost.tar.bz2; \
    test "$(sha256sum boost.tar.bz2)" = "4eb3b8d442b426dc35346235c8733b5ae35ba431690e38c6a8263dce9fcbb402  boost.tar.bz2"; \
    tar -xf boost.tar.bz2; \
    rm boost.tar.bz2; \
    cd boost_1_73_0; \
    CXXFLAGS="-stdlib=libc++ -pthread" LDFLAGS="-stdlib=libc++" ./bootstrap.sh --with-toolset=clang --prefix=/usr; \
    ./b2 toolset=clang cxxflags="-stdlib=libc++ -pthread" linkflags="-stdlib=libc++ -pthread" headers; \
    ./b2 toolset=clang cxxflags="-stdlib=libc++ -pthread" linkflags="-stdlib=libc++ -pthread" \
        link=static variant=release runtime-link=static \
        system filesystem unit_test_framework program_options \
        install -j $(($(nproc)/2)); \
    rm -rf /usr/src/boost_1_73_0

# Z3
RUN set -ex; \
    git clone --depth 1 -b z3-4.8.10 https://github.com/Z3Prover/z3.git \
    /usr/src/z3; \
    cd /usr/src/z3; \
    mkdir build; \
    cd build; \
    LDFLAGS=$CXXFLAGS cmake -DZ3_BUILD_LIBZ3_SHARED=OFF -DCMAKE_INSTALL_PREFIX=/usr \
    -DCMAKE_BUILD_TYPE=Release ..; \
    make libz3 -j; \
    make install; \
    rm -rf /usr/src/z3


# gmp
RUN set -ex; \
    # Replace system installed libgmp static library
    # with sanitized version. Do not perform apt
    # remove because it removes mlton as well that
    # we need for building libabicoder
    rm -f /usr/lib/x86_64-linux-gnu/libgmp.*; \
    rm -f /usr/include/x86_64-linux-gnu/gmp.h; \
    cd /usr/src; \
    wget -q 'https://gmplib.org/download/gmp/gmp-6.2.1.tar.xz' -O gmp.tar.xz; \
    test "$(sha256sum gmp.tar.xz)" = "fd4829912cddd12f84181c3451cc752be224643e87fac497b69edddadc49b4f2  gmp.tar.xz"; \
    tar -xf gmp.tar.xz; \
    cd gmp-6.2.1; \
    ./configure --prefix=/usr --enable-static=yes; \
    make -j; \
    make install; \
    rm -rf /usr/src/gmp-6.2.1; \
    rm -f /usr/src/gmp.tar.xz


# HERA
RUN set -ex; \
	cd /usr/src; \
	git clone --branch="v0.3.2" --depth 1 --recurse-submodules https://github.com/ewasm/hera.git; \
	cd hera; \
	mkdir build; \
	cd build; \
	cmake -G Ninja -DBUILD_SHARED_LIBS=ON -DCMAKE_INSTALL_PREFIX="/usr" ..; \
	ninja; \
	ninja install/strip; \
	rm -rf /usr/src/hera

FROM base
COPY --from=libraries /usr/lib /usr/lib
COPY --from=libraries /usr/bin /usr/bin
COPY --from=libraries /usr/include /usr/include

RUN apt update && apt upgrade --yes && apt install sudo locales --yes
RUN dpkg-reconfigure tzdata

ENTRYPOINT ["/bin/sh -c bash" ]
