/*!
 * FONTE        : prmpos.js
 * CRIAÇÃO      : Jaison
 * DATA CRIAÇÃO : 24/03/2017
 * OBJETIVO     : Biblioteca de funções da tela
 * --------------
 * ALTERAÇÕES   : 
 * --------------
 */
$(document).ready(function() {

	estadoInicial();

	$('fieldset > legend').css({'font-size':'11px','color':'#777','margin-left':'5px','padding':'0px 2px'});
	$('fieldset').css({'clear':'both','border':'1px solid #777','margin':'3px 0px','padding':'10px 3px 5px 3px'});

	return false;

});

function estadoInicial() {
	$('#frmPrmpos').css({'display':'none'});	
	$('#divBotoes', '#divTela').html('').css({'display':'block'});
	formataCabecalho();
	return false;
}

function formataCabecalho() {

	$('#divTela').css({'display':'inline'}).fadeTo(0,0.1);
	removeOpacidade('divTela');	

	carregaTelaPrmpos();
	layoutPadrao();

	return false;
}

function trocaBotao(sNomeBotaoSalvar,sFuncaoSalvar,sFuncaoVoltar) {
	$('#divBotoes','#divTela').html('');
	$('#divBotoes','#divTela').append('<a href="#" class="botao" id="btVoltar" onClick="'+sFuncaoVoltar+'; return false;">Voltar</a>&nbsp;');

	if (sFuncaoSalvar != ''){
		$('#divBotoes','#divTela').append('<a href="#" class="botao" id="btSalvar" onClick="'+sFuncaoSalvar+'; return false;">'+sNomeBotaoSalvar+'</a>');	
	}
	return false;
}

/**
	Funcao responsavel para formatar os campos em tela
*/
function formataCamposTela() {

    highlightObjFocus($('#frmPrmpos'));

    var rVlminimo_emprestado    = $('label[for="vlminimo_emprestado"]', '#frmPrmpos');
    var rVlmaximo_emprestado    = $('label[for="vlmaximo_emprestado"]', '#frmPrmpos');
    var rQtdminima_parcela      = $('label[for="qtdminima_parcela"]',   '#frmPrmpos');
    var rQtdmaxima_parcela      = $('label[for="qtdmaxima_parcela"]',   '#frmPrmpos');

    var cVlminimo_emprestado    = $('#vlminimo_emprestado',             '#frmPrmpos');
    var cVlmaximo_emprestado    = $('#vlmaximo_emprestado',             '#frmPrmpos');
    var cQtdminima_parcela      = $('#qtdminima_parcela',               '#frmPrmpos');
    var cQtdmaxima_parcela      = $('#qtdmaxima_parcela',               '#frmPrmpos');
    var cClsCheck               = $('.clsCheck',                        '#frmPrmpos');
    var cClsList                = $('.clsList',                         '#frmPrmpos');

    rVlminimo_emprestado.addClass('rotulo').css({'width': '140px'});
    cVlminimo_emprestado.addClass('campo moeda').css({'width':'100px'});

    rVlmaximo_emprestado.addClass('rotulo-linha').css({'width': '150px'});
    cVlmaximo_emprestado.addClass('campo moeda').css({'width':'100px'});

    rQtdminima_parcela.addClass('rotulo').css({'width': '140px'});
    cQtdminima_parcela.addClass('campo').css({'width':'100px'}).attr('maxlength','4').setMask('INTEGER','zzzz','','');

    rQtdmaxima_parcela.addClass('rotulo-linha').css({'width': '150px'});
    cQtdmaxima_parcela.addClass('campo').css({'width':'100px'}).attr('maxlength','4').setMask('INTEGER','zzzz','','');

    cClsCheck.addClass('campo').css({'float':'none'});
    cClsList.addClass('campo').css({'width':'100px'});

    cVlminimo_emprestado.unbind('keypress').bind('keypress', function(e) {
        if ( divError.css('display') == 'block' ) { return false; }
        if ( e.keyCode == 9 || e.keyCode == 13 ) {
            cVlmaximo_emprestado.focus();
            return false;
        }
    });

    cVlmaximo_emprestado.unbind('keypress').bind('keypress', function(e) {
        if ( divError.css('display') == 'block' ) { return false; }
        if ( e.keyCode == 9 || e.keyCode == 13 ) {
            cQtdminima_parcela.focus();
            return false;
        }
    });

    cQtdminima_parcela.unbind('keypress').bind('keypress', function(e) {
        if ( divError.css('display') == 'block' ) { return false; }
        if ( e.keyCode == 9 || e.keyCode == 13 ) {
            cQtdmaxima_parcela.focus();
            return false;
        }
    });

    cQtdmaxima_parcela.unbind('keypress').bind('keypress', function(e) {
        if ( divError.css('display') == 'block' ) { return false; }
        if ( e.keyCode == 9 || e.keyCode == 13 ) {
            $("#htmFieldIndex select").first().focus();
            return false;
        }
    });

    $('.clsInput').keydown(function (e) {
        if (e.which === 13) {
            var index = $('.clsInput').index(this) + 1;
            $('.clsInput').eq(index).focus();
        }
    });

	layoutPadrao();
    return false;
}
/**
	Funcao responsavel para carregar a tela
*/
function carregaTelaPrmpos() {

	showMsgAguardo("Aguarde...");
	
	// Executa script de bloqueio através de ajax
	$.ajax({		
		type: "POST",
		url: UrlSite + "telas/prmpos/principal.php", 
		data: {			
			redirect: "script_ajax"
		}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","blockBackground(parseInt($('#divTela').css('z-index')))");
		},
		success : function(response) {
			hideMsgAguardo();
			try {
				$('#divCadastro').html(response);

                var nmBotao = 'Alterar';
                var nmFuncao = 'confirmaAcao();';

                // Exibe os botoes
                trocaBotao(nmBotao,nmFuncao,'');
                $('#btVoltar', '#divBotoes').hide();
                $('#btSalvar', '#divBotoes').addClass('clsInput');
                
                buscaDados();

				return false;
			} catch(error) {
				hideMsgAguardo();
				showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','unblockBackground()');
			}
		}
	});
}

