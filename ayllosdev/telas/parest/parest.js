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

    return false;
}

function formataParametros() {

    rIncomite = $('label[for="incomite"]', '#' + frmParest);
    rContigen = $('label[for="contigen"]', '#' + frmParest);
    rNmregmpf = $('label[for="nmregmpf"]', '#' + frmParest);
    rNmregmpj = $('label[for="nmregmpj"]', '#' + frmParest);
    rQtsstime = $('label[for="qtsstime"]', '#' + frmParest);
    rQtmeschq = $('label[for="qtmeschq"]', '#' + frmParest);
    rQtmesest = $('label[for="qtmesest"]', '#' + frmParest);
    rQtmesemp = $('label[for="qtmesemp"]', '#' + frmParest);

    rIncomite.css('width', '300px');
    rContigen.css('width', '300px');
    rNmregmpf.css('width', '300px');
    rNmregmpj.css('width', '300px');
    rQtsstime.css('width', '300px');
    rQtmeschq.css('width', '300px');
    rQtmesest.css('width', '300px');
    rQtmesemp.css('width', '300px');

    cIncomite = $('#incomite', '#' + frmParest);
    cContigen = $('#nrctremp', '#' + frmParest);
    cNmregmpf = $('#nmregmpf', '#' + frmParest);
    cNmregmpj = $('#nmregmpj', '#' + frmParest);
    cQtsstime = $('#qtsstime', '#' + frmParest);
    cQtmeschq = $('#qtmeschq', '#' + frmParest);
    cQtmesest = $('#qtmesest', '#' + frmParest);
    cQtmesemp = $('#qtmesemp', '#' + frmParest);
    
	cNmregmpf.css('width', '300px').attr('maxlength', '250');	
  cNmregmpj.css('width', '300px').attr('maxlength', '250');	
	cQtsstime.addClass('inteiro').css('width', '48px');
	cQtmeschq.addClass('inteiro').css('width', '48px');
	cQtmesest.addClass('inteiro').css('width', '48px');
	cQtmesemp.addClass('inteiro').css('width', '48px');
	cQtsstime.attr('maxlength', '3');
	cQtmeschq.attr('maxlength', '2');
	cQtmesest.attr('maxlength', '2');
	cQtmesemp.attr('maxlength', '2');

    cTodosFiltro.habilitaCampo();

	layoutPadrao();
    return false;
}



function controlaFoco() {

    $('#cddopcao', '#frmCab').unbind('keypress').bind('keypress', function(e) {
        if (e.keyCode == 9 || e.keyCode == 13) {
            $('#tlcooper', '#frmCab').focus();
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
				$('#nmregmpf', '#divAlteracao').focus();
			}else{
				$('#incomite', '#divAlteracao').focus();
			}
            return false;
        }
    });
	
	$('#incomite', '#divAlteracao').unbind('keypress').bind('keypress', function(e) {
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

	    if ($('#contigen', '#divAlteracao').val() == 0) {
	        $('#incomite', '#divAlteracao').desabilitaCampo();
	        $('#incomite', '#divAlteracao').val('0');
	    } else {
	        $('#incomite', '#divAlteracao').habilitaCampo();
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
	//	manterRotina();
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
	        $('#divBotoes').css({ 'display': 'block' });
	        $('#divAlteracao').css({ 'display': 'block' });
	        $('#contigen', '#divAlteracao').focus();
	        $("#btContinuar", "#divBotoes").show();
	    } else {
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
	
//	var cddopcao = $('#cddopcao', '#frmCab').val();
	
    var tlcooper = normalizaNumero($('#tlcooper', '#' + frmCab).val());
	
    var contigen = normalizaNumero($('#contigen', '#' + frmParest).val());
    var incomite = normalizaNumero($('#incomite', '#' + frmParest).val());
    var nmregmpf = $('#nmregmpf', '#' + frmParest).val();
    var nmregmpj = $('#nmregmpj', '#' + frmParest).val();
    var qtsstime = $('#qtsstime', '#' + frmParest).val();
    var qtmeschq = $('#qtmeschq', '#' + frmParest).val();
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
            incomite: incomite,
            nmregmpf: nmregmpf,
            nmregmpj: nmregmpj,
            qtsstime: qtsstime,
			qtmeschq: qtmeschq,
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
			//	$('#divBotoes').css({'display': 'block'});
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

    var tabelaHeader = $('table > thead > tr > th', divRegistro);
    var fonteLinha = $('table > tbody > tr > td', divRegistro);

    tabelaHeader.css({'font-size': '11px'});
    fonteLinha.css({'font-size': '11px'});

    $('fieldset').css({'clear': 'both', 'border': '1px solid #777', 'margin': '3px 0px', 'padding': '10px 3px 5px 3px'});
    $('fieldset > legend').css({'font-size': '11px', 'color': '#777', 'margin-left': '5px', 'padding': '0px 2px'});


    var ordemInicial = new Array();

    var arrayLargura = new Array();
    arrayLargura[0] = '54px';
    arrayLargura[1] = '54px';
    arrayLargura[2] = '50px';
    arrayLargura[3] = '250px';
    arrayLargura[4] = '250px';
    arrayLargura[5] = '75px';
    arrayLargura[6] = '10px';
    /*arrayLargura[6] = '80px';
    arrayLargura[7] = '80px';    
    arrayLargura[8] = '80px';*/

    var arrayAlinha = new Array();
    arrayAlinha[0] = 'left';
    arrayAlinha[1] = 'center';
    arrayAlinha[2] = 'center';
    arrayAlinha[3] = 'left';
    arrayAlinha[4] = 'left';
    arrayAlinha[5] = 'center';
    /*arrayAlinha[6] = 'center';
    arrayAlinha[7] = 'center';
    arrayAlinha[8] = 'center';
    arrayAlinha[9] = 'center';*/

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