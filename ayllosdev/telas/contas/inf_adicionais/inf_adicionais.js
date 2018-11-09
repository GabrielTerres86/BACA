/*!
 * FONTE        : inf_adicionais.js
 * CRIAÇÃO      : Gabriel Capoia (DB1)
 * DATA CRIAÇÃO : Abril/2010 
 * OBJETIVO     : Biblioteca de funções da rotina Inf. Adicionais da tela de CONTAS
 * --------------
 * ALTERAÇÕES   :
 * --------------
 * 001: [15/04/2010] Rodolpho Telmo (DB1): Criada a função controlaPesquisas que substituirá a controlaLupas
 * 002: [16/04/2010] Rodolpho Telmo (DB1): Alterada função controlaLayout
 * 003: [15/09/2010] Gabriel Ramirez     : Incluir campo de informaçoes complementares para p. fisica tambem.
 * 003: [06/04/2011] Adriano			 : Realizado alteracao na funcao controlaPesquisas para atender a nova     
 *			   							   tabela do rating
 * 004: [06/02/2012] Tiago (CECRED)      : Ajuste para não chamar 2 vezes a função mostraPesquisa.
 * 005: [06/08/2015] Gabriel (RKAM)      : Reformulacao Cadastral
 */

// Definição das variáveis globais para a rotina 
var inpessoa, msgAlert, operacao;
var flgContinuar = false;    // Controle botao Continuar	


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
		url: UrlSite + "telas/contas/inf_adicionais/principal.php",
		data: {
			nrdconta: nrdconta,
			idseqttl: idseqttl,
			inpessoa: inpessoa,
			flgcadas: flgcadas,
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
				controlaFoco( operacao );
			}
			return false;
		}				
	});		
}

