
'''
BOT ART SCHOOL UPLOADER
Jeff Thompson | 2016 | www.jeffreythompson.org

REQUIRES:
- PIL
- colorcorrect
	https://pypi.python.org/pypi/colorcorrect/0.04
- python-twitter

TO DO:
- use grade? or upload to MTurk from here?

'''

import twitter, os, glob, re, time
from PIL import Image, ImageEnhance
import colorcorrect.algorithm as cca
from colorcorrect.util import from_pil, to_pil

import sys
sys.path.insert(0, 'data')
from OAuthSettings_BOTTEST import settings


# image adjustments
contrast_adjust = 	 1.2		# 1 = no change, 0.5 = 50%, 1.5 = 150%
brightness_adjust =  0.8		# ditto
sharpness_adjust = 	 0.5		# 0.5 = no change, 0 = blurry, 1 = sharper

# other settings
convert_bw = 		 False		# convert image to black and white?
auto_white_balance = False		# auto adj white balance (uses retinex algo)
add_BAS_hashtag = 	 True		# include #BotArtSchool if room
add_AND_hashtag = 	 False		# include #ArtOfBots if room
grade_it =  		 False		# submit to MTurk?

image_path = 		 '../FinishedAssignments/'

cyan = 		 		 '\033[36m'
bold = 		 		 '\033[1m'
reverse = 	 		 '\033[7m'
end = 		 		 '\033[0m'
del_line =   		 '\x1b[1A' + '\x1b[2K'

__location__ = os.path.realpath(os.path.join(os.getcwd(), os.path.dirname(__file__)))


# center align in terminal
def center(s):
	length = len(s)
	width = int(os.popen('stty size', 'r').read().split()[1])
	half = (width - length)/2
	remaining = width - half - length
	return (' ' * half) + s + (' ' * remaining)

# print longer words centered in two lines
def split_center(s):
	words = s.split()
	return center(' '.join(words[:len(words)/2])) + '\n' + center(' '.join(words[len(words)/2:]))


# hello
os.system('cls' if os.name=='nt' else 'clear')
print bold + reverse + center('BOT ART SCHOOL UPLOADER') + end + '\n'


# if assignment has id, load info from that
print bold + center('ID #')
print center('(optional)') + end + cyan
success = False
assign_id = raw_input()
if assign_id != '':
	for line in reversed(open('../AssignmentGenerator/AssignmentsGiven.txt').readlines()):
		line = line.strip()
		data = line.split(',')
		if data[0] == assign_id:
			assignment = data[1]
			name = data[2]
			handle = data[3]
			if len(handle) == 0:
				handle = ''
			success = True
			print del_line + center(assign_id) + end + '\n'
			break


# id found? let's see what we found
if success:
	print bold + center('Assignment') + end + cyan
	if assignment.endswith('.'):
		assignment = assignment[:-1]
	if len(assignment) > 60:
		print split_center(assignment) + end + '\n'
	else:
		print center(assignment) + end + '\n'

	print bold + center('Name')
	print center('(optional)') + end + cyan
	if name != '':
		print center(name) + end + '\n'
	else:
		print center('[none]') + end + '\n'

	print bold + center('Twitter handle')
	print center('(optional)') + end + cyan
	if handle != '' and handle[0] != '@':
		handle = '@' + handle
		print center(handle) + end + '\n'
	else:
		print center('[none]') + end + '\n'

	# does this look right?
	print bold + center('DOES THIS LOOK RIGHT?') + end + cyan
	width = int(os.popen('stty size', 'r').read().split()[1])
	answer = raw_input((' ' * ((width/2)-3)) + 'y/n: ')
	if answer.lower() == 'n':
		success = False
	print (del_line * 3) + end


# no id or not right info? input info manually
else:
	# id not found?
	if assign_id != '':
		print del_line + center(assign_id)
		print center('(ID not found! Please enter manually)') + '\n'

	print end + bold + center('Assignment') + end + cyan
	assignment = raw_input()
	if assignment.endswith('.'):
		assignment = assignment[:-1]
	if len(assignment) > 60:
		print del_line + split_center(assignment) + end + '\n'
	else:
		print del_line + center(assignment) + end + '\n'

	print bold + center('Name')
	print center('(optional)') + end + cyan
	name = raw_input()
	if name != '':
		print del_line + center(name) + end + '\n'
	else:
		print del_line + center('[none]') + end + '\n'

	print bold + center('Twitter handle')
	print center('(optional)') + end + cyan
	handle = raw_input('@')
	if handle != '' and handle[0] != '@':
		handle = '@' + handle
		print del_line + center(handle) + end + '\n'
	else:
		print del_line + center('[none]') + end + '\n'


