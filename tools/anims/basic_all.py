import os, sys, glob, json
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
import anim

# 宗教经典：不打分、不评进阶；古兰经：不做任何动画
RELIGIOUS = ("bible", "dhammapada", "gita", "upanishad", "sutra", "jingang", "xinjing", "fahua", "weimo", "amituo")
NO_ANIM = ("quran",)

done = set()
for f in glob.glob(os.path.join(anim.ROOT, "anims", "*.json")):
    d = json.load(open(f, encoding="utf-8"))
    if any(s.get("tier") == "core" for s in d["scenes"]):
        done.add(d["id"])
for f in sorted(glob.glob(os.path.join(anim.ROOT, "texts", "*.json"))):
    tid = os.path.basename(f)[:-5]
    if tid in done or tid.startswith(NO_ANIM):
        continue
    anim.reset()
    anim.save(tid, scored=not tid.startswith(RELIGIOUS))
