　　该项目旨在记录自己压制过的视频：[github地址](https://avanti1980.github.io/video-coding/)

　　考虑到arch下的安装、配置和更新，压制工具必然选[VapourSynth](http://www.vapoursynth.com/)，另外插件也很丰富，免去了到处找插件的烦恼：
```shell
$ yay vapoursynth  
196 aur/vapoursynth-plugin-neo_fft3dfilter-git r5.1.gabb9cdc-1 (+0 0.00) 
    Plugin for Vapoursynth: neo_fft3dfilter (GIT version)
195 aur/vapoursynth-plugin-placebo-git r49.a8be164-1 (+0 0.00) 
    Plugin for VapourSynth: placebo (GIT version)
194 aur/vapoursynth-tools-acsuite-git 4.1.1.r1.g808820a-1 (+0 0.00) 
    Frame-based cutting/trimming/splicing of audio with VapourSynth (GIT version)
193 aur/vapoursynth-plugin-f3kdb 2.0.0-1 (+0 0.00) (孤立) 
    flash3kyuu deband plugin for VapourSynth
192 aur/vapoursynth-plugin-waifu2x-ncnn-vulkan-git r3.0.g870f3c9-1 (+0 0.00) (已安装)
    Plugin for Vapoursynth: waifu2x-ncnn-vulkan (GIT version)
……
5 community/vapoursynth-plugin-lsmashsource 20200531-1 (61.8 KiB 141.9 KiB) 
    L-SMASH source plugin for Vapoursynth
4 community/vapoursynth-plugin-fluxsmooth 2-2 (9.0 KiB 21.0 KiB) (已安装)
    FluxSmooth plugin for VapourSynth
3 community/vapoursynth-plugin-deblock 6-2 (10.1 KiB 17.8 KiB) 
    Deblock plugin for VapourSynth
2 community/vapoursynth R50-1 (836.3 KiB 2.6 MiB) (已安装)
    A video processing framework with the future in mind
1 community/ffms2 2.23.1-3 (92.4 KiB 305.0 KiB) (已安装)
    A libav/ffmpeg based source library and Avisynth plugin for easy frame accurate access
==> 要安装的包 (示例: 1 2 3, 1-3 或 ^4)
==>
```

　　我个人安装的插件是
```shell
$ pacman -Q | grep vapoursynth
vapoursynth R50-1
vapoursynth-editor-git r19.1.g4490d06-1
vapoursynth-plugin-addgrain-git r8.0.g75782b6-1
vapoursynth-plugin-adjust-git v1.0.g7370577-2
vapoursynth-plugin-awarpsharp2-git v4.0.g886d4b7-1
vapoursynth-plugin-bilateral-git r3.6.g5c246c0-1
vapoursynth-plugin-bm3d-git r8.0.g7b3d8dd-1
vapoursynth-plugin-ctmf-git r5.0.g073eccd-1
vapoursynth-plugin-d2vsource-git v1.2.0.g4535f7c-1
vapoursynth-plugin-dctfilter-git r2.1.1.g3c9cbea-1
vapoursynth-plugin-deblock-git r6.1.1.g02e2cec-1
vapoursynth-plugin-delogo-git v0.4.0.g597ad7f-1
vapoursynth-plugin-dfttest-git r7.0.gb228588-1
vapoursynth-plugin-eedi2-git r7.1.1.g36be83a-1
vapoursynth-plugin-eedi3cl-git r4.7.gd11bdb3-1
vapoursynth-plugin-f3kdb-git 2.0pre.r423.54ff2b0-1
vapoursynth-plugin-fft3dfilter-git R1.5.g8562ea7-1
vapoursynth-plugin-fluxsmooth 2-2
vapoursynth-plugin-fmtconv-git r22.7.g4f187bf-1
vapoursynth-plugin-havsfunc-git r33.2.g33719fc-1
vapoursynth-plugin-hqdn3d-git r10.eb820cb-1
vapoursynth-plugin-knlmeanscl-git 1.1.1.r552.1ba48ce-1
vapoursynth-plugin-lsmashsource-git r1046.b6aef0c-1
vapoursynth-plugin-mvsfunc-git v9.r50.7948c8b-1
vapoursynth-plugin-mvtools-git v23.0.g6d805e2-1
vapoursynth-plugin-nnedi3-git v12.0.g8c35822-1
vapoursynth-plugin-nnedi3_resample-git 13.0983895-3
vapoursynth-plugin-nnedi3_weights_bin r1-1
vapoursynth-plugin-nnedi3cl-git r8.0.geb2a810-1
vapoursynth-plugin-sangnom-git r41.10.g788bc2d-1
vapoursynth-plugin-svpflow1 4.2.0.142-2
vapoursynth-plugin-svpflow2-bin 4.3.0.168-1
vapoursynth-plugin-waifu2x-ncnn-vulkan-git r3.0.g870f3c9-1
vapoursynth-plugin-waifu2x-w2xc-git r8.3.ga9f064a-1
vapoursynth-plugin-yadifmod-git r10.1.1.g2b45ada-1
vapoursynth-plugin-znedi3-git r2.0.g78e5e67-1
```

　　下面是vpy脚本模板
```python
#!/bin/env python
## coding: utf-8
import vapoursynth as vs
import sys
import havsfunc as haf     # 扩展脚本
import mvsfunc as mvf      # 扩展脚本
core = vs.get_core()

# 对于mp4/mkv/m2ts文件 推荐用lsmash
clip = core.lsmas.LWLibavSource(source=r'*.mp4', format='yuv420p16')

# 对于ts文件 推荐用D2VWitch通过命令“D2VWitch file”生成索引文件 类似于avs里的dgIndex
clip = core.d2v.Source(input=r'*.d2v', threads=1)

# 切片段
clip = core.std.Trim(clip, first=21793, last=27805)

# 删除台标 只能用于8位精度
clip = core.delogo.EraseLogo(clip, r'*.lgd')

# 转成16位精度
clip = core.fmtc.bitdepth(clip, bits=16)

# 加自己的图片logo
[logo, alpha] = core.imwri.Read(filename='*.png', alpha=True)
logo = core.resize.Bicubic(clip=logo, format=clip.format.id, matrix_s='709')
alpha = core.fmtc.bitdepth(clip=alpha, bits=clip.format.bits_per_sample, fulld=True)
clip = haf.Overlay(clipa=clip, clipb=logo, mask=alpha, x=**, y=-**)

# 修改帧率
clip = haf.ChangeFPS(clip, 30, 1)

# 反交错滤镜yadif和QTGMC二选一

# yadif依赖nnedi3 nnedi3的field参数设置：
# 0 / 1: 保持帧率 底场优先(BFF) / 顶场优先(TFF)
# 2 / 3: 双倍帧率 底场优先(BFF) / 顶场优先(TFF)

# yadif的order参数设置为 0 / 1：BFF / TFF
# yadif的field参数设置为 -1 / 0 / 1：与order相同 / BFF / TFF
# yadif的mode参数设置为
# 0 / 2：保持帧率 (做 / 不做) 空间检测
# 1 / 3：双倍帧率 (做 / 不做) 空间检测

# 原视频是TFF还是BFF可以通过MediaInfo来查看 常见的是TFF居多 故用下面这行就行了
clip = core.yadifmod.Yadifmod(clip, core.nnedi3.nnedi3(clip, field=1, opt=2), order=1, field=-1, mode=0)

# QTGMC依赖havsfunc、mvsfunc、adjust、znedi3、EEDI3、mvtools、fmtconv、temporalsoften 因此这些都配置好才能用
# 参数Preset控制质量 越慢越好 参数FPSDivisor=2表示帧率不翻倍 
clip = haf.QTGMC(clip, Preset='Placebo', FPSDivisor=2, TFF=True)

# 反胶卷过带 http://www.vapoursynth.com/doc/plugins/vivtc.html
yv12 = core.resize.Bicubic(clip, format='yuv420p8')
clip = core.vivtc.VFM(clip=yv12, order=1, clip2=clip)
clip = core.vivtc.VDecimate(clip)

# 切边
clip = core.std.CropRel(clip, left=10, right=10, top=10, bottom=10)

# 改变尺寸 推荐Bicubic
clip = core.resize.Bicubic(clip, 960, 540, filter_param_a=0.333, filter_param_b=0.333)

# 放大&降噪 waifu2x 很慢
clip = mvf.ToRGB(clip, depth=32)
clip = core.w2xc.Waifu2x(clip, noise=1, scale=2, block=128, photo=True, gpu=1)
clip = mvf.ToYUV(clip, css="420", depth=16)

# 降噪 KNLMeansCL和BM3D二选一 推荐用前者 后者实在太慢了
clip = core.knlm.KNLMeansCL(clip, d=1, a=2, s=4, device_type="gpu")
clip = mvf.BM3D(clip, sigma=[3,3,3], radius1=1)

# 字幕
clip = core.sub.TextFile(clip, file=r'*.ass')

clip.set_output()
```

　　脚本写好后就可以通过vspipe喂给编码器了，h264编码任务可以通过如下命令行实现：
```
vspipe **.vpy - --y4m | x264 --demuxer y4m - --preset slower --crf 20 --tune film --keyint 250 --min-keyint 1 --input-depth 16 --sar 1:1 -o a.264 -
```
h265编码任务可以通过如下命令行实现：
```
vspipe **.vpy - --y4m | x265 --y4m --preset slower --deblock -1:-1 --ctu 32 --qg-size 8 --crf 15.0 --pbratio 1.2 --cbqpoffs -2 --crqpoffs -2 --no-sao --me 3 --subme 5 --merange 38 --b-intra --limit-tu 4 --no-amp --ref 4 --weightb --keyint 360 --min-keyint 1 --bframes 6 --aq-mode 1 --aq-strength 0.8 --rd 5 --psy-rd 2.0 --psy-rdoq 1.0 --rdoq-level 2 --no-open-gop --rc-lookahead 80 --scenecut 40 --qcomp 0.65 --no-strong-intra-smoothing --input-depth 16 --output-depth 10 --sar 1:1 -o a.hevc -
```