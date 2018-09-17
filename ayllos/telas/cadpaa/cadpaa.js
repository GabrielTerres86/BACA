/*!
 * FONTE        : imovel.js
 * CRIAÇÃO      : Renato Darosci (Supero) 
 * DATA CRIAÇÃO : 07/06/2016
 * OBJETIVO     : Biblioteca de funções da tela IMOVEL
 * --------------
 * ALTERAÇÕES   :
 * --------------
 * [  /  /    ]                   : 
 */

//Formulários e Tabela
var frmCab = 'frmCab';
var frmOpcao = 'frmOpcao';

var cddopcao = 'C';

var nrJanelas = 0;
var nriniseq = 1;
var nrregist = 50;
var incontrol = true;

// Campos da tela 
var cCdcooper, cCdpa_admin, cDspa_admin, cTprateio, cFlgativo, cDSDtinclus, cDSDsinclus, cDSDtaltera, cDSDsaltera, cDSDtinativ, cDSDsinativ;

// Chamar as funções de iniciação para a tela
$(document).ready(function() {
    estadoInicial();
});

$.fn.extend({ 
    
    desabilitaCheckbox: function() {
        return this.each(function() {	          
            $(this).prop('readonly',true).prop('disabled',true).removeClass('checkboxFocusIn');                    
        });		
    },
    
    habilitaCheckbox: function() {
        return this.each(function() {	          
            $(this).prop('readonly',false).prop('disabled',false).removeClass('checkboxFocusIn');
        });		
    }
});

// Configura o estado inicial da tela
function estadoInicial() {

    $('#divTela').fadeTo(0, 0.1);

    // retira as mensagens	
    hideMsgAguardo();

    // formulario	
    formataCabecalho();
    cTodosCabecalho.limpaFormulario().removeClass('campoErro');
	cTodosTela.limpaFormulario().removeClass('campoErro');

    $('#' + frmOpcao).remove();
    $('#divBotoes').remove();
    $('#divPesquisaRodape', '#divTela').remove();

    cCddopcao.val(cddopcao);
    cCddopcao.focus();

    removeOpacidade('divTela');
}

// Montar o formulário da tela conforme a opção selecionada
function buscaOpcao() {

    showMsgAguardo('Aguarde, buscando dados ...');
	
    // Executa script de confirmação através de ajax
    $.ajax({
        type: 'POST',
        dataType: 'html',
        url: UrlSite + 'telas/cadpaa/form_cadastro.php',
        data: {
            redirect: 'html_ajax'
        },
        error: function(objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError('error', 'Não foi possível concluir a requisição.', 'Alerta - Ayllos', "unblockBackground()");
        },
        success: function(response) {
            $('#divTela').html(response);
            
            formataCabecalho();

            cCddopcao.desabilitaCampo();
            cCddopcao.val(cddopcao);

            // limpa formulario
            cTodosOpcao = $('input[type="text"], select', '#' + frmOpcao);
            cTodosOpcao.limpaFormulario().removeClass('campoErro');
            $('#divPesquisaRodape', '#divTela').remove();
			
			formataOpcao();
            
			hideMsgAguardo();
            return false;
        }
    });

    return false;

}

