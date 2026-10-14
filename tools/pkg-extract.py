"""Extracts a Wallpaper Engine scene.pkg into a directory.

usage: pkg-extract.py <scene.pkg> <output dir>
"""
import os
import struct
import sys


def main():
    src, out = sys.argv[1], os.path.abspath(sys.argv[2])
    with open(src, 'rb') as f:
        def u32():
            return struct.unpack('<I', f.read(4))[0]

        def string():
            return f.read(u32()).decode('utf-8', 'replace')

        string()  # version, e.g. PKGV0023
        entries = [(string(), u32(), u32()) for _ in range(u32())]
        base = f.tell()
        for name, offset, length in entries:
            dst = os.path.normpath(os.path.join(out, name))
            if not dst.startswith(out + os.sep):
                continue  # skip paths that escape the output dir
            os.makedirs(os.path.dirname(dst), exist_ok=True)
            f.seek(base + offset)
            with open(dst, 'wb') as o:
                o.write(f.read(length))


if __name__ == '__main__':
    main()
