/*!
 * FONTE        : endereco.js
 * CRIAÇÃO      : Gabriel Capoia (DB1)
 * DATA CRIAÇÃO : Maio/2010 
 * OBJETIVO     : Biblioteca de funções da rotina Endereco da tela de CONTAS
 * --------------
 * ALTERAÇÕES   : 
 * --------------
 * 000: [11/02/2011] Rodolpho/Rogérius. (DB1) Adicionado pesquisa CEP.
 * 001: [03/05/2011] Rogérius Militao   (DB1) Adicionado o campo "dtinires" (inicio de residencia) com o tratamento
 * 002: [05/07/2011] Henrique Pettenuci       Adicionado os campos nrdoapto e cddbloco.
 * 003: [22/07/2015] Gabriel 		   (RKAM) Reformulacao cadastral.
 * 004: [20/04/2016] Heitor            (RKAM) Limitado o campo NRENDERE em 5 posicoes, chamado 435477 
 * 005: [15/09/2017] Kelvin			   (CECRED) Alterações referente a melhoria 339.
 * 006: [27/09/2017] Kelvin 		   (CECRED) Removido campos nrdoapto, cddbloco e nrcxapst (PRJ339).
 * 007: [06/07/2018] André Bohn		   (MoutS) Ajustado para remover os caracteres especiais no campo de complemento (PRB0040114).
 * 007:	[19/03/2019] Vitor S. Assanuma (GFT) Inserção dos campos de Canal e Data de revisão.
 */

var nomeForm = 'frmEndereco'; // Nome do Formulário 
var flgContinuar = false;     // Controle botao Continuar

 
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
		url: UrlSite + "telas/contas/endereco/principal.php",
		data: {
			nrdconta: nrdconta,
			idseqttl: idseqttl,
			flgcadas: flgcadas,
			redirect: "html_ajax"
		},
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError('error','N&atilde;o foi possível concluir a requisi&ccedil;&atilde;o.','Alerta - Aimaro',bloqueiaFundo(divRotina));
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

function controlaOperacao(operacao, msgRetorno) {
	
	if ( !verificaContadorSelect() && operacao != 'CA') return false;
	
	// Verifica permissões de acesso
	if ( (operacao == 'EA') && (flgAlterar != '1') ) { 
		showError('error','Seu usu&aacute;rio n&atilde;o possui permiss&atilde;o de altera&ccedil;&atilde;o.','Alerta - Aimaro','bloqueiaFundo(divRotina)');
		return false;
	} 
		
	// Mostra mensagem de aguardo
	var msgOperacao = '';
	switch (operacao) {					
		case 'CA': // Consulta para Alteração
			msgOperacao = 'abrindo formulário';
			break;
		case 'EA': 
			msgOperacao = 'abrindo formulário';
			break;
		// Alteração para Consulta
		case 'AE': 
			showConfirmacao('Deseja substituir ENDERECO ATUAL pelo ENDERECO da INTERNET ?','Confirma&ccedil;&atilde;o - Aimaro','manterRotina(\'AE\')','controlaOperacao(\'EI\')','sim.gif','nao.gif');
			return false;
			break;
		case 'EI': 
			showConfirmacao('Deseja EXCLUIR endereco cadastrado na INTERNET ?','Confirma&ccedil;&atilde;o - Aimaro','manterRotina(\'EI\')','controlaOperacao(\'CA\')','sim.gif','nao.gif');
			return false;
			break;
		case 'AC': 
			showConfirmacao('Deseja cancelar opera&ccedil;&atilde;o?','Confirma&ccedil;&atilde;o - Aimaro','controlaOperacao()','bloqueiaFundo(divRotina)','sim.gif','nao.gif');
			return false;
			break;	
		// Alteração para Validação - Validando Alteração
		case 'AV': 
			manterRotina(operacao,'fieldResidencial');
			return false;
			break;	
		// Validação para Alteração - Salvando Alteração
		case 'VA': 
			manterRotina(operacao,'fieldResidencial');
			return false;
			break;
		case 'FA':
			msgOperacao = 'finalizando altera&ccedil;&atilde;o';
			break;
		case 'FAE':
			msgOperacao = 'finalizando altera&ccedil;&atilde;o';
			break;
		case 'FEI':
			msgOperacao = 'finalizando exclus&atilde;o';
			break;		
		// Qualquer outro valor: Cancelando Operação
		default: 
			msgOperacao = 'abrindo formul&aacute;rio';
			break;			
	}	
	showMsgAguardo('Aguarde, ' + msgOperacao + '...');
	
	idseqttl = $('#idseqttl option:selected','#frmCabContas').val();		
	
	// Executa script de através de ajax
	$.ajax({		
		type: 'POST',
		dataType: 'html',
		url: UrlSite + 'telas/contas/endereco/principal.php', 
		data: {
			nrdconta: nrdconta,
			idseqttl: idseqttl,
			flgcadas: flgcadas,
			operacao: operacao,
			redirect: "html_ajax"
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
			}
			controlaFoco( operacao );
			return false;	
		}				
	});			
}


