;
; kr font viewer
; developed by JANGOON
; on 26.01.05
; for DC Inside Mademoiselle Gallery
; 

#NoEnv
#SingleInstance force
#KeyHistory 0
ListLines Off
SetBatchLines, -1
SetWinDelay, -1
SetControlDelay, -1

if (!A_IsAdmin) {
	try {
		Run, *RunAs "%A_ScriptFullPath%"
		ExitApp
	} catch
		ExitApp
}

if (A_IsCompiled) {
	RegRead, iev, HKEY_CURRENT_USER, % "Software\Microsoft\Internet Explorer\Main\FeatureControl\FEATURE_BROWSER_EMULATION", % A_ScriptName
	if (iev != 11000) {
		RegWrite, REG_DWORD, HKEY_CURRENT_USER, % "Software\Microsoft\Internet Explorer\Main\FeatureControl\FEATURE_BROWSER_EMULATION", % A_ScriptName, 11000
	}
} else {
	RegRead, iev, HKEY_CURRENT_USER, % "Software\Microsoft\Internet Explorer\Main\FeatureControl\FEATURE_BROWSER_EMULATION", % "AuthoHokey.exe"
	if (iev != 11000) {
		RegWrite, REG_DWORD, HKEY_CURRENT_USER, % "Software\Microsoft\Internet Explorer\Main\FeatureControl\FEATURE_BROWSER_EMULATION", % "AutoHotkey.exe", 11000
	}
}

Fonts := {0: {}, 1: {}}
, getFonts(), setHtml()

Gui, Margin, 0, 0
Gui, +hwndhGui +Resize +Minsize860x600
Gui, Font, s16
Gui, Add, Edit, x130 y10 w50 Number
Gui, Add, UpDown, Range1-99 Wrap gUD, % Edit1 := 26
Gui, Add, Text, x+2 hp 0x201, % "pt"
Gui, Add, Edit, x+10 w340, % Edit2 := "악역영애 갤러리"
Gui, Add, Button, x+10 yp-1 w60 hp+2 gBtn Default, % "확인"
Gui, Add, Checkbox, x+10 yp+1 hp-2 Checked gBtn, % "한글만"
Gui, Font, bold
Gui, Add, Text, x+5 yp+2 hp +0x201 gTgl, % "BalloonsAI"
Gui, Add, ActiveX, xm-1 y+10 w860 h600 Border vwb, Shell.Explorer
GuiControl, Focus, Edit2
Gui, Show, , % "폰트 뷰어"
onAi := onPs := false
wb.silent := true, wb.Navigate("about:blank")
while (wb.readyState != 4 || wb.busy)
	Sleep, -1
doc := wb.doc, ComObjConnect(doc, wEvent)
for i in Fonts.1
	t .= StrReplace(StrReplace(StrReplace(table, "$1", i), "$2", Edit2), "$3", Edit1)
wb.Document.write(body)
, wb.document.getElementById("item-container").innerHTML := t
, wb.document.getElementById("buttonTrigger").click()
return

Tgl:
Gui, Font, % (onAi := !onAi) ? "cRed" : "cBlack"
GuiControl, Font, Static2
return

toolCheck(ByRef a, ByRef b, ByRef c) {
	static UIA := UIA_Interface()
	static aId := "AutomationId=QApplication.MainWindow.QStackedWidget.QSplitter.QStackedWidget.TextPanel.FontFormatPanel.FontFamilyBox.LineEdit"
	if (a != hCur := WinExist("BalloonsTranslator ahk_exe python.exe")) {
		if (b := UIA.ElementFromHandle(a := hCur)) {
			if (c := b.FindFirstBy(aId))
				return true
		}
	}
	return false
}

OnExit("ExitFunc")

GuiClose:
ExitFunc()
return

ExitFunc() {
	global iev
	if (!A_IsCompiled && iev != 11000)
		RegWrite, REG_DWORD, HKEY_CURRENT_USER, % "Software\Microsoft\Internet Explorer\Main\FeatureControl\FEATURE_BROWSER_EMULATION", % "AutoHotkey.exe", % iev
	ExitApp
}

class wEvent
{
	onClick(w) {
		global onAi
		v := w.getElementById("clickTrigger").textContent
		if (v)
			if (onAi) {
				if (toolCheck(hAi, eAi, el))
					el.SetValue(v)
				else {
					MsgBox, 48, Announce, % "Ai 툴을 찾을 수 없습니다. 클립보드에 복사합니다."
					onAi := false
					Gui, Font, cBlack
					GuiControl, Font, Static2
				}
			} else {
				Clipboard := v
				ToolTip, % """" v """ 폰트가 복사되었습니다."
				SetTimer, tOut, -1500
			}
	}
}

tOut:
ToolTip
return

#if WinActive("ahk_id" hGui)
+Up::
+Down::
Edit1 += A_ThisHotkey = "+Up" ? 2 : -2
GuiControl, , Edit1, % Edit1
Task := "확인"
goto, Btn
return

^k::
GuiControlGet, Button2
GuiControl, , Button2, % !Button2 := Button2
Task := Button2
goto, Btn
return

F11::
Gui, Maximize
return
#If

^'::
SendInput, % "…"
return

Btn:
if (A_GuiControl)
	Task := A_GuiControl
