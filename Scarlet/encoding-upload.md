　　晨间剧洋洋洒洒150+集，每集的压制流程又非常雷同，所以必然批量处理以节约时间。具体到绯红，每集需分成4个部分分别处理，然后再将其连接起来：
1. op之前的部分，无需做特别处理
2. op中的动画部分，这部分视频的原始帧率是12fps，为了能够在30fps的电视上播放，先倍帧到24fps然后做胶卷过带，所以压制时要将这个过程逆回去，先做反胶卷过带，然后砍掉一半重复帧
3. toda单人对着镜头微笑的特写是24fps转30fps的，需做反胶卷过带
4. op之后的部分，无需做特别处理

　　为了方便多次压制，先将各个部分的起始帧数保存在tasklist.txt中：
```shell
$ cat tasklist.txt        
# 190930-ep1,971,4605,7134,7303,27944,小档剪前后档多余内容
# 191001-ep2,978,2764,4829,4922,27951
# ……
# 191011-ep11,986,1536,3601,3694,27960
# 191012-ep12,987,1864,3929,4022,27960,lsmash
# 191012-ep12,980,1857,3922,4015,27953,d2vwitch
# 191012-ep12,971,1848,3913,4006,27944,ffms2
# ……            
# 191016-ep15,989,1617,3682,3775,27962
# 191017-ep16,999,2683,4748,4841,27972,从本集开始小档不剪前后档多余内容
# 191018-ep17,1007,1744,3809,3902,27980
# ……
# 191123-ep48,989,2541,4606,4699,27962
```
第1个数字不是零是因为还录了一小部分前档节目，第5个数字是后档节目的起始帧数。

　　压制的vpy脚本如下：
```python
##!/bin/env python
## coding: utf-8
import vapoursynth as vs
import havsfunc as haf
core = vs.get_core()

# 读取文件
clip = core.lsmas.LWLibavSource(source=r'原档/19****-ep*.ts')

# 剪掉多录的前后档节目 具体数据从tasklist.txt中读取 每集都不一样
clip = core.std.Trim(clip, first=971, last=27943)

# 去NHKBS台标
clip = core.delogo.EraseLogo(clip, r'logo/NHKBSP2019 1920x1080.lgd')

clip = core.fmtc.bitdepth(clip, bits=16)

# 加字幕组logo
[logo, alpha] = core.imwri.Read(filename='logo/logo.png', alpha=True)
logo = core.resize.Bicubic(clip=logo, format=clip.format.id, matrix_s='709')
alpha = core.fmtc.bitdepth(clip=alpha, bits=clip.format.bits_per_sample, fulld=True)
clip = haf.Overlay(clipa=clip, clipb=logo, mask=alpha, x=1400, y=-460)

# 降噪
clip = core.knlm.KNLMeansCL(clip, d=1, a=2, s=4, device_type='gpu')

# 添加字幕
clip = core.sub.TextFile(clip, file=r'压制字幕/19****-ep*.ass')

# 第一部分无需特别处理
clip1 = core.std.Trim(clip, first=971-971, last=4604-971)

# 第二部分先反胶卷过带 再砍掉一半帧
clip2 = core.std.Trim(clip, first=4605-971, last=7133-971)
clip2 = core.vivtc.VFM(core.resize.Bicubic(clip2, format=vs.YUV420P8), order=1, clip2=clip2)
clip2 = core.vivtc.VDecimate(clip2)
clip2 = haf.ChangeFPS(clip2, 12000, 1001)

# 第三部分反胶卷过带
clip3 = core.std.Trim(clip, first=7134-971, last=7302-971)
clip3 = core.vivtc.VFM(core.resize.Bicubic(clip3, format=vs.YUV420P8), order=1, clip2=clip3)
clip3 = core.vivtc.VDecimate(clip3)

# 第四部分无需特别处理
clip4 = core.std.Trim(clip, first=7303-971, last=27943-971)

# 当前要压制哪一部分 就输出哪一部分
clip*.set_output()
```

