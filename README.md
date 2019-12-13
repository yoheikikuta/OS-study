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
(to change CHS parameters)
$ qemu-system-i386 -rtc base=localtime -drive file=boot.img,format=raw,cyls=16,heads=2,secs=20 -boot order=c -curses
```

Need stop container to terminate or kill the corresponding process like `ps aux | grep [q]emu-system-i386 | awk '{print $2}' | xargs kill`.
