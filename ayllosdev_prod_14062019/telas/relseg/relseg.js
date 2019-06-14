/*!
 * FONTE        : relseg.js
 * CRIAÇÃO      : David Kruger
 * DATA CRIAÇÃO : 22/02/2013
 * OBJETIVO     : Biblioteca de funções da tela RELSEG
 * --------------
 * ALTERAÇÕES   : 25/07/2013 - Passado o cddopcao para a função Gera_Impressao repassar a opção e, com isto, verificar as permissões de acesso devidamente. (Carlos)
                : 12/09/2013 - Alterada a função de #dtfimper, para quando for pressionado o enter, gerar o relatório, assim como quando clicado
				               no botão no botão Prosseguir. (Carlos)
				: 18/02/2014 - Exportação em .txt para Tp.Relat 5 (Lucas)

                : 12/05/2016 - PRJ187.2 - Adicionada opção 6 - Seguro Sicredi (Guilherme/SUPERO)
 *				  
 *				  
 * --------------
 */

// Definição de algumas variáveis globais 
var cddopcao        = 'C';

	
//Formulários
var frmCab          = 'frmCab';
var formDados       = 'frmRel';

//Labels e Campos do cabeçalho
var rCddopcao, 
	cCddopcao, cTodosCabecalho, cTodosSeguros, cTodosRelatorios, btnCab, cDtiniper, cDtfimper, cInexprel;

$(document).ready(function() {

	estadoInicial();
	
	highlightObjFocus( $('#'+frmCab) );
	
	$('fieldset > legend').css({'font-size':'11px','color':'#777','margin-left':'5px','padding':'0px 2px'});
	$('fieldset').css({'clear':'both','border':'1px solid #777','margin':'3px 0px','padding':'10px 3px 5px 3px'});
	
	return false;
	
	
});

// seletores
function estadoInicial() {

	$('#frmCab').css({'display':'block'});
	$('#frmSeg').css({'display':'none'});
	$('#frmRel').css({'display':'none'});

    $('#divParam','#frmRel').css('display','block');
    $('#divOp6'  ,'#frmRel').css('display','none');
    $('#tprelato','#frmRel').val( 1 );

    $('#tpseguro','#frmRel').val( 2 );
    $('#tpstaseg','#frmRel').val( 'A' );
    
	formataCabecalho();
	
	cTodosCabecalho.limpaFormulario();
    $('input[type="text"],select','#frmRel').limpaFormulario();
    $('input,select', '#frmRel').removeClass('campoErro');
	
	cCddopcao.val( cddopcao );
    $('#cddopcao','#frmCab').val( 'C' );
    $('#cddopcao','#frmCab').focus();
	
	$('#divBotoes', '#divTela').css({'display':'none'});
	
	removeOpacidade('divTela');
	
	unblockBackground();
	hideMsgAguardo();
	
	$('input,select', '#frmCab').removeClass('campoErro');
	
	controlaFoco();
}

function controlaFoco() {
	
	$('#cddopcao','#frmCab').unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {	
			$('#btnOK','#frmCab').focus();
			return false;
		}	
	});
	
	$('#btnOK','#frmCab').unbind('keypress').bind('keypress', function(e) {
		if($('#cddopcao','#frmCab').val() != 'R'){
			if ( e.keyCode == 9 || e.keyCode == 13 ) {	
				$('#cddopcao','#frmCab').desabilitaCampo();
				btnContinuar();
				return false;
			}	
		}else{
			$('#cddopcao','#frmCab').desabilitaCampo();
		    formataRelatorio();
			$('#frmRel').css('display','block');
			$('#tprelato','#frmRel').focus();	
			$('#divBotoes', '#divTela').css({'display':'block'});
			trocaBotao('btnRelatorio()');
			
		}
	});
	
	$('#btnOK','#frmCab').unbind('click').bind('click', function(){
		if($('#cddopcao','#frmCab').val() != 'R'){
			$('#cddopcao','#frmCab').desabilitaCampo();
			btnContinuar();
			return false;
			
		}else{
		    $('#cddopcao','#frmCab').desabilitaCampo();
		    formataRelatorio();
			$('#frmRel').css('display','block');
			$('#tprelato','#frmRel').focus();	
			$('#divBotoes', '#divTela').css({'display':'block'});
			trocaBotao('btnRelatorio()');
		}
		
	});
	
}


