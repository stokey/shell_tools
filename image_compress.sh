#!/usr/bin/env bash
:<<Description
Creator：Stokey
2019/03/07
压缩图片工具（需要安装jq）
将输入目录下的所有图片文件（及子目录）上传至TinyPNG网站进行压缩
下载压缩完毕后的文件，并且将下载文件存放至输入目录下新建子目录Temp目录下
Description

:<<Description
判断文件是否是图片文件
Description
function isImage(){
	local imagePath=$1;
	if file $imagePath | grep -qE 'image|bitmap'
	then
		echo "1"
		return 1
	else
		echo "0"
		return 0
	fi
}

:<<Description
遍历目录，找到图片文件后上传图片至TinyPNG服务进行压缩
Description
function read_dir(){
	local imageDir=$1;
	lastStr=${imageDir: -1}
	if [[ $lastStr != "/" ]]
	then
		imageDir=$imageDir"/";
	fi
	for file in `ls $1`
	do
		local imagePath=$imageDir$file;
		if [ -d $imagePath ]
		then
			read_dir $imagePath
		else
			# 检测当前文件是否是图片文件
			if [ $(isImage $imagePath) -gt 0 ]
			 then
			  compress $imagePath
			fi
		fi
	done
}

:<<Description
压缩图片
1. 上传图片至TinyPNG服务
2. 下载压缩好的图片文件至输入目录子目录Temp目录
Description
function compress(){
	local imagePath=$1;
	echo "compress imagePath:$imagePath"
	if [[ -n imagePath && $(isImage $imagePath) -gt 0 ]]
		then
		local oldName="$(basename $imagePath)"
		echo "$oldName"
		writeLogToLocal "compress iamgePath:$imagePath"
		# upload image to tinypng service
		# Warning 不能添加-i(会把http response写入文件，导致文件无法打开)
		local result=`curl -s -p -m 60 -H "User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_13_1) AppleWebKit/537.36 (K HTML, like Gecko) Chrome/61.0.3163.100 Safari/537.36" --data-binary "@$imagePath" "https://tinypng.com/web/shrink"`
		#result=$(curl -s -p -m 20 -H "User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_13_1) AppleWebKit/537.36 (K HTML, like Gecko) Chrome/61.0.3163.100 Safari/537.36" --data-binary "@$imagePath" "https://tinypng.com/web/shrink")
		writeLogToLocal "upload result:$result"
		# 获取image download url
		local url=$(echo $result | jq .output.url)
		url=${url:1:$((${#url}-2))}
		# 检查url合法性
		httpStr=${url:0:4}
		if [[ $httpStr != "http" ]]
		then
			echo "download file url is wrong! url:$url"
			writeLogToLocal "download file url is wrong! url:$url"
			return
		fi
		echo $url
		writeLogToLocal $url
		# 判断缓存目录合法性
		if [[ ! -e $tempImageDir || ! -d $tempImageDir ]]
		then
			echo "Temp Dirctory path is null"
			return
		fi
		# 压缩图片保存至本地目录的文件名
		local newImagName=$tempImageDir$oldName
		echo "local image name: $newImagName"

		if [ -n $url ]
		then
			echo "download url is not null:$url"
			wget --output-document=$newImagName $url
			writeLogToLocal "=========$newImagName compress success!===========\n"
		else
			echo "download url is null"
			writeLogToLocal "<<<<<<<<<$newImagName compress failure!>>>>>>>>>>>\n"
		fi
	else
		echo "imagePath is null or imagePath is not image"
	fi
}

:<<Description
写入日志到本地文件
Description
function writeLogToLocal() {
	content=$1
	if [[ -n $content && $isDebugLocal = true ]]
	then
		echo $content >> "$tempImageDir"result.txt
	fi
}

# read image dirctory
imageDir=$1
tempImageDir=""
# 是否支持写入本地日志
isDebugLocal=true
echo "0:$0"
echo "imageDir:$imageDir"
if [[ -n $imageDir  &&  -d $imageDir ]]
then
	lastStr=${imageDir: -1}
	# create temp dir
	if [[ $lastStr = "/" ]]
	then
		tempImageDir=$imageDir"Temp/"
	else
		tempImageDir=$imageDir"/Temp/"
	fi
	echo "tempImageDir:$tempImageDir"
	if [[ ! -d $tempImageDir ]]
	then
		mkdir $tempImageDir
	fi
	read_dir $imageDir
else
	echo "Your input is wrong. You must input a dirctory path!"
fi
