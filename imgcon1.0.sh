#!/bin/bash

readonly SCRIPT_NAME=${0##*/}

imgConvert()
{
    local directory=$1
    
    # コマンド展開した値をfiles変数に代入する
    files=$(find $directory -type fd -print)
    
    for file in $files
    do
        if [[ $file =~ ^(.*/) ]]; then
            dirName=${BASH_REMATCH[1]}
            dirName+="_convert"
            if [[ ! -d $dirName ]]; then
                mkdir ${dirName}
            fi
        fi
        case "$file" in
            *.jpg)
                mv -f $file ${dirName}
            ;;
            *.*)
                convert $file -quality 100 $file.jpg
                    # 変換できないファイルは飛ばす
                    if [[ $? -ne 0 ]] ;then
                        printf '%s\n' "${SCRIPT_NAME}: '$file': 変換できないファイルです" >> ${dirName}.txt
                        continue
                    fi
                sips -s profile "/System/Library/ColorSync/Profiles/Generic RGB Profile.icc" "${file}.jpg"
                mv ${file}.jpg ${dirName}
            ;;
            *)
                continue
            ;;
        esac
        
    done
}

for i in "$@"
do
    imgConvert "$i"
done
