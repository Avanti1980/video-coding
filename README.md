　　该项目旨在记录自己压制过的视频：[https://Avanti.github.io/video-encoding/](https://Avanti.github.io/video-encoding/)

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