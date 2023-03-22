        cd
        mkdir stuff

        for i in {1..5}
        do
                dd if=/dev/zero of=/home/$USER/stuff/some_file$i bs=10MB count=1
        done
