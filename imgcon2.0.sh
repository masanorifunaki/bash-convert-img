#!/bin/bash
readonly SCRIPT_NAME=${0##*/}
IFS=$'\n'

imgConvert()
{
    local files=($(find "$1" -type fd -print))
cat << END
以下のファイルを変換します。
${files[@]}
合計: ${#files[@]} ファイルです。
END
    for file in "${files[@]}"
    do
        # 変換後の画像を格納するフォルダ作成
        if [[ "$file" =~ ^(.*/) ]]; then
            dirConvertFolder=${BASH_REMATCH[1]}_convert
            if [[ ! -d $dirConvertFolder ]]; then
                mkdir ${dirConvertFolder}
            fi
        fi
        # imageMagicで画像変換を行う
        # jpg以外全てjpgへ変換を行う
        # RGBの設定はsipsコマンドで行う
        case $file in
            *.jpg)
                mv -f $file ${dirConvertFolder}
            ;;
            *)
                convert $file -quality 100 $file.jpg 2>> ${dirConvertFolder}_error.txt
                  #変換できないファイルは飛ばす
                if [[ $? -ne 0 ]]; then
                    printf '%s\n' "${SCRIPT_NAME}: '$file': 変換できないファイルです。" >> ${dirConvertFolder}_error.txt
                    continue
                fi
                # CYMKからRGBへの変換ができないので原因調査
                sips -s profile "/System/Library/ColorSync/Profiles/Generic RGB Profile.icc" "${file}.jpg"
                mv ${file}.jpg ${dirConvertFolder}
            ;;
        esac
    done
}

for i in "$@"
do
    imgConvert "$i"
done