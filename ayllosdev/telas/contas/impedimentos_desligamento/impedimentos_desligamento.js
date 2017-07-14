/*!
 * FONTE        : impedimentos_desligamento.js
 * CRIA��O      : Lucas Reinert
 * DATA CRIA��O : Junho/2017
 * OBJETIVO     : Biblioteca de fun��es da rotina Impedimentos Desligamento da tela de CONTAS
 * --------------
 * ALTERA��ES   :
 * --------------
 */

// Fun��o para acessar op��es da rotina
function acessaOpcaoAba(nrOpcoes,id,opcao) {  
	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, carregando...");
	
	// Atribui cor de destaque para aba da op��o
	for (var i = 0; i < nrOpcoes; i++) {
		if (id == i) { // Atribui estilos para foco da op��o
			$("#linkAba" + id).attr("class","txtBrancoBold");
			$("#imgAbaEsq" + id).attr("src",UrlImagens + "background/mnu_sle.gif");				
			$("#imgAbaDir" + id).attr("src",UrlImagens + "background/mnu_sld.gif");
			$("#imgAbaCen" + id).css("background-color","#969FA9");
			continue;			
		}
		
		$("#linkAba" + i).attr("class","txtNormalBold");
		$("#imgAbaEsq" + i).attr("src",UrlImagens + "background/mnu_nle.gif");			
		$("#imgAbaDir" + i).attr("src",UrlImagens + "background/mnu_nld.gif");
		$("#imgAbaCen" + i).css("background-color","#C6C8CA");
	}

	// Carrega conte�do da op��o atrav�s de ajax
	$.ajax({		
		type: "POST", 
		dataType: "html",
		url: UrlSite + "telas/contas/impedimentos_desligamento/principal.php",
		data: {
			nrdconta: nrdconta,
			idseqttl: idseqttl,
			redirect: "html_ajax"
		},
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError('error','N&atilde;o foi poss�vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos',bloqueiaFundo(divRotina));
		},
		success: function(response) {		
			if ( response.indexOf('showError("error"') == -1 ) {
				$('#divConteudoOpcao').html(response);
			} else {
				eval( response );				
			}
			return false;
		}				
	});
		
}

function controlaLayout(operacao) {	
	
	$('#divConteudoOpcao').hide(0, function() {

		// Controla a altura da tela		
		$('#divConteudoOpcao').css('width','670px');
		$('#divConteudoOpcao').css('height','640px');
								
		layoutPadrao();
		hideMsgAguardo();
		bloqueiaFundo(divRotina);	
		$(this).fadeIn(1000);
		divRotina.centralizaRotinaH(); 
	});	
	
	return false;	
}	

function efetuaCancelamentoAuto(){
	
    //Mostra mensagem de aguardo
    showMsgAguardo('Aguarde, efetuando cancelamento autom&aacute;tico ...');
	
	var flaceint = 0;
	var	flaplica = 0;
	var flfolpag = 0;
	var fldebaut = 0;
	var fllimint = 0;
	var flplacot = 0;
    var flpouppr = 0;
	
    $('input[type="checkbox"]', '#frmCancAuto').each(function (i) {

        if ($(this).attr('checked')) {
			switch ($(this).attr('id')) {
				//ATENDA -> EMPRESTIMOS/FINANCIAMENTOS
				case "1":
					flaceint = 1;
					break;
				case "3":
					flaplica = 1;
					break;
				case "8":
					flfolpag = 1;
					break
				case "10":
					fldebaut = 1;
					break;
				case "14":
					fllimint = 1;
					break;
				case "15":
					flplacot = 1;
					break;
				case "16":
					flpouppr = 1;
					break;
			}
		}
	});
	
	
	// Carrega conte�do da op��o atrav�s de ajax
	$.ajax({		
		type: "POST", 
		dataType: "script",
		url: UrlSite + "telas/contas/impedimentos_desligamento/efetua_canc_auto.php",
		data: {
			nrdconta: nrdconta,
			idseqttl: idseqttl,
			flaceint: flaceint,
			flaplica: flaplica,
			flfolpag: flfolpag,
			fldebaut: fldebaut,
			fllimint: fllimint,
			flplacot: flplacot,
			flpouppr: flpouppr,
			redirect: "html_ajax"
		},
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError('error','N&atilde;o foi poss�vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos',bloqueiaFundo(divRotina));
		},
		success: function(response) {		
            hideMsgAguardo();
			eval(response);
			return false;
		}				
	});	
}

