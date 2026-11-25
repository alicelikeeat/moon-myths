"""Casey《欧几里得几何原本前六卷》（1885，PG #21076）→ texts/euclid-en.json"""
import re, html, json
s = open('/home/claude/gb/euclid/21076-h/21076-h.htm', encoding='utf-8', errors='ignore').read()
s = re.sub(r'<(script|style)[^>]*>.*?</\1>', '', s, flags=re.S)
t = html.unescape(re.sub(r'<[^>]+>', '', s)).replace('\r', '')
start = t.find('\nBOOK I. ')
end = t.find('*** END OF')
t = t[start:end if end > 0 else len(t)]
sections, book = [], ''
def new(title): sections.append({'title': title, 'paragraphs': []})
for block in re.split(r'\n\s*\n', t):
    lines = [l.strip() for l in block.split('\n') if l.strip()]
    if not lines: continue
    first = lines[0]
    mb = re.match(r'^BOOK ([IVX]+)\.\s*$', first)
    if mb:
        book = mb.group(1); new(f'Book {book}'); lines = lines[1:]
        if not lines: continue
        first = lines[0]
    mp = re.match(r'^PROP\. ([IVXL]+)\.?\s*[—–-]\s*(Problem|Theorem)\.?', first)
    if mp and book:
        new(f'Book {book} · Prop. {mp.group(1)} ({mp.group(2)})'); lines = lines[1:]
        if not lines: continue
    p = re.sub(r'\s+', ' ', ' '.join(lines)).strip()
    if len(p) < 3 or not re.search(r'[A-Za-z]{2}', p): continue
    if not sections: new('Book I')
    sections[-1]['paragraphs'].append(p)
sections = [x for x in sections if x['paragraphs']]
json.dump({'id': 'euclid-en', 'title': 'The First Six Books of the Elements of Euclid (ed. John Casey, 1885)', 'lang': 'en',
           'source': '公有领域文本，据 Project Gutenberg #21076 整理（Casey 1885 年版）', 'sections': sections},
          open('/home/claude/moon-myths/texts/euclid-en.json', 'w', encoding='utf-8'), ensure_ascii=False, separators=(',', ':'))
print(len(sections), sum(len(x['paragraphs']) for x in sections)); print([x['title'] for x in sections[:6]], sections[-1]['title'])
print(sections[1]['paragraphs'][:3])
