#!/bin/bash

find reports -mindepth 1 -delete
echo 'Old reports deleted'

mkdir -p reports && echo {} > reports/report.json
echo 'Report created'
ls -la reports
echo 'Listing reports directory:'
du -sh reports
echo 'Size of reports directory:'
file reports/report.json

echo 'Report file type checked'
