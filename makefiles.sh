	# Set our variables at the top
	file1=/data/public/stuff1/some_file1
        file2=/data/public/stuff2/some_file1
	paths=("sales" "marketing" "operations" "finance" "human_resources")

	# Prompt user for how many files they would like made
	echo How many files would you like to create?
	read N

	# Test to see if files found in stuff directories. If they are delete the directories
	if test -f "$file1" && test -f "$file2"; then
	  sudo rm -rf /data/public/stuff1
	  sudo rm -rf /data/public/stuff2
	fi

        sudo mkdir -p /data/public/stuff1
	sudo mkdir -p /data/public/stuff2
	
	# Loop through and create N specified number of files in both created directories
        for i in $(seq 1 $N)
        do
               sudo dd if=/dev/zero of=/data/public/stuff1/some_file$i bs=10MB count=1
	       sudo dd if=/dev/zero of=/data/public/stuff2/some_file$i bs=10MB count=1
        done

	# Loop through and create directories based off of entries in paths array
	for path in "${paths[@]}"
	do
		sudo mkdir -p /data/groups/$path
	done

	
