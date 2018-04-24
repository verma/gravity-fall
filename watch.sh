inotifywait -m -e MODIFY --format %f . | while read FILE
do
    if [[ ${FILE: -4} == ".fnl" ]]; then
        make
    else
        echo $( date +%H:%M:%S ) "Ignored" $FILE
    fi
done