function formataCabecalho() {

	// cabecalho
	rCddopcao			= $('label[for="cddopcao"]','#'+frmCab); 
	
	cCddopcao			= $('#cddopcao','#'+frmCab); 
	
	cTodosCabecalho		= $('input[type="text"],select','#'+frmCab);
	btnCab				= $('#btOK','#'+frmCab);
	
	//Rótulos
	rCddopcao.css('width','44px');
	
	//Campos	
	cCddopcao.css({'width':'496px'});
	
	cTodosCabecalho.habilitaCampo();
	
	$('#cddopcao','#'+frmCab).focus();	

	layoutPadrao();
	return false;	
}

function formataRelatorio(){

    var rTelcdage, rDtiniper, rInexprel, rDtfimper, cTelcdage, cDtiniper, cInexprel, cDtfimper, rTprelato, cTprelato, tprelato,
        rTpseguro, cTpseguro, rTpstaseg, cTpstaseg;
	
	highlightObjFocus($('#frmRel')); 
	
	cTodosRelatorios = $('input[type="text"],select','#frmRel');
	
	cTodosRelatorios.limpaFormulario();
	
	cddopcao = $('#cddopcao','#frmCab').val();
	
	// cabecalho dados relatorios
	rTprelato = $('label[for="tprelato"]','#frmRel'); 
	rTelcdage = $('label[for="telcdage"]','#frmRel'); 
	rDtiniper = $('label[for="dtiniper"]','#frmRel'); 
	rDtfimper = $('label[for="dtfimper"]','#frmRel'); 
	rInexprel = $('label[for="inexprel"]','#frmRel'); 
	
	cTprelato = $('#tprelato','#frmRel'); 
	cTelcdage = $('#telcdage','#frmRel'); 
	cDtiniper = $('#dtiniper','#frmRel'); 
	cDtfimper = $('#dtfimper','#frmRel'); 
	cInexprel = $('#inexprel','#frmRel'); 
    // Relatorio tipo 6
    rTpseguro  = $('label[for="tpseguro"]','#frmRel');
    rTpstaseg  = $('label[for="tpstaseg"]','#frmRel');
    cTpseguro  = $('#tpseguro','#frmRel');
    cTpstaseg  = $('#tpstaseg','#frmRel');
	
	//Rótulos
	rTprelato.css('width','44px');
    rTpseguro.css ('width','44px');
    rTpstaseg.css('width','120px');
	rTelcdage.addClass('rotulo').css({'width':'44px'});
	rDtiniper.addClass('rotulo-linha').css({'width':'70px'});
	rDtfimper.addClass('rotulo-linha').css({'width':'30px'});	
	rInexprel.addClass('rotulo-linha').css({'width':'61px'});	
	
	//Campos
	cTprelato.css('width','496px');
    cTpseguro.css('width','100px');
    cTpstaseg.css('width','100px');
	cTelcdage.addClass('inteiro').css({'width':'50px'});
	cDtiniper.addClass('data').css({'width':'100px'});
	cInexprel.css({'width':'65px'});
	cDtfimper.addClass('data').css({'width':'100px','margin-left':'5px'});
	
	cTodosRelatorios.habilitaCampo();
	
	$('#tprelato','#frmRel').focus();	
	
	$('#tprelato','#frmRel').unbind('change').bind('change',function() {
	
		if (cTprelato.val() == 5 || cTprelato.val() == 7) {
			$('#divExpRel','#frmRel').css('display','block');
            $('#divParam' ,'#frmRel').css('display','block');
            $('#divOp6'   ,'#frmRel').css('display','none');
			formataRelatorio();
        } else if (cTprelato.val() == 6){ //SEGURO AUTO
            $('#divExpRel','#frmRel').css('display','none');
            $('#divParam' ,'#frmRel').css('display','none');
            $('#divOp6'   ,'#frmRel').css('display','block');
		} else {
			$('#divExpRel','#frmRel').css('display','none');
            $('#divParam' ,'#frmRel').css('display','block');
            $('#divOp6'   ,'#frmRel').css('display','none');
		}				
	});
	
	$('#tprelato','#frmRel').unbind('keypress').bind('keypress', function(e) {
        if (cTprelato.val() == 6) {
            if ( e.keyCode == 13 || e.keyCode == 9 ) {
                $('#tpseguro','#frmRel').focus();
                return false;
            }
        } else {
			if ( e.keyCode == 13 || e.keyCode == 9 ) {	
				$('#telcdage','#frmRel').focus();
				return false;
			}	
        }
	});
	
	$('#telcdage','#frmRel').unbind('keypress').bind('keypress', function(e) {
			if ( e.keyCode == 13 || e.keyCode == 9 ) {	
				$('#dtiniper','#frmRel').focus();
				return false;
			}	
	});
	
	$('#dtiniper','#frmRel').unbind('keypress').bind('keypress', function(e) {
			if ( e.keyCode == 13 || e.keyCode == 9 ) {	
				$('#dtfimper','#frmRel').focus();
				return false;
			}	
	});
	
    $('#tpseguro','#frmRel').unbind('keypress').bind('keypress', function(e) {
            if ( e.keyCode == 13 || e.keyCode == 9 ) {
                $('#tpstaseg','#frmRel').focus();
                return false;
            }
    });
    $('#tpstaseg','#frmRel').unbind('keypress').bind('keypress', function(e) {
        if ( e.keyCode == 13 || e.keyCode == 9 || e.keyCode == 118 ) {
            showConfirmacao('Confirma a operacao?','Confirma&ccedil;&atilde;o - Ayllos','btnRelatorio();','estadoInicial();','sim.gif','nao.gif');
            return false;
        }
    });

	$('#dtfimper','#frmRel').unbind('keypress').bind('keypress', function(e) {
		if(cddopcao == 'R'){
			if ($('#tprelato', '#frmRel').val() != 5 && $('#tprelato', '#frmRel').val() != 7) {
				if ( e.keyCode == 13 || e.keyCode == 9 || e.keyCode == 118 ) {
					showConfirmacao('Confirma a operacao?','Confirma&ccedil;&atilde;o - Ayllos','btnRelatorio();','estadoInicial();','sim.gif','nao.gif');
					return false;
				}	
			} else {
				if ( e.keyCode == 13 || e.keyCode == 9 || e.keyCode == 118 ) {
					$('#inexprel','#frmRel').focus();
					return false;
				}
			}
		}	
		
	}); 	
	
	$('#inexprel','#frmRel').unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 13 || e.keyCode == 9 || e.keyCode == 118 ) {
			showConfirmacao('Confirma a operacao?','Confirma&ccedil;&atilde;o - Ayllos','btnRelatorio();','estadoInicial();','sim.gif','nao.gif');
			return false;
		}		
	}); 	
	
	layoutPadrao();
	return false;

}


