# -*- coding: utf-8 -*-
"""
Created on Fri Jul 29 14:42:30 2022

@author: Christian Sommer
"""
import pandas as pd
import sparql_dataframe
import geopandas
import json
import os

path = r'C:\data\git\mid-pleistocene-niches\roceeh2wiki'

# query geodata from ROAD's SPARQL endpoint and export as table
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
    df["description"] = '[https://www.roceeh.uni-tuebingen.de/roadweb/tcpdf/localityInfoPDF/localityInfoPDF.php?locality=' + df.title.str.replace(' ', '%20') +' Summary Data Sheet]'
    return df

# transform table to 
def wiki_json(df, commons_description):
    # Head of JSON
    commons_license = "CC-BY-SA-4.0"
    commons_source = "Data retrieved from the [https://www.roceeh.uni-tuebingen.de/roadweb ROCEEH Out Of Africa Database (ROAD)]."

    # Geodata JSON
    df = df.round({'lon': 2, 'lat': 2})
    gdf = geopandas.GeoDataFrame(
        df[['title','description']], geometry=geopandas.points_from_xy(df.lon, df.lat), crs='EPSG:4326')

    geojson = gdf.to_json(drop_id=True)
    geojson = json.loads(geojson)

    geojson['crs']={
        "type": "name",
        "properties": {
            "name": "urn:ogc:def:crs:OGC:1.3:CRS84"
        }
    }

    # Merge head and geodata
    wikidict = {
        "license": commons_license,
        "description": commons_description,
        "sources": commons_source,
        "data": geojson
    }
    wikistring = json.dumps(wikidict, ensure_ascii=False, indent=4)
    return wikistring


clist = pd.read_excel (path+'\data\wiki_cultures.xlsx')
clist = clist.query('use=="T"') # Exlude unused rows


for i,j in clist.iterrows():
    fname = os.path.join(path, 'output', j.road_culture+'.txt')     # create output path and filename
    print(j.enwiki_title, i, fname)
    x = wiki_json(road_query(j.road_culture), j.description)        # query from ROAD and paste to wiki-style json
    with open(fname,'w') as f:                                      # write each culture to an individual file
        f.write(x)
