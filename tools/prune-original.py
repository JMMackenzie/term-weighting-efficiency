#!/usr/env/python3

import json
import sys


def usage():
  print(sys.argv[0] + " <deepct-p.json> <original-u.json> <output_file>")

def convert_to_unicode(text):
  """Converts `text` to Unicode (if it's not already), assuming utf-8 input."""
  if isinstance(text, str):
    return text
  elif isinstance(text, bytes):
    return text.decode("utf-8", "ignore")
  else:
    raise ValueError("Unsupported string type: %s" % (type(text)))

# Check args
if len(sys.argv) != 4:
  usage()
  sys.exit(1)

outfile = open(sys.argv[3], 'w', encoding='utf-8')

# A dictionary for storing the vocab of each document
doc_term_dict = {}

print("Reading the pruned collection and building a vocabulary for each document...")
# Read the pruned vocab for each document 
with open(sys.argv[1], 'r', encoding='utf-8') as f:
  for line in f:
    data = json.loads(line)
    docid = str(data["id"])
    contents = convert_to_unicode(data["contents"])
    for term in contents.split():
      try:  
        doc_term_dict[docid].add(term)
      except KeyError:
        doc_term_dict[docid] = {term}

print("Done.")

print("Reading the original collection and outputting a pruned version...")
# Read the original collection file, and write out the pruned version.
with open(sys.argv[2], 'r', encoding='utf-8') as f:
  for line in f:
    data = json.loads(line.strip())
    docid = str(data["id"])
    # Document was totally pruned
    if docid not in doc_term_dict:
      continue
    out = ""
    contents = convert_to_unicode(data["contents"])
    for term in contents.split():
      if term in doc_term_dict[docid]:
        out += term + " "

    outfile.write(json.dumps({"id": docid, "contents" : out.strip()}))
    outfile.write("\n")
     
print("Done.")
