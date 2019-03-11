# Shell Tools
## 说明
该项目旨在收集和整理日常shell脚本工具。

## 工具说明
### image_compress.sh
+ 简介：压缩图片工具（需要安装jq）。该工具会将输入目录下的所有图片文件（及子目录）上传至TinyPNG网站进行压缩。压缩完毕后会将压缩图片下载至输入目录下新建子目录Temp目录下
+ 使用方式：`sh image_compress.sh /Users/xxxx/Desktop/images`(如果未安装jq，请先执行`brew install jq`命令)
+ 执行流程：
    * 遍历文件目录下所有文件，找到图片文件（如果是文件夹则继续向子目录查找）
    * 将图片文件上传至TinyPNG服务器
    * 解析TinyPNG服务器返回内容，获取压缩完毕后的图片下载地址
    * 通过下载地址将图片下载到Temp目录
+ 后续改进点
    + [ ] 上传失败后未增加重传机制
    + [ ] 下载失败后未增加重传机制

### git_cmd.sh
+ 简介：git批量操作工具。该工具会把当前所在目录父目录下所有文件夹执行输入git命令。适用于多Module项目。
+ 使用方式：`sh git_cmd.sh xxx`，例如：`sh git_cmd.sh checkout -b test`命令会给所有Module创建一个名为test的本地开发分支