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
    sudo_path=$(whereis sudo | awk -F' ' '{print $2}')
    sudo ln -s "$sudo_path" "/bin/run0"
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
    if lsattr "/etc/profile" 2>/dev/null | awk '{print $1}' | grep -q 'i'; then
    	change_to_make="unlocked"
    else
    	change_to_make="locked"
    fi
    run bash -c "echo -e 'YES I UNDERSTAND\ny' | sudo ujust toggle-bash-environment-lockdown"
    [ "$status" -eq 0 ]
    if lsattr "/etc/profile" 2>/dev/null | awk '{print $1}' | grep -q 'i'; then
    	[ "$change_to_make" == "unlocked" ] || exit 1
    else
    	[ "$change_to_make" == "locked" ] || exit 1
    fi
    if lsattr "/etc/profile" 2>/dev/null | awk '{print $1}' | grep -q 'i'; then
    	change_to_make="unlocked"
    else
    	change_to_make="locked"
    fi
    run bash -c "echo -e 'YES I UNDERSTAND\ny' | sudo ujust toggle-bash-environment-lockdown"
    [ "$status" -eq 0 ]
    if lsattr "/etc/profile" 2>/dev/null | awk '{print $1}' | grep -q 'i'; then
    	[ "$change_to_make" == "unlocked" ] || exit 1
    else
    	[ "$change_to_make" == "locked" ] || exit 1
    fi
    if lsattr "/etc/profile" 2>/dev/null | awk '{print $1}' | grep -q 'i'; then
    	change_to_make="unlocked"
    else
    	change_to_make="locked"
    fi
    run bash -c "echo -e 'YES I UNDERSTAND\ny' | sudo ujust toggle-bash-environment-lockdown"
    [ "$status" -eq 0 ]
    if lsattr "/etc/profile" 2>/dev/null | awk '{print $1}' | grep -q 'i'; then
    	[ "$change_to_make" == "unlocked" ] || exit 1
    else
    	[ "$change_to_make" == "locked" ] || exit 1
    fi
    if lsattr "/etc/profile" 2>/dev/null | awk '{print $1}' | grep -q 'i'; then
    	change_to_make="unlocked"
    else
    	change_to_make="locked"
    fi
    run bash -c "echo -e 'YES I UNDERSTAND\ny' | sudo ujust toggle-bash-environment-lockdown"
    [ "$status" -eq 0 ]
    if lsattr "/etc/profile" 2>/dev/null | awk '{print $1}' | grep -q 'i'; then
    	[ "$change_to_make" == "unlocked" ] || exit 1
    else
    	[ "$change_to_make" == "locked" ] || exit 1
    fi
}
