#!/bin/bash

#
# Author: pengru.shen@borqs.com
# Date:   2013/11/03
#

TOP=`dirname $0`
GREEN_PRE="\033[32;49;1m"
GREEN_END="\033[39;49;0m"
RED_PRE="\033[31;49;1m"
RED_END="\033[31;49;0m"
BLUE_PRE="\033[34;49;1m"
BLUE_END="\033[34;49;0m"
APPLE_PRE="\033[36;49;1m"
APPLE_END="\033[36;49;0m"

INPUT_PATH="./input"
IMAGE_LIST="logo boot.unsigned droidboot.unsigned recovery.unsigned"

KEYLIST=(key-ship-NORMAL key-ship-PRESTO key-ship-DUCATI key-factory-DUCATI)
KEY_REPLACE_PATH=
KEY_USE_PATH=${TOP}/configs/key
KEY_USE_PEM=${KEY_USE_PATH}/key.pem
function select_key ()
{
	# print key list
	echo -e "========================================="
	echo -e "KEY LIST"
	echo -e "++++++++"
	echo -e "\t 0 - ${KEYLIST[0]}"
	echo -e "\t 1 - ${KEYLIST[1]}"
	echo -e "\t 2 - ${KEYLIST[2]}"
	echo -e "\t 3 - ${KEYLIST[3]}"
	echo -e "=========================================\n\n"

	# select
	while :
	do
		if read -n 1 -p "Which key you will use?[] >> "
		then
			case ${REPLY} in
			0) PRODUCT=NORMAL;MODE=ship;break;; 
			1) PRODUCT=PRESTO;MODE=ship;break;; 
			2) PRODUCT=DUCATI;MODE=ship;break;; 
			3) PRODUCT=DUCATI;MODE=factory;break;; 
			*) echo -e "\n input parameter error !! \n";continue
			esac
		fi
	done
	KEY_REPLACE_PATH=${TOP}/configs/keys/key-${MODE}-${PRODUCT}

	if [[ ! -e ${KEY_REPLACE_PATH} ]];then
		echo -e "\n\n${RED_PRE}Can not find the Key you select, plz get it from your PM!${RED_END}\n\n"
		exit 1
	else
		echo -e "\n\nUse key <${GREEN_PRE}${KEY_REPLACE_PATH}${GREEN_END}>. Copying...\n\n"
	fi

	# replace the ${TOP}/configs/key/key.pem
	rm -rf ${KEY_USE_PATH}
	cp -rfv ${KEY_REPLACE_PATH} ${KEY_USE_PATH}

	# cat key's info
	cat ${KEY_USE_PATH}/.README
}

#
# main {
#

clear

# select key first
select_key

# Signing...
echo -e "${APPLE_PRE}PV Target Signing start...${APPLE_END}\n"
for image in ${IMAGE_LIST}
do

# For make boot image
if [ -e ${INPUT_PATH}/${image} ];then
  echo -e "\n${GREEN_PRE}=========================================================${GREEN_END}"
  echo -e     "${RED_PRE}${image}${RED_END}\n${GREEN_PRE}+++++++++++${GREEN_END}"

  case ${image} in
    # Sign logo image
    logo)
    #  ./bin/isu            -i   input/logo.bmp                         -o middle/signed_logo.img              -l key/key.pem -t 4
    #  ./bin/xfstk-stitcher -c configs/PV_xfstk_logo_config.txt         -k configs/PV_xfstk_logo.xml
      ;;
    # Sign boot image
    boot.unsigned)
      ./bin/isu            -i   input/boot.unsigned                    -o middle/signed_boot.bin              -l ${KEY_USE_PEM} -t 4
      ./bin/xfstk-stitcher -c configs/PV_xfstk_boot_config.txt         -k configs/PV_xfstk_boot.xml
      ;;
    # Sign droidboot & droidboot.POS image
    droidboot.unsigned)
      ./bin/isu            -i   input/droidboot.unsigned               -o middle/signed_droidboot.img         -l ${KEY_USE_PEM} -t 4
      ./bin/xfstk-stitcher -c configs/PV_xfstk_droidboot_config.txt    -k configs/PV_xfstk_droidboot.xml

      echo -e "${GREEN_PRE}+++++++++++${GREEN_END}\n${RED_PRE}Droidboot.POS${RED_END}\n${GREEN_PRE}+++++++++++${GREEN_END}"
      ./bin/isu            -i   input/droidboot.unsigned               -o middle/signed_droidboot.img.POS.bin -l ${KEY_USE_PEM} -t 4
      ./bin/xfstk-stitcher -c configs/PV_xfstk_droidbootpos_config.txt -k configs/PV_xfstk_droidbootpos.xml
      ;;
    # Sign recovery image
    recovery.unsigned)
      ./bin/isu            -i   input/recovery.unsigned                -o middle/signed_recovery.img          -l ${KEY_USE_PEM} -t 4
      ./bin/xfstk-stitcher -c configs/PV_xfstk_recovery_config.txt     -k configs/PV_xfstk_recovery.xml
      ;;
    *)
      echo -e "${RED_PRE}Unknown input image${RED_END} ${BLUE_PRE}${image}${BLUE_END}\n"
      ;;
  esac
fi

  # For make logo image
  case ${image} in
    logo)
      rm -rf ./logo.list
      find ${INPUT_PATH}/logo -name "*.bmp" | xargs echo >> logo.list
      LOGO_LIST=`cat logo.list`
      MAJOR_REV=1
      if [ -z "${LOGO_LIST}" ] ;then
        echo -e "No logo bitmap files find!"
      else
        for LOGO_FILE in ${LOGO_LIST}
        do  
            LOGO_NAME=`echo $LOGO_FILE|awk -F '/' {'print $4'}`
            ONLY_NAME=`echo $LOGO_NAME|awk -F '.' {'print $1'}`
            echo -e "\n${GREEN_PRE}+++++++++++\n${GREEN_END}${RED_PRE}${ONLY_NAME}-logo${RED_END}\n${GREEN_PRE}+++++++++++${GREEN_END}"
            #echo -e "> ${LOGO_FILE}, NAME: ${LOGO_NAME}, ONLY: ${ONLY_NAME}"
            rm -rf ./${ONLY_NAME}_config.txt ./${ONL_NAME}_platform.xml
            sed -e "s/INPUTFILE_ABCD/signed_${ONLY_NAME}_logo.img/g" ./configs/PV_xfstk_logo.xml        > ./${ONLY_NAME}_platform.xml
            sed -e "s/OUTPUTFILE_ABCD/${ONLY_NAME}-logo.img/g"       ./configs/PV_xfstk_logo_config.txt > ./${ONLY_NAME}_config.txt
            sed -i "s/MAJOR_REV_ABCD/${MAJOR_REV}/"       ./${ONLY_NAME}_platform.xml

            set -x
            ./bin/isu            -i ./input/logo/${ONLY_NAME}.bmp -o middle/signed_${ONLY_NAME}_logo.img -l ${KEY_USE_PEM} -t 4
            ./bin/xfstk-stitcher -c ./${ONLY_NAME}_config.txt     -k ./${ONLY_NAME}_platform.xml
            set +x
            rm -rf ./${ONLY_NAME}_config.txt ./${ONLY_NAME}_platform.xml
        done
        rm -rf ./logo.list
      fi
    ;;
  esac

done
echo -e "${APPLE_PRE}Complete!${APPLE_END}\n"


	# cat key's info
	cat ${KEY_USE_PATH}/.README
#
# }
#
