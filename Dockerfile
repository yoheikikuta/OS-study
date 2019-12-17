FROM ubuntu:18.04
LABEL maintainer="diracdiego@gmail.com"
LABEL version="1.0"

RUN dpkg --add-architecture i386
RUN apt update && apt install -y \
	software-properties-common \
	nasm \
	libc6-dev:i386 \
	gcc:i386 \
	qemu-system-i386 \
	bochs \
	bochs-x

WORKDIR /work

CMD ["/bin/bash"]
