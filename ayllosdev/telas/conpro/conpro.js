/*!
 * FONTE        : conpro.js
 * CRIAÇÃO      : Daniel Zimmermann
 * DATA CRIAÇÃO : 17/03/2016
 * OBJETIVO     : Biblioteca de funções da tela CONPRO
 * --------------
 * ALTERAÇÕES   : 05/07/2017 - P337 - Prever novas situações criadas pela
 *                             pela implantação da análise automática (Motor)
 * --------------
 */

// Variáveis Globais 
var operacao = '';

var frmCab = 'frmCab';
var frmConpro = 'frmConpro';
var frmAciona = 'frmAciona';

var cTodosCabecalho = '';
var cTodosFiltro = '';
var cTodosFiltroAciona = '';

$(document).ready(function() {

    cTodosCabecalho = $('input[type="text"],select', '#' + frmCab);
    cTodosFiltro = $('input[type="text"],select', '#' + frmConpro);
	cTodosFiltroAciona = $('input[type="text"],select', '#' + frmAciona);

    estadoInicial();

});


// Controles
function estadoInicial() {

    // Variaveis Globais
    operacao = '';

    fechaRotina($('#divRotina'));

    // Limpa formularios
    cTodosCabecalho.limpaFormulario();
    cTodosFiltro.limpaFormulario();
	cTodosFiltroAciona.limpaFormulario();

    // habilita foco no formulário inicial
    highlightObjFocus($('#frmCab'));
	
	highlightObjFocus($('#frmConpro'));
	highlightObjFocus($('#frmAciona'));

    // Aplicar Formatação
    controlaLayout();


}

function controlaLayout() {

    $('#divTela').fadeTo(0, 0.1);
    $('fieldset').css({'clear': 'both', 'border': '1px solid #777', 'margin': '3px 0px', 'padding': '10px 3px 5px 3px'});
    $('fieldset > legend').css({'font-size': '11px', 'color': '#777', 'margin-left': '5px', 'padding': '0px 2px'});
    $('#divBotoes').css({'text-align': 'center', 'padding-top': '5px'});

    $('#frmConpro').css({'display': 'none'});
    $('#divBotoes').css({'display': 'none'});
	$('#frmAciona').css({'display': 'none'});

    // Retira html da tabela de resultado
    $('#divResultado').html('');
	
	$('#divResultadoAciona').html('');

    formataCabecalho();
    formataFiltros();
	
	formataFiltrosAciona();

    layoutPadrao();
    controlaFoco();
    removeOpacidade('divTela');
    return false;

}

function formataCabecalho() {

    // Cabeçalho
    rCddopcao = $('label[for="cddopcao"]', '#' + frmCab);

    cCddopcao = $('#cddopcao', '#' + frmCab);
    btnCab = $('#btOK', '#' + frmCab);

    rCddopcao.css('width', '44px');
    cCddopcao.css({'width': '1016px'});

    cTodosCabecalho.habilitaCampo();

    $('#cddopcao', '#' + frmCab).focus();

    return false;
}

function formataFiltros() {

    rNrdconta = $('label[for="nrdconta"]', '#' + frmConpro);
    rNrctremp = $('label[for="nrctremp"]', '#' + frmConpro);
    rCdagenci = $('label[for="cdagenci"]', '#' + frmConpro);
    rDtinicio = $('label[for="dtinicio"]', '#' + frmConpro);
    rDtafinal = $('label[for="dtafinal"]', '#' + frmConpro);
    rInsitest = $('label[for="insitest"]', '#' + frmConpro);
    rInsitefe = $('label[for="insitefe"]', '#' + frmConpro);
    rinsitapr = $('label[for="insitapr"]', '#' + frmConpro);
    rtpproduto = $('label[for="tpproduto"]', '#' + frmConpro);

    rNrdconta.css('width', '100px');
    rNrctremp.css('width', '177px');
    rCdagenci.css('width', '110px');
    rDtinicio.css('width', '100px');
    rDtafinal.css('width', '197px');
    rInsitest.css('width', '100px');
    rInsitefe.css('width', '117px');
    rinsitapr.css('width', '130px');
    rtpproduto.css('width', '100px');

    cNrdconta = $('#nrdconta', '#' + frmConpro);
    cNrctremp = $('#nrctremp', '#' + frmConpro);
    cCdagenci = $('#cdagenci', '#' + frmConpro);
    cDtinicio = $('#dtinicio', '#' + frmConpro);
    cDtafinal = $('#dtafinal', '#' + frmConpro);
    cInsitest = $('#insitest', '#' + frmConpro);
    cInsitefe = $('#insitefe', '#' + frmConpro);
    cinsitapr = $('#insitapr', '#' + frmConpro);
    ctpproduto = $('#tpproduto', '#' + frmConpro);

    cNrdconta.addClass('conta pesquisa').css({'width': '80px'});
    cNrctremp.addClass('contrato3').css({'width': '80px'});
    cCdagenci.css({'width': '40px'}).attr('maxlength','3').setMask('INTEGER','zzz','','');
    cDtinicio.addClass('data').css({'width': '80px'});
    cDtafinal.addClass('data').css({'width': '80px'});

    cInsitest.css({'width': '160px'});
    cInsitefe.css({'width': '80px'});
    cinsitapr.css({'width': '130px'});
    ctpproduto.css({'width': '130px'});

    cTodosFiltro.habilitaCampo();

    return false;
}

