/*!
 * FONTE        : alttar.js
 * CRIAÇÃO      : Jaison        
 * DATA CRIAÇÃO : 25/08/2015
 * OBJETIVO     : Biblioteca de funções da tela ALTTAR
 * --------------
 * ALTERAÇÕES   : 26/11/2015 - Ajustado para buscar os convenios de folha
 *                             de pagamento. (Andre Santos - SUPERO)
 *
 *				  30/10/2017 - Adicionado os campos vlpertar, vlmaxtar, vlmintar 
 *							   e tpcobtar na tela. PRJ M150 (Mateus Z - Mouts)
 *
 *                28/06/2017 - Correcao na validacao de Valor Min. > Valor Max., estava utilizando as variaveis erradas
 *                             INC0017641 - Heitor (Mouts)
 * -------------- 
 */

// Definição de algumas variáveis globais 
var cddopcao		= 'A';
var cddopdet		= 'I';
var cdatrdet		= 'I';	
var cddoppar        = 'V';

//Formulários
var frmCab   		 = 'frmCab';
var frmDetalhaTarifa = 'frmDetalhaTarifa';
var frmVinculacaoParametro = 'frmVinculacaoParametro';

//Labels/Campos do cabeçalho
var rCddopcao, rcdsubgru, rCdsubgru, cCddopcao, cDssubgru, cCdsubgru, cTodosCabecalho, cCdfaixav, cCdpartar, glbTabCdpartar,
glbTabCdfaixav, glbTabVlinifvl, glbTabVlfinfvl, glbTabCdhistor, glbTabCdhisest, glbTabDshistor, glbTabDshisest,
glbFcoCdcooper, glbFcoDtdivulg,	glbFcoDtvigenc,	glbFcoVltarifa,	glbFcoVlrepass, glbFcoCdfaixav, glbFcoNmrescop, glbFcoCdfvlcop,
glbFcoNrconven, glbFcoDsconven, glbFcoCdlcremp, glbFcoDslcremp;

var lstconve;
var lstcdfvl;
var lstdtdiv;
var lstdtvig;
var lstvltar;
var lstvlrep;
var lstcdcop;
var lstlcrem;	

$(document).ready(function() {
	
	estadoInicial();
	
	highlightObjFocus( $('#'+frmCab) );
	
	$('fieldset > legend').css({'font-size':'11px','color':'#777','margin-left':'5px','padding':'0px 2px'});
	$('fieldset').css({'clear':'both','border':'1px solid #777','margin':'3px 0px','padding':'10px 3px 5px 3px'});
	
	return false;
	
});

// seletores
function estadoInicial() {

	$('#divTela').fadeTo(0,0.1);
	$('#frmCab').css({'display':'block'});
	$('#divDetalhamento').css({'display':'none'});
	$('#divParametro').css({'display':'none'});
	
	$('#divOcorrenciaMotivo').css({'display':'none'});
    $('#linCobranca','#frmCab').hide();
    $('#linEmprestimo','#frmCab').hide();
	
	formataCabecalho();
	
	cTodosCabecalho.limpaFormulario();
	cCddopcao.val( cddopcao );
	
	removeOpacidade('divTela');	
	unblockBackground();
	hideMsgAguardo();
	
	cTodosCabecalho.desabilitaCampo();
	
	$('#cddopcao','#frmCab').habilitaCampo();
	$('#cddopcao','#'+frmCab).focus();
	
	trocaBotao('');
	$("#btVoltar","#divBotoes").hide();
	
	$('input,select', '#frmCab').removeClass('campoErro');
	controlaFoco();

}

function controlaFoco() {

	$('#cddopcao','#frmCab').unbind('keypress').bind('keypress', function(e) {
			if ( e.keyCode == 9 || e.keyCode == 13 ) {	
				LiberaCampos();
                $('#cdtarifa','#frmCab').focus();
				return false;
			}	
	});
	
	$('#btnOK','#frmCab').unbind('keypress').bind('keypress', function(e) {
			if ( e.keyCode == 9 || e.keyCode == 13 ) {				
                LiberaCampos();
                $('#cdtarifa','#frmCab').focus();
                return false;
			}	
	});
	
	$('#cdtarifa','#frmCab').unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {	
            if ($('#cdtarifa','#frmCab').val() == ''){		
				$('#cddgrupo','#frmCab').focus();
			} else {
				buscaDadosTarifa();
				return false;
			}
		}			
	});
	
	$('#cddgrupo','#frmCab').unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {
			if ( $('#cddgrupo','#frmCab').val() == '') {
				$('#cdsubgru','#frmCab').focus();
			} else {
				if ($('#cdtarifa','#frmCab').val() != ''){		
					buscaDadosTarifa();
				}
				btnContinuar();
				return false;
			}
		}			
	});
	
	$('#cdsubgru','#frmCab').unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13) {	
			if ( $('#cdsubgru','#frmCab').val() == '') {
				$('#cdcatego','#frmCab').focus();
			} else {
				if ($('#cdtarifa','#frmCab').val() != ''){		
					buscaDadosTarifa();
				}
				btnContinuar();
				return false;
			}
		}
	});
	
	$('#cdsubgru','#frmCab').unbind('blur').bind('blur', function(e) {		
		if ( $('#cdsubgru','#frmCab').val() != '') {
			if ($('#cdtarifa','#frmCab').val() != ''){		
				buscaDadosTarifa();
			}
			btnContinuar();
			return false;
		}		
	});
	
	$('#cdcatego','#frmCab').unbind('keypress').bind('keypress', function(e) {
        if ( e.keyCode == 9 || e.keyCode == 13 ) {	
            if ( $('#cdcatego','#frmCab').val() != '') {
				if ($('#cdtarifa','#frmCab').val() != ''){		
					buscaDadosTarifa();
				}
                btnContinuar();
                return false;
            }
        }
	});
	
	$('#cdcatego','#frmCab').unbind('blur').bind('blur', function(e) {
			
		if ( $('#cdcatego','#frmCab').val() != '') {
			if ($('#cdtarifa','#frmCab').val() != ''){		
				buscaDadosTarifa();
			}
			btnContinuar();
			return false;
		}
			
	});
	
	$('#nrconven','#frmCab').unbind('keypress').bind('keypress', function(e) {
        if ( e.keyCode == 9 || e.keyCode == 13 ) {	
            if ( $('#nrconven','#frmCab').val() != '') {
                btnContinuar();
                $('#dtdivulg','#frmCab').focus();
                return false;
            }
        }
	});
	
	$('#nrconven','#frmCab').unbind('blur').bind('blur', function(e) {
			
		if ( $('#nrconven','#frmCab').val() != '') {
			btnContinuar();
            $('#dtdivulg','#frmCab').focus();
			return false;
		}
			
	});
	
	$('#cdlcremp','#frmCab').unbind('keypress').bind('keypress', function(e) {
        if ( e.keyCode == 9 || e.keyCode == 13 ) {	
            if ( $('#cdlcremp','#frmCab').val() != '') {
                btnContinuar();
                $('#dtdivulg','#frmCab').focus();
                return false;
            }
        }
	});
	
	$('#cdlcremp','#frmCab').unbind('blur').bind('blur', function(e) {
			
		if ( $('#cdlcremp','#frmCab').val() != '') {
			btnContinuar();
            $('#dtdivulg','#frmCab').focus();
			return false;
		}
			
	});

	$('#dtdivulg','#frmCab').unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {	
			if ($('#dtdivulg','#frmCab').val() != ''){
				$('#dtvigenc','#frmCab').focus();
			}
		}
	});

	$('#dtvigenc','#frmCab').unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {	
			if ($('#dtvigenc','#frmCab').val() != ''){
				btnConcluir();
			}
		}
	});

}

