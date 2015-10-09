(function (console) { "use strict";
var Clock = function() { };
Clock.activate = function(state) {
	if(state != null) Clock.enabled = state.enabled; else Clock.enabled = true;
	if(Clock.enabled == null) Clock.enabled = true;
	Clock.showSeconds = atom.config.get("clock.seconds");
	Clock.format24 = atom.config.get("clock.format");
	var this1;
	var _this = window.document;
	this1 = _this.createElement("div");
	this1.classList.add("status-bar-clock","inline-block");
	Clock.view = this1;
	Clock.configChangeListener = atom.config.onDidChange("clock",{ },function(e) {
		Clock.showSeconds = e.newValue.seconds;
		Clock.format24 = e.newValue.format;
		_$Clock_ClockView_$Impl_$.setTime(Clock.view,new Date(),Clock.showSeconds,Clock.format24);
	});
	Clock.commandToggleSeconds = atom.commands.add("atom-workspace","clock:toggle-seconds",function(_) {
		Clock.showSeconds = !Clock.showSeconds;
	});
	if(Clock.enabled) Clock.show(); else Clock.hide();
};
Clock.deactivate = function() {
	if(Clock.timer != null) {
		Clock.timer.stop();
		Clock.timer = null;
	}
	if(Clock.configChangeListener != null) Clock.configChangeListener.dispose();
	if(Clock.commandShow != null) Clock.commandShow.dispose();
	if(Clock.commandHide != null) Clock.commandHide.dispose();
	Clock.commandToggleSeconds.dispose();
};
Clock.serialize = function() {
	return { enabled : Clock.enabled};
};
Clock.show = function() {
	Clock.view.style.display = "inline-block";
	Clock.enabled = true;
	Clock.timer = new haxe_Timer(1000);
	Clock.timer.run = Clock.update;
	Clock.commandHide = atom.commands.add("atom-workspace","clock:hide",function(_) {
		Clock.hide();
	});
	if(Clock.commandShow != null) {
		Clock.commandShow.dispose();
		Clock.commandShow = null;
	}
};
Clock.hide = function() {
	Clock.view.style.display = "none";
	Clock.enabled = false;
	if(Clock.timer != null) {
		Clock.timer.stop();
		Clock.timer = null;
	}
	Clock.commandShow = atom.commands.add("atom-workspace","clock:show",function(_) {
		Clock.show();
	});
	if(Clock.commandHide != null) {
		Clock.commandHide.dispose();
		Clock.commandHide = null;
	}
};
Clock.update = function() {
	_$Clock_ClockView_$Impl_$.setTime(Clock.view,new Date(),Clock.showSeconds,Clock.format24);
};
Clock.consumeStatusBar = function(bar) {
	bar.addRightTile({ item : Clock.view, priority : -100});
};
var _$Clock_ClockView_$Impl_$ = {};
_$Clock_ClockView_$Impl_$.setTime = function(this1,time,showSeconds,format24) {
	var hours = time.getHours();
	if(!format24 && hours > 12) hours -= 12;
	var str = _$Clock_ClockView_$Impl_$.formatTimePart(hours) + ":" + _$Clock_ClockView_$Impl_$.formatTimePart(time.getMinutes());
	if(showSeconds) str += ":" + _$Clock_ClockView_$Impl_$.formatTimePart(time.getSeconds());
	this1.textContent = str;
};
_$Clock_ClockView_$Impl_$.formatTimePart = function(i) {
	if(i < 10) return "0" + i; else if(i == null) return "null"; else return "" + i;
};
var haxe_Timer = function(time_ms) {
	var me = this;
	this.id = setInterval(function() {
		me.run();
	},time_ms);
};
haxe_Timer.prototype = {
	stop: function() {
		if(this.id == null) return;
		clearInterval(this.id);
		this.id = null;
	}
	,run: function() {
	}
};
module.exports = Clock;
Clock.config = { seconds : { 'title' : "Show seconds", 'type' : "boolean", 'default' : true}, format : { 'title' : "24-hour format", 'type' : "boolean", 'default' : true}};
})(typeof console != "undefined" ? console : {log:function(){}});
