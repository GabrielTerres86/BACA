/*!
 * FONTE        : IMUNE.php
 * CRIAÇÃO      : André Santos / SUPERO
 * DATA CRIAÇÃO : 23/08/2013
 * OBJETIVO     : Mostrar tela IMUNE
 * --------------
 * ALTERAÇÕES   : 31/10/2013 - Incluir cddopcao como parametro na manter_rotina,
							   atualiza_dados e imprimir_dados (Lucas R.)
 *
 * --------------
 */

// Definição de algumas variáveis globais
var cddopcao	= 'C';
var nmprimtl 	=  '';
var dsdentid	=  '';
var dtrefini    =  '';
var dtreffim    =  '';
var cdagenci    =   0;
var tprelimt    =   1;
var dscancel    =  '';
var nrcpfcgc ;
var valorBase   = 0;

//Formulários
var frmCab   	= 'frmCab';
var tabDados	= 'tabImune';
var frmImpri    = 'frmCabImp';

//Labels/Campos do Cabeçalho
var rCddopcao, rNrcpfcgc, rNmprimtl, rDsdentid, rCdsitcad, rDtdaprov, rDscancel, rNmoperad,
	cCddopcao, cNrcpfcgc, cNmprimtl, cDsdentid, cCdsitcad, cDtdaprov, cDscancel, cNmoperad, cTodosCabecalho, btnCab;

// Labels/Campos do Cabecalho de Impressao
var rDtrefini, rDtreffim, rTprelimt, rCdagenci,
    cDtrefini, cDtreffim, cTprelimt, cCdagenci;

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
    cNrcpfcgc.val( nrcpfcgc );
    cNmprimtl.val( nmprimtl );
    cDsdentid.val( dsdentid );

    // Desabilita Campos do Cabecalho Inicial
	$('#nrcpfcgc','#'+frmCab).desabilitaCampo();
    $('#nmprimtl','#'+frmCab).desabilitaCampo();
    $('#dsdentid','#'+frmCab).desabilitaCampo();

	$('input,select','#'+frmCab).removeClass('campoErro');
    controlaFoco();
}

function estadoInicialImpressao() {

    // Desabilita frmCab
    $('#'+frmCab).css({'display':'none'});

    // Ajusta form de Impressao
    $('#'+frmImpri).css({'display':'block'});
    $('#divBotoes','#divTela').css({'display':'block'});
    formataCabImpres();

    trocaBotao('btnImprimir()','Imprimir');

    $('#cddopcao','#'+frmImpri).desabilitaCampo();

    // Inicializa Variaveis
    $('#tprelimt','#'+frmImpri).habilitaCampo();
    $('#tprelimt','#'+frmImpri).focus();
    $('#cdagenci','#'+frmImpri).desabilitaCampo();
    $('#dtrefini','#'+frmImpri).habilitaCampo();
    $('#tprelimt','#'+frmImpri).habilitaCampo();
    $('#dtreffim','#'+frmImpri).habilitaCampo();
    $('#cdsitcad','#'+frmImpri).habilitaCampo();
    cTprelimt.val( tprelimt );
    cCdagenci.val( cdagenci );
    cDtrefini.val( dtrefini );
    cDtreffim.val( dtreffim );

	$('input,select','#'+frmCab).removeClass('campoErro');
    controlaFocoImpressao();
}

