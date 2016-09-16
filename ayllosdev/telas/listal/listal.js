/*!
 * FONTE        : LISTAL.php
 * CRIAÇÃO      : André Euzébio / SUPERO
 * DATA CRIAÇÃO : 16/08/2013
 * OBJETIVO     : Mostrar tela LISTAL
 * --------------
 * ALTERAÇÕES   :
 *
 * --------------
 */

// Definição de algumas variáveis globais
var cddopcao	= 'T';
var cdcooper    =  0 ;
var insitreq    =  2 ;
var tprequis    =  5 ;
var cddotipo	= 'X';
var dtinicio	= '' ;
var dttermin	= '' ;

//Formulários
var frmCab   	= 'frmCab';
var tabDados	= 'tabListal';

//Labels/Campos do cabeçalho
var rcddopcao, rCddotipo, rDtinicio, rDttermin, rCdcooper, rInsitreq, rTprequis,
	ccddopcao, cCddotipo, cDtinicio, cDttermin, cCdcooper, cInsitreq, cTprequis,
	cTodosCabecalho, btnCab;

function dataString(vData) {

    var dtArray = vData.split('/');

    switch (dtArray[1]) {
    case "1":
    case "2":
    case "3":
    case "4":
    case "5":
    case "6":
    case "7":
    case "8":
    case "9":
        vMes = "0" + (dtArray[1]);
        break;
    default:
        vMes = dtArray[1];
    }

    return dtArray[0] + "/" + vMes + "/" + dtArray[2];
}

function buscaUltimoDia(vMes){

    var today = new Date();
    var lastDayOfMonth = new Date(today.getFullYear(), vMes + 1 , 0);
    var vUltimoDia = lastDayOfMonth.getDate();

    return vUltimoDia;
}

// Inicio
$(document).ready(function() {
	estadoInicial();
	highlightObjFocus( $('#'+frmCab) );
    return false;
});

// Seletores
function estadoInicial() {

    // Preparando a Tela
    hideMsgAguardo();
    unblockBackground();
    removeOpacidade('divTela');
	formataCabecalho();

	$('#'+frmCab).css({'display':'block'});
    $('#divBotoes','#divTela').css({'display':'none'});
    $('#divPesquisaRodape').remove();

    // Inicializa Variaveis do Cabeçalho
    cCddopcao.val( cddopcao );
	$('#cddopcao','#'+frmCab).habilitaCampo();
    $('#cddopcao','#'+frmCab).focus();
	cCdcooper.val( cdcooper );
    cInsitreq.val( insitreq );
	cTprequis.val( tprequis );
    cDtinicio.val( dtinicio );
    cDttermin.val( dttermin );


    setaDatasTela();

    // Desabilita Campos
    //$('#cddopcao','#'+frmCab).desabilitaCampo();
	$('#cdcooper','#'+frmCab).desabilitaCampo();
	$('#insitreq','#'+frmCab).desabilitaCampo();
	$('#tprequis','#'+frmCab).desabilitaCampo();
    $('#dtinicio','#'+frmCab).desabilitaCampo();
    $('#dttermin','#'+frmCab).desabilitaCampo();

	$('input,select','#'+frmCab).removeClass('campoErro');
    controlaFoco();
}

