# Vanadium OS

This is a personal project to learn the fundamental concepts of Operating System development, starting from 16-bit real mode.

## Objectives

The main goal is to create tools to use the os:
- Boot in 16-bit real mode.
- Display text on the screen.
- Read input from the keyboard.
- (Future goals) 
    - Create a shell, for a custom terminal
    - Create a text editor
    - Create a executable format for files created by the user

## How to Build and Run

### Prerequisites

To build and run this project, you will need the following tools:

- **NASM**: An assembler for the Intel x86 syntax.
- **QEMU**: A machine emulator to run the OS image.

You can install these dependencies on a Debian/Ubuntu-based system with the following command:
```bash
sudo apt-get update
sudo apt-get install nasm qemu-system-x86
```

### Building

To build the operating system, run the following command in the project root:

```bash
./build.sh
```

This will generate a disk image file (e.g., `disk.img`).

### Running

To run the operating system in the QEMU emulator, use the command:

```bash
qemu-system-i386 -fda disk.img -nographics

```
(Optional) Only if sdl support installed:
```bash
qemu-system-i386 -fda disk.img -display sdl
```

## Project Structure

```
.
├── boot.s             # Bootloader code
├── kernel.s           # Kernel code
├── Build.sh          # File to automate the build
└── README.md         # This file
```

## Useful Resources

During the development of this project, the following resources were of great help:

- [OSDev Wiki](https://wiki.osdev.org/) - An indispensable source of knowledge for OS development.
