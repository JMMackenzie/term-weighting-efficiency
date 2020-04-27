#!/bin/bash

echo "Running query processing across each collection for both stopped and unstopped query logs..."

for collection in original-u original-p deepct-u deepct-p; do

  for query in unstopped stopped; do
  
    if [ "$collection" == "original-u" ] || [ "$collection" == "original-p" ]; then
      ./pisa/build/bin/evaluate_queries --encoding block_simdbp \
                                        --index data/indexes/pisa-index/$collection".block_simdbp.idx" \
                                        --wand data/indexes/pisa-index/$collection.fixed-40.bm25.bmw \
                                        --terms data/indexes/pisa-canonical/$collection.termlex \
                                        --documents data/indexes/pisa-canonical/$collection.docmap \
                                        --algorithm block_max_wand \
                                        -k 1000 \
                                        --queries data/queries/$query".qry" \
                                        --scorer bm25 \
                                        --bm25-k1 0.82 \
                                        --bm25-b 0.68 \
                                        --run "$collection-$query" > evaluate/run-files/$collection"_"$query".trec"

    elif [ "$collection" == "deepct-u" ] || [ "$collection" == "deepct-p" ]; then
      ./pisa/build/bin/evaluate_queries --encoding block_simdbp \
                                        --index data/indexes/pisa-index/$collection".block_simdbp.idx" \
                                        --wand data/indexes/pisa-index/$collection.fixed-40.bm25.bmw \
                                        --terms data/indexes/pisa-canonical/$collection.termlex \
                                        --documents data/indexes/pisa-canonical/$collection.docmap \
                                        --algorithm block_max_wand \
                                        -k 1000 \
                                        --queries data/queries/$query".qry" \
                                        --scorer bm25 \
                                        --bm25-k1 8.0 \
                                        --bm25-b 0.90 \
                                        --run "$collection-$query" > evaluate/run-files/$collection"_"$query".trec"
    fi

    done
done

echo "Done."