function formataCabecalho() {

	// Labels
	rCddopcao			= $('label[for="cddopcao"]','#'+frmCab);
	rCdcooper			= $('label[for="cdcooper"]','#'+frmCab);
	rInsitreq           = $('label[for="insitreq"]','#'+frmCab);
	rTprequis           = $('label[for="tprequis"]','#'+frmCab);
	rDtinicio			= $('label[for="dtinicio"]','#'+frmCab);
    rDttermin			= $('label[for="dttermin"]','#'+frmCab);


    // Campos
	cCddopcao			= $('#cddopcao','#'+frmCab);
    cCdcooper			= $('#cdcooper','#'+frmCab);
	cInsitreq           = $('#insitreq','#'+frmCab);
	cTprequis           = $('#tprequis','#'+frmCab);
    cDtinicio			= $('#dtinicio','#'+frmCab);
    cDttermin			= $('#dttermin','#'+frmCab);


	cTodosCabecalho		= $('input[type="text"],select','#'+frmCab);
	btnCab				= $('#btOK','#'+frmCab);

	//Rótulos
	rCddopcao.css('width','150px');
	rCdcooper.css('width','150px');
	rInsitreq.css('width','150px');
	rTprequis.css('width','150px');
	rDtinicio.addClass('rotulo-linha').css({'width':'150px'});
	rDttermin.addClass('rotulo-linha').css({'width':'10px'});

    // Campos
	cCddopcao.css({'width':'300px'});
	cCdcooper.css({'width':'151px'});
	cInsitreq.css({'width':'151px'});
	cTprequis.css({'width':'151px'});
	cDtinicio.addClass('rotulo-linha').css({'width':'90px'});
	cDtinicio.addClass('data').css({'width':'75px'});
	cDttermin.addClass('rotulo-linha').css({'width':'90px'});
	cDttermin.addClass('data').css({'width':'75px'});

	if ( $.browser.msie ) {

	    rCddopcao.css('width','150px');
		rCdcooper.css('width','150px');
		rInsitreq.css('width','150px');
		rTprequis.css('width','150px');
		rDtinicio.addClass('rotulo-linha').css({'width':'150px'});
		rDttermin.addClass('rotulo-linha').css({'width':'10px'});

        cCddopcao.css({'width':'300px'});
		cCdcooper.css({'width':'151px'});
		cInsitreq.css({'width':'151px'});
		cTprequis.css({'width':'151px'});
		cDtinicio.addClass('rotulo-linha').css({'width':'80px'});
		cDtinicio.addClass('data').css({'width':'70px'});
		cDttermin.addClass('rotulo-linha').css({'width':'80px'});
		cDttermin.addClass('data').css({'width':'70px'});
	}

	layoutPadrao();
	return false;
}

function controlaFoco() {

	$('#cddopcao','#'+frmCab).unbind('keypress').bind('keypress', function(e) {
			if ( e.keyCode == 9 || e.keyCode == 13 ) {
				$('#btnOK','#'+frmCab).focus();
				return false;
			}
	});

	$('#btnOK','#'+frmCab).unbind('keypress').bind('keypress', function(e) {
			if ( e.keyCode == 9 || e.keyCode == 13 ) {
                $('#cddopcao','#'+frmCab).desabilitaCampo();
				$('#cdcooper','#'+frmCab).habilitaCampo();
				$('#insitreq','#'+frmCab).habilitaCampo();
				$('#tprequis','#'+frmCab).habilitaCampo();
                $('#dtinicio','#'+frmCab).habilitaCampo();
                $('#dttermin','#'+frmCab).habilitaCampo();

                if ($('#cddopcao','#'+frmCab).val() == 'I' ) {
                    trocaBotao('Imprimir');
                } else {
                    trocaBotao('Prosseguir');
                }

                $('#divBotoes', '#divTela').css({'display':'block'});
                $('#cdcooper','#'+frmCab).focus();
				return false;
			}
	});

	$('#cdcooper','#'+frmCab).unbind('keypress').bind('keypress', function(e) {
            $('#btnOK'   ,'#'+frmCab).hide();
			if ( e.keyCode == 9 || e.keyCode == 13 ) {
				$('#insitreq','#'+frmCab).focus();
                return false;
			}
	});

	$('#insitreq','#'+frmCab).unbind('keypress').bind('keypress', function(e) {
			if ( e.keyCode == 9 || e.keyCode == 13 ) {
				$('#tprequis','#'+frmCab).focus();
                return false;
			}
	});

    $('#tprequis','#'+frmCab).unbind('keypress').bind('keypress', function(e) {
			if ( e.keyCode == 9 || e.keyCode == 13 ) {
                $('#dtinicio','#'+frmCab).focus();
                return false;
			}
	});

    $('#dtinicio','#'+frmCab).unbind('keypress').bind('keypress', function(e) {
			if ( e.keyCode == 9 || e.keyCode == 13 ) {
                $('#dttermin','#'+frmCab).focus();
                return false;
			}
	});

    $('#dttermin','#'+frmCab).unbind('keypress').bind('keypress', function(e) {
			if ( e.keyCode == 9 || e.keyCode == 13 ) {
                $('#btSalvar','#divBotoes').focus();
                return false;
			}
	});

}

