# Anthony Manenti - NOS125-150 SP23
# Shell script for file and folder creation.

## MARK: FILE AND FOLDER CREATION

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
    [nN])
        echo "Great! our work here is finished!"
        his_name_is_callboy
        ;;
    *) echo "invalid response; prompt_for_additional_folders" ;;
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
        echo error: Not a number. Try again.
        sleep 1
        $2
    else
        clear
        $3
    fi
}

# Ask user if they want the default folders.
prompt_for_folders() {
    read -p "Would you like to create a set of default folders in data/groups? (y/n) " yn
    case $yn in
    [yY]) make_folders ;;
    [nN])
        echo Okay! Our work here is done.
        his_name_is_call_boy
        ;;
    *)
        echo invalid response
        prompt_for_folders
        ;;
    esac
}

# Create the files and call the prompt which allows users to decide if they want default folders created.
create_files() {
    sudo mkdir -p /data/public/stuff{1,2}
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
        [nN]) his_name_is_callboy ;;
        *) test_existing_files ;;
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

## MARK: HOSTNAMES

# Allows user to set hostname
set_hostname() {
    inval_guard=true
    read -p "Please enter your hostname : " hostname
    while $inval_guard; do
        read -p "Your new hostname will be : $hostname. Please confirm this change. (y/n) (q: quit without saving) " ynq
        case $ynq in
        [yY])
            inval_guard=false
            echo "Changing hostname now" hostnamectl set-hostname $hostname
            his_name_is_callboy
            ;;
        [nN])
            inval_guard=false
            echo "Okay, let's try again."
            set_hostname
            ;;
        [qQ])
            inval_guard=false
            his_name_is_callboy
            ;;
        *) echo invalid response ;;
        esac
    done
}

## MARK: NETWORKING

### TODO: logic for formatting nmcli
network_config_wizard() {
    echo "I need to build this"
}

# allows user to use our wizard for network config through nmcli command formatting, or opt to use nmcli
configure_networking() {
    clear
    echo -e "\n1) I want to use this script to configure network settings \n2) I want to use nmtui to configure network settings \n3) Quit \n"
    read -p "How can I help you today? " input
    case $input in
    1)
        network_config_wizard
        ;;
    2)
        nmtui
        ;;
    3)
        his_name_is_call_boy
        ;;
    *)
        echo "invalid option"
        configure_networking
        ;;
    esac
}

## MARK: CALLER

# Gives us the multi option prompt and allows us to call functions as we need them.
# This kind of pattern is useful, because it allows us to block everything away and work on one piece at a time.
# We don't have to worry about massive entangled blocks. It's a caller basically.
his_name_is_callboy() {
    clear
    echo -e "\n1) Set Hostname\n2) Create Files and Folders\n3) Create Optional Folders\n4) Configure Networking\n5) Quit)\n"
    read -p "Welcome! What would you like to do? " input
    case $input in
    1)
        set_hostname
        ;;
    2)
        kick_off_flow
        ;;
    3)
        create_additional_folders
        ;;
    4)
        configure_networking
        ;;
    5)
        exit
        ;;
    *)
        echo "invalid option"
        sleep 1
        his_name_is_callboy
        ;;
    esac
}

his_name_is_callboy
