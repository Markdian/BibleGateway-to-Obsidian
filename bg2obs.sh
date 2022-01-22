#!/bin/bash
#----------------------------------------------------------------------------------
# Este script corre el script en ruby de Janathan Clark bg2md.rb
# para hacerlo usable en Obsidian. Encuentra el script en https://github.com/jgclark/BibleGateway-to-Markdown
#
# Es necesario correr el script 'bg2md.rb' en el mismo directorio para generar
# un archivo .md por cada capitulo, organizandolos en sus carpetas correspondientes.
#
# Navigation on the top and bottom is also added.
#
#----------------------------------------------------------------------------------
# SETTINGS
#----------------------------------------------------------------------------------
# Para indicar una version o traduccion diferente
# Usando la abreviacion -v, puedes llamar una version o idioma diferente.
# La version por defecto es la "World English Bible".
# Si quieres cambiar de version o idioma asegurate de respetar las restricciones de derecho de author.
#----------------------------------------------------------------------------------

usage()
{
	echo "Usage: $0 [-beaih] [-v version]"
	echo "  -v version   Specify the translation to download (default = WEB)"
	echo "  -b    Set words of Jesus in bold"
	echo "  -e    Include editorial headers"
	echo "  -a    Create an alias in the YAML front matter for each chapter title"
	echo "  -i    Show download information (i.e. verbose mode)"
	echo "  -h    Display help"
	exit 1
}

# Extract command line options

# Clear translation variable if it exists and set defaults for others
translation='RVR1960'    # Which translation to use
boldwords="false"    # Set words of Jesus in bold
headers="false"      # Include editorial headers
aliases="false"      # Create an alias in the YAML front matter for each chapter title
verbose="true"      # Show download progress for each chapter

# Process command line args
while getopts 'v:beai?h' c
do
	case $c in
		v) translation=$OPTARG ;;
		b) boldwords="true" ;;
		e) headers="true" ;;
		a) aliases="true" ;;
		i) verbose="true" ;;
		h|?) usage ;; 
	esac
done

# Inicializar las variables
book_counter=0 # Establecer el contador en 0
book_counter_max=66 # Establecer la cantidad maxima en 66 libros

# Lista de libros
declare -a bookarray # Declarando los Libros de la Biblia como una lista
declare -a abbarray # Declarar las abreviaturas de cada libro. Puedes adaptarlas si quieres
declare -a lengtharray # Declarar la cantidad de capítulos en cada libro

# -------------------------------------------
# TRANSLATION: Lists of Names
# -------------------------------------------
# For Translation, translate these three lists. Seperated by space and wrapped in quotes if they include whitespace.
# Nombre de "La Biblia" en tu idioma
biblename="La Biblia"
numberarray=("01 - " "02 - " "03 - " "04 - " "05 - " "06 - " "07 - " "08 - " "09 - " "10 - " "11 - " "12 - " "13 - " "14 - " "15 - " "16 - " "17 - " "18 - " "19 - " "20 - " "21 - " "22 - " "23 - " "24 - " "25 - " "26 - " "27 - " "28 - " "29 - " "30 - " "31 - " "32 - " "33 - " "34 - " "35 - " "36 - " "37 - " "38 - " "39 - " "40 - " "41 - " "42 - " "43 - " "44 - " "45 - " "46 - " "47 - " "48 - " "49 - " "50 - " "51 - " "52 - " "53 - " "54 - " "55 - " "56 - " "57 - " "58 - " "59 - " "60 - " "61 - " "62 - " "63 - " "64 - " "65 - " "66 - ")
# Nombres completos de los libros de la Biblia
bookarray=(Génesis Éxodo Levítico Números Deuteronomio Josué Jueces Rut "1 Samuel" "2 Samuel" "1 Reyes" "2 Reyes" "1 Crónicas" "2 Crónicas" Esdras Nehemías Ester Job Salmos Proverbios Eclesiastés Cantares Isaías Jeremías Lamentaciones Ezequiel Daniel Oseas Joel Amós Abdías Jonás Miqueas Nahúm Habacuc Sofonías Hageo Zacarías Malaquías "San Mateo" "San Marcos" "San Lucas" "San Juan" Hechos Romanos "1 Corintios" "2 Corintios" Gálatas Efesios Filipenses Colosenses "1 Tesalonicenses" "2 Tesalonisences" "1 Timoteo" "2 Timoteo" Tito Filemón Hebreos Santiago "1 Pedro" "2 Pedro" "1 Juan" "2 Juan" "3 Juan" Judas Apocalipsis)
# Nombres cortos de los libros de la Biblia
abbarray=(Gen Exod Lev Num Deut Jos Jue Rut "1 Sam" "2 Sam" "1 Rey" "2 Rey" "1 Cron" "2 Cron" Esd Neh Est Job Sal Prov Ecl Cant Isa Jer Lam Ezeq Dan Os Joel Am Abd Jon Miq Nah Hab Sof Hag Zac Mal Mat Mar Luc Jn Hech Rom "1 Cor" "2 Cor" Gal Ef Fil Col "1 Tes" "2 Tes" "1 Tim" "2 Tim" Tito Filem Heb Sant "1 Ped" "2 Ped" "1 Jn" "2 Jn" "3 Jn" Jud Apoc)
# -------------------------------------------

# Lista de capítulos de libros
lengtharray=(50 40 27 36 34 24 21 4 31 24 22 25 29 36 10 13 10 42 150 31 12 8 66 52 5 48 12 14 3 9 1 4 7 3 3 3 2 14 4 28 16 24 21 28 16 16 13 6 6 4 4 5 3 6 4 3 1 13 5 5 3 5 1 1 1 22)