function controlaOperacao(operacao) {

	if( !verificaSemaforo() && operacao != 'CA' ) { return false; }

	// Verifica permissões de acesso
	if ( (operacao == 'CA') && (flgAlterar != '1') ) { 
		showError('error','Seu usu&aacute;rio n&atilde;o possui permiss&atilde;o de altera&ccedil;&atilde;o.','Alerta - Ayllos','semaforo--;bloqueiaFundo(divRotina);');
		return false;
	} 
		
	// Mostra mensagem de aguardo
	var msgOperacao = '';
	switch (operacao) {			
		// Consulta para Alteração
		case 'CA': 
			msgOperacao = 'abrindo altera&ccedil;&atilde;o';
			break;
		// Alteração para Consulta - Cancelando Operação
		case 'AC': 
			showConfirmacao('Deseja cancelar opera&ccedil;&atilde;o?','Confirma&ccedil;&atilde;o - Ayllos','semaforo--;controlaOperacao()','semaforo--;bloqueiaFundo(divRotina)','sim.gif','nao.gif');
			return false;
			break;	
		// Alteração para Validação - Validando Alteração
		case 'AV': 
			manterRotina(operacao);
			return false;
			break;	
		// Validação para Alteração - Salvando Alteração
		case 'VA': 
			manterRotina(operacao);
			return false;
			break;				
		// Qualquer outro Valor: Abrindo tela em modo Consulta
		default: 
			msgOperacao = 'abrindo tela';
			break;			
	}
	
	showMsgAguardo('Aguarde, ' + msgOperacao + '...');
	
	// Executa script de através de ajax
	$.ajax({		
		type: 'POST',
		dataType: 'html',
		url: UrlSite + 'telas/contas/inf_adicionais/principal.php', 
		data: {
			nrdconta: nrdconta,
			idseqttl: idseqttl,
			flgcadas: flgcadas,
			operacao: operacao,
			redirect: "html_ajax"
		},  
		error: function(objAjax,responseError,objExcept) {
			semaforo--;
			hideMsgAguardo();
			showError('error','N&atilde;o foi possível concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','bloqueiaFundo(divRotina)');
		},
		success: function(response) {
			semaforo--;
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
	semaforo--;
	hideMsgAguardo();		
	var msgOperacao = '';
	switch (operacao) {	
		case 'VA': msgOperacao = 'salvando altera&ccedil;&atilde;o'; break;
		case 'AV': msgOperacao = 'validando altera&ccedil;&atilde;o'; break;										
		default: return false; break;
	}
	showMsgAguardo('Aguarde, ' + msgOperacao + '...');
	
	var nrinfcad = $("#nrinfcad",'#frmInfAdicional').val();	
	var nrpatlvr = $("#nrpatlvr",'#frmInfAdicional').val();  
	var nrperger = $("#nrperger",'#frmInfAdicional > #divJuridico').val();  
	var dsinfadi = $("#dsinfadi",'#frmInfAdicional').serialize(); ; 

	$.ajax({		
		type: 'POST',
		url: UrlSite + 'telas/contas/inf_adicionais/manter_rotina.php', 		
		data: {
			nrdconta: nrdconta, idseqttl: idseqttl, 
			nrinfcad: nrinfcad, nrpatlvr: nrpatlvr,	
			nrperger: nrperger, dsinfadi: dsinfadi,
			inpessoa: inpessoa, operacao: operacao,
			flgcadas: flgcadas, redirect: 'script_ajax'
		}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','bloqueiaFundo(divRotina)');
		},
		success: function(response) {
			try {
				
				eval(response);
				
				if  (operacao == 'VA' && (flgcadas == 'M' || flgContinuar)) {
					proximaRotina();
				}
				
			} catch(error) {
				hideMsgAguardo();
				showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','bloqueiaFundo(divRotina)');
			}
		}				
	});
}

function controlaLayout() {	
	
	$('#divConteudoOpcao').fadeTo(1,0.01);
	$('#frmInfAdicional').css({'padding':'5px 5px'});
	
	var rotulos   = $('label','#frmInfAdicional');	
	var codigo    = $('#nrinfcad,#nrpatlvr,#nrperger','#frmInfAdicional');
	var descricao = $('#dsinfcad,#dspatlvr,#dsperger','#frmInfAdicional');				
	var textarea  = $('#dsinfadi','#frmInfAdicional');	
	var nrpatlvr  = $('label[for="nrpatlvr"]','#frmInfAdicional');		
	var juridicos = $('#divJuridico','#frmInfAdicional');

	// Controla a altura da tela e muda o label "nrpatlvr" de acordo com o tipo de pessoa
	if ( inpessoa == 1 ) {	
		$('#divConteudoOpcao').css({'height':'260px','width':'520px'});
		nrpatlvr.html('Patrim&ocirc;nio pessoal livre em rela&ccedil;&atilde;o ao endividamento:');				
		juridicos.css('display','none');		
		
	} else {		
		$('#divConteudoOpcao').css({'height':'315px','width':'520px'});
		nrpatlvr.html('Patrim&ocirc;nio pessoal dos garantidores ou socios livre de &ocirc;nus:');
		juridicos.css('display','block');
	}
	
	// Formatação Inicial
	rotulos.addClass('rotulo');
	codigo.addClass('codigo pesquisa').css('clear','left');
	descricao.addClass('descricao').css('width','453px');
	textarea.addClass('alphanum').css({'width':'507px','height':'80px','float':'left','margin':'3px 0px 3px 3px','padding-right':'1px'});
	
	if ( operacao == 'CA' ) {
		codigo.habilitaCampo();
		textarea.habilitaCampo();
		textarea.limitaTexto();		
		
		codigo.unbind('blur').bind('blur', function() { 
			controlaPesquisas(); 
		});
		
		textarea.unbind("keydown").bind("keydown",function(e) {
			if (e.keyCode == 13) {
				$("#btSalvar","#divBotoes").trigger("click");
				return false;
			}	
		});	
		
		
	} else {
		codigo.desabilitaCampo();
		textarea.desabilitaCampo();
	}
	
	controlaPesquisas();
	layoutPadrao();
	textarea.removeAttr('text-transform');
	hideMsgAguardo();
	bloqueiaFundo(divRotina);
	removeOpacidade('divConteudoOpcao');
	highlightObjFocus($('#frmInfAdicional'));
	controlaFocoEnter("frmInfAdicional");
	return false;
}	

function controlaFoco() {
	if (in_array(operacao,['AC','FA',''])) {
		$('#btAlterar','#divBotoes').focus();
	} else {
		$('.campo:first','#frmInfAdicional').focus();
	}
	return false;
}

function controlaPesquisas() {

	// Variável local para guardar o elemento anterior
	var campoAnterior = '';
	var bo, procedure, titulo, qtReg, filtrosPesq, filtrosDesc, colunas, nrtopico, nritetop;
	
	bo		  = 'b1wgen0059.p';
	procedure = 'busca_seqrating';
	
	/*-------------------------------------*/
	/*       CONTROLE DAS PESQUISAS        */
	/*-------------------------------------*/
	
	// Atribui a classe lupa para os links e desabilita todos
	$('a','#frmInfAdicional').addClass('lupa').css('cursor','auto');
	
	
	// Percorrendo todos os links
	$('a','#frmInfAdicional').each( function() {
		
		if ( !$(this).prev().hasClass('campoTelaSemBorda') ) { $(this).css('cursor','pointer'); }
		
		$(this).unbind("click").bind("click",( function() {
		
			if ( $(this).prev().hasClass('campoTelaSemBorda') ) {
				return false;
			} else {						
				campoAnterior = $(this).prev().attr('name');
				
				// Inf. Cadastrais
				if ( campoAnterior == 'nrinfcad' ) {
					titulo      = 'Informa&ccedil;&atilde;o Cadastral';
					qtReg		= '20';					
					nrtopico    = ( inpessoa == 1 ) ? '1' : '3';
					nritetop    = ( inpessoa == 1 ) ? '4' : '3';
					filtrosPesq	= 'Cód. Inf. Cadastral;nrinfcad;30px;S;0|Inf. Cadastral;dsinfcad;200px;S;|nrtopico;nrtopico;0px;N;'+nrtopico+';N|nritetop;nritetop;0px;N;'+nritetop+';N';
					colunas 	= 'Código;nrseqite;20%;right|Inf. Cadastral;dsseqite;80%;left';
					mostraPesquisa(bo,procedure,titulo,qtReg,filtrosPesq,colunas,divRotina);
					return false;	
				
				// Patrimônio Livre
				} else if ( campoAnterior == 'nrpatlvr' ) {
					titulo      = 'Patrimonio Livre';
					qtReg		= '20';
					nrtopico    = ( inpessoa == 1 ) ? '1' : '3';
					nritetop    = ( inpessoa == 1 ) ? '8' : '9';
					filtrosPesq = 'Cód. Patr. Livre;nrpatlvr;30px;S;0|Patrimonio Livre;dspatlvr;200px;S;|nrtopico;nrtopico;0px;N;'+nrtopico+';N|nritetop;nritetop;0px;N;'+nritetop+';N';
					colunas 	= 'Código;nrseqite;20%;right|Patrimonio Livre;dsseqite;80%;left';
					mostraPesquisa(bo,procedure,titulo,qtReg,filtrosPesq,colunas,divRotina);
					return false;

				// Percepção Geral
				} else if ( campoAnterior == 'nrperger' ) {
					titulo      = 'Percep&ccedil;&atilde;o Geral';
					qtReg		= '20';
					nrtopico    = '3';
					nritetop    = '11';
					filtrosPesq	= 'Cód. Percepção;nrperger;30px;S;0|Percepção Geral;dsperger;200px;S;|nrtopico;nrtopico;0px;N;'+nrtopico+';N|nritetop;nritetop;0px;N;'+nritetop+';N';
					colunas 	= 'Código;nrseqite;20%;right|Percepção Geral;dsseqite;80%;left';
					mostraPesquisa(bo,procedure,titulo,qtReg,filtrosPesq,colunas,divRotina);
					return false;
					
				}					
			}
			return false;		
		}));
	});
	
	/*-------------------------------------*/
	/*   CONTROLE DAS BUSCA DESCRIÇÕES     */
	/*-------------------------------------*/
	
	// Inf. Cadastrais
	$('#nrinfcad','#frmInfAdicional').unbind('change').bind('change',function() {
		titulo      = 'Informa&ccedil;&atilde;o Cadastral';
		nrtopico    = ( inpessoa == 1 ) ? '1' : '3';
		nritetop    = ( inpessoa == 1 ) ? '4' : '3';
		filtrosDesc = 'nrtopico|'+nrtopico+';nritetop|'+nritetop;
		buscaDescricao(bo,procedure,titulo,$(this).attr('name'),'dsinfcad',$(this).val(),'dsseqite',filtrosDesc,'frmInfAdicional');
		return false;
	});
	
	// Patrimônio Livre
	$('#nrpatlvr','#frmInfAdicional').unbind('keypress').bind('keypress',function(e) {
		if (e.keyCode == 13) {
			$(this).trigger("change");
			if (inpessoa == 1) {
				$('#dsinfadi','#frmInfAdicional').focus();
			} else {
				$('#nrperger','#frmInfAdicional').focus();	
			}
		}
	});
	
	// Patrimônio Livre
	$('#nrpatlvr','#frmInfAdicional').unbind('change').bind('change',function() {
		titulo      = 'Patrim&ocirc;nio Livre';
		nrtopico    = ( inpessoa == 1 ) ? '1' : '3';
		nritetop    = ( inpessoa == 1 ) ? '8' : '9';
		filtrosDesc = 'nrtopico|'+nrtopico+';nritetop|'+nritetop;
		buscaDescricao(bo,procedure,titulo,$(this).attr('name'),'dspatlvr',$(this).val(),'dsseqite',filtrosDesc,'frmInfAdicional');
		return false;
	});
	
	// Percepção Geral
	$('#nrperger','#frmInfAdicional').unbind('change').bind('change',function() {
		titulo      = 'Percep&ccedil;&atilde;o Geral';
		nrtopico    = '3';
		nritetop    = '11';
		filtrosDesc = 'nrtopico|'+nrtopico+';nritetop|'+nritetop;
		buscaDescricao(bo,procedure,titulo,$(this).attr('name'),'dsperger',$(this).val(),'dsseqite',filtrosDesc,'frmInfAdicional');
		return false;
	});	
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
	
	if (inpessoa == 1) {
		acessaOpcaoAbaDados(4,2,'@');
	} else {
		fechaRotina(divRotina);
		acessaRotina('FINANCEIRO-FATURAMENTO','Faturamento','faturamento');	
	}
}

function proximaRotina () {
	
	hideMsgAguardo();
	encerraRotina(false);
	
	if (inpessoa == 2) {
		acessaRotina('IMUNIDADE TRIBUTARIA','Imunidade Tributaria','imunidade_tributaria');	
	} else {
		if (flgcadas == 'M') {
			acessaRotina('Dados Pessoais', 'Dados Pessoais', 'dados_pessoais');
		} else {	
			showMsgAguardo('Aguarde, carregando tela ATENDA ...');
			setaParametros('ATENDA','',nrdconta,flgcadas); 	
			direcionaTela('ATENDA','no');
		}
	}
}