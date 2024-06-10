#!/bin/sh

source /koolshare/scripts/base.sh
eval $(dbus export ddnsgo_)
alias echo_date='echo 【$(TZ=UTC-8 date -R +%Y年%m月%d日\ %X)】:'
CONF_FILE=/koolshare/configs/ddnsgo/default.yaml
LOG_FILE=/tmp/upload/ddnsgo_log.txt
DG_LOG_FILE=/tmp/upload/ddnsgo.log
LOCK_FILE=/var/lock/ddnsgo.lock
BASH=${0##*/}
ARGS=$@

set_lock(){
	exec 999>${LOCK_FILE}
	flock -n 999 || {
		# bring back to original log
		http_response "$ACTION"
		exit 1
	}
}

unset_lock(){
	flock -u 999
	rm -rf ${LOCK_FILE}
}

number_test(){
	case $1 in
		''|*[!0-9]*)
			echo 1
			;;
		*)
			echo 0
			;;
	esac
}

detect_running_status(){
	local BINNAME=$1
	local PID
	local i=40
	until [ -n "${PID}" ]; do
		usleep 250000
		i=$(($i - 1))
		PID=$(pidof ${BINNAME})
		if [ "$i" -lt 1 ]; then
			echo_date "🔴$1进程启动失败，请检查你的配置！"
			return
		fi
	done
	echo_date "🟢DDNS-Go 启动成功，pid：${PID}"
}

check_status(){
	local DG_PID=$(pidof ddnsgo)
	if [ "${ddnsgo_enable}" == "1" ]; then
		if [ -n "${DG_PID}" ]; then
			if [ "${ddnsgo_watchdog}" == "1" ]; then
				local ddnsgo_time=$(perpls|grep ddnsgo|grep -Eo "uptime.+-s\ " | awk -F" |:|/" '{print $3}')
				ddnsgo_time="${ddnsgo_time%s}"
				if [ -n "${ddnsgo_time}" ]; then
					local ret="DDNS-Go 进程运行正常！（PID：${DG_PID} , 守护运行时间：$(formatTime $ddnsgo_time)）"
				else
					local ret="DDNS-Go 进程运行正常！（PID：${DG_PID}）"
				fi
			else
				local ret="DDNS-Go 进程运行正常！（PID：${DG_PID}）"
			fi
		else
			local ret="DDNS-Go 进程未运行！"
		fi
	else
		local ret="DDNS-Go 插件未启用"
	fi
	http_response "$ret"
}

formatTime() {
	seconds=$1

	hours=$(( seconds / 3600 ))
	minutes=$(( (seconds % 3600) / 60 ))
	remainingSeconds=$(( seconds % 60 ))

	timeString=""

	if [ $hours -gt 0 ]; then
		timeString="${hours}时"
	fi

	if [ $minutes -gt 0 ] || [ $hours -gt 0 ]; then
		timeString="${timeString}${minutes}分"
	fi

	if [ $remainingSeconds -gt 0 ] || [ $minutes -gt 0 ] || [ $hours -gt 0 ]; then
		timeString="${timeString}${remainingSeconds}秒"
	fi

	echo "$timeString"
}

close_dg_process(){
	dg_process=$(pidof ddnsgo)
	if [ -n "${dg_process}" ]; then
		echo_date "⛔关闭DDNS-Go进程..."
		if [ -f "/koolshare/perp/ddnsgo/rc.main" ]; then
			perpctl d ddnsgo >/dev/null 2>&1
		fi
		rm -rf /koolshare/perp/ddnsgo
		killall ddnsgo >/dev/null 2>&1
		kill -9 "${dg_process}" >/dev/null 2>&1
	fi
}

start_dg_process(){
	rm -rf ${DG_LOG_FILE}
	if [ "${ddnsgo_skipverify}" == "1" ]; then
		skipverify="-skipVerify"
	fi
	if [ "${ddnsgo_watchdog}" == "1" ]; then
		echo_date "🟠启动 DDNS-Go 进程，开启进程实时守护..."
		mkdir -p /koolshare/perp/ddnsgo
		cat >/koolshare/perp/ddnsgo/rc.main <<-EOF
			#!/bin/sh
			/koolshare/scripts/base.sh
			if test \${1} = 'start' ; then
				exec ddnsgo -l :${ddnsgo_port} -f ${ddnsgo_localcheck} -cacheTimes ${ddnsgo_wancheck} ${skipverify} -c $CONF_FILE
			fi
			exit 0

		EOF
		chmod +x /koolshare/perp/ddnsgo/rc.main
		chmod +t /koolshare/perp/ddnsgo/
		sync
		perpctl A ddnsgo >/dev/null 2>&1
		perpctl u ddnsgo >/dev/null 2>&1
		detect_running_status ddnsgo
	else
		echo_date "🟠启动 DDNS-Go 进程..."
		rm -rf /tmp/ddnsgo.pid
		start-stop-daemon -S -q -b -m -p /tmp/var/ddnsgo.pid -x /koolshare/bin/ddnsgo -- -l :${ddnsgo_port} -f ${ddnsgo_localcheck} -cacheTimes ${ddnsgo_wancheck} ${skipverify} -c $CONF_FILE
		sleep 2
		detect_running_status ddnsgo
	fi
}

