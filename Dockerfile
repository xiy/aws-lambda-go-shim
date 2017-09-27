#
# Copyright 2017 Alsanium, SAS. or its affiliates. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

FROM amazonlinux:2017.03.0.20170401 as builder

ENV GOLANG_VERSION 1.9
ENV GOLANG_DOWNLOAD_URL https://golang.org/dl/go$GOLANG_VERSION.linux-amd64.tar.gz
ENV GOLANG_DOWNLOAD_SHA256 d70eadefce8e160638a9a6db97f7192d8463069ab33138893ad3bf31b0650a79

RUN true\
  && yum -q -e 0 -y update || true\
  && yum -q -e 0 -y install gcc python27-devel || true\
  && yum -q -e 0 -y clean all

RUN true\
  && curl -fsSL "$GOLANG_DOWNLOAD_URL" -o golang.tar.gz\
  && echo "$GOLANG_DOWNLOAD_SHA256 golang.tar.gz" | sha256sum -c -\
  && tar -C /usr/local -xzf golang.tar.gz; rm golang.tar.gz

ADD src src

RUN true\
  && mkdir dist\
  && /usr/local/go/bin/go build\
        -buildmode=c-shared\
        -ldflags='-w -s'\
        -o dist/runtime.so ./src\
  && python -m compileall -q -d runtime src

RUN true\
  && cp src/*.pyc dist/.\
  && cp src/pack.bash dist/pack\
  && cp src/version.bash dist/version

RUN sed -i "s/VERSION/$(date -u +%Y-%m-%d)/g" dist/version

FROM amazonlinux:2017.03.0.20170401

ENV PATH /usr/local/go/bin:/shim:$PATH

RUN true\
  && yum -q -e 0 -y update || true\
  && yum -q -e 0 -y install gcc gcc-c++ zlib-devel expat-devel libjpeg-devel glib2-devel zip findutils wget bsdtar || true\
  && yum -q -e 0 -y clean all

ADD src/libvips.sh libvips.sh

RUN chmod +x ./libvips.sh
RUN ./libvips.sh

COPY --from=builder /usr/local/go /usr/local/go
COPY --from=builder dist /shim
