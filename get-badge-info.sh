#!/bin/bash

echo "collecting stats for badges"

line_count=`find . -name '*.sh' | sed 's/.*/\"&\"/' | xargs cat | wc -l`

echo "{\"line_count\":\"$line_count\"}" > badges.json