/*!
 * FONTE        : imppre.js
 * CRIAÇÃO      : Lucas Lombardi
 * DATA CRIAÇÃO : 19/07/2016
 * OBJETIVO     : Biblioteca de funções da tela IMPPRE
 * --------------
 * ALTERAÇÕES   :
 *
 * 000: [11/07/2017] Alteração no controla de apresentação do cargas bloqueadas na opção "A", Melhoria M441. ( Mateus Zimmermann/MoutS )			  
 * 001: [20/02/2019] ALterações e trocas de funções de telas para Pré-Aprovado - p442 (Christian Grauppe/Envolti).
 * 002: [08/05/2019] Ajustes na função de formatação da tabela de informação das telas da IMPPRE - p442 (Christian Grauppe/Envolti).
 *
 * --------------
 */
 
var glbIdcarga = 0;
var glbDscarga, glbDtfinal_vigencia, glbDsmensagem_aviso, glbNmarquivo;
var regSkcarga, regCdcooper, regDscarga, regDtcarga, regQtpfcarregados, regQtpjcarregados, regVllimitetotal;

var divListMsg ,divListErr, divViewMsg, regTableCoop, divListDetVariCargas;

var vlrmediapar, qtregispf, qtregispj, vlrparmax, vlmincarga, qtremovman, pervariault, pervarapri, idcarga, tpcarga, glbcoop;

$(document).ready(function() {

	estadoInicial();

	highlightObjFocus( $('#frmCab') );

	$('fieldset > legend').css({'font-size':'11px','color':'#777','margin-left':'5px','padding':'0px 2px'});
	$('fieldset').css({'clear':'both','border':'1px solid #777','margin':'3px 0px','padding':'10px 3px 5px 3px'});

	return false;

});

function estadoInicial() {

	$('#frmCab').css({'display':'block'});
	$('#divDetalhes').css({'display':'none'});

	$('#divBotoes', '#divTela').html('').css({'display':'block'});

	formataCabecalho();

	return false;

}

function controlaFoco() {

	$('#cddopcao','#frmCab').unbind('keypress').bind('keypress', function(e) {

		if ( $('#cddopcao','#frmCab').hasClass('campoTelaSemBorda') ) { return false; }

		if ( e.keyCode == 9 || e.keyCode == 13 ) {	
			acessa_rotina();			
			return false;
		}	
	});

	$('#btnOK','#frmCab').unbind('keypress').bind('keypress', function(e) {

		if ( $('#cddopcao','#frmCab').hasClass('campoTelaSemBorda') ) { return false; }

		if ( e.keyCode == 9 || e.keyCode == 13 ) {	
			acessa_rotina();
			return false;
		}	
	});

	$('#btnOK','#frmCab').unbind('click').bind('click', function(){
		if ( $('#cddopcao','#frmCab').hasClass('campoTelaSemBorda') ) { return false; }
		acessa_rotina();
		return false;
	});

	return false;

}

function acessa_rotina() {
	$('#cddopcao','#frmCab').desabilitaCampo();
	var cddopcao = $('#cddopcao','#frmCab').val();
	
	switch (cddopcao) {
		case 'I':
			buscaCargas();
			break;
		case 'L':
		case 'E':
			uploadCargas(cddopcao);
			break;
		case 'D':
			variacaoCargas();
			break;
	}
	return false;
}

function formataCabecalho() {

	$('input,select', '#frmCab').removeClass('campoErro');
	$('#divTela').css({'display':'inline'}).fadeTo(0,0.1);
	removeOpacidade('divTela');	

	cTodosCabecalho = $('input[type="text"],select','#frmCab'); 
	cTodosCabecalho.limpaFormulario();

	// cabecalho
	rCddopcao = $('label[for="cddopcao"]','#frmCab');

	cCddopcao = $('#cddopcao','#frmCab');

	//Rótulos
	rCddopcao.css('width','44px');

	//Campos	
	cCddopcao.habilitaCampo().focus();
	
	// Esconde o campo tipo de cadastro
	$('#trTipoCadastro').hide();

	controlaFoco();
	layoutPadrao();

	return false;	

}

// Monta Grid Inicial
function buscaCargas(nriniseq, nrregist) {

    $.ajax({
        type: "POST",
        dataType: "html",
        url: UrlSite + "telas/imppre/busca_cargas_sas.php",
        data: {
            nriniseq: nriniseq,
            nrregist: nrregist,
            redirect: "html_ajax"
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Ayllos", "");
        },
        success: function (response) {
            $('#divDetalhes').html(response).css("display","block");
            formataTabelaCarga();
        }
    });
    return false;
}

// Função para visualizar div da rotina
function mostraRotina() {
    $("#divRotina").css("visibility", "visible");
    $("#divRotina").centralizaRotinaH();
}

// Função para esconder div da rotina e carregar dados da conta novamente
function encerraRotina() {
    $("#divRotina").css({"width": "545px", "visibility": "hidden"});
    $("#divRotina").html("");

    // Esconde div de bloqueio
    unblockBackground();
    return false;
}

