/*!
 * FONTE        : parest.js
 * CRIAÇÃO      : Daniel Zimmermann
 * DATA CRIAÇÃO : 24/03/2016
 * OBJETIVO     : Biblioteca de funções da tela PAREST
 * --------------
 * ALTERAÇÕES   :
 * --------------
 */

// Variáveis Globais 
var operacao = '';

var frmCab = 'frmCab';
var frmParest = 'frmParest';

var cTodosCabecalho = '';
var cTodosFiltro = '';

var alphaExp = /^[a-zA-Z0-9_]+$/;	

$(document).ready(function() {

    cTodosCabecalho = $('input[type="text"],select', '#' + frmCab);
    cTodosFiltro = $('input[type="text"],select', '#' + frmParest);

    estadoInicial();

});


// Controles
function estadoInicial() {

    // Variaveis Globais
    operacao = '';
	
	hideMsgAguardo();

    fechaRotina($('#divRotina'));

    // Limpa formularios
    cTodosCabecalho.limpaFormulario();
    cTodosFiltro.limpaFormulario();

    // habilita foco no formulário inicial
    highlightObjFocus($('#frmCab'));
	
	highlightObjFocus($('#frmParest'));

    // Aplicar Formatação
    controlaLayout();
	
    $('#cddopcao', '#frmCab').val('C'); 
    $('#tlcooper', '#frmCab').val('0');
	$('label[for="tlcooper"]', '#' + frmCab).hide();
	$('#tlcooper', '#' + frmCab).hide();
}

function controlaLayout() {

    $('#divTela').fadeTo(0, 0.1);
    $('fieldset').css({'clear': 'both', 'border': '1px solid #777', 'margin': '3px 0px', 'padding': '10px 3px 5px 3px'});
    $('fieldset > legend').css({'font-size': '11px', 'color': '#777', 'margin-left': '5px', 'padding': '0px 2px'});
    $('#divBotoes').css({'text-align': 'center', 'padding-top': '5px'});

    $('#frmParest').css({'display': 'none'});
    $('#divBotoes').css({'display': 'none'});
	$('#divAlteracao').css({'display': 'none'});

    // Retira html da tabela de resultado
    $('#divConsulta').html('');
	
    formataCabecalho();
    formataParametros();    
    controlaFoco();
	
	layoutPadrao();
    removeOpacidade('divTela');
    return false;

}

function formataCabecalho() {

    // Cabeçalho
    rCddopcao = $('label[for="cddopcao"]', '#' + frmCab);
    rTlcooper = $('label[for="tlcooper"]', '#' + frmCab);

	rCddopcao.css('width', '80px');
	rTlcooper.css('width', '100px');

    cCddopcao = $('#cddopcao', '#' + frmCab);
    cTlcooper = $('#tlcooper', '#' + frmCab);
	
    btnCab = $('#btOK', '#' + frmCab);

    cCddopcao.css({'width': '300px'});
	cTlcooper.css({'width': '100px'});

    cTodosCabecalho.habilitaCampo();

    $('#cddopcao', '#' + frmCab).focus();
	
	$('#cddopcao', '#' + frmCab).unbind('change').bind('change', function (e) {

	    if ($(this).val() == 'C') {
			rTlcooper.hide();
	        cTlcooper.hide();
	    } else {
	        rTlcooper.show();
	        cTlcooper.show();
	    }
	    return false;
	});
	
    return false;
}

