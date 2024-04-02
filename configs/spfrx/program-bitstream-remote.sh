#!/bin/bash
set -eoux pipefail

display_usage() {
    echo -e "\nprogram Talon-DX Bitstream remote script"
    echo -e "------------------------------------------\n"
    echo -e "Install a bitstream into the SPFRx Talon-DX FPGA over SSH."
    echo -e "\nUsage:"
    echo -e "   $0 SPFRX_LOCAL_DIR BOARD_IP"
    echo -e "\n"
    echo -e "SPFRX_LOCAL_DIR : The path to the artifacts directory after download"
    echo -e "BOARD_IP : The IP address of the SPFRx TALON-DX HPS"
}

spfrx_local_dir=${1}
board=${2}
path="/sys/kernel/config/device-tree/overlays"
name="core"

if [ $# -lt 2 ]
then
    display_usage
    exit 1
fi

bs_core=talon_dx-spfrx_base-spfrx_core-hps_first.core.rbf
dtb=talon_dx-spfrx_base-spfrx_core.dtb
scp -o StrictHostKeyChecking=no $spfrx_local_dir/fpga-talon/bin/$bs_core $spfrx_local_dir/fpga-talon/bin/$dtb root@$board:/lib/firmware
ssh -o StrictHostKeyChecking=no root@$board -n "rmdir $path/*; mkdir $path/$name" # trigger removal of old device tree, the setup next image.
ssh -o StrictHostKeyChecking=no root@$board -n "cd /lib/firmware && echo $dtb > $path/$name/path"
ssh -o StrictHostKeyChecking=no root@$board -n "dmesg | tail -n 10"

