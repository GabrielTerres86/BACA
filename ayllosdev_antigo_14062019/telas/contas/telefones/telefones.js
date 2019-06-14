/*!
 * FONTE        : telefones.js
 * CRIAÇÃO      : Rodolpho Telmo (DB1)
 * DATA CRIAÇÃO : 19/05/2010 
 * OBJETIVO     : Biblioteca de funções na rotina TELEFONES da tela de CONTAS
 *
 * ALTERACOES   : 04/08/2015 - Reformulacao Cadastral (Gabriel-RKAM).	
 *				  18/10/2016 - Correcao no envio de dados para XML removendo caract. especiais. (Carlos Rafael Tanholi - SD 540832)
 */

var nrdrowid  = ''; 
var operacao  = '';
var cddopcao  = '';
var cdopetfn  = '';
var nomeForm  = 'frmTelefones';
 
function acessaOpcaoAba(nrOpcoes,id,opcao) {

	// Mostra mensagem de aguardo
	showMsgAguardo('Aguarde, carregando...');
	
	// Atribui cor de destaque para aba da opção
	for (var i = 0; i < nrOpcoes; i++) {
		if (!$('#linkAba' + id)) {
			continue;
		}
		
		if (id == i) { // Atribui estilos para foco da opção
			$('#linkAba'   + id).attr('class','txtBrancoBold');
			$('#imgAbaEsq' + id).attr('src',UrlImagens + 'background/mnu_sle.gif');				
			$('#imgAbaDir' + id).attr('src',UrlImagens + 'background/mnu_sld.gif');
			$('#imgAbaCen' + id).css('background-color','#969FA9');
			continue;			
		}
		
		$('#linkAba'   + i).attr('class','txtNormalBold');
		$('#imgAbaEsq' + i).attr('src',UrlImagens + 'background/mnu_nle.gif');			
		$('#imgAbaDir' + i).attr('src',UrlImagens + 'background/mnu_nld.gif');
		$('#imgAbaCen' + i).css('background-color','#C6C8CA');
	}	
	
	// Carrega conteúdo da opção através do Ajax
	$.ajax({		
		type: 'POST', 
		dataType: 'html',
		url: UrlSite + 'telas/contas/telefones/principal.php',
		data: {
			nrdconta: nrdconta,
			idseqttl: idseqttl,
			inpessoa: inpessoa,
			flgcadas: flgcadas,
			operacao: operacao,
			redirect: 'html_ajax'
		},		
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError('error','N&atilde;o foi possível concluir a requisi&ccedil;&atilde;o.','Alerta - Aimaro','bloqueiaFundo(divRotina)');
		},
		success: function(response) {
			if ( response.indexOf('showError("error"') == -1 ) {
				$('#divConteudoOpcao').html(response);
			} else {
				eval( response );
				controlaFoco( operacao );
			}
			return false;
		}				 
	});
}

