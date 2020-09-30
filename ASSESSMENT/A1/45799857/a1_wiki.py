import re
import argparse
import wikipedia

## parser
parser = argparse.ArgumentParser()
parser.add_argument('input1', help = 'input first search in wikipedia', type = str)
parser.add_argument('input2', help = 'input second search in wikipedia', type = str)
args = parser.parse_args()

## array of files
search_list = [args.input1, args.input2]
search_file = ["raw_057.ref", "raw_157.ref"]

## wiki data retrieval function
def search(search_name):
    for x in search_name:
        page = wikipedia.page(x)      ## access wiki page of each input argument
        info = page.content           ## get content from wikipedia

        if x == args.input1:          ## write raw data in raw_057.ref
            file = search_file[0]
            with open(file, 'w') as filehandle:
                filehandle.write('%s\n' % info)
        else:
            file = search_file[1]     ## write raw data in raw_057.ref
            with open(file, 'w') as filehandle:
                filehandle.write('%s\n' % info)

search(search_list)     ## execute function for data retrieval