function formataSeguros(){

	var rVlrdecom1, rVlrdecom2, rVlrdecom3, rVlrdeiof1, rVlrdeiof2, rVlrdeiof3, rVlrapoli,
	    cVlrdecom1, cVlrdecom2, cVlrdecom3, cVlrdeiof1, cVlrdeiof2, cVlrdeiof3, cVlrapoli;
	
	var cddopcao;
	
	highlightObjFocus($('#frmSeg')); 
	
	cddopcao = $('#cddopcao','#frmCab').val();
	
	// cabecalho dados seguros
    rVlrdecom1          = $('label[for="vlrdecom1"]','#frmSeg');
    rVlrdecom2          = $('label[for="vlrdecom2"]','#frmSeg');
    rVlrdecom3          = $('label[for="vlrdecom3"]','#frmSeg');
    rVlrdeiof1          = $('label[for="vlrdeiof1"]','#frmSeg');
    rVlrdeiof2          = $('label[for="vlrdeiof2"]','#frmSeg');
    rVlrdeiof3          = $('label[for="vlrdeiof3"]','#frmSeg');
    rVlrapoli           = $('label[for="vlrapoli"]','#frmSeg');
	
    cVlrdecom1          = $('#vlrdecom1','#frmSeg');
    cVlrdecom2          = $('#vlrdecom2','#frmSeg');
    cVlrdecom3          = $('#vlrdecom3','#frmSeg');
    cVlrdeiof1          = $('#vlrdeiof1','#frmSeg');
    cVlrdeiof2          = $('#vlrdeiof2','#frmSeg');
    cVlrdeiof3          = $('#vlrdeiof3','#frmSeg');
    cVlrapoli           = $('#vlrapoli','#frmSeg');
	
    cTodosSeguros       = $('input[type="text"]','#frmSeg');

	//Labels
	rVlrdecom1.addClass('rotulo').css({'width':'100px'});
	rVlrdecom2.addClass('rotulo').css({'width':'100px'});
	rVlrdecom3.addClass('rotulo').css({'width':'100px'});
	rVlrdeiof1.addClass('rotulo-linha').css({'width':'60px'});
	rVlrdeiof2.addClass('rotulo-linha').css({'width':'60px'});
	rVlrdeiof3.addClass('rotulo-linha').css({'width':'60px'});
	rVlrapoli.addClass('rotulo-linha').css({'width':'60px'});
	
	//Campos
	cVlrdecom1.addClass('moeda').css({'width':'100px'});	
	cVlrdecom2.addClass('moeda').css({'width':'100px'});	
	cVlrdecom3.addClass('moeda').css({'width':'100px'});	
	cVlrdeiof1.addClass('moeda').css({'width':'100px'});	
	cVlrdeiof2.addClass('moeda').css({'width':'100px'});	
	cVlrdeiof3.addClass('moeda').css({'width':'100px'});	
	cVlrapoli.addClass('moeda').css({'width':'100px'});	
	
	
	if ( $.browser.msie ) {
	
		rVlrdecom1.addClass('rotulo').css({'width':'100px'});
		rVlrdecom2.addClass('rotulo').css({'width':'100px'});
		rVlrdecom3.addClass('rotulo').css({'width':'100px'});
		rVlrdeiof1.addClass('rotulo-linha').css({'width':'60px'});
		rVlrdeiof2.addClass('rotulo-linha').css({'width':'60px'});
		rVlrdeiof3.addClass('rotulo-linha').css({'width':'60px'});
		rVlrapoli.addClass('rotulo-linha').css({'width':'60px'});
	
		//Campos
		cVlrdecom1.addClass('moeda').css({'width':'100px'});	
		cVlrdecom2.addClass('moeda').css({'width':'100px'});	
		cVlrdecom3.addClass('moeda').css({'width':'100px'});	
		cVlrdeiof1.addClass('moeda').css({'width':'100px'});	
		cVlrdeiof2.addClass('moeda').css({'width':'100px'});	
		cVlrdeiof3.addClass('moeda').css({'width':'100px'});	
		cVlrapoli.addClass('moeda').css({'width':'100px'});	
	}
	
	cTodosSeguros.desabilitaCampo();
	
	$('#vlrdecom1','#frmSeg').focus();
	
	$('#vlrdecom1','#frmSeg').unbind('keypress').bind('keypress', function(e) {
			if ( e.keyCode == 13 || e.keyCode == 9 ) {	
				$('#vlrdeiof1','#frmSeg').focus();
				return false;
			}	
	});

	$('#vlrdeiof1','#frmSeg').unbind('keypress').bind('keypress', function(e) {
			if ( e.keyCode == 13 || e.keyCode == 9 || e.keyCode == 118 ) {	
				$('#vlrapoli','#frmSeg').focus();
				return false;
			}	
	});

	$('#vlrapoli','#frmSeg').unbind('keypress').bind('keypress', function(e) {
			if ( e.keyCode == 13 || e.keyCode == 9 ) {	
				$('#vlrdecom2','#frmSeg').focus();
				return false;
			}	
	});
	
	$('#vlrdecom2','#frmSeg').unbind('keypress').bind('keypress', function(e) {
			if ( e.keyCode == 13 || e.keyCode == 9 ) {	
				$('#vlrdeiof2','#frmSeg').focus();
				return false;
			}	
	});
	
	$('#vlrdeiof2','#frmSeg').unbind('keypress').bind('keypress', function(e) {
			if ( e.keyCode == 13 || e.keyCode == 9 ) {	
				$('#vlrdecom3','#frmSeg').focus();
				return false;
			}	
	});
	
	$('#vlrdecom3','#frmSeg').unbind('keypress').bind('keypress', function(e) {
			if ( e.keyCode == 13 || e.keyCode == 9 ) {	
				$('#vlrdeiof3','#frmSeg').focus();
				return false;
			}	
	});

	$('#vlrdeiof3','#frmSeg').unbind('keypress').bind('keypress', function(e) {
		if(cddopcao == 'A'){ 
			if ( e.keyCode == 13 || e.keyCode == 9 || e.keyCode == 118 ) {	
				showConfirmacao('Confirma a operacao?','Confirma&ccedil;&atilde;o - Ayllos','alteraDados();','estadoInicial();','sim.gif','nao.gif');
				return false;
			}	
		}
		
	}); 	
	
	controlaFoco();
	layoutPadrao();
	return false;	

}

