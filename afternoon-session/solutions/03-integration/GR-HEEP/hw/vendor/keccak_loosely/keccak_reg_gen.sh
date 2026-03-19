
echo "Generating keccak_loosely data registers data RTL"
$X_HEEP_PATH/hw/vendor/pulp_platform_register_interface/vendor/lowrisc_opentitan/util/regtool.py -r -t hw/rtl/gen_sv data/keccak_loosely_data_regs.hjson
echo "Generating keccak_loosely ctrl registers data RTL"
$X_HEEP_PATH/hw/vendor/pulp_platform_register_interface/vendor/lowrisc_opentitan/util/regtool.py -r -t hw/rtl/gen_sv data/keccak_loosely_ctrl_regs.hjson

echo "Generating keccak_loosely data registers data SW"
$X_HEEP_PATH/hw/vendor/pulp_platform_register_interface/vendor/lowrisc_opentitan/util/regtool.py --cdefines -o $SW_PATH/keccak_loosely_data_auto.h data/keccak_loosely_data_regs.hjson
echo "Generating keccak_loosely ctrl registers data SW"
$X_HEEP_PATH/hw/vendor/pulp_platform_register_interface/vendor/lowrisc_opentitan/util/regtool.py --cdefines -o $SW_PATH/keccak_loosely_ctrl_auto.h data/keccak_loosely_ctrl_regs.hjson

