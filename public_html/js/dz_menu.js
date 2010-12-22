function initMenu() {
	var menu = $("a.menu");
  var submenu = $("div.menu-text");
  submenu.hide();
  
  menu.mouseover( function () { 
  	var thisSubmenu = $( "#sub" + $(this).attr( "id" ) ); 
  	var others = $("div.menu-text:not(#" + thisSubmenu.attr("id") + ")");
  	others.fadeOut("slow");
		var pos = $(this).position();
		var left = pos.left - ( thisSubmenu.width() / 2 ) + 30;
		left = (left<0) ? 0 : left; 
		thisSubmenu.css( "left", left );
		thisSubmenu.css( "top", pos.top + 40 );
		thisSubmenu.css( "visibility", "visible" );
		thisSubmenu.fadeIn("fast");
	});
	
	$("div.menu-text").hover( 
		function() {},
		function () {
			$(this).fadeOut("slow");
    }
  );   
}

function mapShow() {  
		var icon = $("#map_icon");
  	var map = $("img.modal_map");	
  	var pos = icon.position();
		var left = pos.left - map.attr( "width" ) + 175;
		left = (left<0) ? 0 : left; 
		map.css( "left", left );
		map.css( "top", pos.top - 160 );
		map.css( "visibility", "visible" );
		map.fadeIn("fast");
	}


function mapHide() {
	$("img.modal_map").fadeOut("slow");
}

function initHomeMap() {
	var icon = $("#map_icon");
  var map = $("img.modal_map");
  
  map.hide();
  icon.mouseover( mapShow );
	map.click( mapHide );
	map.hover( 
		function() {},
		mapHide
  );   
}


function missionsShow() {  
		var icon = $("#missions_icon");
  	var missions = $("table.modal_last_missions");	
  	var pos = icon.position();
		var left = pos.left - 100;
		left = (left<0) ? 0 : left; 
		missions.css( "left", left );
		missions.css( "top", pos.top -50  );
		missions.css( "visibility", "visible" );
		missions.fadeIn("fast");
	}


function missionsHide() {
	$("table.modal_last_missions").fadeOut("slow");
}

function initMissions() {
	var icon = $("#missions_icon");
  var missions = $("table.modal_last_missions");
  
  missions.hide();
  icon.mouseover( missionsShow );
	missions.click( missionsHide );
	missions.hover( 
		function() {},
		missionsHide
  );   
}

	    
$(document).ready( initMenu );
$(document).ready( initHomeMap );
$(document).ready( initMissions );