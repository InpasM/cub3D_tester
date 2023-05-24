#! /bin/bash

YELB='\033[1;33m'

BLK='\033[0;30m'

BWHT='\033[1;37m'
BRED='\033[1;31m'
BGRN='\033[1;32m'

NOCOLOR='\033[0m'

##### ARGUMENTS #####
if [[ "$1" == "leaks" ]]
then
	LEAKS=1
else
	LEAKS=0
fi

SLEEP=0.1

BASEDIR=$(dirname "$0")

INVALID_MAP="${BASEDIR}/maps/non_existing_map"
SIMPLE_MAP="${BASEDIR}/maps/simple_map.cub"

NAME_CUB3D=( 		
					"no argument:  ./cub3d"
					"too many arguments:  ./cub3d argument1 argument2"
					"invalid extension 1:  ./cub3d maps/map"
					"invalid extension 2:  ./cub3d maps/map."
					"invalid extension 3:  ./cub3d maps/map.c"
					"invalid extension 4:  ./cub3d maps/map.cu"
					"invalid extension 5:  ./cub3d maps/map.cube"
					"invalid extension 6:  ./cub3d maps/map.cub.cube"

					"non existing map:  ./cub3d maps/non_existing_map.cub"
					"invalid folder:  ./cub3d invalid_folder/map.cub"

					"missing texture 1:  ./cub3d ${BASEDIR}/maps/missing_north.cub"
					"missing texture 2:  ./cub3d ${BASEDIR}/maps/missing_south.cub"
					"missing texture 3:  ./cub3d ${BASEDIR}/maps/missing_west.cub"
					"missing texture 4:  ./cub3d ${BASEDIR}/maps/missing_east.cub"
					"missing all textures:  ./cub3d ${BASEDIR}/maps/missing_all_texture.cub"

					"missing rgb floor:  ./cub3d ${BASEDIR}/maps/missing_rgb_floor.cub"
					"missing rgb roof:  ./cub3d ${BASEDIR}/maps/missing_rgb_roof.cub"
					"missing all rgb:  ./cub3d ${BASEDIR}/maps/missing_all_rgb.cub"

					"invalid texture 1:  ./cub3d ${BASEDIR}/maps/invalid_north.cub"
					"invalid texture 2:  ./cub3d ${BASEDIR}/maps/invalid_south.cub"
					"invalid texture 3:  ./cub3d ${BASEDIR}/maps/invalid_west.cub"
					"invalid texture 4:  ./cub3d ${BASEDIR}/maps/invalid_east.cub"

					"invalid multi texture 1:  ./cub3d ${BASEDIR}/maps/invalid_multi_1.cub"
					"invalid multi texture 2:  ./cub3d ${BASEDIR}/maps/invalid_multi_2.cub"
					"invalid multi texture 3:  ./cub3d ${BASEDIR}/maps/invalid_multi_3.cub"

					"invalid rgb floor:  ./cub3d ${BASEDIR}/maps/invalid_rgb_floor.cub"
					"invalid rgb roof:  ./cub3d ${BASEDIR}/maps/invalid_rgb_roof.cub"
					"invalid both rgb:  ./cub3d ${BASEDIR}/maps/invalid_both_rgb.cub"

					"no map info:  ./cub3d ${BASEDIR}/maps/no_map.cub"
					"map not wide enough:  ./cub3d ${BASEDIR}/maps/not_wide_enough.cub"
					"map not long enough:  ./cub3d ${BASEDIR}/maps/not_long_enough.cub"
					"no starting point:  ./cub3d ${BASEDIR}/maps/no_starting_point.cub"
					"more than one starting point:  ./cub3d ${BASEDIR}/maps/more_than_one_starting_point.cub"
					"invalid character:  ./cub3d ${BASEDIR}/maps/invalid_char.cub"

					"map not close 1:  ./cub3d ${BASEDIR}/maps/no_surrounded_1.cub"
					"map not close 2:  ./cub3d ${BASEDIR}/maps/no_surrounded_2.cub"
					"map not close 3:  ./cub3d ${BASEDIR}/maps/no_surrounded_3.cub"
					"map not close 4:  ./cub3d ${BASEDIR}/maps/no_surrounded_4.cub"
					"map not close 5:  ./cub3d ${BASEDIR}/maps/no_surrounded_5.cub"
					)

PRINT_CATEGORY()
{
	NAME=$1
	printf "${BLK}\n# ###################################### #\n"
	printf "#$BWHT		   TESTS	 	 $BLK#\n"
	printf "#$BWHT		   %s		 $BLK#\n" "$NAME"
	printf "# ###################################### #$NOCOLOR\n\n"
}

$(norminette > /dev/null 2>&1)
if [ "$?" -gt "0" ]
then
	CHECK_NORM="\n${BRED}NORME: KO${NOCOLOR}\n"
else
	CHECK_NORM="\n${BGRN}NORME: OK${NOCOLOR}\n"
fi

make -s -C ../
clear

PRINT_CATEGORY "CUB3D"
sleep $SLEEP
i=0
NUM_OK=0
NUM_KO=0
while [ $i -ne ${#NAME_CUB3D[@]} ]
do
	CMD_CUB3D=$(echo "${NAME_CUB3D[i]}" | cut -d ":" -f 2)
	DISPLAY_CUB3D=$(eval "zsh -c '$CMD_CUB3D'" 2>&1)

	if [ -z "$DISPLAY_CUB3D" ]
	then
		printf "\n\n${BRED}"
		NUM_KO=$((NUM_KO+1))
	else
		printf "\n\n${BGRN}"
		NUM_OK=$((NUM_OK+1))
	fi

	printf "Test nº$i :	${NAME_CUB3D[i]}${NOCOLOR}\n\n"
	printf "$DISPLAY_CUB3D\n"

	if [[ "$LEAKS" == 1 ]]
	then
		DISPLAY_LEAKS=$(eval "zsh -c 'valgrind --leak-check=full --show-leak-kinds=all $CMD_CUB3D'" 2>&1)
		SHORT_LEAK=$(echo "$DISPLAY_LEAKS" | grep -e "ERROR SUMMARY:" -e "total heap usage:")
	fi

	if [[ "$LEAKS" == 1 ]]
	then
		printf "\n${YELB}LEAK check:${NOCOLOR}\n$SHORT_LEAK\n"
	fi

	i=$((i+1))
	sleep $SLEEP
done

if [[ "$NUM_KO" -gt 0 ]]
then
	printf "${BRED}"
else
	printf "${BGRN}"
fi

printf "\n\n\nTEST OK: ${NUM_OK} / ${#NAME_CUB3D[@]}${NOCOLOR}\n"

printf "${CHECK_NORM}"