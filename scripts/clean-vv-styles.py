import csv, re, sys, collections

TAIL_RE = re.compile(r'\s*The quote\s+[“"].*?[”"]\s+is the unmistakable focal message,\s*not a decorative afterthought\.?', re.S)

# Positive rewrites. Each says what IS wanted; §2.5 — five measured cases in this
# project of a named exclusion producing the thing it excluded.
REWRITES = [
    (re.compile(r'\bavoid clinical colors\.?', re.I),
     'keep the inks warm and grounded.'),
    (re.compile(r'\bavoid decorative clutter\.?', re.I),
     'keep the field clean and uncrowded.'),
    (re.compile(r'Favor warm, restorative contrast without pastel overload\.?', re.I),
     'Favor warm, restorative contrast at full strength.'),
    (re.compile(r'\bAvoid sensational red;\s*', re.I),
     'Keep the red dignified and restrained; '),
    (re.compile(r';?\s*no generic mountains\.?', re.I),
     '; the stable level reads as a specific built place.'),
    (re.compile(r'faint cracks appear only in the background structure, never through the main message',
                re.I),
     'faint cracks appear only in the background structure, while the main message stays unbroken'),
    (re.compile(r'circus ringmaster concept without a person', re.I),
     'circus ringmaster concept built from objects alone'),
    (re.compile(r'attitude without depicting a specific religious figure', re.I),
     'attitude carried entirely by the ledger, the pencil and the rays'),
    (re.compile(r'using abstract impact shapes instead of depicting violence', re.I),
     'using abstract impact shapes to carry the energy'),
    (re.compile(r'while the other path remains at its own level and direction—without being depicted as lower, darker, or inferior',
                re.I),
     'while the other path continues at its own level and direction, drawn with equal weight and clarity'),
    (re.compile(r'courtroom-style evidence board without people', re.I),
     'courtroom-style evidence board built from objects alone'),
    (re.compile(r'spine-and-heart metaphor without anatomy', re.I),
     'spine-and-heart metaphor built from geometry'),
    (re.compile(r'resembling a protective trellis or shield—not barbed wire', re.I),
     'resembling a protective garden trellis or shield'),
    (re.compile(r'decorative lines framing the quote instead of hiding the damage', re.I),
     'decorative lines framing the quote, the mend left visible'),
]

src, dst = sys.argv[1], sys.argv[2]
rows = list(csv.DictReader(open(src)))
hdr = list(rows[0].keys())
stats = collections.Counter()

for r in rows:
    v = r['Visual Elements'] or ''
    nv = TAIL_RE.sub('', v).strip()
    if nv != v:
        stats['tail stripped'] += 1
        r['Visual Elements'] = nv
    for col in ('Visual Elements', 'Color Direction', 'Product / Placement'):
        t = r[col] or ''
        for pat, rep in REWRITES:
            t2 = pat.sub(rep, t)
            if t2 != t:
                stats['negative rewritten'] += 1
                t = t2
        t = re.sub(r'\s{2,}', ' ', t).replace(' ;', ';').strip()
        r[col] = t

with open(dst, 'w', newline='') as f:
    w = csv.DictWriter(f, fieldnames=hdr)
    w.writeheader()
    w.writerows(rows)

for k, v in stats.most_common():
    print('  %-22s %d' % (k, v))