function formataCabecalho() {

	// cabecalho
	rCddopcao			= $('label[for="cddopcao"]','#'+frmCab); 
	rCdtarifa			= $('label[for="cdtarifa"]','#'+frmCab);
	rCddgrupo			= $('label[for="cddgrupo"]','#'+frmCab); 	
	rCdsubgru			= $('label[for="cdsubgru"]','#'+frmCab);
	rCdcatego			= $('label[for="cdcatego"]','#'+frmCab);
	rCdlcremp			= $('label[for="cdlcremp"]','#'+frmCab);
	rNrconven			= $('label[for="nrconven"]','#'+frmCab);
	rDtdivulg			= $('label[for="dtdivulg"]','#'+frmCab);
	rDtvigenc			= $('label[for="dtvigenc"]','#'+frmCab);
	
	cCddopcao			= $('#cddopcao','#'+frmCab); 
	cCdtarifa			= $('#cdtarifa','#'+frmCab);
	cCddgrupo           = $('#cddgrupo','#'+frmCab); 
	cCdsubgru			= $('#cdsubgru','#'+frmCab); 
	cCdcatego			= $('#cdcatego','#'+frmCab); 
	cCdlcremp			= $('#cdlcremp','#'+frmCab);
    cNrconven			= $('#nrconven','#'+frmCab);
    cDtdivulg			= $('#dtdivulg','#'+frmCab);
	cDtvigenc			= $('#dtvigenc','#'+frmCab);
    cDstarifa			= $('#dstarifa','#'+frmCab);
	cDsdgrupo			= $('#dsdgrupo','#'+frmCab); 
	cDssubgru			= $('#dssubgru','#'+frmCab);
	cDscatego			= $('#dscatego','#'+frmCab); 
	cDslcremp			= $('#dslcremp','#'+frmCab);
	cDsconven			= $('#dsconven','#'+frmCab);
	
	cTodosCabecalho		= $('input[type="text"],input[type="checkbox"],select','#'+frmCab);
	
	rCddopcao.css('width','115px');
	rCdtarifa.css('width','115px');
	rCddgrupo.css('width','115px');
	rCdsubgru.css('width','115px');
	rCdcatego.css('width','115px');
	rCdlcremp.css('width','115px');
	rNrconven.css('width','115px');
	rDtdivulg.css('width','115px');
	rDtvigenc.css('width','140px');
	
	cCddopcao.css('width','530px');	
	cCdtarifa.css('width','90px').attr('maxlength','9').setMask('INTEGER','zzzzzzzzz','','');
	cCddgrupo.css('width','90px').attr('maxlength','9').setMask('INTEGER','zzzzzzzzz','','');
	cCdsubgru.css('width','90px').attr('maxlength','9').setMask('INTEGER','zzzzzzzzz','','');
	cCdcatego.css('width','90px').attr('maxlength','9').setMask('INTEGER','zzzzzzzzz','','');
	cCdlcremp.css('width','90px').attr('maxlength','9').setMask('INTEGER','zzzzzzzzz','','');
	cNrconven.css('width','90px').attr('maxlength','9').setMask('INTEGER','zzzzzzzzz','','');
	cDtdivulg.addClass('data').css('width','90px');
	cDtvigenc.addClass('data').css('width','90px');
	
	cDstarifa.css('width','450px')
    cDsdgrupo.css('width','450px');
	cDssubgru.css('width','450px');
	cDscatego.css('width','450px');
    cDslcremp.css('width','450px');
	cDsconven.css('width','450px');
	
	cTodosCabecalho.habilitaCampo().removeClass('campoErro');
	
	layoutPadrao();
	return false;	
}

// Botao Voltar
function btnVoltar() {
	estadoInicial();
	return false;
}

