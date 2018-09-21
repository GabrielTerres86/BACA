/*!
 * FONTE        : referencias.js
 * CRIAÇÃO      : Rodolpho Telmo (DB1)
 * DATA CRIAÇÃO : 23/04/2010 
 * OBJETIVO     : Biblioteca de funções na rotina REFERÊNCIAS da tela de CONTAS
 * ALTERAÇÃO    : Adicionado pesquisa CEP. ( Rodolpho/Rogérius. (DB1) ).
 *                06/02/2012 - Ajuste para não chamar 2 vezes a função mostraPesquisa (Tiago). 
 *                05/08/2015 - Reformulacao cadastral (Gabriel-RKAM).
 */

var nrdrowid  = ''; 
var nrdctato  = '';
var operacao  = '';
var nomeForm  = 'frmReferencias';
 
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
		url: UrlSite + 'telas/contas/referencias/principal.php',
		data: {
			operacao: operacao,
			nrdconta: nrdconta,
			flgcadas: flgcadas,
			idseqttl: idseqttl,
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

	if ( (operacao == 'CA') && (flgAlterar   != '1') ) { showError('error','Seu usu&aacute;rio n&atilde;o possui permiss&atilde;o de altera&ccedil;&atilde;o.','Alerta - Aimaro','bloqueiaFundo(divRotina)'); return false; }
	if ( (operacao == 'CC') && (flgConsultar != '1') ) { showError('error','Seu usu&aacute;rio n&atilde;o possui permiss&atilde;o de consulta.'               ,'Alerta - Aimaro','bloqueiaFundo(divRotina)'); return false; }
	if ( (operacao == 'TE') && (flgExcluir   != '1') ) { showError('error','Seu usu&aacute;rio n&atilde;o possui permiss&atilde;o de exclus&atilde;o.'        ,'Alerta - Aimaro','bloqueiaFundo(divRotina)'); return false; }
	if ( (operacao == 'CI') && (flgIncluir   != '1') ) { showError('error','Seu usu&aacute;rio n&atilde;o possui permiss&atilde;o de incluis&atilde;o.'       ,'Alerta - Aimaro','bloqueiaFundo(divRotina)'); return false; }
	
	if ( in_array(operacao,['CA','TE','CC']) ) {
		nrdrowid = '';
		$('table > tbody > tr', 'div.divRegistros').each( function() {
			if ( $(this).hasClass('corSelecao') ) {
				nrdrowid = $('input', $(this) ).val();
			}
		});
		if ( nrdrowid == '' ) { return false; }	
	}
	
	var msgOperacao = '';
	switch (operacao) {			
		case 'CA' : msgOperacao = 'abrindo altera&ccedil;&atilde;o...';break;
		case 'CI' : msgOperacao = 'abrindo inclus&atilde;o...';break;
		case 'CC' : msgOperacao = 'abrindo consulta...';break;
		case 'CB' : msgOperacao = 'buscando dados...';break;
		case 'TE' : msgOperacao = 'processando exlus&atilde;o...';break;
		case 'CE' : showConfirmacao('Deseja confirmar exlus&atilde;o?'        ,'Confirma&ccedil;&atilde;o - Aimaro','manterRotina(\''+operacao+'\')','controlaOperacao()','sim.gif','nao.gif');return false;break;					
		case 'AC' : showConfirmacao('Deseja cancelar altera&ccedil;&atilde;o?','Confirma&ccedil;&atilde;o - Aimaro','controlaOperacao()','bloqueiaFundo(divRotina)','sim.gif','nao.gif');return false;break;
		case 'IC' : showConfirmacao('Deseja cancelar inclus&atilde;o?'        ,'Confirma&ccedil;&atilde;o - Aimaro','controlaOperacao()','bloqueiaFundo(divRotina)','sim.gif','nao.gif');return false;break;
		case 'AV' : manterRotina(operacao);return false;break;	
		case 'VA' : manterRotina(operacao);return false;break;
		case 'IV' : manterRotina(operacao);return false;break;
		case 'VI' : manterRotina(operacao);return false;break;
		default   : nrdrowid = ''; msgOperacao = 'abrindo consulta...';break;
	}
	showMsgAguardo('Aguarde, ' + msgOperacao);		
	
	// Executa script de através de ajax
	$.ajax({		
		type: 'POST',
		dataType: 'html',
		url: UrlSite + 'telas/contas/referencias/principal.php', 
		data: {
			nrdconta: nrdconta,
			idseqttl: idseqttl,
			operacao: operacao,
			nrdrowid: nrdrowid,
			nrdctato: nrdctato,
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
	var msgOperacao = '';
	switch (operacao) {	
		case 'VA': msgOperacao = 'salvando altera&ccedil;&atilde;o';break;
		case 'AV': msgOperacao = 'validando altera&ccedil;&atilde;o';break;						
		case 'VI': msgOperacao = 'salvando inclus&atilde;o';break;
		case 'IV': msgOperacao = 'validando inclus&atilde;o';break;						
		case 'CE': msgOperacao = 'excluindo';break;
		default: controlaOperacao(); return false; break;
	}
	showMsgAguardo('Aguarde, ' + msgOperacao + '...');
	
	nrdctato = $('#nrdctato','#frmReferencias').val();
	nmdavali = $('#nmdavali','#frmReferencias').val();
	nmextemp = $('#nmextemp','#frmReferencias').val();
	cddbanco = $('#cddbanco','#frmReferencias').val();
	cdageban = $('#cdageban','#frmReferencias').val();
	dsproftl = $('#dsproftl','#frmReferencias').val();
	nrcepend = $('#nrcepend','#frmReferencias').val();
	dsendere = $('#dsendere','#frmReferencias').val();
	nrendere = $('#nrendere','#frmReferencias').val();
	complend = $('#complend','#frmReferencias').val();
	nmbairro = $('#nmbairro','#frmReferencias').val();
	nmcidade = $('#nmcidade','#frmReferencias').val();
	cdufende = $('#cdufende','#frmReferencias').val();
	nrcxapst = $('#nrcxapst','#frmReferencias').val();
	nrtelefo = $('#nrtelefo','#frmReferencias').val();
	dsdemail = $('#dsdemail','#frmReferencias').val();
	
	nrdctato = normalizaNumero(nrdctato);
	nrcepend = normalizaNumero(nrcepend);
	nrendere = normalizaNumero(nrendere);
	nrcxapst = normalizaNumero(nrcxapst);
	
	nmdavali = trim(nmdavali);
	nmextemp = trim(nmextemp);
	dsproftl = trim(dsproftl);
	dsendere = trim(dsendere);
	complend = trim(complend);
	nmbairro = trim(nmbairro);
	nmcidade = trim(nmcidade);
	dsdemail = trim(dsdemail);
	nrtelefo = trim(nrtelefo);
	
	// Executa script de confirmação através de ajax
	$.ajax({		
		type: 'POST',
		url: UrlSite + 'telas/contas/referencias/manter_rotina.php', 		
		data: {
			nrdconta: nrdconta, idseqttl: idseqttl, nrdctato: nrdctato,
			nmdavali: nmdavali, nmextemp: nmextemp, cddbanco: cddbanco,
			cdageban: cdageban, dsproftl: dsproftl, nrcepend: nrcepend,
			dsendere: dsendere, nrendere: nrendere, complend: complend,
			nmbairro: nmbairro, nmcidade: nmcidade, cdufende: cdufende,
			nrcxapst: nrcxapst, nrtelefo: nrtelefo, dsdemail: dsdemail,			
			operacao: operacao, nrdrowid: nrdrowid,	flgcadas: flgcadas,
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
	
	altura  = ( in_array(operacao,['AC','IC','FI','FA','FE','']) ) ? '205px' : '340px';
	largura = ( in_array(operacao,['AC','IC','FI','FA','FE','']) ) ? '580px' : '582px';
	divRotina.css('width',largura);	
	$('#divConteudoOpcao').css('height',altura);
	
	// Operação consultando
	if ( in_array(operacao,['AC','IC','FI','FA','FE','']) ) {	

		var divRegistro = $('div.divRegistros');		
		var tabela      = $('table', divRegistro );
		var linha       = $('table > tbody > tr', divRegistro );
		
		divRegistro.css('height','150px');
		
		var ordemInicial = new Array();
		ordemInicial = [[1,0]];
		
		var arrayLargura = new Array();
		arrayLargura[0] = '65px';
		arrayLargura[1] = '150px';
		arrayLargura[2] = '100px';
		
		var arrayAlinha = new Array();
		arrayAlinha[0] = 'right';
		
		nrdrowid = tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha );
		linha.mouseup( function() { 
			nrdrowid = $('input', $(this) ).val();
		}).dblclick( function() {
			controlaOperacao('CA');
		});	
	
	// Operação Alterando/Incluindo
	} else {	

		// RÓTULOS - ENDEREÇO / CONTA / NOME / TELEFONE / EMAIL
		var rRotulos	= $('label[for="nrdctato"],label[for="nmextemp"],label[for="cddbanco"],label[for="cdageban"],,label[for="nrtelefo"]','#'+nomeForm);
		var rLinha		= $('label[for="dsproftl"],label[for="nmdavali"]','#'+nomeForm);		
		var rNome		= $('label[for="nmdavali"]','#'+nomeForm);
		var rRotulo40   = $('label[for="dsdemail"]','#'+nomeForm);
		
		var rCep		= $('label[for="nrcepend"]','#'+nomeForm);
		var rEnd		= $('label[for="dsendere"]','#'+nomeForm);
		var rNum		= $('label[for="nrendere"]','#'+nomeForm);
		var rCom		= $('label[for="complend"]','#'+nomeForm);
		var rCax		= $('label[for="nrcxapst"]','#'+nomeForm);	
		var rBai		= $('label[for="nmbairro"]','#'+nomeForm);
		var rEst		= $('label[for="cdufende"]','#'+nomeForm);	
		var rCid		= $('label[for="nmcidade"]','#'+nomeForm);
		
		var rCon		= $('label[for="nrdctato"]','#'+nomeForm);
		var rNom		= $('label[for="nmdavali"]','#'+nomeForm);
		var rTel		= $('label[for="nrtelefo"]','#'+nomeForm);
		var rEma		= $('label[for="dsdemail"]','#'+nomeForm);

		// Formatando os Rótulos
		rRotulos.addClass('rotulo rotulo-70');
		rLinha.addClass('rotulo-linha');
		rRotulo40.addClass('rotulo-40');

		// referencia
		rCon.addClass('rotulo rotulo-70');
		rNom.addClass('rotulo-linha').css('width','35px');
		
		// endereco
		rCep.addClass('rotulo').css('width','70px');
		rEnd.addClass('rotulo-linha').css('width','35px');
		rNum.addClass('rotulo').css('width','70px');
		rCom.addClass('rotulo-linha').css('width','52px');
		rCax.addClass('rotulo').css('width','70px');
		rBai.addClass('rotulo-linha').css('width','52px');
		rEst.addClass('rotulo').css('width','70px');
		rCid.addClass('rotulo-linha').css('width','52px');

		// telefone e email
		rTel.addClass('rotulo rotulo-70');
		rEma.addClass('rotulo-40');

		// CAMPOS - ENDEREÇO / CONTA / NOME TELEFONE / EMAIL
		var cTodos		= $('input, select','#frmReferencias');
		var cSelect     = $('select','#frmReferencias');
		var cDescricao 	= $('#nmdbanco,#nmageban','#frmReferencias');
		var cCodigo		= $('#cddbanco,#cdageban','#frmReferencias');
		var cCon		= $('#nrdctato','#'+nomeForm);
		var cNom		= $('#nmdavali','#'+nomeForm);
		var cEmpresa	= $('#nmextemp','#frmReferencias');		
		var cCargo		= $('#dsproftl','#frmReferencias');		
		
		var cCep		= $('#nrcepend','#'+nomeForm);
		var cEnd		= $('#dsendere','#'+nomeForm);
		var cNum		= $('#nrendere','#'+nomeForm);
		var cCom		= $('#complend','#'+nomeForm);
		var cCax		= $('#nrcxapst','#'+nomeForm);		
		var cBai		= $('#nmbairro','#'+nomeForm);
		var cEst		= $('#cdufende','#'+nomeForm);	
		var cCid		= $('#nmcidade','#'+nomeForm);

		var cTel	= $('#nrtelefo','#'+nomeForm);
		var cEma	= $('#dsdemail','#'+nomeForm);
		
		// todos
		cTodos.addClass('campo');
		cCodigo.addClass('codigo pesquisa');
		cDescricao.addClass('descricao').css('width','405px');
		
		// referencia
		cCon.css('width','80px').addClass('conta pesquisa');
		cNom.css('width','322px').addClass('alphanum').attr('maxlength','40');
		cEmpresa.css('width','270px').addClass('alphanum').attr('maxlength','35');
		cCargo.css('width','148px').addClass('alphanum').attr('maxlength','20');
		
		// endereco	
		cCep.addClass('cep pesquisa').css('width','65px').attr('maxlength','9');
		cEnd.addClass('alphanum').css('width','338px').attr('maxlength','40');
		cNum.addClass('numerocasa').css('width','65px').attr('maxlength','7');
		cCom.addClass('alphanum').css('width','338px').attr('maxlength','40');	
		cCax.addClass('caixapostal').css('width','65px').attr('maxlength','6');	
		cBai.addClass('alphanum').css('width','338px').attr('maxlength','40');	
		cEst.css('width','65px');	
		cCid.addClass('alphanum').css('width','338px').attr('maxlength','25');

		// telefone e email
		cTel.css('width','150px').attr('maxlength','20');
		cEma.css('width','267px').attr('maxlength','30');

		var endDesabilita = $('#dsendere,#cdufende,#nmbairro,#nmcidade','#'+nomeForm);
		
		// ie
		if ( $.browser.msie ) {	
			cEnd.addClass('alphanum').css('width','341px');
			cCom.addClass('alphanum').css('width','341px');	
			cBai.addClass('alphanum').css('width','341px');	
			cCid.addClass('alphanum').css('width','341px');
		}
		
		switch (operacao) {
			case 'CI': // Caso Inclusão
				$('#'+nomeForm).limpaFormulario();
				cTodos.desabilitaCampo();
				cCon.habilitaCampo();
				break;
			case 'CC': // Caso Consulta
				cTodos.desabilitaCampo();
				break;
			case 'TE': // Caso Exclusão Consulta
				cTodos.desabilitaCampo();
				break;			
			case 'CB': // Caso Pesquisa pela Conta para Inclusão
				cTodos.desabilitaCampo();
				break;
			case 'CA': // Caso Alteração
				cTodos.habilitaCampo();
				cCon.desabilitaCampo();
				endDesabilita.desabilitaCampo();
				break;
			default:
				controlaOperacao();
				return false;
				break;
		}
		
		cCodigo.unbind('blur').bind('blur', function() { 
			controlaPesquisas(); 
		});
		
		cEma.unbind("keydown").bind("keydown",function(e) {
			if (e.keyCode == 13) {
				$("#btSalvar","#divBotoes").trigger("click");
				return false;
			}	
		});	
		
		controlaPesquisas();
		layoutPadrao();
	
		if (operacao == 'CI')  {
			cCon.unbind('keydown').bind('keydown', function(e){ 	
	
				if ( divError.css('display') == 'block' ) { return false; }		
			
				// Se é a tecla ENTER, verificar numero conta e realizar as devidas operações
				if ( e.keyCode == 13 ) {		
							
					// Armazena o número da conta na variável global
					nrconta = normalizaNumero( $(this).val() );
							
					// Verifica se o número da conta é vazio
					if ( nrconta == '' || nrconta == 0 ) { 
						cTodos.habilitaCampo();
						cDescricao.desabilitaCampo();
						cCon.desabilitaCampo();
						endDesabilita.desabilitaCampo();
						controlaPesquisas();
						cNom.focus();
					} else {
						if ( !validaNroConta(nrconta) ) { showError('error','Conta/dv inválida.','Alerta - Aimaro','bloqueiaFundo(divRotina);'); return false; }
						nrdctato = nrconta;
						controlaOperacao('CB');
					}
					return false;
				}		
			});	
		}
		
		
		cNum.trigger('blur');
		cCon.trigger('blur');
		cCep.trigger('blur'); 
		cCax.trigger('blur'); 
	}
	
	hideMsgAguardo();
	bloqueiaFundo(divRotina);
	removeOpacidade('divConteudoOpcao');
	highlightObjFocus($('#frmReferencias'));
	controlaFocoEnter("frmReferencias");
	controlaFoco(operacao);
	divRotina.centralizaRotinaH();
	return false;	
}

function controlaFoco(operacao) {
	if (in_array(operacao,['AC','FA','IC','FI',''])) {		
		$('#btConsultar','#divBotoes').focus();
	} else {		
		$('.campo:first','#'+nomeForm).focus();
	}
	return false;
}

function controlaPesquisas() {
	
	// Variável local para guardar o elemento anterior
	var campoAnterior = '';
	var bo, procedure, titulo, qtReg, filtrosPesq, filtrosDesc, colunas;
	var camposOrigem = 'nrcepend;dsendere;nrendere;complend;nrcxapst;nmbairro;cdufende;nmcidade';	
	
	// Inicializa a BO padrão
	bo = 'b1wgen0059.p';
	
// CONTROLE DAS PESQUISAS
	
	// Atribui a classe lupa para os links de desabilita todos
	$('a','#'+nomeForm).addClass('lupa').css('cursor','auto');
	
	// Percorrendo todos os links
	$('a','#'+nomeForm).each( function() {
	
		if ( !$(this).prev().hasClass('campoTelaSemBorda') ) { $(this).css('cursor','pointer'); }
		
		$(this).unbind("click").bind("click",( function() {
			if ( $(this).prev().hasClass('campoTelaSemBorda') ) {
				return false;
			} else {						
				campoAnterior = $(this).prev().attr('name');
				
				// Banco
				if ( campoAnterior == 'cddbanco' ) {
					procedure	= 'busca_banco';
					titulo      = 'Banco';
					qtReg		= '30';
					filtrosPesq	= 'Cód. Banco;cddbanco;30px;S;0|Nome Banco;nmdbanco;200px;S;';
					colunas 	= 'Código;cdbccxlt;20%;right|Banco;nmextbcc;80%;left';
					mostraPesquisa(bo,procedure,titulo,qtReg,filtrosPesq,colunas,divRotina);
					return false;
				
				// Agência
				} else if ( campoAnterior == 'cdageban' ) {
					procedure	= 'busca_agencia';
					titulo      = 'Agência';
					qtReg		= '30';
					filtrosPesq	= 'Cód. Agência;cdageban;30px;S;0|Agência;nmageban;200px;S;|Cód. Banco;cddbanco;30px;N;|Banco;nmdbanco;200px;N;';
					colunas 	= 'Código;cdageban;20%;right|Agência;nmageban;80%;left';
					mostraPesquisa(bo,procedure,titulo,qtReg,filtrosPesq,colunas,divRotina);
					return false;

				// Nr. Conta do Cônjuge
				} else if ( campoAnterior == 'nrdctato' ) {
					mostraPesquisaAssociado('nrdctato',nomeForm,divRotina);	
					return false;					
				
				// Cep
				} else if ( campoAnterior == 'nrcepend' ) {
					mostraPesquisaEndereco(nomeForm, camposOrigem, divRotina);
					return false;					
				} 		
			}
			return false;
		}));
	});	
	
// CONTROLE DAS BUSCA DESCRIÇÕES
	
	// Banco
	$('#cddbanco','#'+nomeForm).unbind('change').bind('change',function() {		
		procedure   = 'busca_banco';
		titulo      = 'Bancos';
		filtrosDesc = '';
		buscaDescricao(bo,procedure,titulo,$(this).attr('name'),'nmdbanco',$(this).val(),'nmresbcc',filtrosDesc,nomeForm);
		return false;
	});	
	
	// Agência
	$('#cdageban','#'+nomeForm).unbind('change').bind('change',function() {		
		procedure   = 'busca_agencia';
		titulo      =  'Agências';
		filtrosDesc = 'cddbanco|'+$('#cddbanco','#'+nomeForm).val();
		buscaDescricao(bo,procedure,titulo,$(this).attr('name'),'nmageban',$(this).val(),'nmageban',filtrosDesc,nomeForm);
		return false;
	});	

	// Cep
	$('#nrcepend','#'+nomeForm).buscaCEP(nomeForm, camposOrigem, divRotina);
	
	return false;
}

function btLimpar(){		
	
	cTodos		= $('input, select','#frmReferencias');
	cSelect 	= $('select','#frmReferencias');
	cConta 		= $('#nrdctato','#frmReferencias');
	cDescricao 	= $('#nmdbanco,#nmageban','#frmReferencias');
	cNome 		= $('#nmdavali','#frmReferencias');
	
	$('#'+nomeForm).limpaFormulario();
	cTodos.desabilitaCampo();
	cConta.habilitaCampo();	
	controlaPesquisas();
	controlaFoco(operacao);
	
	cConta.unbind('keydown').bind('keydown', function(e){ 	
	
		if ( divError.css('display') == 'block' ) { return false; }		
	
		// Se é a tecla ENTER, verificar numero conta e realizar as devidas operações
		if ( e.keyCode == 13 ) {		
					
			// Armazena o número da conta na variável global
			nrconta = normalizaNumero( $(this).val() );
					
			// Verifica se o número da conta é vazio
			if ( nrconta == '' || nrconta == 0 ) { 
				cTodos.habilitaCampo();
				cDescricao.desabilitaCampo();
				cConta.desabilitaCampo();
				controlaPesquisas();
				cNome.focus();
				
			} else {
				if ( !validaNroConta(nrconta) ) { showError('error','Conta/dv inválida.','Alerta - Aimaro','bloqueiaFundo(divRotina);'); return false; }
				nrdctato = nrconta;
				controlaOperacao('CB');
			}
			return false;
		}		
	});			
	return false;	
}


function voltarRotina() {
	fechaRotina(divRotina);
	acessaRotina('E_MAILS','E-Mails','emails');	
}

function proximaRotina () {
	encerraRotina(false);
	acessaRotina('CONTA CORRENTE','Conta Corrente','conta_corrente');				
}