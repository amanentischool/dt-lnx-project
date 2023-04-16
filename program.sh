# Anthony Manenti - NOS125-150 SP23
# Interactive shell script combining all scripting and config tasks for NOS125.

# NOTE: I am relatively new at shell scripting. I barely remember how to write loops... but I do understand how flow works in programming languages, and I understand the structures and patterns I need to do certain tasks. 
# This script was put together with a lot of head scratching, trial and error, and googling. THANK YOU Linux forums and StackOverflow ... and Github!
# Please feel free to use this script as a reference, to build upon it, and improve it. 

#TODOS:
# 1) Generally my input validation on the case statements in the script feels a bit clunky. (using booleans and while loops) There is likely a more efficent means of doing this.
# 2) I may be overusing the case statements. It works ... and it's easy, but still.
# 3) It would be really cool if I could figure out how to launch a program like nmtui or fdisk and return the user back to my script once they are done.
# 4) A readme would be nice.
# 5) Creating an ssh config file after generating an ssh key for a user would be nice.
# 6) Functionality for creating additional users, adding them as sudoers. Setting their passwords.
# 7) IP address validation.
# 8) Automatic fdisk configuration by piping into fdisk. including automatic mkfs and mount.
# 9) Option for user to be redirected to fdisk for manual config.
# 10) Automatic echo /etc/fstab entry for dev/sdc1 so it gets mounted on reboot.
# 11) Generally I think clearing the users terminal is a good thing. There may be certain sections where keeping some of the history visible is beneficial. Look into it and clean it up where needed.
# 12) Make an array of Linux / Dad jokes and add a random joke picker function to the main menu where a random joke is picked and display.
# 13) Option to install git. 

# MARK: FILE AND FOLDER CREATION

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
    his_name_is_callboy
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

# MARK: HOSTNAMES

# Allows user to set hostname
set_hostname() {
    clear
    local inval_guard=true
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
            set_hostname
            ;;
        [qQ])
            inval_guard=false
            his_name_is_callboy
            ;;
        *)
            echo invalid response
            sleep 1
            ;;
        esac
    done
}

# MARK: NETWORKING

# Ask user if they want to bring the modified interface profile up. Warn that they may be disconnected.
prompt_interface_up() {
    clear
    read -p "Do you want to bring up your newly configured connection now? WARNING: this will disconnect you if you are connected via SSH. If you choose not to do this now, you will be taken back to the main menu and the configuration will be appplied on reboot. (y/n). " yn
    case $yn in
    [yY])
        sudo nmcli connection up static
        inval_guard=false
        ;;
    [nN])
        his_name_is_callboy
        inval_guard=false
        ;;
    *)
        echo "invalid response"
        sleep 1
        prompt_interface_up
        ;;
    esac
}

# Prompt by Prompt network config wizard with nested function for displaying settings table and applying with nmcli. 
network_config_wizard() {
    local inval_guard=true

    confirm_net_config() {
        clear
        printf "%-15s %-15s %-15s %-15s\n" "IP" "Gateway" "DNS" "Interface"
        printf "%-10s %-10s %-10s %-10s\n" "$1" "$2" "$3" "$4"

        read -p "Please confirm you configuration before applying " confirm
        case $confirm in
        [yY])
            if [ -z "$3" ]; then
                sudo nmcli connection add con-name static type ethernet ifname "$4" ipv4.addresses "$1" ipv4.gateway "$2" ipv4.method manual
            else
                sudo nmcli connection add con-name static type ethernet ifname "$4" ipv4.addresses "$1" ipv4.gateway "$2" ipv4.dns "$3" ipv4.method manual
            fi
            prompt_interface_up
            ;;
        [nN])
            network_config_wizard
            ;;
        *)
            echo "invalid response"
            sleep 1
            confirm_net_config
            ;;
        esac
    }

    echo "Please enter your IP address, and include your subnet mask in /xx format at the end of the address "
    read ip
    clear

    echo "Please enter your gateway address "
    read gw
    clear

    # This is running the IP link command and then using AWK to find the first line that starts with a number, followed by a colon and then a space and then the letter e. Which is the interface name we want to change.
    iface=$(ip link | awk -F': ' '/^[0-9]+: e/{print $2; exit}')

    while $inval_guard; do
        read -p "Do you want to override the system default DNS settings? " custdns
        case $custdns in
        [yY])
            echo "Enter your custom DNS address "
            read dns
            inval_guard=false
            confirm_net_config "$ip" "$gw" "$dns" "$iface"
            ;;
        [nN])
            $dns=""
            inval_guard=false
            confirm_net_config "$ip" "$gw" "$dns" "$iface"
            ;;
        *)
            echo "invalid response"
            sleep 1
            ;;
        esac
    done
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

# Basically shell script loads from top to bottom... so the interpreter runs down the file, gets all my function definitions, and at the last moment we call the caller function to kick this thing off.
his_name_is_callboy