function LiberaCampos() {

	if ( $('#cddopcao','#frmCab').hasClass('campoTelaSemBorda')  ) { return false; }	

	//Desabilita campo opção
	cTodosCabecalho		= $('input[type="text"],select','#frmCab'); 
	cTodosCabecalho.desabilitaCampo();
	
	$('#cdtarifa','#frmCab').habilitaCampo();
	$('#cddgrupo','#frmCab').habilitaCampo();
	$('#cdsubgru','#frmCab').habilitaCampo();
	$('#cdcatego','#frmCab').habilitaCampo();
    $('#dtdivulg','#frmCab').habilitaCampo();
    $('#dtvigenc','#frmCab').habilitaCampo();
	
	$('#divBotoes', '#divTela').css({'display':'block'});
	
	trocaBotao( 'btnConcluir' );
	
	$("#btSalvar","#divBotoes").show();
	$("#btVoltar","#divBotoes").show();
	
	$('#cdtarifa','#frmCab').focus();

	return false;

}

function btnContinuar() {

    cddopcao = cCddopcao.val();
    cddgrupo = normalizaNumero( cCddgrupo.val() );
    cdsubgru = normalizaNumero( cCdsubgru.val() );
    cdcatego = normalizaNumero( cCdcatego.val() );
    cdlcremp = normalizaNumero( cCdlcremp.val() );
    nrconven = normalizaNumero( cNrconven.val() );

    if (( nrconven != '' ) && ( ! $('#nrconven','#frmCab').hasClass('campoTelaSemBorda') )) {
        buscaDados(5);
    } else {
        if (( cdlcremp != '' ) && ( ! $('#cdlcremp','#frmCab').hasClass('campoTelaSemBorda') )) {
            buscaDados(4);
        } else {
            if (( cdcatego != '' ) && ( ! $('#cdcatego','#frmCab').hasClass('campoTelaSemBorda') )) {
                buscaDados(3);
            } else {
                if (( cdsubgru != '' ) && ( ! $('#cdsubgru','#frmCab').hasClass('campoTelaSemBorda') )) {
                    buscaDados(2);
                } else {
                    if (( cddgrupo != '' ) && ( ! $('#cddgrupo','#frmCab').hasClass('campoTelaSemBorda') )) {
                        buscaDados(1);
                    } else {
                        if (cdlcremp == 0) {
                            cDslcremp.val('LINHA PADRAO');
                        }
                    }
                }
            }
        }
    }
}

function buscaDados( valor ) {

	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, consultando...");
	
	switch( valor )
	{
		case 1:
		  buscaDadosGrupo();		  		  
		  break;
		case 2:
		  buscaDadosSubGrupo();
		  break;
		case 3:
		  buscaDadosCategoria();
		  break;
		case 4:
		  buscaDadosLinhaCredito();
		  break;
		case 5:
		  buscaDadosConvenio();
		  break;
	}
}

function buscaDadosGrupo(){

	var cddgrupo = $('#cddgrupo','#frmCab').val();
	cddgrupo = normalizaNumero(cddgrupo);

	// Executa script através de ajax
	$.ajax({		
		type: "POST",
		url: UrlSite + "telas/alttar/busca_dados_grupo.php", 
		data: {
			cddgrupo: cddgrupo,
			cddopcao: cddopcao,
			redirect: "script_ajax"
		}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
		success: function(response) {
			try {
				hideMsgAguardo();
				eval(response);
			} catch(error) {
				hideMsgAguardo();
				showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message,"Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
			}
		}				
	});					
	
}

function buscaDadosSubGrupo(){

	var cdsubgru = $('#cdsubgru','#frmCab').val();		
	cdsubgru = normalizaNumero(cdsubgru);		
	
	// Executa script através de ajax
	$.ajax({		
		type: "POST",
		url: UrlSite + "telas/alttar/busca_dados_subgrupo.php", 
		data: {
			cdsubgru: cdsubgru,
			cddopcao: cddopcao,
			redirect: "script_ajax"
		}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
		success: function(response) {
			try {
				hideMsgAguardo();
				eval(response);
			} catch(error) {
				hideMsgAguardo();
				showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message,"Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
			}
		}				
	});					


}

function buscaDadosCategoria(){

	var cdcatego = $('#cdcatego','#frmCab').val();		
	cdcatego = normalizaNumero(cdcatego);		
	
	// Executa script através de ajax
	$.ajax({		
		type: "POST",
		url: UrlSite + "telas/alttar/busca_dados_categoria.php", 
		data: {
			cdcatego: cdcatego,
			cddopcao: cddopcao,
			redirect: "script_ajax"
		}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
		success: function(response) {
			try {
				hideMsgAguardo();
				eval(response);
			} catch(error) {
				hideMsgAguardo();
				showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message,"Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
			}
		}				
	});					


}

function buscaDadosLinhaCredito(){

	var cdlcremp = $('#cdlcremp','#frmCab').val(); 
	var cdcopatu = $('#glbcdcooper','#frmCab').val();    

	// Executa script através de ajax
	$.ajax({		
		type: "POST",
		url: UrlSite + "telas/alttar/busca_dados_linha_credito.php", 
		data: {
            cddopcao: cddopcao,
			cdlcremp: cdlcremp,
			cdcopatu: cdcopatu,
			redirect: "script_ajax"
		}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
		success: function(response) {
			try {
				hideMsgAguardo();
				eval(response);
			} catch(error) {
				hideMsgAguardo();
				showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message,"Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
			}
		}				
	});


}

function buscaDadosConvenio(){

	var nrconven = $('#nrconven','#frmCab').val(); 
    nrconven  = normalizaNumero(nrconven);
	var cdcopatu = $('#glbcdcooper','#frmCab').val();
    var cdsubgru = $('#cdsubgru','#frmCab').val();
    var cdocorre = cdsubgru == 15 ? 1 : 0; // cdsubgru = 15 = Com Registro
	var cdinctar = $('#cdinctar','#frmCab').val();

	// Executa script através de ajax
	$.ajax({		
		type: "POST",
		url: UrlSite + "telas/alttar/busca_dados_convenio.php", 
		data: {
            cddopcao: cddopcao,
			nrconven: nrconven,
			cdcopatu: cdcopatu,
            cdocorre: cdocorre,
            cdinctar: cdinctar,
			redirect: "script_ajax"
		}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
		success: function(response) {
			try {
				hideMsgAguardo();
				eval(response);
			} catch(error) {
				hideMsgAguardo();
				showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message,"Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
			}
		}				
	});	


}

