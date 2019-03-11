#!/usr/bin/env bash

:<<GitCmd
执行Git命令
GitCmd
function gitCmd(){
    if [[ ! -n $1 || ! -e $1 || ! -d $1 ]]
    then
        echo "文件路径有误"
        return
    fi
    lastSub=${1: -1}
    if [[ $lastSub != "/" ]]
    then
        gitDir=$1"/.git"
        workTree=$1"/"
    else
        gitDir=$1".git"
        workTree=$1
    fi
    if [[ -n $5 ]]
    then
        echo `git --git-dir=${gitDir} --work-tree=${workTree} $2 $3 $4 $5`
    elif [[ -n $4 ]]
    then
        echo `git --git-dir=${gitDir} --work-tree=${workTree} $2 $3 $4`
    elif [[ -n $3 ]]
    then
        echo `git --git-dir=${gitDir} --work-tree=${workTree} $2 $3`
    elif [[ -n $2 ]]
    then
        echo `git --git-dir=${gitDir} --work-tree=${workTree} $2`
    else
        echo "参数输入错误"
    fi
}

# 保存当前目录
currentDir=$PWD
echo $currentDir
# 上级目录
dirname="$(dirname $currentDir)"
echo $dirname

if [[ -e $dirname && -d $dirname ]]
then
    # 遍历目录
    for file in `ls $dirname`
    do
        lastSub=${dirname: -1}
        if [[ $lastSub != "/" ]]
        then
           newModulePath=$dirname"/"$file
        else
           newModulePath=$dirname$file
        fi
        if [[ -e $newModulePath && -d $newModulePath ]]
        then
            # 同层级Module创建分支
            gitCmd $newModulePath $1 $2 $3 $4
        fi
    done
fi