from nltk.tokenize import sent_tokenize
import re
import argparse

## parser
parser = argparse.ArgumentParser()
parser.add_argument('input1', help = 'input first text file filename (eg. input.txt)', type = str)
parser.add_argument('input2', help = 'input second text file filename (eg. input.txt)', type = str)
args = parser.parse_args()

## array of files
input_file = [args.input1, args.input2]
new_file = ["057.txt", "157.txt"]

## data cleaning function
def cleaner(input):
    for x in input:     ## input = raw file, loop
        with open(x, 'r') as file:           ## read content of raw input    
            content = file.read()           

        content = sent_tokenize(content)     ## tokenize content per sentence
        
        if len(content) > 300:               ## get only first 300 lines of tokenize raw file
            content = content[0:300]

        for i in range(0, len(content)):
            content[i] = re.sub(r'[^\w\s]', '', content[i])     ## remove puntations and numbers per line

        if x == args.input1:                 ## write clean data to 057.txt
            file = new_file[0]
            with open(file, 'w') as filehandle:
                for listitem in content:
                    filehandle.write('%s\n' % listitem)
        else:
            file = new_file[1]               ## write clean data to 157.txt
            with open(file, 'w') as filehandle:
                for listitem in content:
                    filehandle.write('%s\n' % listitem)

    for y in new_file:                       ## remove empty lines in each input file
        with open(y) as filehandle:
            line = filehandle.readlines()
        with open(y, 'w') as filehandle:
            line = filter(lambda x: x.strip(), line)
            filehandle.writelines(line)

cleaner(input_file)     ## execute function for data cleaning