function buscaDadosTarifa(){

	// Nome do Formulário que estamos trabalhando
	var nomeFormulario = 'frmCab';
	
	//Remove a classe de Erro do form
	$('input,select', '#'+nomeFormulario).removeClass('campoErro');

	var cdtarifa = $('#cdtarifa','#frmCab').val();
	cdtarifa = normalizaNumero(cdtarifa);
	
	var cddopcao = $('#cddopcao','#frmCab').val();

	// Executa script através de ajax
	$.ajax({		
		type: "POST",
		url: UrlSite + "telas/alttar/busca_dados_tarifa.php", 
		data: {
			cddopcao: cddopcao,
			cdtarifa: cdtarifa,
			redirect: "script_ajax"
		}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
		success: function(response) {
			try {
                eval(response);
                hideMsgAguardo();
            } catch(error) {
                hideMsgAguardo();
                showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message,"Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
            }
		}
	});	
	
}

function controlaPesquisa( valor ) {

	$("#divCabecalhoPesquisa").css("width","100%");
	$("#divResultadoPesquisa").css("width","100%");

	switch( valor )
	{
		case 1:
			controlaPesquisaTarifa();
			break;
	    case 2:
			controlaPesquisaGrupo();
			break;
		case 3:
			controlaPesquisaSubGrupo();
			break;
		case 4:
			controlaPesquisaCategoria();
			break;		
		case 5:
			controlaPesquisaConvenio();
			break;
		case 6:
			controlaPesquisaLinhaCredito();
			break;
			
	}
}

function controlaPesquisaTarifa() {

	// Se esta desabilitado o campo 
	if ($("#cdtarifa","#frmCab").prop("disabled") == true)  {
		return;
	}
	
	// Variável local para guardar o elemento anterior
	var campoAnterior = '';
	var bo, procedure, titulo, qtReg, filtros, colunas, cdtarifa, titulo_coluna, cdtarifas, dstarifa, cddgrupo;
    var dsdgrupo, cdsubgru, dssubgru, cdcatego, dscatego, cdinctar, inpessoa, flglaman;	
	
	// Nome do Formulário que estamos trabalhando
	var nomeFormulario = 'frmCab';
	
	var divRotina = 'divTela';
	
	//Remove a classe de Erro do form
	$('input,select', '#'+nomeFormulario).removeClass('campoErro');
	
	var cdtarifa = $('#cdtarifa','#'+nomeFormulario).val();
	cdtarifas = cdtarifa;	
	dstarifa = '';
	cddgrupo = $("#cddgrupo","#frmCab").val();
	dsdgrupo = '';
	dssubgru = '';
	dscatego = '';
	cdsubgru = $("#cdsubgru","#frmCab").val();
	cdcatego = $("#cdcatego","#frmCab").val();
	
	titulo_coluna = "Tarifas";
	
	bo			= 'b1wgen0153.p'; 
	procedure	= 'lista-tarifas';
	titulo      = 'Tarifas';
	qtReg		= '20';	
	filtros 	=           'Grupo;cddgrupo;100px;N;'    + cddgrupo + ';N|Desc;dsdgrupo;150px;N;'      + dsdgrupo + ';N|'; //GRUPO
	filtros     = filtros + 'Subgrupo;cdsubgru;100px;N;' + cdsubgru + ';N|Desc;dssubgru;150px;N;'      + dssubgru + ';N|'; //SUBGRUPO
	filtros     = filtros + 'Categoria;cdcatego;100px;N;' + cdcatego + ';N|Desc;dscatego;150px;N;'     + dssubgru + ';N|'; //CATEGORIA
	filtros     = filtros + 'Codigo;cdtarifa;100px;S;'   + cdtarifa + ';S|Descricao;dstarifa;300px;S;' + dstarifa + ';S';  //TARIFA
	colunas 	=           'Cod;cddgrupo;4%;right|Grupo;dsdgrupo;21%;left|'                  //GRUPO
	colunas     = colunas + 'Cod;cdsubgru;4%;right|SubGrupo;dssubgru;21%;left|'               //SUBGRUPO
	colunas     = colunas + 'Cod;cdcatego;4%;right|Categoria;dscatego;21%;left|'              //CATEGORIA
	colunas     = colunas + 'Cod;cdtarifa;4%;right|' + titulo_coluna + ';dstarifa;21%;left';  //TARIFA
	mostraPesquisa(bo,procedure,titulo,qtReg,filtros,colunas,'','$(\'#cdtarifa\',\'#frmCab\').val()');	
	$("#divPesquisa").css("left","258px");
	$("#divPesquisa").css("top","91px");
	$("#divCabecalhoPesquisa > table").css("width","875px");
	$("#divCabecalhoPesquisa > table").css("float","left");
	$("#divResultadoPesquisa > table").css("width","890px");
	$("#divCabecalhoPesquisa").css("width","890px");
	$("#divResultadoPesquisa").css("width","890px");
	
	return false;

}

