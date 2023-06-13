#!/bin/bash

pid_dir="$HOME/.tmp/gem5"

function stop {
    for pidfile in $pid_dir/*.pidfile; do
        if [ -f "$pidfile" ]; then
            pid=$(cat "$pidfile")
            echo "Stopping daemon process with PID: $pid"
            kill $pid
            rm "$pidfile"
        fi
    done
}

function start {
    if [[ "$1" =~ gem5 ]]; then
        pidfile="$pid_dir/$(basename "$2").pidfile"
    else
        pidfile="$pid_dir/$(basename "$1").pidfile"
    fi
    echo "Running $1"
    nohup "$@" >m5out/stdout.log 2>&1 </dev/null &
    echo $! > "$pidfile"
    echo "PID: $(cat "$pidfile")"
}

function restart {
    if [ -f "$pid_dir/$(basename "$1").pidfile" ]; then
        echo "Restarting daemon process"
        stop
        sleep 1
    fi
    start "$@"
}

function status {
    any_running=false
    for pidfile in $pid_dir/*.pidfile; do
        if [[ -f "$pidfile" ]]; then
            any_running=true
            pid=$(cat "$pidfile")
            if ps -p $pid > /dev/null; then
                echo "Daemon process $(basename "$pidfile" .pidfile) is running with PID: $pid"
            else
                echo "Daemon process $(basename "$pidfile" .pidfile) is not running"
            fi
        fi
    done
    if [[ "$any_running" = false ]]; then
        echo "No daemon processes are running"
    fi
}

case "$1" in
    start | --start)
        start "$@"
        ;;
    stop | --stop)
        stop
        ;;
    restart | --restart | -r)
        restart "${@:2}"
        ;;
    status | --status | -s)
        status
        ;;
    help | --help | -h)
        echo "Usage: $(basename $0) {start|stop|restart|status}"
        echo "  start:              start specified executable as a daemon process"
        echo "      --start [FILE]"
        echo "  stop:               stop all daemon processes"
        echo "      --stop [FILE]"
        echo "  restart:            restart specified daemon process"
        echo "      -r, --restart [FILE]"
        echo "  status:             show status of all daemon processes"
        echo "      -s, --status [FILE]"
        echo "  help                show this help message"
        echo "      -h, --help"
        ;;
    *)
        echo "Usage: $(basename $0) {start|stop|restart|status}"
        ;;
esac

# # Call the stop function if the script is called with the "stop" argument
# if [ "$1" == "stop" ]; then
#     stop
# # Call the restart function if the script is called with the "restart" argument
# elif [ "$1" == "restart" ]; then
#     restart "${@:2}"
# # Call the status function if the script is called with the "status" argument
# elif [ "$1" == "status" ]; then
#     status
# else
#     # Call the run function with all arguments supplied to this script
#     run "$@"
# fi