$ROOT = $PSScriptRoot
$BUILD = Join-Path $ROOT "build"

New-Item -ItemType Directory -Force -Path $BUILD | Out-Null

riscv-none-elf-gcc `
  -march=rv32i `
  -mabi=ilp32 `
  -O0 `
  -ffreestanding `
  -fno-builtin `
  -nostdlib `
  -nostartfiles `
  -T "$ROOT\link.ld" `
  "$ROOT\start.S" "$ROOT\main.c" `
  -o "$BUILD\firmware.elf"

riscv-none-elf-objcopy `
  -O binary `
  "$BUILD\firmware.elf" `
  "$BUILD\firmware.bin"

riscv-none-elf-objdump `
  -d "$BUILD\firmware.elf" `
  > "$BUILD\firmware.asm"

python "$ROOT\bin2hex.py"