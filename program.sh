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
# 5) Creating an ssh config file after generating an ssh key for a user would be nice. (DONE)
# 6) Functionality for creating additional users, adding them as sudoers. Setting their passwords.
# 7) IP address validation. (DONE)
# 8) Automatic fdisk configuration by piping into fdisk. including automatic mkfs and mount.
# 9) Option for user to be redirected to fdisk for manual config.
# 10) Automatic echo /etc/fstab entry for dev/sdc1 so it gets mounted on reboot.
# 11) Generally I think clearing the users terminal is a good thing. There may be certain sections where keeping some of the history visible is beneficial. Look into it and clean it up where needed. (DONE)
# 12) Make an array of Linux / Dad jokes and add a random joke picker function to the main menu where a random joke is picked and display.
# 13) Option to install git. (DONE)

# MARK: FILE AND FOLDER CREATION

# Create additional folders if user wants folders outside of defaults.
create_additional_folders() {
    clear
    optional_folders=()
    should_continue=true

    create() {
        for folder in "${optional_folders[@]}"; do
            sudo mkdir -p /data/groups/$folder
        done
        should_continue=false
        echo Okay! Our work here is done.
        sleep 1
        call_menu
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

# Creates default folders if user indicates they want them, and also starts stack for adding custom folders.
make_folders() {
    paths=("sales" "marketing" "operations" "finance" "human_resources")
    for path in "${paths[@]}"; do
        sudo mkdir -p /data/groups/$path
    done
    call_menu
}

# Gotta know if the user is actually inputting integers when we need em.
# This function is reusable. Include the input you'd like to validate as the first param in the call.
# Include the function you'd like to return back to as the second param in the call if unsuccesful
# Include the function you'd like to move to as the third param in the call if successful and voila!
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
        [nN]) call_menu ;;
        *) test_existing_files ;;
        esac
    else
        create_files
    fi
}

# Ask for file size in MB, send to validate.
prompt_file_size() {
    echo "How many MBs would you like the files to be? [must be an integer]. "
    read S
    validate_num $S prompt_file_size test_existing_files
}

# Kicks off file and default folder creation chain, sends user input to validate.
prompt_num_files() {
    echo "How many files would you like to create? [must be an integer]. "
    read N
    validate_num $N prompt_num_files prompt_file_size
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
            call_menu
            ;;
        [nN])
            inval_guard=false
            set_hostname
            ;;
        [qQ])
            inval_guard=false
            call_menu
            ;;
        *)
            echo invalid response
            sleep 1
            ;;
        esac
    done
}

# MARK: NETWORKING
# IP Validation Regex (https://stackoverflow.com/questions/5284147/validating-ipv4-addresses-with-regexp)
# Ask user if they want to bring the modified interface profile up. Warn that they may be disconnected.
prompt_interface_up() {
    echo
    read -p "Do you want to bring up your newly configured connection now? WARNING: this will disconnect you if you are connected via SSH. If you choose not to do this now, you will be taken back to the main menu and the configuration will be appplied on reboot. (y/n). " yn
    case $yn in
    [yY])
        sudo nmcli connection up static
        inval_guard=false
        call_menu
        ;;
    [nN])
        inval_guard=false
        call_menu
        ;;
    *)
        echo "invalid response"
        sleep 1
        prompt_interface_up
        ;;
    esac
}

# prompt for optional dns address, if valid, send to confirm, if user opts out, send to confirm with nil dns variable.
input_dns() {
    clear
    local inval_guard=true
    while $inval_guard; do
        read -p "Do you want to override the system default DNS settings? (y/n) " yn
        case $yn in
        [yY])
            # Not super DRY here. we're repeating logic we already have, but this is easier than redirecting for now.
            read -p "Enter your custom DNS address " dns
            if [[ $dns =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}/([0-9]|[1-2][0-9]|3[0-2])$ ]]; then
                inval_guard=false
                confirm_net_config "$1" "$2" "$dns"
            else
                echo "Invalid IP address."
                sleep 1
                clear
            fi
            ;;
        [nN])
            dns=""
            inval_guard=false
            confirm_net_config "$1" "$2" "$dns"
            ;;
        *)
            echo "invalid response"
            sleep 1
            ;;
        esac
    done
}

