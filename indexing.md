Building the indexes: Step-by-step guide.

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

4. Now, we index each corpus in PISA, using `block_simdbp` compression.

```
./pisa/build/bin/compress_inverted_index --encoding block_simdbp --collection data/indexes/pisa-canonical/original-u --output data/indexes/pisa-index/original-u.block_simdbp.idx

./pisa/build/bin/compress_inverted_index --encoding block_simdbp --collection data/indexes/pisa-canonical/original-p --output data/indexes/pisa-index/original-p.block_simdbp.idx

./pisa/build/bin/compress_inverted_index --encoding block_simdbp --collection data/indexes/pisa-canonical/deepct-u --output data/indexes/pisa-index/deepct-u.block_simdbp.idx

./pisa/build/bin/compress_inverted_index --encoding block_simdbp --collection data/indexes/pisa-canonical/deepct-p --output data/indexes/pisa-index/deepct-p.block_simdbp.idx

```

5. Create fixed-size wand metadata with blocks of size `40`. 
Note that the BM25 parameters we use for each index differ according to a grid search from Dai and Callan's original paper:

* Original: k1 = 0.82, b = 0.68

* DeepCT: k1 = 8, b = 0.9

```
./pisa/build/bin/create_wand_data --collection data/indexes/pisa-canonical/original-u --output data/indexes/pisa-index/original-u.fixed-40.bm25.bmw --block-size 40 --scorer bm25 --bm25-k1 0.82 --bm25-b 0.68

./pisa/build/bin/create_wand_data --collection data/indexes/pisa-canonical/original-p --output data/indexes/pisa-index/original-p.fixed-40.bm25.bmw --block-size 40 --scorer bm25 --bm25-k1 0.82 --bm25-b 0.68

./pisa/build/bin/create_wand_data --collection data/indexes/pisa-canonical/deepct-u --output data/indexes/pisa-index/deepct-u.fixed-40.bm25.bmw --block-size 40 --scorer bm25 --bm25-k1 8.0 --bm25-b 0.90

./pisa/build/bin/create_wand_data --collection data/indexes/pisa-canonical/deepct-p --output data/indexes/pisa-index/deepct-p.fixed-40.bm25.bmw --block-size 40 --scorer bm25 --bm25-k1 8.0 --bm25-b 0.90

```

6. Build the lexicon for each collection
```
./pisa/build/bin/lexicon build data/indexes/pisa-canonical/original-u.terms data/indexes/pisa-canonical/original-u.termlex

./pisa/build/bin/lexicon build data/indexes/pisa-canonical/original-p.terms data/indexes/pisa-canonical/original-p.termlex

./pisa/build/bin/lexicon build data/indexes/pisa-canonical/deepct-u.terms data/indexes/pisa-canonical/deepct-u.termlex

./pisa/build/bin/lexicon build data/indexes/pisa-canonical/deepct-p.terms data/indexes/pisa-canonical/deepct-p.termlex
```
