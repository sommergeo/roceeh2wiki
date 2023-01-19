# roceeh2wiki
This repo contains tools to publish geodata from the [ROCEEH Out of Africa Database (ROAD)](https://www.roceeh.uni-tuebingen.de/roadweb/smarty_road_simple_search.php) to Wikipedia maps. The tools help to query data from ROAD's [SPARQL](http://www.roceeh.uni-tuebingen.de/roadweb/smarty_sparql_select.php "Must be logged in to enter webform") endpoint and convert the results to the JSON schema of Wikipedia's map extension [Kartographer](https://www.mediawiki.org/wiki/Help:Extension:Kartographer).
The JSON files can be pasted to Wikimedia Commons, which then are linked within Wikis.
 

![Workflow of the roceeh2wiki package](docs/workflow_small.png)

## Results
The following Wikis are currently provided:

|ROAD Content   |Wikimedia                                                                 |Wikipedia                                                                                                                 |
|---------------|--------------------------------------------------------------------------|--------------------------------------------------------------------------------------------------------------------------|
|Ahmarian       |[Link](https://commons.wikimedia.org/wiki/Data:ROCEEH/Ahmarian.map)       |
|Aterian        |[Link](https://commons.wikimedia.org/wiki/Data:ROCEEH/Aterian.map)        |
|Chatelperronian|[Link](https://commons.wikimedia.org/wiki/Data:ROCEEH/Chatelperronian.map)|
|Fauresmith     |[Link](https://commons.wikimedia.org/wiki/Data:ROCEEH/Fauresmith.map)     |
|Gravettian     |[Link](https://commons.wikimedia.org/wiki/Data:ROCEEH/Gravettian.map)     |
|Howiesonspoort |[Link](https://commons.wikimedia.org/wiki/Data:ROCEEH/Howiesonspoort.map) |[en](https://en.wikipedia.org/wiki/Howiesons_Poort) [de](https://de.wikipedia.org/wiki/Howieson%E2%80%99s_Poort_Industrie)|
|Micoquian      |[Link](https://commons.wikimedia.org/wiki/Data:ROCEEH/Micoquian.map)      |
|Still Bay      |[Link](https://commons.wikimedia.org/wiki/Data:ROCEEH/Still_Bay.map)      |
|Uluzzian       |[Link](https://commons.wikimedia.org/wiki/Data:ROCEEH/Uluzzian.map)       |[en](https://en.wikipedia.org/wiki/Uluzzian) [de](https://de.wikipedia.org/wiki/Uluzzien)                                 |

## Background
### Geodata in Wikimedia Commons
Geodata for Wikipedia are collected in Wikimedia Commons for two reasons. First, GeoJSON files can be excessively long depending on its content, so that it disturbs the readability in the Wikipedia text editor. Second, contents in Wikimedia Commons can be accessed from Wikis in all languages, no cross-posting needed.

![Screenshot from Wikimedia Commons](docs/wikimedia_commons_uluzzian_1000x1000.png)

#### URL
All ROAD contents follow the URL-Schema `https://commons.wikimedia.org/wiki/Data:ROCEEH/*.map`, where  `*` denotes the content title. This file is accessible within Wikipedia as `ROCEEH/*.map`.

#### JSON
The following code is an exemple from the Uluzzian culture, and was shortened to show just one site, "Uluzzo C". The Kartographer schema uses a JSON file, which can be divided into general map information and geodata.

- General map information:
	- The `"license"` for all ROAD data is [CC BY-SA 4.0](https://www.roceeh.uni-tuebingen.de/roadweb/smarty_data_use_policy.php) and therefore complies with Wikipedia's terms of use. 
	- The `"description"` is shown in Wikimedia Commons as a subheading. Different languages can be used to translate to the target Wiki's title, e.g. English "Ulizzian" vs. German "Uluzzien".
	- The `"sources"` tag is a standard text. The date of export is always updated.
	- The tags `"zoom"`, `"latitude"` and `"longitude"` are optional and can be used to set the map's initial extent. The map engine however is smart enough to set a suitable extent automatically.
- Geodata:
	- The `"data"` tag is at the heart of Wikipedia's JSON scheme and contains a standard GeoJSON file. Most of its contents are standardized. The appearance of the popup is defined in the features' `"properties"`. 
		- The `"title"` contains the name of the site as exported from ROAD. _It is planned to optionally link to other Wikis, where available._ 
		- The `"description"` always contains a link to the site's [Summary Data Sheet](https://www.roceeh.uni-tuebingen.de/roadweb/tcpdf/localityInfoPDF/localityInfoPDF.php?locality=Uluzzo%20C), a PDF generated with the URL `https://www.roceeh.uni-tuebingen.de/roadweb/tcpdf/localityInfoPDF/localityInfoPDF.php?locality=*`, where `*` denotes the site's name. _It is planned to optionally include existing Wikipedia images and other contents, where available._
```json
{
    "license": "CC-BY-SA-4.0",
    "description": {
        "de": "Fundstellen des Uluzzien",
        "en": "Uluzzian sites"
    },
    "sources": "Data retrieved from the [https://www.roceeh.uni-tuebingen.de/roadweb ROCEEH Out Of Africa Database (ROAD)].",
    "zoom": 5,
    "latitude": 41.5,
    "longitude": 16.3,
    "data": {
        "type": "FeatureCollection",
        "name": "uluzzian_road",
        "crs": {
            "type": "name",
            "properties": {
                "name": "urn:ogc:def:crs:OGC:1.3:CRS84"
            }
        },
        "features": [
            {
                "type": "Feature",
                "properties": {
                    "title": "Uluzzo C",
                    "description": "[[File:Grotta di Uluzzo C 4.jpg|150px|alt=Grotta di Uluzzo C]]</br>[https://www.roceeh.uni-tuebingen.de/roadweb/tcpdf/localityInfoPDF/localityInfoPDF.php?locality=Uluzzo%20C Summary Data Sheet]"
                },
                "geometry": {
                    "type": "Point",
                    "coordinates": [
                        17.96,
                        40.15
                    ]
                }
            }
        ]
    }
}
```




### Maps in Wikipedia

Within the Wiki itself, the map is represented by a `<mapframe>` element. The element's `text` argument is used as a subtitle of the map and cotains a name in the repsective language, the license and the source name. The mapframe points to the Wikimedia Commons file, whose name is posted in `"title"`.

![Screenshot from Wikimedia Commons](docs/wikipedia_uluzzian_1000x700.png)

```html
<mapframe text="Fundstellen des Uluzzien (CC-BY-SA 4.0 [https://www.roceeh.uni-tuebingen.de/roadweb ROCEEH])" width="450", height="350">
{
  "type": "ExternalData",
  "service": "page",
  "title": "ROCEEH/Uluzzian.map"
}
</mapframe>
```