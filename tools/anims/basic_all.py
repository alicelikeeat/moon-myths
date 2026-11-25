import os, sys, glob, json
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
import anim

# 宗教经典（含古兰经）：不打分、不评进阶，只有普通动画
RELIGIOUS = ("quran", "bible", "dhammapada", "gita", "upanishad", "sutra", "jingang", "xinjing", "fahua", "weimo", "amituo", "faju")
NO_ANIM = ()

done = set()
for f in glob.glob(os.path.join(anim.ROOT, "anims", "*.json")):
    d = json.load(open(f, encoding="utf-8"))
    if any(s.get("tier") == "core" for s in d["scenes"]):
        done.add(d["id"])
for f in sorted(glob.glob(os.path.join(anim.ROOT, "texts", "*.json"))):
    tid = os.path.basename(f)[:-5]
    if tid in done or (NO_ANIM and tid.startswith(NO_ANIM)):
        continue
    anim.reset()
    style = None
    if tid.startswith(RELIGIOUS):
        style = ("quran" if tid.startswith("quran") else "bible" if tid.startswith("bible")
                 else "vedic" if tid.startswith(("upanishad", "gita")) else "buddhist")
    anim.save(tid, scored=not tid.startswith(RELIGIOUS), style=style)
