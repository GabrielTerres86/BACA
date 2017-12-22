/*!
 * FONTE        : impedimentos_desligamento.js
 * CRIAÇÃO      : Lucas Reinert
 * DATA CRIAÇÃO : Junho/2017
 * OBJETIVO     : Biblioteca de funções da rotina Impedimentos Desligamento da tela de CONTAS
 * --------------
 * ALTERAÇÕES   : 14/11/2017 - Ajsute para inclusão de novo item para impedimento (Jonata - RKAM P364).
 * --------------
                  21/11/2017 - Ajuste para controle das mensagens de alerta referente a seguro (Jonata - RKAM P364).
 */

// Função para acessar opções da rotina
function acessaOpcaoAba(nrOpcoes,id,opcao) {  
	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, carregando...");
	
	// Atribui cor de destaque para aba da opção
	for (var i = 0; i < nrOpcoes; i++) {
		if (id == i) { // Atribui estilos para foco da opção
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

	// Carrega conteúdo da opção através de ajax
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
			showError('error','N&atilde;o foi possível concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos',bloqueiaFundo(divRotina));
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
	    $('#divConteudoOpcao').css({ 'height': 'auto' });
		$('#divImpedimentos').css({ 'display': 'block', 'height': '100%' });

		$('#frmCancAuto').css({ 'display': 'block', 'float': 'left', 'width': '40%' });
		$('#frmCancManl').css({ 'display': 'block', 'float': 'left', 'width': '60%' });

		$('#divBotoes', '#divImpedimentos').css({ 'display': 'block', 'margin-top': '5px', 'margin-bottom': '10px', 'text-align': 'center', 'width': '100%' });
		$('#divBotoesAuto', '#divImpedimentos').css({ 'display': 'block', 'float': 'left', 'width': '40%' });
		$('#divBotoesManual', '#divImpedimentos').css({ 'display': 'block', 'float': 'right', 'width': '60%' });
		$('fieldset', '#divImpedimentos').css({ 'padding': '0px', 'height': '100%', 'width': '95%' });
								
		layoutPadrao();
		hideMsgAguardo();
		bloqueiaFundo(divRotina);	
		$(this).fadeIn(1000);
		divRotina.centralizaRotinaH(); 
		$('input[type="checkbox"]', '#frmCancAuto').each(function (i) {		
			$(this).prop('checked', true);
		});
	});	
	
	return false;	
}	

