### script for converting a list of colors into a png

# first pre-process the text colors to binary
cat colors | tr -s ' \n' '\n' | while read hex; do
  printf "%b" "$(echo $hex | sed 's/../\\x&/g')"
done > pixels.rgb

# generate the pixels, 1 pixel per color
magick -size 16x4 -depth 8 rgb:pixels.rgb pixels.png

# scale the pixels so that each color is now 8x8 pixels
magick pixels.png -scale 800% pixels.800.png

# remove meta data from png for cleaner git diffing
pngcrush -rem allb -brute pixels.800.png pixels.800.stripped.png

# move palette png to it's final destination
mv pixels.800.stripped.png ../palette.png

# clean up the files we don't need
rm pixels.*
