/*!
 * FONTE        : cadris.js
 * CRIAÇÃO      : James Prust Junior
 * DATA CRIAÇÃO : 15/12/2014
 * OBJETIVO     : Biblioteca de funções da tela CADRIS
 * --------------
 * ALTERAÇÕES   : 
 * --------------
 */
var iCodigoNivelRisco = 2;

$(document).ready(function() {

	estadoInicial();

	highlightObjFocus( $('#frmCab') );

	$('fieldset > legend').css({'font-size':'11px','color':'#777','margin-left':'5px','padding':'0px 2px'});
	$('fieldset').css({'clear':'both','border':'1px solid #777','margin':'3px 0px','padding':'10px 3px 5px 3px'});

	return false;

});

function estadoInicial() {
	$('#frmCab').css({'display':'block'});
	$('#frmCadris').css({'display':'none'});	
	$('#frmCadrisArquivo').css({'display':'none'});	
	$('#divBotoes', '#divTela').html('').css({'display':'block'});
	resetCodigoNivelRisco();
	formataCabecalho();
	return false;
}

function controlaFoco() {

	$('#cddopcao','#frmCab').unbind('keypress').bind('keypress', function(e) {

		if ( $('#cddopcao','#frmCab').hasClass('campoTelaSemBorda') ) { return false; }

		if ( e.keyCode == 9 || e.keyCode == 13 ) {	
			eventTipoOpcao();			
			return false;
		}	
	});

	$('#btnOK','#frmCab').unbind('keypress').bind('keypress', function(e) {

		if ( $('#cddopcao','#frmCab').hasClass('campoTelaSemBorda') ) { return false; }

		if ( e.keyCode == 9 || e.keyCode == 13 ) {	
			eventTipoOpcao();
			return false;
		}	
	});

	$('#btnOK','#frmCab').unbind('click').bind('click', function(){
	
		if ( $('#cddopcao','#frmCab').hasClass('campoTelaSemBorda') ) { return false; }		
		eventTipoOpcao();
		return false;			
	});

	return false;
}

function eventTipoOpcao(){
	resetCodigoNivelRisco();
	carregaTelaCadris();
	return false;
}

