
'''
BOT ART SCHOOL UPLOADER
Jeff Thompson | 2016 | www.jeffreythompson.org

TO DO:
- use grade? or upload to MTurk from here?

'''

import twitter, os, glob, re, time
from PIL import Image, ImageEnhance

import sys
sys.path.insert(0, 'data')
from OAuthSettings_BOTTEST import settings


# image adjustments
contrast_adjust = 	0.5		# 1 = no change, 0.5 = 50%, 1.5 = 150%
brightness_adjust = 1.5		# ditto
sharpness_adjust = 	1.0		# 0.5 = no change, 0 = blurry, 1 = sharper
output_width = 		900		# twitter image size (px)

# other settings
add_BAS_hashtag = 	True
add_AND_hashtag = 	False

image_path = '/Users/JeffThompson/Pictures/Eyefi/'

cyan = 		'\033[36m'
bold = 		'\033[1m'
reverse = 	'\033[7m'
end = 		'\033[0m'
del_line =  '\x1b[1A' + '\x1b[2K'

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


# input info
print bold + center('Assignment') + end + cyan
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
image_file = min(glob.iglob(path), key=os.path.getctime)
img = Image.open(image_file)
img.save('data/temp.jpg')
print center(image_file) + end + '\n'


# wait to begin processing
# go = raw_input(center('[press any key to set crop points]'))
# print del_line + del_line + end
print center('Cropping image') + cyan


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


# convert to B&W, adjust levels, etc
print bold + center('Correcting levels') + end + cyan
img = Image.open('data/temp.jpg')
img = img.convert('L')
enhancer = ImageEnhance.Contrast(img)
img = enhancer.enhance(contrast_adjust)
enhancer = ImageEnhance.Brightness(img)
img = enhancer.enhance(brightness_adjust)
enhancer = ImageEnhance.Sharpness(img)
img = enhancer.enhance(sharpness_adjust)
print center('contrast: ' + str(contrast_adjust))
print center('brightness: ' + str(brightness_adjust))
print center('sharpness: ' + str(sharpness_adjust)) + end


# save full-res image
# print '\n' + bold + center('Saving full-res image to file') + end + cyan
# output_filename = re.sub(r'\s', '_', assignment)
# output_path = os.path.join(os.path.sep, __location__, 'FinishedAssignments', output_filename + '.jpg')
# img.save(output_path)
# print center('[done]') + end


# resize
# print '\n' + bold + center('Resizing image') + end + cyan
# w, h = img.size														# current image size after cropping
# ratio = float(output_width / float(w))								# ratio of current width to output
# print center('ratio: ' + str(ratio))

# output_height = int((float(h) * ratio))								# set proportional height
# img = img.resize((output_width, output_height), Image.ANTIALIAS)
# print center(str(output_width) + ' x ' + str(output_height) + 'px') + end


# save temp version to upload to Twitter
print '\n' + bold + center('Saving image for Twitter') + end + cyan
twitter_image = os.path.join(os.path.sep, __location__, 'data/temp.jpg')
img.save(twitter_image)
print center('[done]') + end


# format tweet
'''
print '\n' + bold + center('Formatting tweet') + end + cyan
tweet = assignment + '; by '
if handle != '':
	tweet += handle
else:
	tweet += name


# can we fit a hashtag?
# tweet + photo = 125 chars
if add_BAS_hashtag and len(tweet) < 125-14:
	tweet += ' #BotArtSchool'
if add_AND_hashtag and len(tweet) < 125-9:
	tweet += ' #ANDFEST'


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
	status = api.PostMedia(status = tweet, media = output_path)
	print center('[success!]') + end + '\n'
except twitter.TwitterError:
	print '\n' + api.message + end + '\n'
'''

# done!
print '\n' + center('ALL DONE!') + '\n\n'


