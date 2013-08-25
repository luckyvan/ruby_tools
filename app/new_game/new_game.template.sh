#!/bin/bash -x

RG_GAME_ID=<%= input_params["from"] %>
GAME_ID=<%= input_params["to"] %>
DEVELOPMENT_ROOT=<%= input_params["root"] %>
DEVELOPMENT_BACK=${DEVELOPMENT_ROOT}/back
GAME_ROOT=${DEVELOPMENT_ROOT}/Games/Game-00${GAME_ID}
PROJ_ROOT=${DEVELOPMENT_ROOT}/projects/Game-00${GAME_ID}
RG_GAME_ROOT=${DEVELOPMENT_ROOT}/Games/Game-00${RG_GAME_ID}
RG_PROJ_ROOT=${DEVELOPMENT_ROOT}/projects/Game-00${RG_GAME_ID}

# new Game Package
if [ -d ${GAME_ROOT} ];then
	mkdir -p ${DEVELOPMENT_BACK}/Games/
	rm ${DEVELOPMENT_BACK}/Games/* -rf
	mv ${GAME_ROOT} ${DEVELOPMENT_BACK}/Games/ 
fi
cp ${RG_GAME_ROOT} ${GAME_ROOT} -rf

for file in $(find ${GAME_ROOT} -name "*${RG_GAME_ID}*")
do 
	newFile=$(echo $file | sed -e "s/${RG_GAME_ID}/${GAME_ID}/g")
	mv $file $newFile
done

grep ${RG_GAME_ID} ${GAME_ROOT} -r | grep -v Binary | grep -v log | cut -d: -f1 | uniq |xargs sed -i "s/${RG_GAME_ID}/${GAME_ID}/g"

# new Project Package
if [ -d ${PROJ_ROOT} ];then
	mkdir -p ${DEVELOPMENT_BACK}/projects/
	rm ${DEVELOPMENT_BACK}/projects/* -rf
	mv ${PROJ_ROOT} ${DEVELOPMENT_BACK}/projects/ 
fi
cp ${RG_PROJ_ROOT} ${PROJ_ROOT} -rf

mv "${PROJ_ROOT}/Game-00${RG_GAME_ID}" "${PROJ_ROOT}/Game-00${GAME_ID}"

for file in $(find ${PROJ_ROOT} -name "*${RG_GAME_ID}*")
do 
	if [ -f $file ]; then
		newFile=$(echo $file | sed -e "s/${RG_GAME_ID}/${GAME_ID}/g")
		mv $file $newFile
	fi	
done

grep ${RG_GAME_ID} ${PROJ_ROOT} -r | grep -v lastbuildstate | grep -v Binary | grep -v log | cut -d: -f1 | uniq |xargs sed -i "s/${RG_GAME_ID}/${GAME_ID}/g"



