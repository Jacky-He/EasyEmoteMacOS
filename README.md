# EasyEmoteMacOS ![badge](https://img.shields.io/badge/cool-project-green)
A very small-scale application that allows users to type emojis almost everywhere in a similar fashion as Discord and Slack. 

### Deployment Target: MacOS 10.15+

# Installation Instruction

### Download File:
Download and decompress the zip file from here: https://github.com/Jacky-He/EasyEmoteMacOS/releases/download/0.0/EasyEmoteMacOS.zip
### Install:
Double click on install.command in the decompressed folder to install EasyEmote.app.

The password it asks for is your computer password.

Note that you might need to go to System Preferences -> Security & Privacy to allow processes to run since this is a third party input method for MacOS mostly for fun and utility.
### Start Using the Input Method:
1. Go to System Preferences -> Keyboard -> Input Sources.

![input sources](https://user-images.githubusercontent.com/39445499/103815050-c1805f00-5030-11eb-98ab-77d4d1c5b427.png)

2. Click on the "+" sign at the bottom left

![add it](https://user-images.githubusercontent.com/39445499/103815065-cb09c700-5030-11eb-9a1e-5e5a28613bdc.png)

3. Add the "Emojis 😃" Input Method under English.

![start  using](https://user-images.githubusercontent.com/39445499/103815076-d2c96b80-5030-11eb-9a96-6e692b768b65.png)

4. Start using the EasyEmote Input Method!

# Demo
![Demo](https://user-images.githubusercontent.com/39445499/103433088-f9168380-4bb8-11eb-990c-f9140c522ecb.gif)

### Note that this is a subsequence search instead of a substring search. For example: "bt" is a subsequence of "bento" while "bt" is not a substring of "bento"

# Credits
Emoji data are retrieved from: https://unicode.org/emoji/charts-13.0/full-emoji-list.html

Additional Library used: [YCML](https://github.com/yconst/YCML) and [FMDB](https://github.com/ccgus/fmdb)

Subsequence Search Data Structure from:

Jain R., Mohania M.K., Prabhakar S. (2013) Efficient Subsequence Search in Databases. In: Wang J., Xiong H., Ishikawa Y., Xu J., Zhou J. (eds) Web-Age Information Management. WAIM 2013. Lecture Notes in Computer Science, vol 7923. Springer, Berlin, Heidelberg. https://doi.org/10.1007/978-3-642-38562-9_45

# Known Issues:
The emojis are currently not subject to customization. Only those representable by Unicode are available. 

The availability is subject to the environment in which the application runs (some emojis will appear as question marks)
