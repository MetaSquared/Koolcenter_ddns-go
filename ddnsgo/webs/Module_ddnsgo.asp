<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="X-UA-Compatible" content="IE=Edge" />
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<meta http-equiv="Pragma" content="no-cache" />
<meta http-equiv="Expires" content="-1" />
<link rel="shortcut icon" href="/res/icon-ddnsgo.png" />
<link rel="icon" href="/res/icon-ddnsgo.png" />
<title>软件中心 - DDNS-Go</title>
<link rel="stylesheet" type="text/css" href="index_style.css">
<link rel="stylesheet" type="text/css" href="form_style.css">
<link rel="stylesheet" type="text/css" href="usp_style.css">
<link rel="stylesheet" type="text/css" href="css/element.css">
<link rel="stylesheet" type="text/css" href="/device-map/device-map.css">
<link rel="stylesheet" type="text/css" href="/js/table/table.css">
<link rel="stylesheet" type="text/css" href="/res/layer/theme/default/layer.css">
<link rel="stylesheet" type="text/css" href="/res/softcenter.css">
<script language="JavaScript" type="text/javascript" src="/state.js"></script>
<script language="JavaScript" type="text/javascript" src="/popup.js"></script>
<script language="JavaScript" type="text/javascript" src="/help.js"></script>
<script language="JavaScript" type="text/javascript" src="/js/jquery.js"></script>
<script language="JavaScript" type="text/javascript" src="/js/httpApi.js"></script>
<script language="JavaScript" type="text/javascript" src="/client_function.js"></script>
<script language="JavaScript" type="text/javascript" src="/general.js"></script>
<script language="JavaScript" type="text/javascript" src="/js/table/table.js"></script>
<script language="JavaScript" type="text/javascript" src="/res/softcenter.js"></script>
<script language="JavaScript" type="text/javascript" src="/help.js"></script>
<script language="JavaScript" type="text/javascript" src="/switcherplugin/jquery.iphone-switch.js"></script>
<script language="JavaScript" type="text/javascript" src="/validator.js"></script>
<style>
a:focus {
	outline: none;
}
.SimpleNote {
	padding:5px 5px;
}
i {
	color: #FC0;
	font-style: normal;
} 
.loadingBarBlock{
	width:740px;
}
.popup_bar_bg_ks{
	position:fixed;
	margin: auto;
	top: 0;
	left: 0;
	width:100%;
	height:100%;
	z-index:99;
	/*background-color: #444F53;*/
	filter:alpha(opacity=90);  /*IE5、IE5.5、IE6、IE7*/
	background-repeat: repeat;
	visibility:hidden;
	overflow:hidden;
	/*background: url(/images/New_ui/login_bg.png);*/
	background:rgba(68, 79, 83, 0.85) none repeat scroll 0 0 !important;
	background-position: 0 0;
	background-size: cover;
	opacity: .94;
}

.FormTitle em {
	color: #00ffe4;
	font-style: normal;
	/*font-weight:bold;*/
}
.FormTable th {
	width: 30%;
}
.formfonttitle {
	font-family: Roboto-Light, "Microsoft JhengHei";
	font-size: 18px;
	margin-left: 5px;
}
.FormTitle, .FormTable, .FormTable th, .FormTable td, .FormTable thead td, .FormTable_table, .FormTable_table th, .FormTable_table td, .FormTable_table thead td {
	font-size: 14px;
	font-family: Roboto-Light, "Microsoft JhengHei";
}
.content_status {
	position: absolute;
	-webkit-border-radius: 5px;
	-moz-border-radius: 5px;
	border-radius:10px;
	z-index: 10;
	margin-left: -215px;
	top: 0;
	left: 0;
	height:auto;
	box-shadow: 3px 3px 10px #000;
	background: rgba(0,0,0,0.88);
	width:748px;
	/*display:none;*/
	visibility:hidden;
}
.user_title{
	text-align:center;
	font-size:18px;
	color:#99FF00;
	padding:10px;
	font-weight:bold;
}
.contentM_qis {
	position: absolute;
	-webkit-border-radius: 5px;
	-moz-border-radius: 5px;
	border-radius: 5px;
	z-index: 200;
	background-color:#2B373B;
	margin-left: 10px;
	top: 250px;
	width:730px;
	height:auto;
	box-shadow: 3px 3px 10px #000;
	/*display:none;*/
	line-height:1.8;
	visibility:hidden;
}
.pop_div_bg{
}
.QISform_wireless {
	width:690px;
	font-size:14px;
	color:#FFFFFF;
}
#ddnsgo_db_settings_div{
}
</style>
<script type="text/javascript">
var dbus = {};
var refresh_flag
var db_ddnsgo = {}
var count_down;
var _responseLen;
var STATUS_FLAG;
var noChange = 0;
var params_check = ['ddnsgo_publicswitch', 'ddnsgo_watchdog', 'ddnsgo_skipverify'];
var params_input = ['ddnsgo_localcheck', 'ddnsgo_wancheck', 'ddnsgo_port'];

