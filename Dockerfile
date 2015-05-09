FROM heroku/cedar:14

RUN useradd -d /app -m app
USER app
WORKDIR /app

ENV HOME /app
ENV PORT 3000

RUN mkdir -p /app/heroku
RUN mkdir -p /app/src
RUN mkdir -p /app/perl

WORKDIR /app/src

ENV PERL_VERSION 5.20.1
ENV PATH /app/perl/perl-$PERL_VERSION/bin:$PATH

# Perl
RUN curl -sL https://raw.githubusercontent.com/tokuhirom/Perl-Build/master/perl-build > /app/heroku/perl-build
RUN chmod +x /app/heroku/perl-build
RUN /usr/bin/perl /app/heroku/perl-build $PERL_VERSION /app/perl/perl-$PERL_VERSION
RUN curl -sL https://cpanmin.us/ | /app/perl/perl-$PERL_VERSION/bin/perl - -n --dev Carmel

ONBUILD COPY cpanfile /app/src/

ONBUILD USER app

ONBUILD RUN carmel install && carmel rollout

ONBUILD COPY . /app/src

ONBUILD RUN mkdir -p /app/.profile.d
ONBUILD RUN echo "export PATH=\"/app/perl/perl-5.20.1/bin:\$PATH\"" > /app/.profile.d/perl.sh
ONBUILD RUN echo "cd /app/src" >> /app/.profile.d/perl.sh

ONBUILD EXPOSE 3000
