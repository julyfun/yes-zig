pipeline data flow close to yes (1000x higher than yes-rs).

```console
zig run yes.zig -O ReleaseFast -- hello | pv > /dev/null
[7.42GiB/s]
```

```fish
du -sh yes
 72K	yes

du -sh (dirname (which yes))/yes
 12K	/usr/bin/yes
```