// 001: adicionao campo "dtinires"
function manterRotina(operacao , nomeField) {
	
	hideMsgAguardo();		
	var msgOperacao = '';
	switch (operacao) {	
		case 'VA': msgOperacao = 'Aguarde, alterando ...'; break;
		case 'AV': msgOperacao = 'Aguarde, validando alteração ...'; break;										
		case 'AE': msgOperacao = 'Aguarde, alterando para dados da internet ...'; break;										
		case 'EI': msgOperacao = 'Aguarde, excluindo dados da internet ...'; break;	
		case 'CC': msgOperacao = 'Aguarde, verificando cidade ...'; break;
 		default: return false; break;
	}
	showMsgAguardo( msgOperacao );
	
	if ( operacao == 'AE' || operacao == 'EI' ) {
		var incasprp = '';
		var vlalugue = '';	
		var dsendere = '';
		var nrendere = '';
		var complend = '';
		var nmbairro = '';
		var nrcepend = '';
		var nmcidade = '';
		var cdufende = '';
		var dtinires = '';	
		var nranores = '';	
		var qtprebem = 0;
		var vlprebem = 0;
		var idorigem = 0;

	} else {
				
		var incasprp = $('#incasprp','#fieldResidencial').val();
		var vlalugue = number_format(parseFloat($('#vlalugue','#fieldResidencial').val().replace(/[.]*/g,'').replace(',','.')),2,',','');	
		var dtinires = $('#dtinires','#fieldResidencial').val();
		var nranores = $('#nranores','#fieldResidencial').val();
		var qtprebem = $('#qtprebem','#fieldResidencial').val();
		var vlprebem = $('#vlprebem','#fieldResidencial').val();
		
		var dsendere = $('#dsendere','#'+nomeField).val();
		var nrendere = $('#nrendere','#'+nomeField).val();
		var complend = $('#complend','#'+nomeField).val();
		var nmbairro = $('#nmbairro','#'+nomeField).val();
		var nrcepend = $('#nrcepend','#'+nomeField).val();
		var nmcidade = $('#nmcidade','#'+nomeField).val();
		var cdufende = $('#cdufende','#'+nomeField).val();
		var idorigem = $('#idorigem','#'+nomeField).val();
		
	}
	
	nrendere = normalizaNumero( nrendere );
	nrcepend = normalizaNumero( nrcepend );
	
	dsendere = trim( dsendere );
	complend = trim( complend );
	nmbairro = trim( nmbairro );
	nmcidade = trim( nmcidade );
	
	if (nomeField == 'fieldResidencial') {
		var tpendass = (inpessoa == 1) ? 10 : 9;
	}
	else if (nomeField == 'fieldCorrespondencia') {
		var tpendass = 13;
	}
	else {
		var tpendass = 14;
	}
			
	$.ajax({		
		type: 'POST',
		url: UrlSite + 'telas/contas/endereco/manter_rotina.php', 		
		data: {
			nrdconta: nrdconta, idseqttl: idseqttl,
			incasprp: incasprp, vlalugue: vlalugue,
			dsendere: dsendere, nrendere: nrendere,
			nmbairro: nmbairro, nrcepend: nrcepend,
			nmcidade: nmcidade, cdufende: cdufende,
			complend: complend, operacao: operacao, 
			dtinires: dtinires, nranores: nranores, 
			qtprebem: qtprebem, vlprebem: vlprebem, 
			tpendass: tpendass, flgcadas: flgcadas, 
			idorigem: idorigem,
			redirect: 'script_ajax'
		},                                                          
		error: function(objAjax,responseError,objExcept) {          
			hideMsgAguardo();                                       
			showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Aimaro','bloqueiaFundo(divRotina)');
		},
		success: function(response) {
			try {
				eval(response);
				
				if (operacao == 'VA' && (flgcadas == 'M' || flgContinuar ) && tpendass == 14) {
					flgContinuar = false;
					proximaRotina();	
				}
				
			} catch(error) {
				hideMsgAguardo();
				showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Aimaro','bloqueiaFundo(divRotina)');
			}
		}				
	});
}