function formataCabecalho() {

	$('input,select', '#frmCab').removeClass('campoErro');
	$('#divTela').css({'display':'inline'}).fadeTo(0,0.1);
	removeOpacidade('divTela');	

	cTodosCabecalho = $('input[type="text"],select','#frmCab'); 
	cTodosCabecalho.limpaFormulario();

	// cabecalho
	rCddopcao			= $('label[for="cddopcao"]','#frmCab'); 	
	cCddopcao			= $('#cddopcao','#frmCab'); 	

	//Rótulos
	rCddopcao.css('width','44px');	

	//Campos	
	cCddopcao.css({'width':'496px'}).habilitaCampo().focus();	

	controlaFoco();
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
function formataCamposTela(cddopcao){

    var rInnivris = $('label[for="innivris"]', '#frmCadris');
    var cInnivris = $('#innivris', '#frmCadris');

    rInnivris.addClass('rotulo').css({width: "90px"});
    cInnivris.addClass('campo').css({'width':'40px'});
    cInnivris.habilitaCampo();

    // Oculta o fieldset de justificativa
    $('#fieldJustificativa', '#frmCadris').hide();

    // Se alterou o list de Nivel de Risco
    cInnivris.unbind('change').bind('change', function () {
        buscaListagem(cddopcao);
    });

    if (cddopcao == 'I') {

        // Exibe o campo de conta e justificativa
        $('.clsContaJustif', '#frmCadris').show();

        var rNrdconta = $('label[for="nrdconta"]', '#frmCadris');
        var rDsjustif = $('label[for="dsjustif"]', '#frmCadris');
        var cNrdconta = $('#nrdconta', '#frmCadris');
        var cDsjustif = $('#dsjustif', '#frmCadris');

        rNrdconta.addClass('rotulo-linha').css({width: "325px"});
        rDsjustif.addClass('rotulo').css({width: "90px"});
        cNrdconta.addClass('conta pesquisa').css({'width':'80px'});
        cDsjustif.addClass('campo').css({'width':'470px','height':'80px','margin-left':'3px'});

        cNrdconta.habilitaCampo();
        cDsjustif.habilitaCampo();

        cNrdconta.unbind('keypress').bind('keypress', function(e) {
            if ( divError.css('display') == 'block' ) { return false; }
            if ( e.keyCode == 9 || e.keyCode == 13 ) {
                if ( normalizaNumero( cNrdconta.val() ) == 0 ) {
                    mostraPesquisaAssociado('nrdconta', 'frmCadris');
                    return false;
                }
                cDsjustif.focus();
                return false;
            }
        });

        cDsjustif.unbind('keypress').bind('keypress', function(e) {
            if ( divError.css('display') == 'block' ) { return false; }
            if ( e.keyCode == 9 || e.keyCode == 13 ) {
                $('#btSalvar','#divBotoes').focus();
                return false;
            }
        });

    } else if (cddopcao != 'L') {

        // Oculta o campo de conta e justificativa
        $('.clsContaJustif', '#frmCadris').hide();
        
        if (cddopcao == 'C') {
            var rDsjustificativa = $('label[for="dsjustificativa"]', '#frmCadris');
            var cDsjustificativa = $('#dsjustificativa', '#frmCadris');
            
            rDsjustificativa.addClass('rotulo-linha').css({'margin-left':'10px','margin-top':'5px'});
            cDsjustificativa.addClass('campo').css({'width':'555px','height':'80px','margin-left':'10px','margin-bottom':'10px'});
            cDsjustificativa.desabilitaCampo();
            
            // Exibe o fieldset de justificativa
            $('#fieldJustificativa', '#frmCadris').show();
        }
    } else {
		$('label[for="nmdarqui"]','#frmCadrisArquivo').addClass('rotulo').css({'width':'80px'});
		$('#nmdarqui','#frmCadrisArquivo').css({'width':'415px'}).desabilitaCampo();
	}

	layoutPadrao();
	controlaPesquisas();	
    return false;
}	

function controlaPesquisas() {

    var nmformul = 'frmCadris';

	// Atribui a classe lupa para os links e desabilita todos
	$('a','#' + nmformul).addClass('lupa').css('cursor','auto');	

	// Percorrendo todos os links
	$('a','#' + nmformul).each( function() {
		if ( !$(this).prev().hasClass('campoTelaSemBorda') ) { $(this).css('cursor','pointer'); }
	});

	/*---------------------*/
	/*  CONTROLE CONTA/DV  */
	/*---------------------*/
	var linkConta = $('a:eq(0)','#' + nmformul);

	if ( linkConta.prev().hasClass('campoTelaSemBorda') ) {	
		linkConta.addClass('lupa').css('cursor','auto').unbind('click').bind('click', function() { return false; });
	} else {
		linkConta.css('cursor','pointer').unbind('click').bind('click', function() {			
			// Se esta desabilitado o campo da conta
			if ($("#nrdconta","#" + nmformul).prop("disabled") == true){
				return;
			}
			mostraPesquisaAssociado('nrdconta',nmformul);
		});
	}
	return false;
}

/**
	Funcao responsavel para carregar a tela
*/
function carregaTelaCadris(){

	showMsgAguardo("Aguarde...");
	
	var cCddopcao = $('#cddopcao','#frmCab');
	cCddopcao.desabilitaCampo();
	
	// Executa script de bloqueio através de ajax
	$.ajax({		
		type: "POST",
		url: UrlSite + "telas/cadris/principal.php", 
		data: {			
			cddopcao: cCddopcao.val(),
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
				$('#innivris', '#frmCadris').val(iCodigoNivelRisco);
				
                buscaListagem(cCddopcao.val());

                var nmBotao;
                var nmFuncao = 'confirmaAcao()';

                switch (cCddopcao.val()){
                    case 'I':
                        nmBotao  = 'Incluir';
                        break;
                    case 'E':
                        nmBotao  = 'Excluir';
                        break;
					case 'L':
						nmBotao = 'Importar';
						break;
                    default:
                        nmBotao  = '';
                        nmFuncao = '';
                }

                // Exibe os botoes
                trocaBotao(nmBotao,nmFuncao,'estadoInicial()');

				return false;
			} catch(error) {
				hideMsgAguardo();
				showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','unblockBackground()');
			}
		}
	});
}

/**
	Funcao responsavel por buscar a listagem
*/
function buscaListagem(cddopcao) {

	showMsgAguardo("Aguarde...");

    var innivris = $('#innivris','#frmCadris').val();

    // Executa script de bloqueio através de ajax
	$.ajax({		
		type: "POST",
		url: UrlSite + "telas/cadris/busca_dados.php", 
		data: {			
			cddopcao: cddopcao,
            innivris: innivris,
			redirect: "script_ajax"
		}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","blockBackground(parseInt($('#divTela').css('z-index')))");
		},
		success : function(response) {
			hideMsgAguardo();
			try { 
				$('#fieldListagem').html(response);
                formataGrid(cddopcao);
                selectAll();
				return false;
			} catch(error) {
				hideMsgAguardo();
				showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','unblockBackground()');
			}
		}
	});
}

