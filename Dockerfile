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

RUN mkdir -p /app/heroku/goroot
RUN mkdir -p /app/src/gopath/app
RUN mkdir -p /app/src/gopath/bin

ENV GOVERSION 1.5rc1
RUN curl https://storage.googleapis.com/golang/go$GOVERSION.linux-amd64.tar.gz \
           | tar xvzf - -C /app/heroku/goroot --strip-components=1

CMD ["app"]

ONBUILD ENV GOROOT /app/heroku/goroot
ONBUILD ENV GOPATH /app/src/gopath
ONBUILD ENV PATH $GOROOT/bin:$GOPATH/bin:$PATH
ONBUILD ENV GO15VENDOREXPERIMENT 1
ONBUILD COPY . /app/src/gopath/app
ONBUILD WORKDIR /app/src/gopath/app
ONBUILD RUN go get -d ./...
ONBUILD RUN go build -o /app/src/gopath/bin/app
ONBUILD EXPOSE 3000
