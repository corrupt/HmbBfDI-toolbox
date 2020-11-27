# WEC to XLSX converter

Simple script to convert the output of [WEC](https://github.com/EU-EDPS/website-evidence-collector) to an xlsx file.
The xlsx file will contain all trackers identified by WEC on a given site, sorted by domain, and a way to mark them found as part of a declaration (e.g. a privacy policy).

It is invoved by passing it WEC's *inspection-log.ndjson* and an optional output filename:

`python wec2xls.py inspection-log.ndjson inspection-log.xlsx`

The resulting xlsx file will look similar to the following screenshot (made using LibreOffice):

![LibreOffice Screenshot](/wec2xls/screenshot.png?raw=true)
