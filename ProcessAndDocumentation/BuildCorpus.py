# -*- coding: utf-8 -*-

import os, re
from bs4 import BeautifulSoup
from markdown import markdown
from html2text import html2text

# prevent unicode sadness
import sys
reload(sys)
sys.setdefaultencoding('utf-8')

# get list of all html files
print 'loading list of html files...'
html = []
for root, dirs, files in os.walk('.'):
	for name in files:
		html.append(os.path.join(root, name))

# load up all text
print 'gathering text..'
all_html = ''
for i, file in enumerate(html):
	print '- ' + str(i+1) + '/' + str(len(html))
	try:
		with open(file) as f:
			h = f.read()
			h.encode('utf-8')
			
			# strip js
			soup = BeautifulSoup(h)
			for script in soup.find_all('script'):
				script.extract()

			# get text from html, strip tags
			s = str(soup)
			s = html2text(s)
			s = markdown(s)
			s = re.sub(r'<.*?>', '', s)
			all_html += s + '\n'
	except:
		print '  - error reading, skipping this one...'

# save to file
print 'saving to file...'
with open('artschool.txt', 'w') as f:
	f.write(all_html)

print 'DONE!'