function controlaOperacao(operacao) {
	
	if ( operacao != 'EV' && operacao != 'CA' && !verificaContadorSelect() ) return false;
	
	if ( (operacao == 'TA') && (flgAlterar   != '1') ) { showError('error','Seu usu&aacute;rio n&atilde;o possui permiss&atilde;o de altera&ccedil;&atilde;o.','Alerta - Aimaro','bloqueiaFundo(divRotina)'); return false; }
	if ( (operacao == 'TX') && (flgExcluir   != '1') ) { showError('error','Seu usu&aacute;rio n&atilde;o possui permiss&atilde;o de exclus&atilde;o.'        ,'Alerta - Aimaro','bloqueiaFundo(divRotina)'); return false; }
	if ( (operacao == 'TI') && (flgIncluir   != '1') ) { showError('error','Seu usu&aacute;rio n&atilde;o possui permiss&atilde;o de incluis&atilde;o.'       ,'Alerta - Aimaro','bloqueiaFundo(divRotina)'); return false; }
	
	// Se a operação necessita filtrar somente um registro, então filtro abaixo
	// Para isso verifico a linha que está selecionado e pego o valor do INPUT HIDDEN desta linha	
	if ( in_array(operacao,['TA','TX','CF']) ) {
		nrdrowid = '';
		$('table > tbody > tr', 'div.divRegistros').each( function() {
			if ( $(this).hasClass('corSelecao') ) {
				nrdrowid = $('input', $(this) ).val();
			}
		});
		if ( nrdrowid == '' ) { return false; }			
	}
		
	var mensagem = '';
	
	switch (operacao) {		
		case 'CF' :	
			mensagem = 'abrindo consultando...';
			cddopcao = 'C';
			break;
		case 'TA' :	
			mensagem = 'abrindo altera&ccedil;&atilde;o...';
			cddopcao = 'A';
			break;
		case 'AT' : 
			showConfirmacao('Deseja cancelar altera&ccedil;&atilde;o?','Confirma&ccedil;&atilde;o - Aimaro','controlaOperacao(\'\')','bloqueiaFundo(divRotina)','sim.gif','nao.gif');
			return false;
			break;
		case 'TI' : 
			mensagem = 'abrindo inclus&atilde;o ...';
			nrdrowid = '';
			cddopcao = 'I';
			break;
		case 'IT' : 
			showConfirmacao('Deseja cancelar inclus&atilde;o?'        ,'Confirma&ccedil;&atilde;o - Aimaro','controlaOperacao(\'\')','bloqueiaFundo(divRotina)','sim.gif','nao.gif');
			return false;
			break;			
		case 'TX' : 
			mensagem = 'processando exclus&atilde;o ...';
			cddopcao = 'E';
			break;
		case 'TE' : 
			showConfirmacao('Deseja confirmar exclus&atilde;o?'        ,'Confirma&ccedil;&atilde;o - Aimaro','manterRotina(\'E\')','controlaOperacao(\'\')','sim.gif','nao.gif');
			return false;
			break;					
		case 'AT' : 
			showConfirmacao('Deseja cancelar altera&ccedil;&atilde;o?','Confirma&ccedil;&atilde;o - Aimaro','controlaOperacao(\'\')','bloqueiaFundo(divRotina)','sim.gif','nao.gif');
			return false;
			break;
		case 'AV' : manterRotina(operacao);return false;break;	
		case 'VA' : manterRotina(operacao);return false;break;
		case 'IV' : manterRotina(operacao);return false;break;
		case 'VI' : manterRotina(operacao);return false;break;
		case 'EV' : manterRotina(operacao);return false;break;
		case 'VE' : manterRotina(operacao);return false;break;
		default   : 
			operacao = '';
			nrdrowid = '';
			cddopcao = 'C';
			mensagem = 'carregando...';
			break;
	}
	showMsgAguardo('Aguarde, ' + mensagem);	
		
	// Executa script de através de ajax
	$.ajax({		
		type: 'POST',
		dataType: 'html',
		url: UrlSite + 'telas/contas/telefones/principal.php', 
		data: {
			nrdconta: nrdconta,	
			idseqttl: idseqttl,
			inpessoa: inpessoa,
			operacao: operacao,	
			nrdrowid: nrdrowid,
			cddopcao: cddopcao,	
			flgcadas: flgcadas,
			redirect: 'script_ajax'
		}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError('error','N&atilde;o foi possível concluir a requisi&ccedil;&atilde;o.','Alerta - Aimaro','bloqueiaFundo(divRotina)');
		},
		success: function(response) {
			if ( response.indexOf('showError("error"') == -1 ) {
				$('#divConteudoOpcao').html(response);
			} else {
				eval( response );
				controlaFoco( operacao );
			}
			return false;
		}
	});
}

function manterRotina( operacao ) {
	hideMsgAguardo();	
	var mensagem = '';
	switch (operacao) {	
		case 'VA': mensagem = 'salvando altera&ccedil;&atilde;o';break;
		case 'AV': mensagem = 'validando altera&ccedil;&atilde;o';break;						
		case 'VI': mensagem = 'salvando inclus&atilde;o';break;
		case 'IV': mensagem = 'validando inclus&atilde;o';break;						
		case 'EV' : mensagem = 'validando exclus&atilde;o';break;
		case 'VE' : mensagem = 'excluindo';break;
		default: controlaOperacao(''); return false; break;
	}
	showMsgAguardo('Aguarde, ' + mensagem + ' ...');
	
	tptelefo = $('#tptelefo','#'+nomeForm).val();	
	nrdddtfc = $('#nrdddtfc','#'+nomeForm).val();
	nrtelefo = $('#nrtelefo','#'+nomeForm).val();
	nrdramal = $('#nrdramal','#'+nomeForm).val();
	secpscto = $('#secpscto','#'+nomeForm).val();
	nmpescto = $('#nmpescto','#'+nomeForm).val();
	cdopetfn = $('#cdopetfn','#'+nomeForm).val();
	nrdrowid = $('#nrdrowid','#'+nomeForm).val();
	idsittfc = $('#idsittfc','#'+nomeForm).val();
	idorigem = $('#idorigem','#'+nomeForm).val();
	
    //remove os caracteres que geram erro no XML
	nmpescto = removeCaracteresInvalidos(nmpescto);

	// Executa script de confirmação através de ajax
	$.ajax({		
		type: 'POST',
		url: UrlSite + 'telas/contas/telefones/manter_rotina.php', 		
		data: {
			nrdconta: nrdconta, idseqttl: idseqttl, tptelefo: tptelefo, 
			nrdddtfc: nrdddtfc, nrtelefo: nrtelefo,	nrdramal: nrdramal, 
			secpscto: secpscto, nmpescto: nmpescto,	cdopetfn: cdopetfn, 
			nrdrowid: nrdrowid, operacao: operacao, flgcadas: flgcadas,
			idsittfc: idsittfc, idorigem: idorigem,
			redirect: 'script_ajax'
		}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Aimaro','bloqueiaFundo(divRotina)');
		},
		success: function(response) {
			try {
				eval(response);
				return false;
			} catch(error) {
				hideMsgAguardo();
				showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Aimaro','bloqueiaFundo(divRotina)');
			}
		}				
	});
}

