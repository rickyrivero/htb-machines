#!/bin/bash

#Colours
greenColour="\e[0;32m"
endColour="\e[0m"
redColour="\e[0;31m"
blueColour="\e[0;34m"
yellowColour="\e[0;33m"
purpleColour="\e[0;35m"
turquoiseColour="\e[0;36m"
grayColour="\e[0;37m"

function ctrl_c(){
  echo -e "\n\n${redColour}[!] Saliendo...${endColour}\n"
  tput cnorm && exit 1
}

# Ctrl + c
trap ctrl_c INT

# Variables globales
main_url="https://htbmachines.github.io/bundle.js"

# Functions

function helpPanel(){
  echo -e "\n${yellowColour}[+]${endColour}${grayColour} Uso:${endColour}"
  echo -e "\t${purpleColour}u)${endColour}${grayColour} Descargar o actualizar archivos necesarios${endColour}"
  echo -e "\t${purpleColour}m)${endColour}${grayColour} Buscar por un nombre de máquina${endColour}"
  echo -e "\t${purpleColour}i)${endColour}${grayColour} Buscar por dirección IP${endColour}"
  echo -e "\t${purpleColour}d)${endColour}${grayColour} Buscar por nivel de dificultad${endColour}"
  echo -e "\t${purpleColour}o)${endColour}${grayColour} Buscar por el sistema operativo${endColour}"
  echo -e "\t${purpleColour}s)${endColour}${grayColour} Buscar por tipo de skill${endColour}"
  echo -e "\t${purpleColour}c)${endColour}${grayColour} Buscar por tipo de certificación${endColour}"
  echo -e "\t${purpleColour}y)${endColour}${grayColour} Obtener link de youtube${endColour}"
  echo -e "\t${purpleColour}h)${endColour}${grayColour} Mostrar panel de ayuda${endColour}\n"
  echo -e "${yellowColour}[+]${endColour}${grayColour} Combinar:${endColour}"
  echo -e "\t${purpleColour}d+o)${endColour}${grayColour} Búsqueda combinada de dificultad y sistema operativo${endColour}\n"
}

function updateFiles(){
  tput civis

  if [ ! -f bundle.js ]; then
    echo -e "\n${yellowColour}[+]${endColour}${grayColour} Descargando archivos necesarios...${endColour}"
    curl -s $main_url > bundle.js
    js-beautify bundle.js | sponge bundle.js
    echo -e "\n${yellowColour}[+]${endColour}${grayColour} Todos los archivos descargados${endColour}"
  else
    echo -e "\n${yellowColour}[+]${endColour}${grayColour} Comprobando actualizaciones...${endColour}"
    sleep 1

    curl -s $main_url > bundle_temp.js
    js-beautify bundle_temp.js | sponge bundle_temp.js
    md5_temp_value=$(md5sum bundle_temp.js | awk '{print $1}')
    md5_original_value=$(md5sum bundle.js | awk '{print $1}')

    if [ "$md5_temp_value" == "$md5_original_value" ]; then
      echo -e "${yellowColour}[+]${endColour}${grayColour} No hay actualizaciones${endColour}"
      rm bundle_temp.js
    else
      echo -e "${yellowColour}[+]${endColour}${grayColour} Hay actualizaciones disponibles${endColour}"
      rm bundle.js && mv bundle_temp.js bundle.js
      sleep 1
      echo -e "${yellowColour}[+] Actualizaciones al día${endColour}"
    fi
  fi
  tput cnorm
}

function searchMachine (){
  machineName="$1"
  
  machineName_checker="$(cat bundle.js | awk "/name: \"$machineName\"/,/resuelta:/" | grep -vE "id:|sku:|resuelta:" | tr -d '"' | tr -d ',' | sed 's/^ *//')"

  if [ "$machineName_checker" ]; then

    echo -e "\n${yellowColour}[+]${endColour}${grayColour} Listando las propiedades de la máquina${endColour}${blueColour} $machineName${endColour}${grayColour}:${endColour}\n"

    cat bundle.js | awk "/name: \"$machineName\"/,/resuelta:/" | grep -vE "id:|sku:|resuelta:" | tr -d '"' | tr -d ',' | sed 's/^ *//'
  else
    echo -e "\n${redColour}[!] La máquina proporcionada no existe${endColour}\n"
  fi
}

function searchIP(){
  ipAddress="$1"
  
  machineName="$(cat bundle.js | grep "ip: \"$ipAddress\"" -B 3 | grep "name: " | awk 'NF{print $NF}' | tr -d '"' | tr -d ',')"

  if [ "$machineName" ]; then
    echo -e "\n${yellowColour}[+]${endColour}${grayColour} La máquina correspondiente para la IP${endColour}${blueColour} $ipAddress${endColour}${grayColour} es${endColour}${purpleColour} $machineName${endColour}"
  else
    echo -e "\n${redColour}[!] La dirección IP proporcionada no existe${endColour}\n"
  fi
}

function getYoutubeLink(){
  machineName="$1"

  youtubeLink="$(cat bundle.js | awk "/name: \"$machineName\"/,/resuelta:/" | grep -vE "id:|sku:|resuelta:" | tr -d '"' | tr -d ',' | sed 's/^ *//' | grep youtube | awk 'NF{print $NF}')"

  if [ "$youtubeLink" ]; then
    echo -e "\n${yellowColour}[+]${endColour}${grayColour} El tutorial de la máquina es:${endColour}${blueColour} $youtubeLink${endColour}\n"
  else
    echo -e "\n${redColour}[!] La máquina proporcionada no existe${endColour}\n"
  fi
}