function controlaCampos(op) {

    var cddopcao = op;
	
	cTodosCabecalhos		= $('input[type="text"],select','#frmCab'); 
	cTodosCabecalhos.desabilitaCampo();

	if( cddopcao == 'A'){
		
		$('#vlrdecom1','#frmSeg').habilitaCampo();
		$('#vlrdecom1','#frmSeg').focus();
		$('#vlrdeiof1','#frmSeg').habilitaCampo();
		$('#vlrapoli','#frmSeg').habilitaCampo();
		
		$('#vlrdecom2','#frmSeg').habilitaCampo();
		$('#vlrdeiof2','#frmSeg').habilitaCampo();
		
		$('#vlrdecom3','#frmSeg').habilitaCampo();
		$('#vlrdeiof3','#frmSeg').habilitaCampo();	
		
		trocaBotao("showConfirmacao('Confirma a operacao?','Confirma&ccedil;&atilde;o - Ayllos','alteraDados();','estadoInicial();','sim.gif','nao.gif');");
	}

	return false;
}

// botoes
function btnVoltar() {
	
	estadoInicial();
	return false;
}

function btnContinuar() {
	
	cddopcao = $('#cddopcao','#frmCab').val();
	
	buscaDados(cddopcao);
	
	return false;
}

function btnAvancar(){
	
	trocaBotao("showConfirmacao('Confirma a operacao?','Confirma&ccedil;&atilde;o - Ayllos','alteraDados();','estadoInicial();','sim.gif','nao.gif');");
	
	return false;
	
}

