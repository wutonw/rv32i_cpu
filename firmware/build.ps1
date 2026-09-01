$ROOT = $PSScriptRoot
$BUILD = Join-Path $ROOT "build"

New-Item -ItemType Directory -Force -Path $BUILD | Out-Null

riscv-none-elf-gcc `
  -march=rv32i_zicsr `
  -mabi=ilp32 `
  -O0 `
  -msmall-data-limit=0 `
  -ffreestanding `
  -fno-builtin `
  -nostdlib `
  -nostartfiles `
  -T "$ROOT\link.ld" `
  "$ROOT\start.S" "$ROOT\trap_entry.S" "$ROOT\main.c" `
  "-Wl,-Map=$BUILD\firmware.map" `
  -o "$BUILD\firmware.elf"

if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

riscv-none-elf-objcopy `
  -O binary `
  --only-section=.text `
  --only-section=.rodata `
  "$BUILD\firmware.elf" `
  "$BUILD\firmware.bin"

if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

riscv-none-elf-objdump `
  -d "$BUILD\firmware.elf" `
  > "$BUILD\firmware.asm"

if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

python "$ROOT\bin2hex.py"
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
