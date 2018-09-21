/*!
 * FONTE        : banco.js
 * CRIAÇÃO      : GAbriel Capoia - DB1 Informatica
 * DATA CRIAÇÃO : 23/04/2010 
 * OBJETIVO     : Biblioteca de funções na rotina Banco da tela de CONTAS
 * --------------
 * ALTERAÇÕES   :
 * --------------
 * 001: [05/05/2010] Rodolpho Telmo (DB1) : Adaptação da tela ao "tableSorter"
 * 002: [06/02/2012] Tiago (CECRED)       : Ajuste para não chamar 2 vezes a função mostraPesquisa. 
 * 003: [05/08/2015] Gabriel (RKAM)       : Reformulacao Cadastral.
 */	 

var nrdlinha = '';
var operacao = '';
var nomeForm = 'frmDadosBancos';

// Função para acessar opções da rotina
function acessaOpcaoAba(nrOpcoes,id,opcao) {

	// Mostra mensagem de aguardo
	showMsgAguardo('Aguarde, carregando ...');
	
	// Atribui cor de destaque para aba da opção
	for (var i = 0; i < nrOpcoes; i++) {
		if (!$('#linkAba' + id)) {
			continue;
		}
		
		if (id == i) { // Atribui estilos para foco da opção
			$('#linkAba' + id).attr('class','txtBrancoBold');
			$('#imgAbaEsq' + id).attr('src',UrlImagens + 'background/mnu_sle.gif');				
			$('#imgAbaDir' + id).attr('src',UrlImagens + 'background/mnu_sld.gif');
			$('#imgAbaCen' + id).css('background-color','#969FA9');
			continue;			
		}
		
		$('#linkAba' + i).attr('class','txtNormalBold');
		$('#imgAbaEsq' + i).attr('src',UrlImagens + 'background/mnu_nle.gif');			
		$('#imgAbaDir' + i).attr('src',UrlImagens + 'background/mnu_nld.gif');
		$('#imgAbaCen' + i).css('background-color','#C6C8CA');
	}

	// Carrega conteúdo da opção através do Ajax
	$.ajax({		
		type: 'POST', 
		dataType: 'html',
		url: UrlSite + 'telas/contas/banco/principal.php',
		data: {
			nrdconta: nrdconta,	idseqttl: idseqttl,
			operacao: operacao,	nrdlinha: nrdlinha,
			flgcadas: flgcadas, redirect: 'html_ajax'
		},		
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError('error','1 N&atilde;o foi possível concluir a requisi&ccedil;&atilde;o.','Alerta - Aimaro','bloqueiaFundo(divRotina)');
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

/*!
 * OBJETIVO : Função de controle das ações/operações da Rotina de Bens da tela de CONTAS
 * PARÂMETRO: Operação que deseja-se realizar
 */
function controlaOperacao(operacao) {

	if ( (operacao == 'TA') && (flgAlterar != '1') ) { showError('error','Seu usu&aacute;rio n&atilde;o possui permiss&atilde;o de altera&ccedil;&atilde;o.','Alerta - Aimaro','bloqueiaFundo(divRotina)'); return false; }
	if ( (operacao == 'TE') && (flgExcluir != '1') ) { showError('error','Seu usu&aacute;rio n&atilde;o possui permiss&atilde;o de exclus&atilde;o.'        ,'Alerta - Aimaro','bloqueiaFundo(divRotina)'); return false; }
	if ( (operacao == 'TI') && (flgIncluir != '1') ) { showError('error','Seu usu&aacute;rio n&atilde;o possui permiss&atilde;o de incluis&atilde;o.'       ,'Alerta - Aimaro','bloqueiaFundo(divRotina)'); return false; }
	
	// Seleciona o registro selecionado somente para alteração e exclusão
	if ( in_array(operacao,['TA','TE']) ) {
		nrdlinha = selecionaRegistro();
		if ( nrdlinha == '' ) { return false; }
	}
	
	var mensagem = '';	
	switch (operacao) {			
		case 'TA' :	
			mensagem = 'abrindo altera&ccedil;&atilde;o ...';
			cddopcao = 'A';
			break;
		case 'TI' : 
			if (nrregatu >= nrlimmax) { showError('error','Limite m&aacute;ximo atingido ('+nrlimmax+').','Alerta - Aimaro','bloqueiaFundo(divRotina)');return false; }
			mensagem = 'abrindo inclus&atilde;o ...';
			nrdlinha = '';
			cddopcao = 'I';
			break;	
		case 'TE' : 
			mensagem = 'processando exclus&atilde;o ...';
			cddopcao = 'E';
			break;			
		case 'AT' : showConfirmacao('Deseja cancelar altera&ccedil;&atilde;o?','Confirma&ccedil;&atilde;o - Aimaro','controlaOperacao()','bloqueiaFundo(divRotina)','sim.gif','nao.gif');return false;break;
		case 'IT' : showConfirmacao('Deseja cancelar inclus&atilde;o?'        ,'Confirma&ccedil;&atilde;o - Aimaro','controlaOperacao()','bloqueiaFundo(divRotina)','sim.gif','nao.gif');return false;break;
		case 'AV' : manterRotina(operacao);return false;break;	
		case 'IV' : manterRotina(operacao);return false;break;
		case 'EV' : manterRotina(operacao);return false;break;
		case 'VA' : manterRotina(operacao);return false;break;		
		case 'VI' : manterRotina(operacao);return false;break;
		case 'VE' : manterRotina(operacao);return false;break;
		default   : 
			nrdlinha = '';
			cddopcao = 'C';
			mensagem = 'abrindo consulta...';
			break;
	}
	showMsgAguardo('Aguarde, ' + mensagem);	

	// Executa script de através de ajax
	$.ajax({		
		type: 'POST',
		dataType: 'html',
		url: UrlSite + 'telas/contas/banco/principal.php', 
		data: {
			nrdconta: nrdconta,	idseqttl: idseqttl,
			operacao: operacao,	nrdlinha: nrdlinha,
			cddopcao: cddopcao, flgcadas: flgcadas,
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

function manterRotina(operacao) {
	hideMsgAguardo();	
	var mensagem = '';
	switch (operacao) {	
		case 'AV': mensagem = 'validando altera&ccedil;&atilde;o'; break;
		case 'IV': mensagem = 'validando inclus&atilde;o'; break;				
		case 'EV': mensagem = 'validando exclus&atilde;o'; break;								
		case 'VA': mensagem = 'alterando'; break;
		case 'VI': mensagem = 'incluindo'; break;
		case 'VE': mensagem = 'excluindo'; break;
		default: controlaOperacao(); return false; break;
	}
	showMsgAguardo('Aguarde, ' + mensagem + '...');	
	
	// Recebendo valores do formulário 
	cddbanco = $('#cddbanco','#'+nomeForm).val();
	dstipope = $('#dstipope','#'+nomeForm).val();
	vlropera = $('#vlropera','#'+nomeForm).val();	
	garantia = $('#garantia','#'+nomeForm).val();
	dsvencto = $('#dsvencto','#'+nomeForm).val();
	nrdlinha = $('#nrdlinha','#'+nomeForm).val();
	
	dstipope = trim(dstipope);
	vlropera = number_format(parseFloat(vlropera.replace(/[.R$ ]*/g,'').replace(',','.')),2,',','');
	garantia = trim(garantia);
		
	// Executa script de confirmação através de ajax
	$.ajax({		
		type: 'POST',
		url: UrlSite + 'telas/contas/banco/manter_rotina.php', 		
		data: {			
			nrdconta: nrdconta,	idseqttl: idseqttl,	cddbanco: cddbanco,
			dstipope: dstipope,	vlropera: vlropera,	garantia: garantia,
			dsvencto: dsvencto,	nrdlinha: nrdlinha,	operacao: operacao,
			flgcadas: flgcadas, redirect: 'script_ajax'
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
}
 
/*!
 * OBJETIVO : Controlar o layout da tela de acordo com a operação
 *            Algumas formatações CSS que não funcionam, são contornadas por esta função
 * PARÂMETRO: Valores válidos: [C] Consultando [A] Alterando [I] Incluindo
 */
function controlaLayout(operacao) {	

	altura  = ( in_array(operacao,['AT','IT','FI','FA','FE','']) ) ? '245px' : '205px';
	largura = ( in_array(operacao,['AT','IT','FI','FA','FE','']) ) ? '585px' : '545px';
	divRotina.css('width',largura);	
	$('#divConteudoOpcao').css('height',altura);
		
	var rotulos     = $('label[for="cddbanco"],label[for="dsvencto"],label[for="vlropera"],label[for="garantia"],label[for="dstipope"]','#'+nomeForm);
	var cTodos      = $('#cddbanco,#dstipope,#vlropera,#garantia,#dsvencto','#'+nomeForm);
	var cBanco  	= $('#cddbanco','#'+nomeForm);
	var cDesBanco	= $('#dsdbanco','#'+nomeForm);
	var cOperacao   = $('#dstipope','#'+nomeForm);
	var cValor  	= $('#vlropera','#'+nomeForm);
	var cGarantia   = $('#garantia','#'+nomeForm);
	var cVencimento = $('#dsvencto','#'+nomeForm);
	
	$('label[for="dtaltjfn"]','.divFinanc').addClass('rotulo').css({'width':'160px'});
	$('label[for="cdoperad"]','.divFinanc').css({'width':'70px'});
	$('#dtaltjfn','.divFinanc').css({'width':'74px'});
	$('#cdoperad','.divFinanc').css({'width':'58px'});
	$('#nmoperad','.divFinanc').css({'width':'130px'});
	$('#dtaltjfn,#cdoperad,#nmoperad','.divFinanc').removeClass('campo').addClass('campoTelaSemBorda').prop('disabled',true);	
	
	// Operação consultando
	if ( in_array(operacao,['AT','IT','FI','FA','FE','']) ) {	
	
		var divRegistro = $('div.divRegistros');		
		var tabela      = $('table', divRegistro );
		
		divRegistro.css('height','150px');
		
		var ordemInicial = new Array();
		ordemInicial = [[0,0]];
		
		var arrayLargura = new Array();
		arrayLargura[0] = '58px';
		arrayLargura[1] = '125px';
		arrayLargura[2] = '80px';
		arrayLargura[3] = '125px';
		
		var arrayAlinha = new Array();
		arrayAlinha[0] = 'right';
		arrayAlinha[1] = 'left';
		arrayAlinha[2] = 'right';
		arrayAlinha[3] = 'left';
		arrayAlinha[4] = 'center';
		
		tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha, 'controlaOperacao(\'TA\')' );
	
	// Operação Alterando/Incluindo
	} else {		
		
		// Controla largura dos campos	
		rotulos.addClass('rotulo').css('width','130px');
		cBanco.css({'width':'30px'});
		cDesBanco.css({'width':'330px'});
		cOperacao.css({'width':'200px'});
		cGarantia.css({'width':'200px'});
		cValor.css({'width':'100px'});		
		cVencimento.css({'width':'70px'});
		
		$('label[for="venc"]','#'+nomeForm).css({'width':'35px'});		
		
		// Caso é inclusão, limpar dados do formulário
		if ( operacao == 'TI' ) {
			$('#'+nomeForm).limpaFormulario();
		}
		
		// Adicionando as classes
		cTodos.addClass('campo');
		
		if($('#dsvencto','#'+nomeForm).val() == 'VARIOS'){
			$('#dsvencto','#'+nomeForm).removeClass('campo').addClass('campoTelaSemBorda').prop('disabled',true).unbind();
			$('#venc','#'+nomeForm).prop('checked',true);
		}else{
			$('#dsvencto','#'+nomeForm).addClass('campo data').removeProp('disabled').unbind();
		}
		
		$('#venc','#'+nomeForm).change(function(){
			
			if ($(this).prop('checked')){
				$('#dsvencto','#'+nomeForm).addClass('campoTelaSemBorda').removeClass('campo data').val('VARIOS').prop('disabled',true).unbind();
			}else{
				$('#dsvencto','#'+nomeForm).removeClass('campoTelaSemBorda').addClass('data campo').val('').removeProp('disabled').unbind();				
                $('#dsvencto','#'+nomeForm).setMask("DATE","","","");				
				$('#dsvencto','#'+nomeForm).attr('tabindex', cGarantia.attr('tabindex') + 1);
				$('#dsvencto','#'+nomeForm).focus();
			}
		});
		
		cVencimento.unbind("keydown").bind("keydown",function(e) {
			if (e.keyCode == 13) {
				$("#btSalvar","#divBotoes").trigger("click");
				return false;
			}	
		});
		
		cBanco.unbind('focusin').bind('focusin', function() { controlaPesquisas(); });

	}
		
	layoutPadrao();
	controlaPesquisas();
	hideMsgAguardo();
	bloqueiaFundo(divRotina);
	removeOpacidade('divConteudoOpcao');
	divRotina.centralizaRotinaH();
	highlightObjFocus($('#frmDadosBancos'));
	controlaFocoEnter("frmDadosBancos");
	controlaFoco(operacao);
	return false;
}

function controlaFoco(operacao) {
	if (in_array(operacao,['AT','IT','FA','FI','FE',''])) {
		$('#btAlterar','#divBotoes').focus();
	} else {
		$('#cddbanco','#'+nomeForm).focus();
	}
	return false;
}

function controlaPesquisas() {

	// Variável local para guardar o elemento anterior
	var campoAnterior = '';
	var bo, procedure, titulo, qtReg, colunas;
	
	bo		  = 'b1wgen0059.p';
	procedure = 'busca_banco';
	titulo    = 'Bancos';
	
	/*-------------------------------------*/
	/*       CONTROLE DAS PESQUISAS        */
	/*-------------------------------------*/
	
	// Atribui a classe lupa para os links e desabilita todos
	$('a','#'+nomeForm).addClass('lupa').css('cursor','auto');
		
	// Percorrendo todos os links
	$('a','#'+nomeForm).each( function() {
		
		if ( !$(this).prev().hasClass('campoTelaSemBorda') ) { $(this).css('cursor','pointer'); }
		
		$(this).unbind("click").bind("click",( function() {
			if ( $(this).prev().hasClass('campoTelaSemBorda') ) {
				return false;
			} else {						
				
				campoAnterior = $(this).prev().attr('name');
				
				// Inf. Cadastrais
				if ( campoAnterior == 'cddbanco' ) {
					qtReg		= '20';
					filtros 	= 'Cód. Banco;cddbanco;30px;S;0|Banco;dsdbanco;200px;S;';
					colunas 	= 'Código;cdbccxlt;20%;right|Banco;nmresbcc;80%;left';
					mostraPesquisa(bo,procedure,titulo,qtReg,filtros,colunas,divRotina);
					return false;
													
				}					
			}
			return false;		
		}));
	});
	
	/*-------------------------------------*/
	/*   CONTROLE DAS BUSCA DESCRIÇÕES     */
	/*-------------------------------------*/
	
	// Bancos
	$('#cddbanco','#'+nomeForm).unbind('change').bind('change', function() {		
		buscaDescricao(bo,procedure,titulo,$(this).attr('name'),'dsdbanco',$(this).val(),'nmresbcc','','frmDadosBancos');
		return false;
	});	
	return false;
}

function voltarRotina() {
	fechaRotina(divRotina);
	acessaRotina('FINANCEIRO-ATIVO/PASSIVO','Ativo/Passivo','ativo_passivo');	
}

function proximaRotina () {
	hideMsgAguardo();
	encerraRotina(false);
	acessaRotina('FINANCEIRO-RESULTADO','Resultado','resultado');				
}