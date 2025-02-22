#!/bin/bash

# Define the paths for the Waybar CSS and Pywal color files
COLOR_FILE="$HOME/.cache/wal/colors-waybar-single-window.css"
CLASSES_FILE="$HOME/.cache/wal/colors-waybar-classes.css"
TITLES_FILE="$HOME/.cache/wal/colors-waybar-titles.css"

COLOR_LINE="@define-color single-window-bg"

previous_class=""
previous_title=""

process_title() {
    title=$1
    # Escape special regex characters
    safe_title=$(echo "$title" | sed 's/[][().*?^$+{}|]/\\&/g')

    # Extract words, escape properly, and join with '|'
    pattern=$(echo "$safe_title" | tr ' ' '\n' | grep -v '^$' | tr '\n' '|' | sed 's/|$//')

    title_line=$(grep -i -E "^@define-color $(echo $class)_($pattern)" "$TITLES_FILE")
}

update_waybar() {
    class=$1
    title=$2

    # Get color lines from CLASSES_FILE css file
    class_line=$(grep -i "^@define-color $class" "$CLASSES_FILE")
    process_title "$title"

    # If there is a color for the specific title
    if [ -n "$title_line" ]; then
        rgba_value=$(echo "$title_line" | awk -F'@define-color [^ ]* ' '{print $2}' | sed 's/;$//')
    # If there is a color just for the class
    elif [ -n "$class_line" ]; then
        rgba_value=$(echo "$class_line" | awk -F'@define-color [^ ]* ' '{print $2}' | sed 's/;$//')
    # If no color found
    else
        echo "Neither class nor title found in source file"
        return
    fi

    # Replace the background color variable for .single class in waybar
    sed -i "s/^$COLOR_LINE .*/$COLOR_LINE $rgba_value;/" "$COLOR_FILE"

    # Simply "touch" the CSS file to update its timestamp and apply updated CSS
    touch ~/.config/waybar/style.css

    # Change previous variables for optimization
    previous_class=$class
    previous_title=$title
}

# Function to check if there is only one window opened
get_window_count() {
    workspace_id=$(hyprctl activeworkspace -j | jq -r .id)

    window_count=$(hyprctl clients -j | jq "[.[] | select(.workspace.id == $workspace_id and .floating == false)] | length")

    echo $window_count
}

get_window() {
    window=$(hyprctl activewindow -j)

    class=$(echo $window | jq -r .class)
    title=$(echo $window | jq -r .title)
    floating=$(echo $window | jq -r .floating)
}

main() {
    window_count=$(get_window_count) 

    if [ $window_count -eq 1 ]; then
        get_window # Get active window when there is only one window opened

        # Check if title or class has changed
        if { [[ $previous_class == $class && $previous_title == $title ]] || [[ $floating == "true" ]]; }; then
            return
        fi

        update_waybar "$class" "$title"
    fi
}

# Run the check in a loop
while true; do
    main

    sleep 0.5
done