　　最终shell脚本如下：
```shell
#!/usr/bin/env bash

SAVEIFS=$IFS
IFS=$(echo -en "\n\b")

# 读取网盘熟肉文件夹名中的更新集数
total_ep=$(baidupcs ls /绯红 | sed -n 's/.*第\(.*\)集.*/\1/p')

# 读取网盘熟肉文件夹中的实际文件总数 和total_ep可能会不一样
total_file=$(baidupcs ls /绯红/绯红【更新至第$total_ep集】 | sed -n 's/.*文件总数: \(.*\),.*/\1/p')
echo 当前网盘中共有$total_file集

while read -r line; do # 根据tasklist.txt进行压制

    line=${line// /} # 去掉空格

    # 如果含有#号或整行为空则跳过 否则进行压制 换言之想压制哪一集就将前面的#号去掉即可
    if [[ "$line" =~ "#" ]] || [ -z "$line" ]; then
        continue
    else
        # 获取当前压制的文件名 比如190930-ep1
        filename=$(echo $line | cut -d ',' -f 1)

        # 获取集数
        ep=$(echo $filename | cut -d 'p' -f 2)

        # 补零到三位数 因为晨间总共150+集
        if [[ $ep -lt 10 ]]; then
            ep=00$ep
        elif [[ $ep -lt 100 ]]; then
            ep=0$ep
        fi

        echo ******开始处理ep$ep******

        # 获取每个部分的起始帧数和结束帧数
        clip1_start=$(echo $line | cut -d ',' -f 2)
        clip2_start=$(echo $line | cut -d ',' -f 3)
        clip3_start=$(echo $line | cut -d ',' -f 4)
        clip4_start=$(echo $line | cut -d ',' -f 5)
        clip5_start=$(echo $line | cut -d ',' -f 6)
        clip1_end=$(($clip2_start - 1))
        clip2_end=$(($clip3_start - 1))
        clip3_end=$(($clip4_start - 1))
        clip4_end=$(($clip5_start - 1))

        # 第一部分的起始帧数也是整集的起始帧数 换算成<时:分:秒.毫秒>的格式
        sec=$(($clip1_start * 1001 / 30000))
        msec=$(($clip1_start * 1001 % 30000))
        msec=$(($msec / 3))
        min=$(($sec / 60))
        sec=$(($sec % 60))
        hour=$(($min / 60))
        min=$(($min % 60))
        clip_start=$hour:$min:$sec.$msec

        # 第四部分的结束帧数也是整集的结束帧数 换算成<时:分:秒.毫秒>的格式
        sec=$(($clip4_end * 1001 / 30000))
        msec=$(($clip4_end * 1001 % 30000))
        msec=$(($msec / 3))
        min=$(($sec / 60))
        sec=$(($sec % 60))
        hour=$(($min / 60))
        min=$(($min % 60))
        clip_end=$hour:$min:$sec.$msec

        # 将音频剪出来
        ffmpeg -nostdin -hide_banner -loglevel panic -i 原档/$filename.ts -ss $clip_start -to $clip_end -vn -c copy $filename.aac

        # 写vpy脚本
        echo "##!/bin/env python" >encoder.vpy
        echo "## coding: utf-8" >>encoder.vpy
        echo "import vapoursynth as vs" >>encoder.vpy
        echo "import havsfunc as haf" >>encoder.vpy
        echo "core = vs.get_core()" >>encoder.vpy
        echo "clip = core.lsmas.LWLibavSource(source=r'原档/$filename.ts')" >>encoder.vpy
        # echo "clip = core.ffms2.Source(source=r'原档/$filename.ts')" >>encoder.vpy

        if [ "$ep" -le 15 ] || [ "$ep" -ge 40 ]; then # 1-15和40-的字幕是针对剪了前后节目的小档的
            echo "clip = core.std.Trim(clip, first=$clip1_start, last=$clip4_end)" >>encoder.vpy
        fi

        echo "clip = core.delogo.EraseLogo(clip, r'logo/NHKBSP2019 1920x1080.lgd')" >>encoder.vpy
        echo "clip = core.fmtc.bitdepth(clip, bits=16)" >>encoder.vpy
        echo "[logo, alpha] = core.imwri.Read(filename='logo/logo.png', alpha=True)" >>encoder.vpy
        echo "logo = core.resize.Bicubic(clip=logo, format=clip.format.id, matrix_s='709')" >>encoder.vpy
        echo "alpha = core.fmtc.bitdepth(clip=alpha, bits=clip.format.bits_per_sample, fulld=True)" >>encoder.vpy
        echo "clip = haf.Overlay(clipa=clip, clipb=logo, mask=alpha, x=1400, y=-460)" >>encoder.vpy
        echo "clip = core.knlm.KNLMeansCL(clip, d=1, a=2, s=4, device_type='gpu')" >>encoder.vpy
        echo "clip = core.sub.TextFile(clip, file=r'字幕/$filename.ass')" >>encoder.vpy

        if [ "$ep" -le 15 ] || [ "$ep" -ge 40 ]; then # 1-15和40-的字幕是针对剪了前后节目的小档的
            echo "clip1 = core.std.Trim(clip, first=$clip1_start-$clip1_start, last=$clip1_end-$clip1_start)" >>encoder.vpy
            echo "clip2 = core.std.Trim(clip, first=$clip2_start-$clip1_start, last=$clip2_end-$clip1_start)" >>encoder.vpy
            echo "clip2 = core.vivtc.VFM(core.resize.Bicubic(clip2, format=vs.YUV420P8), order=1, clip2=clip2)" >>encoder.vpy
            echo "clip2 = core.vivtc.VDecimate(clip2)" >>encoder.vpy
            echo "clip2 = haf.ChangeFPS(clip2, 12000, 1001)" >>encoder.vpy
            echo "clip3 = core.std.Trim(clip, first=$clip3_start-$clip1_start, last=$clip3_end-$clip1_start)" >>encoder.vpy
            echo "clip3 = core.vivtc.VFM(core.resize.Bicubic(clip3, format=vs.YUV420P8), order=1, clip2=clip3)" >>encoder.vpy
            echo "clip3 = core.vivtc.VDecimate(clip3)" >>encoder.vpy
            echo "clip4 = core.std.Trim(clip, first=$clip4_start-$clip1_start, last=$clip4_end-$clip1_start)" >>encoder.vpy
        else
            echo "clip1 = core.std.Trim(clip, first=$clip1_start, last=$clip1_end)" >>encoder.vpy
            echo "clip2 = core.std.Trim(clip, first=$clip2_start, last=$clip2_end)" >>encoder.vpy
            echo "clip2 = core.vivtc.VFM(core.resize.Bicubic(clip2, format=vs.YUV420P8), order=1, clip2=clip2)" >>encoder.vpy
            echo "clip2 = core.vivtc.VDecimate(clip2)" >>encoder.vpy
            echo "clip2 = haf.ChangeFPS(clip2, 12000, 1001)" >>encoder.vpy
            echo "clip3 = core.std.Trim(clip, first=$clip3_start, last=$clip3_end)" >>encoder.vpy
            echo "clip3 = core.vivtc.VFM(core.resize.Bicubic(clip3, format=vs.YUV420P8), order=1, clip2=clip3)" >>encoder.vpy
            echo "clip3 = core.vivtc.VDecimate(clip3)" >>encoder.vpy
            echo "clip4 = core.std.Trim(clip, first=$clip4_start, last=$clip4_end)" >>encoder.vpy
        fi
        echo "clip1.set_output()" >>encoder.vpy

        # 压制第一部分
        vspipe encoder.vpy - --y4m | x264 --demuxer y4m --crf 23.0 --preset slow --tune film --keyint 600 --min-keyint 1 --input-depth 16 -o clip1.264 -

        # 压制第二部分 注意先修改vpy脚本的最后一行
        sed -i '$d' encoder.vpy
        echo "clip2.set_output()" >>encoder.vpy
        vspipe encoder.vpy - --y4m | x264 --demuxer y4m --crf 23.0 --preset slow --tune film --keyint 600 --min-keyint 1 --input-depth 16 -o clip2.264 -

        # 压制第三部分 注意先修改vpy脚本的最后一行
        sed -i '$d' encoder.vpy
        echo "clip3.set_output()" >>encoder.vpy
        vspipe encoder.vpy - --y4m | x264 --demuxer y4m --crf 23.0 --preset slow --tune film --keyint 600 --min-keyint 1 --input-depth 16 -o clip3.264 -

        # 压制第四部分 注意先修改vpy脚本的最后一行
        sed -i '$d' encoder.vpy
        echo "clip4.set_output()" >>encoder.vpy
        vspipe encoder.vpy - --y4m | x264 --demuxer y4m --crf 23.0 --preset slow --tune film --keyint 600 --min-keyint 1 --input-depth 16 -o clip4.264 -

        # 若本地已有熟肉则删除 这种情况发生在重新压制
        if [ -f "熟肉/【绯红联合字幕组】Scarlet.Ep$ep.1080p.mp4" ]; then
            rm "熟肉/【绯红联合字幕组】Scarlet.Ep$ep.1080p.mp4"
        fi

        # 合并所有的.264和.aac得到最终的熟肉
        echo "file 'clip1.264'" >filelist.txt
        echo "file 'clip2.264'" >>filelist.txt
        echo "file 'clip3.264'" >>filelist.txt
        echo "file 'clip4.264'" >>filelist.txt
        ffmpeg -nostdin -hide_banner -loglevel panic -f concat -i filelist.txt -i $filename.aac -c copy 熟肉/【绯红联合字幕组】Scarlet.Ep$ep.1080p.mp4

        rm 原档/*lwi *.264 filelist.txt encoder.vpy $filename.aac # 删除压制的中间文件

        # 若网盘熟肉文件夹已有熟肉则删除 这种情况发生在重新压制
        if [ -n "$(baidupcs ls /绯红/绯红【更新至第$total_ep集】 | grep Ep$ep)" ]; then
            echo 网盘中已有ep$ep 将其删除
            baidupcs rm /绯红/绯红【更新至第$total_ep集】/【绯红联合字幕组】Scarlet.Ep$ep.1080p.mp4
        fi

        # 上传熟肉
        baidupcs upload ~/Videos/绯红/熟肉/【绯红联合字幕组】Scarlet.Ep$ep.1080p.mp4 /绯红/绯红【更新至第$total_ep集】/

    fi

done <tasklist.txt

# 读取上传后网盘熟肉文件夹中的实际文件总数
current_total_file=$(baidupcs ls /绯红/绯红【更新至第$total_ep集】 | grep 文件总数 | sed "s/.*文件总数: \(.*\),.*/\1/g")

# 若文件总数发生变化 即不是对以前的某集重新压制 则重命名网盘熟肉文件夹
if [ "$current_total_file" -ne "$total_file" ]; then
    baidupcs mv /绯红/绯红【更新至第$total_ep集】 /绯红/绯红【更新至第$current_total_file集】
fi
```
