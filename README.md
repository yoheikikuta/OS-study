# OS-study (X86 32bit)
For my personal study.  
Based on [this book](https://gihyo.jp/book/2019/978-4-297-10847-2).


## Using QEMU
### Environment construction

```
$ docker built -t os-study -f Dockerfile .
```

```
$ docker run --name os-study -it --rm -v $PWD:/work os-study
```

### Assemble

```
(in the container)
$ nasm boot.s -o boot.img -l boot.lst
```

### Execution

```
(in the container)
$ qemu-system-i386 -rtc base=localtime -drive file=boot.img,format=raw -boot order=c -curses
(to change CHS parameters)
$ qemu-system-i386 -rtc base=localtime -drive file=boot.img,format=raw,cyls=16,heads=2,secs=20 -boot order=c -curses
```

Need stop container to terminate or kill the corresponding process like `ps aux | grep [q]emu-system-i386 | awk '{print $2}' | xargs kill`.


## Using Bochs
### Environment construction
Need to install [socat](http://www.dest-unreach.org/socat/) and [Xquartz](https://www.xquartz.org/) in the host machine (you can use `brew` to install them).

```
$ docker built -t os-study -f Dockerfile .
```

Set signal(to port 6000 which is for XQuartz) to be shown on the host display. 
```
$ socat TCP-LISTEN:6000,reuseaddr,fork UNIX-CLIENT:\"$DISPLAY\"
```

Run a container.
```
$ ifconfig en0 | grep inet | awk '$1=="inet" {print $2}' | xargs -o -I {host ip} docker run --name os-study -it --rm -v $PWD:/work -e DISPLAY={host ip}:0 os-study
```

Give the host to a connection permission to X server. Open XQuartz terminal and execute the following command.
```
(in the XQuartz terminal)
$ ifconfig en0 | grep inet | awk '$1=="inet" {print $2}' | xargs xhost
```


### Assemble

```
(in the container)
$ nasm boot.s -o boot.img -l boot.lst
```

### Execution

```
(in the container)
$ bochs -f ../../../.bochsrc
```

Need stop container to terminate or kill the corresponding process like `ps aux | grep [b]ochs-bin | awk '{print $2}' | xargs kill`.