function formataCabecalho() {
	// Labels
	rCddopcao			= $('label[for="cddopcao"]','#'+frmCab);
	rNrcpfcgc			= $('label[for="nrcpfcgc"]','#'+frmCab);
    rNmprimtl			= $('label[for="nmprimtl"]','#'+frmCab);
    rDsdentid			= $('label[for="dsdentid"]','#'+frmCab);

    // Campos
	cCddopcao			= $('#cddopcao','#'+frmCab);
	cNrcpfcgc			= $('#nrcpfcgc','#'+frmCab);
    cNmprimtl			= $('#nmprimtl','#'+frmCab);
    cDsdentid			= $('#dsdentid','#'+frmCab);
    cTodosCabecalho		= $('input[type="text"],select','#'+frmCab);
	btnCab				= $('#btOK','#'+frmCab);

	//Rótulos
	rCddopcao.css('width','79px');
    rNrcpfcgc.addClass('rotulo-linha').css({'width':'79px'});
    rNmprimtl.addClass('rotulo-linha').css({'width':'79px'});
    rDsdentid.css({'width':'80px'});

    // Campos
	cCddopcao.css({'width':'441px'});
    cNrcpfcgc.addClass('inteiro').css({'width':'118px'});
	cNmprimtl.css({'width':'354px'});
	cDsdentid.css({'width':'475px'});

    /*
	if ( $.browser.msie ) {
        cNrcpfcgc.css({'width':'115px'});
		cNmprimtl.css({'width':'395px'});
        cDsdentid.css({'width':'395px'});
	}*/

	layoutPadrao();
	return false;
}

function formataCabImpres() {
	// Labels
	rCddopcao			= $('label[for="cddopcao"]','#'+frmImpri);
    rTprelimt 			= $('label[for="tprelimt"]','#'+frmImpri);
    rCdagenci 			= $('label[for="cdagenci"]','#'+frmImpri);
    rDtrefini 			= $('label[for="dtrefini"]','#'+frmImpri);
    rDtreffim			= $('label[for="dtreffim"]','#'+frmImpri);
    rCdsitcad			= $('label[for="cdsitcad"]','#'+frmImpri);

    // Campos
	cCddopcao			= $('#cddopcao','#'+frmImpri);
    cTprelimt			= $('#tprelimt','#'+frmImpri);
    cCdagenci			= $('#cdagenci','#'+frmImpri);
	cDtrefini 			= $('#dtrefini','#'+frmImpri);
    cDtreffim			= $('#dtreffim','#'+frmImpri);
    cCdsitcad			= $('#cdsitcad','#'+frmImpri);
    btnCab				= $('#btnOK1','#'+frmImpri);

	//Rótulos
	rCddopcao.css('width','79px');
    rTprelimt.css('width','79px');
    rCdagenci.addClass('rotulo-linha').css('width','70px');
    rDtrefini.addClass('rotulo-linha').css('width','79px');
    rDtreffim.addClass('rotulo-linha').css('width','10px');
    rCdsitcad.addClass('rotulo-linha').css('width','100px');

    // Campos
	cCddopcao.css({'width':'441px'});
    cTprelimt.css({'width':'245px'});
    cCdagenci.addClass('inteiro').css({'width':'50px'});
    cDtrefini.addClass('data').css({'width':'100px'});
    cDtreffim.addClass('data').css({'width':'100px'});
    cCdsitcad.addClass('inteiro').css({'width':'125px'});

    /*
	if ( $.browser.msie ) {
        cNrcpfcgc.css({'width':'115px'});
		cNmprimtl.css({'width':'395px'});
        cDsdentid.css({'width':'395px'});
	}*/

	layoutPadrao();
	return false;
}

function controlaFoco() {

	$('#cddopcao','#'+frmCab).unbind('keypress').bind('keypress', function(e) {
        if ( e.keyCode == 9 || e.keyCode == 13 ) {
            $('#btnOK','#'+frmCab).focus(); // Botao OK Consultar
            return false;
        }
	});

	$('#btnOK','#'+frmCab).unbind('keypress').bind('keypress', function(e) {
        if ( e.keyCode == 9 || e.keyCode == 13 ) {
            $('#cddopcao','#'+frmCab).desabilitaCampo();
            $('#nrcpfcgc','#'+frmCab).habilitaCampo();

            // Verifica Opcao Escolhida
            if ($('#cddopcao','#'+frmCab).val() == 'R' ) {
                estadoInicialImpressao();
            } else if ($('#cddopcao','#'+frmCab).val() == 'C' ||
                       $('#cddopcao','#'+frmCab).val() == 'A' ) {
                trocaBotao('btnContinuar()','Prosseguir');
                $('#divBotoes', '#divTela').css({'display':'block'});
                $('#nrcpfcgc','#'+frmCab).focus();
            }
            return false;
        }
	});

	$('#nrcpfcgc','#'+frmCab).unbind('keypress').bind('keypress', function(e) {
			if ( e.keyCode == 9 || e.keyCode == 13 ) {
				$('#nrcpfcgc','#'+frmCab).setMask('INTEGER','zz.zzz.zzz/zzzz-zz','/.-','');
                btnContinuar();
                return false;
			}
	});

    $('#btSalvar','#divBotoes').unbind('keypress').bind('keypress', function(e) {
        if ( e.keyCode == 9 || e.keyCode == 13 ) {
            return false;
        }
	});

	$('#btSalvar','#divBotoes').unbind('click').bind('click', function(){
        return false;
	});
}