function efetuaCancelamentoManual(){
	
	produtosCancM = new Array();
	produtosCancMAtenda = new Array();
	var index = 0;	
	var flgcheque = false;
	// Percorrendo todos os checkbox do frmCancManl
    $('input[type="checkbox"]', '#frmCancManl').each(function (i) {

        if ($(this).attr('checked')) {
			switch ($(this).attr('id')) {

				//ATENDA -> EMPRESTIMOS/FINANCIAMENTOS
				case "1":
					produtosCancM[index] = 'showMsgAguardo(\'Aguarde, carregando tela ATENDA ...\'); ' + 
										   'setaParametros(\'ATENDA\',\'\',nrdconta,flgcadas); ' +
										   'setaImped();' +
										   'direcionaTela(\'ATENDA\',\'no\');';
					produtosCancMAtenda[index] = 'acessaRotina(\'\',\'PRESTACOES\',\'Presta&ccedil;&otilde;oes\',\'prestacoes\');';
					produtosCancMContas[index] = '';
					index++;
					break;

				//ATENDA -> LIMITE DE CR�DITO
				case "2":

					produtosCancM[index] = 'showMsgAguardo(\'Aguarde, carregando tela ATENDA ...\'); ' + 
										   'setaParametros(\'ATENDA\',\'\',nrdconta,flgcadas); ' +
										   'setaImped();' +
										   'direcionaTela(\'ATENDA\',\'no\');';
					produtosCancMAtenda[index] = 'acessaRotina(\'\',\'LIMITE CRED\',\'Limite de Cr&eacute;dito\',\'limite_credito\');';
					produtosCancMContas[index] = '';
					index++;

					break;

				//ATENDA -> DESCONTOS
				case "3":

					produtosCancM[index] = 'showMsgAguardo(\'Aguarde, carregando tela ATENDA ...\'); ' + 
										   'setaParametros(\'ATENDA\',\'\',nrdconta,flgcadas); ' +
										   'setaImped();' +
										   'direcionaTela(\'ATENDA\',\'no\');';
					produtosCancMAtenda[index] = 'acessaRotina(\'\',\'DESCONTOS\',\'Descontos\',\'descontos\');';
					produtosCancMContas[index] = '';
					index++;

					break;

				//ATENDA -> BORDER�S
				case "4":

					produtosCancM[index] = 'showMsgAguardo(\'Aguarde, carregando tela ATENDA ...\'); ' + 
										   'setaParametros(\'ATENDA\',\'\',nrdconta,flgcadas); ' +
										   'setaImped();' +
										   'direcionaTela(\'ATENDA\',\'no\');';
					produtosCancMAtenda[index] = 'acessaRotina(\'\',\'DESCONTOS\',\'Descontos\',\'descontos\');';
					produtosCancMContas[index] = '';
					index++;

					break;

				//ATENDA -> CART�ES DE CR�DITO
				case "5":

					produtosCancM[index] = 'showMsgAguardo(\'Aguarde, carregando tela ATENDA ...\'); ' + 
										   'setaParametros(\'ATENDA\',\'\',nrdconta,flgcadas); ' +
										   'setaImped();' +
										   'direcionaTela(\'ATENDA\',\'no\');';
					produtosCancMAtenda[index] = 'acessaRotina(\'\',\'CARTAO CRED\',\'Cart&otilde;es de Cr&eacute;dito\',\'cartao_credito\');';
					produtosCancMContas[index] = '';
					index++;

					break;

				//ATENDA -> APLICA��ES
				case "6":

					produtosCancM[index] = 'showMsgAguardo(\'Aguarde, carregando tela ATENDA ...\'); ' + 
										   'setaParametros(\'ATENDA\',\'\',nrdconta,flgcadas); ' +
										   'setaImped();' +
										   'direcionaTela(\'ATENDA\',\'no\');';
					produtosCancMAtenda[index] = 'acessaRotina(\'\',\'APLICACOES\',\'Aplica&ccedil;&otilde;es\',\'aplicacoes\');';
					produtosCancMContas[index] = '';
					index++;

					break;

				//ATENDA -> POUPAN�A PROGRAMADA
				case "7":

					produtosCancM[index] = 'showMsgAguardo(\'Aguarde, carregando tela ATENDA ...\'); ' + 
										   'setaParametros(\'ATENDA\',\'\',nrdconta,flgcadas); ' +
										   'setaImped();' +
										   'direcionaTela(\'ATENDA\',\'no\');';
					produtosCancMAtenda[index] = 'acessaRotina(\'\',\'POUP. PROG\',\'Poupan&ccedil;a Programada\',\'poupanca_programada\');';
					produtosCancMContas[index] = '';
					index++;

					break;

				//PAGAMENTO POR ARQUIVO
				case "8":

					produtosCancM[index] = 'showMsgAguardo(\'Aguarde, carregando tela ATENDA ...\'); ' + 
										   'setaParametros(\'ATENDA\',\'\',nrdconta,flgcadas); ' +
										   'setaImped();' +
										   'direcionaTela(\'ATENDA\',\'no\');';
					produtosCancMAtenda[index] = 'acessaRotina(\'\',\'PAGTO POR ARQUIVO\',\'Pagto. por arquivo\',\'pagamento_titulo_arq\');';
					produtosCancMContas[index] = '';
					index++;

					break;					
					
				//COBRAN -> ATENDA -> COBRANCA
				case "9":

					produtosCancM[index] = 'showMsgAguardo(\'Aguarde, carregando tela COBRAN ...\'); ' + 
										   'setaParametrosImped(\'COBRAN\',\'\',nrdconta,flgcadas, \'IMPEDI\'); ' +
										   'setaImped();' +
										   'direcionaTela(\'COBRAN\',\'no\');';
					produtosCancMAtenda[index] = '';
					produtosCancMContas[index] = '';
					index++;

					break;

				//ATENDA -> SEGUROS
				case "10":

					produtosCancM[index] = 'showMsgAguardo(\'Aguarde, carregando tela ATENDA ...\'); ' + 
										   'setaParametros(\'ATENDA\',\'\',nrdconta,flgcadas); ' +
										   'setaImped();' +
										   'direcionaTela(\'ATENDA\',\'no\');';
					produtosCancMAtenda[index] = "impedSeguros();";
					produtosCancMContas[index] = '';
					index++;

					break;

				//ATENDA -> CONS�RCIOS
				case "11":

					produtosCancM[index] = 'showMsgAguardo(\'Aguarde, carregando tela ATENDA ...\'); ' + 
										   'setaParametros(\'ATENDA\',\'\',nrdconta,flgcadas); ' +
										   'setaImped();' +
										   'direcionaTela(\'ATENDA\',\'no\');';
					produtosCancMAtenda[index] = "impedConsorcios();";
					produtosCancMContas[index] = '';
					index++;

					break;

				//CONTAS -> ENCERRAR ITG
				case "12":

					produtosCancM[index] = 'showMsgAguardo(\'Aguarde, carregando tela CONTAS ...\'); ' + 
										   'setaParametrosImped(\'CONTAS\',\'\',nrdconta,flgcadas, \'CONTAS\');' +
										   'setaImped();' +					
										   'direcionaTela(\'CONTAS\',\'no\');';
					produtosCancMAtenda[index] = '';
					produtosCancMContas[index] = 'acessaRotina(\'CONTA CORRENTE\',\'Conta Corrente\',\'conta_corrente\');';
					index++;

					break;

				//VENDAS COM CART�ES - BANCOOB
				case "13":
				
					produtosCancM[index] = 'showMsgAguardo(\'Aguarde, carregando tela CONTAS ...\'); ' + 
										   'setaParametrosImped(\'CONTAS\',\'\',nrdconta,flgcadas, \'CONTAS\');' +
										   'setaImped();' +					
										   'direcionaTela(\'CONTAS\',\'no\');';
					produtosCancMAtenda[index] = '';
					produtosCancMContas[index] = "showError('error','Cooperado possui cart&atilde;o Bancoob, orienta-lo a entrar em contato com a institui&ccedil;&atilde;o para efetuar o cancelamento','Alerta - Ayllos','sequenciaImpedimentos();');";
					index++;

					break;

				//VENDAS COM CART�ES - BB
				case "14":

					produtosCancM[index] = 'showMsgAguardo(\'Aguarde, carregando tela CONTAS ...\'); ' + 
										   'setaParametrosImped(\'CONTAS\',\'\',nrdconta,flgcadas, \'CONTAS\');' +
										   'setaImped();' +					
										   'direcionaTela(\'CONTAS\',\'no\');';
					produtosCancMAtenda[index] = '';
					produtosCancMContas[index] = "showError('error','Cooperado possui cart&atilde;o BB, orienta-lo a entrar em contato com a institui&ccedil;&atilde;o para efetuar o cancelamento','Alerta -  Ayllos','sequenciaImpedimentos();');";
					index++;

					break;

				//CHEQUE -> FOLHAS DE CHEQUE EM USO
				case "15":
					
					if (!flgcheque){
						flgcheque = true;
						produtosCancM[index] = 'showMsgAguardo(\'Aguarde, carregando tela CHEQUE ...\'); ' + 
											   'setaParametrosImped(\'CHEQUE\',\'\',nrdconta,flgcadas, \'CHEQUE\');' +
											   'setaImped();' +					
											   'direcionaTela(\'CHEQUE\',\'no\');';
						produtosCancMAtenda[index] = '';
						produtosCancMContas[index] = '';
						index++;
					}
					break;

				//CHEQUE -> CHEQUES DEVOLVIDOS
				case "16":
				
					if (!flgcheque){
						flgcheque = true;
						produtosCancM[index] = 'showMsgAguardo(\'Aguarde, carregando tela CHEQUE ...\'); ' + 
											   'setaParametrosImped(\'CHEQUE\',\'\',nrdconta,flgcadas, \'CHEQUE\');' +
											   'setaImped();' +					
											   'direcionaTela(\'CHEQUE\',\'no\');';
						produtosCancMAtenda[index] = '';
						produtosCancMContas[index] = '';
						index++;
					}
					break;

				//CHEQUE -> TALON�RIOS EM ESTOQUE
				case "17":
					if (!flgcheque){
						flgcheque = true;
						produtosCancM[index] = 'showMsgAguardo(\'Aguarde, carregando tela CHEQUE ...\'); ' + 
											   'setaParametrosImped(\'CHEQUE\',\'\',nrdconta,flgcadas, \'CHEQUE\');' +
											   'setaImped();' +					
											   'direcionaTela(\'CHEQUE\',\'no\');';
						produtosCancMAtenda[index] = '';
						produtosCancMContas[index] = '';
						index++;
					}
					break;

				//CHEQUE -> CHEQUES CANCELADOS
				case "18":
					if (!flgcheque){
						flgcheque = true;
						produtosCancM[index] = 'showMsgAguardo(\'Aguarde, carregando tela CHEQUE ...\'); ' + 
											   'setaParametrosImped(\'CHEQUE\',\'\',nrdconta,flgcadas, \'CHEQUE\');' +
											   'setaImped();' +					
											   'direcionaTela(\'CHEQUE\',\'no\');';
						produtosCancMAtenda[index] = '';
						produtosCancMContas[index] = '';
						index++;
					}
					break;

				//BENEFICIO INSS
				case "19":

					produtosCancM[index] = 'showMsgAguardo(\'Aguarde, carregando tela CONTAS ...\'); ' + 
										   'setaParametrosImped(\'CONTAS\',\'\',nrdconta,flgcadas, \'CONTAS\');' +
										   'setaImped();' +					
										   'direcionaTela(\'CONTAS\',\'no\');';
					produtosCancMAtenda[index] = '';
					produtosCancMContas[index] = "showError('error','Orientar o cooperado a transferir o benef&iacute;cio do INSS para outra institui&ccedil;&atilde;o.','Alerta - Ayllos','sequenciaImpedimentos();');";
					index++;

					break;

				//BENEFICIO INSS
				case "20":

					produtosCancM[index] = 'showMsgAguardo(\'Aguarde, carregando tela CONTAS ...\'); ' + 
										   'setaParametrosImped(\'CONTAS\',\'\',nrdconta,flgcadas, \'CONTAS\');' +
										   'setaImped();' +					
										   'direcionaTela(\'CONTAS\',\'no\');';
					produtosCancMAtenda[index] = '';
					produtosCancMContas[index] = "showError('error','Verificar na Sede se cooperado possui produtos Procapcred, Finame, Cart&atilde;o BNDES e Inovacred.','Alerta - Ayllos','sequenciaImpedimentos();');";
					index++;

					break;
					
			}
			produtosCancM[index - 1] = 'cdproduto = ' + $(this).attr('id') + ";" + produtosCancM[index - 1];			
		}
    });
	
	if (produtosCancM.length > 0) {	
		produtosCancM[index] = 'setaParametrosImped(\'CONTAS\',\'\',nrdconta,flgcadas, \'IMPEDI\');direcionaTela(\'CONTAS\',\'no\');';
	}
	
	if (produtosCancM.length == 0) {

		showError("error", "Nenhum produto foi selecionado.", "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')));");
		return false;

	} else {
		$("#divRotina").css({ 'margin-left': '', 'margin-top': '', "visibility": "hidden" });// Restaurar valores;
		eval(produtosCancM[0]);
		posicao++;

	}
}
