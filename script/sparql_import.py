# -*- coding: utf-8 -*-
"""
Created on Tue Jul 26 15:41:55 2022

@author: Christian Sommer
"""
from SPARQLWrapper import SPARQLWrapper, JSON

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

try:
    ret = sparql.queryAndConvert()

    for r in ret["results"]["bindings"]:
        print(r)
except Exception as e:
    print(e)
    
    