function controlaLayout(operacao) {

	// CONTROLA A ALTURA DA TELA  
	largura = ( in_array(operacao,['EA']) ) ? '550px' : '530px';
	divRotina.css('height','160px');
	divRotina.css('width',largura);

	// SELETORES GENÉRICOS
	var cTodos	= $('input, select','#'+nomeForm);
	var cSelect	= $('select','#'+nomeForm);
	
	// RÓTULOS - IMÓVEL	
	var rImovel = $('label[for="incasprp"],label[for="ib_incasprp"]','#'+nomeForm);
	var rValor  = $('label[for="vlalugue"],label[for="ib_vlalugue"]','#'+nomeForm);	
	var rInicio = $('label[for="dtinires"],label[for="ib_dtinires"]','#'+nomeForm);
	var rTemp   = $('label[for="nranores"],label[for="ib_nranores"]','#'+nomeForm);
	var rVlParc = $('label[for="vlprebem"]','#'+nomeForm);
	var rQtParc = $('label[for="qtprebem"]','#'+nomeForm);
	
	rImovel.addClass('rotulo').css('width','90px');
	rValor.addClass('rotulo-linha').css('width','128px');	
	rInicio.addClass('rotulo').css('width','120px');
	rTemp.addClass('rotulo-linha').css('width','165px');	
	rVlParc.addClass('rotulo-linha').css('width','55px');
	rQtParc.addClass('rotulo-linha').css('width','205px');

	if ( $.browser.msie ) { 
		rQtParc.addClass('rotulo-linha').css('width','208px');
	} else {
		rQtParc.addClass('rotulo-linha').css('width','205px');
	}
	
	// RÓTULOS - ENDEREÇO 
	var rCep	= $('label[for="nrcepend"],label[for="ib_nrcepend"]','#'+nomeForm);
	var rEnd	= $('label[for="dsendere"],label[for="ib_dsendere"]','#'+nomeForm);
	var rNum	= $('label[for="nrendere"],label[for="ib_nrendere"]','#'+nomeForm);
	var rCom	= $('label[for="complend"],label[for="ib_complend"]','#'+nomeForm);
	var rBai	= $('label[for="nmbairro"],label[for="ib_nmbairro"]','#'+nomeForm);
	var rEst	= $('label[for="cdufende"],label[for="ib_cdufende"]','#'+nomeForm);	
	var rCid	= $('label[for="nmcidade"],label[for="ib_nmcidade"]','#'+nomeForm);
	var rOri	= $('label[for="idorigem"],label[for="ib_idorigem"]','#'+nomeForm);
	var rCan	= $('label[for="idcanal"], label[for="ib_idcanal"]', '#'+nomeForm);
	var rRev	= $('label[for="dtrevisa"],label[for="ib_dtrevisa"]','#'+nomeForm);
	var rSta	= $('label[for="dsstatus"],label[for="ib_dsstatus"]','#'+nomeForm);
	
	rCep.addClass('rotulo').css('width','55px');
	rEnd.addClass('rotulo-linha').css('width','25px');
	rNum.addClass('rotulo-linha').css('width','15px');
	rCom.addClass('rotulo').css('width','55px');
	rBai.addClass('rotulo').css('width','55px');
	rCid.addClass('rotulo').css('width','55px');
	rEst.addClass('rotulo-linha').css('width','52px');
	rOri.addClass('rotulo').css('width','55px');
	rCan.addClass('rotulo-linha').css('width','40px');
	rRev.addClass('rotulo-linha').css('width','94px');
	rSta.addClass('rotulo-linha').css('width','40px');
	
	// CAMPOS - IMÓVEL
	var cImovel	= $('#incasprp,#ib_incasprp','#'+nomeForm);
	var cValor  = $('#vlalugue,#ib_vlalugue','#'+nomeForm);	
	var cVlParc = $('#vlprebem','#'+nomeForm);
	var cQtParc = $('#qtprebem','#'+nomeForm);
	var cInicio = $('#dtinires,#ib_dtinires','#'+nomeForm);
	var cTemp   = $('#nranores,#ib_nranores','#'+nomeForm);
	
	cImovel.css('width','150px');
	cValor.addClass('moeda').css('width','104px');	
	cVlParc.addClass('moeda').css('width','104px');
	cQtParc.addClass('inteiro').css('width','104px');
	cInicio.addClass('dataMesAno').css('width','60px').attr('maxlength','7');
	cTemp.addClass('alphanum').css('width','124px').attr('maxlength','3');
	
	// CAMPOS - ENDEREÇO
	var cCep	= $('#nrcepend,#ib_nrcepend','#'+nomeForm);
	var cEnd	= $('#dsendere,#ib_dsendere','#'+nomeForm);
	var cNum	= $('#nrendere,#ib_nrendere','#'+nomeForm);
	var cCom	= $('#complend,#ib_complend','#'+nomeForm);
	var cBai	= $('#nmbairro,#ib_nmbairro','#'+nomeForm);
	var cEst	= $('#cdufende,#ib_cdufende','#'+nomeForm);	
	var cCid	= $('#nmcidade,#ib_nmcidade','#'+nomeForm);
	var cOri	= $('#idorigem,#ib_idorigem','#'+nomeForm);
	var cCan	= $('#idcanal, #ib_idcanal', '#'+nomeForm);
	var cRev	= $('#dtrevisa,#ib_dtrevisa','#'+nomeForm);
	var cSta	= $('#dsstatus,#ib_dsstatus','#'+nomeForm);


	cCep.addClass('cep pesquisa').css('width','65px').attr('maxlength','9');
	cEnd.addClass('alphanum').css('width','240px').attr('maxlength','40');
	cCom.addClass('alphanum').css('width','274px').attr('maxlength','40');	
	cBai.addClass('alphanum').css('width','300px').attr('maxlength','40');	
	cEst.css('width','62px');
	cCid.addClass('alphanum').css('width','300px').attr('maxlength','25');
	cOri.css('width','87px');
	cCan.css('width','87px');
	cRev.css('width','100px');
	cSta.css('width','87px');
	
	// Para evitar a digitação de caracteres especiais que ocasiona erro na recuperação através de XML
    cCom.bind("keyup", function () {
	    this.value = removeAcentos(removeCaracteresInvalidos(this.value));
    });
	// Bloqueia a digitação de caracteres com a tecla Alt + ..
    cCom.bind("keydown", function (e) {
	   if (e.altKey) { return false; }
    });

	if ( $.browser.msie ) {
		cNum.addClass('numerocasa').css('width','44px').attr('maxlength','6');

	} else {
		cNum.addClass('numerocasa').css('width','47px').attr('maxlength','6');
	}
	
	switch(operacao) {	
		case 'CA': // Consulta Alteração
			cTodos.habilitaCampo();
			$('#dsendere,#cdufende,#nmbairro,#nmcidade,#nranores,#idcanal,#dtrevisa','#'+nomeForm).desabilitaCampo();
			montaSelect('b1wgen0059.p','busca_tpimovel','incasprp','incasprp','dscasprp',incasprp);
			layoutPadrao();
			break;
		case 'EA': 
			cTodos.desabilitaCampo();
			break;			
		default:					
			montaSelect('b1wgen0059.p','busca_tpimovel','incasprp','incasprp','dscasprp',incasprp);
			layoutPadrao();	
			cTodos.desabilitaCampo();
			
			break;
	}
	
	cCep.trigger('blur');
	cNum.trigger('blur');
   
	hideMsgAguardo();
	bloqueiaFundo(divRotina);
	removeOpacidade('divConteudoOpcao');
	highlightObjFocus($('#frmEndereco'));
	controlaFocoEnter("frmEndereco");	
	controlaPesquisas();
	divRotina.centralizaRotinaH();	
	controlaFoco(operacao);

	return false;	
}	