function controlaFocoImpressao() {

    $('#btnOK1','#'+frmImpri).unbind('keypress').bind('keypress', function(e) {
        if ( e.keyCode == 9 || e.keyCode == 13 ) {
            $('#tprelimt','#'+frmImpri).habilitaCampo();
            $('#tprelimt','#'+frmImpri).focus();
            return false;
        }
	});

    $('#btnOK1','#'+frmImpri).unbind('click').bind('click', function(){
			$('#tprelimt','#'+frmImpri).habilitaCampo();
            $('#tprelimt','#'+frmImpri).focus();
			return false;

	});

    $('#tprelimt','#'+frmImpri).unbind('keypress').bind('keypress', function(e) {
			if ( e.keyCode == 9 || e.keyCode == 13 ) {
				if ($('#tprelimt','#'+frmImpri).val() == 1) {
                    cCdagenci.val( cdagenci );
                    $('#cdagenci','#'+frmImpri).desabilitaCampo();
                    $('#dtrefini','#'+frmImpri).habilitaCampo();
                    $('#dtreffim','#'+frmImpri).habilitaCampo();
                    $('#dtrefini','#'+frmImpri).focus();
                }else {
                    $('#cdagenci','#'+frmImpri).habilitaCampo();
                    $('#cdagenci','#'+frmImpri).focus();
                    $('#dtrefini','#'+frmImpri).habilitaCampo();
                    $('#dtreffim','#'+frmImpri).habilitaCampo();
                }
                return false;
			}
	});

	$('#tprelimt','#'+frmImpri).unbind('change').bind('change', function() {
        if ($('#tprelimt','#'+frmImpri).val() == 1) {
            cCdagenci.val( cdagenci );
            $('#cdagenci','#'+frmImpri).desabilitaCampo();
            $('#dtrefini','#'+frmImpri).habilitaCampo();
            $('#dtreffim','#'+frmImpri).habilitaCampo();
            $('#dtrefini','#'+frmImpri).focus();
        }else {
            $('#cdagenci','#'+frmImpri).habilitaCampo();
            $('#cdagenci','#'+frmImpri).focus();
            $('#dtrefini','#'+frmImpri).habilitaCampo();
            $('#dtreffim','#'+frmImpri).habilitaCampo();
        }
        return false;
    });

    $('#cdagenci','#'+frmImpri).unbind('keypress').bind('keypress', function(e) {
			if ( e.keyCode == 9 || e.keyCode == 13 ) {
				$('#dtrefini','#'+frmImpri).focus();
                return false;
			}
	});

    $('#dtrefini','#'+frmImpri).unbind('keypress').bind('keypress', function(e) {
            if ( e.keyCode == 9 || e.keyCode == 13 ) {
				$('#dtreffim','#'+frmImpri).focus();
                return false;
			}
	});

    $('#dtrefini','#'+frmImpri).unbind('keypress').bind('keypress', function(e) {
			if ( e.keyCode == 9 || e.keyCode == 13 ) {
				$('#dtreffim','#'+frmImpri).focus();
                return false;
			}
	});

    $('#dtreffim','#'+frmImpri).unbind('keypress').bind('keypress', function(e) {
			if ( e.keyCode == 9 || e.keyCode == 13 ) {
				$('#cdsitcad','#'+frmImpri).focus();
                return false;
			}
	});

    $('#cdsitcad','#'+frmImpri).unbind('keypress').bind('keypress', function(e) {
			if ( e.keyCode == 9 || e.keyCode == 13 ) {
				btnImprimir();
                return false;
			}
	});

    $('#btSalvar','#divBotoes').unbind('keypress').bind('keypress', function(e) {
        if ( e.keyCode == 9 || e.keyCode == 13 ) {
            btnImprimir();
            return false;
        }
	});

    $('#btSalvar','#divBotoes').unbind('click').bind('click', function(){
        return false;
	});
}

