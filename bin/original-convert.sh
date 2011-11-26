#!/bin/bash

umask 000

mkdir -p comments
mkdir hq
mkdir mq
mkdir lq
mkdir thumbs
mkdir zip

cat > .htaccess <<EOF
<Files info.txt>
        deny from all
</Files>
EOF

FILES=$(ls *.jpg *.JPG 2>/dev/null)

counter=1
for file in $FILES; do
    desc=$(sqlite3 $HOME/.shotwell/data/photo.db "SELECT title FROM PhotoTable WHERE filename LIKE \"%$file\";")
    echo "$file: $desc"
    echo "<span>photo ${counter}</span> ${desc}" > comments/${counter}.txt

    newfile=img-${counter}.jpg
    mv $file $newfile

    if [ "$desc" != "" ]; then
        echo "${newfile}: ${desc}" >> comments.txt
    fi

    convert $newfile -resize "x600>" mq/$newfile
    convert $newfile -resize "x480>" lq/$newfile

    convert $newfile -resize "120x120>" thumbs/$newfile

    let counter=$counter+1
done

mv *.jpg hq

#echo "zip: hq"
#zip -q -j zip/hq.zip hq/* comments.txt
#echo "zip: mq"
#zip -q -j zip/mq.zip mq/* comments.txt

rm -f comments.txt

date=$(jhead hq/img-1.jpg | grep Date | cut -d' ' -f 6)
year=$(echo $date | cut -d':' -f 1)
month=$(echo $date | cut -d':' -f 2)
day=$(echo $date | cut -d':' -f 3)

cat > info.txt <<EOF
name|$(basename $(pwd))
date|${day}.${month}.${year}
description|$1
EOF

