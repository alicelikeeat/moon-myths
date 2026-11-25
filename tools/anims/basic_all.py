import os, sys, glob
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
import anim

# 还没有精讲脚本的全文：全部生成普通动画
have = {"daodejing-zh", "lunyu-zh", "tractatus-de", "kant-cpr-de", "kant-cpr-en", "mengzi-zh", "zhuangzi-zh"}
for f in sorted(glob.glob(os.path.join(anim.ROOT, "texts", "*.json"))):
    tid = os.path.basename(f)[:-5]
    if tid in have:
        continue
    anim.reset()
    anim.save(tid)