// Controle de Botoes
function trocaBotao( funcao , botao ) {
	$('#divBotoes','#divTela').html('');
	$('#divBotoes','#divTela').append('<a href="#" class="botao" id="btVoltar" onclick="btnVoltar(); return false;" >Voltar</a>&nbsp;');

	if (botao != '') {
		$('#divBotoes','#divTela').append('<a href="#" class="botao" id="btSalvar" onclick="' + funcao + '; return false;" >' + botao + '</a>');
	}
	return false;
}

// Botoes
function btnVoltar() {
    $('#'+frmImpri).css({'display':'none'});
    $('#divResultado').css({'display':'none'});
    $('#divPesquisaRodape').remove();
    estadoInicial();
	return false;
}

function btnContinuar() {
    buscaImunidade();

    if ($('#cddopcao','#'+frmCab).val() == 'A') {
        trocaBotao('btnAtualizar()','Alterar');
    }
    return false;
}

function btnAtualizar() {
    atualizaImunidade();
    return false;
}

function btnImprimir() {
    geraImpressao();
    return false;
}

// Consulta Imunidade
function buscaImunidade() {
    // Remover os caracteres da mascara de CNPJ
    var nrcpfcgc = $('#nrcpfcgc','#'+frmCab).val().replace(".", "").replace("/", "").replace("-", "").replace(".", "");

	showMsgAguardo("Aguarde, listando imunidade...");

    $.ajax({
    type	: 'POST',
    url		: UrlSite + 'telas/imune/manter_rotina.php',
    dataType: 'html',
    data    :
            {
				cddopcao : $('#cddopcao','#'+frmCab).val(),
				nrcpfcgc : nrcpfcgc,
                redirect : 'script_ajax'
            },
    error   : function(objAjax,responseError,objExcept) {
                hideMsgAguardo();
                showError('error','N&atilde;o foi possível concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','estadoInicial();');
            },
    success : function(response) {
        hideMsgAguardo();
        try {
            if ( response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1 ) {
                try {
                    $('input,select','#'+frmCab).removeClass('campoErro');
                    if ($('#cddopcao','#'+frmCab).val() == 'C') {
                        $('#btSalvar').remove();
                    }
                    $('#divResultado').html(response);
                    formataTabela();
					formataDetalhes( $('#cddopcao','#'+frmCab).val() );
                    if ($('#cddopcao','#'+frmCab).val() == 'A') {
                        guardaValor(true);
                        $('#cdsitcad','#frmDados').focus();
                        valor = $('#cdsitcad','#frmDados').val();
                        liberaCampoDescricao(valor);
                    }
                } catch(error) {
                    hideMsgAguardo();
                    showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','');
                }
            } else {
                try {
                    eval(response);
                    return false;
                } catch(error) {
                    hideMsgAguardo();
                    showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','estadoInicial();');
                }
            }
        } catch(error) {
            showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message,"Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
            hideMsgAguardo();
        }
    }
    });
    return false;
}

