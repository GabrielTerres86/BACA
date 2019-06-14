/*!
 * FONTE        : caddes.js
 * CRIAÇÃO      : Andrey Formigari - Supero
 * DATA CRIAÇÃO : Fevereiro/2019
 * OBJETIVO     : Biblioteca de funções da tela CADDES
 * --------------
 * ALTERAÇÕES   :
 * --------------
 */

var frmCab = '#frmCab';
var frmCadastroDesenvolvedor = '#frmCadastroDesenvolvedor';
var frmFraseDesenvolvedor = '#frmFraseDesenvolvedor';
var frmChaveAcesso = '#frmChaveAcesso';

$(document).ready(function () {
    
	estadoInicial();
	
	$(document.body).unbind('keydown').bind('keydown', function (e) {
		var target = e.target;

		switch (e.keyCode) {
			case 27:
			
				var isPlataformaAPI = $('#isPlataformaAPI', frmCab).val();
				if (isPlataformaAPI == 1){
					parent.voltaPesquisaDesenvolvedor();
					return false;
				}

				if ($('#divPesquisaEndereco').css('visibility') == 'visible'){
					fechaRotina($('#divPesquisaEndereco'));
				}else if ($('#divUsoGenerico').css('visibility') == "hidden"){
					estadoInicial();
				}else{
					fechaRotina($('#divUsoGenerico'));
				}
				
				break;
		}
	 });
});

function onKeyDownBuscaDesenvolvedor(e){
	
	var cddopcao = $('#cddopcao', frmCab).val();
	var cddesen = $('#cddesen', frmCadastroDesenvolvedor).val();
	
	if (e.keyCode == 13 && (cddopcao == "C" || cddopcao == "A" || cddopcao == "E")){
		
		showMsgAguardo('Aguarde, carregando desenvolvedor...');
		
		$.ajax({
			type: "POST",
			dataType: 'html',
			url: UrlSite + 'telas/caddes/principal.php',
			data: {
				cddopcao: cddopcao,
				cddesenvolvedor: cddesen,
				redirect: 'script_ajax'
			},
			error: function (objAjax, responseError, objExcept) {
				hideMsgAguardo();
				showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Aimaro', 'estadoInicial();');
			},
			success: function (response) {
				if (response.substr(0, 14) == 'hideMsgAguardo') {
					eval(response);
				} else {
					$('#divPrincipal').html(response);
					hideMsgAguardo();
				}
			}
		});
		
	}
}

function selecionaPesquisaDesenvolvedor(cddesen){
	
	var cddopcao = $('#cddopcao', frmCab).val();
	
	fechaRotina($('#divUsoGenerico'));
	
	showMsgAguardo('Aguarde, carregando desenvolvedor...');
	
	$.ajax({
		type: "POST",
		dataType: 'html',
		url: UrlSite + 'telas/caddes/principal.php',
		data: {
			cddopcao: cddopcao,
			cddesenvolvedor: cddesen,
			redirect: 'script_ajax'
		},
		error: function (objAjax, responseError, objExcept) {
			hideMsgAguardo();
			showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Aimaro', 'estadoInicial();');
		},
		success: function (response) {
			if (response.substr(0, 14) == 'hideMsgAguardo') {
				eval(response);
			} else {
				$('#divPrincipal').html(response);
				hideMsgAguardo();
			}
		}
	});
}

function carregaOpcaoCabecalhoSelecionada(){
	
	var cddopcao = $('#cddopcao', frmCab).val();
	var isPlataformaAPI = $('#isPlataformaAPI', frmCab).val();
	
	showMsgAguardo('Aguarde, carregando...');
	$.ajax({
		type: "POST",
		dataType: 'html',
		url: UrlSite + 'telas/caddes/principal.php',
		data: {
			cddopcao: cddopcao,
			isPlataformaAPI: isPlataformaAPI,
			redirect: 'script_ajax'
		},
		error: function (objAjax, responseError, objExcept) {
			hideMsgAguardo();
			showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Aimaro', 'estadoInicial();');
		},
		success: function (response) {
			if (response.substr(0, 14) == 'hideMsgAguardo') {
				eval(response);
			} else {
				bloqueiaCabecalho();
				$('#divPrincipal').html(response);
				hideMsgAguardo();
				
			}
		}
	});
}