// Formatar os campos para o layout da opção selecionada
function formataOpcao() {
	
    // Declarar os campos da tela
	cCdcooper   = $('#cdcooper', '#' + frmOpcao);
	cCdpa_admin = $('#cdpa_admin', '#' + frmOpcao);
	cDspa_admin = $('#dspa_admin', '#' + frmOpcao);
	cTprateio	= $('#tprateio', '#' + frmOpcao);
	cFlgativo   = $('#flgativo', '#' + frmOpcao);
	// Campos de log
	cDSDtinclus = $('#ds_dtinclus', '#' + frmOpcao);
	cDSDsinclus = $('#ds_dsinclus', '#' + frmOpcao);
	cDSDtaltera = $('#ds_dtaltera', '#' + frmOpcao);
	cDSDsaltera = $('#ds_dsaltera', '#' + frmOpcao);
	cDSDtinativ = $('#ds_dtinativ', '#' + frmOpcao);
	cDSDsinativ = $('#ds_dsinativ', '#' + frmOpcao);
	
	// Declarar os labels da tela 
	var rCdcooper = $('label[for="cdcooper"]', '#' + frmOpcao);
	var rCdpa_admin = $('label[for="cdpa_admin"]', '#' + frmOpcao);
	var rDspa_admin = $('label[for="dspa_admin"]', '#' + frmOpcao);
	var rTprateio = $('label[for="tprateio"]', '#' + frmOpcao);
	var rFlgativo = $('label[for="flgativo"]', '#' + frmOpcao);
	var rDSDtinclus = $('label[for="ds_dtinclus"]', '#' + frmOpcao);
	var rDSDsinclus = $('label[for="ds_dsinclus"]', '#' + frmOpcao);
	var rDSDtaltera = $('label[for="ds_dtaltera"]', '#' + frmOpcao);
	var rDSDsaltera = $('label[for="ds_dsaltera"]', '#' + frmOpcao);
	var rDSDtinativ = $('label[for="ds_dtinativ"]', '#' + frmOpcao);
	var rDSDsinativ = $('label[for="ds_dsinativ"]', '#' + frmOpcao);
	
	
	// Formatar campos da tela
	cCdcooper.addClass('campo').css({ 'width': '200px' });	
	cCdpa_admin.addClass('campo').css({ 'width': '60px' }).addClass('inteiro').setMask('INTEGER','z.zzz.zzz.zzz','.','');	
	cDspa_admin.addClass('campo').css({ 'width': '400px' }).css({'text-transform':'uppercase'});
	cTprateio.addClass('campo').css({ 'width': '120px' });
	// Formatar os campos de log
	cDSDtinclus.addClass('campo').css({ 'width': '70px' });
	cDSDsinclus.addClass('campo').css({ 'width': '450px' });
	cDSDtaltera.addClass('campo').css({ 'width': '70px' });
	cDSDsaltera.addClass('campo').css({ 'width': '450px' });
	cDSDtinativ.addClass('campo').css({ 'width': '70px' });
	cDSDsinativ.addClass('campo').css({ 'width': '450px' });
	
	// Formatar labels da tela
	rCdcooper.addClass('rotulo').css({ 'width': '80px' });
	rCdpa_admin.addClass('rotulo').css({ 'width': '80px' });
	rDspa_admin.addClass('rotulo-linha').css({ 'width': '75px' });
	rTprateio.addClass('rotulo').css({ 'width': '80px' });
	rFlgativo.addClass('rotulo-linha').css({ 'width': '50px' });
	rDSDtinclus.addClass('rotulo').css({ 'width': '80px' });
	rDSDsinclus.addClass('rotulo-linha').css({ 'width': '0px' });
	rDSDtaltera.addClass('rotulo').css({ 'width': '80px' });
	rDSDsaltera.addClass('rotulo-linha').css({ 'width': '0px' });
	rDSDtinativ.addClass('rotulo').css({ 'width': '80px' });
	rDSDsinativ.addClass('rotulo-linha').css({ 'width': '0px' });
	
	// Campos de log estarão sempre desabilitados
	cDSDtinclus.desabilitaCampo();
	cDSDsinclus.desabilitaCampo();
	cDSDtaltera.desabilitaCampo();
	cDSDsaltera.desabilitaCampo();
	cDSDtinativ.desabilitaCampo();
	cDSDsinativ.desabilitaCampo();
	
	// Listar as cooperativa na tela
	lista_coop();
	// Listas os tipos de raterio na tela
	lista_rateio();
	
	highlightObjFocus($('#' + frmOpcao));
	
    switch (cddopcao) {
        case 'C':
		case 'A':
		case 'R':
			cDspa_admin.desabilitaCampo();
			cTprateio.desabilitaCampo();
			cFlgativo.desabilitaCheckbox();
			
			trocaBotao('CONSULTAR');
			
			break;
		case 'I':
			trocaBotao('SALVAR');
			cFlgativo.prop( "checked", true );
			cFlgativo.desabilitaCheckbox();
			break;
    }
    
	// Realiza o select ao realizar o foco para o campo
	cCdpa_admin.focus(function () {
					this.select();
				});
	
	// Configurar a navegação com enter na tela
	configuraNavegacao();
	
	// Setar o foco no campo da cooperativa
	cCdcooper.focus();
	
    layoutPadrao();
	
	return false;
}