function formataParametros() {

    rIncomite = $('label[for="incomite"]', '#' + frmParest);
    rContigen = $('label[for="contigen"]', '#' + frmParest);
    rAnlautom = $('label[for="anlautom"]', '#' + frmParest);
    rNmregmpf = $('label[for="nmregmpf"]', '#' + frmParest);
    rNmregmpj = $('label[for="nmregmpj"]', '#' + frmParest);
    rQtsstime = $('label[for="qtsstime"]', '#' + frmParest);
    rQtmeschq = $('label[for="qtmeschq"]', '#' + frmParest);
    rQtmeschqal11 = $('label[for="qtmeschqal11"]', '#' + frmParest);
    rQtmeschqal12 = $('label[for="qtmeschqal12"]', '#' + frmParest);
    rQtmesest = $('label[for="qtmesest"]', '#' + frmParest);
    rQtmesemp = $('label[for="qtmesemp"]', '#' + frmParest);

    rIncomite.css('width', '300px');
    rContigen.css('width', '300px');
    rAnlautom.css('width', '300px');
    rNmregmpf.css('width', '300px');
    rNmregmpj.css('width', '300px');
    rQtsstime.css('width', '300px');
    rQtmeschq.css('width', '300px');
    rQtmeschqal11.css('width', '120px');
    rQtmeschqal12.css('width', '120px');
    rQtmesest.css('width', '300px');
    rQtmesemp.css('width', '300px');

    cIncomite = $('#incomite', '#' + frmParest);
    cContigen = $('#contigen', '#' + frmParest);
    cAnlautom = $('#anlautom', '#' + frmParest);
    cNmregmpf = $('#nmregmpf', '#' + frmParest);
    cNmregmpj = $('#nmregmpj', '#' + frmParest);
    cQtsstime = $('#qtsstime', '#' + frmParest);
    cQtmeschq = $('#qtmeschq', '#' + frmParest);
    cQtmeschqal11 = $('#qtmeschqal11', '#' + frmParest);
    cQtmeschqal12 = $('#qtmeschqal12', '#' + frmParest);
    cQtmesest = $('#qtmesest', '#' + frmParest);
    cQtmesemp = $('#qtmesemp', '#' + frmParest);
    
    cNmregmpf.css('width', '300px').attr('maxlength', '250');	
    cNmregmpj.css('width', '300px').attr('maxlength', '250');	
    cQtsstime.addClass('inteiro').css('width', '48px');
    cQtmeschq.addClass('inteiro').css('width', '48px');
    cQtmeschqal11.addClass('inteiro').css('width', '48px');
    cQtmeschqal12.addClass('inteiro').css('width', '48px');
    cQtmesest.addClass('inteiro').css('width', '48px');
    cQtmesemp.addClass('inteiro').css('width', '48px');
    cQtsstime.attr('maxlength', '3');
    cQtmeschq.attr('maxlength', '2');
    cQtmeschqal11.attr('maxlength', '2');
    cQtmeschqal12.attr('maxlength', '2');
    cQtmesest.attr('maxlength', '2');
    cQtmesemp.attr('maxlength', '2');

    cTodosFiltro.habilitaCampo();
		
	layoutPadrao();
    return false;
}



