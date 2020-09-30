** NOTE **
these are the only files needed for the assessment
-----------------------------------------------------

a1_main.sh
------------------
usage:
./a1_main.sh "input1" "input2", (ex. ./a1_main.sh "Sydney" "Nokia")

arguments:
- input1, search input for a1_wiki.py
- input2, search input for a1_wiki.py

output:
- segment evaluation of 057.ref 157.ref input files
- segment evaluation of composite.txt
- composite.txt

executes:
- a1_wiki.py, retrieves data based on the input arguments of a1_main.sh
- a1_clean.py, cleans raw data from a1_wiki.py
- functions which creates and evaluates input files from a1_wiki.py, and create composite.txt

a1_wiki.py
------------------
input:
- input arguments from a1_main.sh

output:
- raw_057.ref, raw data from first argument
- raw_157.ref, raw data from second argument

a1_clean.py
------------------
input:
- raw_057.ref, from a1_wiki.py
- raw_157.ref, from a1_wiki.py

output:
- 057.txt, clean and tokenized raw_057.ref
- 157.txt, clean and tokenized raw_157.ref

-----------------------------------------------------
**NOTE**
configured experiment default files
-----------------------------------------------------

eval
------------------
- evaluates the composite file

eval_dup
------------------
- evaluates the input files 057.ref 157.ref

segment
------------------
- used the command which needs number of segments as argument
- segments input file 057.txt 157.txt 

-----------------------------------------------------
**NOTE**
other files, used for evaluation and monitoring
-----------------------------------------------------

a1_logs
------------------
- contains logs of a1_main execution

057_f.txtx
------------------
- used for segment boundary evaluation and segmentation process

157_f.txtx
------------------
- used for segment boundary evaluation and segmentation process