	# Anthony Manenti - NOS125-150 SP23
	# Shell script for file and folder creation.

	# Set our variables at the top
	file1=/data/public/stuff1/some_file1
        file2=/data/public/stuff2/some_file1
	paths=("sales" "marketing" "operations" "finance" "human_resources")
	optional_folders=()

        # HELPERS
        # Boolean and while loop keeps calling nested create function. Allows user to add optional folders until they are finished.
        create_additional_folders() {
          should_continue=true
          
            create() {
              for folder in "${optional_folders[@]}"; do
                sudo mkdir -p /data/groups/$folder
              done
                echo Okay! Our work here is done.
                should_continue=false
            }

	# Push to optional folders array unless user inputs 'done'  
          while $should_continue; do
            read -p "enter a folder name to add the folder, or type done to complete this process " input
            case $input in 
                done ) clear; create;;
                   * ) clear; optional_folders+=("$input")
            esac
          done
       }

	# Flow control basically, call looping function to keep adding if yes, bounce em out if no.
	prompt_for_additional_folders() {
	 read -p "Default folders created! Would you like to create additional folders? (y/n) " yn
	  case $yn in 
	    [yY] ) create_additional_folders;;
	    [nN] ) echo Great! our work here is finished!;;
	       * ) echo invalid response;;
          esac
	}
	
	# Creates default folders if user indicates they want them, and also starts stack for adding custom folders.
	make_folders() { 
         for path in "${paths[@]}"
           do
             sudo mkdir -p /data/groups/$path
           done
           prompt_for_additional_folders
        }

	# Gotta know if the user is actually inputting integers when we need em.
	validate_num() {
	  isnum='^[0-9]+$'
	    if ! [[ $1 =~ $isnum ]] ; then
   	      echo "error: Not a number.Try again."
   	      sleep 2; $2
   	    else
   	      clear; $3 
	    fi
	}
	
	# MAIN LOGIC FLOW. 
	# We use the flow to call helper functions when we need em, easier to deal with than nesting deeply.

	kick_off_flow() {
	  clear
	  # Prompt user for how many files they would like made
	  echo "How many files would you like to create? [must be an integer]. "
	  read N
	  validate_num $N kick_off_flow get_file_size
        }
	
 	get_file_size() {
	  # Prompt user for the size of filed in MB we are creating
	  echo "How many MBs would you like the files to be? [must be an integer]. "
	  read S
	  validate_num $S get_file_size
	}
	
	kick_off_flow

	# Test to see if files found in stuff directories. If they are delete the directories
	if test -f "$file1" || test -f "$file2"; then
	  read -p "Files are already present in the target directories. If you continue existing files will be deleted. Are you sure you wish to continue? (y/n). " yn
	  case $yn in 
	    [yY] ) sudo rm -rf /data/public/stuff1; sudo rm -rf /data/public/stuff2;;
	    [nN] ) echo exiting script now; exit 1;;
	       * ) echo invalid response;;
          esac
	fi

	sudo mkdir -p /data/public/stuff{1,2}
	
	# Loop through and create N specified number of files in both created directories
        for i in $(seq 1 $N); do
          sudo dd if=/dev/zero of=/data/public/stuff1/some_file$i bs=$S count=1
	  sudo dd if=/dev/zero of=/data/public/stuff2/some_file$i bs=$S count=1
        done
        clear
        
	# Ask user if they want the default folders.
	read -p "Would you like to create a set of default folders in data/groups? You will also be given the chance to create custom folders. (y/n) " yn
          case $yn in
            [yY] ) make_folders;;
            [nN] ) echo Okay! Our work here is done.;;
               * ) echo invalid response;;
          esac

