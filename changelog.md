# admpresales/octane
All notable changes to this project will be documented in this file. The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)

# [12.55.8.137 (SaaS)] - 2017-11-30

### Added
- Octane bot API key has been added to support Mattermost chatbot in the future.

### Fixed
- PPM API Key was actually created with Jenkins user name. It is now properly named as ppm
- Users mappings have been re-added to the synchronizer.

### Changed
- Demo data has been modified to increased default velocity for all demo projects to 60.
- Several duplicate records have been removed from defects and requirements in an effort to help the synchronizer work between Octane and ALM.

# [12.55.7.84 (SaaS)] - 2017-10-31

### Added 
- PPM API Key has now been added
- Validation check in the integration bridge has been set to N in /opt/bridge/product/conf/wrapper-custom.conf, allowing 
Octane to perform synchronizations with ALM  .NET 12.55 without errors stating the version is incompatible. This is still a unsupported
feature.