function difficultyLevel(){
  difficulty="$1"

  result_check="$(cat bundle.js | grep "dificultad: \"$difficulty\"" -B 5 | grep "name: " | tr -d ',' | tr -d '"' | awk 'NF{print $NF}' | column)"

  if [ "$result_check" ]; then
    echo -e "\n${yellowColour}[+]${endColour}${grayColour} Resultados con la dificultad:${endColour}${blueColour} $difficulty${endColour}\n"
    cat bundle.js | grep "dificultad: \"$difficulty\"" -B 5 | grep name | tr -d ',' | tr -d '"' | awk 'NF{print $NF}' | column
  else
    echo -e "\n${redColour}[!] La dificultad proporcionada no existe${endColour}\n"
  fi
}

function getOSMachines(){
  os="$1"
  
  result_os="$(cat bundle.js | grep "so: \"$os\"" -B 5 | grep "name: " | tr -d ',' | tr -d '"' | awk 'NF{print $NF}' | column)"

  if [ "$result_os" ]; then
    echo -e "\n${yellowColour}[+]${endColour}${grayColour} Resultados con el OS:${endColour}${blueColour} $os${endColour}\n"
    cat bundle.js | grep "so: \"$os\"" -B 5 | grep "name: " | tr -d ',' | tr -d '"' | awk 'NF{print $NF}' | column
  else
    echo -e "\n${redColour}[!] El sistema operativo indicado no existe${endColour}\n"
  fi
}

function getOSDifficultyMachines(){
  difficulty="$1"
  os="$2"
  
  check_results="$(cat bundle.js | grep "so: \"$os\"" -C 4 | grep "dificultad: \"$difficulty\"" -B 5 | grep "name: " | tr -d ',' | tr -d '"' | awk 'NF{print $NF}' | column)"

  if [ "$check_results" ]; then
    echo -e "\n${yellowColour}[+]${endColour}${grayColour} Resultados con la dificultad:${endColour}${blueColour} $difficulty${endColour}${grayColour} y el OS:${endColour}${blueColour} $os${endColour}\n"
    cat bundle.js | grep "so: \"$os\"" -C 4 | grep "dificultad: \"$difficulty\"" -B 5 | grep "name: " | tr -d ',' | tr -d '"' | awk 'NF{print $NF}' | column
  else
    echo -e "\n${redColour}[!] Error con los argumentos indicados${endColour}\n"
  fi
}

function getSkill(){
  skill="$1"
  
  check_skill="$(cat bundle.js | grep "skills: " -B 6 | grep "$skill" -i -B 6 | grep "name: " | awk 'NF{print $NF}' | tr -d ',' | tr -d '"' | column)"

  if [ "$check_skill" ]; then
    echo -e "\n${yellowColour}[+]${endColour}${grayColour} Resultados con la skill:${endColour}${blueColour} $skill${endColour}\n"
    cat bundle.js | grep "skills: " -B 6 | grep "$skill" -i -B 6 | grep "name: " | awk 'NF{print $NF}' | tr -d ',' | tr -d '"' | column
  else
    echo -e "\n${redColour}[!] No se ha encontrado ninguna máquina con la skill: $skill${endColour}\n"
  fi
}

function getCertification(){
  certification="$1"

  check_results="$(cat bundle.js | grep "like: " -B 8 | grep "$certification" -i -B 8 | grep "name: " | awk 'NF{print $NF}' | tr -d ',' | tr -d '"' | column)"
  
  if [ "$check_results" ]; then
    echo -e "\n${yellowColour}[+]${endColour}${grayColour} Resultados con la certificación:${endColour}${blueColour} $certification${endColour}\n"
    cat bundle.js | grep "like: " -B 8 | grep "$certification" -i -B 8 | grep "name: " | awk 'NF{print $NF}' | tr -d ',' | tr -d '"' | column
  else
    echo -e "\n${redColour}[!] No se ha encontrado ninguna máquina con la certificación: $certification${endColour}\n"
  fi

}

# Indicadores
declare -i parameter_counter=0

# Chivatos
declare -i chivato_difficulty=0
declare -i chivato_os=0

while getopts "m:ui:y:d:o:s:c:h" arg; do
  case $arg in
    m) machineName="$OPTARG"; let parameter_counter+=1;;
    u) let parameter_counter+=2;;
    i) ipAddress="$OPTARG"; let parameter_counter+=3;;
    y) machineName="$OPTARG"; let parameter_counter+=4;;
    d) difficulty="$OPTARG"; chivato_difficulty=1; let parameter_counter+=5;;
    o) os="$OPTARG"; chivato_os=1; let parameter_counter+=6;;
    s) skill="$OPTARG"; let parameter_counter+=7;;
    c) certification="$OPTARG"; let parameter_counter+=8;;
    h) ;;
  esac
done

if [ $parameter_counter -eq 1 ]; then
  searchMachine $machineName
elif [ $parameter_counter -eq 2 ]; then
  updateFiles
elif [ $parameter_counter -eq 3 ]; then
  searchIP $ipAddress
elif [ $parameter_counter -eq 4 ]; then
  getYoutubeLink $machineName
elif [ $parameter_counter -eq 5 ]; then
  difficultyLevel $difficulty
elif [ $parameter_counter -eq 6 ]; then
  getOSMachines $os
elif [ $parameter_counter -eq 7 ]; then
  getSkill "$skill"
elif [ $parameter_counter -eq 8 ]; then
  getCertification $certification
elif [ $chivato_difficulty -eq 1 ] && [ $chivato_os -eq 1 ]; then
  getOSDifficultyMachines $difficulty $os
else
  helpPanel
fi