function efetuaCancelamentoAuto(){
	
	var flaceint = 0;
	var	flaplica = 0;
	var flfolpag = 0;
	var fldebaut = 0;
	var fllimint = 0;
	var flplacot = 0;
    var flpouppr = 0;
	var checkprd = false;
	
    $('input[type="checkbox"]', '#frmCancAuto').each(function (i) {

        if ($(this).attr('checked')) {
			// Se checou algum produto atribuir flag
			checkprd = true;
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
	
	if (!checkprd){
		showError("error", "Nenhum produto foi selecionado.", "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')));");
		return false;
	}
	
    //Mostra mensagem de aguardo
    showMsgAguardo('Aguarde, efetuando cancelamento autom&aacute;tico ...');
	
	// Carrega conteúdo da opção através de ajax
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
			showError('error','N&atilde;o foi possível concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos',bloqueiaFundo(divRotina));
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
	produtosCancMContas = new Array();
	produtosCancMCheque = new Array();
	var index = 0;	

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
					produtosCancMCheque[index] = '';
					index++;
					break;

				//ATENDA -> LIMITE DE CRÉDITO
				case "2":

					produtosCancM[index] = 'showMsgAguardo(\'Aguarde, carregando tela ATENDA ...\'); ' + 
										   'setaParametros(\'ATENDA\',\'\',nrdconta,flgcadas); ' +
										   'setaImped();' +
										   'direcionaTela(\'ATENDA\',\'no\');';
					produtosCancMAtenda[index] = 'acessaRotina(\'\',\'LIMITE CRED\',\'Limite de Cr&eacute;dito\',\'limite_credito\');';
					produtosCancMContas[index] = '';
					produtosCancMCheque[index] = '';
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
					produtosCancMCheque[index] = '';
					index++;

					break;

				//ATENDA -> BORDERÔS
				case "4":

					produtosCancM[index] = 'showMsgAguardo(\'Aguarde, carregando tela ATENDA ...\'); ' + 
										   'setaParametros(\'ATENDA\',\'\',nrdconta,flgcadas); ' +
										   'setaImped();' +
										   'direcionaTela(\'ATENDA\',\'no\');';
					produtosCancMAtenda[index] = 'acessaRotina(\'\',\'DESCONTOS\',\'Descontos\',\'descontos\');';
					produtosCancMContas[index] = '';
					produtosCancMCheque[index] = '';
					index++;

					break;

				//ATENDA -> CARTÕES DE CRÉDITO
				case "5":

					produtosCancM[index] = 'showMsgAguardo(\'Aguarde, carregando tela ATENDA ...\'); ' + 
										   'setaParametros(\'ATENDA\',\'\',nrdconta,flgcadas); ' +
										   'setaImped();' +
										   'direcionaTela(\'ATENDA\',\'no\');';
					produtosCancMAtenda[index] = 'acessaRotina(\'\',\'CARTAO CRED\',\'Cart&otilde;es de Cr&eacute;dito\',\'cartao_credito\');';
					produtosCancMContas[index] = '';
					produtosCancMCheque[index] = '';
					index++;

					break;

				//ATENDA -> APLICAÇÕES
				case "6":

					produtosCancM[index] = 'showMsgAguardo(\'Aguarde, carregando tela ATENDA ...\'); ' + 
										   'setaParametros(\'ATENDA\',\'\',nrdconta,flgcadas); ' +
										   'setaImped();' +
										   'direcionaTela(\'ATENDA\',\'no\');';
					produtosCancMAtenda[index] = 'acessaRotina(\'\',\'APLICACOES\',\'Aplica&ccedil;&otilde;es\',\'aplicacoes\');';
					produtosCancMContas[index] = '';
					produtosCancMCheque[index] = '';
					index++;

					break;

				//ATENDA -> POUPANÇA PROGRAMADA
				case "7":

			        produtosCancM[index] = 'showMsgAguardo(\'Aguarde, carregando tela ATENDA ...\'); ' +
										   'setaParametros(\'ATENDA\',\'\',nrdconta,flgcadas); ' +
										   'setaImped();' +
										   'direcionaTela(\'ATENDA\',\'no\');';
			        produtosCancMAtenda[index] = 'acessaRotina(\'\',\'POUP. PROG\',\'Poupan&ccedil;a Programada\',\'poupanca_programada\');';
			        produtosCancMContas[index] = '';
			        produtosCancMCheque[index] = '';
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
					produtosCancMCheque[index] = '';
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
					produtosCancMCheque[index] = '';
					index++;

					break;

				//ATENDA -> SEGUROS
				case "10":

				    var seguroVida = $('#flsegauto', '#frmCancManl').val();
				    var seguroAuto = $('#flsegvida', '#frmCancManl').val();

					produtosCancM[index] = 'showMsgAguardo(\'Aguarde, carregando tela ATENDA ...\'); ' + 
										   'setaParametros(\'ATENDA\',\'\',nrdconta,flgcadas); ' +
										   'setaImped();' +
										   'direcionaTela(\'ATENDA\',\'no\');';
					produtosCancMAtenda[index] = "impedSeguros(\'" + seguroVida + "\',\'" + seguroAuto + "\');";
					produtosCancMContas[index] = '';
					produtosCancMCheque[index] = '';
					index++;

					break;

				//ATENDA -> CONSÓRCIOS
				case "11":

					produtosCancM[index] = 'showMsgAguardo(\'Aguarde, carregando tela ATENDA ...\'); ' + 
										   'setaParametros(\'ATENDA\',\'\',nrdconta,flgcadas); ' +
										   'setaImped();' +
										   'direcionaTela(\'ATENDA\',\'no\');';
					produtosCancMAtenda[index] = "impedConsorcios();";
					produtosCancMContas[index] = '';
					produtosCancMCheque[index] = '';
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
					produtosCancMCheque[index] = '';
					index++;

					break;

				//VENDAS COM CARTÕES - BANCOOB
				case "13":
				
					produtosCancM[index] = 'showMsgAguardo(\'Aguarde, carregando tela CONTAS ...\'); ' + 
										   'setaParametrosImped(\'CONTAS\',\'\',nrdconta,flgcadas, \'CONTAS\');' +
										   'setaImped();' +					
										   'direcionaTela(\'CONTAS\',\'no\');';
					produtosCancMAtenda[index] = '';
					produtosCancMContas[index] = "showError('error','Cooperado possui cart&atilde;o Bancoob, orienta-lo a entrar em contato com a institui&ccedil;&atilde;o para efetuar o cancelamento','Alerta - Ayllos','sequenciaImpedimentos();');";
					produtosCancMCheque[index] = '';
					index++;

					break;

				//VENDAS COM CARTÕES - BB
				case "14":

					/*produtosCancM[index] = 'showMsgAguardo(\'Aguarde, carregando tela CONTAS ...\'); ' + 
										   'setaParametrosImped(\'CONTAS\',\'\',nrdconta,flgcadas, \'CONTAS\');' +
										   'setaImped();' +					
										   'direcionaTela(\'CONTAS\',\'no\');';
					produtosCancMAtenda[index] = '';
					produtosCancMContas[index] = '';
					produtosCancMCheque[index] = '';*/
					
					$.ajax({		
						type: "POST", 
						dataType: "html",
						url: UrlSite + "telas/contas/impedimentos_desligamento/efetua_ok_para_cartoes_bb.php",
						data: {
							nrdconta: nrdconta,
							idseqttl: idseqttl,
							redirect: "html_ajax"
						},
						error: function(objAjax,responseError,objExcept) {
							hideMsgAguardo();
							showError('error','N&atilde;o foi possível concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos',bloqueiaFundo(divRotina));
						},
						success: function(response) {		
							
							eval( response );
							
							return false;
						}				
					});
					
					//showError('error','Efetue o cancelamento do cartao junto ao Banco do Brasil.','Alerta - Ayllos','');
					
					index++;

					break;

			    //CHEQUE -> FOLHAS DE CHEQUE EM USO
				case "15":
					
				    produtosCancM[index] = 'showMsgAguardo(\'Aguarde, carregando tela CHEQUE ...\'); ' +
										   'setaParametrosImped(\'CHEQUE\',\'\',nrdconta,flgcadas, \'CHEQUE\');' +
										   'setaImped();' +
										   'direcionaTela(\'CHEQUE\',\'no\');';
				    produtosCancMAtenda[index] = '';
				    produtosCancMContas[index] = '';
				    produtosCancMCheque[index] = 'tppeschq = \'1\';'; // Chq em uso
				    index++;

                    produtosCancM[index]= 'showMsgAguardo(\'Aguarde, carregando tela MANTAL ...\'); ' +
										   'setaParametrosImped(\'MANTAL\',\'\',nrdconta,flgcadas, \'IMPEDI\'); ' +
										   'setaImped();' +
										   'direcionaTela(\'MANTAL\',\'no\');';
					produtosCancMAtenda[index]= '';
					produtosCancMContas[index]= '';
					produtosCancMCheque[index]= '';
					index++;
					
					break;

				//CHEQUE -> CHEQUES CANCELADOS
				case "16":
					produtosCancM[index] = 'showMsgAguardo(\'Aguarde, carregando tela CHEQUE ...\'); ' + 
										   'setaParametrosImped(\'CHEQUE\',\'\',nrdconta,flgcadas, \'CHEQUE\');' +
										   'setaImped();' +					
										   'direcionaTela(\'CHEQUE\',\'no\');';
					produtosCancMAtenda[index] = '';
					produtosCancMContas[index] = '';
					produtosCancMCheque[index] = 'tppeschq = \'3\';'; // Chq cancelados
					index++;
					
					break;					
					
				//CHEQUE -> TALONÁRIOS EM ESTOQUE
				case "17":
					produtosCancM[index] = 'showMsgAguardo(\'Aguarde, carregando tela CHEQUE ...\'); ' + 
										   'setaParametrosImped(\'CHEQUE\',\'\',nrdconta,flgcadas, \'CHEQUE\');' +
										   'setaImped();' +					
										   'direcionaTela(\'CHEQUE\',\'no\');';
					produtosCancMAtenda[index] = '';
					produtosCancMContas[index] = '';
					produtosCancMCheque[index] = 'tppeschq = \'1\';'; // Chq em uso
					index++;
					
					break;
					
				//CHEQUE -> CHEQUES DEVOLVIDOS
				case "18":
					produtosCancM[index] = 'showMsgAguardo(\'Aguarde, carregando tela ESTOUR ...\'); ' + 
										   'setaParametrosImped(\'ESTOUR\',\'\',nrdconta,flgcadas, \'ESTOUR\');' +
										   'setaImped();' +					
										   'direcionaTela(\'ESTOUR\',\'no\');';
					produtosCancMAtenda[index] = '';
					produtosCancMContas[index] = '';
					produtosCancMCheque[index] = ''; // Chq devolvidos
					index++;
					
					break;
				
				//BENEFICIO INSS
				case "19":

					produtosCancM[index] = 'showMsgAguardo(\'Aguarde, carregando tela CONTAS ...\'); ' + 
										   'setaParametrosImped(\'CONTAS\',\'\',nrdconta,flgcadas, \'CONTAS\');' +
										   'setaImped();' +					
										   'direcionaTela(\'CONTAS\',\'no\');';
					produtosCancMAtenda[index] = '';
					produtosCancMContas[index] = "showError('error','Orientar o cooperado a transferir o benef&iacute;cio do INSS para outra institui&ccedil;&atilde;o.','Alerta - Ayllos','sequenciaImpedimentos();');";
					produtosCancMCheque[index] = '';
					index++;

					break;

				//PRODUTOS BRDE
				case "20":

					produtosCancM[index] = 'showMsgAguardo(\'Aguarde, carregando tela CONTAS ...\'); ' + 
										   'setaParametrosImped(\'CONTAS\',\'\',nrdconta,flgcadas, \'CONTAS\');' +
										   'setaImped();' +					
										   'direcionaTela(\'CONTAS\',\'no\');';
					produtosCancMAtenda[index] = '';
					produtosCancMContas[index] = "showError('error','Verificar na Sede se cooperado possui produtos Procapcred, Finame, Cart&atilde;o BNDES e Inovacred.','Alerta - Ayllos','sequenciaImpedimentos();');";
					produtosCancMCheque[index] = '';
					index++;

					break;
					
				//Lançamentos futuros
				case "21":
				
					produtosCancM[index] = 'showMsgAguardo(\'Aguarde, carregando tela ATENDA ...\'); ' + 
										   'setaParametros(\'ATENDA\',\'\',nrdconta,flgcadas); ' +
										   'setaImped();' +
										   'direcionaTela(\'ATENDA\',\'no\');';
					produtosCancMAtenda[index] = 'acessaRotina(\'\',\'LAUTOM\',\'Lan&ccedil;amentos Futuros\',\'lancamentos_futuros\');';
					produtosCancMContas[index] = '';
					produtosCancMCheque[index] = '';
					index++;
					
					break;
					
				//Cartões magnético
				case "22":
				
					produtosCancM[index] = 'showMsgAguardo(\'Aguarde, carregando tela ATENDA ...\'); ' + 
										   'setaParametros(\'ATENDA\',\'\',nrdconta,flgcadas); ' +
										   'setaImped();' +
										   'direcionaTela(\'ATENDA\',\'no\');';
					produtosCancMAtenda[index] = 'acessaRotina(\'\',\'MAGNETICO\',\'Cart&otilde;es Magn&eacute;ticos\',\'magneticos\');';
					produtosCancMContas[index] = '';
					produtosCancMCheque[index] = '';
					index++;
					
					break;

				//CHEQUE -> FOLHAS DE CHEQUE EM ESTOQUE
				case "23":

						produtosCancM[index] = 'showMsgAguardo(\'Aguarde, carregando tela CHEQUE ...\'); ' +
										 'setaParametrosImped(\'CHEQUE\',\'\',nrdconta,flgcadas, \'CHEQUE\');' +
										 'setaImped();' +
										 'direcionaTela(\'CHEQUE\',\'no\');';
						produtosCancMAtenda[index] = '';
						produtosCancMContas[index] = '';
						produtosCancMCheque[index] = 'tppeschq = \'2\';'; // Chq EM ESTOQUE / ARQUIVO
						index++;

						produtosCancM[index] = 'showMsgAguardo(\'Aguarde, carregando tela MANTAL ...\'); ' +
										 'setaParametrosImped(\'MANTAL\',\'\',nrdconta,flgcadas, \'IMPEDI\'); ' +
										 'setaImped();' +
										 'direcionaTela(\'MANTAL\',\'no\');';
						produtosCancMAtenda[index] = '';
						produtosCancMContas[index] = '';
						produtosCancMCheque[index] = '';
						index++;

						break;
						
				//CONVENIO CDC
				case "24":
									
					produtosCancM[index] = 'showMsgAguardo(\'Aguarde, carregando tela ATENDA ...\'); '  + 
										   'setaParametros(\'ATENDA\',\'\',nrdconta,flgcadas); ' +
										   'setaImped();' +
										   'direcionaTela(\'ATENDA\',\'no\');';
					produtosCancMAtenda[index] = 'acessaRotina(\'\',\'CONVENIO CDC\',\'Conv&ecirc;nio CDC\',\'convenio_cdc\');';
					produtosCancMContas[index] = '';
					produtosCancMCheque[index] = '';
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



function finalizarRotina() {

    executandoImpedimentos = false;
    flgimped = false;
    fechaRotina(divRotina);

}