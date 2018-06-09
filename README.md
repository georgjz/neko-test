# Neko Library Test ROM

This repository contains files for a simple test ROM that demonstrates how to use the [Neko SNES Library](https://github.com/georgjz/neko). Check the link for more details about the library routines.

## Building the test ROM
There is a makefile that should take care of it. Simple clone the code and use make to build it:
```
$ git clone --recursive https://github.com/georgjz/neko-test.git
$ cd neko-test
$ make
```
The files of the Neko library are includes as a submodule. At the very beginning of the makefile there are two options you can set:
```
# Edit this portion to fit your project
MMAP		= MemoryMap.cfg			# memory map file needed by ld65 linker
BUILDNAME	= NekoCradle.smc     	# name of the final ROM
```
The `MMAP` is the name of the memory map file ld65 needs to build the ROM. Check the [cc65 toolchain documentation](https://cc65.github.io/doc/) for details. `BUILDNAME` will simply determine the name of the output ROM file. This file will be placed in `build/release`. There is no debug option in the makefile yet.

*__Warning__: Do not alter anything else in the makefile unless you know how makefiles work.*  

In the directory `neko` you will find a simple sample program. It will load a tile map and a simple sprite sheet of a cat into VRAM. The cat can be moved with the DPad of Joypad 1. Once the cat comes to close to the screen boundry, the camera will pan in the walking direction.

*__Warning__: There is a bug in the camera movement code: some times the camera will jump a screen instead of panning smoothly when the cat hits the scroll boundry. It does not happen every time the game is started, but every other. Simple reload the ROM if you experience this. I tested only with the [bsnes+ emulator](https://github.com/devinacker/bsnes-plus).

I'm still working on a fix.*