function setaDatasTela() {

    var dtHoje  = new Date();
    dtIniPer 	=  dataString("01/" + (dtHoje.getMonth() + 1)  + "/" + dtHoje.getFullYear());
    dtFimPer 	=  dataString(buscaUltimoDia(dtHoje.getMonth()) + "/" + (dtHoje.getMonth() + 1) + "/" + dtHoje.getFullYear());

    $('#dtinicio','#frmCab').val(dtIniPer);
    $('#dttermin','#frmCab').val(dtFimPer);
	return false;
}

// Controle de Botoes
function trocaBotao( botao ) {
	$('#divBotoes','#divTela').html('');
	$('#divBotoes','#divTela').append('<a href="#" class="botao" id="btVoltar" onclick="btnVoltar(); return false;" >Voltar</a>&nbsp;');

	if (botao != '') {
		$('#divBotoes','#divTela').append('<a href="#" class="botao" id="btSalvar" onclick="btnContinuar(); return false;" >' + botao + '</a>');
	}
	return false;
}

// Botoes
function btnVoltar() {
    $('#divResultado').css({'display':'none'});
    //$('#divPesquisaRodape').remove();
    estadoInicial();
	return false;
}

function LiberaCampos() {
    cTodosCabecalho.habilitaCampo();
    return false;
}

function btnContinuar() {

 	var cddopcao = $('#cddopcao','#'+frmCab).val();
    var cdcooper = $('#cdcooper','#'+frmCab).val();
    var insitreq = $('#insitreq','#'+frmCab).val();
    var tprequis = $('#tprequis','#'+frmCab).val();
	var dtinicio = $('#dtinicio','#'+frmCab).val();
	var dttermin = $('#dttermin','#'+frmCab).val();

    var dtArrIni    = dtinicio.split('/');
    var dtArrFim    = dttermin.split('/');
    var cmpDtinicio = parseInt(dtArrIni[2] + dtArrIni[1] + dtArrIni[0]);
    var cmpDttermin = parseInt(dtArrFim[2] + dtArrFim[1] + dtArrFim[0]);


	if ( (dtinicio == "") || (dttermin == "") ) {
			showError('error','Data Inicial e Final devem ser informadas para pesquisa!','Alerta - Ayllos','focaCampoErro(\'dtinicio\',\''+ frmCab +'\');');
			return false;
	}
	if ( cmpDtinicio > cmpDttermin ) {
			showError('error','Data Inicial superior a Data Final!','Alerta - Ayllos','focaCampoErro(\'dtinicio\',\''+ frmCab +'\');');
			return false;
	}

    $('input,select','#'+frmCab).removeClass('campoErro');
    showMsgAguardo("Aguarde, buscando dados... ");

    if (cddopcao == 'T') {
       $.ajax({
        type	: 'POST',
        url		: UrlSite + 'telas/listal/manter_rotina.php',
        dataType: 'html',
        data    :
                {
                    cddopcao : cddopcao,
                    cdcooper : cdcooper,
                    insitreq : insitreq,
                    tprequis : tprequis,
                    dtinicio : dtinicio,
                    dttermin : dttermin,
                    redirect : 'script_ajax'
                },
        error   : function(objAjax,responseError,objExcept) {
                    hideMsgAguardo();
                    showError('error','N&atilde;o foi possível concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','estadoInicial();');
                },
        success : function(response) {
            hideMsgAguardo();
            try {
                //
				if ( response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1 ) {
						try {
							$('#divResultado').html(response);
							formataTabela();
							//LiberaCampos();
							return false;
						} catch(error) {
							hideMsgAguardo();
							showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','');
						}
					} else {
						try {
						    eval( response );
						} catch(error) {
							hideMsgAguardo();
							showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','estadoInicial();');
						}
					}
                hideMsgAguardo();

			} catch(error) {
				hideMsgAguardo();
				showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message,"Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
            }
        }
      });
    }else {
        Gera_Impressao();
    }
    return false;
}