// Formata tabela de dados da remessa
function formataTabelaCarga() {

    // Habilita a conteudo da tabela
    $('#divCab').css({'display': 'block'});

    var divRegistro = $('div.divRegistros');
    var tabela      = $('table', divRegistro);
    var linha       = $('table > tbody > tr', divRegistro);
    var conteudo    = $('#conteudo', linha).val();

	$('#frmCab', '#divTela').css({'margin-top':'10px'});

    divRegistro.css({'margin-top': '1px', 'height': '300px', 'padding-bottom': '1px'});

    var ordemInicial = new Array();
	//ordemInicial = [[0,0]];

    var arrayLargura = new Array();
    arrayLargura[0] = '40px';
    arrayLargura[1] = '40px';
    arrayLargura[2] = '130px';
    arrayLargura[3] = '70px';
    arrayLargura[4] = '60px';
    arrayLargura[5] = '50px';
    arrayLargura[6] = '50px';
    arrayLargura[7] = '50px';
    arrayLargura[8] = '90px';
    arrayLargura[9] = '50px';
    arrayLargura[10] = '50px';

    var arrayAlinha = new Array();
    arrayAlinha[0] = 'center';
    arrayAlinha[1] = 'center';
    arrayAlinha[2] = 'left';
    arrayAlinha[3] = 'center';
    arrayAlinha[4] = 'center';
    arrayAlinha[5] = 'center';
    arrayAlinha[6] = 'center';
    arrayAlinha[7] = 'center';
    arrayAlinha[8] = 'center';
    arrayAlinha[9] = 'center';
    arrayAlinha[10] = 'center';

    hideMsgAguardo();

	$('#btVoltar', '#divBotoes').unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {
			btnVoltar();
		}
	});

    // seleciona o registro que é clicado
    $(linha).click(function () {
        selecionaTabela($(this));
    }).focus();

	// Necessário por o código aqui por conta do evento click que foi removido da tabela atravez do unbind
	// David Valente [Envolti]
	// 16/04/2019
	tabela.formataTabelaIMPPRE(ordemInicial, arrayLargura, arrayAlinha);

    return false;
}

function selecionaTabela(tr) {
	regSkcarga = $('.skcarga', tr).val();
	regCdcooper = $('.cdcooper', tr).val();
	regDscarga = $('.dscarga', tr).val();
	regDtcarga = $('.dtcarga', tr).val();
	regQtpfcarregados = $('.qtpfcarregados', tr).val();
	regQtpjcarregados = $('.qtpjcarregados', tr).val();
	regVllimitetotal = $('.vllimitetotal', tr).val();
	regDssituac = $('.dssituac', tr).val();
	regDthorini = $('.dthorini', tr).val();
	regDthorfim = $('.dthorfim', tr).val();

	if (regDssituac == "Importada" || regDssituac == "Gerada") {
		$('#btRejeitar').removeClass('adisabled');
	} else {
		$('#btRejeitar').addClass('adisabled');
	}

	if (regDssituac == "Importada") {
		$('#btLiberar').removeClass('adisabled');
	} else {
		$('#btLiberar').addClass('adisabled');
	}
	
	if (regDssituac == "Gerada") {
		$('#btImportar').removeClass('adisabled');
	} else {
		$('#btImportar').addClass('adisabled');
	}
	
    return false;
}

function btnVoltar() {
	estadoInicial();
	return false;
}

function btnExecutarCarga(cddopcao) {
	
	showMsgAguardo('Aguarde, carregando...');
	
	var acao = 'rejeitar';
	var funcao = 'justificativa();';

	if (regSkcarga) {
		if (cddopcao == "I") {
			acao = 'importar';
			funcao = 'cargaSAS(\'I\');';
		} else if (cddopcao == "L") {
			acao = 'liberar';
			funcao = 'cargaSAS(\'L\');';
		}

		showConfirmacao('Deseja realmente '+acao+' a carga do Pré-Aprovado selecionada?','Confirma&ccedil;&atilde;o - Aimaro','bloqueiaFundo(divRotina);'+funcao,'hideMsgAguardo();','sim.gif','nao.gif');
	} else {
        showError('error','Selecione pelo menos uma Carga para execução.','Alerta - Ayllos',"hideMsgAguardo();");
	}

    return false;
}

/* Acessar tela principal da rotina */
function justificativa() {

	showMsgAguardo('Aguarde, carregando...');
    $.ajax({
        dataType: "html",
        type: "POST",
        url: UrlSite + "telas/imppre/cadastro_carga.php",
        data: {
            skcarga: regSkcarga,
			cdcooper: regCdcooper,
			dscarga: regDscarga,
            redirect: "html_ajax"
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Ayllos", "bloqueiaFundo(divRotina);");
        },
        success: function (response) {
            mostraRotina();
            $("#divRotina").html(response);
            //atualizaSeletor();
            hideMsgAguardo();
			bloqueiaFundo(divRotina);
        }
    });
    return false;
}

