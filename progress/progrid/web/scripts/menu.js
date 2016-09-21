//***************************************************************************//
//*** Fonte: menu.js                                                      ***//
//*** Autor: David                                                        ***//
//*** Data : Julho/2007        Ultima Alteracoes: 05/12/2011              ***//
//***                                                                     ***//
//*** Objetivo  : Funções para controle do menu                           ***//
//***             Necessita a chamada de jquery.js e funcoes.js           ***//
//***                                                                     ***//	 
//*** Alteracoes:   26/11/2010 - Dar foco no campo do nome da tela.       ***//
//**						     Incluida funcao que trata do carrega-    ***//
//***   						 mento da tela. (Gabriel)                 ***//
//***																	  ***//
//*** 				18/07/2011 - Direciona tela para a MUDSEN quando      ***//
//***							 precisar trocar a senha (Gabriel)        ***//
//***																	  ***//
//*** 				05/12/2011 - Direciona para a tela ATENDA ao efetuar  ***//
//***							 o login (David)                          ***//
//***************************************************************************//

$(document).ready(function() {

	// Bloquear Menu de Contexto no Menu para evitar que o operador abra a tela em uma nova guia
	$("#divMenu").bind("contextmenu",function(e) { e.preventDefault(); });
	
	// Troca cor de fundo do item quando mouse estiver sobre o mesmo 
	$("#divMenu > span").hover(function() { 
		$(this).css("background-color","#CED0C3");
		$(this).css("cursor","pointer");
	},function() { 
		$(this).css("background-color","#E3E2DD"); 
	}); 

	// Troca cor de fundo do item quando mouse estiver sobre o mesmo 
	$("#divMenu > div > dl > dt").hover(function() { 
		$(this).css("background-color","#CED0C3");
		$(this).css("cursor","pointer");
	},function() { 
		$(this).css("background","none"); 
	}); 	

	// Mostra/Esconde módulo do menu
	$("#divMenu > span").click(function() { 
		var objDiv = $(this).next("div");
	
		if (objDiv.css("display") == "none") {
			$("#divMenu > span > img").each(function(i) {
				$(this).attr("src",UrlImagens + "geral/open.gif");
			});
			
			$("#divMenu > div").each(function(i) {
				$(this).css("display","none");
			});
			
			$("img",this).attr("src",UrlImagens + "geral/hide.gif");
			objDiv.css("display","block");
		} else {
			$("img",this).attr("src",UrlImagens + "geral/open.gif");
			objDiv.css("display","none");
		}
	}); 	
	
	// Se foi pressionada a tecla "Enter" no link do m&oacute;dulo, aciona evento "Click" ao objeto "span"
	$("#divMenu > span > a").keypress(function(e) {
		var keyValue = getKeyValue(e);
					
		if (keyValue == 13) { 
			$(this).parent().trigger("click");
			return false;
		}	
		
		return true;
	});	

	// Chamada da tela do item selecionado
	$("#divMenu > div > dl > dt").click(function() {
		var tela = $("a",this).html();
	
		direcionaTela(tela,true);
	});	
	
	// Se foi pressionada a tecla "Enter" no link do item, aciona evento "Click" ao objeto "dt"
	$("#divMenu > div > dl > dt > a").keypress(function(e) {
		var keyValue = getKeyValue(e);
		
		if (keyValue == 13) { 
			$(this).parent().trigger("click");
			return false;
		}	
		
		return true;
	}); 
	
	// Se for pressionado ENTER no campo do nome da tela, carrega a tela 
	$('#tela','#frmAcesso').bind('keydown',function(e) {
	
		if  (getKeyValue(e) == 13) {
			carregaTela ();
			return false;
		}
		return true;		
	}) ;
		
	$('#btnAcessoTela','#frmAcesso').prop('disabled',false);
	$('#tela','#frmAcesso').habilitaCampo();
    $('#tela','#frmAcesso').focus();
	
	// Se tem que trocar de senha e acaba de Fazer log-in , chama a MUDSEN
	if (document.referrer == UrlSite + "home.php") {
		if ($('#flgdsenh','#frmAcesso').val() == "yes" && $('#telatual','#frmAcesso').val() == "") {	
			if (existeTela("mudsen")) {
				direcionaTela("mudsen",false);		
			} else if ($('#inproces','#frmAcesso').val() == "1" && existeTela("atenda")) {
				direcionaTela("atenda",false);		
			}
		} else if ($('#inproces','#frmAcesso').val() == "1" && $('#telatual','#frmAcesso').val() == "" && existeTela("atenda")) {
			direcionaTela("atenda",false);
		}
	}
	
});

function carregaTela () {

	var nmdatela = $('#tela','#frmAcesso').val();	
			
	// Tela nao digitada
	if (nmdatela == "") {
	   return;	
	}
						
	if (!existeTela(nmdatela)) {
		showError("error","Tela n&atilde;o dispon&iacute;vel.","Alerta - Ayllos","$('#tela','#frmAcesso').focus()");	
		return;
	}
			
	direcionaTela(nmdatela,true);	
	
 }
 
 
 function existeTela (nmdatela) {
	
	var telas = $('#telas','#frmAcesso').val().toLowerCase().split(",");
	var flgachou = false;	


	// Verifica se tela existe
	for (var i = 0; i < telas.length; i++) {
	
		if (telas[i] == "") {
			continue;
		}
										
		if (telas[i].replace(" ","") == nmdatela.toLowerCase()) {
			flgachou = true;	
			break;
		}
	}
	
	return flgachou;
 
 }
 
 function direcionaTela (nmdatela,flgcriti) {
  
	// Se tem que trocar de senha , nao permitir mudar de tela
	if   (flgcriti) {
		if   ($('#flgdsenh','#frmAcesso').val() == "yes" && $('#telatual','#frmAcesso').val() == "MUDSEN") {
			showError("error","&Eacute; preciso trocar a senha do operador.","Alerta - Ayllos","$('#cdoperad','#frmMudsen').focus()");	
			return;
		}
	}
	
	$("#nmdatela","#frmMenu").val(nmdatela.toUpperCase());	
	$("#frmMenu").attr("action",UrlSite + "telas/" + nmdatela.toLowerCase() + "/" + nmdatela.toLowerCase() + ".php");	
	$("#frmMenu").submit();
 }
 
function carregarTelaPrincipal() {
	$("#nmdatela","#frmMenu").val("PRINCIPAL");	
	$("#frmMenu").attr("action",UrlSite + "/principal.php");	
	$("#frmMenu").submit();
}

function efetuaLogoff() {	
	$("#frmMenu").attr("action",UrlSite + "/includes/logoff.php");	
	$("#frmMenu").submit();
}