function btnRelatorio(){

	cddopcao = $('#cddopcao','#frmCab').val();

	Gera_Impressao(cddopcao); 
	
	return false;

}

function trocaBotao( funcao ) {
	
	$('#divBotoes','#divTela').html('');
	$('#divBotoes','#divTela').append('<a href="#" class="botao" id="btVoltar" onClick="btnVoltar(); return false;" >Voltar</a>&nbsp;');
	$('#divBotoes','#divTela').append('<a href="#" class="botao" id="btSalvar" onClick="'+funcao+'; return false;">Prosseguir</a>');
	
	
	return false;
}

function buscaDados(op) {

	showMsgAguardo("Aguarde, buscando dados...");
	
	// Executa script de bloqueio através de ajax
	$.ajax({		
		type: "POST",
		url: UrlSite + "telas/relseg/busca_seguros.php", 
		data: {
			cddopcao: op,
			redirect: "script_ajax"
		}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
		success : function(response) {
					hideMsgAguardo();
					if ( response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1 ) {
						try { 
							$('#divSeguros').html(response);
							return false;
						} catch(error) {
							hideMsgAguardo();
							showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','unblockBackground()');
						}
					} else {
						try { 
							eval( response );
						} catch(error) {
							hideMsgAguardo();
							showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','unblockBackground()');
						}
					}
				}		
	});				
}


