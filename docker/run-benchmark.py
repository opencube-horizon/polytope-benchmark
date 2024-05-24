import argparse
import time
import sys

import geopandas as gpd
from shapely.geometry import shape
from earthkit.data import from_source

from polytope.datacube.backends.xarray import XArrayDatacube
from polytope.engine.hullslicer import HullSlicer
from polytope.polytope import Polytope, Request
from polytope.shapes import ConvexPolytope, Select, Span
import xarray as xr


def data_from_source(source: str, request: dict):
    src = source.split(":")
    if src[0] == "fdb":
        ds = from_source(src[0], request, stream=True, batch_size=0)
        if len(ds) == 0:
            raise ValueError(f"No data found in {src[0]} for request {request}")
        return ds.to_xarray(xarray_open_dataset_kwargs={"squeeze": True})
    if src[0] == "file":
        return xr.open_dataset(src[1])


def polygon_benchmark(source: dict):
    print("POLYGON SOURCE", source)
    request = {
        "class": "od",
        "stream": "oper",
        "expver": "0001",
        "date": "20220206",
        "time": "12",
        "levtype": "sfc",
        "type": "fc",
        "param": 167,
        "step": 0,
        "domain": "g",
    }
    array = data_from_source(source, request).t2m
    axis_options = {
        "longitude": {"cyclic": [0, 360.0]},
        "latitude": {"reverse": {True}},
        "isobaricInhPa": {"reverse": {True}},
    }
    xarraydatacube = XArrayDatacube(array)
    slicer = HullSlicer()
    API = Polytope(datacube=array, engine=slicer, axis_options=axis_options)

    shapefile = gpd.read_file("./test_data/World_Countries__Generalized_.shp")

    request_objects = []
    countries = []
    for i in range(
        0, 196
    ):  # NOTE: can change range to adjust number of retrieved polygons
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
        for obj in poly[
            :75
        ]:  # NOTE: can change 10 to another number to adjust number of retrieved polygons
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


def vertical_benchmark(source: str):
    print("VERTICAL SOURCE", source)
    request = {
        "class": "er",
        "stream": "oper",
        "expver": "0001",
        "date": "19900731",
        "time": "00",
        "levtype": "ml",
        "levelist": list(range(1, 32)),
        "type": "fc",
        "param": 130,
        "step": 0,
        "domain": "g",
    }
    array = data_from_source(source, request).t
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
                    Select("time", ["1990-07-31"]),
                    Select("latitude", [lat]),
                    Select("longitude", [lon]),
                    Span("hybrid", 1, 31),
                    Select("valid_time", ["1990-07-31"]),
                )

                # Extract the values of the long and lat from the tree
                result = API.retrieve(request)
                # result.pprint()
                num_points += len(result.leaves)

    print("POLYTOPE TIME FOR VERTICAL PROFILES")
    print(time.time() - time0)
    print("NUMBER OF POINTS EXTRACTED")
    print(num_points)


def timeseries_benchmark(source: str):
    print("TIMESERIES SOURCE", source)
    request = {
        "class": "er",
        "stream": "oper",
        "expver": "0001",
        "date": [f"199008{x:02}" for x in range(1, 32)],
        "time": "00",
        "levtype": "ml",
        "levelist": 1,
        "type": "fc",
        "param": 130,
        "step": 0,
        "domain": "g",
    }
    array = data_from_source(source, request).t
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
                    Select("hybrid", [1]),
                )

                # Extract the values of the long and lat from the tree
                result = API.retrieve(request)
                # result.pprint()
                num_points += len(result.leaves)

    print("POLYTOPE TIME FOR TIMESERIES")
    print(time.time() - time0)
    print("NUMBER OF POINTS EXTRACTED")
    print(num_points)


def main(args):
    parser = argparse.ArgumentParser(description="Run the benchmark")
    parser.add_argument(
        "--polygon-source",
        type=str,
        default="file:test_data/polygon.grib",
        help="source of the data for polygon benchmark",
    )
    parser.add_argument(
        "--vertical-source",
        type=str,
        default="file:test_data/vertical.grib",
        help="source of the data for vertical profile benchmark",
    )
    parser.add_argument(
        "--timeseries-source",
        type=str,
        default="file:test_data/timeseries.grib",
        help="source of the data for timeseries benchmark",
    )

    args = parser.parse_args(args)
    polygon_benchmark(args.polygon_source)
    vertical_benchmark(args.vertical_source)
    timeseries_benchmark(args.timeseries_source)


if __name__ == "__main__":
    main(sys.argv[1:])