function pesquisaDesenvolvedor(nriniseq, nrregist){
	
	showMsgAguardo('Aguarde, carregando...');
	
	var dsempresa = $('#dsempresa', '#frmPesquisaDesenvolvedor').val();
	var nrdocumento = $('#nrdocumento', '#frmPesquisaDesenvolvedor').val();
	
	$.ajax({
		type: "POST",
		dataType: 'html',
		url: UrlSite + 'telas/caddes/realiza_pesquisa_desenvolvedor.php',
		data: {
			dsempresa: dsempresa,
			nrdocumento: nrdocumento,
			nriniseq: nriniseq,
			nrregist: nrregist,
			redirect: 'script_ajax'
		},
		error: function (objAjax, responseError, objExcept) {
			hideMsgAguardo();
			showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Aimaro', 'estadoInicial();');
		},
		success: function (response) {
			if (response.substr(0, 14) == 'hideMsgAguardo') {
				eval(response);
			} else {
				$('#divUsoGenerico').html(response);
			}
		}
	});
}

function carregaPesquisaDesenvolvedor(){
	
	var cddopcao = $('#cddopcao', frmCab).val();
	
	if (cddopcao == "C" || cddopcao == "A" || cddopcao == "E"){
	
		showMsgAguardo('Aguarde, carregando...');
		
		$.ajax({
			type: "POST",
			dataType: 'html',
			url: UrlSite + 'telas/caddes/realiza_pesquisa_desenvolvedor.php',
			data: {
				redirect: 'script_ajax'
			},
			error: function (objAjax, responseError, objExcept) {
				hideMsgAguardo();
				showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Aimaro', 'estadoInicial();');
			},
			success: function (response) {
				if (response.substr(0, 14) == 'hideMsgAguardo') {
					eval(response);
				} else {
					bloqueiaFundo($("#divRotina"));
					exibeRotina($('#divUsoGenerico'));
					$('#divUsoGenerico').html(response);
				}
			}
		});
	}
}

function enviarFraseViaEmail(skipConfirm){
	
	if (!skipConfirm) {
		showConfirmacao('Confirma envio do e-mail com a frase para o desenvolvedor?', 'Confirma&ccedil;&atilde;o - Aimaro', 'enviarFraseViaEmail(true);', '', 'sim.gif', 'nao.gif');
		return;
	}
	
	var cddesen = $('#cddesen', frmCadastroDesenvolvedor).val();
	
	showMsgAguardo('Aguarde, enviando e-mail...');
	
	$.ajax({
		dataType: "html",
		type: "POST",
		url: UrlSite + "telas/caddes/enviar_frase_email.php",
		data: {
            cddesenvolvedor: cddesen,
			redirect: "script_ajax" // Tipo de retorno do ajax
		},
        error: function (objAjax, responseError, objExcept) {
			hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Aimaro", "");
		},
        success: function (response) {
			eval(response);
		}
	});
}

function enviarChaveViaEmail(skipConfirm){
	
	if (!skipConfirm) {
		showConfirmacao('Confirma envio do e-mail com a chave para o desenvolvedor?', 'Confirma&ccedil;&atilde;o - Aimaro', 'enviarChaveViaEmail(true);', '', 'sim.gif', 'nao.gif');
		return;
	}
	
	var cddesen = $('#cddesen', frmCadastroDesenvolvedor).val();
	
	showMsgAguardo('Aguarde, enviando e-mail...');
	
	$.ajax({
		dataType: "html",
		type: "POST",
		url: UrlSite + "telas/caddes/enviar_chave_email.php",
		data: {
            cddesenvolvedor: cddesen,
			redirect: "script_ajax" // Tipo de retorno do ajax
		},
        error: function (objAjax, responseError, objExcept) {
			hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Aimaro", "");
		},
        success: function (response) {
			eval(response);
		}
	});
}

