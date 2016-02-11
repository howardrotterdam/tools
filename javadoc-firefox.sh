#!/bin/sh

if [ ! "$1" ]
then
  echo "Search full path file name which matches all the provided sub-strings for Javadoc jar file stored in ~/ivy2/cache and open a clickable list in Firefox.
Usage: $0 <case insensitive sub-string of the file name> ...
Suitable for MacOS only.
"
  exit 1
fi

DIR=~/.ivy2/cache
TMPD=/tmp/jdff
mkdir -p $TMPD
TMPF=$TMPD/$$

find $DIR -iname '*-javadoc.jar' >$TMPF
for PAT in "$@"
do
  fgrep -i "$PAT" <$TMPF >$TMPF.1 && mv $TMPF.1 $TMPF
done

echo "javadoc.jar files matching \"$@\" found in ~/.ivy2/cache/
<ol>" > $TMPF.htm

cat $TMPF |
while read JAR
do
  cat >>$TMPF.htm <<EOF
<li><a href="jar:file://$JAR!/index.html">${JAR##*/.ivy2/cache/}</a></li>
EOF
done

echo "</ol>" >> $TMPF.htm

osascript -e "tell application \"Firefox\"" -e "activate" -e "open location \"file://$TMPF.htm\"" -e "end tell"

# clean up old temp files not access recently
find $TMPD -atime +1h -delete

# open -a Firefox --args "jar:file://$1!/index.html"
# This command is not stable.  Firefox is only able to open the URL at first time.
