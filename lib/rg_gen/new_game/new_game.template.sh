#!/bin/bash -x

RG_GAME_ID=<%= rgid %>
GAME_ID=<%= gid %>
ROOT=<%= root %>
GAME_ROOT=./Gen/Development/Games/Game-00${GAME_ID}
PROJ_ROOT=./Gen/Development/projects/Game-00${GAME_ID}
RG_GAME_ROOT=${ROOT}/Games/Game-00${RG_GAME_ID}
RG_PROJ_ROOT=${ROOT}/projects/Game-00${RG_GAME_ID}


# new Game Package
mkdir -p ./Gen/Development/Games
mkdir -p ./Gen/Development/projects

cp ${RG_GAME_ROOT} ${GAME_ROOT} -rf

for file in $(find ${GAME_ROOT} -name "*${RG_GAME_ID}*")
do 
	newFile=$(echo $file | sed -e "s/${RG_GAME_ID}/${GAME_ID}/g")
	mv $file $newFile
done

grep ${RG_GAME_ID} ${GAME_ROOT} -r | grep -v Binary | grep -v log | cut -d: -f1 | uniq |xargs sed -i "s/${RG_GAME_ID}/${GAME_ID}/g"

# new Project Package
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



