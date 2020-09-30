#!/bin/bash

## log creation config
datetime=$(TZ=Australia/Sydney date +%Y%m%d-%H%M%S)      ## date and time format
logfile=./a1_logs/$datetime.log      ## log file name with datetime

## input data retrieval
echo "$datetime: START >> Wikidata extraction" > $logfile
python3 a1_wiki.py $1 $2
samples=(raw_057.ref raw_157.ref)

echo "Data Extraction Done." 
echo "$datetime: CREATED >> raw_057.ref raw_157.ref" >> $logfile
echo "$datetime: DONE >> Wikidata Extraction" >> $logfile

## input data cleaning
echo "$datetime: START >> Input data cleaning" >> $logfile
python3 a1_clean.py ${samples[0]} ${samples[1]}
files=(057 157)

echo "Data Cleaning Done."
echo "$datetime: CREATED >> 057.txt 157.txt" >> $logfile
echo "$datetime: DONE >> Input Data Cleaning" >> $logfile

seg_n=$3

## input data segmentation
segment_index(){
	segment_num=`cat $1.txt | ./segment ./config/dp.config $2`     ## get segmentation boundaries of input file
	segment_num=($segment_num)     ## convert to array
	segment_arr=()                 ## clean segment array

	for index in "${segment_num[@]}"
	do
		segment_arr+=(`echo "$index"| sed 's/[^0-9]*//g'`)         ## remove punctuations in segment array
	done
}

## segmented input file creation and evaluation
segment_file(){
	readarray -t file1_array < $1.txt
	echo '==========' > $1_f.txt
	for line in "${file1_array[@]}"      ## append all tokenize lines to *_f.txt
	do                                   ## which will be used for segment evaluation
        	echo $line >> $1_f.txt       ## and composite file creations
	done
	echo '==========' >> $1_f.txt

	for index in "${segment_arr[@]}"
	do
		sed -i "`expr $index + 1` i ==========" $1_f.txt      ## insert boundary marker after the last line
	done                                                      ## of each segment topic
}

## segment evaluation function
eval_output(){
	eval_out=`./eval ./config/dp.config | tail -1`            ## get segment evaluation average
	eval_out=($eval_out)                                      ## convert to array
	wd_new=${eval_out[1]}
	pk_new=${eval_out[0]}

	if [ $seg_n -eq 2 ]                                       ## evaluate and compare input arguments
	then                                                      ## goal: find best boundary with low ave. scores
		wd_old=$wd_new
		pk_old=$pk_new
		f_seg=$seg_n

		echo "$datetime: UPDATED >> wd_old $wd_old, pk_old $pk_old, $seg_n" >> $logfile
	else
		if [ $(echo "$wd_new<$wd_old" | bc) -eq 1 ]
		then
			wd_old=$wd_new
			pk_old=$pk_new

			echo "$datetime: UPDATED >> wd_old $wd_old, pk_old $pk_old, $seg_n" >> $logfile

			for input in "${files[@]}"
			do
				cp $input\_f.txt $input.ref
				echo "$datetime: UPDATED >> $input.ref" >> $logfile
			done

			f_seg=$seg_n
		elif [ $(echo "$wd_new==$wd_old" | bc) -eq 1 ]
		then
			if [ $(echo "$pk_new<$pk_old" | bc) -eq 1 ]
			then
				 wd_old=$wd_new
				 pk_old=$pk_new
				 
				 echo "$datetime: UPDATE >> wd_old $wd_old, pk_old $pk_old, $seg_n" >> $logfile

				 for input in "${files[@]}"
				 do
					 cp $input\_f.txt $input.refi
					 echo "$datetime: UPDATED >> $input.ref" >> $logfile
				 done

				 f_seg=$seg_n
			 fi
		fi
	fi
}

## composite file creation
composite_create(){
	echo "$datetime: START >> Composite File Creation" >> $logfile

	total_cnt=`grep -in '==========' 057.ref | awk -F':' '{print $1}' | wc -l`     ## get total number of boundaries in input file
	del_1=()
	del_2=()

	for (( x=1; x<=$total_cnt; x++ ))      ## append each topic of input files to array del_1 for input 1, and del_2 for input2
	do
        	del_1+=(`grep -in '==========' 057.ref | awk -F':' '{print $1}' | head -$x | tail -1`)
        	del_2+=(`grep -in '==========' 157.ref | awk -F':' '{print $1}' | head -$x | tail -1`)
	done

	start_1=${del_1[0]}
	start_2=${del_2[0]}

	readarray -t arr_one < 057.ref
	readarray -t arr_two < 157.ref

	i=1

	for y in "${del_1[@]}"      ## alternately append input files segmentation topics to composite file
	do
        	if [ $y == $start_1 ]
        	then
        	        echo "==========" > composite.txt        ## always start with marker
        	else
        	        for (( a=$start_1; a<$y; a++ ))
        	        do
        	                echo ${arr_one[$a]} >> composite.txt
        	        done
        	        start_1=$y
			
        	        for (( b=$start_2; b<=`expr ${del_2[$i]} - 1`; b++ ))
                	do
                        	echo ${arr_two[$b]} >> composite.txt
                	done
                	start_2=${del_2[$i]}
                	i=`expr $i + 1`
        	fi
	done
	echo "$datetime: DONE >> Composite File Creation" >> $logfile
}

## main
for seg_n in {2..10}                 ## number of segmentation boundaries
do
	for input in "${files[@]}"       ## input from a1_clean.py
	do
		echo "$datetime: START >> Segmentation $input; $seg_n boundary" >> $logfile
		segment_index $input $seg_n         
		segment_file $input
		echo "$datetime: DONE >> Segmentation $inpit; $seg_n boundary" >> $logfile
	done
	echo "$datetime: START >> Segment Evaluation of $input, $seg_n boundary" >> $logfile
	eval_output

	echo "$datetime: DONE >> Segmentation Evalutation of $input, $seg_n boundary" >> $logfile
done

## individual files evaluation
echo "Segmentation Done."
echo ""
echo "Number of Segment Boundaries: $f_seg"
echo "Pk Score: $pk_old"
echo "WinDiff Score: $wd_old"

## composite file evaluation
composite_create
echo "Composite File Done: a1_composite.txt"
echo "Evaluating Segmentation with Composite File ..."
echo ""
echo "..."
echo "EVAL:"
./eval_dup ./config/dp.config | tail -3

echo "$datetime: SCRIPT DONE!!" >> $logfile
