#!/bin/bash
#set -e -x

# This script creates a new PDF from each PDF file with 2x2 pages of the original document on one page.
# The new documents are created in the "nup" subfolder. If the "nup" subfolder does not exist, it will be created.
# There are always 2 variants created: one for duplex printing and one for simplex printing. The respective variants differ in the position of the stapling margin.

FILES=`ls *.pdf`

if [ ! -d "nup" ]
then
	mkdir nup
fi


for FILE in $FILES
do
	FILENAME=${FILE%.pdf}

  pdfjam -q --nup 2x2 --landscape --outfile $FILENAME-nup.pdf $FILENAME.pdf
  
  pdftk $FILENAME-nup.pdf cat 1-endeven output even.pdf
  pdftk $FILENAME-nup.pdf cat 1-endodd output odd.pdf
  
  pdfjam -q --offset '0cm 1.0cm' --scale 0.90 --landscape even.pdf 
  pdfjam -q --offset '0cm -1.0cm' --scale 0.90 --landscape odd.pdf 
  
  pdftk A=even-pdfjam.pdf B=odd-pdfjam.pdf shuffle B A output $FILENAME-duplex.pdf

  pdfjam -q --offset '0cm -1.0cm' --scale 0.90 --landscape $FILENAME-nup.pdf --outfile $FILENAME-simplex.pdf
  
  rm even*.pdf
  rm odd*.pdf
  rm $FILENAME-nup.pdf
done 

mv *-duplex.pdf nup
mv *-simplex.pdf nup
