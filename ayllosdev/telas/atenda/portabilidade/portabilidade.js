/**********************************************************************
  Fonte: portabilidade.js                                                
  Autor: Anderson-Alan		 											   
  Data : Setembro/2018                 Ultima Alteracao: 24/09/2018
                                                                   
  Objetivo  : Biblioteca de funcoes da rotina Portabilidade da tela Atenda                                              
                                                                   	 
  Alteracoes: 05/03/2019 - Inserido validacao de e-mail na Solicitacao de Portabilidade. INC0033519 (Mateus Z - Mouts)
 					
  Alteracoes: 29/04/2019 - Alterado para validar o e-mail somente quando o mesmo estiver preenchido (João Gabriel Mannes - Mouts)
 					
*************************************************************************/

var callafterCapital = ''; 

var lstLancamentos = new Array();
var lstEstorno = new Array();
var glb_opcao = '';
var nomeForm = '';

var vintegra = 0;

// Função para acessar opções da rotina
function acessaOpcaoAba(nrOpcoes, id, opcao) {
	glb_opcao = opcao;
	
	if (opcao == "0") {	// Opção Principal
		var msg = ", carregando dados de portabilidade";
		var UrlOperacao = UrlSite + "telas/atenda/portabilidade/envio_solicitacao.php";
	} else if (opcao == "1") { // Opção
	    var msg = ", carregando dados de portabilidade";
		var UrlOperacao = UrlSite + "telas/atenda/portabilidade/destinatario.php";
	}
	
	if (opcao != "")
		// Mostra mensagem de aguardo
		showMsgAguardo("Aguarde" + msg + " ...");
	
    // Atribui cor de destaque para aba da opção
	for (var i = 0; i < nrOpcoes; i++) {
	    if (id == i) { // Atribui estilos para foco da opção
            $("#linkAba" + id).attr("class", "txtBrancoBold");
            $("#imgAbaEsq" + id).attr("src", UrlImagens + "background/mnu_sle.gif");
            $("#imgAbaDir" + id).attr("src", UrlImagens + "background/mnu_sld.gif");
            $("#imgAbaCen" + id).css("background-color", "#969FA9");
			continue;			
		}
		
        $("#linkAba" + i).attr("class", "txtNormalBold");
        $("#imgAbaEsq" + i).attr("src", UrlImagens + "background/mnu_nle.gif");
        $("#imgAbaDir" + i).attr("src", UrlImagens + "background/mnu_nld.gif");
        $("#imgAbaCen" + i).css("background-color", "#C6C8CA");
	}

	if (opcao != "") { // Demais Opções		
	    // Carrega conteúdo da opção através de ajax
		$.ajax({		
			type: "POST", 
			dataType: "html",
			url: UrlOperacao,
			data: {
				nrdconta: nrdconta,
				sitaucaoDaContaCrm: sitaucaoDaContaCrm,
				redirect: "html_ajax"
			},
            error: function (objAjax, responseError, objExcept) {
				hideMsgAguardo();
				showError("error", "Não foi possível concluir a requisição.", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
			},
            success: function (response) {
				if (response.substr(0, 14) == 'hideMsgAguardo') {
					eval(response);
				} else {
					$("#divConteudoOpcao").html(response);
					controlaFoco(opcao); 
				}
			}	
		}); 
	}					
}


//Função para controle de navegação
function controlaFoco(opcao) {
    var IdForm = '';
    var formid;

    if (opcao == "@") { //Envio de Solicitação
        $('.FirstInput:first ').focus();
	}
}


//
function controlaLayout(cddopcao) {
	
    altura = '630px';
	largura = '500px';
	
	if (in_array(cddopcao, ['C','A','I'])) {
		
		nomeForm = 'frmDadosPortabilidade';		
		if (glb_opcao == '0') {
			altura = '680px';
        	largura = '555px';
		} else {
			altura = '590px';
        	largura = '555px';
		}
        
		
        $('#' + nomeForm).css('margin-top', '2px');
		
		var rNrcpfcgc = $('label[for="nrcpfcgc"]', '#'+nomeForm);
		var rNmprimtl = $('label[for="nmprimtl"]', '#'+nomeForm);
		var rNrtelefo = $('label[for="nrtelefo"]', '#'+nomeForm);
		var rDsdemail = $('label[for="dsdemail"]', '#'+nomeForm);
		var rDsdbanco = $('label[for="dsdbanco"]', '#'+nomeForm);
		var rCdageban = $('label[for="cdageban"]', '#'+nomeForm);
		var rNrispbif_banco_folha = $('label[for="nrispbif_banco_folha"]', '#'+nomeForm);
		var rNrcnpjif = $('label[for="nrcnpjif"]', '#'+nomeForm);
		var rTppessoa_emp = $('#lbl_tppessoa_empregador', '#'+nomeForm);
		var rNrdocnpj_emp = $('label[for="nrdocnpj_emp"]', '#'+nomeForm);
		var rNmprimtl_emp = $('label[for="nmprimtl_emp"]', '#'+nomeForm);
		var rNrispbif = $('label[for="nrispbif"]', '#'+nomeForm);
		var rNrdocnpj = $('label[for="nrdocnpj"]', '#'+nomeForm);
		var rTpconta = $('label[for="tpconta"]', '#'+nomeForm);
		var rCdagectl = $('label[for="cdagectl"]', '#'+nomeForm);
		var rNrdconta = $('label[for="nrdconta"]', '#'+nomeForm);
		var rDscodigo = $('label[for="dssituacao"]', '#'+nomeForm);
		var rDtsolicitacao = $('label[for="dtsolicita"]', '#'+nomeForm);
		var rDtretorno = $('label[for="dtretorno"]', '#'+nomeForm);
		var rNrnu_portabilidade = $('label[for="nrnu_portabilidade"]', '#'+nomeForm);
		var rDsmotivo = $('label[for="dsmotivo"]', '#'+nomeForm);
		var rDsretorno = $('label[for="dsretornno"]', '#'+nomeForm);
		var rIdentificador = $('label[for="nr_identificador"]', '#'+nomeForm);
		
		var cNrcpfcgc = $('#nrcpfcgc', '#'+nomeForm);
		var cNmprimtl = $('#nmprimtl', '#'+nomeForm);
		var cNrtelefo = $('#nrtelefo', '#'+nomeForm);
		var cDsdemail = $('#dsdemail', '#'+nomeForm);
		var cDsdbanco = $('#dsdbanco', '#'+nomeForm);
		var cCdageban = $('#cdageban', '#'+nomeForm);
		var cNrispbif_banco_folha = $('#nrispbif_banco_folha', '#'+nomeForm);
		var cNrcnpjif = $('#nrcnpjif', '#'+nomeForm);
		var cNrdocnpj_emp = $('#nrdocnpj_emp', '#'+nomeForm);
		var cNmprimtl_emp = $('#nmprimtl_emp', '#'+nomeForm);
		var cNrispbif = $('#nrispbif', '#'+nomeForm);
		var cNrdocnpj = $('#nrdocnpj', '#'+nomeForm);
		var cTpconta = $('#tpconta', '#'+nomeForm);
		var cCdagectl = $('#cdagectl', '#'+nomeForm);
		var cNrdconta = $('#nrdconta', '#'+nomeForm);
		var cDscodigo = $('#dssituacao', '#'+nomeForm);
		var cDtsolicitacao = $('#dtsolicita', '#'+nomeForm);
		var cDtretorno = $('#dtretorno', '#'+nomeForm);
		var cNrnu_portabilidade = $('#nrnu_portabilidade', '#'+nomeForm);
		var cDsmotivo = $('#dsmotivo', '#'+nomeForm);
		var cDsretorno = $('#dsretornno', '#'+nomeForm);
		var cIdentificador = $('#nr_identificador', '#'+nomeForm);
		
		rNrcpfcgc.addClass('rotulo').css({ 'width': '98px' });
		cNrcpfcgc.css({ 'width': '112px' });
		
		rNmprimtl.css({ 'width': '50px' });
		cNmprimtl.css({ 'width': '250px' });
		
		rNrtelefo.addClass('rotulo').css({ 'width': '98px' });
		cNrtelefo.css({ 'width': '112px' });
		
		rDsdemail.css({ 'width': '50px' });
		cDsdemail.css({ 'width': '250px' });
		
		rDsdbanco.addClass('rotulo').css({ 'width': '98px' });
		cDsdbanco.css({ 'width': '415px' });
		
		rCdageban.css({ 'width': '80px' });
		cCdageban.css({ 'width': '80px' });
		
		rNrispbif_banco_folha.addClass('rotulo').css({ 'width': '98px' });
		cNrispbif_banco_folha.css({ 'width': '112px' });
		
		rNrcnpjif.css({ 'width': '165px' });
		cNrcnpjif.css({ 'width': '135px' });
		
		rTppessoa_emp.addClass('rotulo').css({ 'width': '98px' });

		rNrdocnpj_emp.addClass('rotulo').css({ 'width': '98px' });
		cNrdocnpj_emp.css({ 'width': '112px' });
		
		rNmprimtl_emp.css({ 'width': '52px' });
		cNmprimtl_emp.css({ 'width': '250px' });
		
		rNrispbif.addClass('rotulo').css({ 'width': '98px' });
		cNrispbif.css({ 'width': '112px' });
		
		rNrdocnpj.css({ 'width': '52px' });
		cNrdocnpj.css({ 'width': '248px' });
		
		rTpconta.addClass('rotulo').css({ 'width': '98px' });
		cTpconta.css({ 'width': '110px' });
		
		rNrdconta.css({ 'width': '72px' });
		cNrdconta.css({ 'width': '110px' });
		
		rDscodigo.addClass('rotulo').css({ 'width': '98px' });
		cDscodigo.css({ 'width': '135px' });
		
		rDtsolicitacao.addClass('rotulo').css({ 'width': '98px' });
		cDtsolicitacao.css({ 'width': '135px' });
		
		rDtretorno.css({ 'width': '132px' });
		cDtretorno.css({ 'width': '145px' });

		rNrnu_portabilidade.css({ 'width': '132px' });
		cNrnu_portabilidade.css({ 'width': '145px' });
		
		rDsmotivo.addClass('rotulo').css({ 'width': '98px' });
		cDsmotivo.css({ 'width': '416px', 'height': '45px' });
		
		rDsretorno.addClass('rotulo').css({ 'width': '98px' });
		cDsretorno.css({ 'width': '416px', 'height': '45px', 'margin-top': '5px' });
		
		rIdentificador.css({ 'width': '132px' });
		cIdentificador.css({ 'width': '145px' });


		if (cddopcao == 'C') {
			$('input,select','#'+nomeForm).desabilitaCampo();
		} else {
			$('[readonly]','#'+nomeForm).desabilitaCampo();
		}

		$('#dsdbanco').bind('change', function (){
			var $el = $(this).find(':selected'),
				nrispbif = $el.data('nrispbif'),
				nrispbif = lpad(nrispbif, 8),
				nrcnpjif = $el.data('nrcnpjif');

			$('#nrispbif_banco_folha').val(nrispbif);
			$('#nrcnpjif').val(nrcnpjif);
		});
		
    } else if (cddopcao == 'S') {

    }
	
	callafterCapital = '';
	
    divRotina.css('width', largura);
    $('#divConteudoOpcao').css({ 'height': altura, 'width': largura });

	layoutPadrao();

	hideMsgAguardo();
	bloqueiaFundo(divRotina);

	removeOpacidade('divConteudoOpcao');
	divRotina.centralizaRotinaH();

	return false;
}
    
function controlaOperacao(cddopcao) {
	switch(cddopcao) {
		// Solicita portabilidade
		case 'S':
			var cDsdbanco = $('#dsdbanco', '#'+nomeForm);
			var cDsdemail = $('#dsdemail', '#'+nomeForm);
			var vCdbccxlt = cDsdbanco.val();
			if (!vCdbccxlt) {
				showError("error", "O campo Banco Folha deve ser selecionado.", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
				cDsdbanco.focus();
				return;
			}
			if (cDsdemail.val()){
			  if (!validaEmail(cDsdemail.val())) {
    				showError("error", "E-mail inv&aacute;lido.", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
					return false;
				}
			}
			solicitaPortabilidade(false);
		break;

		// Cancela portabilidade
		case 'E':
			exibeCancelamento();
		break;
		// Contesta Portabilidade
		case 'CP':
			contestaPortabilidade();
			break;
	}
	return;
}

function solicitaPortabilidade(skipConfirm) {
	if (!skipConfirm) {
		showConfirmacao('Confirma a solicita&ccedil;&atilde;o de Portabilidade de Sal&aacute;rio para o cooperado?', 'Confirma&ccedil;&atilde;o - Aimaro', 'solicitaPortabilidade(true)', ' blockBackground(parseInt($("#divRotina").css("z-index")))', 'sim.gif', 'nao.gif');
		return;
	}

	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, solicitando portabilidade...");

	var cdbccxlt = $('#dsdbanco', '#'+nomeForm).val();
	var nrispbif_banco_folha = $('#nrispbif_banco_folha', '#'+nomeForm).val();
	var nrcnpjif = $('#nrcnpjif', '#'+nomeForm).val();

	// Carrega conteúdo da opção através de ajax
	$.ajax({
		dataType: "html",
		type: "POST",
		url: UrlSite + "telas/atenda/portabilidade/solicita_portabilidade.php",
		data: {
			nrdconta: nrdconta,
            cdbccxlt: cdbccxlt,
			cddopcao: 'S',
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

function exibeCancelamento() {
	exibeRotina($('#divUsoGenerico'));

	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, carregando motivos de cancelamento...");

	// Carrega conteúdo da opção através de ajax
	$.ajax({
		dataType: "html",
		type: "POST",
		url: UrlSite + "telas/atenda/portabilidade/form_cancela_portabilidade.php",
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
				fechaRotina($('#divRotina'));
				$("#divUsoGenerico").html(response);
			}
		}
	});
}

function contestaPortabilidade() {
	exibeRotina($('#divUsoGenerico'));

	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, carregando motivos de contesta&ccedil;&atilde;o...");

	// Carrega conteúdo da opção através de ajax
	$.ajax({
		dataType: "html",
		type: "POST",
		url: UrlSite + "telas/atenda/portabilidade/form_contesta_portabilidade.php",
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
				fechaRotina($('#divRotina'));
				$("#divUsoGenerico").html(response);
			}
		}
	});
}

function responderContestacao(rowid, idstatus) {
	exibeRotina($('#divUsoGenerico'));
	
	var dsmotivo_contestacao = $('input#dsmotivo_contestacao').val();

	// Carrega conteúdo da opção através de ajax
	$.ajax({
		dataType: "html",
		type: "POST",
		url: UrlSite + "telas/atenda/portabilidade/form_responde_contestacao.php",
		data: {
			idstatus: idstatus,
			dsrowid: rowid,
			dsmotivo: dsmotivo_contestacao,
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
				fechaRotina($('#divRotina'));
				$("#divUsoGenerico").html(response);
			}
		}
	});
}

function regularizarContestacao(rowid, idstatus) {
	exibeRotina($('#divUsoGenerico'));

	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, carregando motivos de regulariza&ccedil;&atilde;o...");

	// Carrega conteúdo da opção através de ajax
	$.ajax({
		dataType: "html",
		type: "POST",
		url: UrlSite + "telas/atenda/portabilidade/form_regularizacao_portabilidade.php",
		data: {
			idstatus: idstatus,
			dsrowid: rowid,
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
				fechaRotina($('#divRotina'));
				$("#divUsoGenerico").html(response);
			}
		}
	});
}


function confirmaCantestacaoPortabilidade(skipConfirm) {

	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, contestando portabilidade...");

	var cdmotivo = $('#cdmotivo', '#frmContestaPortabilidade').val();
	
	if (!cdmotivo){
		hideMsgAguardo();
		showError("error", "Selecione um motivo para continuar.", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
		return;
	}
	
	if (!skipConfirm) {
		showConfirmacao('Confirma a Contesta&ccedil;&atilde;o de Portabilidade?', 'Confirma&ccedil;&atilde;o - Aimaro', 'confirmaCantestacaoPortabilidade(true)', ' blockBackground(parseInt($("#divRotina").css("z-index")))', 'sim.gif', 'nao.gif');
		return;
	}

	// Carrega conteúdo da opção através de ajax
	$.ajax({
		dataType: "html",
		type: "POST",
		url: UrlSite + "telas/atenda/portabilidade/contesta_portabilidade.php",
		data: {
			nrdconta: nrdconta,
            cdmotivo: cdmotivo,
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

function buscaMotivosRespondeContestacao(){
	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, carregando motivos...");

	var idsituacao = $('input[name="idsituacao"]', '#frmResponderContestacao').val();

	// Carrega conteúdo da opção através de ajax
	$.ajax({
		dataType: "html",
		type: "POST",
		url: UrlSite + "telas/atenda/portabilidade/responde_contestacao.php",
		data: {
            idsituacao: idsituacao,
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

function confirmaRespondeContestacao(skipConfirm, rowid) {

	var cdmotivo = $('#cdmotivo', '#frmResponderContestacao').val();
	var idsituacao = $('input[name="idsituacao"]:checked', '#frmResponderContestacao').val();
	
	if (!cdmotivo){
		showError("error", "Selecione um motivo para continuar.", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
		return;
	}
	
	if (!skipConfirm) {
		showConfirmacao('Confirma o envio da resposta de contesta&ccedil;&atilde;o?', 'Confirma&ccedil;&atilde;o - Aimaro', 'confirmaRespondeContestacao(true, \''+rowid+'\')', ' blockBackground(parseInt($("#divRotina").css("z-index")))', 'sim.gif', 'nao.gif');
		return;
	}
	
	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, respondendo contesta&ccedil;&atilde;o...");

	// Carrega conteúdo da opção através de ajax
	$.ajax({
		dataType: "html",
		type: "POST",
		url: UrlSite + "telas/atenda/portabilidade/responde_contestacao.php",
		data: {
			dsrowid: rowid,
            cdmotivo: cdmotivo,
            idsituacao: idsituacao,
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

function confirmaCancelamento(skipConfirm) {
	if (!skipConfirm) {
		showConfirmacao('Confirma o cancelamento de Portabilidade de Sal&aacute;rio para o cooperado?', 'Confirma&ccedil;&atilde;o - Aimaro', 'confirmaCancelamento(true)', ' blockBackground(parseInt($("#divRotina").css("z-index")))', 'sim.gif', 'nao.gif');
		return;
	}

	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, solicitando cancelamento...");

	var cdmotivo = $('#cdmotivo', '#frmCancelaPortabilidade').val();

	// Carrega conteúdo da opção através de ajax
	$.ajax({
		dataType: "html",
		type: "POST",
		url: UrlSite + "telas/atenda/portabilidade/cancela_portabilidade.php",
		data: {
			nrdconta: nrdconta,
            cdmotivo: cdmotivo,
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

function confirmaRegularizarPortabilidade(skipConfirm, rowid) {

	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, regularizando portabilidade...");

	var cdmotivo = $('#cdmotivo', '#frmRegularizarPortabilidade').val();
	
	if (!cdmotivo){
		hideMsgAguardo();
		showError("error", "Selecione um motivo para continuar.", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
		return;
	}
	
	if (!skipConfirm) {
		showConfirmacao('Confirma a Regulariza&ccedil;&atilde;o de Portabilidade?', 'Confirma&ccedil;&atilde;o - Aimaro', 'confirmaRegularizarPortabilidade(true, \''+rowid+'\')', ' blockBackground(parseInt($("#divRotina").css("z-index")))', 'sim.gif', 'nao.gif');
		return;
	}

	// Carrega conteúdo da opção através de ajax
	$.ajax({
		dataType: "html",
		type: "POST",
		url: UrlSite + "telas/atenda/portabilidade/regulariza_portabilidade.php",
		data: {
			dsrowid: rowid,
            cdmotivo: cdmotivo,
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

function imprimirTermoAdesao(dsrowid) {
    $("#dsrowid", "#frmTermo").val(dsrowid);

    var action = $("#frmTermo").attr("action");
    var callafter = "";

    carregaImpressaoAyllos("frmTermo", action, callafter);
}

function lpad (str, max) {
  str = str.toString();
  return str.length < max ? lpad("0" + str, max) : str;
}

$(document.body).unbind('keydown').bind('keydown', function (e) {
	var target = e.target;

	switch (e.keyCode) {
		case 27:
			//fechaRotina($('#divUsoGenerico'));
			//fechaRotina(divRotina);
			//encerraRotina();
			break;
	}
 });