function controlaPesquisaGrupo() {

	// Se esta desabilitado o campo 
	if ($("#cddgrupo","#frmCab").prop("disabled") == true)  {
		return;
	}
	
	// Variável local para guardar o elemento anterior
	var campoAnterior = '';
	var bo, procedure, titulo, qtReg, filtros, colunas, cddgrupo, titulo_coluna, cdgrupos, dsdgrupo;	
	
	// Nome do Formulário que estamos trabalhando
	var nomeFormulario = 'frmCab';
	
	var divRotina = 'divTela';
	
	//Remove a classe de Erro do form
	$('input,select', '#'+nomeFormulario).removeClass('campoErro');
	
	var cddgrupo = $('#cddgrupo','#'+nomeFormulario).val();
	cdgrupos = cddgrupo;	
	dsdgrupo = '';
	
	titulo_coluna = "Grupos de produto";
	
	bo			= 'b1wgen0153.p'; 
	procedure	= 'lista-grupos';
	titulo      = 'Grupos';
	qtReg		= '20';
	filtros 	= 'Codigo;cddgrupo;100px;S;' + cddgrupo + ';S|Descricao;dsdgrupo;300px;S;' + dsdgrupo + ';S';
	colunas 	= 'Codigo;cddgrupo;20%;right|' + titulo_coluna + ';dsdgrupo;50%;left';
	mostraPesquisa(bo,procedure,titulo,qtReg,filtros,colunas,'','$(\'#cddgrupo\',\'#frmCab\').val()');
	
	return false;
}

function controlaPesquisaSubGrupo(){

	// Se esta desabilitado o campo 
	if ($("#cdsubgru","#frmCab").prop("disabled") == true)  {
		return;
	}	
	
	// Variável local para guardar o elemento anterior
	var campoAnterior = '';
	var bo, procedure, titulo, qtReg, filtros, colunas, cdsubgru, titulo_coluna;	
	
	// Nome do Formulário que estamos trabalhando
	var nomeFormulario = 'frmCab';
	
	var divRotina = 'divTela';
	
	//Remove a classe de Erro do form
	$('input,select', '#'+nomeFormulario).removeClass('campoErro');
	
	var cdsubgru = $('#cdsubgru','#'+nomeFormulario).val();
	var cddgrupo  = $('#cddgrupo','#'+nomeFormulario).val();
	dssubgru = '';
	
	titulo_coluna = "Sub-grupos de produto";
	
	bo			= 'b1wgen0153.p'; 
	procedure	= 'lista-subgrupos';
	titulo      = 'Sub-grupos';
	qtReg		= '20';
	filtros 	= 'Grupo;cddgrupo;100px;N;' + cddgrupo + ';S|Codigo;cdsubgru;100px;S;' + cdsubgru + ';S|Descricao;dssubgru;300px;S;' + dssubgru + ';S';
	colunas 	= 'Grupo;cddgrupo;15%;right|Codigo;cdsubgru;15%;right|' + titulo_coluna + ';dssubgru;65%;left';
	
	mostraPesquisa(bo,procedure,titulo,qtReg,filtros,colunas,'','$(\'#cdsubgru\',\'#frmCab\').focus()');

	$("#divCabecalhoPesquisa > table").css("width","560px");
	$("#divResultadoPesquisa > table").css("width","100%");
	$("#divCabecalhoPesquisa > table").css("float","left");
	$("#divCabecalhoPesquisa").css("width","580px");
	$("#divResultadoPesquisa").css("width","100%");	

	
	return false;
}

function controlaPesquisaCategoria() {

	// Se esta desabilitado o campo contrato
	if ($("#cdcatego","#frmCab").prop("disabled") == true)  {
		return;
	}	

	// Variável local para guardar o elemento anterior
	var campoAnterior = '';
	var bo, procedure, titulo, qtReg, filtros, colunas, titulo_coluna, cdgrupos, dscatego;	
	var aux_cddgrupo, aux_dsdgrupo, aux_cdsubgru, aux_dssubgru;
	
	// Nome do Formulário que estamos trabalhando
	var nomeFormulario = 'frmCab';
	
	var divRotina = 'divTela';
	
	//Remove a classe de Erro do form
	$('input,select', '#'+nomeFormulario).removeClass('campoErro');
	
	var cdtipcat = $('#cdtipcat','#'+nomeFormulario).val();
	var cddgrupo = $('#cddgrupo','#'+nomeFormulario).val();
	var cdsubgru = $('#cdsubgru','#'+nomeFormulario).val();
	var cdcatego = $('#cdcatego','#'+nomeFormulario).val();
	var dsdgrupo = $('#dsdgrupo','#'+nomeFormulario).val();
	var dssubgru = $('#dssubgru','#'+nomeFormulario).val();
	
	cdtipcat = normalizaNumero( cdtipcat );
	cddgrupo = normalizaNumero( cddgrupo );
	cdsubgru = normalizaNumero( cdsubgru );
	cdcatego = normalizaNumero( cdcatego );	
	
	aux_cddgrupo = cddgrupo;
	aux_dsdgrupo = dsdgrupo;
	aux_cdsubgru = cdsubgru;
	aux_dssubgru = dssubgru;
	
	dscatego = '';
	
	titulo_coluna = "Categoria";
	
	bo			= 'b1wgen0153.p'; 
	procedure	= 'lista-categorias';
	titulo      = 'Descricao';
	qtReg		= '20';
	filtros 	= 'Grupo;cddgrupo;130px;N;' + cddgrupo + ';N|' + 'SubGrupo;cdsubgru;130px;N;' + cdsubgru + ';N|' +
	              'Tipo Categoria;cdtipcat;130px;S;' + cdtipcat + ';S|' + 'Categoria;cdcatego;130px;S;' + cdcatego + ';S|' +
				  'Descricao;dscatego;300px;S;' + dscatego + ';S';
	colunas 	= 'Grupo;cddgrupo;15%;right|SubGrupo;cdsubgru;15%;right|Tipo;cdtipcat;10%;right|' +
	              'Codigo;cdcatego;15%;right|' + titulo_coluna + ';dscatego;50%;left';
	mostraPesquisa(bo,procedure,titulo,qtReg,filtros,colunas,'','verifica_campos(' + aux_cddgrupo + ', "' + aux_dsdgrupo + '", ' + aux_cdsubgru + ', "' + aux_dssubgru + '")');	
	
	$("#divPesquisa").css("left","258px");
	$("#divPesquisa").css("top","91px");
	$("#divCabecalhoPesquisa > table").css("width","675px");
	$("#divCabecalhoPesquisa > table").css("float","left");
	$("#divResultadoPesquisa > table").css("width","690px");
	$("#divCabecalhoPesquisa").css("width","690px");
	$("#divResultadoPesquisa").css("width","690px");
	
	return false;	
}

