# Timewarrior Wrapper: Auto-updates AwesomeWM bar on any state change
timew() {
    # 1. Run the actual timew command and pass all arguments to it
    command timew "$@"
    
    # 2. Tell AwesomeWM to pull the new data
    awesome-client "require('utils.get_task')()"
}
