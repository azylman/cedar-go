FROM heroku/cedar:14

RUN useradd -d /app -m app
USER app
WORKDIR /app

ENV HOME /app
ENV PORT 3000

RUN mkdir -p /app/heroku/mercurial
RUN curl -L http://mercurial.selenic.com/release/mercurial-3.4.tar.gz \
          | tar xvzf - -C /app/heroku/mercurial --strip-components=1 \
          && cd /app/heroku/mercurial \
          && make local
ENV PATH /app/heroku/mercurial:$PATH

RUN mkdir -p /app/goroot
RUN mkdir -p /app/gopath/src/app
RUN mkdir -p /app/gopath/bin

# Need to set PATH when Heroku tries to run the container, as well
RUN mkdir -p /app/.profile.d
RUN echo "export PATH=\"/app/gopath/bin:\$PATH\"" >> /app/.profile.d/profile.sh

ENV GOVERSION 1.5rc1
RUN curl https://storage.googleapis.com/golang/go$GOVERSION.linux-amd64.tar.gz \
           | tar xvzf - -C /app/goroot --strip-components=1

CMD ["app"]

ONBUILD ENV GOROOT /app/goroot
ONBUILD ENV GOPATH /app/gopath
ONBUILD ENV PATH $GOROOT/bin:$GOPATH/bin:$PATH
ONBUILD ENV GO15VENDOREXPERIMENT 1
ONBUILD COPY . /app/gopath/src/app
ONBUILD WORKDIR /app/gopath/src/app
ONBUILD RUN go build -o /app/gopath/bin/app
ONBUILD EXPOSE 3000