String.prototype.myReplace = function(f, e){
	var reg = new RegExp(f, "g"); 
	return this.replace(reg, e); 
}

function init() {
	show_menu(menu_hook);
	register_event();
	get_dbus_data();
	check_status();
}

function get_dbus_data(){
	$.ajax({
		type: "GET",
		url: "/_api/ddnsgo_",
		dataType: "json",
		async: false,
		success: function(data) {
			dbus = data.result[0];
			conf2obj();
			show_hide_element();
			pannel_access();
		}
	});
}

function pannel_access(){
	if(dbus["ddnsgo_enable"] == "1"){
		var protocol = "http:";
		var hostname = document.domain;
		if (hostname.indexOf('.kooldns.cn') != -1 || hostname.indexOf('.ddnsto.com') != -1 || hostname.indexOf('.tocmcc.cn') != -1) {
			protocol = location.protocol;//如果是走的ddnsto则不管是否开启公网开关。
			if(hostname.indexOf('.kooldns.cn') != -1){
				hostname = hostname.replace('.kooldns.cn','-ddnsgo.kooldns.cn');
			}else if(hostname.indexOf('.ddnsto.com') != -1){
				hostname = hostname.replace('.ddnsto.com','-ddnsgo.ddnsto.com');
			}else{
				hostname = hostname.replace('.tocmcc.cn','-ddnsgo.tocmcc.cn');
			}

			webUiHref = protocol + "//" + hostname;
		}else{
			webUiHref = protocol + "//" + hostname + ":" + dbus["ddnsgo_port"];
		}

		E("dgnav").href = webUiHref;
		E("dgnav").innerHTML = "访问 DDNS-Go";
	}
}

function conf2obj(){
	for (var i = 0; i < params_check.length; i++) {
		if(dbus[params_check[i]]){
			E(params_check[i]).checked = dbus[params_check[i]] != "0";
		}
	}
	for (var i = 0; i < params_input.length; i++) {
		if (dbus[params_input[i]]) {
			$("#" + params_input[i]).val(dbus[params_input[i]]);
		}
	}
	if (dbus["ddnsgo_version"]){
		E("ddnsgo_version").innerHTML = " - " + dbus["ddnsgo_version"];
	}
	if (dbus["ddnsgo_binary"]){
		E("ddnsgo_binary").innerHTML = dbus["ddnsgo_binary"];
	}
}

function show_hide_element(){
	if(dbus["ddnsgo_enable"] == "1"){
		E("dg_status").style.display = "";
		E("dg_binary").style.display = "";
		E("dg_pannel").style.display = "";
		E("dg_apply_1").style.display = "none";
		E("dg_apply_2").style.display = "";
		E("dg_apply_3").style.display = "";
	}else{
		E("dg_status").style.display = "";
		E("dg_binary").style.display = "none";
		E("dg_pannel").style.display = "none";
		E("dg_apply_1").style.display = "";
		E("dg_apply_2").style.display = "none";
		E("dg_apply_3").style.display = "none";
	}
}

