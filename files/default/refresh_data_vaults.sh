for vault in $(knife vault list)
do
    for item in $(knife vault show $vault)
    do
        set -x
        knife vault refresh $vault $item -M client
        set +x
    done
done