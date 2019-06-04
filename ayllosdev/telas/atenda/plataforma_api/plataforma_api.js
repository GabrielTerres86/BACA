/**********************************************************************
  Fonte: plataforma_api.js                                                
  Autor: Andrey Formigari		 											   
  Data : Fevereiro/2019                 Ultima Alteracao: 
                                                                   
  Objetivo  : Biblioteca de funcoes da rotina Plataforma API da tela Atenda                                              
                                                                   	 
 					
*************************************************************************/

var cddopcao = 'C';
var arrDesenvolvedores = [];

function controlaLayout(tipo) {
	
    altura = '220px';
	largura = '600px';

	arrDesenvolvedores = [];

	// Principal
	if (tipo == 'P') {
		
		var divRegistro = $('div.divRegistros');
        var tabela = $('table', divRegistro);
		var ordemInicial = new Array();

        var arrayLargura = new Array();
        arrayLargura[0] = '170px';
        arrayLargura[1] = '230px';
        arrayLargura[2] = '100px';
        arrayLargura[3] = '100px';

        var arrayAlinha = new Array();
        arrayAlinha[0] = 'left';
        arrayAlinha[1] = 'left';
        arrayAlinha[2] = 'center';
        arrayAlinha[3] = 'center';

		tabela.formataTabela(ordemInicial, arrayLargura, arrayAlinha, '');
		
		divRotina.css('width', largura);
		$('#divConteudoOpcao').css({ 'height': altura, 'width': largura });

		layoutPadrao();

		hideMsgAguardo();
		bloqueiaFundo(divRotina);

		removeOpacidade('divConteudoOpcao');
		divRotina.centralizaRotinaH();
		
		$('.tituloRegistros tr').find('th')[0].setAttribute('style', 'width: 166px;');
		$('.tituloRegistros tr').find('th')[1].setAttribute('style', 'width: 223px;');
		$('.tituloRegistros tr').find('th')[2].setAttribute('style', 'width: 100px;');
		$('.tituloRegistros tr').find('th')[3].setAttribute('style', 'width: 94px;');

	// Form principal
	} else if (tipo == 'F') {
		
		
		$('#servico', '#frmInclusao').unbind('keypress').bind('keypress', function (e) {
			// se pressionou TAB ou ENTER
			if (e.keyCode == 9 || e.keyCode == 13) {
				$('#situacao', '#frmInclusao').focus();
				return false;
			}
		});
		
		// Situacao
		$('#situacao', '#frmInclusao').unbind('keypress').bind('keypress', function (e) {
			// se pressionou TAB ou ENTER
			if (e.keyCode == 9 || e.keyCode == 13) {
				controlaLayout('FI');
				return false;
			}
		});

		$('#divUsoGenerico').css({ 'height': '500px', 'width': '765px' });

		$('#divUsoGenerico').centralizaRotinaH();

		if (cddopcao == 'C'){
			$('input[type="text"],select', '#divCabecalho').desabilitaCampo();
		} else {
			$('input[type="text"],select', '#divCabecalho').not('#emissao,#dtadesao').habilitaCampo();
		}
		$('#divBotoes', '#divCabecalho').show();
		$('#divFinalidades').hide();
		$('#divDesenvolvedores').hide();
		$('#divTipoAutoriazacao').hide();

		$('#servico', '#frmInclusao').focus();

		bloqueiaFundo($('#divUsoGenerico'));
		
		if (cddopcao == 'I'){
			$('#situacao', '#divCabecalho').desabilitaCampo();
		}
	
    // Finalidades
	} else if (tipo == 'FI') {
		
		if (!$('#servico option:selected', '#frmInclusao').val()){
			showError("error", "O servi&ccedil;o n&atilde;o foi selecionado.", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')));$(\'#nv_senha\', \'#frmCredenciasAcesso\').focus();");
			return;
		}
		
		var convenio_ativo = $('#convenio_ativo', '#frmInclusao').val();
		var produto = $('#servico option:selected', '#frmInclusao').val();
		if (convenio_ativo == 0 && produto == 6){
		    showError("error", "Cooperado n&atilde;o possui conv&ecirc;nio de software ativo para utiliza&ccedil;&atilde;o das APIs de Cobran&ccedil;a.", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')));$(\'#nv_senha\', \'#frmCredenciasAcesso\').focus();");
			return;
		}
			
		$('#divUsoGenerico').css({ 'height': '500px', 'width': '765px' });

		$('#divUsoGenerico').centralizaRotinaH();

		if (cddopcao == 'A') {
			$('input[type="text"],select', '#divCabecalho').not('#situacao').desabilitaCampo();
		} else {
			$('input[type="text"],select', '#divCabecalho').desabilitaCampo();
		}

		$('#divBotoes', '#divCabecalho').hide();
		
		setTimeout(function(){ exibeGridFinalidades(); }, 100);

	// Cadastro de Desenvolvedores
	} else if(tipo == 'D') {
		
		$('#divUsoGenerico').css({ 'height': '700px' });
		$('#divBotoes', '#divFinalidades').hide();
		
		setTimeout(function(){ carregaGridDesenvolvedor(); exibeTipoAutorizacao(); }, 100);
	} else if(tipo == 'FA') {
		exibeTipoAutorizacao();
	}

	return false;
}
    
function controlaOperacao(_cddopcao) {
	cddopcao = _cddopcao;
	switch(cddopcao) {
		// Incluir
		case 'C':
		case 'I':
		case 'A':
			exibeFormPlataformaApi();
			break;
		// Exclusão da API Selecionada
		case 'E':
			excluirAPI();
			break;
		// Credencias de Acesso
		case 'CA':
			exibeFormCredenciasAcesso();
			break;
		// Principal
		case 'P':
			exibePrincipal();
			break;
		// Listagem de APIs
		case 'LP':
			exibeListaAPIs();
			break;
		// Listagem de Desenvolvedores
		case 'LD':
			exibeListaDesenvolvedores();
			break;
		//Formulário para incluir Desenvolvedor
		case 'ID':
			exibeFormIncluirDesenvolvedor();
			break;
		// Formulário para cadastrar Desenvolvedor
		case 'CD':
			exibeFormCadastrarDesenvolvedor();
			break;
		// Imprime o Termo
		case 'IT':
			imprimeTermo();
			break;
	}
	return;
}

function imprimeTermo(){
	var rowid = '';
	var linhaSelecionada = $('table > tbody > tr.corSelecao', 'div.divRegistros');
	
	if (linhaSelecionada.length) {
		rowid = linhaSelecionada.find('#rowid').val();
	}else{
		showError("error", "N&atilde;o foi poss&iacute;vel selecionar um servi&ccedil;o.", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
		return;
	}
	
	$("#dsrowid", "#frmTermo").val(rowid);

    var action = $("#frmTermo").attr("action");
    var callafter = "";
	
	carregaImpressaoAyllos("frmTermo", action, callafter);
	
	exibeRotina($('#divRotina'));
	
	return false;
}

function exibeFormPlataformaApi() {
	var cdproduto = '',
		dtadesao = '',
		idsituacao_adesao = '',
		idservico_api = '',
		convenio_ativo = '',
		produtos_disponiveis = '';

	var linhaSelecionada = $('table > tbody > tr.corSelecao', 'div.divRegistros');

	if (linhaSelecionada.length) {
		cdproduto = linhaSelecionada.find('#cdproduto').val();
		dtadesao = linhaSelecionada.find('#dtadesao').val();
		idsituacao_adesao = linhaSelecionada.find('#idsituacao_adesao').val();
		idservico_api = linhaSelecionada.find('#idservico_api').val();
		convenio_ativo = linhaSelecionada.find('#convenio_ativo').val();
	}
	
	if (!convenio_ativo) convenio_ativo = $('#cdsitconv').val();
	
	produtos_disponiveis = $('#cdproddisp').val();
	servicos_disponiveis = $('#cdservdisp').val();

	fechaRotina($('#divRotina'));
	
	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, carregando informa&ccedil;&otilde;es...");

	// Se for inclusão
	var servicosIds = [];
	if (cddopcao == 'I') {
		var divRegistros = $('.divRegistros', '#divConteudoOpcao');

		$('table > tbody > tr', divRegistros).each(function (i, el){
			servicosIds.push($(el).find('#cdproduto').val());
		});
	}

	// Carrega conteúdo da opção através de ajax
	$.ajax({
		dataType: "html",
		type: "POST",
		url: UrlSite + "telas/atenda/plataforma_api/form_plataforma_api.php",
		data: {
			cddopcao: cddopcao,
			cdproduto: cdproduto,
			idservico_api: idservico_api,
			dtadesao: dtadesao,
			convenio_ativo: convenio_ativo,
			idsituacao_adesao: idsituacao_adesao,
			produtos_disponiveis: produtos_disponiveis,
			servicos_disponiveis: servicos_disponiveis,
			servicosIds: servicosIds.join(','),
			redirect: "script_ajax" // Tipo de retorno do ajax
		},
        error: function (objAjax, responseError, objExcept) {
			hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
        success: function (response) {
			if (response.substr(0, 14) == 'hideMsgAguardo') {
				eval(response);
			} else {
				// exibe rotina
				
				exibeRotina($('#divUsoGenerico'));
				$("#divUsoGenerico").html(response);
			}
		}
	});
}

function exibeGridFinalidades() {
	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, carregando informa&ccedil;&otilde;es...");
	
	// Carrega conte�do da op��o atrav�s de ajax
	$.ajax({
		dataType: "html",
		type: "POST",
		url: UrlSite + "telas/atenda/plataforma_api/grid_finalidades.php",
		data: {
			cddopcao: cddopcao,
			nrdconta: nrdconta,
			idservico_api: $('#servico_api', '#frmInclusao').val(),
			redirect: "script_ajax" // Tipo de retorno do ajax
		},
        error: function (objAjax, responseError, objExcept) {
			hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
        success: function (response) {
			if (response.substr(0, 14) == 'hideMsgAguardo') {
				eval(response);
			} else {
				$('#divFinalidades').html(response);
				bloqueiaFundo($('#divUsoGenerico'));
				controlaLayout('D');
			}
		}
	});
}

function exibeTipoAutorizacao() {
	
	// Carrega conteúdo da opção através de ajax
	$.ajax({
		dataType: "html",
		type: "POST",
		url: UrlSite + "telas/atenda/plataforma_api/tipo_autorizacao_form.php",
		data: {
			cddopcao: cddopcao,
			nrdconta: nrdconta,
			redirect: "script_ajax" // Tipo de retorno do ajax
		},
        error: function (objAjax, responseError, objExcept) {
			hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
        success: function (response) {
			if (response.substr(0, 14) == 'hideMsgAguardo') {
				eval(response);
			} else {
				$('#divTipoAutoriazacao').html(response);
			}
		}
	});
}

function carregaGridDesenvolvedor(carrega_memoria) {
	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, carregando informa&ccedil;&otilde;es...");

	var ls_desenvolvedores = [];
	for (var i=0; i < arrDesenvolvedores.length; ++i) {
		var aux = [];
		for (var key in arrDesenvolvedores[i]) {
			if (arrDesenvolvedores[i].hasOwnProperty(key)) {
				aux.push(arrDesenvolvedores[i][key]);
			}
		}
		ls_desenvolvedores.push(aux.join('#'));
	}

	// Carrega conte�do da op��o atrav�s de ajax
	$.ajax({
		dataType: "html",
		type: "POST",
		url: UrlSite + "telas/atenda/plataforma_api/grid_desenvolvedores.php",
		data: {
			cddopcao: cddopcao,
			nrdconta: nrdconta,
			idservico_api: $('#servico_api', '#frmInclusao').val(),
			ls_desenvolvedores: ls_desenvolvedores.join('|'),
			carrega_memoria: carrega_memoria,
			redirect: "script_ajax" // Tipo de retorno do ajax
		},
        error: function (objAjax, responseError, objExcept) {
			hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
        success: function (response) {
			if (response.substr(0, 14) == 'hideMsgAguardo') {
				eval(response);
			} else {
				$('#divDesenvolvedores').html(response);
				bloqueiaFundo($('#divUsoGenerico'));
			}
		}
	});
}

function exibeFormCredenciasAcesso() {
	
	fechaRotina($('#divRotina'));
	
	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, carregando informa&ccedil;&atilde;o...");

	// Carrega conte�do da op��o atrav�s de ajax
	$.ajax({
		dataType: "html",
		type: "POST",
		url: UrlSite + "telas/atenda/plataforma_api/form_credencias_acesso.php",
		data: {
			cddopcao: "CA",
			redirect: "script_ajax" // Tipo de retorno do ajax
		},
        error: function (objAjax, responseError, objExcept) {
			hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
        success: function (response) {
			if (response.substr(0, 14) == 'hideMsgAguardo') {
				eval(response);
			} else {
				// exibe rotina
				$('#divUsoGenerico').css({'width':'400px'});
				exibeRotina($('#divUsoGenerico'));
				$("#divUsoGenerico").html(response);
			}
		}
	});
}

function exibeFormIncluirDesenvolvedor() {

	fechaRotina($('#divRotina'));
	
	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, carregando informa&ccedil;&atilde;o...");

	// Carrega conteúdo da opção através de ajax
	$.ajax({
		dataType: "html",
		type: "POST",
		url: UrlSite + "telas/atenda/plataforma_api/form_cadastro_desenvolvedor.php",
		data: {
			redirect: "script_ajax" // Tipo de retorno do ajax
		},
        error: function (objAjax, responseError, objExcept) {
			hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
        success: function (response) {
			if (response.substr(0, 14) == 'hideMsgAguardo') {
				eval(response);
			} else {
				// exibe rotina
				exibeRotina($('#divUsoGenerico'));
				$("#divUsoGenerico").html(response);
			}
		}
	});
}

function exibePrincipal() {
	
	fechaRotina($('#divRotina'));
	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, carregando informa&ccedil;&atilde;o...");

	// Carrega conteúdo da opção através de ajax
	$.ajax({
		dataType: "html",
		type: "POST",
		url: UrlSite + "telas/atenda/plataforma_api/plataforma_api.php",
		data: paramsDefaultPlataformaAPI,
        error: function (objAjax, responseError, objExcept) {
			hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
        success: function (response) {
			if (response.substr(0, 14) == 'hideMsgAguardo') {
				eval(response);
			} else {
				$("#divRotina").html(response);
			}
		}
	});
}

function exibeListaAPIs(){
	// Carrega conteúdo da opção através de ajax
	$.ajax({
		dataType: "html",
		type: "POST",
		url: UrlSite + "telas/atenda/plataforma_api/principal.php",
		data: paramsDefaultPlataformaAPI,
        error: function (objAjax, responseError, objExcept) {
			hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
        success: function (response) {
			if (response.substr(0, 14) == 'hideMsgAguardo') {
				eval(response);
			} else {
				$("#divConteudoOpcao").html(response);
			}
		}
	});
}

function exibeListaDesenvolvedores(){
	// Carrega conteúdo da opção através de ajax
	$.ajax({
		dataType: "html",
		type: "POST",
		url: UrlSite + "telas/atenda/plataforma_api/lista_desenvolvedores.php",
		data: paramsDefaultPlataformaAPI,
        error: function (objAjax, responseError, objExcept) {
			hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
        success: function (response) {
			if (response.substr(0, 14) == 'hideMsgAguardo') {
				eval(response);
			} else {
				$("#divConteudoOpcao").html(response);
			}
		}
	});
}

function confirmaCredenciasAcesso(skipConfirm) {

	var nv_senha = $('#nv_senha', '#frmCredenciasAcesso').val();
	var cf_senha = $('#cf_senha', '#frmCredenciasAcesso').val();
	
	if ( (nv_senha !== cf_senha) || (nv_senha == '' || cf_senha == '') ){
		showError("error", "As senhas est&atilde;o diferentes, verifique!", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')));$(\'#nv_senha\', \'#frmCredenciasAcesso\').focus();");
		return;
	}
	
	if (!skipConfirm) {
		showConfirmacao('Confirma a inclus&atilde;o da nova Credencial de Acesso?', 'Confirma&ccedil;&atilde;o - Aimaro', 'confirmaCredenciasAcesso(true)', ' blockBackground(parseInt($("#divRotina").css("z-index")))', 'sim.gif', 'nao.gif');
		return;
	}
	
	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, criando credencias...");

	// Carrega conteúdo da opção através de ajax
	$.ajax({
		dataType: "html",
		type: "POST",
		url: UrlSite + "telas/atenda/plataforma_api/confirma_credencias_acesso.php",
		data: {
			nrdconta: nrdconta,
			nv_senha: nv_senha,
			cf_senha: cf_senha,
			cddopcao: "CA",
			redirect: "script_ajax" // Tipo de retorno do ajax
		},
        error: function (objAjax, responseError, objExcept) {
			hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
        success: function (response) {
			eval(response);
		}
	});
}

function excluirAPI(skipConfirm) {
	
	var rowid = '';
	var linhaSelecionada = $('table > tbody > tr.corSelecao', 'div.divRegistros');
	var dsservico = '';
	
	if (linhaSelecionada.length) {
		rowid = linhaSelecionada.find('#rowid').val();
		dsservico = linhaSelecionada.find('#dsproduto_servico').val();
	}else{
		showError("error", "N&atilde;o foi poss&iacute;vel selecionar um servi&ccedil;o.", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
		return;
	}
	
	if (!skipConfirm) { 
		showConfirmacao('Confirma a exclus&atilde;o do servi&ccedil;o "'+dsservico+'"?', 'Confirma&ccedil;&atilde;o - Aimaro', 'excluirAPI(true)', ' blockBackground(parseInt($("#divRotina").css("z-index")))', 'sim.gif', 'nao.gif');
		return;
	}
	
	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, excluindo registro...");

	// Carrega conteúdo da opção através de ajax
	$.ajax({
		dataType: "html",
		type: "POST",
		url: UrlSite + "telas/atenda/plataforma_api/excluir_api.php",
		data: {
			rowid: rowid,
			redirect: "script_ajax" // Tipo de retorno do ajax
		},
        error: function (objAjax, responseError, objExcept) {
			hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
        success: function (response) {
			eval(response);
		}
	});
}

function adicionaDesenvolvedor() {
	var form = $('#frmInclusao', '#divUsoGenerico');
	var cddesenvolvedor = $('#cddesenvolvedor', form).val(),
		nrdocumento = $('#nrdocumento', form).val(),
		dsempresa = $('#dsempresa', form).val(),
		dscontato = $('#dscontato', form).val(),
		dsemail = $('#dsemail', form).val(),
		nrtelefone = $('#nrtelefone', form).val();

	arrDesenvolvedores.push({
		cddesenvolvedor: cddesenvolvedor,
		nmdesenvolvedor: dsempresa,
		nrdocumento: nrdocumento,
		nrtelefone: nrtelefone,
		dscontato: dscontato,
		dsemail: dsemail
	});
	
	$('#cddesenvolvedor', form).val("");

	carregaGridDesenvolvedor(true);
}

function detalharDesenvolvedor() {
	var reg = selecionaRegistro();

	if (!reg) {
		showError("error", "Voc&ecirc; deve selecionar um registro.", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
		return;
	}
	
	fechaRotina($('#divUsoGenerico'));
	showMsgAguardo("Aguarde, carregando desenvolvedor...");

	$.ajax({
		dataType: "html",
		type: "POST",
		url: UrlSite + "telas/atenda/plataforma_api/detalhar_desenvolvedor.php",
		data: {
			cddesen: reg,
			redirect: "script_ajax" // Tipo de retorno do ajax
		},
        error: function (objAjax, responseError, objExcept) {
			hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
        success: function (response) {
			if (response.substr(0, 14) == 'hideMsgAguardo') {
				eval(response);
			} else {
				$('#divRotina').css({'width':'700px'});
				exibeRotina($('#divRotina'));
				$("#divRotina").html(response);
				hideMsgAguardo();
				blockBackground(parseInt($('#divRotina').css('z-index')));
				$('#divRotina').addClass('detailDesen');
			}
		}
	});
}

function removeDesenvolvedor() {
	var reg = selecionaRegistro();

	if (!reg) {
		showError("error", "Voc&ecirc; deve selecionar um registro.", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
		return;
	}

	$.ajax({
		dataType: "html",
		type: "POST",
		url: UrlSite + "telas/atenda/plataforma_api/valida_permissao.php",
		data: {
			cddopcao: 'A',
			redirect: "script_ajax" // Tipo de retorno do ajax
		},
        error: function (objAjax, responseError, objExcept) {
			hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
        success: function (response) {
			if (response.substr(0, 14) == 'hideMsgAguardo') {
				eval(response);
			} else {
				var selected = {};

				for (var i=0; i < arrDesenvolvedores.length; i++) {
					if (arrDesenvolvedores[i].cddesenvolvedor == reg) {
						selected = arrDesenvolvedores[i];
					}
				}

				var idx = arrDesenvolvedores.indexOf(selected);

				arrDesenvolvedores.splice(idx,1);

				carregaGridDesenvolvedor(true);
			}
		}
	});
}

function solicitaSenha() {
	var tipoAutorizacao = $('input[name="tp_autorizacao"]:checked', '#frmTipoAutorizacao').val();
	var ls_finalidades = [],
		ls_desenvolvedores = [],
		idservico_api = $('#servico_api', '#frmInclusao').val(),
		idsituacao_adesao = $('#situacao', '#frmInclusao').val();

	// Varre as finalidades...
	$('#tbFinalidades > tbody > tr > td > input[type="checkbox"]:checked', '#divFinalidades').each(function (i, el){
		ls_finalidades.push($(el).val());
	});

	$('#tbDesenvolvedores > tbody > tr > td > input', '#divDesenvolvedores').each(function (i, el) {
		ls_desenvolvedores.push($(el).val());
	});
	
	var _gravar = 'gravar(true, '+idservico_api+', '+idsituacao_adesao+', \''+ls_finalidades.join(';')+'\', \''+ls_desenvolvedores.join(';')+'\', '+tipoAutorizacao+');';
	
	if (!tipoAutorizacao && idsituacao_adesao == "1"){
		showError("error", "Selecione um tipo de autoriza&ccedil;&atilde;o para continuar.", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
		return false;
	}else if (tipoAutorizacao == '2'){
		eval(_gravar);
		return false;
	}else if (tipoAutorizacao == '1'){
		
		// Se situação for igual a Inativa, não deve solicitar senha
		if (idsituacao_adesao == "0"){
			eval(_gravar);
			return false;
		}
		
		$('#divUsoGenerico').css({'width':'400px'});
		
		var _solicitasenhamagnetico = solicitaSenhaMagnetico(_gravar, nrdconta);
		var _settimeout = setInterval(function(){
			if ($('#btVoltar', '#divBotoesSenhaMagnetico').length > 0){
				clearTimeout(_settimeout);
				$('#divBotoesSenhaMagnetico #btVoltar, #divUsoGenerico #tdTitTela a').attr('onclick', "fechaRotina($('#divUsoGenerico'));exibeRotina($('#divRotina'));controlaOperacao('P');return false;");
				$('#divBotoesSenhaMagnetico #btValidar').attr('onclick', "validaSenhaMagnetico();return false;");
				$('#divSolicitaSenhaMagnetico #validainternet').val("s");
			}
		}, 100);
	}else{
		eval(_gravar);
		return false;
	}
}

function gravar(skipConfirm, idservico_api, idsituacao_adesao, ls_finalidades, ls_desenvolvedores, tipoAutorizacao) {
	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, carregando informa&ccedil;&otilde;es...");
	
	if (!skipConfirm){
		hideMsgAguardo();
        showError("error", "Senha n&atilde;o autorizada.", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
		return false;
	}

	// Carrega conteúdo da opção através de ajax
	$.ajax({
		dataType: "html",
		type: "POST",
		url: UrlSite + "telas/atenda/plataforma_api/grava_servicos_coop.php",
		data: {
			cddopcao: cddopcao,
			nrdconta: nrdconta,
			idservico_api: idservico_api,
			tp_autorizacao : tipoAutorizacao,
			idsituacao_adesao: idsituacao_adesao,
			ls_finalidades: ls_finalidades,
			ls_desenvolvedores: ls_desenvolvedores,
			redirect: "script_ajax" // Tipo de retorno do ajax
		},
        error: function (objAjax, responseError, objExcept) {
			hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
        success: function (response) {
			eval(response);
		}
	});
}

function controlaPesquisa() {
	fechaRotina($('#divUsoGenerico'));

	// Definicao dos filtros
	var filtros = "Codigo;cddesenvolvedor;;;;N;|Telefone;nrtelefone;;;;N;|Contato;dscontato;;;;N;|Email;dsemail;;;;N;|CPF/CNPJ;nrdocumento;200px;S;;;|Nome;dsempresa;200px;S;;;";

	// Campos que serao exibidos na tela
	var colunas = 'Codigo;cddesenvolvedor;;;;N|Telefone;nrtelefone;;;;N|Contato;dscontato;;;;N|Email;dsemail;;;;N|CPF/CNPJ;nrdocumento;30%;left|Nome;dsnome;60%;left';

	// Funcao para executar quando fechar a pesquisa
	var fncOnClose = 'adicionaDesenvolvedor();exibeRotina($("#divUsoGenerico"));';

	// Exibir a pesquisa
	mostraPesquisa("CADDES",                       //businessObject
				   "PESQUISA_DESENVOLVEDOR",       //nomeProcedure
				   "Desenvolvedores",              //tituloPesquisa
				   "30",                           //quantReg
				   filtros,                        //filtros
				   colunas,                        //colunas
				   $("#divUsoGenerico"),           //divBloqueia
				   fncOnClose,                     //fncOnClose
				   "frmInclusao"                   //nomeRotina
				   );
	
	var maxLoops = 0;
	var _settimeout = setInterval(function(){
			
		if ($('#divResultadoPesquisa').length > 0){
			$('#btCadastroDesenvolvedor').remove();
			$('#btCadastroDesenvolvedorVoltar').remove();
			$('<input onclick="controlaOperacao(\'CD\');" id="btCadastroDesenvolvedor" style="margin: 10px 5px;cursor: pointer;" type="button" class="botao" value="Cadastrar Desenvolvedor" />').insertAfter($('#divResultadoPesquisa'));
			$('<input onclick="$(\'#divPesquisa .fecharPesquisa\').click();" id="btCadastroDesenvolvedorVoltar" style="margin: 10px 0;cursor: pointer;" type="button" class="botao" value="Voltar" />').insertAfter($('#divResultadoPesquisa'));
		}
		
		maxLoops++;
		
		// Garante que se der algum problema, ele saia do loop infinito em no máximo 10 segundos
		if (maxLoops > 99){
			clearTimeout(_settimeout);
		}
		
		if ($('#divResultadoPesquisa').length > 0){
			clearTimeout(_settimeout);
		}
		
	}, 100);
}

function exibeFormCadastrarDesenvolvedor(){
	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, carregando informa&ccedil;&otilde;es...");

	// Carrega conteúdo da opção através de ajax
	$.ajax({
		dataType: "html",
		type: "POST",
		url: UrlSite + "telas/atenda/plataforma_api/form_cadastrar_desenvolvedor.php",
		data: {
			redirect: "script_ajax" // Tipo de retorno do ajax
		},
        error: function (objAjax, responseError, objExcept) {
			hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
        success: function (response) {
			$('#divRotina').css({'width':'700px', 'height':'440px'});
			$("#divRotina").html(response);
			$('#divRotina').centralizaRotinaH();
			fechaRotina($('#divPesquisa'));
			exibeRotina($('#divRotina'));
		}
	});
}

function retornoCadastroDesenvolvedor(retorno){
	fechaRotina($('#divRotina'));
	selecionaPesquisa(retorno, 'frmInclusao');
}

function voltaPesquisaDesenvolvedor(){
	fechaRotina($('#divRotina'));
	exibeRotina($('#divPesquisa'));
	return false;
}