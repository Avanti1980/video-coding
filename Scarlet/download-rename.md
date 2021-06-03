　　查询网盘现有的ts文件：
```
$ baidupcs ls /绯红/晨间原档等多个文件 | sed -n 's/.*ＮＨＫ\(.*\)ts.*/ＮＨＫ\1ts/p'         
ＮＨＫＢＳプレミアム 連続テレビ小説 スカーレット（３９）「弟子にしてください！」[解][字] 20191113_0730.ts
ＮＨＫＢＳプレミアム 連続テレビ小説 スカーレット（４０）「弟子にしてください！」[解][字] 20191114_0730.ts
```
这个例子中网盘存放着第39和40集。

　　查询本地下载的ts文件：
```
$ ls ~/Videos/绯红/原档
190920 もうすぐ！連続テレビ小説「スカーレット」.ts
190927 いよいよスタート！連続テレビ小説「スカーレット」スペシャル_Cut.ts
190930-ep1.ts
191001-ep2.ts
……
191112-ep38.ts
191113-ep39.ts
```
注意本地文件进行了重命名，这是为了避免日文给后续压制带来麻烦。

　　下载没有下过的ts文件，脚本如下：
```shell
#!/usr/bin/env bash

SAVEIFS=$IFS
IFS=$(echo -en "\n\b")

# 查询网盘现有的ts文件
download_list=($(baidupcs ls /绯红/晨间原档等多个文件 | sed -n 's/.*ＮＨＫ\(.*\)ts.*/ＮＨＫ\1ts/p'))

# 查询本地下载的ts文件
exist_files=$(ls ~/Videos/绯红/原档)

for line in ${download_list[@]}; do # 依次处理网盘中现有的ts文件

    # 获取日期
    time=$(echo $line | sed -n 's/.*].20\(.*\)_.*/\1/p')

    # 获取集数并处理日文数字
    ep=$(echo $line | sed 's/.*（\([１２３４５６７８９０]*\)）.*/\1/g')
    ep=${ep//０/0}
    ep=${ep//１/1}
    ep=${ep//２/2}
    ep=${ep//３/3}
    ep=${ep//４/4}
    ep=${ep//５/5}
    ep=${ep//６/6}
    ep=${ep//７/7}
    ep=${ep//８/8}
    ep=${ep//９/9}

    # 是否已经下到本地了?
    if [[ "$exist_files" =~ "$time-ep$ep.ts" ]]; then
        echo 文件 "< $time-ep$ep.ts >" 已存在
    else
        line=${line// /\\ } # 空格要加斜杠转义

        # 是否下到本地了但还没有重命名？
        if [[ "$exist_files" =~ "$line" ]]; then
            echo 文件 "$line" 已存在
        else
            echo 文件 "$line" 不存在 开始下载
            baidupcs download -saveto ~/Videos/绯红/原档/ /绯红/晨间原档等多个文件/$line
        fi

        # 中括号要加斜杠转义
        line=${line//[/\\[}
        line=${line//]/\\]}

        # 将本地的ts文件重命名
        mv ~/Videos/绯红/原档/$line ~/Videos/绯红/原档/$time-ep$ep.ts
    fi
done
```