/**
	Funcao responsavel para formatar a GRID
*/
function formataGrid(cddopcao){
    var divRegistro  = $('div.divRegistros','#frmCadris');
    var tabela       = $('table', divRegistro );
	var ordemInicial = new Array();
    var arrayLargura = new Array();
    var arrayAlinha  = new Array();

    divRegistro.css({'height':'120px'});
    
    // Se for exclusao
    if (cddopcao == 'E') {
        arrayLargura[0] = '15px';
        arrayLargura[1] = '150px';
    } else {
        arrayLargura[0] = '150px';
    }

    tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha, '' );

    // Se for exclusao
    if (cddopcao == 'E') {
		$("th:eq(0)", tabela).removeClass();
		$("th:eq(0)", tabela).unbind('click');
    // Se for consulta
    } else if (cddopcao == 'C') {
        // Seleciona primeiro
        selecionaRisco();
        // Carrega o registro clicado
        $('table > tbody > tr', divRegistro).click( function() {
            selecionaRisco();
        });
    }
}

/**
	Funcao responsavel para selecionar tudo ou nao
*/
function selectAll() {
    $("#select_all").change(function(){
        $(".clsCheckbox").prop('checked', $(this).prop("checked"));
    });
    return false;
}

/**
	Funcao responsavel para confirmar acao
*/
function confirmaAcao() {

    var cddopcao = $('#cddopcao','#frmCab').val();
    var nmfuncao = 'incluirRisco()';

    if (cddopcao == 'E') {
        var qtcheckado = $("[class='clsCheckbox']:checked").size();
        if (qtcheckado == 0) {
            showError('error','Nenhuma conta informada!', "Alerta - Ayllos", "$('#cddopcao','#frmCab').focus()");
            return false;
        } else {
            nmfuncao = 'excluirRisco()';
        }
    } else if (cddopcao == 'L') {
		nmfuncao = 'importarRisco()';
	}

    showConfirmacao('Confirma a opera&ccedil;&atilde;o?', 'Confirma&ccedil;&atilde;o - Ayllos', nmfuncao, '', 'sim.gif', 'nao.gif');
}

/**
	Funcao responsavel por excluir risco
*/
function excluirRisco() {
    var cddopcao 		  = $('#cddopcao','#frmCab').val();
    var nrdconta 		  = '';
	iCodigoNivelRisco     = $('#innivris','#frmCadris').val();

    $("[class='clsCheckbox']:checked").each(function () {
        nrdconta += (nrdconta == '' ? '' : '|') + normalizaNumero($(this).val());
    });

    showMsgAguardo("Aguarde, excluindo...");

    // Executa script de bloqueio através de ajax
	$.ajax({		
		type: "POST",
		url: UrlSite + "telas/cadris/manter_rotina.php", 
		data: {			
			cddopcao: cddopcao,
            nrdconta: nrdconta,
            innivris: iCodigoNivelRisco,
			redirect: "script_ajax"
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

/**
	Funcao responsavel por incluir risco
*/
function incluirRisco() {
    var cddopcao 	   = $('#cddopcao','#frmCab').val();    
    var nrdconta 	   = normalizaNumero($('#nrdconta','#frmCadris').val());
    var dsjustif 	   = $('#dsjustif','#frmCadris').val();
	iCodigoNivelRisco  = $('#innivris','#frmCadris').val();

    if (nrdconta == '') {
        showError('error','Conta n&atilde;o informada!', "Alerta - Ayllos", "$('#nrdconta','#frmCadris').focus()");
        return false;
    }

    showMsgAguardo("Aguarde, incluindo...");

    // Executa script de bloqueio através de ajax
	$.ajax({		
		type: "POST",
		url: UrlSite + "telas/cadris/manter_rotina.php", 
		data: {			
			cddopcao: cddopcao,
            nrdconta: nrdconta,
            innivris: iCodigoNivelRisco,
            dsjustif: dsjustif,
			redirect: "script_ajax"
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

/**
	Funcao responsavel por carregar a justificativa no campo
*/
function selecionaRisco() {
    // Limpa o campo
    $('#dsjustificativa','#fieldJustificativa').val('');
    // Verifica o clicado
    $('table > tbody > tr', 'div.divRegistros').each( function() {
		if ( $(this).hasClass('corSelecao') ) {
            $('#dsjustificativa','#fieldJustificativa').val($('#hdn_dsjustif',  $(this)).val());
		}
	});
	return false;
}

function resetCodigoNivelRisco(){
	iCodigoNivelRisco = 2;
}

/**
	Funcao responsavel por importar arquivo de risco
*/
function importarRisco() {
    var cddopcao 		  = $('#cddopcao','#frmCab').val();
    var nmdarqui 		  = $('#nmdarqui','#frmCadrisArquivo').val();
	
    showMsgAguardo("Aguarde, importando...");

    // Executa script de bloqueio através de ajax
	$.ajax({		
		type: "POST",
		url: UrlSite + "telas/cadris/manter_rotina.php", 
		data: {			
			cddopcao: cddopcao,
            nmdarqui: nmdarqui,
			redirect: "script_ajax"
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