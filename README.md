# ECHO66

A simple, universal x86 operating system running exclusively in 16-bit Real Mode. Written in FASM-flavoured assembly.

## Features
- **Bootloader:** Reads `KERNEL.BIN` from a FAT12-formatted floppy disk and loads it into memory.
- **Kernel:** Echoes back keyboard interrupts and provides basic command-line shell functionality.

## Commands

### Compile
```bash
./fasm/fasm [name].asm
```

### Start Emulator
```bash
qemu-system-x86_64 -fda disk.img
```

### Disk Creation
```bash
dd if=/dev/zero of=disk.img bs=512 count=2880
```

### Disk Formatting
```bash
sudo mkfs.fat -F 12 disk.img
# OR
mformat -f 1440 -i disk.img ::
```

### Bootloader Injection
```bash
dd if=boot.bin of=disk.img bs=512 count=1 conv=notrunc
```

### Kernel Injection (Old)
```bash
dd if=kernel.bin of=disk.img bs=512 seek=1 conv=notrunc
```

### Kernel Load New
```bash
mcopy -i disk.img kernel.bin ::/kernel.bin
```
