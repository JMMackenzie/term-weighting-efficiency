#!/bin/bash

for collection in original-u original-p deepct-u deepct-p; do
  echo "Building Anserini index for $collection"
  sh anserini/target/appassembler/bin/IndexCollection -collection JsonCollection -generator DefaultLuceneDocumentGenerator -threads 1 -input data/raw/$collection/ -index data/indexes/anserini-$collection -optimize
  echo "Done."

  echo "Converting Anserini/Lucene index to CIFF index..."
  ./anserini-ciff/target/appassembler/bin/ExportAnseriniLuceneIndex -index data/indexes/anserini-$collection -output data/indexes/ciff/$collection.ciff
  echo "Done."

  echo "Converting CIFF to PISA format..."
  ./pisa-ciff/target/release/ciff2pisa --ciff-file data/indexes/ciff/$collection.ciff --output data/indexes/pisa-canonical/$collection
  echo "Done."

  echo "Building PISA index with block_simdbp compression..."
  ./pisa/build/bin/compress_inverted_index --encoding block_simdbp --collection data/indexes/pisa-canonical/$collection --output data/indexes/pisa-index/$collection.block_simdbp.idx
  echo "Done."

  echo "Building WAND data for $collection..."
  if [ "$collection" == "original-u" ] || [ "$collection" == "original-p" ]; then
    ./pisa/build/bin/create_wand_data --collection data/indexes/pisa-canonical/$collection \
                                      --output data/indexes/pisa-index/$collection.fixed-40.bm25.bmw \
                                      --block-size 40 \
                                      --scorer bm25 \
                                      --bm25-k1 0.82 \
                                      --bm25-b 0.68

  elif [ "$collection" == "deepct-u" ] || [ "$collection" == "deepct-p" ]; then
    ./pisa/build/bin/create_wand_data --collection data/indexes/pisa-canonical/$collection \
                                      --output data/indexes/pisa-index/$collection.fixed-40.bm25.bmw \
                                      --block-size 40 \
                                      --scorer bm25 \
                                      --bm25-k1 8.0 \
                                      --bm25-b 0.90

  else
    echo "Error: Unexpected collection name. Exiting."
    exit 1
  fi
 
  echo "Building the term lexicon..."
  ./pisa/build/bin/lexicon build data/indexes/pisa-canonical/$collection.terms data/indexes/pisa-canonical/$collection.termlex
  echo "Done."

  echo "Building the document identifier map..."
  ./pisa/build/bin/lexicon build data/indexes/pisa-canonical/$collection.documents data/indexes/pisa-canonical/$collection.docmap
  echo "Done."

done



