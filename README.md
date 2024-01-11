# Polytope Benchmark


Polytope (https://github.com/ecmwf/polytope) is a library for extracting complex data from datacubes. It enables non-orthogonal access to data, where the stencil used to extract data from the datacube can be any arbitrary n-dimensional polygon (called a polytope). 

This is a benchmark that collects metrics on the time taken to perform different Polytope requests. It requires a Docker image, which can be created from the Dockerfile provided. Assuming access to a Kubernetes Cluster, the benchmark can be executed by running `run-benchmark.sh`, which writes the metrics outputted in the run into a results file in the subdirectory `bench_run/<run-number>`.
