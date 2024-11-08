"""Constants to provide to other Python files for neatness"""

import os
import os.path

# repo-wide logging format
LOG_FORMAT = "[%(asctime)s|%(levelname)s|%(filename)s#%(lineno)s] %(message)s"

# Define paths for test data using the .jupyter-notebook/data submodule
DATA_DIR = os.path.join(os.getcwd(), ".jupyter-notebook/data/mid_telescope")
CBF_PARAMS_DIR = os.path.join(DATA_DIR, "cbf")
TMC_PARAMS_DIR = os.path.join(DATA_DIR, "tmc")

HW_CONFIG_DIR = CBF_PARAMS_DIR + "/hw_config"
SLIM_CONFIG_DIR = CBF_PARAMS_DIR + "/slim_config"
SYS_PARAMS_DIR = CBF_PARAMS_DIR + "/sys_params"
CBF_INPUT_DIR = CBF_PARAMS_DIR + "/cbf_input_data"
BITE_CONFIG_DIR = CBF_INPUT_DIR + "/bite_config_parameters"

# Define config and json files for test data using folders
CBF_INPUT_JSON = CBF_INPUT_DIR + "/cbf_input_data.json"
BITE_CONFIG_JSON = BITE_CONFIG_DIR + "/bite_configs.json"
FILTERS_JSON = BITE_CONFIG_DIR + "/filters.json"

HW_CONFIG = CBF_PARAMS_DIR + HW_CONFIG_DIR + "/hw_config_psi.yaml"
HW_CONFIG_SWAP = CBF_PARAMS_DIR + HW_CONFIG_DIR + "/hw_config_swap_psi.yaml"
SLIM_CONFIG = CBF_PARAMS_DIR + SLIM_CONFIG_DIR + "/fs_slim_4vcc_1fsp.yaml"
DISH_CONFIG = CBF_PARAMS_DIR + SYS_PARAMS_DIR + "/load_dish_config.json"

ASSIGN_RESOURCES_JSON = TMC_PARAMS_DIR + "assign_resources_psi.json"
CONFIGURE_SCAN_JSON = TMC_PARAMS_DIR + "configure_scan.json"
SCAN_JSON = TMC_PARAMS_DIR + "scan.json"

