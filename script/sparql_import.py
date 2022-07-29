# -*- coding: utf-8 -*-
"""
Created on Tue Jul 26 15:41:55 2022

@author: Christian Sommer
"""
import sparql_dataframe

def road_query(culture):

    endpoint = "http://www.roceeh.uni-tuebingen.de:3030/road/query"
    q = '''
        PREFIX road: <https://www.roceeh.uni-tuebingen.de/road/>
        PREFIX wgs84_pos: <https://www.w3.org/2003/01/geo/wgs84_pos#>
        
        SELECT  DISTINCT (?culture) ?title ?lon ?lat
        WHERE {
          ?x a road:ArchaeologicalLayer.
          ?x road:ArchaeologicalLayer\#archstratigraphyIdArchstrat "'''+culture+'''".
          ?x road:ArchaeologicalLayer\#localityId ?title.
          ?y a road:Locality.
          ?y road:Locality\#id ?title.
          ?y wgs84_pos:long ?lon.
          ?y wgs84_pos:lat ?lat.
        } ORDER BY ?title
    '''
    df = sparql_dataframe.get(endpoint, q)
    return df

#x = road_query("Uluzzian")


# =============================================================================
# ALTERNATIVE with SPARQLWrapper 
# from SPARQLWrapper import SPARQLWrapper, JSON
# from pandas.io.json import json_normalize
# 
# 
# sparql = SPARQLWrapper("http://www.roceeh.uni-tuebingen.de:3030/road/query") # URI must be http! https://stackoverflow.com/questions/65516325/ssl-wrong-version-number-on-python-request
# sparql.setQuery("""
#     PREFIX road: <https://www.roceeh.uni-tuebingen.de/road/>
#     PREFIX wgs84_pos: <https://www.w3.org/2003/01/geo/wgs84_pos#>
#     
#     SELECT  DISTINCT (?culture) ?title ?lon ?lat
#     WHERE {
#       ?x a road:ArchaeologicalLayer.
#       ?x road:ArchaeologicalLayer\#archstratigraphyIdArchstrat "Uluzzian".
#       ?x road:ArchaeologicalLayer\#localityId ?title.
#       ?y a road:Locality.
#       ?y road:Locality\#id ?title.
#       ?y wgs84_pos:long ?lon.
#       ?y wgs84_pos:lat ?lat.
#     } ORDER BY ?title
#     """)
# 
# sparql.setReturnFormat(JSON)
# result = sparql.query().convert()
# 
# 
# 
#  try:
#      ret = sparql.queryAndConvert()
#  
#      for r in ret["results"]["bindings"]:
#          print(r)
#  except Exception as e:
#      print(e)
# 
#     
#     
# df = json_normalize(result["results"]["bindings"])
# =============================================================================