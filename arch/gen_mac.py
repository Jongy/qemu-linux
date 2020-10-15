import sys
import hashlib

if len(sys.argv) != 2:
    raise Exception("call me with 1 arg (seed)")

mac = bytearray(hashlib.sha1(sys.argv[1].encode()).digest()[:6])
mac[0] = mac[0] & ~1
mac[0] = mac[0] | 2
print(":".join('{:02x}'.format(o) for o in mac))