function formataFiltrosAciona() {

    rNrdconta = $('label[for="nrdconta"]', '#' + frmAciona);
    rNrctremp = $('label[for="nrctremp"]', '#' + frmAciona);
	rDtinicio = $('label[for="dtinicio"]', '#' + frmAciona);
    rDtafinal = $('label[for="dtafinal"]', '#' + frmAciona);
    rtpproduto = $('label[for="tp"]', '#' + frmAciona);

    rNrdconta.css('width', '100px');
    rNrctremp.css('width', '130px');
	rDtinicio.css('width', '130px');
    rDtafinal.css('width', '130px');

    cNrdconta = $('#nrdconta', '#' + frmAciona);
    cNrctremp = $('#nrctremp', '#' + frmAciona);
	cDtinicio = $('#dtinicio', '#' + frmAciona);
    cDtafinal = $('#dtafinal', '#' + frmAciona);

    cNrdconta.addClass('conta pesquisa').css({'width': '80px'});
    cNrctremp.addClass('contrato3').css({'width': '80px'});
	cDtinicio.addClass('data').css({'width': '80px'});
    cDtafinal.addClass('data').css({'width': '80px'});

    cTodosFiltroAciona.habilitaCampo();

    return false;
}

function controlaFoco() {

    $(".acionamentoTpproduto").change(function(param){
        $("#nrdconta , #frmAciona").focus();
        
    });

    $('#cddopcao', '#frmCab').unbind('keypress').bind('keypress', function(e) {
        if (e.keyCode == 9 || e.keyCode == 13) {
            $('#btnOK', '#frmCab').focus();
            return false;
        }
    });

    $('#btnOK', '#frmCab').unbind('keypress').bind('keypress', function(e) {
        if (e.keyCode == 9 || e.keyCode == 13) {
            LiberaCampos();
            return false;
        }
    });

    $('#nrdconta', '#frmConpro').unbind('keypress').bind('keypress', function(e) {
        if (e.keyCode == 9 || e.keyCode == 13) {
            $('#nrctremp', '#frmConpro').focus();
            return false;
        }
    });

    $('#nrctremp', '#frmConpro').unbind('keypress').bind('keypress', function(e) {
        if (e.keyCode == 9 || e.keyCode == 13) {
            $('#cdagenci', '#frmConpro').focus();
            return false;
        }
    });

    $('#cdagenci', '#frmConpro').unbind('keypress').bind('keypress', function(e) {
        if (e.keyCode == 9 || e.keyCode == 13) {
            $('#dtinicio', '#frmConpro').focus();
            return false;
        }
    });

    $('#dtinicio', '#frmConpro').unbind('keypress').bind('keypress', function(e) {
        if (e.keyCode == 9 || e.keyCode == 13) {
            $('#dtafinal', '#frmConpro').focus();
            return false;
        }
    });

    $('#dtafinal', '#frmConpro').unbind('keypress').bind('keypress', function(e) {
        if (e.keyCode == 9 || e.keyCode == 13) {
            $('#insitest', '#frmConpro').focus();
            return false;
        }
    });

    $('#insitest', '#frmConpro').unbind('keypress').bind('keypress', function(e) {
        if (e.keyCode == 9 || e.keyCode == 13) {
            $('#insitefe', '#frmConpro').focus();
            return false;
        }
    });

    $('#insitefe', '#frmConpro').unbind('keypress').bind('keypress', function(e) {
        if (e.keyCode == 9 || e.keyCode == 13) {
            $('#insitapr', '#frmConpro').focus();
            return false;
        }
    });

    $('#insitapr', '#frmConpro').unbind('keypress').bind('keypress', function(e) {
        if (e.keyCode == 9 || e.keyCode == 13) {
            controlaOperacao();
            return false;
        }
    });
	
	$('#nrdconta', '#frmAciona').unbind('keypress').bind('keypress', function(e) {
        if (e.keyCode == 9 || e.keyCode == 13) {
            $('#nrctremp', '#frmAciona').focus();
            return false;
        }
    });

    $('#nrctremp', '#frmAciona').unbind('keypress').bind('keypress', function(e) {
        if (e.keyCode == 9 || e.keyCode == 13) {
            $('#dtinicio', '#frmAciona').focus();
            return false;
        }
    });
	
	$('#dtinicio', '#frmAciona').unbind('keypress').bind('keypress', function(e) {
        if (e.keyCode == 9 || e.keyCode == 13) {
            $('#dtafinal', '#frmAciona').focus();
            return false;
        }
    });

    $('#dtafinal', '#frmAciona').unbind('keypress').bind('keypress', function(e) {
        if (e.keyCode == 9 || e.keyCode == 13) {
            controlaOperacao();
            return false;
        }
    });
	
}