function controlaPesquisas() {		
	
	// Atribui a classe lupa para os links e desabilita todos
	$('a','#'+nomeForm).addClass('lupa').css('cursor','auto');	

	// a variavel camposOrigem deve ser composta:
	// 1) os cincos primeiros campos são os retornados para o formulario de origem
	// 2) o sexto campo é o campo q será focado após o retorno ao formulario de origem, que
	// pelo requisito na maioria dos casos será o NUMERO do endereço	
	var camposOrigem = 'nrcepend;dsendere;nrendere;complend;nrcxapst;nmbairro;cdufende;nmcidade';	
	var camposCor = 'nrcepend;dsendere;nrendere;complend;nrcxapst;nmbairro;cdufende;nmcidade;idorigem';	
	
	/*-------------------------------------*/
	/*       CONTROLE DAS PESQUISAS        */
	/*-------------------------------------*/
	
	// Percorrendo todos os links
	$('a','#'+nomeForm).each( function() {
		if ( !$(this).prev().hasClass('campoTelaSemBorda') ) { $(this).css('cursor','pointer'); }
	});

	// Tipo de imovel
	$('#incasprp','#'+nomeForm).unbind('change').bind('change',function() {

		if (isHabilitado($(this)) == false) {
			return false;
		}	
	
		if ($(this).val() != 2) { // Nao Financiado
			$('#vlprebem','#'+nomeForm).val("0,00").desabilitaCampo();
			$('#qtprebem','#'+nomeForm).val("0").desabilitaCampo();
		} else {
			$('#vlprebem','#'+nomeForm).habilitaCampo();
			$('#qtprebem','#'+nomeForm).habilitaCampo();
		}
		
		if ($(this).val() == 3) { // Alugado 		
			$("#valor","#"+nomeForm).html("Aluguel:");			
		} else {
			$("#valor","#"+nomeForm).html("Valor:");
		}
		
		if ($(this).val() == 4 || $(this).val() == 5) { // Cedido / Familiar
			$("#vlalugue","#"+nomeForm).val("0,00").desabilitaCampo();
		} else {
			$("#vlalugue","#"+nomeForm).habilitaCampo();
		}
		
		
		
	});
	
	$('input','#'+nomeForm).unbind('focus').bind('focus',function() {	
		$('#incasprp','#'+nomeForm).trigger('change');
	});
	
	/*-------------------------------------*/
	/*   CONTROLE DAS BUSCA DESCRIÇÕES     */
	/*-------------------------------------*/

	// CEP RESIDENCIAL
	$('#nrcepend','#fieldResidencial').buscaCEP('fieldResidencial', camposOrigem, divRotina);
	
	// Validar que o CEP do cooperado seja numa cidade de atuacao da cooperativa. Somente alerta, nao trava
	$('#nrcepend','#fieldResidencial').unbind('blur').bind('blur',function() {
			
		if (isHabilitado($(this)) == false || $(this).val() == "0" || $(this).val() == "" || $('#divAguardo').css('display') == 'block' ) {
			return false;
		}	
						
		manterRotina('CC','fieldResidencial');
			
		return false;
		
	});
	
	// CEP DE CORRESPONDENCIA
	$('#nrcepend','#fieldCorrespondencia').buscaCEP('fieldCorrespondencia', camposOrigem, divRotina);
	
	// CEP COMPLEMENTAR
	$('#nrcepend','#fieldComplementar').buscaCEP('fieldComplementar', camposOrigem, divRotina);
	
	// 001: adicionado o evento no campo "dtinires"
	$('#dtinires','#'+nomeForm).unbind('blur').bind('blur', function() {
		if ($(this).val() != '') { 
			trataInicioResid($(this).val());
		} else {
			$('#nranores','#'+nomeForm).val('');
		}
		return false;
	});	
	
}