// Alterar Imunidade
function atualizaImunidade() {
    var nrcpfcgc = $('#nrcpfcgc','#'+frmCab).val().replace(".", "").replace("/", "").replace("-", "").replace(".", "");
    var cdsitcad = $('#cdsitcad','#frmDados').val();
    var dscancel = $('#dscancel','#frmDados').val();

    showMsgAguardo("Aguarde, atualizando imunidade...");

    $.ajax({
    type	: 'POST',
    url		: UrlSite + 'telas/imune/atualiza_dados.php',
    dataType: 'html',
    data    :
            {
                nrcpfcgc : nrcpfcgc,
                cdsitcad : cdsitcad,
                dscancel : dscancel,
				cddopcao : $('#cddopcao','#'+frmCab).val(),
                redirect : 'script_ajax'
            },
    error   : function(objAjax,responseError,objExcept) {
                hideMsgAguardo();
                showError('error','N&atilde;o foi possível concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','estadoInicial();');
            },
    success : function(response) {
        hideMsgAguardo();
            try {
                if ( response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1 ) {
                    try {
                        $('input,select','#'+frmCab).removeClass('campoErro');
                        showError('inform','Registro atualizado com sucesso','Alerta - Ayllos','btnVoltar();');
                    } catch(error) {
                        hideMsgAguardo();
                        showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','');
                    }
                } else {
                    try {
                        eval(response);
                        cDscancel.val('');
                        return false;
                    } catch(error) {
                        hideMsgAguardo();
                        showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','estadoInicial();');
                    }
                }
            } catch(error) {
                showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message,"Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
                hideMsgAguardo();
            }
        }
    });
    return false;
}

// Imprimir Imunidade

function geraImpressao() {

    var tprelimt = $('#tprelimt','#'+frmImpri).val();
    var cdagenci = $('#cdagenci','#'+frmImpri).val();
    var dtrefini = $('#dtrefini','#'+frmImpri).val();
    var dtreffim = $('#dtreffim','#'+frmImpri).val();
    var cdsitcad = $('#cdsitcad','#'+frmImpri).val();
	var cddopcao = $('#cddopcao','#'+frmImpri).val();

    var dtArrIni    = dtrefini.split('/');
    var dtArrFim    = dtreffim.split('/');
    var cmpDtinicio = parseInt(dtArrIni[2] + dtArrIni[1] + dtArrIni[0]);
    var cmpDttermin = parseInt(dtArrFim[2] + dtArrFim[1] + dtArrFim[0]);


	if ( (dtrefini == "") || (dtreffim == "") ) {
			showError('error','Data Inicial e Final devem ser informadas para pesquisa!','Alerta - Ayllos','focaCampoErro(\'dtrefini\',\''+ frmCab +'\');');
			return false;
	}
	if ( cmpDtinicio > cmpDttermin ) {
			showError('error','Data Inicial superior a Data Final!','Alerta - Ayllos','focaCampoErro(\'dtrefini\',\''+ frmCab +'\');');
			return false;
	}

	$('input,select','#'+frmCab).removeClass('campoErro');

    $('#tprelimt', '#frmImprimir').val( tprelimt );
    $('#cdagenci', '#frmImprimir').val( cdagenci );
	$('#dtrefini', '#frmImprimir').val( dtrefini );
	$('#dtreffim', '#frmImprimir').val( dtreffim );
	$('#cdsitcad', '#frmImprimir').val( cdsitcad );
	$('#cddopcao', '#frmImprimir').val( cddopcao );

    var action = UrlSite + 'telas/imune/imprimir_dados.php';

	carregaImpressaoAyllos("frmImprimir",action);

}