# Initialise the "The Bible" file for all of the books
echo -e "# ${biblename}\n" >> "${biblename}.md"

if ${verbose} -eq "true"; then
	echo "Descarga puesta en marcha de la biblia ${translation}."
fi

 # Recorre el contador de libros y configurando el libro y la cantidad de capitulos
  for ((book_counter=0; book_counter <= book_counter_max; book_counter++))
  do

	if ${verbose} -eq "true"; then
		echo ""   # Make a new line which the '-n' flag to the echo command prevents.
	fi

    book=${bookarray[$book_counter]}
    numberbook=${numberarray[book_counter]}
    maxchapter=${lengtharray[$book_counter]}
    abbreviation=${abbarray[$book_counter]}

	if ${verbose} -eq "true"; then
		echo -n "${book} "
	fi

    for ((chapter=1; chapter <= maxchapter; chapter++))
    do

    	if ${verbose} -eq "true"; then
    		echo -n "."
		fi

((prev_chapter=chapter-1)) # Counting the previous and next chapter for navigation
((next_chapter=chapter+1))

# Exporting
  export_prefix="${abbreviation} " # Setting the first half of the filename
filename=${export_prefix}$chapter # Setting the filename


  prev_file=${export_prefix}$prev_chapter # Naming previous and next files
  next_file=${export_prefix}$next_chapter

  # Formatting Navigation and omitting links that aren't necessary
  if [ ${maxchapter} -eq 1 ]; then
    # For a book that only has one chapter
    navigation="[[${book}]]"
  elif [ ${chapter} -eq ${maxchapter} ]; then
    # If this is the last chapter of the book
    navigation="[[${prev_file}|← ${book} ${prev_chapter}]] | [[${book}]]"
  elif [ ${chapter} -eq 1 ]; then
    # If this is the first chapter of the book
    navigation="[[${book}]] | [[${next_file}|${book} ${next_chapter} →]]"
  else
    # Navigation for everything else
    navigation="[[${prev_file}|← ${book} ${prev_chapter}]] | [[${book}]] | [[${next_file}|${book} ${next_chapter} →]]"
  fi

  if ${boldwords} -eq "true" && ${headers} -eq "false"; then
    text=$(ruby bg2md.rb -e -c -b -f -l -r -v "${translation}" ${book} ${chapter}) # This calls the 'bg2md_mod' script
  elif ${boldwords} -eq "true" && ${headers} -eq "true"; then
    text=$(ruby bg2md.rb -c -b -f -l -r -v "${translation}" ${book} ${chapter}) # This calls the 'bg2md_mod' script
  elif ${boldwords} -eq "false" && ${headers} -eq "true"; then
    text=$(ruby bg2md.rb -e -c -f -l -r -v "${translation}" ${book} ${chapter}) # This calls the 'bg2md_mod' script
  else
    text=$(ruby bg2md.rb -e -c -f -l -r -v "${translation}" ${book} ${chapter}) # This calls the 'bg2md_mod' script
  fi


  text=$(echo $text | sed 's/^(.*?)v1/v1/') # Deleting unwanted headers

  # Formatting the title for markdown
  title="# ${book} ${chapter}"

  # Navigation format
  export="${title}\n\n$navigation\n***\n\n$text\n\n***\n$navigation"
  if ${aliases} -eq "true"; then
    alias="---\nAliases: [${book} ${chapter}]\n---\n" # Add other aliases or 'Tags:' here if desired. Make sure to follow proper YAML format.
    export="${alias}${export}"
  fi
  

  # Export
  echo -e $export >> "$filename.md"

  # Creating a folder

  folder_name="${book}" # Setting the folder name

  # Creating a folder for the book of the Bible if it doesn't exist, otherwise moving new file into existing folder
  mkdir -p "./${biblename} (${translation})/${numberbook}${folder_name}"; mv "${filename}".md "./${biblename} (${translation})/${numberbook}${folder_name}"


done # End of the book exporting loop

  # Create an overview file for each book of the Bible:
  overview_file="Regresa a: [[${biblename}]]\n# ${book}\n\n[[${abbreviation} 1| Empieza a leer la Biblia →]]"
  echo -e $overview_file >> "$book.md"
  mv "$book.md" "./${biblename} (${translation})/${numberbook}${folder_name}"

  # Append the bookname to "The Bible" file
  echo -e "* [[${book}]]" >> "${biblename}.md"
  done

# Tidy up the Markdown files by removing unneeded headers and separating the verses
# with some blank space and an H6-level verse number.
#
# Using a perl one-liner here in order to help ensure that this works across platforms
# since the sed utility works differently on macOS and Linux variants. The perl should
# work consistently.

if ${verbose} -eq "true"; then
	echo ""
	echo "Cleaning up the Markdown files."
fi
# Clear unnecessary headers
find . -name "*.md" -print0 | xargs -0 perl -pi -e 's/#.*(#####\D[1]\D)/#$1/g'

# Format verses into H6 headers
find . -name "*.md" -print0 | xargs -0 perl -pi -e 's/######\s([0-9]\s|[0-9][0-9]\s|[0-9][0-9][0-9]\s)/\n\n###### $1\n/g'

# Delete crossreferences
find . -name "*.md" -print0 | xargs -0 perl -pi -e 's/\<crossref intro.*crossref\>//g'

if ${verbose} -eq "true"; then
echo "Descarga completa. Los archivos Markdown estan listos para ser usados en Obsidian."
fi
