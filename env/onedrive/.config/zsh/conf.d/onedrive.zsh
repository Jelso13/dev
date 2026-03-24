alias mountonedrive="rclone mount onedrive: ~/Resources/onedrive/ --vfs-cache-mode writes --rc &"
# return message if umountonedrive doesn't work
alias umountonedrive="fusermount -u ~/Resources/onedrive/ && echo 'onedrive unmounted' || echo 'onedrive unmount failed'"
