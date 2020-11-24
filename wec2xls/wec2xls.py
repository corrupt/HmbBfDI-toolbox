import ndjson
import sys
import os
import xlsxwriter
from urllib.parse import urlparse
from datetime import datetime
from dateutil.parser import parse

infile = ''
outfile = ''
row_offset = 3
title_set = False

if len(sys.argv) < 2:
    sys.exit(f'usage: {sys.argv[0]} <input file> [<output file]')
else:
    infile = os.path.abspath(sys.argv[1])
    try:
        assert os.path.isfile(infile)
    except AssertionError:
        sys.exit(f'usage: {sys.argv[0]} <input file> [<output file]')
if len(sys.argv) < 3:
    outfile = f'{os.path.splitext(infile)[0]}.xlsx'
else:
    outfile = os.path.abspath(sys.argv[2])

with open(infile) as f:
    data = ndjson.load(f)

    wb = xlsxwriter.Workbook(outfile)
    tr = wb.add_worksheet('Tracking Requests')

    f_bold = wb.add_format({'bold': True})
    tr.write_string(row_offset-1, 0, "Domain", f_bold)
    tr.write_string(row_offset-1, 1, "URLs", f_bold)
    tr.write_string(row_offset-1, 2, "Datenschutzerklärung?", f_bold)
    tr.write_string(row_offset-1, 3, "Anbieterin", f_bold)

    urls = dict()
    maxlength = [0, 0]
    for d in data:
        if 'type' in d and d['type'] == 'Browser':
            if 'level' in d and d['level'] == 'info':
                if not title_set:
                    if 'message' in d and d['message'].startswith('browsing now to '):
                        f_header = wb.add_format({
                            'font_size': 16,
                            'valign': 'vcenter',
                            })
                        m = d['message']
                        url = m[m.find("browsing now to ")+16:]
                        date = parse(timestr=d['timestamp'])

                        title = [f_bold, 'Website:', f' {url}\n', f_bold, 'Zeitpunkt:', f' {date.strftime("%d.%m.%Y %H:%M")}']
                        tr.merge_range(0, 0, row_offset-2, 3, '')
                        tr.write_rich_string(0, 0, f_bold, 'Website:', f' {url}\n', f_bold, 'Zeitpunkt:', f' {date.strftime("%d.%m.%Y %H:%M")}', f_header)
                        tr.set_row(0,50,f_header)
                        title_set = True

        if 'type' in d and d['type'] == 'Request.Tracking':
            u = urlparse(d['data']['url'])
            u_split = u.netloc.split('.')
            u_base = f'{u_split[len(u_split)-2]}.{u_split[len(u_split)-1]}'
            maxlength[0] = len(u_base) if len(u_base) > maxlength[0] else maxlength[0]
            if u_base not in urls:
                urls[u_base] = set()
            urls[u_base].add(f'{u.scheme}://{u.netloc}{u.path}')

    f_good = wb.add_format({
        'bg_color': '#ccffcc',
        'fg_color': '#006600',
        'top': 1,
        'bottom': 1,
    })
    f_bad = wb.add_format({
        'bg_color': '#ffcccc',
        'fg_color': '#cc0000',
        'top': 1,
        'bottom': 1,
    })

    for i,u in enumerate(urls):
        f = wb.add_format({
            'text_wrap': True,
            'align': 'vjustify'
        })
        c = wb.add_format({
            'align': 'center',
            'align': 'vcenter',
        })

        row = i+row_offset

        tr.write_url(row,0,u, f.set_align('vcenter'))
        tr.conditional_format(row, 0, row, 2, {'type': 'formula',
                                     'criteria': f'=$C${row+1}="nein"',
                                     'format': f_bad
                                    })
        tr.conditional_format(row, 0, row, 2, {'type': 'formula',
                                     'criteria': f'=$C${row+1}="ja"',
                                     'format': f_good
                                    })
        cell = ''
        rows = 0
        for l in urls[u]:
            cell += f'{l}\n'
        maxlength[1] = len(l) if len(l) > maxlength[1] else maxlength[1]
        tr.write_string(row, 1, cell, f)
        tr.write_string(row, 2, 'nein', c)
        #if len(urls[u]) > 1:
        #    tr.set_row(row, len(urls[u])*14) #15 is default row height

    tr.data_validation(row_offset, 2, row_offset+len(urls)-1, 2, {'validate': 'list', 'source': ['nein', 'ja']})

    tr.set_column(0, 0, maxlength[0])
    tr.set_column(1, 1, maxlength[0]*2)
    tr.set_column(2, 2, len("Datenschutzerklärung"))
    tr.set_column(3, 3, len("Datenschutzerklärung"))

    wb.close()