function configuraNavegacao() {
	
	// Cooperativa
	cCdcooper.unbind('keydown').bind('keydown', function(e) {
		if (divError.css('display') == 'block') { return false; }
		
        // Se é a tecla ENTER
        if (e.keyCode == 13) {
            cCdpa_admin.focus();
            return false;
        }
    });
	
	// Definir ação para o campo de código
	cCdpa_admin.unbind('keydown').bind('keydown', function(e) {
		if (divError.css('display') == 'block') { return false; }
		
        // Se é a tecla ENTER
        if (e.keyCode == 13) {
			if (cddopcao == 'I') {
				cDspa_admin.focus();
			} else {
				botaoAcao.click();
				cCdpa_admin.focus();
			}
            return false;
        }
    });
	
	cDspa_admin.unbind('keydown').bind('keydown', function(e) {
		if (divError.css('display') == 'block') { return false; }
		
        // Se é a tecla ENTER
        if (e.keyCode == 13) {
            cTprateio.focus();
            return false;
        }
    });
	
	cTprateio.unbind('keydown').bind('keydown', function(e) {
		if (divError.css('display') == 'block') { return false; }
		
        // Se é a tecla ENTER
        if (e.keyCode == 13) {
			if (cddopcao == 'I') {
				botaoAcao.focus();
			} else {
				cFlgativo.focus();
			}
            return false;
        }
    });
	
	cFlgativo.unbind('keydown').bind('keydown', function(e) {
		if (divError.css('display') == 'block') { return false; }
		
        // Se é a tecla ENTER
        if (e.keyCode == 13) {
            botaoAcao.focus();
            return false;
        }
    });
	
}

// Formatar o cabecalho
function formataCabecalho() {

    // Label
    rCddopcao = $('label[for="cddopcao"]', '#' + frmCab);
    rCddopcao.css({'width': '120px'}).addClass('rotulo');

    // Input
    cCddopcao = $('#cddopcao', '#' + frmCab);
    cCddopcao.css({'width': '450px'});
	
    // Outros	
    cTodosCabecalho = $('input[type="text"], select', '#' + frmCab);
    btnOK1 = $('#btnOk1', '#' + frmCab);
    cTodosCabecalho.habilitaCampo();
    cTodosTela = $('input[type="text"], select', '#' + frmOpcao);
	
    // Se clicar no botao OK
    btnOK1.unbind('click').bind('click', function() {

        if (divError.css('display') == 'block') {
            return false;
        }
        if (cCddopcao.hasClass('campoTelaSemBorda')) {
            return false;
        }

        //
        cCddopcao.desabilitaCampo();
        cddopcao = cCddopcao.val();

        //		
        buscaOpcao();
        return false;

    });


    // 
    cCddopcao.unbind('keydown').bind('keydown', function(e) {
        if (divError.css('display') == 'block') {
            return false;
        }

        // Se é a tecla ENTER
        if (e.keyCode == 13) {
            btnOK1.click();
            return false;
        }

    });
	
    layoutPadrao();
    //controlaPesquisas();
    return false;
}

// FUNÇÕES DOS BOTÕES DA TELA
// Controla o botão Voltar
function btnVoltar() {

    estadoInicial();

    //controlaPesquisas();
    return false;
}

// Função chamada pelo botão salvar para salvar os dados do imóvel informado em tela
function btnSalvar() {

    hideMsgAguardo();
	cTodosTela.removeClass('campoErro');
    
	// Cooperativa
    var vr_cdcooper = (cCdcooper.prop('selectedIndex') == -1) ? "" : cCdcooper.val();
    if (vr_cdcooper == "") {
        showError("error", "Cooperativa deve ser informada.", "Alerta - Ayllos", "hideMsgAguardo();focaCampoErro('" + cCdcooper.attr('name') + "','" + frmOpcao + "');");
        return false;
    }
	
	// Código do PA
    if (cCdpa_admin.val() == "" || cCdpa_admin.val() == "0") {
        showError("error", "Código do PA deve ser informado.", "Alerta - Ayllos", "hideMsgAguardo();focaCampoErro('" + cCdpa_admin.attr('name') + "','" + frmOpcao + "');");
        return false;
    }
	
	// Descrição do PA
    if (cDspa_admin.val() == "") {
        showError("error", "Descrição do PA deve ser informada.", "Alerta - Ayllos", "hideMsgAguardo();focaCampoErro('" + cDspa_admin.attr('name') + "','" + frmOpcao + "');");
        return false;
    }
	
	// Tipo do Rateio
    var vr_tprateio = (cTprateio.prop('selectedIndex') == -1) ? "" : cTprateio.val();
    if (vr_tprateio == "") {
        showError("error", "Rateio deve ser informado.", "Alerta - Ayllos", "hideMsgAguardo();focaCampoErro('" + cTprateio.attr('name') + "','" + frmOpcao + "');");
        return false;
    }
	
	// Normalizar números
    var vr_cdpaadmi = normalizaNumero(cCdpa_admin.val());
	// Flag ativo - Checkbox
	var vr_flgativo = (cFlgativo.prop('checked') == true) ? 1 : 0;
	
	var ds_usrlsite;
	if (cddopcao == 'I') {
		ds_urlsite = 'telas/cadpaa/db_salvar_dados.php';
	} else { 
		ds_urlsite = 'telas/cadpaa/db_alterar_dados.php';
	}
	
    showMsgAguardo('Aguarde, gravando dados ...');

    $.ajax({
        type: 'POST',
        url: UrlSite + ds_urlsite,
        data: {
            cddopcao: cddopcao,
			cdcooper: vr_cdcooper,
            cdpaadmi: vr_cdpaadmi,
            dspaadmi: cDspa_admin.val(),
            tprateio: vr_tprateio, 
			flgativo: vr_flgativo,
            redirect: 'script_ajax'
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', '');
        },
        success: function (response) {
            try {
                eval(response);
                // Se não encontrar erro
                if (response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1) {
                    try {
                        showError("inform", "Registro salvo com sucesso!", "Alerta - Ayllos", "btnVoltar();");
                        return false;
                    } catch (error) {
                        hideMsgAguardo();
                        showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'unblockBackground()');
                    }
                } else {
                    try {
                        eval(response);
                    } catch (error) {
                        hideMsgAguardo();
                        showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'unblockBackground()');
                    }
                }

                return false;
            } catch (error) {
                hideMsgAguardo();
                showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'estadoInicial();');
            }
        }
    });

}

