HOST={$1:-"localhost"}
PORT={$2:-"8080"}
POLYGON_SOURCE={$3:-"file:output8.grib"}
VERTICAL_SOURCE={$4:-"file:vertical_profile_era5_grid.grib"}
TIMESERIES_SOURCE={$5:-"file:timeseries_era5.grib"}

# Set up FDB config
sed -i "s/%HOST%/$HOST/g" /home/fdb/etc/fdb/config.yaml
sed -i "s/%PORT%/$PORT/g" /home/fdb/etc/fdb/config.yaml

python3 run-benchmark.py --polygon-source $POLYGON_SOURCE --vertical-source $VERTICAL_SOURCE --timeseries-source $TIMESERIES_SOURCE