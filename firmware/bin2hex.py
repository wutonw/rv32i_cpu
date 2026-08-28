from pathlib import Path


ROM_WORDS = 1024
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

    hex_path.write_text(
        "".join(f"{word:08x}\n" for word in words),
        encoding="ascii"
    )


if __name__ == "__main__":
    base = Path(__file__).resolve().parent
    build = base / "build"

    bin_to_hex(
        build / "firmware.bin",
        build / "firmware.hex"
    )