function LiberaCampos() {

    if ($('#cddopcao', '#frmCab').hasClass('campoTelaSemBorda')) {
        return false;
    }
	
	// Desabilita campo opção
	cTodosCabecalho = $('input[type="text"],select', '#frmCab');
	cTodosCabecalho.desabilitaCampo();
	
	if ( $('#cddopcao', '#frmCab').val() == 'A' ) {
        
		$('#frmAciona').css({'display': 'block'});
		$('#tpproduto', '#frmAciona').focus();
        $('#tpproduto', '#frmAciona').click();
		$('#divBotoes', '#frmAciona').css({'display': 'block'});
		$("#btContinuar", "#divBotoes").show();

	} else {
        $("#tpproduto").val("9");
        if($('#cddopcao', '#frmCab').val() == 'C'){
            $(".tpproduto").show();
            $("#tpproduto ").focus();
            alteraProduto(null);
            
        }else if($('#cddopcao', '#frmCab').val() == 'R'){
            $(".tpproduto").hide();
            alteraProduto(3);
        }

		$('#frmConpro').css({'display': 'block'});
		$('#tpproduto', '#frmConpro').focus();
		$('#divBotoes', '#frmConpro').css({'display': 'block'});
		$("#btContinuar", "#divBotoes").show();

	}
	
	$('#divBotoes').css({'display': 'block'});

    return false;

}

function controlaOperacao() {

    var operacao = $('#cddopcao', '#' + frmCab).val();
	
    switch (operacao) {
        case 'C': // Consulta
            var tpprd = $("#tpproduto").val();
            if(tpprd == 9){
                 showError('error', 'Por favor, selecione o tipo produto. ', 'Alerta - Ayllos', '');
                return false;    
            }
            manterRotina(1,100);
            return false;
            break;
        case 'R': // Impressão
            confirmaImpressao();
            return false;
            break;
		case 'A': // Acionamentos
            buscaAcionamentos();
            return false;
            break;
        default:
            return false;
            break;
    }

}

