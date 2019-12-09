# OS-study (X86 32bit)
For my personal study.  
Based on [this book](https://gihyo.jp/book/2019/978-4-297-10847-2).

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
