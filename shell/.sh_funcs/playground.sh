function plg() {
    DIR="$HOME/dev/playground"
    NAME=$(date "+%Y%m%d%H%M")
    EXT=""
    case $1 in
        "python" | "py")
            DIR="$DIR/python"
            EXT="py"
            ;;

        *)
            NAME="${1%.*}"
            EXT="${1##*.}"
            case $EXT in
                "py")
                    DIR="$DIR/python"
                    ;;

                *)
                    echo "Unknown command: $1"
                    return 1
                    ;;

            esac
            ;;
    esac

    [ ! -d "$DIR" ] && mkdir -p $DIR
    cd $DIR
    $EDITOR "$NAME.$EXT"
}
