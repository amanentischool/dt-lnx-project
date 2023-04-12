	# Set our variables at the top
	file1=/data/public/stuff1/some_file1
        file2=/data/public/stuff2/some_file1
	paths=("sales" "marketing" "operations" "finance" "human_resources")

	# HELPERS
	make_folders () { 
         for path in "${paths[@]}"
           do
             sudo mkdir -p /data/groups/$path
           done
        }		

	# Prompt user for how many files they would like made
	echo How many files would you like to create? [must be an integer]
	read N

	isnum='^[0-9]+$'

	if ! [[ $N =~ $isnum ]] ; then
   	  echo "error: Not a number" >&2; exit 1
	fi	

	# Test to see if files found in stuff directories. If they are delete the directories
	if test -f "$file1" && test -f "$file2"; then
	  read -p "Files are already present in the target directories. If you continue existing files will be deleted. Are you sure you wish to continue? (y/n) " yn
	  case $yn in 
	    [yY] ) sudo rm -rf /data/public/stuff1; sudo rm -rf /data/public/stuff2
	    break;;
	    [nN] ) echo aborting script;
	    exit;;
	    * ) echo invalid response;;
          esac
	fi

        sudo mkdir -p /data/public/stuff1
	sudo mkdir -p /data/public/stuff2
	
	# Loop through and create N specified number of files in both created directories
        for i in $(seq 1 $N)
        do
               sudo dd if=/dev/zero of=/data/public/stuff1/some_file$i bs=10MB count=1
	       sudo dd if=/dev/zero of=/data/public/stuff2/some_file$i bs=10MB count=1
        done


	read -p "Would you like this script to create additional directories for you in /data/groups ?" yn
          case $yn in
            [yY] ) make_folders
            [nN] ) echo aborting script;
            exit;;
            * ) echo invalid response;;
          esac
	