function controlaPesquisaConvenio(){

	// Se esta desabilitado o campo 
	if ($("#nrconven","#frmCab").prop("disabled") == true)  {
		return; 
	}
	
	// Variável local para guardar o elemento anterior
	var campoAnterior = '';
	var bo, procedure, titulo, qtReg, filtros, colunas, titulo_coluna, nrconven;
	
	// Nome do Formulário que estamos trabalhando
	var nomeFormulario = 'frmCab';
	
	var divRotina = 'divTela';
	
	//Remove a classe de Erro do form
	$('input,select', '#'+nomeFormulario).removeClass('campoErro');
	
	var cdsubgru = $('#cdsubgru','#'+nomeFormulario).val();
    var cdocorre = cdsubgru == 15 ? 1 : 0; // cdsubgru = 15 = Com Registro
    var nrconven = $('#nrconven','#'+nomeFormulario).val();
	var cdcopatu = $('#glbcdcooper','#'+nomeFormulario).val();
	var cdinctar = normalizaNumero($('#cdinctar','#frmCab').val());
	dsconven = '';
	
	titulo_coluna = "Convenios";
	
	bo			= 'b1wgen0153.p'; 
	procedure	= 'lista-convenios';
	titulo      = 'Convenios';
	qtReg		= '20';
	filtros 	= 'Codigo;nrconven;130px;S;' + nrconven + ';S|Descricao;dsconven;300px;S;' + dsconven + ';S|Codigo;cdcopatu;130px;N;' + cdcopatu + ';N';
	filtros     = filtros + '|Ocorrencia;cdocorre;130px;N;' + cdocorre + ';N' + '|Tipo incidencia;cdinctar;130px;N;' + cdinctar + ';N';
	colunas 	= 'Codigo;nrconven;15%;right|Descricao;dsconven;75%;left';
	mostraPesquisa(bo,procedure,titulo,qtReg,filtros,colunas,'','$(\'#nrconven\',\'#frmCab\').focus()');
	
    return true;
}

function controlaPesquisaLinhaCredito(){

	// Se esta desabilitado o campo 
	if ($("#cdlcremp","#frmCab").prop("disabled") == true)  {
		return; 
	}
	
	// Variável local para guardar o elemento anterior
	var campoAnterior = '';
	var bo, procedure, titulo, qtReg, filtros, colunas, titulo_coluna, cdlcremp;
	
	// Nome do Formulário que estamos trabalhando
	var nomeFormulario = 'frmCab';
	
	var divRotina = 'divTela';
	
	//Remove a classe de Erro do form
	$('input,select', '#'+nomeFormulario).removeClass('campoErro');
	
	var cdlcremp = $('#cdlcremp','#'+nomeFormulario).val();
	var cdcopatu = $('#glbcdcooper','#'+nomeFormulario).val();
	var dslcremp = '';
	
	titulo_coluna = "Linhas de Credito";
	
	bo			= 'b1wgen0153.p'; 
	procedure	= 'lista-linhas-credito';
	titulo      = 'Linhas de Credito';
	qtReg		= '20';
	filtros 	= 'Codigo;cdlcremp;130px;S;' + cdlcremp + ';S|Descricao;dslcremp;300px;S;' + dslcremp + ';S|Codigo;cdcopatu;130px;N;' + cdcopatu + ';N';
	colunas 	= 'Codigo;cdlcremp;15%;right|Descricao;dslcremp;75%;left';
    mostraPesquisa(bo,procedure,titulo,qtReg,filtros,colunas,'','$(\'#cdlcremp\',\'#frmCab\').focus()');

    return true;
}

function trocaBotao( botao ) {
	
	$('#divBotoes','#divTela').html('');
	$('#divBotoes','#divTela').append('<a href="#" class="botao" id="btVoltar" onclick="btnVoltar(); return false;">Voltar</a>');
	
	if ( botao == 'btnConcluir') {
		$('#divBotoes','#divTela').append('&nbsp;<a href="#" class="botao" onClick="btnConcluir()" return false;" >Prosseguir</a>');
		return false;
	}

	if ( botao != '') {
		$('#divBotoes','#divTela').append('&nbsp;<a href="#" class="botao" onClick="realizaOperacao()" return false;" >'+botao+'</a>');
	}
	
	return false;
}

function btnConcluir() {

    cdtarifa = normalizaNumero( cCdtarifa.val() );
    dstarifa = $('#dstarifa','#frmCab').val();
    cddgrupo = normalizaNumero( cCddgrupo.val() );
    cdsubgru = normalizaNumero( cCdsubgru.val() );
    cdcatego = normalizaNumero( cCdcatego.val() );
    cdlcremp = cCdlcremp.val();
    nrconven = normalizaNumero( cNrconven.val() );
    dtdivulg = cDtdivulg.val();
    dtvigenc = cDtvigenc.val();
    dt_split = dtvigenc.split('/');
    dtvigen2 = new Date(dt_split.slice(0,3).reverse().join('/'));
    dt_split = $('#glbdtmvtolt','#frmCab').val().split('/');
    dtmvtolt = new Date(dt_split.slice(0,3).reverse().join('/'));

    if (dtdivulg == '') {
        showError('error','Data da divulgação deve ser informada.','Alerta - Ayllos','cDtdivulg.focus();');
        return false;
    }

    if (dtvigenc == '') {
        showError('error','Data de início da vigência deve ser informada.','Alerta - Ayllos','cDtvigenc.focus();');
        return false;
    }

    if (dtmvtolt >= dtvigen2) {
        showError('error','Data de início da vigência deve ser maior que a data atual.','Alerta - Ayllos','cDtvigenc.focus();');
        return false;
    }

    if (cdtarifa == '' && (cddgrupo == '' || cdsubgru == '' || cdcatego == '')) {
        return false;
    } else if (cdcatego == 2 && nrconven == '') { // Cobranca
        showError('error','Convênio deve ser informado.','Alerta - Ayllos','cNrconven.focus();');
        return false;
    } else if (cdcatego == 3 && cdlcremp == '') { // Emprestimo
        showError('error','Linha de Crédito deve ser informada.','Alerta - Ayllos','cCdlcremp.focus();');
        return false;
    } else {
        if (cdtarifa > 0 && dstarifa == '') {
            buscaDadosTarifa();
        }
        carregaDetalhamento();
    }

}