function cargaSAS(cddopcao) {

	showMsgAguardo('Aguarde, carregando...');
	
	if (cddopcao == "R") {
		var regDsrejeicao = $("#dsrejeicao", "#frmDados").val();
	}

	$.ajax({
        type: "POST",
        dataType: "html",
        url: UrlSite + "telas/imppre/executa_cargas_sas.php",
        data: {
            skcarga: regSkcarga,
			cddopcao: cddopcao,
			dsrejeicao: regDsrejeicao,
            redirect: "html_ajax"
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Ayllos", "");
        },
        success: function (retorno) {
			eval(retorno);
        }
    });
    return false;

}

// Monta Grid Inicial
function uploadCargas(operacao) {
    $.ajax({
        type: "POST",
        dataType: "html",
        url: UrlSite + "telas/imppre/upload_cargas_sas.php",
        data: {
			operacao: operacao,
            redirect: "html_ajax"
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Ayllos", "");
        },
        success: function (response) {
            $('#divDetalhes').html(response).css("display","block");

			divListMsg = $("#divListMsg");
			divListMsg.hide();
        }
    });
    return false;
}

function enviarCargas(operacao) {

	var mensagem = 'Aguarde, validando arquivo ...';
	var cUserFile;

	var formEnvia	= $('#frmArquivo');
	var cDsArquivo	= $('#userfile','#frmArquivo');
	var rDsArquivo	= $('label[for="userfile"]','#frmArquivo');
	var sidlogin	= $('#sidlogin','#frmMenu').val();

	// Remove propriedades dos campos
	cDsArquivo.removeClass('campoErro');

	// Link para o action do formulario
	action = UrlSite + 'telas/imppre/upload_cargas_sas_rotina.php';

	// Se o campo de comprovante estiver sem valor informado
	if (cDsArquivo.val().length == 0) {
		showError("error",'Arquivo a ser carregado deve ser informado.',"Alerta - Ayllos","focaCampoErro('userfile','frmArquivo')");
		return false; 
	}
	cUserFile = cDsArquivo;

	// Incluir o campo de login para validação (campo necessario para validar sessao)
	$('#sidlogin',formEnvia).remove();
	formEnvia.append('<input type="hidden" id="sidlogin" name="sidlogin" />');
	$('#sidlogin',formEnvia).val( sidlogin );

	// Incluir o campo de operacao (campo necessario para direcionar Upload SAS (M) ou Exclusão por CSV (E) )
	$('#operacao',formEnvia).remove();
	formEnvia.append('<input type="hidden" id="operacao" name="operacao" />');
	$('#operacao',formEnvia).val( operacao );

	// Configuro o formulário para posteriormente submete-lo
	formEnvia.attr('method','post');
	formEnvia.attr('action',action);
	formEnvia.attr('target','frameBlank');

	// Mensagem de aguardo...
	showMsgAguardo(mensagem);

	// Limpa a lista de erro e faz o submit do formulário
	$('#divListErr').html('');
	formEnvia.submit();

	return false;
}

function msgError(tipo,msg,callback){
	showError(tipo,msg,"Alerta - Ayllos",callback);
}

function formataTabListMsg(operacao) {

	var divRegistro = $('div.divRegistros','#divRegistrosCargas');		
	var tabela      = $('table',divRegistro);
	var linha       = $('table > tbody > tr',divRegistro);

	divRegistro.css({'height':'220px'});

	var ordemInicial = new Array();
	ordemInicial = [[0,0]];

	// Se a opção selecionada for comprovante

	//divListMsg.css({'width':'900px'});
	//divRegistro.css({'width':'900px'});

	var arrayLargura = new Array();
	var arrayAlinha = new Array();

	if (operacao == 'L') {

		arrayLargura[0] = '35px';
		arrayLargura[1] = '70px';
		arrayLargura[2] = '150px';
		arrayLargura[3] = '';
		arrayLargura[4] = '35px';
		arrayLargura[5] = '35px';
		arrayLargura[6] = '35px';
		arrayLargura[7] = '70px';
		arrayLargura[8] = '70px';
		arrayLargura[9] = '70px';
		arrayLargura[10] = '35px';

		arrayAlinha[0] = 'center';
		arrayAlinha[1] = 'center';
		arrayAlinha[2] = '';
		arrayAlinha[3] = '';
		arrayAlinha[4] = 'center';
		arrayAlinha[5] = 'center';
		arrayAlinha[6] = 'center';
		arrayAlinha[7] = 'right';
		arrayAlinha[8] = 'right';
		arrayAlinha[9] = 'right';
		arrayAlinha[10] = 'center';

		$('tfoot td',tabela).css({"padding":"0px 5px","border-right":"1px dotted #999","font-size":"12px","color":"#333"});

	} else {

		arrayLargura[0] = '50px';
		arrayLargura[1] = '90px';
		arrayLargura[2] = '90px';
		arrayLargura[3] = '120px';
		arrayLargura[4] = '';

		arrayAlinha[0] = 'center';
		arrayAlinha[1] = 'center';
		arrayAlinha[2] = 'center';
		arrayAlinha[3] = 'center';
		arrayAlinha[4] = 'left';

	}

	if (operacao == 'L') {

		// seleciona o registro que é clicado
		$(linha).click(function () {
			selecionaTabelaErro($(this));
		}).focus();

	}

	tabela.formataTabelaIMPPRE( ordemInicial, arrayLargura, arrayAlinha);

	hideMsgAguardo();
	bloqueiaFundo( $('#divRotina') );

	return false;
}

