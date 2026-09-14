import zipfile, xml.etree.ElementTree as ET, csv, re, sys, os
NS='{http://schemas.openxmlformats.org/spreadsheetml/2006/main}'
RNS='{http://schemas.openxmlformats.org/officeDocument/2006/relationships}'
def colnum(ref):
    c=re.match(r'([A-Z]+)',ref).group(1); n=0
    for ch in c: n=n*26+ord(ch)-64
    return n-1
def extract(path, outdir):
    os.makedirs(outdir, exist_ok=True)
    z=zipfile.ZipFile(path); shared=[]
    if 'xl/sharedStrings.xml' in z.namelist():
        for si in ET.fromstring(z.read('xl/sharedStrings.xml')).iter(NS+'si'):
            shared.append(''.join(t.text or '' for t in si.iter(NS+'t')))
    wb=ET.fromstring(z.read('xl/workbook.xml'))
    rels={r.get('Id'):r.get('Target') for r in ET.fromstring(z.read('xl/_rels/workbook.xml.rels'))}
    names=[]
    for s in wb.iter(NS+'sheet'):
        name=s.get('name'); t=rels[s.get(RNS+'id')].lstrip('/')
        if not t.startswith('xl/'): t='xl/'+t
        root=ET.fromstring(z.read(t)); rows=[]
        for row in root.iter(NS+'row'):
            cells={}
            for c in row.iter(NS+'c'):
                v=c.find(NS+'v'); isel=c.find(NS+'is')
                if c.get('t')=='s' and v is not None: val=shared[int(v.text)]
                elif isel is not None: val=''.join(x.text or '' for x in isel.iter(NS+'t'))
                elif v is not None: val=v.text
                else: continue
                cells[colnum(c.get('r'))]=(val or '').strip()
            if cells: rows.append([cells.get(i,'') for i in range(max(cells)+1)])
        w=max((len(r) for r in rows), default=0)
        with open(os.path.join(outdir,name+'.csv'),'w',newline='') as f:
            wr=csv.writer(f)
            for r in rows: wr.writerow(r+['']*(w-len(r)))
        names.append((name,len(rows)))
    return names
if __name__=='__main__':
    for n,r in extract(sys.argv[1], sys.argv[2]): print(f'   {n:36s} {r:4d}')