function btnConsultar() {
	
	cTodosTela.removeClass('campoErro');
	buscaPaAdmin();
	
}

// Chamar a rotina que fará o envio das informações para replicação
function btnReplicar() {
	
	hideMsgAguardo();
    cTodosTela.removeClass('campoErro');
	
	var checkCoop = $('input[name=flgcooper]', '#tabConteudo');
	var listaCoop = $('input[name=cdcooper]', '#tabConteudo');
	
	// Se não há itens na lista
	if (checkCoop.length == 0) {
		showError("error", "Não há cooperativas para replicar.", "Alerta - Ayllos", "hideMsgAguardo();");
        return false;
	}
	
	var indSelecionado = false;
	var listaCooper = '';
	
	// Percorrer todos os itens para agrupar os selecionados
	for (i = 0;i < checkCoop.length;i++) {
		// Se o checkbox foi marcado
		if (checkCoop[i].checked) {
			indSelecionado = true;
			// Adiciona a cooperativa selecionada a lista
			listaCooper += listaCoop[i].value + ';';
		}		
	}
	
	// Se nenhuma cooperativa foi selecionada
	if (!indSelecionado) {
		showError("error", "Nenhuma cooperativa foi selecionada.", "Alerta - Ayllos", "hideMsgAguardo();");
        return false;
	}
	
	var vr_cdcooper = (cCdcooper.prop('selectedIndex') == -1) ? "" : cCdcooper.val();
	var vr_cdpaadmi = normalizaNumero(cCdpa_admin.val());
	
    showMsgAguardo('Aguarde, gravando dados ...');

    $.ajax({
        type: 'POST',
        url: UrlSite + 'telas/cadpaa/db_replicar_dados.php',
        data: {
            cdcooper: vr_cdcooper,
            cdpaadmi: vr_cdpaadmi,
			lscooper: listaCooper,
            redirect: 'script_ajax'
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', '');
        },
        success: function (response) {
            try {
                eval(response);
                // Se não encontrar erro
                if (response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1) {
                    try {
                        showError("inform", "Registros replicados com sucesso!", "Alerta - Ayllos", "btnVoltar();");
                        return false;
                    } catch (error) {
                        hideMsgAguardo();
                        showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'unblockBackground()');
                    }
                } else {
                    try {
                        eval(response);
                    } catch (error) {
                        hideMsgAguardo();
                        showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'unblockBackground()');
                    }
                }

                return false;
            } catch (error) {
                hideMsgAguardo();
                showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'estadoInicial();');
            }
        }
    });
}