function carregaDetalhamento(){
	
	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, buscando detalhamento...");
	
	var cddopcao = $('#cddopcao','#frmCab').val();
    var cdtarifa = normalizaNumero( $('#cdtarifa','#frmCab').val() );
    var cddgrupo = normalizaNumero( $('#cddgrupo','#frmCab').val() );
    var cdsubgru = normalizaNumero( $('#cdsubgru','#frmCab').val() );
	var cdcatego = normalizaNumero( $('#cdcatego','#frmCab').val() );
    var cdlcremp = normalizaNumero( $('#cdlcremp','#frmCab').val() );
    var nrconven = normalizaNumero( $('#nrconven','#frmCab').val() );
    var dtdivulg = $('#dtdivulg','#frmCab').val();
    var dtvigenc = $('#dtvigenc','#frmCab').val();

    // Carrega dados parametro através de ajax
	$.ajax({		
		type	: 'POST',
		dataType: 'html',
		url		: UrlSite + 'telas/alttar/carrega_detalhamento.php', 
		data    : 
				{ 
					cddopcao	: cddopcao,
					cdtarifa	: cdtarifa,
                    cddgrupo    : cddgrupo,
                    cdsubgru    : cdsubgru,
                    cdcatego    : cdcatego,
                    cdlcremp    : cdlcremp,
                    nrconven    : nrconven,
                    dtdivulg    : dtdivulg,
                    dtvigenc    : dtvigenc,
					redirect	: 'script_ajax' 
				},
		error   : function(objAjax,responseError,objExcept) {
					hideMsgAguardo();
					showError('error','N&atilde;o foi possível concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','estadoInicial();');
				},
		success : function(response) { 
                    try {
                        $('#divDetalhamento').html(response);	
                        $('#divDetalhamento').css({'display':'block'});

                        formataDetalhamento();

                        hideMsgAguardo();
                        return false;
                    } catch(error) {
                        hideMsgAguardo();
                        showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','unblockBackground()');
                    }
				}
	});

	return false;		
}

