#!/bin/bash
#
# This script will set up a new version of the dpdoughtroy-com / menu-on-wall-transcription dataset 
# by retrieving the Google Spreadsheet at:
# https://spreadsheets.google.com/spreadsheet/ccc?pli=1&hl=en&key=t7_5xgxUiHibGpbWFPtVQLA&hl=en#gid=0

CSV2RDF4LOD_CONVERT_OMIT_RAW_LAYER=true
google2source.sh -w t7_5xgxUiHibGpbWFPtVQLA auto
