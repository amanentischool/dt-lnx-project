# Anthony Manenti - NOS125-150 SP23
# Interactive Shell program combining all of our script and setup tasks into a fun lil' ride. Weee. 

# Create additional folders if user wants folders outside of defaults.
create_additional_folders() {
    optional_folders=()
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
        done)
            clear
            create
            ;;
        *)
            clear
            optional_folders+=("$input")
            ;;
        esac
    done
}

# Flow control basically, call looping function to keep adding if yes, bounce em out if no.
prompt_for_additional_folders() {
    read -p "Default folders created! Would you like to create additional folders? (y/n) " yn
    case $yn in
    [yY]) create_additional_folders ;;
    [nN]) echo Great! our work here is finished! ;;
    *) echo invalid response ;;
    esac
}

# Creates default folders if user indicates they want them, and also starts stack for adding custom folders.
make_folders() {
    paths=("sales" "marketing" "operations" "finance" "human_resources")
    for path in "${paths[@]}"; do
        sudo mkdir -p /data/groups/$path
    done
}

# Gotta know if the user is actually inputting integers when we need em.
validate_num() {
    isnum='^[0-9]+$'
    if ! [[ $1 =~ $isnum ]]; then
        echo "error: Not a number.Try again."
        sleep 1
        $2
    else
        clear
        $3
    fi
}

# Ask user if they want the default folders. If they indicate yes, we make them.
prompt_for_folders() {
    read -p "Would you like to create a set of default folders in data/groups? (y/n) " yn
    case $yn in
    [yY]) make_folders ;;
    [nN]) echo Okay! Our work here is done. ;;
    *) echo invalid response ;;
    esac
}

# Create the files and call the prompt which allows users to decide if they want default folders created.
create_files() {
    echo "is at create_files"
    sudo mkdir -p /data/public/stuff{1,2}
    # Loop through and create N specified number of files in both created directories
    for i in $(seq 1 $N); do
        sudo dd if=/dev/zero of=/data/public/stuff1/some_file$i bs=$S count=1
        sudo dd if=/dev/zero of=/data/public/stuff2/some_file$i bs=$S count=1
    done
    prompt_for_folders
}

# Test to see if there are already files present in target directories. Ask for confirmation before blowing them away.
test_existing_files() {
    file1=/data/public/stuff1/some_file1
    file2=/data/public/stuff2/some_file1
    # Test to see if files found in stuff directories. If they are delete the directories
    if test -f "$file1" || test -f "$file2"; then
        read -p "Files are already present in the target directories. If you continue existing files will be deleted. Are you sure you wish to continue? (y/n). " yn
        case $yn in
        [yY])
            sudo rm -rf /data/public/stuff{1,2}
            create_files
            ;;
        [nN])
            echo exiting script now
            exit 1
            ;;
        *) echo invalid response ;;
        esac
    else
        create_files
    fi
}

# Ask for file size in MB, send to validate.
get_file_size() {
    echo "How many MBs would you like the files to be? [must be an integer]. "
    read S
    validate_num $S get_file_size test_existing_files
}

# Kicks off file and default folder creation chain, sends user input to validate.
kick_off_flow() {
    echo "How many files would you like to create? [must be an integer]. "
    read N
    validate_num $N kick_off_flow get_file_size
}

# Gives us the multi option prompt and allows us to call functions as we need them.
# This kind of pattern is useful, because it allows us to block everything away and work on one piece at a time.
# We don't have to worry about massive entangled blocks. It's a caller basically.
his_name_is_callboy() {
    echo -e "\n1) Create Files and Folders\n2) Create Optional Folders\n3) Do This Later\n4) Quit)"
    read -p "Welcome! What would you like to do? " input
    case $input in
    1)
        echo "Very well. Let's get to work, shall we?"
        kick_off_flow
        ;;
    2)
        echo "Alrighty... here we go"
        create_additional_folders
        ;;
    3)
        echo "Well. I don't know what to do with this."
        # optionally call a function or run some code here
        ;;
    4)
        echo "I'm so lonely."
        exit
        ;;
    *) echo "invalid option $REPLY" ;;
    esac
}

# He is the one who calls.
his_name_is_callboy
