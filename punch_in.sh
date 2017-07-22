#!/usr/bin/env bash

daily_punch_in() {
    source punch_days

    last_date=`tail -n 1 records.md | cut -d' ' -f2`
    now_date=`date +%F`
    if [ "$last_date" = "$now_date" ];then
        return -1
    fi
    last_month=`tail -n 1 records.md | cut -d' ' -f2 | cut -d'-' -f2`
    now_month=`date +%F | cut -d'-' -f2`
    if [ "$last_month" != "$now_month" ];then
        month_days=1
    else
        let month_days=month_days+1
    fi
    let all_days=all_days+1
    printf "month_days=%d\nall_days=%d\n" $month_days $all_days > punch_days
    msg="- "`date +%F' '\(%A' '%B\)' '%T`" "`printf "打卡成功，本月第%d次打卡，总共打卡%d次" $month_days $all_days`
    echo $msg >> records.md
    return 0
}

main() {
    git --version > /dev/null
    if [ $? != 0 ];then
        echo "git not found"
        exit -1
    fi
    old_pwd=$PWD
    if [ "$punch_in_pwd" = "" ];then
        echo "punch_in_pwd unset"
        exit -1
    fi
    cd $punch_in_pwd
    git pull origin master:master > /dev/null
    daily_punch_in
    if [ $? -eq 0 ];then
        git commit -m "`date +%F' '%T`"" punch in" records.md punch_days > /dev/null
        git push origin master:master > /dev/null
    fi
    cd $old_pwd
}

install() {
    self_file=`echo $PWD`"/""$0"
    sh_file="$HOME/.bashrc"
    test -n "$1" && sh_file="$HOME/$1"
    cat $sh_file | grep $self_file > /dev/null
    if [ $? == 0 ];then
        echo "already install"
        exit -1
    fi
    printf "\n# daily punch in\nexport punch_in_pwd="$PWD"\nbash "$self_file" > /dev/null &\nunset punch_in_pwd\n" >> "$sh_file"
}

if [ "$1" = "install" ];then
        install $2
    exit 0
fi
main
