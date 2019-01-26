Vagrant.configure("2") do |config|
    config.vm.provider "docker" do |d|
        d.build_dir = "."
        d.privileged = true
        d.has_ssh = true
    end
    config.ssh.port = 2222
end