Switch Task
{
	Case "확인":
		UD:
		GuiControlGet, Edit2
		if (Edit2 = "")
			Edit2 := "악역영애 갤러리"
		GuiControlGet, Edit1
		containers := wb.Document.getElementsByClassName("preview")
		Loop, % containers.Length
			containers[A_Index - 1].innerText := Edit2, containers[A_Index - 1].style.fontSize := Edit1 "pt"
		wb.document.getElementById("buttonTrigger").click()
	Default:
		GuiControlGet, Edit2
		GuiControlGet, v, , Button2
		t := ""
		for i in Fonts[v]
			t .= StrReplace(StrReplace(StrReplace(table, "$1", i), "$2", Edit2 ? Edit2 : "악역영애 갤러리"), "$3", Edit1)
		wb.document.getElementById("item-container").innerHTML := t
		, wb.document.getElementById("buttonTrigger").click()
}
return

GuiSize:
GuiControl, Move, wb, % "w" A_GuiWidth + 2 " h" A_GuiHeight - 49
wb.document.getElementById("resizeTrigger").click()
return

getFonts() {
	hdc := DllCall("GetDC", "Ptr", 0)
	VarSetCapacity(logfont, 92, 0)
	NumPut(1, logfont, 23, "UChar")
	pCallback := RegisterCallback("EnumFontFamExProc", "F")
	DllCall("EnumFontFamiliesEx", "Ptr", hdc, "Ptr", &logfont, "Ptr", pCallback, "Ptr", 0, "UInt", 0)
	DllCall("ReleaseDC", "Ptr", 0, "Ptr", hdc)
}

EnumFontFamExProc(lpelfe, lpntme, FontType, lParam) {
	global Fonts
	charset := NumGet(lpelfe+0, 23, "UChar")
	n := StrGet(lpelfe + 28, 32, "UTF-16")
	if (SubStr(n, 1, 1) = "@")
		return 1
	n := RegExReplace(n, "i)[\s\-]+(?:(?:Semi|Demi|Extra)?(?:Bold|Light)|Regular|Medium|Thin|Black|Heavy|Italic|Oblique|[RBLMTHI]|SB|EB|EL|SL)+$")
	if (charset = 129)
		Fonts.1[n] := true, Fonts.0[n] := true
	else if (charset = 0)
		Fonts.0[n] := true
	return 1
}

setHtml() {
global
body=
(

<html lang="ko">
<head>
	<meta http-equiv="X-UA-Compatible" content="IE=edge">
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
	<title>폰트 탐색기</title>
	<style type="text/css">
		* {
			box-sizing: border-box;
		}
		body, html {
			width: 100`%;
			margin: 0;
			padding: 0;
			font-family: "돋움", Dotum, sans-serif;
			font-size: 14px;
			background-color: #f0f0f0;
		}
		#item-container { 
			width: 100`%; 
			height: 30px;
			padding: 0; 
			font-size: 0;
			text-align: center; 
		}
		.item-unit {
			display: inline-block;
			vertical-align: top;
			margin: 0 -1px -1px 0; 
			border: 1px solid #ccc;
			text-align: left;
			background: #fff;
			font-size: 14px;
			width: 420px; 
			overflow: hidden;
			*display: inline;
			*zoom: 1;
		}
		.item-table {
			display: table;
			width: 100`%;
			height: 100`%;
			border-collapse: collapse;
			table-layout: fixed;
		}
		.item-row {
			display: table-row;
		}
		.label, .value {
			display: table-cell;
			vertical-align: middle;
			padding-right: 10px;
		}
		.label {
			width: 140px;
			background-color: #f2f2f2;
			border-right: 1px solid #ddd;
		}
		.label:hover {
			cursor: pointer;
		}
		.value {
			width: 300px;
		}
		.inner-box {
			padding: 0px 10px;
			overflow: hidden;
			white-space: nowrap;
			text-overflow: clip;
		}
	</style>
</head>
<body">
<button id="buttonTrigger" onclick="syncHeights()" style="display: none;"></button>
<button id="resizeTrigger" onclick="colCheck()" style="display: none;"></button>
<span id="clickTrigger" style="display: none;"></span>
<div id="item-container">
</div>
<script>
	var cols = 0;
	function colCheck() {
		var items = document.getElementsByClassName('item-unit');
		if (!items || items.length === 0) return;
		var colCount = 0;
		var firstY = items[0].offsetTop;
		for (var i = 0; i < items.length; i++) {
			if (Math.abs(items[i].offsetTop - firstY) <= 10) {
				colCount++;
			} else {
				break;
			}
		}
		if (colCount !== cols) {
			cols = colCount;
			syncHeights();
		}
	}
	function syncHeights() {
		var items = document.getElementsByClassName('item-unit');
		if (items.length === 0) return;
		for (var i = 0; i < items.length; i++) {
			items[i].style.height = 'auto';
		}
		var start = 0;
		while (start < items.length) {
			var currentRowY = items[start].offsetTop;
			var rowMaxHeight = 0;
			var end = start;
			for (var j = start; j < items.length; j++) {
				if (Math.abs(items[j].offsetTop - currentRowY) > 5) break;
				if (items[j].offsetHeight > rowMaxHeight) {
					rowMaxHeight = items[j].offsetHeight;
				}
				end = j;
			}
			for (var k = start; k <= end; k++) {
				items[k].style.height = rowMaxHeight + 'px';
			}
			start = end + 1;
		}
	}
	function clipSet(e) {
		document.getElementById("clickTrigger").textContent = e.textContent;
		setTimeout(function() { document.getElementById("clickTrigger").textContent = ""; }, 100);
	}
	window.onload = syncHeights();
</script>
</body>
</html>
)
table=
(
<div class="item-unit">
	<div class="item-table"><div class="item-row">
		<div class="label"><div class="inner-box" onclick="clipSet(this);">$1</div></div>
		<div class="value"><div class="inner-box preview" style="font-size: $3pt; font-family: '$1'";>$2</div></div>
	</div></div>
</div>

)
}

