/*!
 * FONTE        : ppe.js
 * CRIAÇÃO      : Carlos Henrique
 * DATA CRIAÇÃO : 21/12/2015 
 * OBJETIVO     : Biblioteca de funções na rotina COMERCIAL PPE da tela de CONTAS
 * --------------
 * ALTERAÇÕES   : 01/12/2016 - Definir a não obrigatoriedade do PEP (Tiago/Thiago SD532690)
 * --------------
 */

var nrdrowid = ''; // Chave da Tabela Progress
var cdnvlcgo = ''; // Nível do cargo
var cdturnos = ''; // Cód. Turmo 
var nomeForm = 'frmDadosPpe'; // Nome do Formulário
var operacao = '';
var cddrendi = '';
var vlrdrend = '';
var nmdfield = '';
var otrsrend = '';
var flgContinuar = false;     // Controle botao Continuar	
var cTodos_1 = '';
var cRsocupa = '';
var	cDsrelacionamento = '';

var tpexposto        = '';
var cdocpttl         = '';
var cdrelacionamento = '';
var dtinicio         = '';
var dttermino        = '';
var nmempresa        = '';
var nrcnpj_empresa   = '';
var nmpolitico       = '';
var nrcpf_politico   = '';

var flgAlterando = false;
var opcao = '';

function atualizaTipoExposto(tipo) {
	var tipoExposto = tipo.value;
	var divExposto1 = $('#divExposto1','#'+nomeForm);
	var divExposto2 = $('#divExposto2','#'+nomeForm);
	if (tipoExposto == 1) {
		divExposto1.css('display','block');
		divExposto2.css('display','none');
	} else if (tipoExposto == 2) {
		divExposto1.css('display','none');
		divExposto2.css('display','block');
	} else {
		divExposto1.css('display','none');
		divExposto2.css('display','none');
	}	
}

