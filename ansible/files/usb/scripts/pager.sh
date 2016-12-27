#!/bin/bash

FILE="${1}"
FOOTER="n = next page, p = previous page, q = quit       "
FOOTER_MSG="After pressing 'q' (quit) you will be able to accept or decline the license."
TOTAL=$(cat ${FILE} | wc -l | tr -d '[[:space:]]')
ROWS=$(tput lines)
ROWS=$((ROWS-5))
START=1
END=$((ROWS+1))

print_page() {
	percentage=$((END*100/TOTAL))
	position="lines ${START}-${END}/${TOTAL} (${percentage}%)"

	clear
	sed -n "${START},${END}p" "${FILE}"
	printf "\033[30;47m%s %-26s\033[0m\n" "${FOOTER}" "${position}"
	printf "\033[37;100m%s\033[0m" "${FOOTER_MSG}"
}

if [[ ${ROWS} -ge ${TOTAL} ]]; then
	cat "${FILE}"
	echo -e "\033[30;47mlines ${START}-${TOTAL}/${TOTAL}\033[0m"
	exit 0
fi

print_page

while true; do
	read -n 1 key

	case "${key}" in
		p|P)
			start=$((START-ROWS))

			if [[ ${start} -le 1 ]]; then
				START=1
				END=$((ROWS+1))
			else
				END=${START}
				START=${start}
			fi

			print_page
			;;
		n|N)
			end=$((END+ROWS))

			if [[ ${end} -ge ${TOTAL} ]]; then
				START=$((TOTAL-ROWS))
				END=${TOTAL}
			else
				START=${END}
				END=${end}
			fi

			print_page
			;;
		q|Q)
			exit 0
			;;
		*)
			echo -en "\a"
			;;
	esac
done