function alteraDados() {

	showMsgAguardo("Aguarde, alterando dados...");
	
	var vlrdecom1 = $('#vlrdecom1','#frmSeg').val();
	var vlrdecom2 = $('#vlrdecom2','#frmSeg').val();
	var vlrdecom3 = $('#vlrdecom3','#frmSeg').val();
	
	var vlrdeiof1 = $('#vlrdeiof1','#frmSeg').val();
	var vlrdeiof2 = $('#vlrdeiof2','#frmSeg').val();
	var vlrdeiof3 = $('#vlrdeiof3','#frmSeg').val();
	
	var recid1 = $('#recid1','#frmSeg').val();
	var recid2 = $('#recid2','#frmSeg').val();
	var recid3 = $('#recid3','#frmSeg').val();
	
	var vlrapoli = $('#vlrapoli','#frmSeg').val();
	
	cddopcao = $('#cddopcao','#frmCab').val();
	
	
	// Executa script de bloqueio através de ajax
	$.ajax({		
		type: "POST",
		url: UrlSite + "telas/relseg/grava_dados.php", 
		data: {
		    cddopcao: cddopcao,
			vlrdecom1: vlrdecom1,
			vlrdecom2: vlrdecom2,
			vlrdecom3: vlrdecom3,
			vlrdeiof1: vlrdeiof1,
			vlrdeiof2: vlrdeiof2,
			vlrdeiof3: vlrdeiof3,
			recid1   : recid1,
			recid2   : recid2,
			recid3   : recid3,
			vlrapoli : vlrapoli,
			redirect: "script_ajax"
		}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
		success: function(response) {
				try {
					eval(response);
					return false;
				} catch(error) {
					hideMsgAguardo();
					showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','unblockBackground();');
				}
			}		
	});				
}

// imprimir
function Gera_Impressao(cddopcao) {	
	
	var action = UrlSite + 'telas/relseg/gera_relatorios.php';
	
	cDtiniper = $('#dtiniper','#frmRel'); 
	cDtfimper = $('#dtfimper','#frmRel'); 
	cInexprel = $('#inexprel','#frmRel'); 
    cTprelato = $('#tprelato','#frmRel');

	
    if (cTprelato.val() != 6) {
	if (cDtiniper.hasClass('campo') && (cDtiniper.val() == '' || cDtiniper.val() == null) ) {
		showError('error','170 - Data nao informada!','Alerta - Ayllos','focaCampoErro(\'dtiniper\',\''+ formDados +'\');');
		return false;
	}else if (cDtfimper.hasClass('campo') && (cDtfimper.val() == '' || cDtfimper.val() == null) ) {
		      showError('error','170 - Data nao informada!','Alerta - Ayllos','focaCampoErro(\'dtfimper\',\''+ formDados +'\');');
		      return false;
	}  
    }

    cTodosRelatorios = $('input[type="text"],select','#' + formDados);
	
	cTodosRelatorios.removeClass('campoErro');
	
	$('input', '#'+ formDados).habilitaCampo();
	
	$('#sidlogin','#' + formDados).remove();
	
	$('#' + formDados).append('<input type="hidden" id="sidlogin" name="sidlogin" value="' + $('#sidlogin','#frmMenu').val() + '" />');
	
	// Configuro o formulário para posteriormente submete-lo
	$('#cddopcao','#' + formDados).val(cddopcao);
	
	var callafter = "estadoInicial();";
	carregaImpressaoAyllos(formDados,action,callafter);
}