# prompt for and validate gateway address, send to optional dns function if valid, else prompt again.
input_gateway_address() {
    clear
    read -p "Enter your gateway IP address: " gw
    if [[ $gw =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        input_dns "$1" "$gw"
    else
        echo "Invalid IP address."
        sleep 1
        input_gateway_address
    fi
}

# prompt for and validate ip address, send to gateway address function if valid. else prompt again.
input_ip_address() {
    clear
    read -p "Enter an IP address with CIDR notation (e.g., 192.168.1.0/24): " ip
    if [[ $ip =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        input_gateway_address "$ip"
    else
        echo "Invalid IP address. Try again"
        sleep 1
        input_ip_address
    fi
}

# Creates a prompt which allows users to confirm their network config before applying.
confirm_net_config() {
    clear
    # This is running the IP link command and then using AWK to find the first line that starts with a number, followed by a colon and then a space and then the letter e, which is the interface we want to change.
    iface=$(ip link | awk -F': ' '/^[0-9]+: e/{print $2; exit}')
    # print config back to user for confirmation.
    echo
    echo "IP : $1"
    echo "Gateway : $2"
    echo "DNS : $3"
    echo "Interface : $iface"
    echo

    read -p "Please confirm you configuration before applying (y: confirm, n: restart config, or q: quit to main menu) " ynq
    case $ynq in
    [yY])
    	# Check if third param (DNS) is null, format nmcli accordingly and run.
        if [ -z "$3" ]; then
            sudo nmcli connection add con-name static type ethernet ifname "$iface" ipv4.addresses "$1" ipv4.gateway "$2" ipv4.method manual
        else
            sudo nmcli connection add con-name static type ethernet ifname "$iface" ipv4.addresses "$1" ipv4.gateway "$2" ipv4.dns "$3" ipv4.method manual
        fi
        prompt_interface_up
        ;;
    [nN])
        input_ip_address
        ;;
    [qQ])
        call_menu
        ;;
    *)
        echo "invalid response"
        sleep 1
        confirm_net_config
        ;;
    esac
}

# allows user to use our wizard for network config through nmcli command formatting, or opt to use nmcli
configure_networking() {
    clear
    echo -e "\n1) I want to use this script to configure network settings \n2) I want to use nmtui to configure network settings \n3) Quit \n"
    read -p "How can I help you today? " input
    case $input in
    1)
        input_ip_address
        ;;
    2)
        nmtui
        ;;
    3)
	call_menu
        ;;
    *)
        echo "invalid option"
        configure_networking
        ;;
    esac
}

# MARK : FILE DELETION

# Simple and dumb delete. Delete all the things. Godspeed.
delete_all_files() {
    clear
    read -p "This will remove all files and folder from /data/public and /data/groups. Are you sure you want to do this? (y/n) " yn
    case $yn in
    [Yy])
        sudo rm -rf /data/public
        sudo rm -rf /data/groups
        call_menu
        ;;
    [Nn])
        call_menu
        ;;
    *)
        echo "invalid option"
        sleep 1
        delete_all_files
        ;;
    esac
}

# MARK : GIT CONFIGURATION

# Create SSH config  for user. Lovely lil nested conditionals.
create_ssh_config() {
    clear
    read -p "Please name your ssh key (no spaces allowed) " name
    
    # Check if it has spaces in it. We don't like spaces.
    if [[ $name == *" "* ]]; then
        echo "Invalid name, please try again ..."
        sleep 1
        create_ssh_config
    else
        # Make sure we aint trying to overwrite anything. Prompt again if we are.
        if [ -f ~/.ssh/$name ]; then
            echo "Careful! A key of this name already exists, please enter another name."
            sleep 1
            create_ssh_config
        else
            echo "Creating SSH key..."
            ssh-keygen -t rsa -N "" -f ~/.ssh/$name
            # If they aint got a config file already, make it.
            if [ ! -f ~/.ssh/config ]; then
                echo "No existing SSH config file. Creating a new config file..."
                touch ~/.ssh/config
            fi
	    # If they already have a config entry for github. Don't make it complicated. Tell them to look at the file.
            if grep -q "Host github.com" ~/.ssh/config; then
                echo "You already have a config file entry for github. Please review your config file"
                sleep 1
                call_menu
            else
                echo -e "\nHost github.com" >>~/.ssh/config
                echo "  User git" >>~/.ssh/config
                echo "  IdentityFile ~/.ssh/$name" >>~/.ssh/config
            fi
        fi
    fi
}

install_git() {
    local inval_guard=true
    clear

    # Check if git installed. Silence output - if it aint. install it.
    if ! command -v git &>/dev/null; then
        echo "Git is not installed. Installing Git..."
        sudo dnf install -y git
    else
        echo "Git is already installed"
    fi

    while $inval_guard; do
        read -p "Would you like to create an SSH key and SSH config file now? (y/n) " yn
        case $yn in
        [yY])
            inval_guard=false
            create_ssh_config
            sleep 1
            call_menu
            ;;
        [nN])
            inval_guard=false
            call_menu
            ;;
        *)
            echo "invalid response"
            sleep 1
            ;;
        esac
    done
}

# MARK: CALLER

# Gives us the multi option prompt and allows us to call functions as we need them.
# This kind of pattern is useful, because it allows us to block everything away and work on one piece at a time.
# We don't have to worry about massive entangled blocks. It's a caller basically.
call_menu() {
    clear
    echo -e "\n1) Set Hostname\n2) Create Files and Folders\n3) Create Optional Folders\n4) Configure Networking\n5) Delete folders and files\n6) Install Git\n7) Quit\n"
    read -p "Welcome! What would you like to do? " input
    case $input in
    1)
        set_hostname
        ;;
    2)
        prompt_num_files
        ;;
    3)
        create_additional_folders
        ;;
    4)
        configure_networking
        ;;
    5)
        delete_all_files
        ;;
    6)
        install_git
        ;;
    7)
        exit
        ;;
    *)
        echo "invalid option"
        sleep 1
        call_menu
        ;;
    esac
}

# Basically shell script loads from top to bottom... so the interpreter runs down the file, gets all my function definitions, and at the last moment we call the caller function to kick this thing off.
call_menu
