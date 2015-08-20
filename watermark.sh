#!/bin/sh


for f in imgs/*.jpg; do
	image=`basename $f`
	echo $image
	mkdir -p watermarked
	title=`cat imgs/$image.txt`
	width=$(identify -format %w imgs/$image)

	convert -background '#0008' -fill white -gravity center \
		-size ${width}x30 caption:"$title" \
		imgs/$image +swap -gravity north -composite \
		watermarked/$image

done