// imprimir
function Gera_Impressao() {

    var cddopcao = $('#cddopcao','#'+frmCab).val();
    var cdcooper = $('#cdcooper','#'+frmCab).val();
    var insitreq = $('#insitreq','#'+frmCab).val();
    var tprequis = $('#tprequis','#'+frmCab).val();
	var dtinicio = $('#dtinicio','#'+frmCab).val();
	var dttermin = $('#dttermin','#'+frmCab).val();


	$('#cddopcao', '#frmImprimir').val( cddopcao );
    $('#cdcooper', '#frmImprimir').val( cdcooper );
    $('#insitreq', '#frmImprimir').val( insitreq );
    $('#tprequis', '#frmImprimir').val( tprequis );
	$('#dtinicio', '#frmImprimir').val( dtinicio );
	$('#dttermin', '#frmImprimir').val( dttermin );

	var action = UrlSite + 'telas/listal/imprimir_dados.php';
	cTodosCabecalho.habilitaCampo();

	carregaImpressaoAyllos("frmImprimir",action);

}

function formataTabela() {
	// Tabela
    $('input[type="text"],select','#'+frmCab).desabilitaCampo();
    btnCab.desabilitaCampo();
    $('#divResultado').css({'display':'block'});

    var divRegistro = $('div.divRegistros', '#'+tabDados);
	var tabela      = $('table', divRegistro );
	var linha       = $('table > tbody > tr', divRegistro );

    $('#'+tabDados).css({'margin-top':'5px'});
	divRegistro.css({'height':'285px','padding-bottom':'2px'});

	var ordemInicial = new Array();

	var arrayLargura = new Array();
	arrayLargura[0] = '120px';
	arrayLargura[1] = '118px';
	arrayLargura[2] = '125px';

    /*
	if ( $.browser.msie ) {
		arrayLargura[0] = '50px';
        arrayLargura[1] = '73px';
        arrayLargura[2] = '70px';
	}
    */

	var arrayAlinha = new Array();
        arrayAlinha[0] = 'left';
        arrayAlinha[1] = 'center';
        arrayAlinha[2] = 'center';

	tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha, '' );
    $("th", tabela).removeClass();
    $("th", tabela).unbind('click');

	$('.headerSort','#tabListal').removeClass(); /* Daniel */

	hideMsgAguardo();


	$('#btSalvar', '#divBotoes').css({'display':'none'});
    return false;
}

function LiberaCampos(){
	$('#cddopcao','#'+frmCab).desabilitaCampo();
	$('#cdcooper','#'+frmCab).habilitaCampo();
	$('#insitreq','#'+frmCab).habilitaCampo();
	$('#tprequis ','#'+frmCab).habilitaCampo();
	$('#dtinicio','#'+frmCab).habilitaCampo();
	$('#dttermin','#'+frmCab).habilitaCampo();

	if ($('#cddopcao','#'+frmCab).val() == 'I' ) {
		trocaBotao('Imprimir');
	} else {
		trocaBotao('Prosseguir');
	}

	$('#divBotoes', '#divTela').css({'display':'block'});
	$('#cdcooper','#'+frmCab).focus();

}

