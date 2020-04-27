#!/bin/bash

echo "Grabbing the data from CMU..."
wget http://boston.lti.cs.cmu.edu/appendices/arXiv2019-DeepCT-Zhuyun-Dai/weighted_documents/corrected_org_collection_berttoken.zip -O data/raw/original-u.zip
wget http://boston.lti.cs.cmu.edu/appendices/arXiv2019-DeepCT-Zhuyun-Dai/weighted_documents/corrected_sample_100_keepall_jsonl.zip -O data/raw/deepct-u.zip
wget http://boston.lti.cs.cmu.edu/appendices/arXiv2019-DeepCT-Zhuyun-Dai/weighted_documents/sample_100_jsonl.zip -O data/raw/deepct-p.zip
echo "Done."

echo "Validating MD5 hashes..."
for file in original-u deepct-u deepct-p; do
  if md5sum -c data/raw/$file'.zip.md5'; then
    echo "$file is OK..."
  else
    echo "Error: data/raw/$file.zip is corrupt. Exiting."
    exit 1
  fi

done
echo "Done."

echo "Unpacking data and preparing json files..."
cd data/raw/
unzip original-u.zip
cat org_collection_berttoken/1.json org_collection_berttoken/2.json > original-u/original-u.json

unzip deepct-u.zip
cat sample_100_keepall_jsonl_new/1.json sample_100_keepall_jsonl_new/2.json > deepct-u/deepct-u.json

unzip deepct-p.zip
cat sample_100_jsonl/docs00.json sample_100_jsonl/docs01.json sample_100_jsonl/docs02.json sample_100_jsonl/docs03.json sample_100_jsonl/docs04.json sample_100_jsonl/docs05.json sample_100_jsonl/docs06.json sample_100_jsonl/docs07.json sample_100_jsonl/docs08.json > deepct-p/deepct-p.json
echo "Done."

echo "Building original-p json data via Python tool..."
python3 ../../tools/prune-original.py deepct-p/deepct-p.json original-u/original-u.json original-p/original-p.json

cd ../../

echo "All done..."

