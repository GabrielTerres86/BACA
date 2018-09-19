/*!
 * FONTE        : consulta_rfb.js
 * CRIAÇÃO      : Gabriel (RKAM)
 * DATA CRIAÇÃO : 04/09/2015 
 * OBJETIVO     : Funcoes da CONSULTA A RECEITA FEDERAL
 *
 * ALTERACOES   :  
 */
 
// Estas variaveis sao alimentadas no consulta_rfb.php com os parametros recebidos
var inpessoa;
var nrcpfcgc;
var dtnasctl;
var dtmvtolt;
 
 
 $(document).ready(function() {
	 		
 });
 
 function estadoInicialRfb () {
	 
	$("#frmRfb").submit(function(){
		return false; 
	});	

	$("#dscaptch","#frmRfb").unbind('keypress').bind('keypress', function(e) { 		
		if (e.keyCode == 13) {
			efetuarConsulta(false);
			return false;
		}			
	});
	 
 }

//  flgDispara -> Flag utilizada para indicar que foi feita consulta automaticamente.
//                Isto e' feito para PJ quando carregada a tela para evitar erros. 
 function carrregarCaptcha (flgDispara) {
	 
	 $("#dscaptch","#divConteudoOpcao").val("").focus();
	 	 
	if (flgDispara == false || inpessoa == 1) {	 
		 //O parâmetro em que são passado os segundos serve apenas para forçar o browser a não utilizar imagem em cache, e sempre fazer uma nova requisição
		 if (inpessoa == 1) {
			carregaImagem("CPF");
		 } else {
			carregaImagem("CNPJ");
		 } 		 
	}
	
	// Disparar automaticamente a primeira vez quando PJ somente para evitar erros
	if (inpessoa == 2 && flgDispara) {
		efetuarConsulta(flgDispara);
		carrregarCaptcha(false);
	}
	 
 }
 
 function carregaImagem (tipoConsulta) {
	 
	 var nomeForm = (inpessoa == 1) ? 'frmFisico' : 'frmJuridico';
	 var data = new Date();
	 var hora = data.getTime();
	 		
	 var url = '';
	 if(tipoConsulta == 'CPF'){
	 	url = "../../includes/consulta_rfb/rfb/cpf/getcaptcha.php";
	 }else{
	 	url = "../../includes/consulta_rfb/rfb/cnpj/getcaptcha.php";
	 }
	 		
	$.ajax({
		type: "GET",
		url:  url,
		timeout: 3000,
		data: {
		  tipoConsulta : tipoConsulta,
		  hora: hora
		},
		error: function(objAjax,responseError,objExcept) {	
			hora = data.getTime();
			document.getElementById("imgCaptcha").src = url+"?tipoConsulta=" + tipoConsulta + "&" + hora;	
			document.getElementById('btConcluir').style.visibility="inherit";
		},
		success: function(response) {		
			if (response != '') {
				hora = data.getTime();
				document.getElementById("imgCaptcha").src = url+"?tipoConsulta=" + tipoConsulta + "&" + hora;	
				document.getElementById('btConcluir').style.visibility="inherit";
			} else {
				// Nao foi possivel carregar as imagens, site RFB fora do ar
				var metodo = ''; 
				//retirado para evitar que a tela fique travada após o tempo de resposta da consulta do captcha
				//metodo = 'blockBackground(parseInt($("#divRotina").css("z-index")));';
				
				metodo += '$("#inconrfb","#" + nomeForm).val(0); ';
				metodo += '$("#dtcnscpf","#" + nomeForm).val("");';
				
				showError("error","Site de consulta da Receita Federal do Brasil indisponível. Efetue a consulta manualmente,","Alerta - Aimaro", metodo);
				
			}
		}				 
	}); 
	
}

 function efetuarConsulta(flgDispara) {
	 
	var url      = (inpessoa == 1) ? 'processaCPF.php' : 'processaCNPJ.php';
	if(inpessoa == 1) {
		var url = 'rfb/cpf/processa.php';
	}else{
		var url = 'rfb/cnpj/processa.php';
	};
	url = '/includes/consulta_rfb/' + url;
	//console.log(url);
	var dscaptch = $("#dscaptch","#divConteudoOpcao").val(); 
	 	 
	if (inpessoa == 2) {
		
		nrcpfcgc = normalizaNumero(nrcpfcgc);
		
		// Adicionar 0 na esquerda senao nao funciona a consulta
		if (nrcpfcgc.length == 12) {
			nrcpfcgc = "00." + nrcpfcgc;
		}
		else
		if (nrcpfcgc.length == 13) {
			nrcpfcgc = "0" + nrcpfcgc;
		}
 				
	}
		 		 
	$.ajax({
		type: "POST",
		url: url,
		dataType: "json",
		data: {
			dtnasctl: dtnasctl,
			nrcpfcgc: nrcpfcgc,
			dscaptch: dscaptch,
			redirect: "html_ajax"
		},
		error: function(objAjax,responseError,objExcept) {
			//console.log('deu ruim - ini');
			//console.log(objAjax)
			//console.log(responseError)
			//console.log(objExcept)
			//console.log('deu ruim - fim');
			hideMsgAguardo();
			showError("error","Não foi possível concluir a requisição.","Alerta - Aimaro","");
		},
		success: function(response) {
			//console.log('deu retorno');
			trata_resposta(response, flgDispara);
		}				 
	}); 	
	
 }
 
 function trata_resposta(response , flgDispara) {
	 
	 ////console.log(response);
	 var nomeForm = (inpessoa == 1) ? 'frmFisico' : 'frmJuridico';

	 if (response == "") {
		$("#nmttlrfb","#" + nomeForm).val("");
		$("#cdsitcpf","#" + nomeForm).val(0);
		$("#dtcnscpf","#" + nomeForm).val("");
		$("#inconrfb","#" + nomeForm).val(0);
		
		if (flgDispara == false) {
			showError("error","Site de consulta da Receita Federal do Brasil indisponível. Efetue a consulta manualmente,","Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index'))); carrregarCaptcha(false);");
		}
		
		return false;	
	 }
	 
	 if (flgDispara) {
		 return false;
	 }
	 //var objeto   = jQuery.parseJSON (response);
	 var objeto   = response;
	 //console.log(objeto);
	 var posdnome = (inpessoa == 1) ? 1 : 2;
	 var possitua = (inpessoa == 1) ? 2 : 17;
	 var inconrfb = (objeto[possitua] == "REGULAR" || objeto[possitua] == "ATIVA" ) ? 1 : -1;
	 var status = objeto["status"];
	 	 	 			 
	if (status != "OK") {
		
		limparDadosRFB();
		
		if (flgDispara == false) { 
			showError("error",status,"Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')));carrregarCaptcha(false);");
		}
		
		return false;
	} 
	
	if (inconrfb != -1) {
		$("#dtcnscpf","#" + nomeForm).val(dtmvtolt);
	}
	
	$("#nmttlrfb","#" + nomeForm).val(objeto[posdnome]);
	$("#cdsitcpf","#" + nomeForm).val(retornaSituacao(objeto[possitua]));
	$("#inconrfb","#" + nomeForm).val(inconrfb);
	
	if (inpessoa == 2) {
		
		if (objeto[4] != null) {
			$("#cdcnae"  ,'#'+nomeForm).val(normalizaNumero(objeto[4])).trigger("change");
		}
		if (objeto[6] != null) {
			$("#natjurid",'#'+nomeForm).val(normalizaNumero(objeto[6].split(" - ")[0])).trigger("change");
		}
		
		$("#dtiniatv",'#'+nomeForm).val(objeto[1]);
		$("#dsendere",'#'+nomeForm).val(objeto[7]);
		$("#nrendere",'#'+nomeForm).val(objeto[8]);
		$("#complend",'#'+nomeForm).val(objeto[9]);
		$("#nrcepend",'#'+nomeForm).val(normalizaNumero(objeto[10]));	
		$("#nmbairro",'#'+nomeForm).val(objeto[11]);
		$("#nmcidade",'#'+nomeForm).val(objeto[12]);
		$("#cdufende",'#'+nomeForm).val(objeto[13]);
		$("#dsdemail",'#'+nomeForm).val(objeto[14]);
		if (objeto[15] != "") {
			$("#nrdddtfc",'#'+nomeForm).val(objeto[15].split(")")[0].substr(1));
			$("#nrtelefo",'#'+nomeForm).val(objeto[15].split(")")[1].substr(1,9));
		}		
	}
	
	if (inconrfb == -1) {
		fechaRotina(divRotina);
		if (inpessoa == 1) {
			showError('error','CPF com situa&ccedil&atilde;o diferente de regular. Cadastro n&atilde;o permitido.','Alerta - Aimaro','$("#nrcpfcgc","#frmFisico").focus();');
		} else {
			showError('error','CNPJ com situa&ccedil&atilde;o diferente de regular. Cadastro n&atilde;o permitido.','Alerta - Aimaro','$("#nrcpfcgc","#frmJuridico").focus();');
		}
	}
	else {
		$("#nmprimtl","#" + nomeForm).focus();
		fechaRotina(divRotina);
	}
			 
 }

function retornaSituacao (situacao) {
	switch(situacao) {
		case "REGULAR"  :
		case "ATIVA"    : return 1;
		case "PENDENTE" : return 2;
		case "CANCELADO":
		case "CANCELADA": return 3;
		case "IRREGULAR": return 4;
		case "SUSPENSO" : 
		case "SUSPENSA" : return 5;
		default         : return 0;
	}
}

function limparDadosRFB() {
	
	var nomeForm = (inpessoa == 1) ? 'frmFisico' : 'frmJuridico';
	
	$("#nmttlrfb","#" + nomeForm).val("");
	$("#cdsitcpf","#" + nomeForm).val(0);
	$("#dtcnscpf","#" + nomeForm).val("");
	$("#inconrfb","#" + nomeForm).val("");
}