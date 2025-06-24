pipeline data flow close to yes (1000x higher than yes-rs).

```console
zig run yes.zig -O ReleaseFast -- hello | pv > /dev/null
^C.2GiB 0:00:03 [7.42GiB/s]
```
