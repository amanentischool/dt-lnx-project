
	FILE1=/data/public/stuff1/some_file1
        FILE2=/data/public/stuff2/some_file1

	echo How many files would you like to create?
	read N

	if test -f "$FILE1" && test -f "$FILE2"; then
	  sudo rm -rf /data/public/stuff1
	  sudo rm -rf /data/public/stuff2
	fi

        sudo mkdir -p /data/public/stuff1
	sudo mkdir -p /data/public/stuff2

        for i in $(seq 1 $N)
        do
               sudo dd if=/dev/zero of=/data/public/stuff1/some_file$i bs=10MB count=1
	       sudo dd if=/dev/zero of=/data/public/stuff2/some_file$i bs=10MB count=1
        done