function menu_hook(title, tab) {
	tabtitle[tabtitle.length - 1] = new Array("", "ddnsgo");
	tablink[tablink.length - 1] = new Array("", "Module_ddnsgo.asp");
}

function register_event(){
	$(".popup_bar_bg_ks").click(
		function() {
			count_down = -1;
		});
	$(window).resize(function(){
		var page_h = window.innerHeight || document.documentElement.clientHeight || document.body.clientHeight;
		var page_w = window.innerWidth || document.documentElement.clientWidth || document.body.clientWidth;
		if($('.popup_bar_bg_ks').css("visibility") == "visible"){
			document.scrollingElement.scrollTop = 0;
			var log_h = E("loadingBarBlock").clientHeight;
			var log_w = E("loadingBarBlock").clientWidth;
			var log_h_offset = (page_h - log_h) / 2;
			var log_w_offset = (page_w - log_w) / 2 + 90;
			$('#loadingBarBlock').offset({top: log_h_offset, left: log_w_offset});
		}
	});
}

function check_status(){
	var id = parseInt(Math.random() * 100000000);
	var postData = {"id": id, "method": "ddnsgo_config.sh", "params":['status'], "fields": ""};
	$.ajax({
		type: "POST",
		url: "/_api/",
		async: true,
		data: JSON.stringify(postData),
		success: function (response) {
			E("ddnsgo_status").innerHTML = response.result;
			setTimeout("check_status();", 10000);
		},
		error: function(){
			E("ddnsgo_status").innerHTML = "获取运行状态失败";
			setTimeout("check_status();", 5000);
		}
	});
}

function save(flag){
	var db_ddnsgo = {};
	if(flag){
		console.log(flag)
		db_ddnsgo["ddnsgo_enable"] = flag;
	}else{
		db_ddnsgo["ddnsgo_enable"] = "0";
	}
	for (var i = 0; i < params_check.length; i++) {
			db_ddnsgo[params_check[i]] = E(params_check[i]).checked ? '1' : '0';
	}
	for (var i = 0; i < params_input.length; i++) {
		if (E(params_input[i])) {
			db_ddnsgo[params_input[i]] = E(params_input[i]).value;
		}
	} 
	var id = parseInt(Math.random() * 100000000);
	var postData = {"id": id, "method": "ddnsgo_config.sh", "params": ["web_submit"], "fields": db_ddnsgo};
	$.ajax({
		type: "POST",
		url: "/_api/",
		data: JSON.stringify(postData),
		dataType: "json",
		success: function(response) {
			if(response.result == id){
				get_log();
			}
		}
	});
}

function get_log(flag){
	E("ok_button").style.visibility = "hidden";
	showALLoadingBar();
	$.ajax({
		url: '/_temp/ddnsgo_log.txt',
		type: 'GET',
		cache:false,
		dataType: 'text',
		success: function(response) {
			var retArea = E("log_content");
			if (response.search("DD01N05S") != -1) {
				retArea.value = response.myReplace("DD01N05S", " ");
				E("ok_button").style.visibility = "visible";
				retArea.scrollTop = retArea.scrollHeight;
				if(flag == 1){
					count_down = -1;
					refresh_flag = 0;
				}else{
					count_down = 6;
					refresh_flag = 1;
				}
				count_down_close();
				return false;
			}
			setTimeout("get_log(" + flag + ");", 500);
			retArea.value = response.myReplace("DD01N05S", " ");
			retArea.scrollTop = retArea.scrollHeight;
		},
		error: function(xhr) {
			E("loading_block_title").innerHTML = "暂无日志信息 ...";
			E("log_content").value = "日志文件为空，请关闭本窗口！";
			E("ok_button").style.visibility = "visible";
			return false;
		}
	});
}

