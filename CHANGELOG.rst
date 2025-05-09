############
Change Log
############

All notable changes to this project will be documented in this file.
This project adheres to `Semantic Versioning <http://semver.org/>`.

2025-05-09
**********
* MAP-352: Update TDC MCS to 1.3.0 which supports new tel model for AA1 PST simulation mode

2025-04-21
**********
* MAP-344: Update TMC to 1.0.0-rc.3 adds new DishVccCommandStatus attribute for monitoring DishVCC job status

2025-04-03
**********
* MAP-335: Update SDP from 1.1.0 to 1.1.1

2025-04-02
**********
* MAP-306: Update TMC to 1.0.0-rc.2 which includes ADR-9 naming convention updates
* MAP-308: Update SDP to 1.1.0 which uses vis-receive 0.5.0
* MAP-310: Update TDC MCS to 1.2.1 and EC to 1.1.3 which enables VCC gain adjustments
* MAP-327: Update DishLMC to 7.0.1 which resolves SPFRx incompatibility issues in SKB-809 and SKB-818

2025-03-28
***********
* MAP-307: Update ska-csp-lmc-mid from 0.24.0 to 1.0.1

2025-03-25
***********
* MAP-325: Update cbf-tdc-mcs to 1.2.0 and cbf-engineering-console to 1.1.2.

2025-03-20
***********
* MAP-326: Override CspScanInterfaceURL in the two TMC values files to use ska-csp-scan/2.2 to get past CBF Subarray failing to transition to Scanning when the Scan command is issued.

2025-03-11
***********
* MAP-318: Update .gitlab-ci.yml to allow logs to be collected without depending on test to be run, create unique names for artifact files when run.

2025-03-06
***********
* MAP-319: Update ska-tango-base from 0.4.10 to 0.4.17 and ska-tango-util from 0.4.11 to 0.4.17

2025-03-05
***********
* MAP-243: Update ska-tmc-mid from 0.24.0 to 0.25.0

2025-03-03
***********
* MAP-300: Update dish-lmc in ska-mid-psi and ska-mid-psi-dish-lmc charts from 6.0.1 to 7.0.0

2025-02-25
***********
* MAP-301 Bump EDA (ska-tango-archiver) to 2.9.0 which addresses the following:
  - SKB-440: The Archviewer control system dropdown is sorted alphabetically
  - SKB-441: The Archviewer can display Enum data
  - SKB-445: The Archviewer and Archwizard are accessible via the Ingress IP
* MAP-276 Bump TMC version from 0.22.8 to 0.24.0 to work with oso-scripting updates in notebooks.

2025-02-24
***********
* REL-1881 Pulling in SPFRx 0.5.0

2025-02-20
***********
* MAP-294 Bump MCS to 1.1.2 and EC to 1.1.1 (which uses bitstream 1.0.1) which fixes SKB-729 issues such that when the CBF On sequence fails, the CBF can recover and be turned back Off and On.

2025-02-18
***********
* MAP-213 Bump Taranta to 2.13.1 and replace TangoGQL with TangoGQL-Ariadne 1.0.1

2025-02-11
***********
* REL-1880 Bumping SPFRx from 0.4.0 to 0.4.1

2025-01-29
***********
* MAP-282 Bump SPFRx to 0.4.0, switch to using TDC MCS 1.1.1, and remove CBF TmLeafNode
* MAP-281 Bump SDP version from 0.21.0 to 0.24.1

2025-01-21
***********
* MAP-245 Bump MCS and TmLeafNode from 1.1.0 to 1.1.1 Engineering Console from 1.0.0 to 1.0.1. Also adds .ms to git ignore to prevent diffing of measurement data folders.

2025-01-17
***********
* MAP-245 Add in python script to enable reading of measurement data.

2025-01-08
***********
* MAP-277 Add in shell script to retrieve measurement data from namespaces.

2025-01-06
***********
* MAP-229 Bump dish-lmc to 6.0.1 

2024-11-18
***********
* MAP-200 Update and split Helm chart files to deploy dish-LMC first.

2024-11-14
***********
* MAP-158 Bump MCS, leafnode, EC and DISH-LMC versions for ADR-99 testing.

2024-11-08
***********
* SKB-434 Bump ska-tmc-mid from 0.22.8-rc1 to 0.22.8 and ska-tango-archiver from 2.8.0 to 2.8.1, to resolve errors found in the arhiver when monitoring the sdpSubarrayObState + cspSubarrayObState attributes. Also removes `archiver/default.yaml` and `archiver/demo.yaml` files as no longer needed.

2024-10-29
***********
* MAP-190 Bump ska-mid-dish-spfrx-talondx-console from 0.3.6 to 0.3.8
* MAP-194 Add BDD and Xray infrastructure with stubbed out automated test

2024-10-25
***********
* MAP-205 Bump ska-tmc-mid version in chart.yaml from 0.22.6 to 0.22.8

2024-10-13
***********
* MAP-166 Bumping all versions to include mid product release candidates for more stable end-to-end

2024-09-10
***********
* MAP-170 Bump spfrx-talondx-console version in chart.yaml from 0.3.3 to 0.3.6

2024-09-06
***********
* MAP-150 Bump csp-lmc-mid version in chart.yaml from 0.22.0 to 0.23.1

2024-09-05
***********
* MAP-151 Bump ska-db-oda-umbrella version in chart.yaml from 5.3.0 to 6.0.0
* MAP-141 Bump csp-tmc-mid version in chart.yaml from 0.21.2 to 0.22.2

2024-09-03
***********
* MAP-139 Add separate `SPFRX_ENABLED` pipeline argument (defaults to false). Dish LMC and SPFRx components can now be spun up separately, but if `DISH_LMC_ENABLED` is false, `SPFRX_ENABLED` will also be false.
* MAP-140 Dynamic archiving of attributes based on `SPFRX_ENABLED` and `DISH_LMC_ENABLED` flags. Only loads in from the YAML files in the archiver directory if the relevant flags are set to true.

2024-08-12
***********
* MAP-87 Add EDA configs for mid-telescope.yaml (set as default ARCHIVE_CONFIG) and dish-lmc.yaml


2024-Jan-11
************
* MAP-22 Add TMC and test auto-correlation driven through TMC

2023-Dec-11
************
* MAP-27 Initial CI commit files
