############
Change Log
############

All notable changes to this project will be documented in this file.
This project adheres to `Semantic Versioning <http://semver.org/>`_.

2024-09-03
***********
* MAP-139 Add separate `SPFRX_ENABLED` pipeline argument (defaults to false). Dish LMC and SPFRx components can now be spun up separately, but if `DISH_LMC_ENABLED` is false, `SPFRX_ENABLED` will also be false.
* MAP-140 Dynamic archiving of attributes based on SPFRx/LMC flags. Only loads in from the YAML files in the archiver directories if the relevant flags are set.

2024-08-12
***********
* MAP-87 Add EDA configs for mid-telescope.yaml (set as default ARCHIVE_CONFIG) and dish-lmc.yaml


2024-Jan-11
************
* MAP-22 Add TMC and test auto-correlation driven through TMC

2023-Dec-11
************
* MAP-27 Initial CI commit files
