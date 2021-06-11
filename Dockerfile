FROM dbp2123/afni:0.0.1_20.0.18
# STart with my AFNI build
# BSL Preprocssing Pipeline 



#################
# FSL 6.0 Install
###################
RUN apt-get update && \
apt-get install -y libopenblas-dev \
                   unzip           \
                   wget            \
                   jq           && \
                   rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
     
WORKDIR /tmp              
RUN wget -q http://fsl.fmrib.ox.ac.uk/fsldownloads/fslinstaller.py && chmod 775 fslinstaller.py
RUN /tmp/fslinstaller.py -d /usr/local/fsl && \
    rm -rf /usr/local/fsl/data/first && \
    rm -rf /usr/local/fsl/fslpython/pkgs/*.bz2


################
# Matlab MCR
################
RUN apt-get -qq update && apt-get -qq install -y \
    unzip \
    xorg \
    wget \
    curl \
    zip && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    mkdir /mcr-install && \
    mkdir /opt/mcr && \
    cd /mcr-install && \
    wget https://ssd.mathworks.com/supportfiles/downloads/R2017b/deployment_files/R2017b/installers/glnxa64/MCR_R2017b_glnxa64_installer.zip && \
    cd /mcr-install && \
    unzip -q MCR_R2017b_glnxa64_installer.zip && \
    ./install -destinationFolder /opt/mcr -agreeToLicense yes -mode silent && \
    cd / && \
    rm -rf mcr-install

# Configure environment variables for MCR
ENV LD_LIBRARY_PATH /opt/mcr/v93/runtime/glnxa64:/opt/mcr/v93/bin/glnxa64:/opt/mcr/v93/sys/os/glnxa64:/opt/mcr/v93/extern/bin/glnxa64
ENV XAPPLRESDIR /opt/mcr/v93/x11/app-defaults

# Make FSL happy
ENV FSLDIR=/usr/local/fsl
ENV PATH=$FSLDIR/bin:$PATH
RUN /bin/bash -c 'source /usr/local/fsl/etc/fslconf/fsl.sh'
ENV FSLMULTIFILEQUIT=TRUE
ENV FSLOUTPUTTYPE=NIFTI_GZ
ENV FLYWHEEL=/flywheel/v0


COPY run $FLYWHEEL/run
#COPY run_FW_filter.sh $FLYWHEEL/run_FW_filter.sh
COPY FW_filter $FLYWHEEL/FW_filter


RUN chmod +x $FLYWHEEL/run  
            # $FLYWHEEL/FW_filter


ENTRYPOINT /bin/bash



# docker run --rm -ti --entrypoint=/bin/bash -v /Users/davidparker/Documents/Flywheel/SSE/MyWork/Gears/aTBS/atbs-0.0.7_5ea9ad96bfda5100476aa08f/input:/flywheel/v0/input -v /Users/davidparker/Documents/Flywheel/SSE/MyWork/Gears/aTBS/atbs-0.0.7_5ea9ad96bfda5100476aa08f/output:/flywheel/v0/output -v /Users/davidparker/Documents/Flywheel/SSE/MyWork/Gears/aTBS/atbs-0.0.7_5ea9ad96bfda5100476aa08f/config.json:/flywheel/v0/config.json dbp2123/atbs:0.0.3

#docker run --rm -ti --entrypoint=/bin/bash -v /Users/davidparker/Documents/Flywheel/SSE/MyWork/Gears/aTBS/aTBS_FW_Gear/atbs-0.1.2_5ebc3e48bfda5102716aa09e/input:/flywheel/v0/input -v /Users/davidparker/Documents/Flywheel/SSE/MyWork/Gears/aTBS/aTBS_FW_Gear/atbs-0.1.2_5ebc3e48bfda5102716aa09e/output:/flywheel/v0/output -v /Users/davidparker/Documents/Flywheel/SSE/MyWork/Gears/aTBS/aTBS_FW_Gear/atbs-0.1.2_5ebc3e48bfda5102716aa09e/config.json:/flywheel/v0/config.json dbp2123/ppbsl:0.0.1