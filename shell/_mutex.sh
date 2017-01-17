# Function for using a pid file as a mutex
#
# The script was taken from http://stackoverflow.com/a/731634, which
# doesn't specify a license so I assume it's in public domain. It may
# contain changes done by Yan Li.  Copyright (c) 2016 Yan Li
# <yanli@ascar.io>. All rights reserved.

# Open a mutual exclusion lock on the file, unless another process already owns one.
#
# If the file is already locked by another process, the operation fails.
# This function defines a lock on a file as having a file descriptor open to the file.
#
# To acquire a lock:
# mutex /var/run/myscript.lock || { echo "Already running." >&2; exit 1; }
#
# This function uses FD 9 to open a lock on the file.  To release the lock, close FD 9:
# exec 9>&-
_mutex() {
    local file=$1 pid pids 

    exec 9>>"$file"
    { pids=$(fuser -f "$file"); } 2>&- 9>&- 
    for pid in $pids; do
        [[ $pid = $$ ]] && continue

        exec 9>&- 
        return 1 # Locked by a pid.
    done 
}