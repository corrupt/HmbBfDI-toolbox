# WEC Instrumentation

Simple bash script to instrument [WEC](https://github.com/EU-EDPS/website-evidence-collector). Requires at least [fa8e87e](https://github.com/EU-EDPS/website-evidence-collector/tree/fa8e87e4608b597da9817938c971fb11b605f99c) to be able to pass a user data directory to Chromium.

Nothing fancy to its usage. We maintain a version of this script for each of our projects, sometimes with custom changes. It automates the launch of a Chromium instance browsing to the website in question that can then be configured as required, e.g. universally agree to all tracking in a tracking banner. We mainly use this to easily make snapshots of websites' tracking behavior pre- and post-consent