check_config(){
	lan_ipaddr=$(ifconfig br0|grep -Eo "inet addr.+"|awk -F ":| " '{print $3}' 2>/dev/null)
	dbus set ddnsgo_addr=$lan_ipaddr
	mkdir -p /koolshare/configs/ddnsgo
	mkdir -p /tmp/ddnsgo
	if [ ! -f "$CONF_FILE" ]; then
		touch "$CONF_FILE"
	fi

	if [ $ddnsgo_publicswitch == "0" ]; then
		nopubbool="true"
	else
		nopubbool="false"
	fi
	pattern="notallowwanaccess:"
	if grep -q "$pattern" "$CONF_FILE"; then
		sed -i "s/$pattern.*/$pattern $nopubbool/" "$CONF_FILE"
	else
		echo "$pattern $nopubbool" >> "$CONF_FILE"
	fi
}

open_port() {
	local CM=$(lsmod | grep xt_comment)
	local OS=$(uname -r)

	if [ $(number_test ${ddnsgo_port}) != "0" ]; then
		dbus set ddnsgo_port=9876
	fi
	
	if [ -z "${CM}" -a -f "/lib/modules/${OS}/kernel/net/netfilter/xt_comment.ko" ];then
		echo_date "ℹ️加载xt_comment.ko内核模块！"
		insmod /lib/modules/${OS}/kernel/net/netfilter/xt_comment.ko
	fi

	echo_date "🧱添加防火墙入站规则，打开DDNS-Go端口：${ddnsgo_port}"
	local MATCH=$(iptables -t filter -S INPUT | grep -w "dg_rule")
	if [ -z "${MATCH}" ];then
		iptables -t filter -I INPUT -d ${ddnsgo_addr} -p tcp -m conntrack --ctstate DNAT -m tcp --dport ${ddnsgo_port} -j ACCEPT -m comment --comment "dg_rule" >/dev/null 2>&1
	fi

	local MATCH=$(iptables -t nat -S VSERVER | grep -w "dg_rule")
	if [ -z "${MATCH}" ];then
		iptables -t nat -I VSERVER -p tcp -m tcp --dport ${ddnsgo_port} -j DNAT --to-destination ${ddnsgo_addr}:${ddnsgo_port} -m comment --comment "dg_rule" >/dev/null 2>&1
	fi

	local MATCH=$(ip6tables -t filter -S INPUT | grep -w "dg_rule")
	if [ -z "${MATCH}" ];then
		ip6tables -t filter -I INPUT -p tcp -m tcp --dport ${ddnsgo_port} -j ACCEPT -m comment --comment "dg_rule" >/dev/null 2>&1
	fi
}

close_port(){
	echo_date "🧱关闭本插件在防火墙上打开的所有端口!"
	while [ $(iptables -t filter -S INPUT | grep -cw "dg_rule") -ge 1 ];
	do
		`iptables -t filter -S INPUT | grep -w "dg_rule" | sed 's/-A/iptables -t filter -D/g'` >/dev/null 2>&1
	done
	while [ $(iptables -t nat -S VSERVER | grep -cw "dg_rule") -ge 1 ];
	do
		`iptables -t nat -S VSERVER | grep -w "dg_rule" | sed 's/-A/iptables -t nat -D/g'` >/dev/null 2>&1
	done
	while [ $(ip6tables -t filter -S INPUT | grep -cw "dg_rule") -ge 1 ];
	do
		`ip6tables -t filter -S INPUT | grep -w "dg_rule" | sed 's/-A/ip6tables -t filter -D/g'` >/dev/null 2>&1
	done
}

close_dg(){
	# 1. remove log
	rm -rf ${DG_LOG_FILE}

	# 2. stop ddns-go
	close_dg_process

	# 3. close_port
	close_port
}

start_dg (){
	# 1. check_config
	check_config

	# 2. stop first
	close_dg_process

	# 3. start process
	start_dg_process

	# 3. open port
	close_port >/dev/null 2>&1
	if [ "${ddnsgo_publicswitch}" == "1" ];then
		open_port
	fi
}

case $1 in
start)
	if [ "${ddnsgo_enable}" == "1" ]; then
		logger "[软件中心-开机自启]: DDNS-Go自启动开启！"
		start_dg
	else
		logger "[软件中心-开机自启]: DDNS-Go未开启，不自动启动！"
	fi
	;;
boot_up)
	if [ "${ddnsgo_enable}" == "1" ]; then
		start_dg
	fi
	;;
start_nat)
	if [ "${ddnsgo_enable}" == "1" ]; then
		close_port >/dev/null 2>&1
		if [ "${ddnsgo_publicswitch}" == "1" ];then
			logger "[软件中心]-[${0##*/}]: NAT重启触发打开DDNS-Go防火墙端口！"
			open_port
		fi
	fi
	;;
stop)
	close_dg
	;;
esac

case $2 in
web_submit)
	set_lock
	true > ${LOG_FILE}
	http_response "$1"
	# 调试
	# echo_date "$BASH $ARGS" | tee -a ${LOG_FILE}
	# echo_date ddnsgo_enable=${ddnsgo_enable} | tee -a ${LOG_FILE}
	if [ "${ddnsgo_enable}" == "1" ]; then
		echo_date "▶️开启DDNS-Go！" | tee -a ${LOG_FILE}
		start_dg | tee -a ${LOG_FILE}
	elif [ "${ddnsgo_enable}" == "2" ]; then
		echo_date "🔁重启DDNS-Go！" | tee -a ${LOG_FILE}
		dbus set ddnsgo_enable=1
		start_dg | tee -a ${LOG_FILE}
	else
		echo_date "ℹ️停止DDNS-Go！" | tee -a ${LOG_FILE}
		close_dg | tee -a ${LOG_FILE}
	fi
	echo DD01N05S | tee -a ${LOG_FILE}
	unset_lock
	;;
status)
	check_status
	;;
esac
