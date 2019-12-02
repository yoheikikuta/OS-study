# OS-study
X86 32bit

## Environment construction

```
$ docker built -t os-study -f Dockerfile .
```

```
$ docker run -it --rm -v $PWD:/work os-study
```

## Assemble

```
(in the container)
$ nasm boot.s -o boot.img -l boot.lst
```

## Execution

```
(in the container)
$ qemu-system-i386 -rtc base=localtime -drive file=boot.img,format=raw -boot order=c -curses
```

Need to stop container to terminate.