function controlaFoco() {

    $('#cddopcao', '#frmCab').unbind('keypress').bind('keypress', function(e) {
        if (e.keyCode == 9 || e.keyCode == 13) {
			if ($(this).val() == 'C'){
				$('#btnOK', '#frmCab').focus();
			}else{
				$('#tlcooper', '#frmCab').focus();
			}
            return false;
        }
    });
	
	  $('#tlcooper', '#frmCab').unbind('keypress').bind('keypress', function(e) {
        if (e.keyCode == 9 || e.keyCode == 13) {
            $('#btnOK', '#frmCab').focus();
            return false;
        }
    });

    $('#btnOK', '#frmCab').unbind('keypress').bind('keypress', function(e) {
        if (e.keyCode == 9 || e.keyCode == 13) {
			
			controlaOperacao();
            return false;
        }
    });
	
	  $('#contigen', '#divAlteracao').unbind('keypress').bind('keypress', function(e) {
        if (e.keyCode == 9 || e.keyCode == 13) {
			if ($(this).val() == 0){
				$('#anlautom', '#divAlteracao').focus();
			}else{
				$('#incomite', '#divAlteracao').focus();
			}
            return false;
        }
    });
	
    $('#incomite', '#divAlteracao').unbind('keypress').bind('keypress', function(e) {
		if (e.keyCode == 9 || e.keyCode == 13) {
			$('#anlautom', '#divAlteracao').focus();
			return false;
		}
    });
	
    $('#anlautom', '#divAlteracao').unbind('keypress').bind('keypress', function(e) {
		if (e.keyCode == 9 || e.keyCode == 13) {
			$('#nmregmpf', '#divAlteracao').focus();
			return false;
		}
    });
	
	  $('#nmregmpf', '#divAlteracao').unbind('keypress').bind('keypress', function(e) {
        if (e.keyCode == 9 || e.keyCode == 13) {
			
			$('#nmregmpj', '#divAlteracao').focus();
            return false;
        }
    });
    
	
	$('#nmregmpj', '#divAlteracao').unbind('keypress').bind('keypress', function(e) {
        if (e.keyCode == 9 || e.keyCode == 13) {
			
			$('#qtsstime', '#divAlteracao').focus();
            return false;
        }
    });    

	$('#qtsstime', '#divAlteracao').unbind('keypress').bind('keypress', function(e) {
        if (e.keyCode == 9 || e.keyCode == 13) {
			
			$('#qtmeschq', '#divAlteracao').focus();			
            return false;
        }
    });
	
	$('#qtmeschq', '#divAlteracao').unbind('keypress').bind('keypress', function(e) {
        if (e.keyCode == 9 || e.keyCode == 13) {
			
			$('#qtmeschqal11', '#divAlteracao').focus();
            return false;
        }
    });
	
	$('#qtmeschqal11', '#divAlteracao').unbind('keypress').bind('keypress', function(e) {
        if (e.keyCode == 9 || e.keyCode == 13) {
			
			$('#qtmeschqal12', '#divAlteracao').focus();
            return false;
        }
    });
	$('#qtmeschqal12', '#divAlteracao').unbind('keypress').bind('keypress', function(e) {
        if (e.keyCode == 9 || e.keyCode == 13) {
			
			$('#qtmesest', '#divAlteracao').focus();
            return false;
        }
    });
	
	$('#qtmesest', '#divAlteracao').unbind('keypress').bind('keypress', function(e) {
        if (e.keyCode == 9 || e.keyCode == 13) {
			
			$('#qtmesemp', '#divAlteracao').focus();
            return false;
        }
    });
	
	$('#qtmesemp', '#divAlteracao').unbind('keypress').bind('keypress', function(e) {
        if (e.keyCode == 9 || e.keyCode == 13) {
			
			manterRotina('A');
            return false;
        }
    });

	$('#contigen', '#divAlteracao').unbind('change').bind('change', function (e) {

	    if ($(this).val() == 0) {
	        $('#incomite', '#divAlteracao').desabilitaCampo();
	        $('#incomite', '#divAlteracao').val('0');
	    } else {
	        $('#incomite', '#divAlteracao').habilitaCampo();
	    }
	    return false;
	});
  
	$('#anlautom', '#divAlteracao').unbind('change').bind('change', function (e) {

	    if ($(this).val() == 0) {
	      $('#nmregmpf', '#divAlteracao').desabilitaCampo();
          $('#nmregmpj', '#divAlteracao').desabilitaCampo();
          $('#qtsstime', '#divAlteracao').desabilitaCampo();
          $('#qtmeschq', '#divAlteracao').desabilitaCampo();
          $('#qtmeschqal11', '#divAlteracao').desabilitaCampo();
          $('#qtmeschqal12', '#divAlteracao').desabilitaCampo();
          $('#qtmesest', '#divAlteracao').desabilitaCampo();
          $('#qtmesemp', '#divAlteracao').desabilitaCampo();
	      $('#nmregmpf', '#divAlteracao').val('');
          $('#nmregmpj', '#divAlteracao').val('');
          $('#qtsstime', '#divAlteracao').val('0');
          $('#qtmeschq', '#divAlteracao').val('0');
          $('#qtmeschqal11', '#divAlteracao').val('0');
          $('#qtmeschqal12', '#divAlteracao').val('0');
          $('#qtmesest', '#divAlteracao').val('0');
          $('#qtmesemp', '#divAlteracao').val('0');
	    } else {
	      $('#nmregmpf', '#divAlteracao').habilitaCampo();
          $('#nmregmpj', '#divAlteracao').habilitaCampo();
          $('#qtsstime', '#divAlteracao').habilitaCampo();
          $('#qtmeschq', '#divAlteracao').habilitaCampo();
          $('#qtmeschqal11', '#divAlteracao').habilitaCampo();
          $('#qtmeschqal12', '#divAlteracao').habilitaCampo();
          $('#qtmesest', '#divAlteracao').habilitaCampo();
          $('#qtmesemp', '#divAlteracao').habilitaCampo();
	    }
	    return false;
	});  	
  
	// Permitir somente letras, números e o caractere "_"
	$('#nmregmpf', '#divAlteracao').keyup(function(e) {
		if (alphaExp.test(this.value) !== true){
			this.value = this.value.replace(/[^a-zA-Z0-9_]+/, '');
		}		
		return false;
	});
  
  $('#nmregmpj', '#divAlteracao').keyup(function(e) {
		if (alphaExp.test(this.value) !== true){
			this.value = this.value.replace(/[^a-zA-Z0-9_]+/, '');
		}		
		return false;
	});
	
}

function controlaOperacao() {
		
	if ( $('#cddopcao', '#frmCab').val() == 'C' ) {
		LiberaCampos();
	} else {			
		LiberaCampos();
	}
	
	// Desabilita campo opção
	cTodosCabecalho = $('input[type="text"],select', '#frmCab');
	cTodosCabecalho.desabilitaCampo();
	
	return false;
}

function LiberaCampos() {
	
    if ($('#cddopcao', '#frmCab').hasClass('campoTelaSemBorda')) {
        return false;
    }
	
    // Desabilita campo opção
    cTodosCabecalho = $('input[type="text"],select', '#frmCab');
    cTodosCabecalho.desabilitaCampo();

	$('#frmParest').css({'display': 'block'});
	
    // Apenas quando for alteração
    if ($('#cddopcao', '#frmCab').val() == 'A') {

	    if ($('#tlcooper', '#' + frmCab).val() == 0) { // Todas
			// Mostra Divs
	        $('#divBotoes').css({ 'display': 'block' });
	        $('#divAlteracao').css({ 'display': 'block' });
			// Esconde campos e labels
			$('input[type="text"],select,label', '#frmParest').desabilitaCampo().hide();
			$('label[for="incomite"]', '#' + frmParest).show();
			$('label[for="contigen"]', '#' + frmParest).show();
			// Habilita campos específicos
	        $('#contigen', '#divAlteracao').habilitaCampo().show().focus();
			$('#contigen', '#divAlteracao').val('0');
	        $('#incomite', '#divAlteracao').desabilitaCampo().show();
			$('#incomite', '#divAlteracao').val('0');			
	        $("#btContinuar", "#divBotoes").show();
	    } else {
			$('input[type="text"],select,label', '#frmParest').show();
	        manterRotina('X');
	    }
    } else {
        $("#btContinuar", "#divBotoes").hide();
		manterRotina('C');
    }

    return false;

}