function selecionaTabelaErro(tr) {
	var regQtdErros = $('input[name="qtderros"]', tr).val();
	var regIdLinha = $('input[name="idlinha"]', tr).val();
	var regBloqCarga = $('div#divRegistrosCargas div').data('value');

	if (regQtdErros > 0) {
		$('#btErros').removeClass('adisabled');
		regTableCoop = $('table#cooperados'+regIdLinha, '#divRegistrosCoop').closest("div").clone();
	} else {
		$('#btErros').addClass('adisabled');
		regTableCoop = "";
	}

	if(regQtdErros == 0 && $('#btImpCargas').data('flgbloqcarga') == "N"){
		$('#btImpCargas').removeClass('adisabled');
	}else{
		$('#btImpCargas').addClass('adisabled');
	}

    return false;
}

function btnErros() {

	showMsgAguardo('Aguarde, carregando...');
    $.ajax({
        dataType: "html",
        type: "POST",
        url: UrlSite + "telas/imppre/carga_manual_erros.php",
        data: {
            redirect: "html_ajax"
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Ayllos", "bloqueiaFundo(divRotina);");
        },
        success: function (response) {
            mostraRotina();
            $("#divRotina").html(response);
			$("#divConteudoOpcao").html(regTableCoop);
			formataTabListErros();
        }
    });
    return false;
}

function formataTabListErros() {

	var divRegistro = $('div.divRegistros','#divConteudoOpcao');
	var tabela      = $('table', divRegistro );
	var linha       = $('table > tbody > tr', divRegistro );

	divRegistro.parent().css({'display':'block'});

	var ordemInicial = new Array();
	ordemInicial = [[0,0]];

	var arrayLargura = new Array();
	arrayLargura[0] = '40px';
	arrayLargura[1] = '50px';
	arrayLargura[2] = '120px';
	arrayLargura[3] = '70px';
	arrayLargura[4] = '70px';
	arrayLargura[5] = '70px';
	arrayLargura[6] = '';

	var arrayAlinha = new Array();
	arrayAlinha[0] = 'center';
	arrayAlinha[1] = 'center';
	arrayAlinha[2] = 'center';
	arrayAlinha[3] = 'center';
	arrayAlinha[4] = 'right';
	arrayAlinha[5] = 'right';
	arrayAlinha[6] = 'left';

	var metodoTabela = '';

	tabela.formataTabelaIMPPRE( ordemInicial, arrayLargura, arrayAlinha, metodoTabela );

	hideMsgAguardo();
	bloqueiaFundo(divRotina);

	return false;
}

function btnImpCargas(operacao, exec) {
	dsarquivo = $("#dsarquiv", "#divListMsg").val();
	dsdiretor = $("#dsdireto", "#divListMsg").val();

	if (exec == "carga") {
		showMsgAguardo('Aguarde, carregando...');
		$.ajax({
			dataType: "html",
			type: "POST",
			url: UrlSite + "telas/imppre/carga_manual_incluir.php",
			data: {
				operacao: operacao,
				dsdiretor: dsdiretor,
				dsarquivo: dsarquivo,
				redirect: "html_ajax"
			},
			error: function (objAjax, responseError, objExcept) {
				hideMsgAguardo();
				showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')) )");
			},
			success: function (response) {
				eval(response);
			}
		});

	} else {
		var msg = "";
		if (operacao == 'L') {
			msg = 'Confirmar a libera&ccedil;&atilde;o? A carga ser&aacute; liberada automaticamente no processo noturno ap&oacute;s a atualiza&ccedil;&atilde;o dos ratings';
		} else {
			msg = 'Voc&ecirc; tem certeza que deseja proceder com a Exclus&atilde;o destes Cooperados?';
		}

		showConfirmacao( msg, 'Confirma&ccedil;&atilde;o - Aimaro', 'btnImpCargas(\''+operacao+'\',\'carga\');', 'hideMsgAguardo();', 'sim.gif', 'nao.gif');
	}
}

function variacaoCargas() {

    //Requisição para montar o form correspondente a opção escolhida
    $.ajax({
        type: "POST",
        url: UrlSite + "telas/imppre/monta_form_filtro_detalhe_carga.php",
        data: {
            redirect: "script_ajax"
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Ayllos", "estadoInicial();");
        },
        success: function (response) {
            hideMsgAguardo();
            if (response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 ) {
                try {
					$('#divDetalhes').html(response).css("display","block");
					formataFiltroCarga();
                    return false;
                } catch (error) {
                    showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message, "Alerta - Ayllos", "estadoInicial();");
                }
            } else {
                try {
					eval(response);
                } catch (error) {
                    showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message, "Alerta - Ayllos", "estadoInicial();");
                }
            }
        }
    });

    return false;

}