function controlaLayout(operacao) {		
	
	altura  = ( in_array(operacao,['AT','IT','FI','FA','FE','SC','']) ) ? '205px' : '196px';
	altura = ( operacao == 'TI') ? '220px': altura ;
	largura = ( in_array(operacao,['AT','IT','FI','FA','FE','SC','']) ) ? '580px' : '368px';
	divRotina.css('width',largura);	
	$('#divConteudoOpcao').css('height',altura);
	
	
	// Operação consultando
	if ( in_array(operacao,['CT','AT','IT','FI','FA','FE','SC','']) ) {	

		var divRegistro = $('div.divRegistros');		
		var tabela      = $('table', divRegistro );
		var linha       = $('table > tbody > tr', divRegistro );
		
		divRegistro.css('height','150px');
		
		var ordemInicial = new Array();
		ordemInicial = [[1,0]];
		
		var arrayLargura = new Array();
		arrayLargura[0] = '65px';
		arrayLargura[1] = '32px';
		arrayLargura[2] = '58px';
		arrayLargura[3] = '41px';
		arrayLargura[4] = '81px';
		arrayLargura[5] = '53px';
		arrayLargura[6] = '60px';

		var arrayAlinha = new Array();
		arrayAlinha[0] = 'center';
		arrayAlinha[1] = 'center';
		arrayAlinha[2] = 'center';
		arrayAlinha[3] = 'center';
		arrayAlinha[4] = 'left';
		arrayAlinha[5] = 'center';
		arrayAlinha[6] = 'center';
		arrayAlinha[7] = 'left';

		var metodoTabela = ( operacao != 'SC' ) ? 'controlaOperacao(\'TA\')' : 'controlaOperacao(\'CF\')' ;
		tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha, metodoTabela );

	// Operação Alterando/Incluindo
	} else {	

		var sugest 		= $('#sugestao');
		var formulario  = $('#'+nomeForm);
		var cTodos     	= $('input,select','#'+nomeForm);		
		var rRotulos   	= $('label[for="tptelefo"],label[for="nrdddtfc"],label[for="cdopetfn"],label[for="nrdramal"],label[for="nmpescto"],label[for="idsittfc"]','#'+nomeForm);
		var rLinha      = $('label[for="nrtelefo"],label[for="secpscto"],label[for="idorigem"]','#'+nomeForm);

		var cGrupo_1    = $('#tptelefo,#nrdddtfc,#nrtelefo,#idsittfc,#idorigem','#'+nomeForm);
		var cIdentif   	= $('#tptelefo','#'+nomeForm);
		var cDDD       	= $('#nrdddtfc','#'+nomeForm);
		var cTelefone  	= $('#nrtelefo','#'+nomeForm);
		var cOperadora 	= $('#cdopetfn','#'+nomeForm);
		var cNrRamal	= $('#nrdramal','#'+nomeForm);
		var cSetor		= $('#secpscto','#'+nomeForm);
		var cIdSituacao	= $('#idsittfc','#'+nomeForm);
		var cIdOrigem	= $('#idorigem','#'+nomeForm);
		var cContato	= $('#nmpescto','#'+nomeForm);	

		sugest.css({'display':'none'});
		formulario.css('padding-top','5px');
		rRotulos.addClass('rotulo').css('width','100px');
		rLinha.css('width','80px');
		cTodos.desabilitaCampo();
		cIdentif.css('width','230px');
		cDDD.addClass('inteiro').attr('maxlength','3').css('width','60px');
		cTelefone.addClass('inteiro').attr('maxlength','10').css('width','87px');
		cOperadora.css('width','230px');			
		cNrRamal.addClass('inteiro').attr('maxlength','4').css('width','60px');
		cSetor.addClass('alphanum').attr('maxlength','7').css('width','87px');
		cIdSituacao.css('width','60px');
		cIdOrigem.css('width','87px');
		cContato.addClass('alphanum').attr('maxlength','30').css('width','230px');
		

		if ( operacao == 'CF' ){
			cTodos.desabilitaCampo();
		// Se a operação for diferente de exclusão
		} else if ( operacao != 'TX' ) {		
			
			cGrupo_1.habilitaCampo();
			if (inpessoa==2) { cSetor.addClass('campo').habilitaCampo(); }

			// Dependendo do tipo de telefone, habilito ou desabilito campos
			if ( cIdentif.val() == '2' ) { // Tipo Celular
				cOperadora.habilitaCampo();
			
			} else if ( cIdentif.val() == '3' ) { // Tipo Comercial
				cNrRamal.habilitaCampo();
				cSetor.habilitaCampo();
				cContato.habilitaCampo();
				
			} else if ( cIdentif.val() == '4' ) { // Tipo Contato
				cContato.habilitaCampo();
				cSetor.habilitaCampo();
			}	
			
			// Caso mudar o tipo de telefone, habilito ou desabilito campos
			cIdentif.change( function() {
				
				// Tipo Nenhum
				if ( $(this).val() == '' ) { 
					cTodos.desabilitaCampo();
					cIdentif.habilitaCampo();
					
				// Tipo Diferente de Nenhum Residencial
				} else {
					cTodos.habilitaCampo();
					
					// Tipo Residendial
					if ( $(this).val() == '1' ) { 
						cOperadora.val('').desabilitaCampo();
						cNrRamal.val('').desabilitaCampo();
						cSetor.val('').desabilitaCampo();
						cContato.val('').desabilitaCampo();
						
					// Tipo Celular
					} else if ( $(this).val() == '2' ) { 
						cOperadora.habilitaCampo();
						cNrRamal.val('').desabilitaCampo();
						cSetor.val('').desabilitaCampo();
						cContato.val('').desabilitaCampo();
						
					// Tipo Comercial
					} else if ( $(this).val() == '3' ) {
						cOperadora.val('').desabilitaCampo();
						cNrRamal.addClass('campo').habilitaCampo();
						cContato.addClass('campo').habilitaCampo();
						cSetor.addClass('campo').habilitaCampo();
						
					// Tipo Contato
					} else if ( $(this).val() == '4' ) {	
						cOperadora.val('').desabilitaCampo();
						cNrRamal.val('').desabilitaCampo();
						cSetor.val('').desabilitaCampo();
						cContato.habilitaCampo();
					}
					
					if (inpessoa==2) { cSetor.addClass('campo').habilitaCampo(); }
					
					cDDD.focus();
				}

			});
			
			cSetor.unbind("keydown").bind("keydown",function(e) {
				if (e.keyCode == 13 && isHabilitado(cContato) == false) {
					$("#btSalvar","#divBotoes").trigger("click");
					return false;
				}	
			});	
			
			cContato.unbind("keydown").bind("keydown",function(e) {
				if (e.keyCode == 13) {
					$("#btSalvar","#divBotoes").trigger("click");
					return false;
				}	
			});	
				
		} 
		
		if ( operacao == 'TI' ) {
			sugest.css({'display':'block','clear':'both','margin':'7px -2px 0px -2px','padding':'3px 0px','background-color':'#EFEFEF','color':'#555','border-top':'1px solid #DEDFDE'});
			sugest.html(sugestao);
			$('#'+nomeForm).limpaFormulario();
		}	
		
		montaSelect('b1wgen0059.p','busca_operadoras','cdopetfn','cdopetfn','cdopetfn;nmopetfn',cdopetfn,'','');		
	}
	
	layoutPadrao();
	hideMsgAguardo();
	bloqueiaFundo(divRotina);
	removeOpacidade('divConteudoOpcao');
	highlightObjFocus($('#frmTelefones'));
	controlaFocoEnter("frmTelefones");
	controlaFoco(operacao);
	divRotina.centralizaRotinaH();
	return false;	
}

function controlaFoco(operacao) {
	if (in_array(operacao,['AT','IT','FA','FI','FE',''])) {
		$('#btIncluir','#divBotoes').focus();
	} else {
		$('#tptelefo','#'+nomeForm).focus();
	}
	return false;
}

function voltarRotina() {
	if (inpessoa == 1) {
		acessaOpcaoAbaDados(3,0,'@');
	} else {
		fechaRotina(divRotina);
		acessaRotina('BENS','Bens','bens');
	}
	
}

function proximaRotina () {
		
	hideMsgAguardo();
	
	if (inpessoa == 1) {
		acessaOpcaoAbaDados(3,2,'@');
	} else {
		encerraRotina(false);
		acessaRotina('E_MAILS','E-Mails','emails');	
	}	
}