/**
	Funcao responsavel por buscar os dados
*/
function buscaDados() {

	showMsgAguardo("Aguarde...");

    // Executa script de bloqueio através de ajax
	$.ajax({		
		type: "POST",
		url: UrlSite + "telas/prmpos/busca_dados.php", 
		data: {			
			redirect: "script_ajax"
		}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","blockBackground(parseInt($('#divTela').css('z-index')))");
		},
		success : function(response) {
			hideMsgAguardo();
			try { 
				eval(response);
                formataCamposTela();
                $('#vlminimo_emprestado', '#frmPrmpos').focus();
				return false;
			} catch(error) {
				hideMsgAguardo();
				showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','unblockBackground()');
			}
		}
	});
}

/**
	Funcao responsavel para confirmar acao
*/
function confirmaAcao() {
    showConfirmacao('Confirma a opera&ccedil;&atilde;o?', 'Confirma&ccedil;&atilde;o - Ayllos', 'gravarDados()', '', 'sim.gif', 'nao.gif');
}

/**
	Funcao responsavel por gravar os dados
*/
function gravarDados() {

    var vlminimo_emprestado = $('#vlminimo_emprestado', '#frmPrmpos').val();
    var vlmaximo_emprestado = $('#vlmaximo_emprestado', '#frmPrmpos').val();
    var qtdminima_parcela   = normalizaNumero($('#qtdminima_parcela', '#frmPrmpos').val());
    var qtdmaxima_parcela   = normalizaNumero($('#qtdmaxima_parcela', '#frmPrmpos').val());

    var cddindex, tpatualizacao;
    var strPeriodicidadeIndex  = '';
    $('#htmFieldIndex select').each(function(){
        cddindex = normalizaNumero($(this).attr('id'));
        tpatualizacao = $('#tpatualizacao_' + cddindex, '#frmPrmpos').val();
        strPeriodicidadeIndex   += (strPeriodicidadeIndex == '' ? '' : '#') + cddindex + '_' + tpatualizacao;
    });

    var idcarencia, flghabilitado;
    var strPeriodicidadeCaren  = '';
    $('#htmBodyCarencia input').each(function(){
        idcarencia = normalizaNumero($(this).attr('id'));
        flghabilitado = $('#flghabilitado_' + idcarencia,  '#frmPrmpos').prop('checked') ? 1 : 0;
        strPeriodicidadeCaren   += (strPeriodicidadeCaren == '' ? '' : '#') + idcarencia + '_' + flghabilitado;
    });

    showMsgAguardo("Aguarde, processando...");

    // Executa script de bloqueio através de ajax
	$.ajax({		
		type: "POST",
		url: UrlSite + "telas/prmpos/manter_rotina.php", 
		data: {
			vlminimo_emprestado   : vlminimo_emprestado,
			vlmaximo_emprestado   : vlmaximo_emprestado,
            qtdminima_parcela     : qtdminima_parcela,
            qtdmaxima_parcela     : qtdmaxima_parcela,
            strPeriodicidadeIndex : strPeriodicidadeIndex,
            strPeriodicidadeCaren : strPeriodicidadeCaren,
			redirect              : "script_ajax"
		}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","blockBackground(parseInt($('#divTela').css('z-index')))");
		},
		success : function(response) {
			try { 
				eval(response);
				return false;
			} catch(error) {
				hideMsgAguardo();
				showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','unblockBackground()');
			}
		}
	});
}
