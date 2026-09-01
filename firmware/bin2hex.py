from pathlib import Path


ROM_WORDS = 512
NOP = 0x00000013


def bin_to_hex(bin_path: Path, hex_path: Path) -> None:
    data = bin_path.read_bytes()
    max_bytes = ROM_WORDS * 4

    if len(data) > max_bytes:
        raise ValueError(
            f"firmware is {len(data)} bytes, larger than the {max_bytes}-byte ROM"
        )

    words = []
    for offset in range(0, len(data), 4):
        chunk = data[offset : offset + 4].ljust(4, b"\x00")
        words.append(int.from_bytes(chunk, byteorder="little"))

    words.extend([NOP] * (ROM_WORDS - len(words)))

    image = "".join(f"{word:08x}\n" for word in words)
    hex_path.write_text(image, encoding="ascii")

    # Gowin pROM IP uses the same one-32-bit-word-per-line image as the
    # simulator hex file.  Keep both names synchronized after every build.
    mi_path = hex_path.with_suffix(".mi")
    mi_path.write_text(image, encoding="ascii")


if __name__ == "__main__":
    base = Path(__file__).resolve().parent
    build = base / "build"

    bin_to_hex(
        build / "firmware.bin",
        build / "firmware.hex"
    )
