//************************************************************************//
//*** Fonte: rating.js                                                 ***//
//*** Autor: David                                                     ***//
//*** Data : Abril/2010                   Última Alteração: 25/06/2012 ***//
//***                                                                  ***//
//*** Objetivo  : Biblioteca de funções para procedimentos referente   ***//
//***             ao RATING do cooperado                               ***//
//***                                                                  ***//	 
//*** Alterações: 10/11/2011 - Feito tratamento para cdcooper = 3 na   ***//
//***                          funcao validaDadosRating(). (Fabricio)  ***//
//***																   ***//
//***			  25/06/2012 - Alterado funcao abreJanelaImpressao()   ***//
//***						   adequacao ao modo de submeter para      ***//
//***						   impressao. (Jorge)              		   ***//
//***                                                                  ***//
//***             16/04/2015 - Consultas automatizadas (Gabriel-RKAM)  ***//
//***                                                                  ***//
//***             16/04/2015 - Liberacao M442          (Heitor-Mouts)  ***//
//************************************************************************//

var fncRatingContinue = "";  // Variável para armazenar função que será acionada quando os dados do RATING já foram validados
var fncRatingSuccess  = "";  // Variável para armazenar função que será acionada quando a operação do RATING foi finalizada com sucesso
var contWinRating     = 0;   // Variável para contagem do número de janelas abertas para impressão do RATING

// Variáveis para armazenar dados do RATING do cooperado
var nrgarope = 0;
var nrinfcad = 0;
var nrliquid = 0;
var nrpatlvr = 0;
var vltotsfn = 0;
var perfatcl = 0;	
var nrperger = 0;
var tpctrrat = 0;
var nrctrrat = 0;
var dtconbir;

// Função para mostrar div para atualização do RATING
function informarRating(divHide,fncContinue,fncCancel,fncSuccess) {
	showMsgAguardo("Aguarde, carregando dados do rating ...");	
	
	fncRatingContinue = fncContinue;
	fncRatingSuccess  = fncSuccess;
	
	$("#btnCancelaRating").unbind("click");
	$("#btnCancelaRating").bind("click",function() {
		eval(fncCancel);
		return false;
	});
	
	$("#btnCriticaRating").unbind("click");
	$("#btnCriticaRating").bind("click",function() {
		eval(fncSuccess);
		return false;
	});
	
	$("#" + divHide).css("display","none");		
	$("#divDadosRating").css("display","block");	
	
	// Encerra mensagem de aguardo e bloqueia fundo da tela
	hideMsgAguardo();
	blockBackground(parseInt($("#divRotina").css("z-index")));	
}

// Função para validar dados informados referente ao RATING do cooperado
function validaDadosRating(cdcooper , operacao , inprodut) { 

	var vlprodut;

	showMsgAguardo("Aguarde, validando dados do rating ...");

	if (inprodut == 3 && operacao == 'I_PROT_CRED') { // Limite de credito
		vlprodut = $("#vllimite","#frmNovoLimite").val().replace(".","").replace(",",".");
	}
		
	nrgarope = $("#nrgarope","#frmDadosRating").val();
	nrliquid = $("#nrliquid","#frmDadosRating").val();
	nrpatlvr = $("#nrpatlvr","#frmDadosRating").val();	
		
		
	if (inprodut == 3) { // Limite de credito
		if (operacao != 'A_PROT_CRED' && operacao != 'I_PROT_CRED') {			
			nrinfcad = $("#nrinfcad","#frmOrgaos").val();
			dtconbir = $("#dtcnsspc","#frmOrgaos").val();
		} else {
			nrinfcad = (nrinfcad == 0 || operacao == 'I_PROT_CRED' ) ? undefined : nrinfcad;
		}
	} else {
		nrinfcad = $("#nrinfcad","#frmDadosRating").val();
		vltotsfn = $("#vltotsfn","#frmDadosRating").val().replace(/\./g,"");
	}
								
    perfatcl = (inpessoa == 1) ? "0,00" : $("#perfatcl","#frmDadosRating").val().replace(/\./g,"");
	nrperger = (inpessoa == 1) ? "0" : $("#nrperger","#frmDadosRating").val();
			
	if (cdcooper == 3) {
	
		if (nrgarope != "" && validaNumero(nrgarope,true,0,0)) {
			hideMsgAguardo();
			showError("error","N&atilde;o pode ser informado nenhuma garantia.","Alerta - Ayllos","$('#nrgarope','#frmDadosRating').focus();blockBackground(parseInt($('#divRotina').css('z-index')))");
			return false;
		}
		
		if (nrpatlvr != "" && validaNumero(nrpatlvr,true,0,0)) {
			hideMsgAguardo();
			showError("error","N&atilde;o pode ser informado nenhum Patrim&ocirc;nio Pessoal Livre.","Alerta - Ayllos","$('#nrpatlvr','#frmDadosRating').focus();blockBackground(parseInt($('#divRotina').css('z-index')))");
			return false;
		}	
		
		if (inpessoa != 1 && (nrperger != "" && validaNumero(nrperger,true,0,0))) {
			hideMsgAguardo();
			showError("error","N&atilde;o pode ser informado nenhuma Percep&ccedil;&atilde;o Geral.","Alerta - Ayllos","$('#nrperger','#frmDadosRating').focus();blockBackground(parseInt($('#divRotina').css('z-index')))");
			return false;
		}
	
	}

	// Executa o script de validação dos dados do rating através de ajax
	$.ajax({		
		type: "POST", 
		url: UrlSite + "includes/rating/rating_valida_dados.php",
		data: {
			nrdconta: nrdconta,			
			nrgarope: nrgarope,
			nrinfcad: nrinfcad,
			nrliquid: nrliquid,
			nrpatlvr: nrpatlvr,			
			nrperger: nrperger,
			operacao: operacao,
			inprodut: inprodut,
			inpessoa: inpessoa,
			vlprodut: vlprodut,
			redirect: "script_ajax"
		},		
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
		success: function(response) {
			try {
				eval(response);
			} catch(error) {
				hideMsgAguardo();
				showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message,"Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
			}
		}				
	}); 
}

