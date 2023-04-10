        sudo mkdir -p /data/public/stuff1
	sudo mkdir -p /data/public/stuff2

        for i in {1..10}
        do
               sudo dd if=/dev/zero of=/data/public/stuff1/some_file$i bs=10MB count=1
	       sudo dd if=/dev/zero of=/data/public/stuff2/some_file$i bs=10MB count=1
        done
