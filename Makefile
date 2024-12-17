# Define variables
SINGULARITY_IMAGE=library://boyewo/collection/dp3-new-benchmark-singularity.sif
IMAGE_NAME=dp3-new-benchmark-singularity.sif
DATA_DIR=/mnt/datavolume # replace /mnt/datavolume with the file system to be accessed


# Default target
all: run

# Pull the Singularity image from the registry
pull:
	singularity pull $(IMAGE_NAME) $(SINGULARITY_IMAGE)
    
# Run the Singularity command
run: pull
	singularity exec --bind "/mnt:/mnt" "$(IMAGE_NAME)" images.py /mnt/datavolume

