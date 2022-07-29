# -*- coding: utf-8 -*-
"""
Created on Fri Jul 29 14:42:30 2022

@author: Christian Sommer
"""
import sparql_dataframe
import geopandas
import json


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


def wiki_json(df):
    # Head of JSON
    commons_license = "CC-BY-SA-4.0"
    commons_source = "Data retrieved from the [https://www.roceeh.uni-tuebingen.de/roadweb ROCEEH Out Of Africa Database (ROAD)]."
    commons_description = {"de": "Fundstellen des Uluzzien","en": "Uluzzian sites"}



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
    print(wikistring)