function formataFiltroCarga() {

	var divForm = "#divFiltroCarga";

	divListDetVariCargas = $("#divListDetVariCargas");
	divListDetVariCargas.hide();

    //rotulo
    $('label[for="cdcooper"]', divForm).addClass("rotulo").css({ 'width': '100px' });
	$('label[for="tpcarga"]',  divForm).addClass("rotulo-linha").css({ 'width': '103px' });
	$('label[for="indsitua"]', divForm).addClass("rotulo-linha").css({ 'width': '100px' });
    $('label[for="dtlibera"]', divForm).addClass("rotulo").css({ 'width': '100px' });
    $('label[for="dtliberafim"]', divForm).addClass("rotulo-linha").css({ 'width': '20px' });
    $('label[for="dtvigencia"]', divForm).addClass("rotulo-linha").css({ 'width': '100px' , 'padding-left': '190px' });
    $('label[for="dtvigenciafim"]', divForm).addClass("rotulo-linha").css({ 'width': '20px' });
	$('label[for="skcarga"]',  divForm).addClass("rotulo").css({ 'width': '100px' });
	$('label[for="dscarga"]',  divForm).addClass("rotulo-linha").css({ 'width': '100px' });

    // campo
    $('#cdcooper', divForm).css({ 'width': '150px' }).habilitaCampo();
	$('#tpcarga', divForm).css({ 'width': '150px' }).habilitaCampo().val('T');
	$('#indsitua', divForm).css({ 'width': '150px' }).habilitaCampo().val('T');
    $('#dtlibera', divForm).css({ 'width': '80px' }).addClass('data').habilitaCampo();
    $('#dtliberafim', divForm).css({ 'width': '80px' }).addClass('data').habilitaCampo();
    $('#dtvigencia', divForm).css({ 'width': '80px' }).addClass('data').habilitaCampo();
    $('#dtvigenciafim', divForm).css({ 'width': '80px' }).addClass('data').habilitaCampo();
	$('#skcarga', divForm).css({ 'width': '120px' }).addClass('inteiro').attr('maxlength', '15').habilitaCampo();
	$('#dscarga', divForm).css({ 'width': '440px' }).attr('maxlength', '300').habilitaCampo();

    $('#frmFiltroDetVari').css({ 'display': 'block' });
    $('#divBotoes').css({ 'display': 'block' });
    $(divForm).css({ 'display': 'block' });

    $('#btProsseguir', '#divBotoes').css({ 'display': 'inline' });
    $('#btVoltar', '#divBotoes').css({ 'display': 'inline' });

    highlightObjFocus($('#frmFiltroDetVari'));

    //Define ação para o campo cdcooper
    $("#cdcooper", divForm).unbind('keypress').bind('keypress', function (e) {

        $(this).removeClass('campoErro');

        // Se é a tecla ENTER, TAB
        if (e.keyCode == 13 || e.keyCode == 9) {
            $("#tpcarga", divForm).focus();
            return false;
        }

    });

    //Define ação para o campo tpcarga
    $("#tpcarga", divForm).unbind('keypress').bind('keypress', function (e) {

        $(this).removeClass('campoErro');

        // Se é a tecla ENTER, TAB
        if (e.keyCode == 13 || e.keyCode == 9) {
            $("#indsitua", divForm).focus();
            return false;
        }

    });

    //Define ação para o campo indsitua
    $("#indsitua", divForm).unbind('keypress').bind('keypress', function (e) {

        $(this).removeClass('campoErro');

        // Se é a tecla ENTER, TAB
        if (e.keyCode == 13 || e.keyCode == 9) {
            $("#dtlibera", divForm).focus();
            return false;
        }

    });

    //Define ação para o campo dtlibera
    $("#dtlibera", divForm).unbind('keypress').bind('keypress', function (e) {

        $(this).removeClass('campoErro');

        // Se é a tecla ENTER, TAB
        if (e.keyCode == 13 || e.keyCode == 9) {
            $("#skcarga", divForm).focus();
            return false;
        }

    });

    //Define ação para o campo skcarga
    $("#skcarga", divForm).unbind('keypress').bind('keypress', function (e) {

        $(this).removeClass('campoErro');

        // Se é a tecla ENTER, TAB
        if (e.keyCode == 13 || e.keyCode == 9) {
            $("#dscarga", divForm).focus();
            return false;
        }

    });

    //Define ação para o campo dtlibera
    $("#dscarga", divForm).unbind('keypress').bind('keypress', function (e) {

        $('input,select').removeClass('campoErro');

        // Se é a tecla ENTER, TAB
        if (e.keyCode == 13 || e.keyCode == 9) {
            $("#btProsseguir", "#divBotoes").click();
            return false;
        }

    });

    //Define ação para CLICK no botão de Concluir
    $("#btProsseguir", "#divBotoes").unbind('click').bind('click', function () {
        buscaDetVariCargas(1,20);
        return false;
    });

    //Define ação para CLICK no botão de Voltar
    $("#btVoltar", "#divBotoes").unbind('click').bind('click', function () {
        estadoInicial();
        return false;
    });

    $("#cdcooper", divForm).focus();

    layoutPadrao();

}