function manterRotina(cdopcao) {

    var mensagem = '';

    hideMsgAguardo();

    mensagem = 'Aguarde, efetuando solicitacao...';
    showMsgAguardo(mensagem);
	
    var tlcooper = normalizaNumero($('#tlcooper', '#' + frmCab).val());
	
    var contigen = normalizaNumero($('#contigen', '#' + frmParest).val());
    var incomite = normalizaNumero($('#incomite', '#' + frmParest).val());
    var anlautom = normalizaNumero($('#anlautom', '#' + frmParest).val());
    
    var nmregmpf = $('#nmregmpf', '#' + frmParest).val();
    var nmregmpj = $('#nmregmpj', '#' + frmParest).val();
    var qtsstime = $('#qtsstime', '#' + frmParest).val();
    var qtmeschq = $('#qtmeschq', '#' + frmParest).val();
    var qtmeschqal11 = $('#qtmeschqal11', '#' + frmParest).val();
    var qtmeschqal12 = $('#qtmeschqal12', '#' + frmParest).val();
    var qtmesest = $('#qtmesest', '#' + frmParest).val();
    var qtmesemp = $('#qtmesemp', '#' + frmParest).val();

    $.ajax({
        type: 'POST',
        async: true,
        url: UrlSite + 'telas/parest/manter_rotina.php',
        data: {
            cddopcao: cdopcao,
            tlcooper: tlcooper,
            contigen: contigen,
            anlautom: anlautom,
            incomite: incomite,
            nmregmpf: nmregmpf,
            nmregmpj: nmregmpj,
            qtsstime: qtsstime,
            qtmeschq: qtmeschq,
            qtmeschqal11: qtmeschqal11,
            qtmeschqal12: qtmeschqal12,
            qtmesest: qtmesest,
            qtmesemp: qtmesemp,
            redirect: 'script_ajax'
        },
        error: function(objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'estadoInicial();');
        },
        success: function(response) {
            try {
                eval(response);	
                return false;
            } catch (error) {
                hideMsgAguardo();
                showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'estadoInicial();');
            }
        }
    });

    return false;

}


function formataResultado() {

    var divRegistro = $('div.divRegistros', '#divConsulta');
    var tabela = $('table', divRegistro);

    divRegistro.css({'height': '280px'});
    divRegistro.css({'width': '740px'});

    var tabelaHeader = $('table > thead > tr > th', divRegistro);
    var fonteLinha = $('table > tbody > tr > td', divRegistro);

    tabelaHeader.css({'font-size': '11px'});
    fonteLinha.css({'font-size': '11px'});

    $('fieldset').css({'clear': 'both', 'border': '1px solid #777', 'margin': '3px 0px', 'padding': '10px 3px 5px 3px'});
    $('fieldset > legend').css({'font-size': '11px', 'color': '#777', 'margin-left': '5px', 'padding': '0px 2px'});

    var ordemInicial = new Array();

    var arrayLargura = new Array();
    arrayLargura[0] = '80px';
    arrayLargura[1] = '60px';
    arrayLargura[2] = '60px';
    arrayLargura[3] = '60px';
    arrayLargura[4] = '200px';

    var arrayAlinha = new Array();
    arrayAlinha[0] = 'left';
    arrayAlinha[1] = 'center';
    arrayAlinha[2] = 'center';
    arrayAlinha[3] = 'center';
    arrayAlinha[4] = 'left';
    arrayAlinha[5] = 'left';

    tabela.formataTabela(ordemInicial, arrayLargura, arrayAlinha, '');

    hideMsgAguardo();
	
	  $('#divBotoes').css({'display': 'block'});

    return false;
}

function alteracaoMensagem(){
	hideMsgAguardo();
	return false;
}

function confirmaAlteracao() {

    showConfirmacao('Confirma a Altera&ccedil;&atilde;o dos parametros?', 'Confirma&ccedil;&atilde;o - Ayllos', 'manterRotina(\'A\');', '', 'sim.gif', 'nao.gif');
}

function desbloqueia() {
	cTodosCabecalho.habilitaCampo();
	$('#cddopcao', '#frmCab').focus();
	return false;
}