function controlaFoco(operacao) {
		
	if (in_array(operacao,['AC',''])) {
		$('#btAlterar','#divBotoes').focus();
	} else {
		$('#vlalugue','#'+nomeForm).focus();
	}
	return false;
}

// 001: faz a validação do valor digitado.
function trataInicioResid (dtinires) {

	hideMsgAguardo();		
	showMsgAguardo( "Aguarde, tratando início de residencia..." );

	$.ajax({		
	type: 'POST',
	url: UrlSite + 'telas/contas/endereco/tratar_inicio_res.php', 		
	data: {
		dtinires: dtinires, 			
		redirect: 'script_ajax'                                 
	},                                                          
	error: function(objAjax,responseError,objExcept) {          
		hideMsgAguardo();                                       
		showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Aimaro','bloqueiaFundo(divRotina)');
	},
	success: function(response) {
		try {
			eval(response);
		} catch(error) {
			hideMsgAguardo();
			showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Aimaro','bloqueiaFundo(divRotina)');
		}
	}				
	});
	
	return false;
}

function controlaContinuar () {
	
	flgContinuar = true;
	
	if ($("#btAlterar","#divBotoes").length > 0) {
		proximaRotina();
	} else {
		controlaOperacao('AV');
	}
}

function voltarRotina() {
	
	fechaRotina(divRotina);
	
	if (inpessoa == 1) {
		acessaRotina('DADOS PESSOAIS','Dados Pessoais','dados_pessoais');
	} else {
		acessaRotina('REGISTRO','Registro','registro');
	}
	
}

function proximaRotina() {
	
	hideMsgAguardo();
	
	if (inpessoa == 1) {	
		acessaOpcaoAbaDados(3,1,'@');	
	} else {
		encerraRotina(false);
		acessaRotina('PARTICIPACAO','Participação Empresas','participacao');
	}
	
}