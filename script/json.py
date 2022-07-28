# -*- coding: utf-8 -*-
"""
Created on Thu Jul 28 14:29:58 2022

@author: Christian Sommer
"""

import pandas as pd
import geopandas
import json


# Head of JSON
commons_license = "CC-BY-SA-4.0"
commons_source = "Data retrieved from the [https://www.roceeh.uni-tuebingen.de/roadweb ROCEEH Out Of Africa Database (ROAD)]."
commons_description = {"de": "Fundstellen des Uluzzien","en": "Uluzzian sites"}



# Geodata JSON
df = pd.read_csv (r'D:\SOMMER\git\roceeh2wiki\data\roceeh_data_test.csv', sep=';')
df.columns = df.columns.str.replace('.', '_') ## Replace points with strings
print(df)

df = df.round({'locality_x': 2, 'locality_y': 2})
print(df)

gdf = geopandas.GeoDataFrame(
    df['title'], geometry=geopandas.points_from_xy(df.locality_x, df.locality_y), crs='EPSG:4326')

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
print(wikidict)
wikistring = json.dumps(wikidict)
print(wikistring)


# Export as JSON file
with open(r'D:\SOMMER\git\roceeh2wiki\test\json_data.json', 'w', encoding='utf-8') as f:
    json.dump(wikidict, f, ensure_ascii=False, indent=4)