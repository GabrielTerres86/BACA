// JavaScript Document
var ajax = false;

function open_ajax() {
	ajax = false;
	
	if (window.XMLHttpRequest) { // Mozilla, Safari,...
		ajax = new XMLHttpRequest();
		
		if (ajax.overrideMimeType) {
			ajax.overrideMimeType("text/xml");
		}
	} else if (window.ActiveXObject) { // IE
		try {
			ajax = new ActiveXObject("Msxml2.XMLHTTP");
		} catch (e) {
			try {
				ajax = new ActiveXObject("Microsoft.XMLHTTP");
			} catch (e) {}
		}
	}
	
	
	if (!ajax) {
		alert('Giving up :( Cannot create an XMLHTTP instance');
		return false;
	}
}
function retornaObj(obj){
	
		return document.getElementById(""+obj+"") ;
	
}

function centerPosition(obj) {
	// Captura posição esquerda e do topo do documento onde a barra de rolagem está posicionada
	var curX = window.pageXOffset ? window.pageXOffset : document.body.scrollLeft;
	var curY = window.pageYOffset ? window.pageYOffset : document.body.scrollTop;		
		
	// Captura tamanho que deve sobrar ao redor do div
	var offsetX = window.innerWidth ? (window.innerWidth - obj.offsetWidth) / 2 : (document.body.clientWidth - obj.offsetWidth) / 2;
	var offsetY = window.innerHeight ? (window.innerHeight - obj.offsetHeight) / 2 : (document.documentElement.clientHeight  - obj.offsetHeight) / 2;
				
	// Atribui posição ao div
	obj.style.left = curX + offsetX + "px";
	obj.style.top  = curY + offsetY + "px";

}
function ajaxOnResponse () {
    var objLayer = retornaObj("divBloqueio");

    if (ajax.readyState == 1) { // Requisição foi configurada

       // centerPosition(objLayer);

        // Seleciona todos os "selects" do documento
        selects = document.getElementsByTagName("select");

        // Esconde todos os "selects" do documento
        for (var i = 0; i < selects.length; i++) {
            selects[i].style.visibility = "hidden";
        }

        objLayer.style.visibility = "visible";
    } else if (ajax.readyState == 4) { // Requisição completada
        objLayer.style.visibility = "hidden";

        // Seleciona todos os "selects" do documento
        selects = document.getElementsByTagName("select");

        // Mostra todos os "selects" do documento
        for (var i = 0; i < selects.length; i++) {
            selects[i].style.visibility = "visible";
        }

        if (ajax.status == 200) {   // Se requisição retornou uma página válida           
			try {
                eval(ajax.responseText);
            } catch (error) { 
                showError("atencao","ATENÇÃO: Não foi possível concluir a requisição." + error);
            }
        } else {
            showError("atencao","ATENÇÃO: Não foi possível concluir a requisição.");
        }
    }
}