function showALLoadingBar(){
	document.scrollingElement.scrollTop = 0;
	E("loading_block_title").innerHTML = "&nbsp;&nbsp;DDNS-Go日志信息";
	E("LoadingBar").style.visibility = "visible";
	var page_h = window.innerHeight || document.documentElement.clientHeight || document.body.clientHeight;
	var page_w = window.innerWidth || document.documentElement.clientWidth || document.body.clientWidth;
	var log_h = E("loadingBarBlock").clientHeight;
	var log_w = E("loadingBarBlock").clientWidth;
	var log_h_offset = (page_h - log_h) / 2;
	var log_w_offset = (page_w - log_w) / 2 + 90;
	$('#loadingBarBlock').offset({top: log_h_offset, left: log_w_offset});
}
function hideALLoadingBar(){
	E("LoadingBar").style.visibility = "hidden";
	E("ok_button").style.visibility = "hidden";
	if (refresh_flag == "1"){
		refreshpage();
	}
}
function count_down_close() {
	if (count_down == "0") {
		hideALLoadingBar();
	}
	if (count_down < 0) {
		E("ok_button1").value = "手动关闭"
		return false;
	}
	E("ok_button1").value = "自动关闭（" + count_down + "）"
		--count_down;
	setTimeout("count_down_close();", 1000);
}
function open_alist_hint(itemNum) {
	statusmenu = "";
	width = "350px";
	switch (itemNum) {
		case 1:
			width ="300";
			statusmenu = "路由系统版本太老，根证书过期时请钩选";
			_caption = "跳过证书验证";
			return overlib(statusmenu, OFFSETX, 20, OFFSETY, -0, RIGHT, STICKY, WIDTH, 'width', CAPTION, _caption, CLOSETITLE, '');
		break;

		case 2:
			width ="300";
			statusmenu = "每*秒检查一次本地IP变化";
			_caption = "本地检查间隔时间";
			return overlib(statusmenu, OFFSETX, 20, OFFSETY, -0, RIGHT, STICKY, WIDTH, 'width', CAPTION, _caption, CLOSETITLE, '');
		break;

		case 3:
			width ="300";
			statusmenu = "当本地检查*次时，强制同DNS服务商对比IP是否有变化";
			_caption = "公网比对间隔次数";
			return overlib(statusmenu, OFFSETX, 20, OFFSETY, -0, RIGHT, STICKY, WIDTH, 'width', CAPTION, _caption, CLOSETITLE, '');
		break;

		default:
			statusmenu = '';
			_caption = '';
			return overlib(statusmenu, OFFSETX, 20, OFFSETY, -0, RIGHT, STICKY, WIDTH, 'width', CAPTION, _caption, CLOSETITLE, '');
		break;
	}
	
	var tag_name = document.getElementsByTagName('a');
	for (var i = 0; i < tag_name.length; i++)
		tag_name[i].onmouseout = nd;

	if (helpcontent == [] || helpcontent == "" || hint_array_id > helpcontent.length)
		return overlib('<#defaultHint#>', HAUTO, VAUTO);
	else if (hint_array_id == 0 && hint_show_id > 21 && hint_show_id < 24)
		return overlib(helpcontent[hint_array_id][hint_show_id], FIXX, 270, FIXY, 30);
	else {
		if (hint_show_id > helpcontent[hint_array_id].length)
			return overlib('<#defaultHint#>', HAUTO, VAUTO);
		else
			return overlib(helpcontent[hint_array_id][hint_show_id], HAUTO, VAUTO);
	}
}
function mOver(obj, hint){
	$(obj).css({
		"color": "#00ffe4",
		"text-decoration": "underline"
	});
	open_alist_hint(hint);
}
function mOut(obj){
	$(obj).css({
		"color": "#fff",
		"text-decoration": ""
	});
	E("overDiv").style.visibility = "hidden";
}

function validateInput(input, minValue, maxValue) {

	// 删除非数字字符
	input.value = input.value.replace(/\D/g, '');

	// 将输入值转换为整数
	let value = parseInt(input.value, 10);

	// 判断是否在指定范围内
	if (isNaN(value) || value < minValue || value > maxValue) {
		value = '';
	}

	// 更新文本框显示的值
	input.value = value;
}
</script>

