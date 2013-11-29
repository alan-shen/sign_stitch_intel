#!/bin/bash

#
# Author: pengru.shen@borqs.com
# Date:   2013/11/03
#

#==========================================================================================================
# DV logo/boot/recovery/droidboot Make Steps:
#++++++++++++++++++++++++++++++++++++++++++++
#                                                                                           
#                                       ####################################################################           
#                                                  INPUT      #       MIDDLE FILE        #        OUTPUT   #                  
#                                       ####################################################################           
#                                       +------------------+     +--------------------+      +-------------+
#                                       |          logo.bmp|     |     signed_logo.img|      |     logo.img|       
#                         1.KERNEL \    +------------------+     +--------------------+      +-------------+
#                        /2.CMDLINE|>>>>|     boot.unsigned|>>>>>|     signed_boot.bin|>>>>>>|     boot.bin|
#          boot_cmdline -|         |    | recovery.unsigned|  ^  | signed_recovery.img|  ^   | recovery.img|
#      recovery_cmdline -|         |    |droidboot.unsigned| /|\ |signed_droidboot.img| /|\  |droidboot.img|
#     droidboot_cmdline -/         |    +------------------+  |  +--------------------+  |   +-------------+-------+
#                                  |                          |                          |   |droidboot.img.POS.bin|
#                        /3.RAMDISK/                          |                          |   +---------------------+
#  ramdisk-recovery.img -|                                    |                          |
#  ramdisk-recovery.img -|                                    |                          |
# ramdisk-droidboot.img -/            ________________________/                          |
#                                    /                                                   |
#                                   /                                                    |
#                          +++++++++                                                     | 
#                          +  ISU  +                                                     |
#                          +++++++++ +----------------------------------------------+    |
#                                    | 1= ISU - Intel Signing Utility               |    |
#                                    | 2= SRC - /device/intel/intel_signing_utility |    |
#                                    | 3= KEY - "./key/key.pem"                     |    |
#                                    +----------------------------------------------+    |
#                                                                                        |
#                                    ____________________________________________________/
#                                   /
#                 ++++++++++++++++++
#                 + xfstk-stitcher +
#                 ++++++++++++++++++ +----------------------------------------------+
#                                    | 1= x86 firmware software tool kit            |
#                                    | 2= SRC - /device/intel/xfstk-stitcher        |
#                                    | 3= CONFIG & XML...                           |
#                                    +----------------------------------------------+
# 
# NOTE: 
# 	This tool(cmdline&configs) is as same as it in "/lfstk/borqs-x86-pv"!!!
# 	
#==========================================================================================================

GREEN_PRE="\033[32;49;1m"
GREEN_END="\033[39;49;0m"
RED_PRE="\033[31;49;1m"
RED_END="\033[31;49;0m"
BLUE_PRE="\033[34;49;1m"
BLUE_END="\033[34;49;0m"
APPLE_PRE="\033[36;49;1m"
APPLE_END="\033[36;49;0m"

INPUT_PATH="./input"
IMAGE_LIST="logo"

#
# main {
#
echo -e "${APPLE_PRE}DV Target Stitching start...${APPLE_END}\n"
for image in ${IMAGE_LIST}
do

#if [ -e ${INPUT_PATH}/${image} ];then
#  echo -e "\n${GREEN_PRE}=========================================================${GREEN_END}"
#  echo -e     "${RED_PRE}${image}${RED_END}\n${GREEN_PRE}+++++++++++${GREEN_END}"
  case ${image} in
    # Sign logo image
    logo)
      rm -rf ./logo.list
      find ${INPUT_PATH} -name "*.bmp" | xargs echo >> logo.list
      LOGO_LIST=`cat logo.list`
      MAJOR_REV=1
      if [ -z "${LOGO_LIST}" ] ;then
        echo -e "No logo bitmap files find!"
      else
        for LOGO_FILE in ${LOGO_LIST}
        do
            LOGO_NAME=`echo $LOGO_FILE|awk -F '/' {'print $3'}`
            ONLY_NAME=`echo $LOGO_NAME|awk -F '.' {'print $1'}`
            #echo -e "> ${LOGO_FILE}, NAME: ${LOGO_NAME}, ONLY: ${ONLY_NAME}"
            echo -e "\n${GREEN_PRE}=========================================================${GREEN_END}"
            echo -e     "${RED_PRE}${ONLY_NAME}-logo${RED_END}\n${GREEN_PRE}+++++++++++${GREEN_END}"
            rm -rf ./${ONLY_NAME}_config.txt ./${ONL_NAME}_platform.xml
            sed -e "s/INPUTFILE_ABCD/${ONLY_NAME}.bmp/g"       ./configs/logo-platform.xml > ./${ONLY_NAME}_platform.xml
	    sed -e "s/OUTPUTFILE_ABCD/${ONLY_NAME}-logo.img/g" ./configs/logo-config.txt   > ./${ONLY_NAME}_config.txt
	    sed -i "s/MAJOR_REV_ABCD/${MAJOR_REV}/"       ./${ONLY_NAME}_platform.xml
            ./bin/xfstk-stitcher -c ./${ONLY_NAME}_config.txt -k ./${ONLY_NAME}_platform.xml
            rm -rf ./${ONLY_NAME}_config.txt ./${ONLY_NAME}_platform.xml
        done
        rm -rf ./logo.list
      fi
      ;;
    *)
      echo -e "${RED_PRE}Unknown input image${RED_END} ${BLUE_PRE}${image}${BLUE_END}\n"
      ;;
  esac
#fi
done
echo -e "${APPLE_PRE}Complete!${APPLE_END}\n"
#
# }
#
