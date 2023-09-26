#!/bin/sh
eval $(dbus export ddnsgo_)
source /koolshare/scripts/base.sh

if [ "$ddnsgo_enable" == "1" ];then
	echo_date "先关闭DDNS-Go插件！"
	sh /koolshare/scripts/ddnsgo_config.sh stop
fi

find /koolshare/init.d/ -name "*ddnsgo*" | xargs rm -rf
rm -rf /koolshare/bin/ddnsgo 2>/dev/null
rm -rf /tmp/ddnsgo 2>/dev/null
rm -rf /koolshare/res/icon-ddnsgo.png 2>/dev/null
rm -rf /koolshare/scripts/ddnsgo*.sh 2>/dev/null
rm -rf /koolshare/webs/Module_ddnsgo.asp 2>/dev/null
rm -rf /koolshare/scripts/ddnsgo_install.sh 2>/dev/null
rm -rf /koolshare/scripts/uninstall_ddnsgo.sh 2>/dev/null
rm -rf /koolshare/configs/ddnsgo 2>/dev/null
rm -rf /tmp/upload/ddnsgo* 2>/dev/null

dbus remove ddnsgo_version
dbus remove ddnsgo_binary
dbus remove ddnsgo_watchdog
dbus remove ddnsgo_localcheck
dbus remove ddnsgo_wancheck
dbus remove ddnsgo_port
dbus remove ddnsgo_addr
dbus remove ddnsgo_enable
dbus remove ddnsgo_skipverify
dbus remove ddnsgo_publicswitch
dbus remove softcenter_module_ddnsgo_name
dbus remove softcenter_module_ddnsgo_install
dbus remove softcenter_module_ddnsgo_version
dbus remove softcenter_module_ddnsgo_title
dbus remove softcenter_module_ddnsgo_description