// Esta função pode receber por parametro o nome do botão ou literal a ser tratado de forma particular
function trocaBotao(botao) {

    $('#divBotoes', '#divTela').html('');
    $('#divBotoes', '#divTela').append('<a href="#" class="botao" id="btVoltar" onclick="btnVoltar(); return false;">Voltar</a>');

    switch (botao) {
        case 'SALVAR':
            $('#divBotoes', '#divTela').append('&nbsp;<a href="#" class="botao" id="botaoAcao" onclick="btnSalvar(); return false;" >Salvar</a>');
            break;
		case 'CONSULTAR':
			$('#divBotoes', '#divTela').append('&nbsp;<a href="#" class="botao" id="botaoAcao" onclick="btnConsultar(); return false;" >Consultar</a>');
            break;
		case 'REPLICAR':
			$('#divBotoes', '#divTela').append('&nbsp;<a href="#" class="botao" id="botaoAcao" onclick="btnReplicar(); return false;" >Replicar</a>');
            break;
        default:
            if (botao != '') {
                $('#divBotoes', '#divTela').append('&nbsp;<a href="#" class="botao" id="botaoAcao" onclick="btnContinuar(); return false;" >' + botao + '</a>');
            }
    }

    return false;
}

// Formatar a tela para permitir alteração
function formataAltera() {
	
	cCdcooper.desabilitaCampo();
	cCdpa_admin.desabilitaCampo();
	cDspa_admin.habilitaCampo();
	cTprateio.habilitaCampo();
	cFlgativo.habilitaCheckbox();
	
	cDspa_admin.focus();
	
	trocaBotao('SALVAR');
}

function formataReplicar() {
	
	cCdcooper.desabilitaCampo();
	cCdpa_admin.desabilitaCampo();
	cDspa_admin.desabilitaCampo();
	cTprateio.desabilitaCampo();
	cFlgativo.desabilitaCampo();
	
	trocaBotao('REPLICAR');
	 
}

// Busca as cooperativas a serem listadas na tela 
function lista_coop() {

    //mensagem = 'Aguarde, processando ...';

    // Mostra mensagem de aguardo
    //showMsgAguardo(mensagem);

    // Carrega dados da conta através de ajax
    $.ajax({
        type: "POST",
        url: UrlSite + "telas/cadpaa/db_busca_cooperativa.php",
        data: {
            cddopcao: cddopcao,
            redirect: "html_ajax" // Tipo de retorno do ajax
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Ayllos", "");
        },
        success: function (response) {
            hideMsgAguardo();
            try {
                eval(response);
                hideMsgAguardo();
            } catch (error) {
                showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message + ".", "Alerta - Ayllos", "");
            }
        }
    });

}

// Busca as cooperativas a serem listadas na tela 
function lista_rateio() {

    //mensagem = 'Aguarde, processando ...';

    // Mostra mensagem de aguardo
    //showMsgAguardo(mensagem);

    // Carrega dados da conta através de ajax
    $.ajax({
        type: "POST",
        url: UrlSite + "telas/cadpaa/db_busca_rateio.php",
        data: {
            cddopcao: cddopcao,
            redirect: "html_ajax" // Tipo de retorno do ajax
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Ayllos", "");
        },
        success: function (response) {
            hideMsgAguardo();
            try {
                eval(response);
                hideMsgAguardo();
            } catch (error) {
                showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message + ".", "Alerta - Ayllos", "");
            }
        }
    });

}

// Busca os dados do PA administrativo
function buscaPaAdmin() {

	// Cooperativa
    var vr_cdcooper = (cCdcooper.prop('selectedIndex') == -1) ? "" : cCdcooper.val();
    if (vr_cdcooper == "") {
        showError("error", "Cooperativa deve ser informada.", "Alerta - Ayllos", "hideMsgAguardo();focaCampoErro('" + cCdcooper.attr('name') + "','" + frmOpcao + "');");
        return false;
    }
	
	// Código do PA
    if (cCdpa_admin.val() == "" || cCdpa_admin.val() == "0") {
        showError("error", "Código do PA deve ser informado.", "Alerta - Ayllos", "hideMsgAguardo();focaCampoErro('" + cCdpa_admin.attr('name') + "','" + frmOpcao + "');");
        return false;
    }
	var vr_cdpaadmi = normalizaNumero(cCdpa_admin.val());

    mensagem = 'Aguarde, processando ...';

    // Mostra mensagem de aguardo
    showMsgAguardo(mensagem);
	
    // Carrega dados da conta através de ajax
    $.ajax({
        type: "POST",
        url: UrlSite + "telas/cadpaa/db_busca_pa_admin.php",
        data: {
            cddopcao: cddopcao,
			cdcooper: vr_cdcooper,
			cdpaadmi: vr_cdpaadmi,
            redirect: "html_ajax" // Tipo de retorno do ajax
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Ayllos", "");
        },
        success: function (response) {
            hideMsgAguardo();
            try {
                eval(response);
                hideMsgAguardo();
            } catch (error) {
                showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message + ".", "Alerta - Ayllos", "");
            }
        }
    });

}

