# Builds ckbuilder.jar from source inside a container.
#
# wslc (exports a tar archive; directory exports are not supported):
#
#   wslc build -o type=tar,dest=bin/ckbuilder.tar .
#   tar -xf bin/ckbuilder.tar -C bin
#
# Docker (exports the jar straight into ./bin):
#
#   docker build -o type=local,dest=bin .

FROM debian:bookworm-slim AS build

RUN apt-get update \
	&& apt-get install -y --no-install-recommends openjdk-17-jdk-headless ant \
	&& rm -rf /var/lib/apt/lists/*

WORKDIR /src
COPY . .

# Same as dev/build/build_jar.sh ("ant jar" followed by "ant clean"); the jar ends up in /src/bin.
RUN ant -f dev/build/build.xml jar clean \
	&& java -jar bin/ckbuilder.jar --help > /dev/null

# Final stage contains only the jar, so the build output is just that file.
FROM scratch AS export
COPY --from=build /src/bin/ckbuilder.jar /ckbuilder.jar
