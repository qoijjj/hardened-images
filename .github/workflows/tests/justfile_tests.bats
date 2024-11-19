#!/usr/bin/env bats

setup() {
    sudo mkdir -p /usr/share/ublue-os/just/
    sudo mkdir -p /usr/share/bluebuild/justfiles

    sudo cp -f files/system/usr/bin/ujust /usr/bin/ujust
    sudo cp -f files/system/usr/share/ublue-os/just/60-custom.just /usr/share/ublue-os/just/
    sudo cp -f files/system/usr/share/ublue-os/justfile /usr/share/ublue-os/
    sudo cp -f files/justfiles/*.just /usr/share/bluebuild/justfiles/
    for filepath in /usr/share/bluebuild/justfiles/*.just; do
        sudo echo "import '$filepath'" >> /usr/share/ublue-os/just/60-custom.just
    done

    sudo chmod 777 -R /usr/share/bluebuild/
    sudo chmod 777 -R /usr/share/ublue-os/
}

@test "Ensure ujust is configured correctly for tests" {
    run ujust logs-this-boot
    [ "$status" -eq 0 ]
}