</head>
<body id="app" skin='<% nvram_get("sc_skin"); %>' onload="init();">
	<div id="TopBanner"></div>
	<div id="Loading" class="popup_bg"></div>
	<div id="LoadingBar" class="popup_bar_bg_ks" style="z-index: 201;" >
		<table cellpadding="5" cellspacing="0" id="loadingBarBlock" class="loadingBarBlock" align="center">
			<tr>
				<td height="100">
					<div id="loading_block_title" style="margin:10px auto;margin-left:10px;width:85%; font-size:12pt;"></div>
					<div id="loading_block_spilt" style="margin:10px 0 10px 5px;" class="loading_block_spilt">
						<li><font color="#ffcc00">请等待日志显示完毕，并出现自动关闭按钮！</font></li>
						<li><font color="#ffcc00">在此期间请不要刷新本页面，不然可能导致问题！</font></li>
					</div>
					<div style="margin-left:15px;margin-right:15px;margin-top:10px;outline: 1px solid #3c3c3c;overflow:hidden">
						<textarea cols="50" rows="25" wrap="off" readonly="readonly" id="log_content" autocomplete="off" autocorrect="off" autocapitalize="off" spellcheck="false" style="border:1px solid #000;width:99%; font-family:'Lucida Console'; font-size:11px;background:transparent;color:#FFFFFF;outline: none;padding-left:5px;padding-right:22px;overflow-x:hidden"></textarea>
					</div>
					<div id="ok_button" class="apply_gen" style="background:#000;visibility:hidden;">
						<input id="ok_button1" class="button_gen" type="button" onclick="hideALLoadingBar()" value="确定">
					</div>
				</td>
			</tr>
		</table>
	</div>
	<!--=============================================================================================================-->
	<table class="content" align="center" cellpadding="0" cellspacing="0">
		<tr>
			<td width="17">&nbsp;</td>
			<td valign="top" width="202">
				<div id="mainMenu"></div>
				<div id="subMenu"></div>
			</td>
			<td valign="top">
				<div id="tabMenu" class="submenuBlock"></div>
				<table width="98%" border="0" align="left" cellpadding="0" cellspacing="0">
					<tr>
						<td align="left" valign="top">
							<table width="760px" border="0" cellpadding="5" cellspacing="0" bordercolor="#6b8fa3" class="FormTitle" id="FormTitle">
								<tr>
									<td bgcolor="#4D595D" colspan="3" valign="top">
										<div>&nbsp;</div>
										<div class="formfonttitle">DDNS-Go <lable id="ddnsgo_version"></lable></div>
										<div style="float: right; width: 15px; height: 25px; margin-top: -20px">
											<img id="return_btn" alt="" onclick="reload_Soft_Center();" align="right" style="cursor: pointer; position: absolute; margin-left: -30px; margin-top: -25px;" title="返回软件中心" src="/images/backprev.png" onmouseover="this.src='/images/backprevclick.png'" onmouseout="this.src='/images/backprev.png'" />
										</div>
										<div style="margin: 10px 0 10px 5px;" class="splitLine"></div>
										<div class="SimpleNote">
											<a href="https://github.com/jeessy2/ddns-go" target="_blank"><em>DDNS-Go</em></a>&nbsp;自动获得你的公网 IPv4 或 IPv6 地址，并解析到对应的域名服务
											<span><a type="button" href="https://github.com/jeessy2/ddns-go" target="_blank" class="ks_btn" style="margin-left:5px;" >项目地址</a></span>
											<span><a type="button" class="ks_btn" href="javascript:void(0);" onclick="get_log(1)" style="margin-left:5px;">插件日志</a></span>
										</div>
										<div id="ddnsgo_status_pannel">
											<table width="100%" border="1" align="center" cellpadding="4" cellspacing="0" bordercolor="#6b8fa3" class="FormTable">
												<thead>
													<tr>
														<td colspan="2">DDNS-Go - 状态</td>
													</tr>
												</thead>
												<tr id="dg_status" style="display: none;">
													<th>状态</th>
													<td>
														<span style="margin-left:4px" id="ddnsgo_status"></span>
													</td>
												</tr>
												<tr id="dg_binary" style="display: none;">
													<th>内核</th>
													<td>
														<span style="margin-left:4px" id="ddnsgo_binary"></span>
													</td>
												</tr>
												<tr id="dg_pannel" style="display: none;">
													<th>访问</th>
													<td>
														<a type="button" style="vertical-align:middle;cursor:pointer;" id="dgnav" class="ks_btn" href="" target="_blank">访问 DDNS-Go</a>
													</td>
												</tr>
											</table>
										</div>
										<div style="margin-top:10px">
											<table width="100%" border="1" align="center" cellpadding="4" cellspacing="0" bordercolor="#6b8fa3" class="FormTable">
												<thead>
													<tr>
														<td colspan="2">DDNS-Go - 设置</td>
													</tr>
												</thead>
												<tr>
													<th>实时进程守护</th>
													<td>
														<input type="checkbox" id="ddnsgo_watchdog" style="vertical-align:middle;">
													</td>
												</tr>
												<tr>
													<th>开启公网访问</th>
													<td>
														<input type="checkbox" id="ddnsgo_publicswitch" style="vertical-align:middle;">
													</td>
												</tr>
												<tr>
													<th><span onmouseover="mOver(this, 1)" onmouseleave="mOut(this)">跳过证书验证</span></th>
													<td>
														<input type="checkbox" id="ddnsgo_skipverify" style="vertical-align:middle;">
													</td>
												</tr>
												<tr id="dg_localcheck">
													<th><span onmouseover="mOver(this, 2)" onmouseleave="mOut(this)">本地检查间隔时间(单位:秒)</span></th>
													<td>
														<input type="text" id="ddnsgo_localcheck" oninput="validateInput(this, 1, 36000)" style="width: 50px;" maxlength="5" class="input_3_table" autocorrect="off" autocapitalize="off" style="background-color: rgb(89, 110, 116);" value="300">
													</td>
												</tr>
												<tr id="dg_wancheck">
													<th><span onmouseover="mOver(this, 3)" onmouseleave="mOut(this)">公网比对间隔次数</span></th>
													<td>
														<input type="text" id="ddnsgo_wancheck" oninput="validateInput(this, 1, 10000)" style="width: 50px;" maxlength="5" class="input_3_table" autocorrect="off" autocapitalize="off" style="background-color: rgb(89, 110, 116);" value="5">
													</td>
												</tr>
												<tr id="dg_port">
													<th>面板端口</th>
													<td>
														<input type="text" id="ddnsgo_port" oninput="validateInput(this, 1, 65535)" style="width: 50px;" maxlength="5" class="input_3_table" autocorrect="off" autocapitalize="off" style="background-color: rgb(89, 110, 116);" value="9876">
													</td>
												</tr>
											</table>
										</div>
										<div id="dg_apply" class="apply_gen">
											<input class="button_gen" style="display: none;" id="dg_apply_1" onClick="save(1)" type="button" value="开启" />
											<input class="button_gen" style="display: none;" id="dg_apply_2" onClick="save(2)" type="button" value="重启" />
											<input class="button_gen" style="display: none;" id="dg_apply_3" onClick="save(0)" type="button" value="关闭" />
										</div>
										<div style="margin: 10px 0 10px 5px;" class="splitLine"></div>
										<div style="margin:10px 0 0 5px">
											<li>若开启公网访问，请务必设置<em>足够复杂</em>的DDNS-Go后台登录用户名/密码!!!</li>
											
										</div>
									</td>
								</tr>
							</table>
						</td>
					</tr>
				</table>
			</td>
			<td width="10" align="center" valign="top"></td>
		</tr>
	</table>
	<div id="footer"></div>
</body>
</html>