function buscaDetVariCargas(nriniseq, nrregist) {

	var mensagem = 'Aguarde, buscando registros ...';

	var sidlogin	= $('#sidlogin','#frmMenu').val();
	var formEnvia	= $('#frmFiltroDetVari');

	// Link para o action do formulario
	action = UrlSite + 'telas/imppre/det_vari_cargas_rotina.php';

	// Configuro o formulário para posteriormente submete-lo
	formEnvia.attr('method', 'post');
	formEnvia.attr('action', action);
	formEnvia.attr('target', 'frameBlank');

	$('#sidlogin',formEnvia).remove();
	formEnvia.append('<input type="hidden" id="sidlogin" name="sidlogin" />');
	$('#sidlogin',formEnvia).val( sidlogin );

	if (nriniseq) {
		$('#nriniseq',formEnvia).remove();
		formEnvia.append('<input type="hidden" id="nriniseq" name="nriniseq" />');
		$('#nriniseq',formEnvia).val( nriniseq );
	}
	if (nrregist) {
		$('#nrregist',formEnvia).remove();
		formEnvia.append('<input type="hidden" id="nrregist" name="nrregist" />');
		$('#nrregist',formEnvia).val( nrregist );
	}

	// Mensagem de aguardo...
	showMsgAguardo(mensagem);

	formEnvia.submit();

	return false;
}

function formataListDetVariCargas(nriniseq, nrregist) {

	var divRegistro = $('div.divRegistros','#divRegistrosHistorCargas');
	var tabela      = $('table', divRegistro );
	var linha       = $('table > tbody > tr', divRegistro );
	var formEnvia	= $('#frmFiltroDetVari');

	divRegistro.parent().css({'display':'block'});
		
	// CARD 6.2.27 David Valente [Envolti]
	// 22/04/2019
	// HACK PARA ajustar a tela conforme os registro, até 20 linhas na tabela nao gera barra de rolagem
	divRegistro.css({'display'   :'block',
					 'min-height':'100%', 
					 'height'    :'auto'});

	$('a.paginacaoAnterior').unbind('click').bind('click', function() {
        buscaDetVariCargas( (nriniseq - nrregist) , nrregist );
    });

    $('a.paginacaoProximo').unbind('click').bind('click', function() {
        buscaDetVariCargas( (nriniseq + nrregist) , nrregist );
    });

    $('#divPesquisaRodape', '#divTela').formataRodapePesquisa();

	var ordemInicial = new Array();
	//ordemInicial = [[0,0]];

	var arrayLargura = new Array();
	arrayLargura[0] = '110px';
	arrayLargura[1] = '50px';
	arrayLargura[2] = '50px';
	arrayLargura[3] = '';
	arrayLargura[4] = '50px';
	arrayLargura[5] = '65px';
	arrayLargura[6] = '65px';
	arrayLargura[7] = '50px';
	arrayLargura[8] = '100px';

	var arrayAlinha = new Array();
	arrayAlinha[0] = 'center';
	arrayAlinha[1] = 'center';
	arrayAlinha[2] = 'center';
	arrayAlinha[3] = '';
	arrayAlinha[4] = 'center';
	arrayAlinha[5] = 'right';
	arrayAlinha[6] = 'right';
	arrayAlinha[7] = 'right';
	arrayAlinha[8] = 'right';

	// seleciona o registro que é clicado
	$(linha).click(function () {
		selecionaTabelaDetVariCarga($(this));
	}).focus();

	tabela.formataTabelaIMPPRE( ordemInicial, arrayLargura, arrayAlinha );

	hideMsgAguardo();
	bloqueiaFundo( $('#divRotina') );

    /* Atribuindo o foco para a linha da tabela, pois ao clicar no cabecalho nao retornava
     para linha da tabela, dessa maneira a tela apresentava erro na hora de alterar ou
     excluir o registro selecionado * /

    $('table > thead > tr > th', divRegistro).click(function () {
        $('tr#'+idcarga, divRegistro).focus();
    });

    // seleciona o registro que é clicado
    $(linha).click(function () {
        selecionaTabelaDetVariCarga($(this));
    });

    // seleciona o registro que é focado
    $(linha).focus(function () {
        selecionaTabelaDetVariCarga($(this));
    });

	$(linha).not('#nada').children().first().trigger('click');
*/
	return false;
}

