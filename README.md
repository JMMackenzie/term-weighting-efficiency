DeepCT Efficiency Study
=======================

Introduction
------------
This repo shows how to reproduce the experiments from the following SIGIR
short paper: **Efficiency Implications of Term Re-Weighting for Passage Retrieval**
by Joel Mackenzie, Zhuyun Dai, Luke Gallagher, and Jamie Callan.

```
@inproceedings{mdgc20-sigir,
 author = {J. Mackenzie and Z. Dai and L. Gallagher and J. Callan},
 title = {Efficiency Implications of Term Re-Weighting for Passage Retrieval},
 booktitle = {Proc. SIGIR},
 year = {2020},
 pages = {To appear}
}

```
 

Tools
-----
We will use the [PISA](https://github.com/pisa-engine/pisa/) and 
[Anserini](https://github.com/castorini/anserini) search systems to build 
indexes of the MS-Marco DeepCT indexes. Please note that the original DeepCT 
codebase can be found [here](https://github.com/AdeDZY/DeepCT).
We also use the [CIFF](https://github.com/osirrc/ciff) tool for index exchange 
between Anserini and PISA. 

These tools are included automatically as git submodules. You may need to run
`git submodule update --init --recursive` to grab all of the tools and their
dependencies.

Next, we'll build these tools. Refer to the README files in the respective
repositories for detailed instructions.

```
echo "Building PISA"
cd pisa
mkdir build
cd build
cmake ..
make
cd ../../
```

```
echo "Building PISA CIFF"
cd pisa-ciff
cargo build --release
cd ../
```

```
echo "Building Anserini"
cd anserini
mvn clean package appassembler:assemble
cd eval
tar xvfz trec_eval.9.0.4.tar.gz && cd trec_eval.9.0.4 && make
cd ../../../
```

```
echo "Building Anserini-CIFF"
cd anserini-ciff
mvn clean package appassembler:assemble
cd ../
```

Collections
-----------
We have four collections in jsonl format. They are the original MS-Marco corpus
tokenized by BERT, and the DeepCT version (same tokenization process). For each
index, both an 'unpruned' and a 'pruned' version are generated - the pruned
versions remove all postings which DeepCT weighted to zero. 

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

Build Indexes
-------------

1. Create Anserini Indexes for raw collections. We use a single thread since
our input is just one file.

```
sh anserini/target/appassembler/bin/IndexCollection -collection JsonCollection -generator DefaultLuceneDocumentGenerator -threads 1 -input data/raw/original-u/ -index data/indexes/anserini-original-u -optimize

sh anserini/target/appassembler/bin/IndexCollection -collection JsonCollection -generator DefaultLuceneDocumentGenerator -threads 1 -input data/raw/original-p/ -index data/indexes/anserini-original-p -optimize

sh anserini/target/appassembler/bin/IndexCollection -collection JsonCollection -generator DefaultLuceneDocumentGenerator -threads 1 -input data/raw/deepct-u/ -index data/indexes/anserini-deepct-u -optimize

sh anserini/target/appassembler/bin/IndexCollection -collection JsonCollection -generator DefaultLuceneDocumentGenerator -threads 1 -input data/raw/deepct-p/ -index data/indexes/anserini-deepct-p -optimize

```

The `-u` indexes should each contain `8,841,823` documents, and the `-p` indexes should
each contain `8,841,796` documents.

2. Now we'll use the CIFF tool to generate an index exchange blob such that the
PISA system can use the indexes built by Anserini.

```
./anserini-ciff/target/appassembler/bin/ExportAnseriniLuceneIndex -index data/indexes/anserini-original-u -output data/indexes/ciff/original-u.ciff

./anserini-ciff/target/appassembler/bin/ExportAnseriniLuceneIndex -index data/indexes/anserini-original-p -output data/indexes/ciff/original-p.ciff

./anserini-ciff/target/appassembler/bin/ExportAnseriniLuceneIndex -index data/indexes/anserini-deepct-u -output data/indexes/ciff/deepct-u.ciff

./anserini-ciff/target/appassembler/bin/ExportAnseriniLuceneIndex -index data/indexes/anserini-deepct-p -output data/indexes/ciff/deepct-p.ciff
```

3. Next, we convert the `.ciff` indexes into a format that PISA can read.
```
./pisa-ciff/target/release/ciff2pisa --ciff-file data/indexes/ciff/original-u.ciff --output data/indexes/pisa-canonical/original-u
./pisa-ciff/target/release/ciff2pisa --ciff-file data/indexes/ciff/original-p.ciff --output data/indexes/pisa-canonical/original-p
./pisa-ciff/target/release/ciff2pisa --ciff-file data/indexes/ciff/deepct-u.ciff --output data/indexes/pisa-canonical/deepct-u
./pisa-ciff/target/release/ciff2pisa --ciff-file data/indexes/ciff/deepct-p.ciff --output data/indexes/pisa-canonical/deepct-p

```

4. Now, we index each corpus in PISA, using `block_simdbp` compression and fixed-size wand metadata with blocks of size `40`.
