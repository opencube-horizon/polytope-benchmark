import time

import geopandas as gpd
from shapely.geometry import shape

from polytope.datacube.backends.xarray import XArrayDatacube
from polytope.engine.hullslicer import HullSlicer
from polytope.polytope import Polytope, Request
from polytope.shapes import ConvexPolytope, Select, Span
import xarray as xr
import os 
import requests

class HTTPError(Exception):
    def __init__(self, status_code, message):
        self.status_code = status_code
        self.message = message
        super().__init__(f"HTTPError {status_code}: {message}")


def download_test_data(nexus_url, filename):
    local_directory = "./tests/data"

    if not os.path.exists(local_directory):
        os.makedirs(local_directory)

    # Construct the full path for the local file
    local_file_path = os.path.join(local_directory, filename)

    if not os.path.exists(local_file_path):
        session = requests.Session()
        response = session.get(nexus_url)
        if response.status_code != 200:
            raise HTTPError(response.status_code, "Failed to download data.")
        # Save the downloaded data to the local file
        with open(local_file_path, "wb") as f:
            f.write(response.content)


nexus_url = "https://get.ecmwf.int/test-data/polytope/test-data/output8.grib"
download_test_data(nexus_url, "output8.grib")
nexus_url = "https://get.ecmwf.int/test-data/polytope/test-data/vertical_profile_era5_grid.grib"
download_test_data(nexus_url, "vertical_profile_era5_grid.grib")
nexus_url = "https://get.ecmwf.int/test-data/polytope/test-data/timeseries_era5.grib"
download_test_data(nexus_url, "timeseries_era5.grib")
nexus_url = "https://get.ecmwf.int/test-data/polytope/test-data/World_Countries__Generalized_.shp"
download_test_data(nexus_url, "World_Countries__Generalized_.shp")
nexus_url = "https://get.ecmwf.int/test-data/polytope/test-data/World_Countries__Generalized_.shx"
download_test_data(nexus_url, "World_Countries__Generalized_.shx")

# Pieces of countries

array = xr.open_dataset("./tests/data/output8.grib", engine="cfgrib")
array = array.t2m
axis_options = {
            "longitude": {"cyclic": [0, 360.0]},
            "latitude": {"reverse": {True}},
            "isobaricInhPa": {"reverse": {True}},
        }
xarraydatacube = XArrayDatacube(array)
slicer = HullSlicer()
API = Polytope(datacube=array, engine=slicer, axis_options=axis_options)

shapefile = gpd.read_file("./tests/data/World_Countries__Generalized_.shp")

request_objects = []
countries = []
for i in range(0, 196):  # NOTE: can change range to adjust number of retrieved polygons
    s = shape(shapefile.iloc[i]["geometry"])
    if s.geom_type == "MultiPolygon":
        countries.append(shapefile.iloc[i])
for country in countries:
    multi_polygon = shape(country["geometry"])
    polygons = list(multi_polygon.geoms)
    polygons_list = []

    # Now create a list of x,y points for each polygon

    for polygon in polygons:
        if polygon.area < 1.7:
            xx, yy = polygon.exterior.coords.xy
            polygon_points = [list(a) for a in zip(xx, yy)]
            polygons_list.append(polygon_points)

    # Then do union of the polygon objects and cut using the slicer
    poly = []
    for points in polygons_list:
        polygon = ConvexPolytope(["longitude", "latitude"], points)
        poly.append(polygon)
    for obj in poly[:75]:  # NOTE: can change 10 to another number to adjust number of retrieved polygons
        request_objects.append(obj)

print("NUMBER OF REQUESTS")
print(len(request_objects))

num_points = 0
time0 = time.time()
for request_obj in request_objects:
    request = Request(
        request_obj,
        Select("number", [0]),
        Select("time", ["2022-02-06T12:00:00"]),
        Select("step", ["00:00:00"]),
        Select("surface", [0]),
        Select("valid_time", ["2022-02-06T12:00:00"]),
    )

    # Extract the values of the long and lat from the tree
    result = API.retrieve(request)
    num_points += len(result.leaves)

print("POLYTOPE TIME FOR COUNTRY PARTS/POLYGONS")
print(time.time() - time0)
print("NUMBER OF POINTS EXTRACTED")
print(num_points)


# Vertical profiles

array = xr.open_dataset("./tests/data/vertical_profile_era5_grid.grib", engine="cfgrib").t
axis_options = {
            "longitude": {"cyclic": [0, 360.0]},
            "latitude": {"reverse": {True}},
            "isobaricInhPa":  {"reverse": {True}},
        }
xarraydatacube = XArrayDatacube(array)
slicer = HullSlicer()
API = Polytope(datacube=array, engine=slicer, axis_options=axis_options)

number_of_points = 10748

lats = [-89 + i for i in range(180)]
lons = [i for i in range(90)]

num_points = 0
time0 = time.time()

for lat in lats:
    for lon in lons:
        if num_points < number_of_points:
            request = Request(
                Select("number", [0]),
                Select("step", ["00:00:00"]),
                Select("time", ["1990-08-01"]),
                Select("latitude", [lat]),
                Select("longitude", [lon]),
                Span("hybrid", 1, 31),
                Select("valid_time", ["1990-08-01"])
            )

            # Extract the values of the long and lat from the tree
            result = API.retrieve(request)
            # result.pprint()
            num_points += len(result.leaves)

print("POLYTOPE TIME FOR VERTICAL PROFILES")
print(time.time() - time0)
print("NUMBER OF POINTS EXTRACTED")
print(num_points)

# Timeseries

array = xr.open_dataset("./tests/data/timeseries_era5.grib", engine="cfgrib").t
axis_options = {
            "longitude": {"cyclic": [0, 360.0]},
            "latitude": {"reverse": {True}},
            "isobaricInhPa": {"reverse": {True}},
        }
xarraydatacube = XArrayDatacube(array)
slicer = HullSlicer()
API = Polytope(datacube=array, engine=slicer, axis_options=axis_options)

number_of_points = 10748

lats = [-89 + i for i in range(180)]
lons = [i for i in range(90)]

num_points = 0
time0 = time.time()

for lat in lats:
    for lon in lons:
        if num_points < number_of_points:
            request = Request(
                Select("number", [0]),
                Select("step", ["00:00:00"]),
                Span("time", "1990-08-01", "1990-08-31"),
                Select("latitude", [lat]),
                Select("longitude", [lon]),
                Select("hybrid", [1])
            )

            # Extract the values of the long and lat from the tree
            result = API.retrieve(request)
            # result.pprint()
            num_points += len(result.leaves)

print("POLYTOPE TIME FOR TIMESERIES")
print(time.time() - time0)
print("NUMBER OF POINTS EXTRACTED")
print(num_points)