function acessaOpcaoAba(nrOpcoes,id,opcao) {
	// Mostra mensagem de aguardo
	
	showMsgAguardo('Aguarde, carregando ...');
	
	// Atribui cor de destaque para aba da opção
	for (var i = 0; i < nrOpcoes; i++) {
		if (!$('#linkAba' + id)) {
			continue;
		}
		
		if (id == i) { // Atribui estilos para foco da opÃ§Ã£o
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
		url: UrlSite + 'telas/contas/ppe/principal.php',
		data: {
			nrdconta: nrdconta,
			idseqttl: idseqttl,
			flgcadas: flgcadas,
			operacao: operacao,
			redirect: 'html_ajax'
		},		
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','bloqueiaFundo(divRotina)');
		},
		success: function(response) {
			hideMsgAguardo();
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


function controlaOperacao(operacao, flgConcluir) {

	if ( !verificaContadorSelect() ) return false;

	var mensagem = '';
	switch (operacao) {			
		case 'SC' : mensagem = 'Aguarde, abrindo formulário ...'; break;	
		case 'CA' : mensagem = 'Aguarde, abrindo formulário ...'; flgAlterando = true; break;	
		case 'CAE': mensagem = 'Aguarde, abrindo formulário ...'; break;	
		case 'AC' : showConfirmacao('Deseja cancelar operação?','Confirmação - Ayllos','controlaOperacao()','bloqueiaFundo(divRotina)','sim.gif','nao.gif'); return false; break;
		case 'AV' : manterRotina(operacao); return false; break;	
		case 'VA' : manterRotina(operacao); opcao = 'A'; return false; break;
		case 'PPE': manterRotina(operacao); return false; break;
		case 'PPE_ABA': manterRotina(operacao); return false; break;
		case 'PPE_ABA_ABRE': acessaOpcaoAbaDados(3,2,'@'); return false; break;
		default: 
			flgAlterando = false;
			mensagem = 'Aguarde, abrindo formulário ...'; 
			nrdrowid = ''; 
			break;
	}	
	
	
	showMsgAguardo( mensagem );
	
	var tpexposto = $('#tpexposto','#'+nomeForm).val();
	var cdnatopc = $('#cdnatopc','#'+nomeForm).val();
	var cdocpttl = $('#cdocpttl','#'+nomeForm).val();
	var tpcttrab = $('#tpcttrab','#'+nomeForm).val();
	var cdempres = $('#cdempres','#'+nomeForm).val();
	var dsproftl = $('#dsproftl','#'+nomeForm).val();
	
	var dtadmemp = $('#dtadmemp','#'+nomeForm).val();
	var nrcadast = $('#nrcadast','#'+nomeForm).val();
	
	var inpolexp = $('#inpolexp','#'+nomeForm).val();  
	
	
	nrcadast = normalizaNumero(nrcadast);

	inpolexp = normalizaNumero(inpolexp);

	$.ajax({		
		type: 'POST',
		dataType: 'html',
		url: UrlSite + 'telas/contas/ppe/principal.php', 
		data: {
			nrdconta: nrdconta,	idseqttl: idseqttl,	
			operacao: operacao,	nrdrowid: nrdrowid,
			cdnatopc: cdnatopc, cdocpttl: cdocpttl, 
			tpcttrab: tpcttrab, dsproftl: dsproftl, 
			cdnvlcgo: cdnvlcgo,	dtadmemp: dtadmemp,
			nrcadast: nrcadast,	flgcadas: flgcadas,
			inpolexp: inpolexp,
			redirect: 'script_ajax'
		}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError('error','N&atilde;o foi possível concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','bloqueiaFundo(divRotina)');
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
	
//alert('chw operacao manterrotina ppe.js: ' + operacao);
	
	switch (operacao) {	
		case 'AV': mensagem = 'Aguarde, validando ...'; break;
		case 'VA': mensagem = 'Aguarde, alterando ...'; 
				   cTodos_1.habilitaCampo(); 
				   cRsocupa.desabilitaCampo();
				   cDsrelacionamento.desabilitaCampo();
				   
				   flgAlterando = true;
				   
				   return false; break;
		case 'PPE':mensagem = 'Aguarde, validando ...'; break;
		case 'PPE_ABA':mensagem = 'Aguarde, alterando ...'; break;
		default: return false; break;
	}	
	
	showMsgAguardo( mensagem );

	
	tpexposto = $('#tpexposto','#'+nomeForm).val();
		
	cdocpttl = $('#cdocpttl','#'+nomeForm).val();	
	
	inpolexp = $('#inpolexp','#'+nomeForm).val();	
	
	inpolexp = normalizaNumero( inpolexp );
		
	$.ajax({		
		type: 'POST',
		url: UrlSite + 'telas/contas/ppe/manter_rotina.php', 		
		data: {
			nrdconta: nrdconta, idseqttl: idseqttl, operacao: operacao, nrdrowid: nrdrowid,
			cdnatopc: cdnatopc,	cdocpttl: cdocpttl, tpcttrab: tpcttrab, cdempres: cdempres,
			nmextemp: nmextemp, nrcpfemp: nrcpfemp, dsproftl: dsproftl, cdnvlcgo: cdnvlcgo, 
			nrcadast: nrcadast,	dtadmemp: dtadmemp, cepedct1: cepedct1,	endrect1: endrect1, 
			nrendcom: nrendcom,	complcom: complcom,	bairoct1: bairoct1, cidadct1: cidadct1, 
			ufresct1: ufresct1,	cxpotct1: cxpotct1, flgcadas: flgcadas, 
			flgContinuar: flgContinuar, inpolexp: inpolexp,
			redirect: 'script_ajax'
		}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','bloqueiaFundo(divRotina)');
		},
		success: function(response) {
			hideMsgAguardo();
			try {
				eval(response);				
				return false;
			} catch(error) {				
				showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','bloqueiaFundo(divRotina)');
			}
		}				
	});

}

function controlaLayout(operacao) {	

	altura  = '160px';
	largura = '580px';
	divRotina.css('width',largura);	
	$('#divConteudoOpcao').css('height',altura);

    // FIELDSET INF. PROFISSIONAIS
	var rotulos_1 = $('label[for="tpexposto"],label[for="nmpolitico"],label[for="cdrelacionamento"],label[for="nmempresa"],label[for="dtinicio"]','#'+nomeForm );
	var rotulos_2 = $('label[for="nrcpf_politico"]','#'+nomeForm );
	var rotulos_3 = $('label[for="cdocpttl"]','#'+nomeForm );
	
	rotulos_1.css('width','110px');
	rotulos_2.css('width','36px');
	rotulos_3.css('width','60px');

	
	cTodos_1          = $('input,select','#'+nomeForm+' fieldset:eq(0)');
	var cCodigo_1     = $('#cdocpttl','#'+nomeForm );
	
	cRsocupa          = $('#rsocupa','#'+nomeForm );
	cDsrelacionamento = $('#dsrelacionamento','#'+nomeForm );	

	var cInpolexp     = $('#inpolexp','#'+nomeForm );


	cTodos_1.desabilitaCampo();
	
	
//alert('chw opcao ppe.js operacao:' + operacao + ' op:' + opcao + ' inpolexp: ' + cInpolexp.val());

if ((opcao == 'A' || operacao == 'CA' /* || opcao == '' */) && cInpolexp.val() == 1) {	
	cTodos_1.habilitaCampo();	
	flgAlterando = true;	
} else {	
	cTodos_1.desabilitaCampo();
}

	// Campos que ficam SEMPRE desabilitados:
	cRsocupa.desabilitaCampo();
	cDsrelacionamento.desabilitaCampo();
	
	
    controlaPesquisas();
	
    $('#cdocpttl').trigger('change');
	$('#cdrelacionamento').trigger('change');		
	
	layoutPadrao();	

	hideMsgAguardo();
	bloqueiaFundo(divRotina);
	removeOpacidade('divConteudoOpcao');
	highlightObjFocus($('#divConteudoOpcao'));
	controlaFoco(operacao);
	divRotina.centralizaRotinaH();
	
	
	return false;
}

function controlaFoco(operacao) {		
	if (in_array(operacao,[''])) {		
		$('#btAlterar','#divBotoes').focus();
	} else if ( operacao == 'CAE' ) {
		if ((cooperativa == 2 && $('#cdempres','#'+nomeForm).val() == 88) || $('#cdempres','#'+nomeForm).val() == 81) {
			$('#nmextemp','#'+nomeForm ).focus();
		} else {
			$('#dsproftl','#'+nomeForm ).focus();
		}
	} else {		
		$('#cdnatopc','#'+nomeForm ).focus();
	}
	return false;
}

function retornaContaSelect(){
	return contaSelect;
}

function controlaPesquisas() {

	// Variável local para guardar o elemento anterior
	var campoAnterior = '';
	var bo, procedure, titulo, qtReg, filtrosPesq, filtrosDesc, colunas, campoDescricao;
	var camposOrigem = 'cepedct1;endrect1;nrendcom;complcom;cxpotct1;bairoct1;ufresct1;cidadct1';	
	
	bo = 'b1wgen0059.p';
	
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
				
				// Ocupacao
				if ( campoAnterior == 'cdocpttl' ) {
					procedure	= 'busca_ocupacao';
					titulo      = 'Ocupa&ccedil;&atilde;o';
					qtReg		= '30';
					filtrosPesq	= 'Cód. Ocupação;cdocpttl;30px;S;0|Ocupação;rsocupa;200px;S;';
					colunas 	= 'Código;cdocupa;20%;right|Ocupação;dsdocupa;80%;left';
					mostraPesquisa(bo,procedure,titulo,qtReg,filtrosPesq,colunas,divRotina);
					return false;

				// Busca relacionamento
				} else if ( campoAnterior == 'cdrelacionamento' ) {
					procedure	= 'busca_relacionamento';
					titulo      = 'Relacionamento';
					qtReg		= '30';
					filtrosPesq	= 'Cód. relacionamento;cdrelacionamento;30px;S;0|Relacionamento;dsrelacionamento;200px;S;';
					colunas 	= 'Código;codigo;20%;right|Relacionamento;descricao;80%;left';
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
	 
	// Ocupação
	$('#cdocpttl','#'+nomeForm).unbind('change').bind('change',function() {
		titulo      = 'Ocupação';
		procedure   = 'busca_ocupacao';
		filtrosDesc = '';
		buscaDescricao(bo,procedure,titulo,$(this).attr('name'),'rsocupa',$(this).val(),'dsdocupa',filtrosDesc,nomeForm);
		return false;
	});	

	// Relacionamento
	$('#cdrelacionamento','#'+nomeForm).unbind('change').bind('change',function() {
		titulo      = 'Relacionamento';
		procedure   = 'busca_relacionamento';
		filtrosDesc = '';
		buscaDescricao(bo,procedure,titulo,$(this).attr('name'),'dsrelacionamento',$(this).val(),'descricao',filtrosDesc,nomeForm);
		return false;
	});

}


function voltarRotina() {
	encerraRotina(false);
	acessaRotina('CONTATOS','Contatos','contatos_pf');
}

function salvarPpe() {
	
//alert('salvarPpe chw opcao operacao flgAlterando: ' + opcao + operacao + flgAlterando);	
	
	if (validarPpe()) {

		tpexposto        = $('#tpexposto',       '#'+nomeForm).val();		
		cdocpttl         = $('#cdocpttl',        '#'+nomeForm).val();
		cdrelacionamento = $('#cdrelacionamento','#'+nomeForm).val();
		dtinicio         = $('#dtinicio',        '#'+nomeForm).val();
		dttermino        = $('#dttermino',       '#'+nomeForm).val();
		nmempresa        = $('#nmempresa',       '#'+nomeForm).val();
		nrcnpj_empresa   = normalizaNumero($('#nrcnpj_empresa',  '#'+nomeForm).val());
		nmpolitico       = $('#nmpolitico',      '#'+nomeForm).val();
		nrcpf_politico   = normalizaNumero($('#nrcpf_politico',  '#'+nomeForm).val());
				
//alert('chw salvarppe ' + nrdconta + ' seqttl ' + idseqttl + ' tpexposto ' + tpexposto);
			
		$.ajax({		
			type: 'POST',
			url: UrlSite + 'telas/contas/ppe/manter_rotina.php', 		
			data: {
				nrdconta: 		  	nrdconta,
				idseqttl:		  	idseqttl,
				operacao:        	'PPE_ABA', 
				tpexposto: 			tpexposto,
				cdocpttl: 			cdocpttl,
				cdrelacionamento:	cdrelacionamento, 
				dtinicio: 			dtinicio,				
				dttermino: 			dttermino, 	
				nmempresa: 			nmempresa, 
				nrcnpj_empresa: 	nrcnpj_empresa, 
				nmpolitico: 		nmpolitico, 
				nrcpf_politico: 	nrcpf_politico,			
				redirect: 'script_ajax'
			}, 
			error: function(objAjax,responseError,objExcept) {
				hideMsgAguardo();
				showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','bloqueiaFundo(divRotina)');
			},
			success: function(response) {
				hideMsgAguardo();
				try {
					eval(response);		

					if(opcao == 'A' || operacao == 'CA'){ // opcao Alterar ou for operacao CAdastro
						imprimirDeclaracao();
						setTimeout(acessaAbaBens, 5000); // aguardar 5 segundos para a tela nao mudar repentinamente enquanto faz a requisicao de impressao			
					}		
					
					return false;
				} catch(error) {				
					showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','bloqueiaFundo(divRotina)');
				}
			}				
		});	

	    //imprimirDeclaracao();
		//setTimeout(acessaAbaBens, 5000); // aguardar 5 segundos para a tela nao mudar repentinamente enquanto faz a requisicao de impressao

	}
	
}

function acessaAbaBens() {
   acessaOpcaoAbaDados(3,1,'@');
}

function imprimirDeclaracao() {
	dsrelacionamento = $('#dsrelacionamento','#'+nomeForm).val();
	rsocupa          = $('#rsocupa','#'+nomeForm).val();	
	nmextttl          = $('#nmextttl','#'+nomeForm).val();
	nrcpfcgc          = $('#nrcpfcgc','#'+nomeForm).val();
	
	nrdconta         = $('#nrdconta','#'+nomeForm).val();	
	cidade           = $('#cidade','#'+nomeForm).val();

	
	var action    = UrlSite + 'telas/contas/ppe/imprime_declaracao.php';
	var callafter = "hideMsgAguardo();bloqueiaFundo(divRotina);";

	$('#sidlogin','#'+nomeForm).remove();

	$('#'+nomeForm).append('<input type="hidden" id="sidlogin" name="sidlogin" value="' + $('#sidlogin','#frmMenu').val() + '" />');
	$('#'+nomeForm).append('<input type="hidden" id="dsrelacionamento" name="dsrelacionamento" value="' + dsrelacionamento + '" />');
	$('#'+nomeForm).append('<input type="hidden" id="rsocupa" name="rsocupa" value="' + rsocupa + '" />');
	$('#'+nomeForm).append('<input type="hidden" id="nmextttl" name="nmextttl" value="' + nmextttl + '" />');
	$('#'+nomeForm).append('<input type="hidden" id="nrcpfcgc" name="nrcpfcgc" value="' + nrcpfcgc + '" />');
	
	$('#'+nomeForm).append('<input type="hidden" id="nrdconta" name="nrdconta" value="' + nrdconta + '" />');
	$('#'+nomeForm).append('<input type="hidden" id="cidade" name="cidade" value="' + cidade + '" />');

	carregaImpressaoAyllos(nomeForm,action,callafter);

	return false;	
}

function validarPpe() {

	tpexposto        = $('#tpexposto',       '#'+nomeForm).val();
	cdocpttl         = $('#cdocpttl',        '#'+nomeForm).val();
	cdrelacionamento = $('#cdrelacionamento','#'+nomeForm).val();
	dtinicio         = $('#dtinicio',        '#'+nomeForm).val();
	dttermino        = $('#dttermino',       '#'+nomeForm).val();
	nmempresa        = $('#nmempresa',       '#'+nomeForm).val();
	nrcnpj_empresa   = $('#nrcnpj_empresa',  '#'+nomeForm).val();
	nmpolitico       = $('#nmpolitico',      '#'+nomeForm).val();
	nrcpf_politico   = $('#nrcpf_politico',  '#'+nomeForm).val();
	inpolexp         = $('#inpolexp',        '#'+nomeForm).val();
	nmextttl         = $('#nmextttl',        '#'+nomeForm).val();
	rsocupa          = $('#rsocupa',         '#'+nomeForm).val();

// alert(tpexposto + '|' + cdocpttl + '|' +  cdrelacionamento + '|' + dtinicio + '|' + dttermino + '|' + nmempresa 
// + '|' + nrcnpj_empresa + '|' + nmpolitico + '|' + nrcpf_politico + '|' + inpolexp + '|' + nmextttl + '|' + rsocupa);
	
	if (tpexposto == 1) { // exerce/exerceu
	
		nrcnpj_empresa = normalizaNumero(nrcnpj_empresa);
		if (!validaCpfCnpj(nrcnpj_empresa,2)) {
			showError('error','CNPJ inv&aacute;lido.','Alerta - Ayllos','bloqueiaFundo(divRotina,\'nrcnpj_empresa\',\''+nomeForm+'\');');
			return false;
		}
	
		if (trim(cdocpttl) == '' || 
			trim(cdocpttl) == 0  ||
		    trim(dtinicio) == '') {			
			showError('error',"Os campos 'Ocupação' e 'Data de início' devem ser preenchidos",'Alerta - Ayllos','bloqueiaFundo(divRotina)');
			return false;
		}
	} else if (tpexposto == 2) {  // relacionamento
	
		nrcpf_politico = normalizaNumero(nrcpf_politico);
		if (!validaCpfCnpj(nrcpf_politico,1)) {
			showError('error','CPF inv&aacute;lido.','Alerta - Ayllos','bloqueiaFundo(divRotina,\'nrcpf_politico\',\''+nomeForm+'\');');
			return false;
		}

		if (trim(cdocpttl)         == '' || 
		    trim(cdocpttl)         == 0  ||
		    trim(nmpolitico)       == '' || 
			trim(nrcpf_politico)   == '' ||
			trim(cdrelacionamento) == '') {
			showError('error',"Os campos 'Ocupação', 'Nome político', 'CPF' e 'Tipo de relacionamento' devem ser preenchidos",'Alerta - Ayllos','bloqueiaFundo(divRotina)');			
			return false;
		}
	} else {
		if (inpolexp == 1) { // pessoa exposta politicamente
			showError('error',"Escolha uma opção do campo 'Tipo exposto'",'Alerta - Ayllos','bloqueiaFundo(divRotina)');
			return false;
		}
	}	
	
	return true;
}

function proximaRotina () {
	
	hideMsgAguardo();	

	tpexposto        = $('#tpexposto', '#'+nomeForm).val();
	inpolexp         = $('#inpolexp',  '#'+nomeForm).val();
	
	if (inpolexp == 1 && tpexposto == '') { // pessoa exposta politicamente
		showError('error',"Escolha uma opção do campo 'Tipo exposto'",'Alerta - Ayllos','bloqueiaFundo(divRotina)');
		return false;
	}

	if (flgAlterando && 
		inpolexp == 1 && 
		(tpexposto == 1 || tpexposto == 2)) { // Se clicou em alterar...
		showConfirmacao('Deseja confirmar altera&ccedil;&atilde;o?','Confirma&ccedil;&atilde;o - Ayllos',
						'salvarPpe();',
						'function foo() { return false }',
						'sim.gif','nao.gif');
	} else if(opcao == 'A' || operacao == 'CA') {
	    if (inpolexp == 1) {
	        imprimirDeclaracao();
	        setTimeout(acessaAbaBens, 5000); // aguardar 5 segundos para a tela nao mudar repentinamente enquanto faz a requisicao de impressao							
	    } else {
	        acessaAbaBens();
	    }
	} else {
		acessaAbaBens();
	}

}