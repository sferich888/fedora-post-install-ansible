# fedora-post-install-ansible
Using Ansible to Post setup a sytem and User account[s]!

### For Testing! 
```
VM_NAME=fedora_test_vm
sudo virt-install -n $VM_NAME -r 2048 --disk path=/var/lib/libvirt/images/${VM_NAME}.img,size=25,format=qcow2,sparse=false --location="https://mirrors.rit.edu/fedora/fedora/linux/releases/27/Workstation/x86_64/os/" --initrd-inject=fedora.ks -x "ks=file:/fedora.ks" --noautoconsole
```

Once youhave a test vm you can run the playbooks! 
