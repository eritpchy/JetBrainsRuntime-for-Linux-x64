FROM ubuntu:16.04
ADD /etc/apt/sources.list /etc/apt/sources.list
RUN apt update \
	&& apt install -y autoconf make build-essential libx11-dev libxext-dev libxrender-dev libxtst-dev libxt-dev libxrandr-dev libcups2-dev libfontconfig1-dev libasound2-dev unzip zip git

#jdk11
RUN apt install -y software-properties-common \
	&& add-apt-repository ppa:openjdk-r/ppa -y \
	&& apt update \
	&& apt install -y openjdk-11-jdk

#Cmake
RUN apt install -y libssl-dev wget \
	&& cd /root \
	&& wget https://github.com/Kitware/CMake/releases/download/v3.20.2/cmake-3.20.2.tar.gz \
	&& tar xf cmake-3.20.2.tar.gz \
	&& cd cmake-3.20.2 \
	&& ./bootstrap \
	&& make -j$(nproc) \
	&& make install \
	&& cmake --version

#OpenJFX
RUN add-apt-repository ppa:ubuntu-toolchain-r/test -y \
	&& apt update \
	&& apt install -y libgtk2.0-dev libgtk-3-dev ant gcc-8 g++-8 ruby gperf  libgl1-mesa-dev mercurial \
	&& update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-8 100 \
	&& update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-8 100 \
	&& cd /root \
	&& hg clone http://hg.openjdk.java.net/openjfx/11-dev/rt \
	&& /usr/bin/printf '\xfe\xed\xfe\xed\x00\x00\x00\x02\x00\x00\x00\x00\xe2\x68\x6e\x45\xfb\x43\xdf\xa4\xd9\x92\xdd\x41\xce\xb6\xb2\x1c\x63\x30\xd7\x92' > /etc/ssl/certs/java/cacerts \
	&& update-ca-certificates -f \
	&& /var/lib/dpkg/info/ca-certificates-java.postinst configure \
	&& cd rt \
	&& chmod a+x ./gradlew \
	&& ./gradlew -PCOMPILE_WEBKIT=true -Djavax.net.ssl.trustStorePassword=changeit  -Djavax.net.ssl.trustStore=/etc/ssl/certs/java/cacerts

#JetBrainsRuntime
ADD idea.patch /tmp/idea.patch
RUN cd /root \
	&& git clone --depth=1 -b master --single-branch https://github.com/JetBrains/JetBrainsRuntime.git \
	&& cd JetBrainsRuntime \
	&& patch -p1 < /tmp/idea.patch \
	&& rm -f /tmp/idea.patch \
	&& CC=gcc-8 sh ./configure --disable-warnings-as-errors  --with-import-modules=../rt/build/modular-sdk \
	&& make JOBS=$(nproc) images \
	&& cd build/linux-x86_64-normal-server-release/images/ \
	&& mv jdk jbr \
	&& zip -r jbr-linux-x64.zip ./jbr/*