function manterRotina(nriniseq, nrregist) {

 
    highlightObjFocus($('#frmConpro'));

    var mensagem = '';

    hideMsgAguardo();

    mensagem = 'Aguarde, buscando dados...';
    showMsgAguardo(mensagem);

    var nrdconta = normalizaNumero($('#nrdconta', '#' + frmConpro).val());
    var nrctremp = normalizaNumero($('#nrctremp', '#' + frmConpro).val());
    var cdagenci = normalizaNumero($('#cdagenci', '#' + frmConpro).val());
    var dtinicio = $('#dtinicio', '#' + frmConpro).val();
    var dtafinal = $('#dtafinal', '#' + frmConpro).val();
    var insitest = $('#insitest', '#' + frmConpro).val();
    var insitefe = $('#insitefe', '#' + frmConpro).val();
    var insitapr = $('#insitapr', '#' + frmConpro).val();
    var tpproduto = $('#tpproduto', '#' + frmConpro).val();

    var cddopcao = $('#cddopcao', '#' + frmCab).val();

    $.ajax({
        type: 'POST',
        async: true,
        url: UrlSite + 'telas/conpro/manter_rotina.php',
        data: {
            cddopcao: cddopcao,
            nrdconta: nrdconta,
            nrctremp: nrctremp,
            cdagenci: cdagenci,
            dtinicio: dtinicio,
            dtafinal: dtafinal,
            insitest: insitest,
            insitefe: insitefe,
            insitapr: insitapr,
            nriniseq: nriniseq,
            nrregist: nrregist,
            tpproduto: tpproduto,
            redirect: 'script_ajax'
        },
        error: function(objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError('error', '1 N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'estadoInicial();');
        },
        success: function(response) {
            try {
        
                eval(response);
                $('#divPesquisaRodape', '#divResultado').formataRodapePesquisa();
                
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
	
	var tpProdutoSelecionado = $('#tpproduto', '#' + frmConpro).val();
	
	var divRegistro = $('div.divRegistros', '#divResultado');
    var tabela = $('table', divRegistro);

    divRegistro.css({ 'height': '250px' });

    var tabelaHeader = $('table > thead > tr > th', divRegistro);
    var fonteLinha = $('table > tbody > tr > td', divRegistro);

    tabelaHeader.css({'font-size': '11px'});
    fonteLinha.css({'font-size': '11px'});

    $('fieldset').css({'clear': 'both', 'border': '1px solid #777', 'margin': '3px 0px', 'padding': '10px 3px 5px 3px'});
    $('fieldset > legend').css({'font-size': '11px', 'color': '#777', 'margin-left': '5px', 'padding': '0px 2px'});


    var ordemInicial = new Array();
    //ordemInicial = [[3,0]]; // 4a coluna, ascendente

    var arrayAlinha = new Array();
    arrayAlinha[0] = 'center';
    arrayAlinha[1] = 'right';
    arrayAlinha[2] = 'right';
    arrayAlinha[3] = 'right';
    arrayAlinha[4] = 'center';
    arrayAlinha[5] = 'center';
    arrayAlinha[6] = 'center';
    arrayAlinha[7] = 'center';
    arrayAlinha[8] = 'center';
    arrayAlinha[9] = 'center';
    arrayAlinha[10] = 'center';
    arrayAlinha[11] = 'center';
    arrayAlinha[12] = 'center';
    arrayAlinha[13] = 'center';
    arrayAlinha[14] = 'center';
	
	var arrayLargura = new Array();

    var metodoTabela = '';
	
    if(tpProdutoSelecionado.toString() == 4){
		//Altera o Titulo do cabeçalho
		$(".hr_title_valor_proposta ").text("Valor Limite");
		$(".hr_title_efetivada ").text("Aprovada");
		
		arrayLargura[0] = '25px';
		arrayLargura[1] = '85px';
		arrayLargura[2] = '85px';
		arrayLargura[3] = '110px';
		arrayLargura[4] = '60px';
		arrayLargura[5] = '140px';
		arrayLargura[6] = '140px';
		arrayLargura[7] = '70px';
		arrayLargura[8] = '140px';

		
    }
	else{
		arrayLargura[0] = '25px';
		arrayLargura[1] = '60px';
		arrayLargura[2] = '60px';
		arrayLargura[3] = '110px';
		arrayLargura[4] = '50px';
		arrayLargura[5] = '40px';
		arrayLargura[6] = '60px';
		arrayLargura[7] = '50px';
		arrayLargura[8] = '65px';
		arrayLargura[9] = '70px';
		arrayLargura[10] = '55px';
		arrayLargura[11] = '50px';
		arrayLargura[12] = '60px';
		arrayLargura[13] = '65px';
	}
	
	tabela.formataTabela(ordemInicial, arrayLargura, arrayAlinha, metodoTabela);

    hideMsgAguardo();

    return false;
}

function buscaAcionamentos() {
	
   // highlightObjFocus($('#frmConpro'));

    var mensagem = '';

    

    var nrdconta = normalizaNumero($('#nrdconta', '#' + frmAciona).val());
    var nrctremp = normalizaNumero($('#nrctremp', '#' + frmAciona).val());
	
	var dtinicio = $('#dtinicio', '#' + frmAciona).val();
    var dtafinal = $('#dtafinal', '#' + frmAciona).val();
    

    var cddopcao = $('#cddopcao', '#' + frmCab).val();

    var tpproduto =  $('#tpproduto', '#frmAciona' ).val();
    
    if (nrdconta == 0 || nrdconta == '') {
        showError('error', 'Numero da Conta deve ser Informado.', 'Alerta - Ayllos', "$('#nrdconta', '#frmAciona').focus();");
        return false;
    }
    /*
    if (nrctremp == 0 || nrctremp == '') {
        showError('error', 'Numero do Contrato deve ser Informado.', 'Alerta - Ayllos', "$('#nrctremp', '#frmAciona').focus();");
        return false;
    }
    */
    hideMsgAguardo();

    mensagem = 'Aguarde, buscando dados de acionamento...';
    showMsgAguardo(mensagem);

    $.ajax({
        type: 'POST',
        async: true,
		    dataType: 'html',
        url: UrlSite + 'telas/conpro/busca_acionamento.php',
        data: {
            cddopcao: cddopcao,
            nrdconta: nrdconta,
            nrctremp: nrctremp,
            dtinicio: dtinicio,
            dtafinal: dtafinal,
            tpproduto: tpproduto,
            redirect: 'html_ajax'
        },
        error: function(objAjax, responseError, objExcept) {
            hideMsgAguardo();
			      showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'estadoInicial();');
        },
        success: function(response) {
			      hideMsgAguardo();
            try {
				        $('#divResultadoAciona').html(response);
                return false;
            } catch (error) {                
				        showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'estadoInicial();');
            }
        }
    });

    return false;

}


function controlaPesquisa(opcao) {

    if (opcao == 1) {

        
		
        if ($('#cddopcao', '#' + frmCab).val() == 'A') {

            if ($('#nrdconta', '#frmAciona').hasClass('campoTelaSemBorda')) {
                return false;
            }
		
			mostraPesquisaAssociado('nrdconta', 'frmAciona');
			
		} else {

		    if ($('#nrdconta', '#' + frmConpro).hasClass('campoTelaSemBorda')) {
		        return false;
		    }

			mostraPesquisaAssociado('nrdconta', 'frmConpro');
		}
    } else {

        if ($('#cddopcao', '#' + frmCab).val() == 'A') {
            if ($('#nrctremp', '#frmAciona').hasClass('campoTelaSemBorda')) {
                return false;
            }
        } else {
            if ($('#nrctremp', '#' + frmConpro).hasClass('campoTelaSemBorda')) {
                return false;
            }
        }

        mostraContrato();
    }

    return false;
}

function mostraContrato() {

    showMsgAguardo('Aguarde, buscando ...');

    // Executa script de confirmação através de ajax
    $.ajax({
        type: 'POST',
        dataType: 'html',
        url: UrlSite + 'telas/conpro/contrato.php',
        data: {
            redirect: 'html_ajax'
        },
        error: function(objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError('error', 'Não foi possível concluir a requisição.', 'Alerta - Ayllos', "unblockBackground()");
        },
        success: function(response) {
            $('#divRotina').html(response);
            buscaContrato();
            return false;
        }
    });
    return false;
}


function buscaContrato() {
	
	var nmformul = '';

    showMsgAguardo('Aguarde, buscando ...');

	if ( $('#cddopcao', '#' + frmCab).val() == 'A' ) {
		
		nmformul = '#frmAciona';
		
	} else {
		
		nmformul = '#frmConpro';
	}
	
	
   // var nmformul = '#frmConpro';
    var nrdconta = normalizaNumero($('#nrdconta', nmformul).val());

    $.ajax({
        type: 'POST',
        dataType: 'html',
        url: UrlSite + 'telas/conpro/busca_contrato.php',
        data: {
            nrdconta: nrdconta,
            redirect: 'script_ajax'
        },
        error: function(objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError('error', 'Não foi possível concluir a requisição.', 'Alerta - Ayllos', "unblockBackground();");
        },
        success: function(response) {
            try {
                $('#divConteudo').html(response);
                exibeRotina($('#divRotina'));
                formataGridContrato();
                return false;
            } catch (error) {
                hideMsgAguardo();
                showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'unblockBackground()');
            }
        }
    });
    return false;
}

function formataGridContrato() {

    var divRegistro = $('div.divRegistros', '#divContrato');
    var tabela = $('table', divRegistro);
   // var linha = $('table > tbody > tr', divRegistro);

    divRegistro.css({'height': '120px', 'width': '500px'});

    var ordemInicial = new Array();
    ordemInicial = [[0, 0]];

    var arrayLargura = new Array();
    arrayLargura[0] = '60px';
    arrayLargura[1] = '62px';
    arrayLargura[2] = '80px';
    arrayLargura[3] = '60px';
    arrayLargura[4] = '80px';
    arrayLargura[5] = '38px';


    var arrayAlinha = new Array();
    arrayAlinha[0] = 'right';
    arrayAlinha[1] = 'left';
    arrayAlinha[2] = 'right';
    arrayAlinha[3] = 'right';
    arrayAlinha[4] = 'right';
    arrayAlinha[5] = 'right';
    arrayAlinha[6] = 'right';

    var metodoTabela = 'selecionaContrato();';

    tabela.formataTabela(ordemInicial, arrayLargura, arrayAlinha, metodoTabela);

    hideMsgAguardo();
    bloqueiaFundo($('#divRotina'));

    return false;
}

function selecionaContrato() {

    var nrctremp = 0;
    //var nmformul = '#frmConpro';

    if ($('table > tbody > tr', 'div.divRegistros').hasClass('corSelecao')) {
        $('table > tbody > tr', 'div.divRegistros').each(function() {
            if ($(this).hasClass('corSelecao')) {
                nrctremp = $('#nrctremp', $(this)).val();
            }
        });
    }

	if ( $('#cddopcao', '#' + frmCab).val() == 'A' ) {
		$('#nrctremp', '#frmAciona').val(nrctremp).focus();
	} else {
		$('#nrctremp', '#frmConpro').val(nrctremp).focus();
	}
    fechaRotina($('#divRotina'));
    return false;
}

function confirmaImpressao() {

    showConfirmacao('Confirma a Impress&atilde;o do relatorio?', 'Confirma&ccedil;&atilde;o - Ayllos', 'carregarImpresso();', '', 'sim.gif', 'nao.gif');

}

function carregarImpresso() {

    // Formulario de Impressao
    var frmImp = 'frmImpressao';

    var nrdconta = normalizaNumero($('#nrdconta', '#' + frmConpro).val());
    var nrctremp = normalizaNumero($('#nrctremp', '#' + frmConpro).val());
    var cdagenci = normalizaNumero($('#cdagenci', '#' + frmConpro).val());
    var dtinicio = $('#dtinicio', '#' + frmConpro).val();
    var dtafinal = $('#dtafinal', '#' + frmConpro).val();
    var insitest = $('#insitest', '#' + frmConpro).val();
    var insitefe = $('#insitefe', '#' + frmConpro).val();
    var insitapr = $('#insitapr', '#' + frmConpro).val();
    var cddopcao = $('#cddopcao', '#' + frmCab).val();

    fechaRotina($('#divUsoGenerico'), $('#divRotina'));

    $('#sidlogin', '#' + frmImp).remove();
    $('#nrdconta', '#' + frmImp).remove();
    $('#nrctremp', '#' + frmImp).remove();
    $('#cdagenci', '#' + frmImp).remove();
    $('#dtinicio', '#' + frmImp).remove();
    $('#dtafinal', '#' + frmImp).remove();
    $('#insitest', '#' + frmImp).remove();
    $('#insitefe', '#' + frmImp).remove();
    $('#insitapr', '#' + frmImp).remove();
    $('#cddopcao', '#' + frmImp).remove();
    $('#nriniseq', '#' + frmImp).remove();
    $('#nrregist', '#' + frmImp).remove();


    // Insere input do tipo hidden do formulário para enviá-los posteriormente
    $('#' + frmImp).append('<input type="text" id="sidlogin" name="sidlogin" />');

    $('#' + frmImp).append('<input type="text" id="nrdconta" name="nrdconta" />');
    $('#' + frmImp).append('<input type="text" id="nrctremp" name="nrctremp" />');
    $('#' + frmImp).append('<input type="text" id="cdagenci" name="cdagenci" />');
    $('#' + frmImp).append('<input type="text" id="dtinicio" name="dtinicio" />');
    $('#' + frmImp).append('<input type="text" id="dtafinal" name="dtafinal" />');
    $('#' + frmImp).append('<input type="text" id="insitest" name="insitest" />');
    $('#' + frmImp).append('<input type="text" id="insitefe" name="insitefe" />');
    $('#' + frmImp).append('<input type="text" id="insitapr" name="insitapr" />');
    $('#' + frmImp).append('<input type="text" id="cddopcao" name="cddopcao" />');
    $('#' + frmImp).append('<input type="text" id="nriniseq" name="nriniseq" />')
    $('#' + frmImp).append('<input type="text" id="nrregist" name="nrregist" />')

    // Agora insiro os devidos valores nos inputs criados
    $('#sidlogin', '#' + frmImp).val($('#sidlogin', '#frmMenu').val());

    $('#nrdconta', '#' + frmImp).val(nrdconta);
    $('#nrctremp', '#' + frmImp).val(nrctremp);
    $('#cdagenci', '#' + frmImp).val(cdagenci);
    $('#dtinicio', '#' + frmImp).val(dtinicio);
    $('#dtafinal', '#' + frmImp).val(dtafinal);
    $('#insitest', '#' + frmImp).val(insitest);
    $('#insitefe', '#' + frmImp).val(insitefe);
    $('#insitapr', '#' + frmImp).val(insitapr);
    $('#cddopcao', '#' + frmImp).val(cddopcao);

    $('#nriniseq', '#' + frmImp).val(1);
    $('#nrregist', '#' + frmImp).val(999999);


    var action = UrlSite + 'telas/conpro/impressao.php';

    // Variavel para os comandos de controle
    var controle = '';

    carregaImpressaoAyllos(frmImp, action, controle);

    return false;
}

function desbloqueia() {
    cTodosFiltro.habilitaCampo();
    $('#nrdconta', '#' + frmConpro).focus();
}


function formataBusca() {

    var divRegistro = $('div.divRegistros', '#divResultadoAciona');
    var tabela = $('table', divRegistro);

    divRegistro.css({'height': '250px'});

    var tabelaHeader = $('table > thead > tr > th', divRegistro);
    var fonteLinha = $('table > tbody > tr > td', divRegistro);

    tabelaHeader.css({'font-size': '11px'});
    fonteLinha.css({'font-size': '11px'});

    $('fieldset').css({'clear': 'both', 'border': '1px solid #777', 'margin': '3px 0px', 'padding': '10px 3px 5px 3px'});
    $('fieldset > legend').css({'font-size': '11px', 'color': '#777', 'margin-left': '5px', 'padding': '0px 2px'});


    var ordemInicial = new Array();

    var arrayLargura = new Array();

    arrayLargura[0] = '80px';
    arrayLargura[1] = '70px';
	  arrayLargura[2] = '110px';
    arrayLargura[3] = '100px';
    arrayLargura[4] = '280px';
    arrayLargura[5] = '120px';

    var arrayAlinha = new Array();
    arrayAlinha[0] = 'right';
    arrayAlinha[1] = 'right';
    arrayAlinha[2] = 'left';
    arrayAlinha[3] = 'left';
    arrayAlinha[4] = 'left';
    arrayAlinha[5] = 'center';
    arrayAlinha[6] = 'left';

    var metodoTabela = '';

    tabela.formataTabela(ordemInicial, arrayLargura, arrayAlinha, metodoTabela);

    hideMsgAguardo();
	
    return false;
}



function abreProtocoloAcionamento(dsprotocolo) {

    showMsgAguardo('Aguarde, carregando...');

    // Executa script de através de ajax
    $.ajax({
        type: 'POST',
        dataType: 'html',
        url: UrlSite + 'telas/conpro/tab_acionamento.php',
        data: {
            dsprotocolo: dsprotocolo,
            redirect: 'html_ajax'
        },
        error: function(objAjax, responseError, objExcept) {
			      hideMsgAguardo();
            showError('error', 'N&atilde;o foi possível concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'bloqueiaFundo(divRotina)');
        },
        success: function(response) {
            hideMsgAguardo();
			      if (response.substr(0,4) == "hide") {
				        eval(response);
			      } else {
                $('#nmarquiv', '#frmImprimir').val(response);
                var action = UrlSite + 'telas/conpro/tab_acionamento.php';
                carregaImpressaoAyllos("frmImprimir",action,"");
			      }
            return false;
        }
    });

}

function alteraProduto(prd){
    
    populaSelect('insitapr',parecer[prd]);
    populaSelect('insitest',situacoes[prd]);
    $("#nrdconta",'#frmConpro').focus();
   

}

function populaSelect(id, dataset){
    $("#"+id).empty();       
    for(var data in dataset ){
        $('#'+id).append('<option value="'+data+'" '+(data.toString() == "9" ? "selected='selected'":"")+'>'+dataset[data]+'</option>');
    }
}


