#!env bash

daily_punch_in() {
    source punch_days

    last_date=`tail -n 1 records.md | cut -d' ' -f2-4`
    now_date=`date | cut -d' ' -f1-3`
    if [ "$last_date" = "$now_date" ];then
        exit -1
    fi
    last_month=`tail -n 1 records.md | cut -d' ' -f2`
    now_month=`date | cut -d' ' -f2`
    if [ "$last_month" != "$now_month" ];then
        month_days=0
    else
        let month_days=month_days+1
    fi
    let all_days=all_days+1
    printf "month_days=%d\nall_days=%d\n" $month_days $all_days > punch_days
    msg="- "`date`" "`printf "打卡成功，本月第%d次打卡，总共打卡%d次" $month_days $all_days`
    echo $msg >> records.md
}

main() {
    git --version > /dev/null
    if [ $? != 0 ];then
        echo "git not found"
        exit -1
    fi

    old_pwd=$PWD
    self_file=`echo $PWD`"/""$0"
    punch_in_pwd=`cat ~/.bashrc | grep $self_file | cut -d' ' -f2`
    if [ "$punch_in_pwd" = "" ];then
        exit -1
    fi
    cd $punch_in_pwd
    git pull origin master:master
    daily_punch_in
    git commit -m `date` records.md
    git push origin master:master
    cd $old_pwd
}

install() {
    self_file=`echo $PWD`"/""$0"
    cat ~/.bashrc | grep $self_file > /dev/null
    if [ $? == 0 ];then
        exit -1
    fi
    printf "\n# daily punch in\nbash "$self_file"\n" >> ~/.bashrc
}

if [ "$1" = "install" ];then
    install
    exit 0
fi
main