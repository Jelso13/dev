#!/bin/zsh

# Get the context from Taskwarrior
context=$(task _get rc.context)

# Check if the context variable is set and determine the color
if [ -n "$context" ]; then
    case "$context" in
        "work")
            echo -e "\e[38;2;95;135;215m󱇯 $context\e[0m"  # blue
            ;;
        "personal")
            echo -e "\e[38;2;255;135;95m󰛡 $context\e[0m"  # orange
            ;;
        "development")
            echo -e "\e[38;2;95;175;95m󰌢 $context\e[0m"  # Green
            ;;
        *)
            echo -e "\e[33m$context\e[0m"  # Yellow for any other context
            ;;
    esac
else
    echo ""
fi

