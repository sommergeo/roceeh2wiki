# -*- coding: utf-8 -*-
"""
Created on Tue Jul 26 15:41:55 2022

@author: Christian Sommer
"""
import ssl
ssl._create_default_https_context = ssl._create_unverified_context

from SPARQLWrapper import SPARQLWrapper, JSON

# Specify the DBPedia endpoint
sparql = SPARQLWrapper("http://dbpedia.org/sparql")

# Query for the description of "Capsaicin", filtered by language
sparql.setQuery("""
    PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
    SELECT ?comment
    WHERE { <http://dbpedia.org/resource/Capsaicin> rdfs:comment ?comment
    FILTER (LANG(?comment)='en')
    }
""")

# Convert results to JSON format
sparql.setReturnFormat(JSON)
result = sparql.query().convert()

# The return data contains "bindings" (a list of dictionaries)
for hit in result["results"]["bindings"]:
    # We want the "value" attribute of the "comment" field
    print(hit["comment"]["value"])



sparql = SPARQLWrapper("https://www.roceeh.uni-tuebingen.de/road/")
sparql.setQuery("""
    PREFIX road: <https://www.roceeh.uni-tuebingen.de/road/>
    PREFIX wgs84_pos: <https://www.w3.org/2003/01/geo/wgs84_pos#>
    SELECT  ?title ?lon ?lat
    WHERE{
    ?x a road:Locality.
    ?x road:Locality\#id ?title.
    ?x wgs84_pos:long ?lon.
    ?x wgs84_pos:lat ?lat.
     }ORDER BY ?id
""")

sparql.setReturnFormat(JSON)
result = sparql.query().convert()

print(result)
