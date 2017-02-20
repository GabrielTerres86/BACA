/*
Autor..........: Tiago
Programa.......: formataconta.js
Data de criação: 05/09/2016

Objetivo.......: Rotina para formatar mascara do numero de conta no caixa online

Alteracoes.....: 03/11/2016 - Ajustes para TAB e ESC funcionarem de acrodo com o padrão
                              de navegação (Tiago/Elton SD535217).
*/

$(document).ready(function () {


	//$("#v_conta").unmask();	
	//$("#v_conta").unbind("keydown").bind("keydown",function(){ $("#v_conta").unmask(); $("#v_conta").mask("0000.000.0"); $("#v_conta").attr("maxlength","12"); });	
	$("#v_conta").unbind("keypress");
	$("#v_conta").unbind("keyup");
	$("#v_conta").unbind("keydown");
		
//	$('#v_conta').setMask('INTEGER','zzzz.zzz.z','.','');
	
	// Evento onKeyUp no campo "nrdconta"
	$("#v_conta").bind("keyup",function(e) { 		   
		// Seta máscara ao campo
		if (!$("#v_conta").setMaskOnKeyUp("INTEGER","zzzz.zzz.z",".",e)) {			
			return false;
		}
	}); 
	
	// Evento onKeyDown no campo "nrdconta"
	$("#v_conta").bind("keydown", function (e) {
        //Verificar tecla ENTER para realizar acao
	    var code = (e.keyCode ? e.keyCode : e.which);
	    if (code == 13 || code == 9) {
	        document.forms[0].submit();
	        e.preventDefault();
	    }

		if(e.keyCode == 27){
			top.frames[0].document.forms[0].v_rotina.focus();
			e.preventDefault();
	    }

		// Seta máscara ao campo
		return $("#v_conta").setMaskOnKeyDown("INTEGER","zzzz.zzz.z",".",e);		
	});


});	