function gerarNovaFrase(skipConfirm){
	
	if (!skipConfirm) {
		showConfirmacao('Ao gerar uma nova frase, a atual ser&aacute; perdida. Confirma a gera&ccedil;&atilde;o de uma nova frase para o Desenvolvedor?', 'Confirma&ccedil;&atilde;o - Aimaro', 'gerarNovaFrase(true);', '', 'sim.gif', 'nao.gif');
		return;
	}
	
	var cddesen = $('#cddesen', frmCadastroDesenvolvedor).val();
	
	showMsgAguardo('Aguarde, gerando uma nova frase...');
	
	$.ajax({
		dataType: "html",
		type: "POST",
		url: UrlSite + "telas/caddes/gerar_nova_frase_desenvolvedor.php",
		data: {
            cddesenvolvedor: cddesen,
			redirect: "script_ajax" // Tipo de retorno do ajax
		},
        error: function (objAjax, responseError, objExcept) {
			hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Aimaro", "");
		},
        success: function (response) {
			eval(response);
		}
	});
}

function gerarUUID(skipConfirm){
	
	if (!skipConfirm) {
		showConfirmacao('Ao gerar um novo UUID, o atual ser&aacute; cancelado. Confirma a gera&ccedil;&atilde;o de novo UUID para o desenvolvedor?', 'Confirma&ccedil;&atilde;o - Aimaro', 'gerarUUID(true);', '', 'sim.gif', 'nao.gif');
		return;
	}
	
	var cddesen = $('#cddesen', frmCadastroDesenvolvedor).val();
	
	showMsgAguardo('Aguarde, gerando a UUID...');
	
	$.ajax({
		dataType: "html",
		type: "POST",
		url: UrlSite + "telas/caddes/gerar_uuid_desenvolvedor.php",
		data: {
            cddesenvolvedor: cddesen,
			redirect: "script_ajax" // Tipo de retorno do ajax
		},
        error: function (objAjax, responseError, objExcept) {
			hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Aimaro", "");
		},
        success: function (response) {
			eval(response);
		}
	});
}

function carregaFormFraseDesenvolvedor(dsfrase, cddesen, dsuuid){
	
	var cddopcao = $('#cddopcao', frmCab).val();
	$('#cddesen', frmCadastroDesenvolvedor).val(cddesen);
	
	showMsgAguardo('Aguarde, carregando...');
	$.ajax({
		type: "POST",
		dataType: 'html',
		url: UrlSite + 'telas/caddes/form_frase_desenvolvedor.php',
		data: {
			cddopcao: cddopcao,
			dsfrase: dsfrase,
			cddesenvolvedor: cddesen,
			dsuuid: dsuuid,
			redirect: 'script_ajax'
		},
		error: function (objAjax, responseError, objExcept) {
			hideMsgAguardo();
			showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Aimaro', 'estadoInicial();');
		},
		success: function (response) {
			if (response.substr(0, 14) == 'hideMsgAguardo') {
				eval(response);
			} else {
				hideMsgAguardo();
				$('#divFraseDesenvolvedor').html(response);
				$('#dsuser_portal', frmChaveAcesso).focus();
			}
		}
	});
}

function controlaLayout(opcao){
	switch(opcao){
		case 'C': // consultar
		case 'E': // excluir
		case 'A': // Alterar
			
			$('input, select', frmCadastroDesenvolvedor).attr('disabled', 'disabled').addClass('campoTelaSemBorda');
			$('#cddesen', frmCadastroDesenvolvedor).removeAttr('disabled').removeClass('campoTelaSemBorda');
			$('#dsuser_portal', frmChaveAcesso).attr('disabled', 'disabled').addClass('campoTelaSemBorda');
			$('#cddesen', frmCadastroDesenvolvedor).focus();
			
			break;
		case 'I': // Incluir
			
			$('#cddesen', frmCadastroDesenvolvedor).attr('disabled', 'disabled').addClass('campoTelaSemBorda');
			$('#inpessoa_j', frmCadastroDesenvolvedor).click();
			
			break;
		case 'AC': // Alterar depois de consultar
			
			$('input, select', frmCadastroDesenvolvedor).removeAttr('disabled').removeClass('campoTelaSemBorda');
			$('#cddesen', frmCadastroDesenvolvedor).attr('disabled', 'disabled').addClass('campoTelaSemBorda');
			$('#dsuser_portal', frmChaveAcesso).removeAttr('disabled').removeClass('campoTelaSemBorda');
			
			$('#cpf_cnpj, #inpessoa_f, #inpessoa_j').attr('disabled', 'disabled').addClass('campoTelaSemBorda');
			
			break;
		case 'ID': // Incluir e Desativar
			
			$('input, select', frmCadastroDesenvolvedor).attr('disabled', 'disabled').addClass('campoTelaSemBorda');
			
			break;
		case 'CE':
		
			$('#cddesen', frmCadastroDesenvolvedor).attr('disabled', 'disabled').addClass('campoTelaSemBorda');
			
			break;
	}
}