function selecionaTabelaDetVariCarga(tr) {

    idcarga 	= $('input[name="idcarga"]', tr).val();
    vlrmediapar = $('input[name="vlrmediapar"]', tr).val();
	qtregispf 	= $('input[name="qtregispf"]', tr).val();
	qtregispj 	= $('input[name="qtregispj"]', tr).val();
    vlrparmax 	= $('input[name="vlrparmax"]', tr).val();
	vlmincarga 	= $('input[name="vlmincarga"]', tr).val();
    qtremovman 	= $('input[name="qtremovman"]', tr).val();
	pervariault = $('input[name="pervariault"]', tr).val();
	pervarapri 	= $('input[name="pervarapri"]', tr).val();
	cdcooper 	= $('input[name="cdcooper"]', tr).val();
	dssitua		= $('td.dssitua span', tr).text();
	tpcarga     = $('input[name="tpcarga"]', tr).val();
	glbcoop     = $('input[name="glbcoop"]', tr).val();

	if (glbcoop == 3) {
	    $('#btBloquear').removeClass('adisabled');
	} else {
	    if (tpcarga == "Manual") {
	        $('#btBloquear').removeClass('adisabled');
	    } else {
	        $('#btBloquear').addClass('adisabled');
	    }
	}

	if (dssitua == "Rejeit.") {
	    $('#btExportar').addClass('adisabled');
	    $('#btBloquear').addClass('adisabled');
	}

    return false;
}

function btnDetalhes() {

	showMsgAguardo('Aguarde, carregando...');
    $.ajax({
        dataType: "html",
        type: "POST",
        url: UrlSite + "telas/imppre/carga_manual_erros.php",
        data: {
			operacao: "D", //tela Detalhe
            redirect: "html_ajax"
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')) )");
        },
        success: function (response) {
            mostraRotina();
            $("#divRotina").html(response);
			formataTabDetvariCarga();
        }
    });
    return false;

}

function formataTabDetvariCarga() {

	var divForm = "#frmDetVaricarga";
	
	$('label', divForm).css({ 'height':'unset', 'text-align':'center', 'width': '200px', 'margin':'10px 10px 0 0' });
	$('input[type=text]', divForm).addClass('campo').attr({'readonly':'readonly'}).css({ 'width': '200px' });

    //rotulo
    $('label[for="vlrmediapar"]', divForm).addClass("rotulo");
	$('label[for="qtregispf"]',   divForm).addClass("rotulo-linha");
	$('label[for="qtregispj"]',   divForm).addClass("rotulo-linha");
    $('label[for="vlrparmax"]',   divForm).addClass("rotulo").css({ 'clear':'left' });
	$('label[for="vlmincarga"]',  divForm).addClass("rotulo-linha");
    $('label[for="qtremovman"]',  divForm).addClass("rotulo").css({ 'clear':'left', "height" : "50px"});
	$('label[for="pervariault"]', divForm).addClass("rotulo-linha").css({ 'clear':'left', "height" : "50px"});
	$('label[for="pervarapri"]',  divForm).addClass("rotulo-linha").css({ 'clear':'left', "height" : "50px"});

    $('input#vlrmediapar', 	divForm).val(vlrmediapar);
	$('input#qtregispf', 	divForm).val(qtregispf);
	$('input#qtregispj', 	divForm).val(qtregispj);
    $('input#vlrparmax', 	divForm).val(vlrparmax);
	$('input#vlmincarga', 	divForm).val(vlmincarga);
    $('input#qtremovman', 	divForm).val(qtremovman);
	$('input#pervariault', 	divForm).val(pervariault);
	$('input#pervarapri', 	divForm).val(pervarapri);

    $(divForm).css({ 'display': 'block' });

    highlightObjFocus($(divForm));

	hideMsgAguardo();
	bloqueiaFundo(divRotina);
}

function btnBloquear() {
	showMsgAguardo('Aguarde, carregando...');
	
	var acao = "desbloquear";
	if (dssitua == "Ativa") {
		acao = "bloquear";
	}

	showConfirmacao('Deseja '+acao+' a carga do Pré-Aprovado selecionada?','Confirma&ccedil;&atilde;o - Aimaro','bloqueiaFundo(divRotina);confirmBloquear();','hideMsgAguardo();','sim.gif','nao.gif');
}

function confirmBloquear() {
	showMsgAguardo('Aguarde, carregando...');
    $.ajax({
        dataType: "html",
        type: "POST",
        url: UrlSite + "telas/imppre/det_vari_cargas_rotina.php",
        data: {
			operacao: "B", //operacao Bloquear
			idcarga: idcarga,
            redirect: "html_ajax"
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Ayllos", "blockBackground(parseInt( $('#divRotina').css('z-index')) )");
        },
        success: function (response) {
            //eval(response);

            $("#divRotina").html(response);
        }
    });
    return false;
}

function btnExportar() {
	
	var formEnvia	= $('#frmFiltroDetVari');
	var inputs		= formEnvia.serialize();

	var values = {};
	$.each(inputs, function(i, field) {
		values[field.name] = field.value;
	});

	showMsgAguardo('Aguarde, carregando...');
    $.ajax({
        dataType: "html",
        type: "POST",
        url: UrlSite + "telas/imppre/det_vari_cargas_rotina.php",
        data: {
			operacao: "CSV", //operacao Exportar
			idcarga: idcarga,
            redirect: "html_ajax"
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')) )");
        },
        success: function (response) {
            //eval(response);
			
            $("#divRotina").html(response);
        }
    });

    return false;
}