// Função para atualizar dados do RATING do cooperado
function atualizaDadosRating(iddivcri) {
	showMsgAguardo("Aguarde, atualizando dados do rating ...");
	
	// Executa o script para gravar dados do rating através de ajax
	$.ajax({		
		type: "POST", 
		url: UrlSite + "includes/rating/rating_atualiza_dados.php",
		data: {
			nrdconta: nrdconta,									
			nrgarope: nrgarope,
			nrinfcad: nrinfcad,
			nrliquid: nrliquid,
			nrpatlvr: nrpatlvr,
			nrperger: nrperger,
			tpctrrat: tpctrrat,
			nrctrrat: nrctrrat,	
			iddivcri: iddivcri,
			redirect: "script_ajax"
		},		
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
		success: function(response) {
			try {
				eval(response);
			} catch(error) {
				hideMsgAguardo();
				showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message,"Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
			}
		}				
	});	
}



// Função para imprimir rating do cooperado
function imprimirRating(flgefeti,tpctrato,nrctrato,iddivcri,fnfinish) {
	if (flgefeti) {
		abreJanelaImpressao();
	} else {
		showMsgAguardo("Aguarde, carregando par&acirc;metros para impress&atilde;o do rating ...");	
		
		fncRatingSuccess = fnfinish;		
		
		// Executa o script de validação dos dados do rating através de ajax
		$.ajax({		
			type: "POST", 
			url: UrlSite + "includes/rating/rating_dados_impressao.php",
			data: {
				nrdconta: nrdconta,			
				tpctrato: tpctrato,
				nrctrato: nrctrato,
				iddivcri: iddivcri,
				redirect: "script_ajax"
			},		
			error: function(objAjax,responseError,objExcept) {
				hideMsgAguardo();
				showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
			},
			success: function(response) {
				try {
					eval(response);
				} catch(error) {
					hideMsgAguardo();
					showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message,"Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
				}
			}				
		}); 	
	}
}

function imprimirRatingProposta(flgefeti,tpctrato,nrctrato,iddivcri,fnfinish) {
	if (flgefeti) {
		abreJanelaImpressao();
	} else {
		showMsgAguardo("Aguarde, carregando par&acirc;metros para impress&atilde;o do rating proposta ...");	

		fncRatingSuccess = fnfinish;

		// Executa o script de validação dos dados do rating através de ajax
		$.ajax({
			type: "POST",
			url: UrlSite + "includes/rating/rating_dados_impressao_proposta.php",
			data: {
				nrdconta: nrdconta,
				tpctrato: tpctrato,
				nrctrato: nrctrato,
				iddivcri: iddivcri,
				redirect: "script_ajax"
			},
			error: function(objAjax,responseError,objExcept) {
				hideMsgAguardo();
				showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
			},
			success: function(response) {
				try {
					eval(response);
				} catch(error) {
					hideMsgAguardo();
					showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message,"Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
				}
			}				
		}); 	
	}
}

// Função para abrir janela de impressão
function abreJanelaImpressao() {
	
	var action = $("#frmImprimirRating").attr("action");
	var callafter = "blockBackground(parseInt($('#divRotina').css('z-index')));";
	
	carregaImpressaoAyllos("frmImprimirRating",action,callafter);
}

// Função para envio de formulário de impressao
function Gera_Impressao_Proposta(nmarqpdf, callback) {

    hideMsgAguardo();

    var action = UrlSite + 'includes/rating/imprimir_pdf.php';

    $('#nmarqpdf', '#frmImprimirRating').remove();
	$('#sidlogin', '#frmImprimirRating').remove();

	$('#frmImprimirRating').append('<input type="hidden" id="nmarqpdf" name="nmarqpdf" value="' + nmarqpdf + '" />');
	$('#frmImprimirRating').append('<input type="hidden" id="sidlogin" name="sidlogin" value="' + $('#sidlogin', '#frmMenu').val() + '" />');

	carregaImpressaoAyllos("frmImprimirRating", action, callback);

}