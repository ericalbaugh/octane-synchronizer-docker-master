# octane-synchronizer-docker
Docker build for adding Synchronization to ALM.NET for Octane

To build, use the following syntax:

docker build -t admpresales/octane:(octane-version)_dis --shm-size=2g .

In order for the integrity checks to pass, The ALM .NET container must be up and running with the name alm prior to the build being run and be on the same network as 
the octane build. For example, if ALM .NET is running on the demo-net network, then the build must include the --network demo-net
added to the build parameters, like so:

docker build -t admpresales/octane:(octane-version)_dis --shm-size=2g --network demo-net .


