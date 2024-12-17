## Storage Benchmark DP3

This task involves benchmarking the performance of four storage systems: CephFS (Manila), CephRBD (Cinder), Local Disk (SSD), and S3 (s3fs) by downloading large dataset and processing them in a reproducible environment. 


### Prerequisite:
- S3 storage/bucket created (this is required for s3 storage benchmark test). Detail of how to create an S3 bucket can be found [here](https://confluence.skatelescope.org/pages/viewpage.action?spaceKey=SRCSC&title=Integrating+FUSE+Mount+on+S3+Buckets+with+CEPH+Storage%3A+Enabling+POSIX+Permissions+for+CARTA+and+CASA+Applications)

- Install Singularity

### Hardware requirement:

The performance of each benchmark is partly dependent on CPU speed and memory bandwidth. In general, the faster these components, the better you'll be able to evaluate the underlying storage.

There are two options for running this task. The first option is to create the Singularity container manually. The Singularity definition file can be cloned as shown and then follow the procedure below to create the Singularity container. The second option is to run it automatically by pulling the Singularity container from the registry.

### Option 1:

Create the Singularity container manually

```bash
git clone https://github.com/uksrc-developers/storage-benchmarks.git
```

Build the singularity container

```bash
cd storage-benchmarks
sudo singularity build benchmark.singularity.sif benchmark.singularity
```

Create directory

Choose or create a directory corresponding to the file system you intend to access. In this example, we use `/data` for CephRBD (Cinder storage), `/project` for CephFS (Manila share), `/home/azimuth/benchmark_local` for the local disk (SSD), and `/mnt/s3bucket` for S3 storage.

```bash
# for s3 stoage
sudo mkdir -p /mnt/your/mount/point  # replace /your/mount/point with the folder path to mount the s3 storge
sudo chown <user>:<user> /mnt/your/mount/point # replace user with the login user
sudo chmod 755 /your/mount/point

# for other storage, check that the storage e.g. /data or /project is mounted
```

Create a file to store S3 access key and secret key. 

Note: `s3fs` is not required to be installed on the host machine. It is already part of the software on the singularity definition file. More info on [s3fs](https://github.com/s3fs-fuse/s3fs-fuse) and how to create and mount s3 storage can be found [here](https://confluence.skatelescope.org/pages/viewpage.action?spaceKey=SRCSC&title=Integrating+FUSE+Mount+on+S3+Buckets+with+CEPH+Storage%3A+Enabling+POSIX+Permissions+for+CARTA+and+CASA+Applications).

```bash
# this is only required when testing s3 storage
echo "<access key>:<secret key>" > ~/.passwd-s3fs # replace <access key>:<secret key> with your access key and screte key
chmod 600 ~/.passwd-s3fs
```

Bind the writable directory when starting the Singularity container, where "/data" is the manila share. Binding the directory is only required if the directory to be accessed e.g. "/data" or "/mnt" is not visible within the singularity container.

Mount the s3 bucket using s3fs (This step is only required for s3 storage)

```bash
# replace /home/rocky/.passwd-s3fs to the path on your machine
# replace "https://object.arcus.openstack.hpc.cam.ac.uk" and "arcus.openstack.hpc.cam.ac.uk" with path to your s3 storage

sudo singularity exec --bind /mnt:/mnt benchmark.singularity.sif bash

s3fs <s3 bucket name> /mnt/<your-mount-point> -o passwd_file=/home/rocky/.passwd-s3fs -o use_cache=/tmp -o url=https://object.arcus.openstack.hpc.cam.ac.uk -o endpoint=arcus.openstack.hpc.cam.ac.uk -o use_path_request_style -o nonempty

 # check if the s3 bucket has been mounted
 df -h # should return /mnt/<your-mount-point>

 images.py /mnt/s3bucket/ download # this downloads the dataset
 images.py /mnt/s3bucket # this runs the benchmark
 ```

Download dataset
```bash
singularity exec --bind /data:/data benchmark.singularity.sif images.py /data download # replace /data with the directory corresponding to file system to be accessed
```

Run the benchmark

```bash
singularity exec --bind /data:/data benchmark.singularity.sif images.py /data # replace /data with the directory corresponding to file system to be accessed
```

### Option 2:

 Run it automatically by pulling the singularity container from the registry (This option does not work for S3 storage).

 This method runs the storage benchmark task automatically by pull the singularity container from the registry.

Place the `Makefile` in working directory and run the make command, which pulls the image and runs the command

```bash
make
```

 #### Sample result

```bash
100%|████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████| 5/5 [00:30<00:00,  6.13s/it]
Average execution time 6.122161 seconds
Max execution time 6.252471 seconds
Std dev of execution time 0.066033 seconds
```