$.fn.extend({ 
	
	/*!
	 * Formatar a tabela desta tela, sem setar Ordernação
	 */
	formataTabelaCADPAA: function(ordemInicial, larguras, alinhamento, metodoDuploClick ) {

		var tabela = $(this);		
		
		// Forma personalizada de extra??o dos dados para ordena??o, pois para n?meros e datas os dados devem ser extra?dos para serem ordenados
		// n?o da forma que s?o apresentados na tela. Portanto adotou-se o padr?o de no in?cio da tag TD, inserir uma tag SPAN com o formato do 
		// dado aceito para ordena??o
		var textExtraction = function(node) {  
			if ( $('span', node).length == 1 ) {
				return $('span', node).html();
			} else {
				return node.innerHTML;
			}		
		}

		// O thead no IE n?o funciona corretamento, portanto ele ? ocultado no arquivo "estilo.css", mas seu conte?do
		// ? copiado para uma tabela fora da tabela original
		var divRegistro = tabela.parent();
		divRegistro.before('<table class="tituloRegistros"><thead>'+$('thead', tabela ).html()+'</thead></table>');		
		
		var tabelaTitulo = $( 'table.tituloRegistros',divRegistro.parent() );	
		
		// $('thead', tabelaTitulo ).append( $('thead', tabela ).html() );
		$('thead > tr', tabelaTitulo ).append('<th class="ordemInicial"></th>');
		
		
		// Formatando - Largura 
		if (typeof larguras != 'undefined') {
			for( var i in larguras ) {
				$('td:eq('+i+')', tabela ).css('width', larguras[i] );
				$('th:eq('+i+')', tabelaTitulo ).css('width', larguras[i] );
			}		
		}	
		
		// Calcula o n?mero de colunas Total da tabela
		var nrColTotal = $('thead > tr > th', tabela ).length;
		
		//$('td:last-child', tabela ).prop('colspan','2');
		
		// Formatando - Alinhamento
		if (typeof alinhamento != 'undefined') {
			for( var i in alinhamento ) {
				var nrColAtual = i;
				nrColAtual++;
				$('td:nth-child('+nrColTotal+'n+'+nrColAtual+')', tabela ).css('text-align', alinhamento[i] );		
			}		
		}			

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
		
		$('td:nth-child('+nrColTotal+'n)', tabela ).css('border','0px');
		
		// Iniciar com a primeira linha selecionado e retornar o valor da chave deste primerio registro, que se encontra no input do tipo hidden
		tabela.zebraTabela(0);	
		return true;
	}
});

// Formatar a tabela de cooperativas para replicação
function formataResultado() {

    var divRegistro = $('div.divRegistros', '#divReplica');
    var tabConteudo = $('table', '#tabConteudo');
	var divTabela	= $('div.divTabela', '#divReplica');
	
	divTabela.css({'width': '300px'});
	divTabela.css({'margin': '0 auto'});
	
	divRegistro.css({'height': '150px'});
	
    var tabelaHeader = $('table > thead > tr > th', divRegistro);
    var fonteLinha = $('table > tbody > tr > td', divRegistro);

    tabelaHeader.css({'font-size': '11px'});
    fonteLinha.css({'font-size': '11px'});
	
    //$('fieldset','#divReplica').css({'clear': 'both', 'border': '1px solid #777', 'margin': '3px 0px', 'padding': '10px 3px 5px 3px'});
    //$('fieldset > legend','#divReplica').css({'font-size': '11px', 'color': '#777', 'margin-left': '5px', 'padding': '0px 2px'});


    var ordemInicial = new Array();
    //ordemInicial = [[3,0]]; // 4a coluna, ascendente

    var arrayLargura = new Array();

    arrayLargura[0] = '20px';
    arrayLargura[1] = '280px';
    

    var arrayAlinha = new Array();
    arrayAlinha[0] = 'center';
    arrayAlinha[1] = 'left';

    var metodoTabela = '';

    tabConteudo.formataTabelaCADPAA(ordemInicial, arrayLargura, arrayAlinha, metodoTabela);
	
	var tabelaTitulo = $( 'table.tituloRegistros',divRegistro.parent() );	
	
	
    hideMsgAguardo();
	
    return false;
}