function formataDetalhes( opcao ) {

    // Rótulo
    rCdsitcad			= $('label[for="cdsitcad"]','#frmDados');
    rDtdaprov			= $('label[for="dtdaprov"]','#frmDados');
    rDscancel           = $('label[for="dscancel"]','#frmDados');
    rNmoperad           = $('label[for="nmoperad"]','#frmDados');

    // Campos
    cCdsitcad			= $('#cdsitcad','#frmDados');
    cDtdaprov			= $('#dtdaprov','#frmDados');
    cDscancel           = $('#dscancel','#frmDados');
    cNmoperad           = $('#nmoperad','#frmDados');

    rCdsitcad.addClass('rotulo-linha').css({'width':'100px'});
    rDtdaprov.addClass('rotulo-linha').css({'width':'80px'});
    rDscancel.addClass('rotulo-linha').css({'width':'100px'});
    rNmoperad.addClass('rotulo-linha').css({'width':'80px'});

    cCdsitcad.addClass('campo').css({'width':'210px'});
    cDtdaprov.addClass('campo data').css({'width':'75px'});
    cDscancel.addClass('campo').css({'width':'210px'}).attr('maxlength','33');
    cNmoperad.addClass('campo').css({'width':'108px'});

    // Desabilta Campos
    $('#dtdaprov','#frmDados').desabilitaCampo();
    $('#nmoperad','#frmDados').desabilitaCampo();

    if (opcao == 'C') {
        $('#cdsitcad','#frmDados').desabilitaCampo();
        $('#dscancel','#frmDados').desabilitaCampo();
    } else if (opcao == 'A') {
        $('#cdsitcad','#frmDados').habilitaCampo();
        $('#dscancel','#frmDados').desabilitaCampo();
    };

	return false;
}

function guardaValor(opcao){
    if (opcao == true){
       valorBase = $('#cdsitcad','#frmDados').val();
    }
}

function liberaCampoDescricao(valor) {

    if  (valor == 2) {
        $('#dscancel','#frmDados').habilitaCampo();
        $('#dscancel','#frmDados').focus();
    }else {
        $('#dscancel','#frmDados').desabilitaCampo();
        $('#dscancel','#frmDados').val( dscancel );
    }
    return false;
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
    divRegistro.css({'height':'150px','padding-bottom':'2px'});

	var ordemInicial = new Array();

	var arrayLargura = new Array();
	arrayLargura[0] = '40px';
	arrayLargura[1] = '80px';

	/*if ( $.browser.msie ) {
		arrayLargura[0] = '50px';
        arrayLargura[1] = '73px';
        arrayLargura[2] = '70px';
	}*/

	var arrayAlinha = new Array();
        arrayAlinha[0] = 'center';
        arrayAlinha[1] = 'center';
        arrayAlinha[2] = 'lefth';

    cNmprimtl.val( $('#nmprimtl','#tabImune').val() );
    cDsdentid.val( $('#cddentid','#tabImune').val() + ' - ' + $('#dsdentid','#tabImune').val() );


    tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha, '' );

    //$('table', tabela).removeClass();
    //$('th', tabela).unbind('click');
    //$('.headerSort', tabela).removeClass();
    
    //$('table > thead > tr > th', 'tabImune').unbind('click');
    //$('table > thead > tr > th.headerSort', 'tabImune').removeClass();
    //$('table', 'tabImune').unbind('click');

	hideMsgAguardo();

    return false;
}

function LiberaCampos() {

    if ( $('#cddopcao','#frmCab').hasClass('campoTelaSemBorda')  ) { return false; }

    $('#cddopcao','#'+frmCab).desabilitaCampo();
    $('#divBotoes', '#divTela').css({'display':'block'});
    $('#nrcpfcgc','#'+frmCab).habilitaCampo();

    // Verifica Opcao Escolhida
    if ($('#cddopcao','#'+frmCab).val() == 'R' ) {
        estadoInicialImpressao();
    } else if ($('#cddopcao','#'+frmCab).val() == 'C' ||
               $('#cddopcao','#'+frmCab).val() == 'A' ) {
        trocaBotao('btnContinuar()','Prosseguir');
    }

    $('#divBotoes', '#divTela').css({'display':'block'});
    $('#nrcpfcgc','#'+frmCab).focus();

    $('#divBotoes', '#divTela').css({'display':'block'});
    $('#nrcpfcgc','#'+frmCab).focus();
	return false;
}

function LiberaCamposImpressao() {

    if ( $('#cddopcao','#'+frmImpri).hasClass('campoTelaSemBorda')  ) { return false; }
    $('#divBotoes', '#divTela').css({'display':'block'});

    $('#tprelimt','#'+frmImpri).habilitaCampo();
    $('#tprelimt','#'+frmImpri).focus();

    return false;
}