# get image from file, move to temp space
print bold + center('Loading image') + end + cyan
path = os.path.join(os.path.sep, __location__, image_path, '*.JPG')
image_file = sorted(glob.glob(path))[-1]
# image_file = min(glob.iglob(path), key=os.path.getctime)
img = Image.open(image_file)
img.save('data/temp.jpg')
path, filename = os.path.split(image_file)
print center(image_path + filename) + end + '\n'


# wait to begin processing
# go = raw_input(center('[press any key to set crop points]'))
# print del_line + del_line + end
print center('Cropping/de-skewing image') + cyan


# set crop points with a little Processing app
# then crop and de-skew using ImageMagick
# requires a little hack to wait for 'bbox.txt' to be edited :(
modified = time.ctime(os.path.getmtime('data/bbox.txt'))
created = time.ctime(os.path.getmtime('data/bbox.txt'))
os.system('open data/CropByPoints.app')
while modified == created:
	time.sleep(0.5)
	modified = time.ctime(os.path.getmtime('data/bbox.txt'))

bbox = open('data/bbox.txt').readlines()[0]
cmd = '/opt/local/bin/convert data/temp.jpg -matte -virtual-pixel transparent -distort perspective "' + bbox + '" data/temp.jpg'
print center('working...')
os.system(cmd)
print del_line + center('[done]') + end + '\n'


# convert to B&W, adjust levels, etto_pil(cca.retinex(from_pil(img))).show()c
print bold + center('Correcting levels') + end + cyan
img = Image.open('data/temp.jpg')
if convert_bw:
	img = img.convert('L')
if auto_white_balance:
	img = to_pil(cca.retinex_with_adjust(from_pil(img)))
enhancer = ImageEnhance.Contrast(img)
img = enhancer.enhance(contrast_adjust)
enhancer = ImageEnhance.Brightness(img)
img = enhancer.enhance(brightness_adjust)
enhancer = ImageEnhance.Sharpness(img)
img = enhancer.enhance(sharpness_adjust)
print center('contrast: ' + str(contrast_adjust))
print center('brightness: ' + str(brightness_adjust))
print center('sharpness: ' + str(sharpness_adjust)) + end


# save temp version to upload to Twitter
print '\n' + bold + center('Saving image for Twitter') + end + cyan
twitter_image = os.path.join(os.path.sep, __location__, 'data/temp.jpg')
img.save(twitter_image)
print center('[done]') + end


# format tweet
print '\n' + bold + center('Formatting tweet') + end + cyan
tweet = assignment + '; by '
if handle != '':
	tweet += handle
else:
	tweet += name
# tweet += ' - reply with grade! '


# can we fit a hashtag?
# tweet + photo = 125 chars
if add_BAS_hashtag and len(tweet) < 125-14:
	tweet += ' #BotArtSchool'
if add_AND_hashtag and len(tweet) < 125-9:
	tweet += ' #artofbots'


# print tweet (format for Terminal niceness)
if len(tweet) > 60:
	print split_center(tweet) + end
else:
	print center('"' + tweet + '"') + end


# post to twitter
print '\n' + bold + center('Posting to @artassignbot') + end + cyan
consumer_key = 		  settings['consumer_key']
consumer_secret = 	  settings['consumer_secret']
access_token_key = 	  settings['oauth_token']
access_token_secret = settings['oauth_secret']
try:
	api = twitter.Api(consumer_key = consumer_key, consumer_secret = consumer_secret, access_token_key = access_token_key, access_token_secret = access_token_secret)

	status = api.PostMedia(status = tweet, media = 'data/temp.jpg')
	print center('[success!]') + end + '\n'
except Exception as e:
	print '\n' + str(e) + end + '\n'


# done!
print '\n' + center('ALL DONE!') + '\n\n'


