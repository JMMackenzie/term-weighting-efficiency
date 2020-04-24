Preparing the Data
------------------

Download and validate the data.
```
wget http://boston.lti.cs.cmu.edu/appendices/arXiv2019-DeepCT-Zhuyun-Dai/weighted_documents/corrected_org_collection_berttoken.zip -O data/raw/original-u.zip

wget http://boston.lti.cs.cmu.edu/appendices/arXiv2019-DeepCT-Zhuyun-Dai/weighted_documents/corrected_sample_100_keepall_jsonl.zip -O data/raw/deepct-u.zip

wget http://boston.lti.cs.cmu.edu/appendices/arXiv2019-DeepCT-Zhuyun-Dai/weighted_documents/sample_100_jsonl.zip -O data/raw/deepct-p.zip

md5sum data/raw/original-u.zip
dd98a257270feb0ed34ae69606be7c98  data/raw/original-u.zip

md5sum data/raw/deepct-u.zip
261e7e98e7c0162bbe9eb6fd232a02f9  data/raw/deepct-u.zip

md5sum data/raw/deepct-p.zip
6d44db3b576f3ab4ed09990be490defd  data/raw/deepct-p.zip

```

Unpack and prepare the data.
```
cd data/raw/

unzip original-u.zip
cat org_collection_berttoken/1.json org_collection_berttoken/2.json > original-u/original-u.json

unzip deepct-u.zip
cat sample_100_keepall_jsonl_new/1.json sample_100_keepall_jsonl_new/2.json > deepct-u/deepct-u.json

unzip deepct-p.zip
cat sample_100_jsonl/docs00.json sample_100_jsonl/docs01.json sample_100_jsonl/docs02.json sample_100_jsonl/docs03.json sample_100_jsonl/docs04.json sample_100_jsonl/docs05.json sample_100_jsonl/docs06.json sample_100_jsonl/docs07.json sample_100_jsonl/docs08.json > deepct-p/deepct-p.json

md5sum original-u/original-u.json
2a9d315da238f947d2eb4db8bbbf058e  original/original-u.json

md5sum deepct-u/deepct-u.json
16ad6f86d99dd0b822950a6731513213  deepct-u/deepct-u.json

ms5sum deepct-p/deepct-p.json
0ad6965434d72ead8256bfdec25fa65e  deepct-p/deepct-p.json

```

Now, we can generate the original-pruned index from the original-unpruned and
the deepct-pruned collections. This takes around 10-15 minutes to run on a modern
server.
```
python3 ../../tools/prune-original.py deepct-p/deepct-p.json original-u/original-u.json original-p/original-p.json

md5sum original-p/original-p.json
b856c62ebc10fae5c9a1b5eea8f0c27e  original-p/original-p.json

cd ../../
```