function estadoInicial() {
	$('#divPrincipal, #divFraseDesenvolvedor').html("");
	desbloqueiaCabecalho();
    $('#cddopcao', frmCab).focus();
    return false;
}

function bloqueiaCabecalho(){
	$('#cddopcao', frmCab).attr('disabled','disabled').addClass('campoTelaSemBorda');
	$('#btnOKCab', frmCab).addClass('botaoDesativado').removeClass('botao');
	$('#btnOKCab', frmCab).removeAttr('onclick');
}

function desbloqueiaCabecalho(){
	$('#cddopcao', frmCab).removeAttr('disabled').removeClass('campoTelaSemBorda');
	$('#btnOKCab', frmCab).addClass('botao').removeClass('botaoDesativado');
	$('#btnOKCab', frmCab).attr('onclick','carregaOpcaoCabecalhoSelecionada(); return false;');
	$('#cddopcao', frmCab).unbind('keypress').bind('keypress', function(e) {
		if ( divError.css('display') == 'block' ) { return false; }		
		// Se é a tecla ENTER, 
		if ( e.keyCode == 13 ) {
			$('#btnOKCab', '#frmCab').focus();
			return false;
		}
	});
}

function confirmaExcluirDesenvolvedor(skipConfirm){
	var cddesen = $('#cddesen', frmCadastroDesenvolvedor).val();
	
	if (!cddesen){
		showError("error", "Seleciona um desenvolvedor primeiro.", "Alerta - Aimaro", "");
		return;
	}
	
	if (!skipConfirm) {
		showConfirmacao('Confirma a exclus&atilde;o do desenvolvedor?', 'Confirma&ccedil;&atilde;o - Aimaro', 'confirmaExcluirDesenvolvedor(true)', '', 'sim.gif', 'nao.gif');
		return;
	}
	
	showMsgAguardo("Aguarde, excluindo desenvolvedor...");
	
	$.ajax({
		dataType: "html",
		type: "POST",
		url: UrlSite + "telas/caddes/exclui_desenvolvedor.php",
		data: {
            cddesenvolvedor: cddesen,
			redirect: "script_ajax" // Tipo de retorno do ajax
		},
        error: function (objAjax, responseError, objExcept) {
			hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Aimaro", "");
		},
        success: function (response) {
			eval(response);
		}
	});
}

