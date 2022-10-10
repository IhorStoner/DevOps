echo "What you want to do?"
select task in  ADDUSER DELUSER EXIT
 
do
    case $task in
        ADDUSER)
            read -p "Enter username: " user
            useradd -m "$user"
            read -p "Enter new password $user: " pswd
            chpasswd <<< "$user:$pswd"
            read -p "Set root for $user? (Y/n) " isRoot
            [[ $isRoot == "Y" ]] && usermod -aG sudo "$user" && echo "Root for $user has been set"
            [[ $? == 0 ]] && echo "User has been created" && exit 0;;
        DELUSER)
            read -p "Enter username: " user
            userdel -r "$user"
            [[ $? == 0 ]] && echo "User has been deleted" && exit 0;;
        EXIT)
            echo 'by!'
            exit 0;;
        *)
            echo "What is this?";;
    esac
done