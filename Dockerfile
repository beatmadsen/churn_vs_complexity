# Create a build image with wget and unzip
FROM ubuntu:latest as pmd_builder
# Install wget and unzip
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      wget unzip

RUN wget https://github.com/pmd/pmd/releases/download/pmd_releases%2F7.0.0/pmd-dist-7.0.0-bin.zip --no-check-certificate
RUN unzip pmd-dist-7.0.0-bin.zip

FROM ruby:3.3-bullseye
# Install git and java JDK

RUN apt-get update; \
	  apt-get install -y --no-install-recommends \
      git openjdk-17-jdk

# copy PMD from build image
COPY --from=pmd_builder /pmd-bin-7.0.0 /usr/local/bin/pmd-bin-7.0.0
# make pmd available in the PATH
RUN ln -s /usr/local/bin/pmd-bin-7.0.0/bin/pmd /usr/local/bin/pmd

COPY *.gemspec Gemfile* /app/
COPY lib /app/lib

WORKDIR /app

RUN bundle install

COPY bin /app/bin
COPY tmp/pmd-support /app/tmp/pmd-support
COPY tmp/template /app/tmp/template

CMD ["/bin/sh", "-c", "echo 'It works!'"]