function confirmaCadastroDesenvolvedor(skipConfirm) {

	var cddesen = $('#cddesen', frmCadastroDesenvolvedor).val();
	var cpf_cnpj = $('#cpf_cnpj', frmCadastroDesenvolvedor).val();
	var dsempresa = $('#dsempresa', frmCadastroDesenvolvedor).val();
	var nrcep = $('#nrcep', frmCadastroDesenvolvedor).val();
	var dsendereco = $('#dsendereco', frmCadastroDesenvolvedor).val();
	var dsbairro = $('#dsbairro', frmCadastroDesenvolvedor).val();
	var dscidade = $('#dscidade', frmCadastroDesenvolvedor).val();
	var dsuf = $('#dsuf', frmCadastroDesenvolvedor).val();
	var dscomplemento = $('#dscomplemento', frmCadastroDesenvolvedor).val();
	var nrendereco = $('#nrendereco', frmCadastroDesenvolvedor).val();
	var dsemail = $('#dsemail', frmCadastroDesenvolvedor).val();
	var nrtelcelular = $('#nrtelcelular', frmCadastroDesenvolvedor).val();
	var nrddd_celular = $('#nrddd_celular', frmCadastroDesenvolvedor).val();
	var dscontatocel = $('#dscontatocel', frmCadastroDesenvolvedor).val();
	var nrtelcomercial = $('#nrtelcomercial', frmCadastroDesenvolvedor).val();
	var nrddd_comercial = $('#nrddd_comercial', frmCadastroDesenvolvedor).val();
	var dscontatocom = $('#dscontatocom', frmCadastroDesenvolvedor).val();
	var inpessoa = $('input[name="inpessoa"]:checked', frmCadastroDesenvolvedor).val();
	var dsusuario_portal = $('#dsuser_portal', frmChaveAcesso).val();
	var cddopcao = $('#cddopcao', frmCab).val();
	var isPlataformaAPI = $('#isPlataformaAPI', frmCab).val();
	
	if (!inpessoa){
		showError("error", "Selecione uo Tipo de Pessoa para continuar.", "Alerta - Aimaro", "");
		return;
	}
	
	if (!validaCpfCnpj(cpf_cnpj, inpessoa)) {
	    showError("error", "Digite um " + ((inpessoa == 1) ? 'CPF' : 'CNPJ') + " v&aacute;lido para continuar.", "Alerta - Aimaro", "$('#cpf_cnpj', frmCadastroDesenvolvedor).focus();");
	    return;
	}

	if (!dsempresa) {
	    showError("error", "Digite o nome de empresa para continuar.", "Alerta - Aimaro", "$('#dsempresa', frmCadastroDesenvolvedor).focus();");
	    return;
	}

	if (!validaEmail(dsemail)) {
	    showError("error", "Digite um e-mail v&aacute;lido para continuar.", "Alerta - Aimaro", "$('#dsemail', frmCadastroDesenvolvedor).focus();");
	    return;
	}
	
	// Se cair aqui, significa que o operador está alterando após cadastrar um novo desenvolvedor (opcao = I)
	if (cddesen > 0){
		cddopcao = "A";
	}
	
	if (!skipConfirm) {
		if (cddopcao == "A"){
			showConfirmacao('Confirma a altera&ccedil;&atilde;o do desenvolvedor?', 'Confirma&ccedil;&atilde;o - Aimaro', 'confirmaCadastroDesenvolvedor(true)', '', 'sim.gif', 'nao.gif');
		}else if(cddopcao == "I"){
			showConfirmacao('Confirma a inclus&atilde;o de um novo desenvolvedor?', 'Confirma&ccedil;&atilde;o - Aimaro', 'confirmaCadastroDesenvolvedor(true)', '', 'sim.gif', 'nao.gif');
		}
		return;
	}
	
	if (cddopcao == "A"){
		// Mostra mensagem de aguardo
		showMsgAguardo("Aguarde, alterando desenvolvedor...");
		var urlAjax = "telas/caddes/altera_desenvolvedor.php";
	}else if(cddopcao == "I"){
		// Mostra mensagem de aguardo
		showMsgAguardo("Aguarde, cadastrando desenvolvedor...");
		var urlAjax = "telas/caddes/cadastra_desenvolvedor.php";
	}
		

	// Carrega conteúdo da opção através de ajax
	$.ajax({
		dataType: "html",
		type: "POST",
		url: UrlSite + urlAjax,
		data: {
			cddopcao: cddopcao,
            cddesenvolvedor: cddesen,
            inpessoa: inpessoa,
            nrdocumento: cpf_cnpj,
            dsnome: dsempresa,
            nrcep_endereco: nrcep,
            dsendereco: dsendereco,
            nrendereco: nrendereco,
            dscomplemento: dscomplemento,
            dsbairro: dsbairro,
            dscidade: dscidade,
            dsunidade_federacao: dsuf,
            dsemail: dsemail,
            nrddd_celular: nrddd_celular,
            nrtelefone_celular: nrtelcelular,
            dscontato_celular: dscontatocel,
            nrddd_comercial: nrddd_comercial,
            nrtelefone_comercial: nrtelcomercial,
            dscontato_comercial: dscontatocom,
            dsusuario_portal: dsusuario_portal,
			isPlataformaAPI : isPlataformaAPI,
			redirect: "script_ajax" // Tipo de retorno do ajax
		},
        error: function (objAjax, responseError, objExcept) {
			hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Aimaro", "");
		},
        success: function (response) {
			eval(response);
		}
	});
}