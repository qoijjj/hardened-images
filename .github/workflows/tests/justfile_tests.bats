#!/usr/bin/env bats

setup() {
    sudo mkdir -p /usr/share/ublue-os/just/
    sudo mkdir -p /usr/share/bluebuild/justfiles/
    sudo mkdir -p /usr/lib/ujust/


    sudo cp -fr files/system/usr/lib/ujust /usr/lib/ujust
    sudo cp -f files/system/usr/bin/ujust /usr/bin/ujust
    sudo cp -f files/system/usr/share/ublue-os/just/60-custom.just /usr/share/ublue-os/just/
    sudo cp -f files/system/usr/share/ublue-os/justfile /usr/share/ublue-os/
    sudo cp -f files/justfiles/*.just /usr/share/bluebuild/justfiles/
    for filepath in /usr/share/bluebuild/justfiles/*.just; do
        sudo sh -c "echo \"import '$filepath'\" >> /usr/share/ublue-os/just/60-custom.just"
    done
}

@test "Ensure ujust is configured correctly for tests" {
    run ujust bios
    [ "$status" -eq 0 ]
}

@test "Ensure motd toggle functions properly" {
    run ujust toggle-user-motd
    [ "$status" -eq 0 ]
    [ -f "${HOME}/.config/no-show-user-motd" ]
    run ujust toggle-user-motd
    [ "$status" -eq 0 ]
    [ ! -f "${HOME}/.config/no-show-user-motd" ]
}

@test "Ensure bash lockdown works" {
    x=0
    while [ $x -le 5 ]
    do
    if lsattr "/etc/profile" 2>/dev/null | awk '{print $1}' | grep -q 'i'; then
    	change_to_make="unlocked"
    else
    	change_to_make="locked"
    fi
    run bash -c "echo -e 'YES I UNDERSTAND\ny' | sudo ujust --set shell "sudo /usr/bin/bash" toggle-bash-environment-lockdown"
    [ "$status" -eq 0 ]
    if lsattr "/etc/profile" 2>/dev/null | awk '{print $1}' | grep -q 'i'; then
    	[ "$change_to_make" == "unlocked" ] || exit 1
    else
    	[ "$change_to_make" == "locked" ] || exit 1
    fi
    uid_min=$(grep -Po '^\s*UID_MIN\s+\K\d+' /etc/login.defs)
    uid_max=$(grep -Po '^\s*UID_MAX\s+\K\d+' /etc/login.defs)
    user_string=$(getent passwd | awk -F':' -v max="$uid_max" -v min="$uid_min" 'max >= $3 && $3 >= min {print $1}' | tr '\n' ',' | sed 's/,*$//')
    for user in "${user_list[@]}"; do
    	user_home=$(getent passwd "$user" | awk -F':' '{ print $6}')
        if lsattr "$user_home/.bash_profile" 2>/dev/null | awk '{print $1}' | grep -q 'i'; then
    	    change_to_make="unlocked"
        else
    	    change_to_make="locked"
        fi
        run bash -c "echo -e 'YES I UNDERSTAND\nn' | sudo ujust --set shell "sudo /usr/bin/bash" toggle-bash-environment-lockdown"
        [ "$status" -eq 0 ]
        if lsattr "$user_home/.bash_profile" 2>/dev/null | awk '{print $1}' | grep -q 'i'; then
    	    [ "$change_to_make" == "unlocked" ] || exit 1
        else
    	    [ "$change_to_make" == "locked" ] || exit 1
        fi
    done
    x=$(( $x + 1 ))
    done
}