function formataDetalhamento() {

	$('#divRotina').css('width','640px');

	var divRegistro = $('#divAtribuicaoDetalhamento');		
	var tabela      = $('table', divRegistro );
	var linha       = $('table > tbody > tr', divRegistro );
    
	cCdlcremp.desabilitaCampo();
	cNrconven.desabilitaCampo();
    cDtdivulg.desabilitaCampo();
	cDtvigenc.desabilitaCampo();
    
    $('.formatFieldOn').css({'width': '80px', 'text-align': 'right'}).setMask('DECIMAL', 'zzz.zzz.zzz.zz9,99', '.', '');
    $('.formatFieldOff').css({'width': '80px', 'text-align': 'right'}).desabilitaCampo();
    $('.tarifa').css({'width': '50px'});
			
	divRegistro.css({'height':'200px','width':'100%'});
	
	var ordemInicial = new Array();
	ordemInicial = [[0,0]];	
	
	var arrayLargura = new Array();
	arrayLargura[0] = '11%';
	arrayLargura[1] = '9.4%';
	arrayLargura[2] = '9.4%';
	arrayLargura[3] = '6.3%';
	arrayLargura[4] = '6.3%';
	arrayLargura[5] = '9.4%';
	arrayLargura[6] = '9.4%';
	arrayLargura[7] = '9.4%';
	arrayLargura[8] = '9.4%';
	arrayLargura[9] = '9.4%';
	arrayLargura[10] = '9%';

	var arrayAlinha = new Array();
	arrayAlinha[0] = 'left';
	arrayAlinha[1] = 'center';
	arrayAlinha[2] = 'center';
	arrayAlinha[3] = 'center';
	arrayAlinha[4] = 'center';
	arrayAlinha[5] = 'center';
	arrayAlinha[6] = 'center';
	arrayAlinha[7] = 'center';
	arrayAlinha[8] = 'center';
	arrayAlinha[9] = 'center';
	arrayAlinha[10] = 'center';
	
	var metodoTabela = '';
			
	tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha, metodoTabela );

    // var tabelaTitulo = $( 'table.tituloRegistros',divRegistro.parent() );
    // $('th:eq(0)', tabelaTitulo ).css('width', '223px');
    // $('th:eq(1)', tabelaTitulo ).css('width', '102px');
    // $('th:eq(2)', tabelaTitulo ).css('width', '102px');
    // $('th:eq(3)', tabelaTitulo ).css('width', '102px');
    // $('th:eq(4)', tabelaTitulo ).css('width', '102px');

	return false;
}
function realizaOperacao(cddopfco) {
    // Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, concluindo...");

	//Remove a classe de Erro do form
	$('input,select', '#frmAtribuicaoDetalhamento').removeClass('campoErro');
    
    var cddopcao = $('#cddopcao','#frmCab').val();
    var dtdivulg = $('#dtdivulg','#frmCab').val();
    var dtvigenc = $('#dtvigenc','#frmCab').val();
    var qtd_regs = $('#qtd_regs','#frmAtribuicaoDetalhamento').val();
	var cdinctar = normalizaNumero($('#cdinctar','#frmCab').val());
    
    var vltarnew = 0;
    var lstfaixa = '';
    var lstvltar = '';
    var lstconve = '';
    var lstocorr = '';
    var lstlcrem = '';
    var blntemvl = false;
    var vlpertar = '';
    var vlmintar = '';
    var vlmaxtar = '';
    var tpcobtar = '';
    var vlpercno = 0;
    var vlminnov = 0;
    var vlmaxnov = 0;
    
    for (var i = 1; i <= qtd_regs; i++) {
        vltarnew = $('#vltarnew_' + i,'#frmAtribuicaoDetalhamento').val().replace('.', '').replace(',', '.');
        vlpercno = $('#vlpercno_' + i,'#frmAtribuicaoDetalhamento').val().replace('.', '').replace(',', '.');
        vlminnov = $('#vlminnov_' + i,'#frmAtribuicaoDetalhamento').val().replace('.', '').replace(',', '.');
        vlmaxnov = $('#vlmaxnov_' + i,'#frmAtribuicaoDetalhamento').val().replace('.', '').replace(',', '.');
        if (vltarnew > 0 || vlpercno > 0 || vlminnov > 0 || vlmaxnov > 0) {

        	if(parseFloat(vlminnov) > parseFloat(vlmaxnov)) {
        		hideMsgAguardo();
        		showError("error","O valor do campo Min. Novo deve ser menor que o Max. Novo","Alerta - Ayllos","unblockBackground(parseInt($('#divRotina').css('z-index')))");
        		return false;
        	}

        if (vltarnew > 0) {
        		tpcobtar = tpcobtar + (tpcobtar == '' ? '' : ';') + 1;
        	}else if(vlpercno > 0 || vlminnov > 0 || vlmaxnov > 0){
        		tpcobtar = tpcobtar + (tpcobtar == '' ? '' : ';') + 2;
        	}

            blntemvl = true;
            lstvltar = lstvltar + (lstvltar == '' ? '' : ';') + vltarnew;
            lstfaixa = lstfaixa + (lstfaixa == '' ? '' : ';') + $('#cdfaixav_' + i,'#frmAtribuicaoDetalhamento').val();
            lstlcrem = lstlcrem + (lstlcrem == '' ? '' : ';') + $('#cdlcremp_' + i,'#frmAtribuicaoDetalhamento').val();
            lstconve = lstconve + (lstconve == '' ? '' : ';') + $('#nrconven_' + i,'#frmAtribuicaoDetalhamento').val();
            lstocorr = lstocorr + (lstocorr == '' ? '' : ';') + $('#cdocorre_' + i,'#frmAtribuicaoDetalhamento').val();
        	vlpertar = vlpertar + (vlpertar == '' ? '' : ';') + vlpercno;
            vlmintar = vlmintar + (vlmintar == '' ? '' : ';') + vlminnov;
            vlmaxtar = vlmaxtar + (vlmaxtar == '' ? '' : ';') + vlmaxnov;
        }
    }
    
    // Se foi digitado algum valor e possui as datas
    if (blntemvl && dtdivulg != '' && dtvigenc != '') {
        // Executa script através de ajax
        $.ajax({		
            type: "POST",
            url: UrlSite + "telas/alttar/manter_rotina.php",  
            data: {
                cddopcao: cddopcao,
                dtdivulg: dtdivulg,
                dtvigenc: dtvigenc,
                lstvltar: lstvltar,
                lstfaixa: lstfaixa,
                lstlcrem: lstlcrem,
                lstconve: lstconve,
                lstocorr: lstocorr,
				cdinctar: cdinctar,
				vlpertar: vlpertar,
				vlmintar: vlmintar,
				vlmaxtar: vlmaxtar,
				tpcobtar: tpcobtar,
                redirect: "script_ajax"
            }, 
            error: function(objAjax,responseError,objExcept) {
                hideMsgAguardo();
                showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
            },
            success: function(response) {
                try {
                    hideMsgAguardo();				
                    eval(response);
                } catch(error) {
                    hideMsgAguardo();
                    showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message,"Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
                }
            }				
        });
    } else {
        showError('error','Nenhum valor informado.','Alerta - Ayllos','hideMsgAguardo();');
        return false;
    }
}

function verifica_campos(cddgrupo, dsdgrupo, cdsubgru, dssubgru){

	var nomeFormulario = 'frmCab';
	
	if(($('#cddgrupo','#'+nomeFormulario).val() == '') ||
		($('#cddgrupo','#'+nomeFormulario).val() == '0')){
	
		$('#cddgrupo','#'+nomeFormulario).val(cddgrupo);
		$('#dsdgrupo','#'+nomeFormulario).val(dsdgrupo);
		
	}
	
	if(($('#cdsubgru','#'+nomeFormulario).val() == '') ||
		($('#cdsubgru','#'+nomeFormulario).val() == '0')){
	
		$('#cdsubgru','#'+nomeFormulario).val(cdsubgru);
		$('#dssubgru','#'+nomeFormulario).val(dssubgru);
		
	}	
	
	$("#cdcatego","#frmCab").focus();

	return false;
}

function limparCampoTarifaAtual(id){

	$('#vltarnew_'+id,'#frmAtribuicaoDetalhamento').val(0).blur();
	
}

function limparCamposNovaTarifa(id){

	$('#vlpercno_'+id,'#frmAtribuicaoDetalhamento').val(0).blur();
	$('#vlminnov_'+id,'#frmAtribuicaoDetalhamento').val(0).blur();
	$('#vlmaxnov_'+id,'#frmAtribuicaoDetalhamento').val(0).blur();
}