############
Change Log
############

All notable changes to this project will be documented in this file.
This project adheres to `Semantic Versioning <http://semver.org/>`_.

2024-10-25
***********
* MAP-206 Bump ska-mid-cbf-engineering-console from 0.10.11 to 0.10.12-rc.1

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