function Gera_Impressao(nmarquivo, callback) {

    hideMsgAguardo();

	dsform = 'frmFiltroDetVari';

    var action = UrlSite + 'telas/imppre/download_arquivo.php';

    $('#nmarquivo', '#'+dsform).remove();
    $('#sidlogin', '#'+dsform).remove();
    $('#opcao', '#'+dsform).remove();

    $('#'+dsform).append('<input type="hidden" id="nmarquivo" name="nmarquivo" value="' + nmarquivo + '" />');
    $('#'+dsform).append('<input type="hidden" id="sidlogin" name="sidlogin" value="' + $('#sidlogin', '#frmMenu').val() + '" />');
    $('#'+dsform).append('<input type="hidden" id="opcao" name="opcao" value="' + $('#cddopcao', '#frmCabMovrgp').val() + '" />');

    carregaImpressaoAyllos(dsform, action, callback);

    return false;

}

$.fn.extend({

	formataTabelaIMPPRE: function(ordemInicial, larguras, alinhamento, metodoDuploClick ) {

		var tabela = $(this);

		// Forma personalizada de extração dos dados para ordenação, pois para números e datas os dados devem ser extraídos para serem ordenados
		// não da forma que são apresentados na tela. Portanto adotou-se o padrão de no início da tag TD, inserir uma tag SPAN com o formato do 
		// dado aceito para ordenação
		var textExtraction = function(node) {
			if ( $('span', node).length == 1 ) {
				return $('span', node).html();
			} else {
				return node.innerHTML;
			}
		}

		// Configurações para o Sorter
		tabela.has("tbody > tr").tablesorter({ 
			sortList         : ordemInicial,
			textExtraction   : textExtraction,
			widgets          : ['zebra'],
			cssAsc			 : 'headerSortUp',
			cssDesc          : 'headerSortDown',
			cssHeader  		 : 'headerSort'
		});

		// O thead no IE não funciona corretamento, portanto ele é ocultado no arquivo "estilo.css", mas seu conteúdo
		// é copiado para uma tabela fora da tabela original
		var divRegistro = tabela.parent();
		divRegistro.before('<table class="tituloRegistros"><thead>'+$('thead', tabela ).html()+'</thead></table>');		

		var tabelaTitulo = $( 'table.tituloRegistros',divRegistro.parent() );	

		// $('thead', tabelaTitulo ).append( $('thead', tabela ).html() );
		$('thead > tr', tabelaTitulo ).append('<th class="ordemInicial"></th>');

		// Formatando - Largura 
		if (typeof larguras != 'undefined') {
			for( var i in larguras ) {
				$('td:nth-of-type('+(parseInt(i) + parseInt(1))+')', tabela ).css('width', larguras[i] );
				$('th:eq('+i+')', tabelaTitulo ).css('width', larguras[i] );
			}		
		}

		// Calcula o número de colunas Total da tabela
		var nrColTotal = $('thead > tr > th', tabela ).length;

		// Formatando - Alinhamento
		if (typeof alinhamento != 'undefined') {
			for( var i in alinhamento ) {
				var nrColAtual = i;
				nrColAtual++;
				//alert('td:nth-child('+nrColTotal+'n+'+nrColAtual+')');
				$('td:nth-child('+nrColTotal+'n+'+nrColAtual+')', tabela ).css('text-align', alinhamento[i] );		
			}		
		}

		// Controla Click para Ordenação
		$('th', tabelaTitulo ).each( function(i) {
			$(this).mousedown( function() {
				if( $(this).hasClass('ordemInicial') ) {
					tabela.has("tbody > tr").tablesorter({ sortList: ordemInicial }).tablesorter({ sortList: ordemInicial });
				} else {
					$('th:eq('+i+')',divRegistro).click();
				}
			});
			$(this).mouseup( function() {

				$('table > tbody > tr', divRegistro).each( function(i) {
					$(this).click(function () {
						$('table', divRegistro).zebraTabela( i );
					});
				});

				$('th', tabela ).each( function(i) {
					var classes = $(this).attr('class');
					if ( classes != 'ordemInicial' ) {
						$('th:eq('+i+')', tabelaTitulo ).removeClass('headerSort headerSortUp headerSortDown');
						$('th:eq('+i+')', tabelaTitulo ).addClass( classes );
					}
				});

				$('tr.corSelecao',divRegistro).click();
			});
		});

		$('table > tbody > tr', divRegistro).each( function(i) {
			$(this).bind('click', function() {
				$('table', divRegistro).zebraTabela( i );
			});
		});

		if ( typeof metodoDuploClick != 'undefined' ) {	
			$('table > tbody > tr', divRegistro).dblclick( function() {
				eval( metodoDuploClick );
			});	

			$('table > tbody > tr', divRegistro).keypress( function(e) {
				if ( e.keyCode == 13 ) {
					eval( metodoDuploClick );
				}
			});
		}

		$('td:nth-of-type('+nrColTotal+'n)', tabela ).css('border','0px');

		// Iniciar com a primeira linha selecionado e retornar o valor da chave deste primerio registro, que se encontra no input do tipo hidden
		tabela.zebraTabela(0);
		
		$('tr.corSelecao',divRegistro).click();
		return true;
	}
});
