#!/bin/bash

#!/bin/bash
#
#3> <> prov:specializationOf <https://github.com/timrdf/csv2rdf4lod-automation/blob/master/bin/cr-retrieve.sh> ;
#3>    prov:wasRevisionOf    <https://github.com/timrdf/csv2rdf4lod-automation/blob/master/bin/cr-publish-cockpit.sh> .

if [[ "$1" == "--help" || "$1" == "-h" || $# != 1 ]]; then
   echo "usage: `basename $0` <distribution-url>"
   echo "  Create publish/bin/publish.sh and invoke for every conversion cockpit within the current directory tree."
   #cho "                -w : Avoid dryrun; do it. If not provided, will only dry run."
   #echo "  --skip-if-exists : If a version exists for the dataset, do not retrieve it."
   exit 1
fi

see='https://github.com/timrdf/csv2rdf4lod-automation/wiki/CSV2RDF4LOD-not-set'
CSV2RDF4LOD_HOME=${CSV2RDF4LOD_HOME:?"not set; source csv2rdf4lod/source-me.sh or see $see"}

# cr:data-root cr:source cr:directory-of-datasets cr:dataset cr:directory-of-versions cr:conversion-cockpit
ACCEPTABLE_PWDs="cr:dataset cr:directory-of-versions"
if [ `${CSV2RDF4LOD_HOME}/bin/util/is-pwd-a.sh $ACCEPTABLE_PWDs` != "yes" ]; then
   ${CSV2RDF4LOD_HOME}/bin/util/pwd-not-a.sh $ACCEPTABLE_PWDs
   exit 1
fi

if   [[ `is-pwd-a.sh cr:conversion-cockpit` == "yes" ]]; then

   echo "Possible, but not designed and not implemented."

elif [[ `is-pwd-a.sh                                                 cr:dataset cr:directory-of-versions` == "yes" ]]; then

   DIST_URL="$1"
   UUID=`$CSV2RDF4LOD_HOME/bin/util/resource-name.sh | sed 's/^_//' | awk '{print tolower($0)}'`

   echo "@prefix rdfs:       <http://www.w3.org/2000/01/rdf-schema#> ."                > dcat.ttl
   echo "@prefix conversion: <http://purl.org/twc/vocab/conversion/> ."               >> dcat.ttl
   echo "@prefix dcat:       <http://www.w3.org/ns/dcat#> ."                          >> dcat.ttl
   echo "@prefix void:       <http://rdfs.org/ns/void#> ."                            >> dcat.ttl
   echo "@prefix prov:       <http://www.w3.org/ns/prov#> ."                          >> dcat.ttl
   echo "@prefix datafaqs:   <http://purl.org/twc/vocab/datafaqs#> ."                 >> dcat.ttl
   echo "@prefix :           <$CSV2RDF4LOD_BASE_URI/id/> ."                           >> dcat.ttl
   echo                                                                               >> dcat.ttl
   echo "<$CSV2RDF4LOD_BASE_URI/source/`cr-source-id.sh`/dataset/`cr-dataset-id.sh`>" >> dcat.ttl
   echo "   a void:Dataset, dcat:Dataset;"                                            >> dcat.ttl
   echo "   conversion:source_identifier  \"`cr-source-id.sh`\";"                     >> dcat.ttl
   echo "   conversion:dataset_identifier \"`cr-dataset-id.sh`\";"                    >> dcat.ttl
   echo "   prov:wasDerivedFrom :download_$UUID;"                                     >> dcat.ttl
   echo "."                                                                           >> dcat.ttl
   echo                                                                               >> dcat.ttl
   echo ":download_$UUID"                                                             >> dcat.ttl
   echo "   a dcat:Distribution;"                                                     >> dcat.ttl
   echo "   dcat:downloadURL <$DIST_URL>;"                                            >> dcat.ttl
   echo "."                                                                           >> dcat.ttl
   echo                                                                               >> dcat.ttl
   echo "<dataset/$UUID>"                                                             >> dcat.ttl
   echo "   a dcat:Dataset;"                                                          >> dcat.ttl
   echo "   dcat:distribution :download_$UUID;"                                       >> dcat.ttl
   echo "."                                                                           >> dcat.ttl

elif [[ `is-pwd-a.sh                        cr:directory-of-datasets                                    ` == "yes" ]]; then
   for next in `directories.sh`; do
      pushd $next > /dev/null
         $0 $* # Recursive call
      popd > /dev/null
   done
elif [[ `is-pwd-a.sh              cr:source                                                             ` == "yes" ]]; then
   if [ -d dataset ]; then
      # This would conform to the directory structure if 
      # we had included 'dataset' in the convention.
      # This is here in case we ever fully support it.
      pushd dataset > /dev/null
         $0 $* # Recursive call
      popd > /dev/null
   else
      # Handle the original (3-year old) directory structure 
      # that does not include 'dataset' as a directory.
      for dataset in `cr-list-datasets.sh`; do
         pushd $dataset > /dev/null
            $0 $* # Recursive call
         popd > /dev/null
      done
   fi
elif [[ `is-pwd-a.sh cr:data-root                                                                       ` == "yes" ]]; then
   for sourceID in `cr-list-sources.sh`; do
      pushd $sourceID > /dev/null
         $0 $* # Recursive call
      popd > /dev/null
   done
fi

