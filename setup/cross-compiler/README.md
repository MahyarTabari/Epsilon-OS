# x86 cross compiler

## Why not to use the host default compiler?

Answer: the compiler must be configured for a special architecture and operating system. Although the architecture in our case - if we compile and run the os on our own system - is the same, but the operating system differs.

We can compile the OS with specifying a lot of options with the default compiler of our system, but it is messy and we are not in favor of doing so. So we compile our compiler from source code to customize it for our need. For example one of the important things to notice is that we do not want to use the libgcc provided by Linux. We ourselves have to implement it.


## Setting Up
To set up the cross-compiler you can run the script provided in this directory.

First make it executable:
```bash
chmod +x build.sh
```

Then run it:
```bash
./build.sh
```
