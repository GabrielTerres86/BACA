/*!
 * FONTE        : prestacoes.js
 * CRIAÇÃO      : André Socoloski - DB1
 * DATA CRIAÇÃO : 29/03/2011
 * OBJETIVO     : Biblioteca de funções na rotina Prestações da tela ATENDA
 * --------------
 * ALTERAÇÕES   :
 * --------------
 * 001: [29/04/2011] Rogerius (DB1): alterado a função controlaLayout() para formata os campos de endereco e contato.
 * 002: [29/04/2011] Rogerius (DB1): alterado a função contIntervis atualizaTela() para que seja colocado os valores nos 3 novos campos do endereco
 * 003: [23/08/2011] Marcelo L. Pereira (GATI): criação de rotinas para pagamento
 * 004: [29/08/2011] Marcelo L. Pereira (GATI): alterando listagem do extrato
 * 005: [22/07/2011] Adicionado funcionalidades de rotina do botão 'Desfazer Efetivação'. ( Marcelo/Gati )
 * 006: [14/06/2012] Jorge Hamaguchi  (CECRED): Alterado funcoes carregarImpresso() e imprimirExtrato(), novo esquema de impressao, retirado campo "redirect" popup
 * 007: [04/07/2012] Nao mostrar a tela de data do extrato no tipo 1 do emprestimo (Gabriel)
 * 008: [14/12/2012] Alterar descricao tipo de emprestimo por Produto (Gabriel).
 * 009: [23/01/2013] Ajustado largura do form frmNovaProp (Daniel).
 * 010: [22/02/2013] Incluir valor parcial do desconto (Gabriel).
 * 011: [25/02/2013] Passar como parametro o numero do contrato para a validacao de pagamentos (Gabriel).
 * 012: [31/05/2013] Incluir /cooperativa/ nas url (Lucas R.)
 * 013: [11/06/2013] 2a. fase projeto Credito (Gabriel).
 * 014: [07/11/2013] Ajuste no valor do campo da diferenca (Gabriel).
 * 015: [20/02/2014] Ajuste para introduzir paginacao em lista de prestacoes. (Jorge).
 * 016: [07/03/2014] Ajuste para carregar os valores nos campos da Multa, Juros de Mora e Total Pagamento. (James)
 * 017: [20/03/2014] Ajuste para passar cddopcao como parametro para principal.php. (James)
 * 018: [23/04/2014] Ajuste para somente liberar a tela de pagamento, quando todas as parcelas estiver carregada. (James)
 * 019: [05/06/2014] Ajuste para permitir o avalista efetuar o pagamento. (James)
 * 020: [26/06/2014] Criação das rotinas para geração do relatorio de antecipação. (Daniel Zimmermann/Odirlei AMcom)
 * 021: [21/07/2014] Incluido mensagem de informacao quando efetuado o pagamento da parcela. (James)
 * 022: [14/08/2014] Ajuste informacoes do avalista, incluso novos campos (Daniel)
 * 023: [26/08/2014] Ajuste informacoes do pagamento de prestacoes confirmaPagamento()(Vanessa)
 * 024: [01/09/2014] Lucas R./Gielow (CECRED) : Ajustes para validar tipo de impressão do tipo 6, Projeto CET.
 * 025: [12/09/2014] Projeto Contratos de Emprestimos: Inclusao da passagem do numero do contrato. (Tiago Castro - RKAM)
 * 026: [30/11/2014] Projeto de consultas automatizadas (Jonata-RKAM)
 * 027: [25/11/2014] Inclusao do campo cdorigem na funcao controlaOperacao. (Jaison)
 * 028: [25/11/2014] Ajuste na funcao mostraDivImpressao para nao remover todo o conteudo da divUsoGenerico e sim apenas os botoes no arquivo impressao.php. (Jaison)
 * 029: [01/12/2014] Incluir as telas das consultas automatizadas (Jonata-RKAM).
 * 030: [14/01/2015] Projeto microcredito (Jonata-RKAM).
 * 031: [30/11/2014] Projeto Transferencia para Prejuizo (Daniel)
 * 032: [08/04/2015] Consultas automatizadas para o limite de credito (Jonata-RKAM)
 * 033: [27/05/2015] Aumento da largura da divRotina e das colunas dos registros na funcao controlaLayout
 *                   e criacao da operacao 'PORTAB_CRED' mostraDivPortabilidade. (Jaison/Diego - SD: 290027)
 * 034: [09/06/2015] Impresao da Revisao dos contratos (Gabriel-RKAM).
 * 035: [24/06/2015] Projeto 215 - Dv 3 (Daniel)
 * 036: [28/08/2015] Chamado 288513 - Inclusao do tipo de risco (Heitor - RKAM)
 * 037: [12/01/2015] Impressao do demonstrativo de empres. pre-aprovado feito no TAA e Int.Bank.(Carlos Rafael Tanholi - Pré-Aprovado fase II).
 * 038: [15/03/2016] Odirlei (AMCOM): Alterado rotina mostraEmail para verificar se deve permitir o envio de email para o comite. PRJ207 - Esteira
 * 039: [27/07/2016] Alterado função controlaFoco(Evandro - RKAM)
 * 040: [22/06/2017] Alterado para mostrar frame de portabilidade independente de ter selecionado um contrato ou não. (Projeto 357 - Reinert)
 * 041: [13/06/2017] Ajuste devido ao aumento do formato para os campos crapass.nrdocptl, crapttl.nrdocttl, 
			         crapcje.nrdoccje, crapcrl.nridenti e crapavt.nrdocava
					 (Adriano - P339).

 */

// Carrega biblioteca javascript referente ao RATING e CONSULTAS AUTOMATIZADAS
$.getScript(UrlSite + "includes/rating/rating.js");
$.getScript(UrlSite + "includes/consultas_automatizadas/protecao_credito.js");
//campo que valida existencia de portabilidade no contrato
var possuiPortabilidade = 'N';

/* Variáveis para impressão */
var idimpres  = 0;
var promsini  = 1;
var flgemail  = false;
var flgimpnp  = '';
var flgimppr  = '';
var cdorigem  = 0;
var qtpromis  = 0;
var nrJanelas = 0;

var nrdlinha = '';
var operacao = '';
var nomeForm = 'frmDadosPrest';
var tabDados = 'tabPrestacao';

var nrctremp  = '';
var inprejuz  = 0;
var operacao  = '';
var cddopcao  = '';
var idseqttl  = 1;
var indarray  = '';
var dtmvtolt  = '';
var nrdrecid  = '';
var tplcremp  = '';
var tpemprst  = 0;
var intpextr  = '';

var flgPagtoAval  = 0;
var nrAvalistas   = 0;
var contAvalistas = 0;
var nrAlienacao   = 0;
var contAlienacao = 0;
var nrIntervis    = 0;
var contIntervis  = 0;
var nrHipotecas   = 0;
var contHipotecas = 0;
var dtpesqui      = '';
var nrparepr	  = 0;
var vlpagpar	  = 0;
var glb_nriniseq  = 1;
var glb_nrregist  = 50;
var idSocio 	  = 0;
var flmail_comite = 0;

var arrayBensAssoc = new Array();
var arrayDadosPortabilidade = new Array();

var valorTotAPagar, valorAtual , valorTotAtual;

var nrctremp1, qtdregis1, nrdconta1, lstdtvcto1, lstdtpgto1, lstparepr1, lstvlrpag1;

// Função para acessar opções da rotina
function acessaOpcaoAba(nrOpcoes,id,opcao,nriniseq, nrregist) {
	
	operacao = "";
	glb_nriniseq = nriniseq;
	glb_nrregist = nrregist;
	
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
		url: UrlSite + 'telas/atenda/prestacoes/cooperativa/principal.php',
		data: {
			nrdconta: nrdconta,
			idseqttl: idseqttl,
			nriniseq: glb_nriniseq,
			nrregist: glb_nrregist,
			operacao: operacao,
			redirect: 'html_ajax'
		},
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError('error','N&atilde;o foi possível concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','bloqueiaFundo(divRotina)');
		},
		success: function(response) {
			if ( response.indexOf('showError("error"') == -1 ) {
				$('#divConteudoOpcao').html(response);
				bloqueiaFundo($('#divRotina'));
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

	var mensagem = '';
	var iddoaval_busca = 0;
	var inpessoa_busca = 0;
	var nrdconta_busca = 0;
	var nrcpfcgc_busca = 0;
	var qtpergun = 0;
	var nrseqrrq = 0;

	if ( in_array(operacao,['']) ) {
		nrctremp = '';
	}

	if ( in_array(operacao,['TC','IMP', 'C_PAG_PREST', 'D_EFETIVA', 'C_TRANSF_PREJU', 'C_DESFAZ_PREJU', 'PORTAB_CRED', 'PORTAB_CRED_C', 'C_LIQ_MESMO_DIA']) ) {

		$('table > tbody > tr', 'div.divRegistros').each( function() {
			if ( $(this).hasClass('corSelecao') ) {

				if (typeof $('#nrctremp', $(this) ).val() != 'undefined'){
					nrctremp = $('#nrctremp', $(this) ).val();
				}
				if (typeof $('#inprejuz', $(this) ).val() != 'undefined'){
					inprejuz = $('#inprejuz', $(this) ).val();
				}
				if (typeof $('#flgimppr', $(this) ).val() != 'undefined'){
					flgimppr = $('#flgimppr', $(this) ).val();
				}
				if (typeof $('#flgimpnp', $(this) ).val() != 'undefined'){
					flgimpnp = $('#flgimpnp', $(this) ).val();
				}
				if (typeof $('#cdorigem', $(this) ).val() != 'undefined'){
					cdorigem = $('#cdorigem', $(this) ).val();
				}
				if (typeof $('#qtpromis', $(this) ).val() != 'undefined'){
					qtpromis = $('#qtpromis', $(this) ).val();
				}
				if (typeof $('#nrdrecid', $(this) ).val() != 'undefined'){
					nrdrecid = $('#nrdrecid', $(this) ).val();
				}

				if (typeof $('#tplcremp', $(this) ).val() != 'undefined'){
					tplcremp = $('#tplcremp', $(this) ).val();
				}

				if (typeof $('#tpemprst', $(this) ).val() != 'undefined'){
					tpemprst = $('#tpemprst', $(this) ).val();
				}
				
				if (typeof $('#dsdavali', $(this) ).val() != 'undefined'){
					flgPagtoAval = ((trim($('#dsdavali',$(this)).val()) == "") ? 0 : 1);					
				}
			}
		});
		if ( nrctremp == '' && operacao != 'PORTAB_CRED') { return false; }
	}

	// C_PAG_PREST
	switch (operacao) {
		case 'IMP' :
			validaImpressao(operacao);
			return false;
			break;
		case 'C_DESCONTO':
			mensagem = 'consultando desconto ...';
			break;
		case 'C_EXTRATO' :
			dtpesqui = $('#dtpesqui' , '#frmDataInicial').val();
			mensagem = 'abrindo extrato ...';
			fechaRotina($('#divUsoGenerico'),$('#divRotina'));
			break;
		case 'C_NOVA_PROP_V' :
			contAvalistas = 0;
			contAlienacao = 0;
			contHipotecas = 0;
			mensagem = 'abrindo consultar ...';
			fechaRotina($('#divUsoGenerico'),$('#divRotina'));
			break;
		case 'C_NOVA_PROP' :
		case 'C_INICIO':
			if(nrdrecid == ''){
				showError('error','N&atilde;o existem informa&ccedil;&otilde;es complementares para este contrato.','Alerta - Ayllos','bloqueiaFundo(divRotina)');
				return false;
			}
			idSocio = 0;
			mensagem = 'abrindo consultar ...';
			operacao = 'C_NOVA_PROP';
			break;
		case 'C_BENS_ASSOC' :
			initArrayBens('C_BENS_ASSOC');
			mostraTabelaBens('BT','C_BENS_ASSOC');
			return false;
 			break;
			
		case 'C_DADOS_AVAL' :
			if ( contAvalistas < nrAvalistas ){
				mensagem = 'abrindo consultar ...';
				cddopcao = 'C';
			}else{
				contAvalistas = 0;
			    controlaOperacao('C_DADOS_PROP');
				return false;
			}		
			break;
		case 'C_DADOS_PROP_PJ' :
			mensagem = 'abrindo consultar ...';
			cddopcao = 'C';
			break;
		case 'C_DADOS_PROP' :			
			if ( inpessoa == 1 ){
				mensagem = 'abrindo consultar ...';
				cddopcao = 'C';
			}else{
				controlaOperacao('C_DADOS_PROP_PJ');
				return false;
			}
			break;
		case 'C_ALIENACAO' :
			if ( contAlienacao < nrAlienacao ){
				mensagem = 'abrindo consultar ...';
			}else{
				contAlienacao = 0;
				controlaOperacao('C_INTEV_ANU');
				return false;
			}
			break;
		case 'C_INTEV_ANU' :
			if ( contIntervis < nrIntervis ){
				mensagem = 'abrindo consultar ...';
			}else{
				contIntervis = 0;
				controlaOperacao('C_PROT_CRED');
				return false;
			}
			break;
		case 'C_HIPOTECA' :
			if ( contHipotecas < nrHipotecas ){
				mensagem = 'abrindo consultar ...';
			}else{
				contHipotecas = 0;
				controlaOperacao('C_PROT_CRED');
				return false;
			}
			break;
		case 'C_PROT_CRED' :
			mensagem = 'abrindo consultar ...';
			break;
		case 'C_PROTECAO_TIT':	
			iddoaval_busca = 0;
			inpessoa_busca = inpessoa;
			nrdconta_busca = nrdconta;
			nrcpfcgc_busca = 0;
			mensagem = 'consultando dados ...';
			break;
		case 'C_PROTECAO_SOC':
		    idSocio = idSocio + 1;
			iddoaval_busca = 0;
			inpessoa_busca = inpessoa;
			nrdconta_busca = nrdconta;
			nrcpfcgc_busca = 0;
			mensagem = 'consultando dados ...';
			break;		
		case 'C_PROTECAO_AVAL':
			iddoaval_busca = contAvalistas;
			inpessoa_busca = arrayAvalistas[contAvalistas - 1]['inpessoa'];
			nrdconta_busca = retiraCaracteres(arrayAvalistas[contAvalistas - 1]['nrctaava'],'0123456789',true);
			nrcpfcgc_busca = arrayAvalistas[contAvalistas - 1]['nrcpfcgc'];		
			mensagem = 'consultando dados ...';	
			break;		
		case 'C_PROTECAO_CONJ':
			iddoaval_busca = 99;
			inpessoa_busca = 1;
			nrdconta_busca = arrayAssociado['nrctacje'];
			nrcpfcgc_busca = arrayAssociado['nrcpfcjg'];		
			mensagem = 'consultando dados ...';	
			break;
		case 'C_BENS_ASSOC' :
			initArrayBens('C_BENS_ASSOC');
			mostraTabelaBens('BT','C_BENS_ASSOC');
			return false;
 			break;
	case 'C_MICRO_PERG':

			if   (arrayProposta['nrseqrrq'] == 0) {
				controlaOperacao('TC');
				return false;
			}
	
			cddopcao  = 'C';
			qtpergun = $("#qtpergun","#frmQuestionario").val();
			nrseqrrq = arrayProposta['nrseqrrq'];			
			mensagem = 'consultando dados ...';	
			break;	
		case 'C_PAG_PREST' : 
			fechaRotina($('#divUsoGenerico'),$('#divRotina'));
			if(tpemprst != 1){
				showError('error','O produto n&atilde;o possui essa op&ccedil;&atilde;o.','Alerta - Ayllos','bloqueiaFundo(divRotina)');
				return false;
			}
			mensagem = 'abrindo pagamento ...';
			break;

		case 'C_PAG_PREST_PREJU':
			
			fechaRotina($('#divUsoGenerico'),$('#divRotina'));
			mensagem = 'abrindo pagamento de prejuizo...';
			
			break;

		case 'D_EFETIVA' :
			mensagem = 'validando informa&ccedil;&otilde;es';
			cddopcao = 'D';
			break;
		case 'E_EFETIVA' :
			showConfirmacao('Confirmar opera&ccedil;&atilde;o?','Confirma&ccedil;&atilde;o - Ayllos','controlaOperacao("TD_EFETIVA");','controlaOperacao("")','sim.gif','nao.gif');
			return false;
			break;
		case 'TD_EFETIVA' :
			mensagem = 'desfazendo efetiva&ccedil;&atilde;o...';
			break;	
		case 'TC' :
			mensagem = 'abrindo consultar...';
			cddopcao = 'C';
			idSocio = 0;
			break;
		case 'C_TRANSF_PREJU' :
			/*if(tpemprst != 1){
				showError('error','O produto n&atilde;o possui essa op&ccedil;&atilde;o.','Alerta - Ayllos','bloqueiaFundo(divRotina)');
				return false;
			}
			*/					
			mensagem = 'Transferindo Contrato para Prejuizo...';
			cddopcao = 'U';
			break;	
		case 'C_DESFAZ_PREJU' :
			if(tpemprst != 1){
				showError('error','O produto n&atilde;o possui essa op&ccedil;&atilde;o.','Alerta - Ayllos','bloqueiaFundo(divRotina)');
				return false;
			}
								
			mensagem = 'Desfazendo Transferencia para Prejuizo...';
			cddopcao = 'Q';
			break;
		case 'PORTAB_CRED' :
			mostraDivPortabilidade(operacao);
			return false;
			break;
		case 'PORTAB_APRV' :
			if ( nrctremp == '' ) { return false; }
			mostraDivPortabilidadeAprovar(operacao);
			return false;
			break;
		case 'PORTAB_EXTR' :
			if ( nrctremp == '' ) { return false; }
			imprimeExtratoPortabilidade();
			return false;
			break;
		case 'PORTAB_CRED_C' :
			var numeroContrato = $("#tabPrestacao table tr.corSelecao").find("input[id='nrctremp']").val();		
			mensagem = "Carregando Consulta de Portabilidade";
			break;
		case 'C_LIQ_MESMO_DIA' :		
			mensagem = 'Efetuando Liquidação do Contrato...';
			cddopcao = 'P'; /* Daniel */
			break;	
			
		default   :
			cddopcao = 'C';
			mensagem = 'abrindo consultar...';
			
			arrayDadosPortabilidade = new Array();			
			break;
	}
	
	if (operacao != 'C_DESCONTO' && operacao != 'C_LIQ_MESMO_DIA') {
		$('.divRegistros').remove();
	}
	
	var inconcje = 0; 
	
	if (typeof arrayProposta != 'undefined') { // Consulta ao conjuge
		if (inpessoa == 1 && arrayRendimento['inconcje'] == 'yes') {
			inconcje = 1;
		}
	}
	
	var dtcnsspc = (typeof arrayProtCred == 'undefined') ? '' : arrayProtCred['dtcnsspc']; 
	
	
	showMsgAguardo('Aguarde, ' + mensagem);
	
	// Carrega conteúdo da opção através do Ajax
	$.ajax({
		type: 'POST',
		dataType: 'html',
		url: UrlSite + 'telas/atenda/prestacoes/cooperativa/principal.php',
		data: {
			nrdconta: nrdconta,
			idseqttl: idseqttl,
			nriniseq: glb_nriniseq,
			nrregist: glb_nrregist,
			operacao: operacao,			
			nrctremp: nrctremp,
			prejuizo: inprejuz,
			dtpesqui: dtpesqui,
			tpemprst: tpemprst,
			nrparepr: nrparepr,
			vlpagpar: vlpagpar,
			inconcje: inconcje,
			dtcnsspc: dtcnsspc,
			idSocio : idSocio,
			iddoaval_busca: iddoaval_busca,
			inpessoa_busca: inpessoa_busca,
			nrdconta_busca: nrdconta_busca,
			nrcpfcgc_busca: nrcpfcgc_busca,
			nrseqrrq : nrseqrrq,
			qtpergun : qtpergun,
			cddopcao: cddopcao,	
			inprodut : 1,
			nrdocmto : nrctremp,
			redirect: 'html_ajax'
		},
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError('error','N&atilde;o foi possível concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','bloqueiaFundo(divRotina)');
		},
		success: function(response) {
		
			if ( response.indexOf('showError("error"') == -1 ) {
				if (operacao == 'C_DESCONTO') {
					eval( response );
					hideMsgAguardo();
					bloqueiaFundo(divRotina);
				} else {
					if (operacao == 'C_LIQ_MESMO_DIA') {
						hideMsgAguardo();
						bloqueiaFundo(divRotina);
						eval( response );
					} else {
						$('#divConteudoOpcao').html(response);
						//consulta campos de portabilidade	
						if (operacao == 'PORTAB_CRED_C') {
							//carrega os campos da tela
							carregaCamposPortabilidade(cdcooper, nrdconta, numeroContrato, 'CONTRATO');       				
						}
					}
				}
			} else {
				eval( response );
				controlaFoco( operacao );
			}
			return false;
		}
	});
}

/*!
 * OBJETIVO : Controlar o layout da tela de acordo com a operação
 *            Algumas formatações CSS que não funcionam, são contornadas por esta função
 * PARÂMETRO: Valores válidos: [C] Consultando [A] Alterando [I] Incluindo
 */
function controlaLayout(operacao) {

	altura  = '230px';
	largura = '740px';

	// Operação consultando
	if ( in_array(operacao,['']) ) {

		var divRegistro = $('div.divRegistros');
		var tabela      = $('table', divRegistro );

		var ordemInicial = new Array();
		ordemInicial = [[0,0]];

		var arrayLargura = new Array();
		arrayLargura[0] = '38px';
		arrayLargura[1] = '38px';
		arrayLargura[2] = '70px';
		arrayLargura[3] = '110px';
		arrayLargura[4] = '74px';
		arrayLargura[5] = '97px';
		arrayLargura[6] = '38px';
		arrayLargura[7] = '85px';
		arrayLargura[8] = '97px';

		var arrayAlinha = new Array();
		arrayAlinha[0] = 'center';
		arrayAlinha[1] = 'center';
		arrayAlinha[2] = 'right';
		arrayAlinha[3] = 'center';
		arrayAlinha[4] = 'right';
		arrayAlinha[5] = 'center';
		arrayAlinha[6] = 'right';
		arrayAlinha[7] = 'right';
		arrayAlinha[8] = 'right';

		tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha, 'controlaOperacao(\'TC\')' );

	} else if ( in_array(operacao,['C_EXTRATO']) ) {

		var divRegistros = $('div.divRegistros');
		var tabela       = $('table', divRegistros );

		altura  = '235px';

		divRegistros.css('height','176px');

		var ordemInicial = new Array();
		ordemInicial = [[0,0]];

		var arrayLargura = new Array();
		var arrayAlinha = new Array();

		if(tpemprst == 1)
		{
			arrayLargura[0] = '65px';
			arrayLargura[1] = '120px';
			arrayLargura[2] = '70px';
			arrayLargura[3] = '70px';
			arrayLargura[4] = '70px';

			arrayAlinha[0] = 'center';
			arrayAlinha[1] = 'left';
			arrayAlinha[2] = 'center';
			arrayAlinha[3] = 'center';
			arrayAlinha[4] = 'right';
			arrayAlinha[5] = 'right';
		}
		else
		{
			arrayLargura[0] = '70px';
			arrayLargura[1] = '180px';
			arrayLargura[2] = '80px';
			arrayLargura[3] = '35px';

			arrayAlinha[0] = 'center';
			arrayAlinha[1] = 'left';
			arrayAlinha[2] = 'center';
			arrayAlinha[3] = 'center';
			arrayAlinha[4] = 'right';
		}

		tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha, '' );

	} else if ( in_array(operacao,['C_PREJU']) ) {

		nomeForm = 'frmPreju';
		altura   = '240px';
		largura  = '485px';
		
		var rRotulos     = $('label[for="dtprejuz"],label[for="vlprejuz"],label[for="slprjori"],label[for="vlrpagos"],label[for="vlsdprej"],label[for="vlttmupr"],label[for="vlpgmupr"]','#'+nomeForm);
		var cTodos       = $('select,input','#'+nomeForm);

		var rRotuloLinha = $('label[for="vlacresc"],label[for="vljraprj"],label[for="vljrmprj"],label[for="vlrabono"],label[for="vlttjmpr"],label[for="vlpgjmpr"],label[for="tpdrisco"]','#'+nomeForm);

		var cTodosMoeda  = $('#vlrabono,#vlprejuz,#vljrmprj,#slprjori,#vljraprj,#vlrpagos,#vlacresc,#vlsdprej,#vlttmupr,#vlpgmupr,#vlttjmpr,#vlpgjmpr','#'+nomeForm);


		

		cTodosMoeda.addClass('moeda');
		cTodos.addClass('campo').css('width','123px');

		rRotulos.addClass('rotulo').css('width','95px');
		rRotuloLinha.addClass('rotulo-linha').css('width','112px');;

		cTodos.desabilitaCampo();

	} else if ( in_array(operacao,['TC']) ) {

		nomeForm = 'frmDadosPrest';
		altura   = '445px';
		largura  = '485px';

		var rRotulos     = $('label[for="nrctremp"],label[for="qtaditiv"],label[for="vlemprst"],label[for="vlsdeved"],label[for="vlpreemp"],label[for="vlprepag"],label[for="vlpreapg"],label[for="dslcremp"],label[for="dsdaval1"],label[for="dsdaval2"],label[for="dsdpagto"],label[for="dsfinemp"],label[for="vlmtapar"],label[for="vlmrapar"],label[for="vltotpag"]','#'+nomeForm); 
		var cTodos       = $('select,input','#'+nomeForm);

		var rRotuloLinha = $('label[for="cdpesqui"],label[for="txmensal"],label[for="txjuremp"],label[for="vljurmes"],label[for="vljuracu"],label[for="dspreapg"],label[for="qtmesdec"]','#'+nomeForm);

		var cPesquisa 	= $('#cdpesqui','#'+nomeForm);
		var rPesquisa   = $('label[for="cdpesqui"]','#'+nomeForm );
		var r_Linha2    = $('label[for="txmensal"],label[for="txjuremp"],label[for="vljurmes"],label[for="vljuracu"],label[for="dspreapg"],label[for="qtmesdec"]','#'+nomeForm );
		var cTodosGr    = $('#dsdaval1,#dsdaval2,#dsdpagto,#dslcremp,#dsfinemp','#'+nomeForm);

		var cMoeda      = $('#vlemprst,#vlsdeved,#vlpreemp,#vlprepag,#vlpreapg,#vljuracu,#vljurmes,#vlmtapar,#vlmrapar,#vltotpag','#'+nomeForm);
		var cContrato   = $('#nrctremp','#'+nomeForm);
		var cTaxaMes	= $('#txmensal','#'+nomeForm);
		var cTaxaJuros  = $('#txjuremp','#'+nomeForm);
		var cMesesDeco  = $('#qtmesdec','#'+nomeForm);
		var cQtAditiv   = $('#qtaditiv','#'+nomeForm);

		cQtAditiv.addClass('inteiro');
		cTaxaMes.addClass('porcento_7');
		cTaxaJuros.addClass('porcento_7');
		cContrato.setMask('INTEGER','zzz.zzz.zz9','.','');
		cMesesDeco.addClass('inteiro');

		cMoeda.addClass('moeda');
		cTodos.addClass('campo').css('width','131px');

		rRotulos.addClass('rotulo').css('width','85px');
		rRotuloLinha.addClass('rotulo-linha').css('width','112px');;

		// Hack IE
		if ( $.browser.msie ) {
			cTodosGr.css({'width':'377px'});
		} else {
			cTodosGr.css({'width':'380px'});
		}

		r_Linha2.css('width','112px');
		rPesquisa.css('width','60px');
		cPesquisa.css({'width':'183px'});

		cTodos.desabilitaCampo();

		//PORTABILIDADE - seta o retorno de pagina para a consulta de portabilidade
		if ( possuiPortabilidade == 'S') {
                    //seta a acao do botao voltar
                    $("#btVoltar", "#divBotoes").unbind('click').bind('click', function() {
                        controlaOperacao('PORTAB_CRED_C');
				return false; //controla a execucao de apenas um evento
                    });                    
		}
		

	} else if (in_array(operacao,['C_NOVA_PROP','C_NOVA_PROP_V']) ) {

		nomeForm = 'frmNovaProp';
		altura   = '300px';
		largura  = '440px';

		inconfir = 1;

		var rRotulos     = $('label[for="nivrisco"],label[for="qtpreemp"],label[for="vlpreemp"],label[for="vlemprst"],label[for="flgpagto"],label[for="tpemprst"],label[for="flgimppr"],label[for="dsctrliq"]','#'+nomeForm );
		var cTodos       = $('select,input'    ,'#'+nomeForm);
		var r_Linha1     = $('label[for="cdlcremp"]','#'+nomeForm );
		var rCet     	 = $('label[for="percetop"]','#'+nomeForm );
		var rDiasUteis   = $('#duteis','#'+nomeForm );
		var r_Linha2     = $('label[for="nivcalcu"],label[for="flgimpnp"],label[for="dtdpagto"],label[for="vlpreemp"]','#'+nomeForm );
		var cCodigo		 = $('#cdfinemp,#idquapro,#cdlcremp','#'+nomeForm);
		var cDescricao   = $('#dsfinemp,#dsquapro,#dslcremp','#'+nomeForm);

		var rNivelRic    = $('label[for="nivrisco"]','#'+nomeForm);
		var rRiscoCalc   = $('label[for="nivcalcu"]','#'+nomeForm);
		var rVlEmpr      = $('label[for="vlemprst"]','#'+nomeForm);
		var rLnCred      = $('label[for="cdlcremp"]','#'+nomeForm);
		var rDsLnCred    = $('label[for="dslcremp"]','#'+nomeForm);
		var rVlPrest     = $('label[for="vlpreemp"]','#'+nomeForm);
		var rFinali      = $('label[for="cdfinemp"]','#'+nomeForm);
		var rDsFinali    = $('label[for="dsfinemp"]','#'+nomeForm);
		var rQtParc      = $('label[for="qtpreemp"]','#'+nomeForm);
		var rQualiParc   = $('label[for="idquapro"]','#'+nomeForm);
		var rDsQualiParc = $('label[for="dsquapro"]','#'+nomeForm);
		var rDebitar     = $('label[for="flgpagto"]','#'+nomeForm);
		var rPercCET	 = $('label[for="percetop"]','#'+nomeForm);
		var rLiberar 	 = $('label[for="qtdialib"]','#'+nomeForm);

		var rDtPgmento   = $('label[for="dtdpagto"]','#'+nomeForm);
		var rProposta    = $('label[for="flgimppr"]','#'+nomeForm);
		var rNtPromis    = $('label[for="flgimpnp"]','#'+nomeForm);
		var rLiquidacoes = $('label[for="dsctrliq"]','#'+nomeForm);
		var rDtLiberar   = $('label[for="dtlibera"]','#'+nomeForm);
		var cNivelRic    = $('#nivrisco','#'+nomeForm);
		var cRiscoCalc   = $('#nivcalcu','#'+nomeForm);
		var cVlEmpr      = $('#vlemprst','#'+nomeForm);
		var cLnCred      = $('#cdlcremp','#'+nomeForm);
		var cDsLnCred    = $('#dslcremp','#'+nomeForm);
		var cVlPrest     = $('#vlpreemp','#'+nomeForm);
		var cFinali      = $('#cdfinemp','#'+nomeForm);
		var cDsFinali    = $('#dsfinemp','#'+nomeForm);
		var cQtParc      = $('#qtpreemp','#'+nomeForm);
		var cQualiParc   = $('#idquapro','#'+nomeForm);
		var cDsQualiParc = $('#dsquapro','#'+nomeForm);
		var cDebitar     = $('#flgpagto','#'+nomeForm);
		var cPercCET	 = $('#percetop','#'+nomeForm);
		var cTipoEmpr 	 = $('#tpemprst','#'+nomeForm);
		var cLiberar 	 = $('#qtdialib','#'+nomeForm);
		var cDtlibera    = $('#dtlibera','#'+nomeForm);
		var cDtPgmento   = $('#dtdpagto','#'+nomeForm);
		var cProposta    = $('#flgimppr','#'+nomeForm);
		var cNtPromis    = $('#flgimpnp','#'+nomeForm);
		var cLiquidacoes = $('#dsctrliq','#'+nomeForm);

		cNivelRic.addClass('rotulo').css('width','90px');
        cRiscoCalc.addClass('').css('width','108px');
        cVlEmpr.addClass('rotulo moeda').css('width','90px');
        cLnCred.css('width','32px').attr('maxlength','3');
        cDsLnCred.css('width','108px');
        cVlPrest.addClass('moeda').css('width','90px');
        cFinali.addClass('rotulo').css('width','32px');
        cDsFinali.css('width','108px');
        cQtParc.addClass('rotulo').css('width','50px').setMask('INTEGER','zz9','','');
        cQualiParc.addClass('rotulo').css('width','32px');
        cDsQualiParc.addClass('').css('width','108');
        cDebitar.addClass('rotulo').css('width','90px');
        cPercCET.addClass('porcento').css('width','45px');
        cTipoEmpr.addClass('rotulo').css('width','90px');
        cLiberar.addClass('rotulo inteito').css('width','45px').attr('maxlength','3');
        cDtlibera.css('width','108px').setMask("DATE","","","divRotina");
		cDtPgmento.css('width','108px').setMask("DATE","","","divRotina");
        cProposta.addClass('rotulo').css('width','108px');
		cNtPromis.addClass('').css('width','108px');
		cLiquidacoes.addClass('rotulo alphanum').css('width','320px');

		rRotulos.addClass('rotulo').css('width','75px');
		rDtLiberar.css('width','305px');


		rLiberar.css('width','137px');
		rProposta.css('width','305px');

		rRiscoCalc.addClass('').css('width','137px');
		rLnCred.addClass('').css('width','82px');
		rFinali.addClass('').css('width','82px');
		rQualiParc.addClass('').css('width','82px');
		rPercCET.addClass('').css('width','177px');
		rDtPgmento.addClass('rotulo').css('width','305px');
		rNtPromis.addClass('rotulo').css('width','305px');
		rDiasUteis.addClass('rotulo-linha');

		tpemprst = arrayProposta['tpemprst'];
		cdtpempr = arrayProposta['cdtpempr'];
		dstpempr = arrayProposta['dstpempr'];
		cdtpempr = cdtpempr.split(",");
		dstpempr = dstpempr.split(",");
		for(x=0;x<cdtpempr.length;x++)
		{
			if(tpemprst == cdtpempr[x])
				cTipoEmpr.append("<option value='"+cdtpempr[x]+"' selected>"+dstpempr[x]+"</option>");
			else
				cTipoEmpr.append("<option value='"+cdtpempr[x]+"'>"+dstpempr[x]+"</option>");
		}

		cTodos.desabilitaCampo();

	} else if (in_array(operacao,['C_COMITE_APROV'])) {

		nomeForm = 'frmComiteAprov';
		altura   = '252px';
		largura  = '442px';

		var cComite = $('#dsobscmt','#'+nomeForm);
		var cObs    = $('#dsobserv','#'+nomeForm);

		var cTodos  = $('select,input'    ,'#'+nomeForm);

		cComite.addClass('alphanum').css({'width':'420px','height':'80px','float':'left','margin':'3px 0px 3px 3px','padding-right':'1px'});
		cObs.addClass('alphanum').css({'width':'420px','height':'80px','float':'left','margin':'3px 0px 3px 3px','padding-right':'1px'});

		cComite.desabilitaCampo();
		cObs.desabilitaCampo();
		cTodos.desabilitaCampo();


	} else if (in_array(operacao,['C_DADOS_PROP'])){

		nomeForm = 'frmDadosProp';
		altura   = '337px';
		largura  = '462px';

		var cTodos    = $('input','#'+nomeForm+' fieldset:eq(0)');

		var rSalario = $('label[for="vlsalari"]','#'+nomeForm );
		var rDemais  = $('label[for="vloutras"]','#'+nomeForm );

		var cSalario = $('#vlsalari','#'+nomeForm);
		var cDemais  = $('#vloutras','#'+nomeForm);

		rSalario.addClass('rotulo').css('width','50');
		rDemais.addClass('').css('width','187');
		cSalario.addClass('rotulo moeda').css('width','90px');
		cDemais.addClass('moeda').css('width','100px');

		// FIELDSET OUTROS RENDIMENTOS
		var rCodigos	= $('label[for="tpdrend1"],label[for="tpdrend2"],label[for="tpdrend3"],label[for="tpdrend4"],label[for="tpdrend5"],label[for="tpdrend6"]','#'+nomeForm );
		var rValores	= $('label[for="vldrend1"],label[for="vldrend2"],label[for="vldrend3"],label[for="vldrend4"],label[for="vldrend5"],label[for="vldrend6"]','#'+nomeForm );

		rCodigos.addClass('rotulo').css('width','50px');
		rValores.addClass('rotulo-linha');

		var cTodos_1    = $('input','#'+nomeForm+' fieldset:eq(1)');
		var cCodigos_1  = $('#tpdrend1,#tpdrend2,#tpdrend3,#tpdrend4,#tpdrend5,#tpdrend6','#'+nomeForm );
		var cDesc_1     = $('#dsdrend1,#dsdrend2,#dsdrend3,#dsdrend4,#dsdrend5,#dsdrend6','#'+nomeForm );
		var cValores_1  = $('#vldrend1,#vldrend2,#vldrend3,#vldrend4,#vldrend5,#vldrend6','#'+nomeForm );

		cCodigos_1.addClass('codigo pesquisa');
		cDesc_1.addClass('descricao').css('width','187px');
		cValores_1.addClass('moeda_6').css('width','100px');

		var cTodos_2   = $('input','#'+nomeForm+' fieldset:eq(2)');
		var rRotulo_2  = $('label[for="vlsalcon"],label[for="flgdocje"]','#'+nomeForm);
		var rLocalTrab = $('label[for="nmextemp"]','#'+nomeForm);
		var rVlAlug    = $('label[for="vlalugue"]','#'+nomeForm);

		var cSalConj   = $('#vlsalcon','#'+nomeForm);
		var cLocalTrab = $('#nmextemp','#'+nomeForm);
		var cCoresp    = $('#flgdocje','#'+nomeForm);
		var cVlAlug    = $('#vlalugue','#'+nomeForm);

		rRotulo_2.addClass('rotulo').css('width','100px');
		rLocalTrab.addClass('').css('width','116px');
		rVlAlug.addClass('').css('width','135px');
		cSalConj.addClass('moeda').css('width','90px');
		cLocalTrab.addClass('').css('width','121px');
		cCoresp.addClass('rotulo').css('width','90px');
		cVlAlug.addClass('moeda').css('width','121px');

		cTodos.desabilitaCampo();
		cTodos_1.desabilitaCampo();
		cTodos_2.desabilitaCampo();

	// * 001: alterado a função controlaLayout() para formata os campos de endereco e contato.
	} else if (in_array(operacao,['C_DADOS_AVAL'])){

		nomeForm = 'frmDadosAval';
		altura   = '407px'; // Daniel 387
		largura  = '498px';

		var cTodos  = $('select,input','#'+nomeForm+' fieldset:eq(0)');

		var rRotulo = $('label[for="qtpromis"],label[for="nmdavali"],label[for="tpdocava"]','#'+nomeForm );

		var rConta  = $('label[for="nrctaava"]','#'+nomeForm );
		var rCpf    = $('label[for="nrcpfcgc"]','#'+nomeForm );
		var rNacio  = $('label[for="dsnacion"]','#'+nomeForm );
		
		var rInpessoa = $('label[for="inpessoa"]','#'+nomeForm ); // Daniel
		var rDtNaci = $('label[for="dtnascto"]','#'+nomeForm ); // Daniel

		var cQntd  = $('#qtpromis','#'+nomeForm);
		var cConta = $('#nrctaava','#'+nomeForm);
		var cCPF   = $('#nrcpfcgc','#'+nomeForm);
		var cNome  = $('#nmdavali','#'+nomeForm);
		var cDoc   = $('#tpdocava','#'+nomeForm);
		var cNrDoc = $('#nrdocava','#'+nomeForm);
		var cNacio = $('#dsnacion','#'+nomeForm);
		
		var cInpessoa =  $('#inpessoa','#'+nomeForm); // Daniel
		var cDspessoa =  $('#dspessoa','#'+nomeForm); // Daniel
		var cDtnascto =  $('#dtnascto','#'+nomeForm); // Daniel

		rRotulo.addClass('rotulo').css('width','40px');
		rConta.css('width','240px');
		rCpf.css('width','45px');
		rNacio.css('width','45px');
		
		rDtNaci.css('width','133px'); // Daniel
		rInpessoa.css('width','40px'); // Daniel

		cQntd.css('width','60px').setMask('INTEGER','zz9','','');
		cConta.addClass('conta pesquisa').css('width','115px');
		cCPF.addClass('cpf').css('width','134px');
		cNome.addClass('alphanum').css('width','255px').attr('maxlength','40');
		cDoc.css('width','50px');
		cNrDoc.addClass('alphanum').css('width','202px').attr('maxlength','40');
		cNacio.addClass('alphanum').css('width','114px').attr('maxlength','13');
		
		cInpessoa.css('width','20px').setMask('INTEGER','9','',''); // Daniel
		cDspessoa.css('width','145px'); // Daniel
		cDtnascto.css('width','70px'); // Daniel

		var cTodos_1    = $('select,input','#'+nomeForm+' fieldset:eq(1)');

		var rRotulo_1 = $('label[for="nmconjug"],label[for="tpdoccjg"]','#'+nomeForm );
		var rCpf_1    = $('label[for="nrcpfcjg"]','#'+nomeForm );

		var cConj    = $('#nmconjug','#'+nomeForm);
		var cCPF_1   = $('#nrcpfcjg','#'+nomeForm);
		var cDoc_1   = $('#tpdoccjg','#'+nomeForm);
		var cNrDoc_1 = $('#nrdoccjg','#'+nomeForm);

		rRotulo_1.addClass('rotulo').css('width','50px');
		rCpf_1.addClass('').css('width','40px');

		cConj.addClass('alphanum').css('width','250px').attr('maxlength','40');
		cCPF_1.addClass('cpf').css('width','134px');
		cDoc_1.css('width','50px');
		cNrDoc_1.addClass('alphanum').css('width','197px').attr('maxlength','40');

		var cTodos_2    = $('select,input','#'+nomeForm+' fieldset:eq(2)');
		var cTodos_3    = $('select,input','#'+nomeForm+' fieldset:eq(3)');

		var rCep	= $('label[for="nrcepend"]','#'+nomeForm);
		var rEnd	= $('label[for="dsendre1"]','#'+nomeForm);
		var rNum	= $('label[for="nrendere"]','#'+nomeForm);
		var rCom	= $('label[for="complend"]','#'+nomeForm);
		var rCax	= $('label[for="nrcxapst"]','#'+nomeForm);
		var rBai	= $('label[for="dsendre2"]','#'+nomeForm);
		var rEst	= $('label[for="cdufresd"]','#'+nomeForm);
		var rCid	= $('label[for="nmcidade"]','#'+nomeForm);

		var rTel	= $('label[for="nrfonres"]','#'+nomeForm);
		var rEma	= $('label[for="dsdemail"]','#'+nomeForm);

		// endereco
		rCep.addClass('rotulo').css('width','55px');
		rEnd.addClass('rotulo-linha').css('width','35px');
		rNum.addClass('rotulo').css('width','55px');
		rCom.addClass('rotulo-linha').css('width','52px');
		rCax.addClass('rotulo').css('width','55px');
		rBai.addClass('rotulo-linha').css('width','52px');
		rEst.addClass('rotulo').css('width','55px');
		rCid.addClass('rotulo-linha').css('width','52px');

		// telefone e email
		rTel.addClass('rotulo-linha');
		rEma.addClass('rotulo').css('width','55px');

		var cCep	= $('#nrcepend','#'+nomeForm);
		var cEnd	= $('#dsendre1','#'+nomeForm);
		var cNum	= $('#nrendere','#'+nomeForm);
		var cCom	= $('#complend','#'+nomeForm);
		var cCax	= $('#nrcxapst','#'+nomeForm);
		var cBai	= $('#dsendre2','#'+nomeForm);
		var cEst	= $('#cdufresd','#'+nomeForm);
		var cCid	= $('#nmcidade','#'+nomeForm);

		var cTel	= $('#nrfonres','#'+nomeForm);
		var cEma	= $('#dsdemail','#'+nomeForm);

		// endereco
		cCep.addClass('cep pesquisa').css('width','65px').attr('maxlength','9');
		cEnd.addClass('alphanum').css('width','300px').attr('maxlength','40');
		cNum.addClass('numerocasa').css('width','65px').attr('maxlength','7');
		cCom.addClass('alphanum').css('width','300px').attr('maxlength','40');
		cCax.addClass('caixapostal').css('width','65px').attr('maxlength','6');
		cBai.addClass('alphanum').css('width','300px').attr('maxlength','40');
		cEst.css('width','65px');
		cCid.addClass('alphanum').css('width','300px').attr('maxlength','25');

		// telefone e email
		cTel.css('width','150px').attr('maxlength','20');
		cEma.css('width','237px').attr('maxlength','30');

		cTodos.desabilitaCampo();
		cTodos_1.desabilitaCampo();
		cTodos_2.desabilitaCampo();
		cTodos_3.desabilitaCampo();

	} else if (in_array(operacao,['C_PROTECAO_TIT','C_PROTECAO_AVAL','C_PROTECAO_CONJ','C_PROTECAO_SOC'])){

		altura   = '430px';
		largura  = '510px';
	
		formata_protecao (operacao, arrayProtCred['nrinfcad'] , arrayProtCred['dsinfcad'] );
		
			
	} else if (in_array(operacao,['C_HIPOTECA'])){

		nomeForm = 'frmHipoteca';
		altura   = '160px';
		largura  = '452px';

		var cTodos  = $('select,input' ,'#'+nomeForm);
		var rRotulo = $('label[for="dscatbem"],label[for="dsbemfin"],label[for="dscorbem"]','#'+nomeForm );
		var rVlMerc = $('label[for="vlmerbem"]','#'+nomeForm );
		var rTitulo = $('#lsbemfin','#'+nomeForm );

		var cCateg  = $('#dscatbem','#'+nomeForm);
		var cVlMerc = $('#vlmerbem','#'+nomeForm);
		var cDesc  	= $('#dsbemfin','#'+nomeForm);
		var cEnd  	= $('#dscorbem','#'+nomeForm);

		rRotulo.addClass('rotulo').css('width','60px');
		rTitulo.addClass('').css({'width':'253px','clear':'both'});
		rVlMerc.addClass('rotulo-linha');

		cCateg.addClass('').css('width','132px');
		cVlMerc.addClass('moeda').css('width','132px');
		cDesc.addClass('alphanum').css('width','370px');
		cEnd.addClass('alphanum').css('width','370px');

		cTodos.desabilitaCampo();


	}else if (in_array(operacao,['C_PROT_CRED'])){

		nomeForm = 'frmOrgProtCred';
		altura   = ( inpessoa == 1 ) ? '310px': '263' ;
		largura  = '485px';

		var cTodos = $('input','#'+nomeForm+' fieldset:eq(0)');
		var rRotulo = $('label[for="dtcnsspc"],label[for="dtoutspc"]','#'+nomeForm );
		var rInfCad = $('label[for="nrinfcad"]','#'+nomeForm );
		var r2Tit = $('label[for="dtoutspc"]','#'+nomeForm );

		var c1Tit     = $('#dtcnsspc','#'+nomeForm);
		var cInfCad   = $('#nrinfcad','#'+nomeForm);
		var cDsInfCad = $('#dsinfcad','#'+nomeForm);
		var c2Tit 	  = $('#dtoutspc','#'+nomeForm);

		rRotulo.addClass('rotulo').css('width','133px');
		rInfCad.addClass('rotulo-linha');

		c1Tit.addClass('data').css('width','65px');
		cInfCad.addClass('codigo').css('width','32px');
		cDsInfCad.addClass('codigo').css('width','125px');
		c2Tit.addClass('data').css('width','65px');

		var cTodos_1  = $('input','#'+nomeForm+' fieldset:eq(1)');
		var rRotulo_1 = $('label[for="dtdrisco"],label[for="vltotsfn"],label[for="dtoutris"]','#'+nomeForm );

		var rQtIF	  = $('label[for="qtifoper"]','#'+nomeForm );
		var rQtOpe	  = $('label[for="qtopescr"]','#'+nomeForm );
		var rVencidas = $('label[for="vlopescr"]','#'+nomeForm );
		var rPrej	  = $('label[for="vlrpreju"]','#'+nomeForm );
		var rEndiv	  = $('label[for="vlsfnout"]','#'+nomeForm );
		var r2Tit_1	  = $('label[for="dtoutris"]','#'+nomeForm );

		var c1Tit_1   = $('#dtdrisco','#'+nomeForm);
		var cQtIF     = $('#qtifoper','#'+nomeForm);
		var cQtOpe    = $('#qtopescr','#'+nomeForm);
		var cEndiv    = $('#vltotsfn','#'+nomeForm);
		var cVenc     = $('#vlopescr','#'+nomeForm);
		var cPrej     = $('#vlrpreju','#'+nomeForm);
		var c2Tit_1   = $('#dtoutris','#'+nomeForm);
		var c2TitEndv = $('#vlsfnout','#'+nomeForm);

		rRotulo_1.addClass('rotulo').css('width','110px');
		rQtIF.css('width','112px');
		rQtOpe.addClass('rotulo-linha');
		rVencidas.addClass('rotulo-linha');
		rPrej.addClass('rotulo-linha');
		rEndiv.css('width','176px');

		c1Tit_1.addClass('').css('width','85px');
		cQtIF.addClass('inteiro').css('width','30px');
		cQtOpe.addClass('inteiro').css('width','30px');
		cEndiv.addClass('moeda').css('width','85px');
		cVenc.addClass('moeda').css('width','85px');
		cPrej.addClass('moeda').css('width','90px');
		c2Tit_1.addClass('').css('width','85px');
		c2TitEndv.addClass('moeda').css('width','90px');

		var cTodos_2  = $('input','#'+nomeForm+' fieldset:eq(2)');
		var rRotulo_2 = $('label[for="nrgarope"],label[for="nrpatlvr"],label[for="nrperger"]','#'+nomeForm );

		var rGarantia = $('label[for="nrgarope"]','#'+nomeForm );
		var rLiquidez = $('label[for="nrliquid"]','#'+nomeForm );
		var rPatriLv  = $('label[for="nrpatlvr"]','#'+nomeForm );
		var rPercep   = $('label[for="nrperger"]','#'+nomeForm );

		var cCodigo   = $('#nrgarope,#nrliquid,#nrpatlvr,#nrperger','#'+nomeForm );

		var cGarantia = $('#dsgarope','#'+nomeForm );
		var cLiquidez = $('#dsliquid','#'+nomeForm );
		var cPatriLv  = $('#dspatlvr','#'+nomeForm );
		var cPercep   = $('#nrperger','#'+nomeForm );
		var cDsPercep = $('#dsperger','#'+nomeForm );
		var lupa 	  = $('#lupanrperger','#'+nomeForm );

		rRotulo_2.addClass('rotulo');
		rLiquidez.addClass('rotulo-linha');
		rPatriLv.css('width','106px');
		rPercep.addClass('rotulo-linha');
		rGarantia.addClass('rotulo-linha');

		cCodigo.addClass('codigo').css('width','32px');
		cGarantia.addClass('descricao').css('width','123px');
		cLiquidez.addClass('descricao').css('width','123px');
		cPatriLv.addClass('descricao').css('width','302px');
		cDsPercep.addClass('descricao').css('width','181px');

		cTodos.desabilitaCampo();
		cTodos_1.desabilitaCampo();
		cTodos_2.desabilitaCampo();

		if ( inpessoa == 1){
			r2Tit.css('display','block');
			c2Tit.css('display','block');

			r2Tit_1.css('display','block');
			c2Tit_1.css('display','block');

			rEndiv.css('display','block');
			c2TitEndv.css('display','block');

			rPercep.css('display','none');
			cPercep.css('display','none');
			lupa.css('display','none');
			cDsPercep.css('display','none');
		}else{
			r2Tit.css('display','none');
			c2Tit.css('display','none');

			r2Tit_1.css('display','none');
			c2Tit_1.css('display','none');

			rEndiv.css('display','none');
			c2TitEndv.css('display','none');

			rPercep.css('display','block');
			cPercep.css('display','block');
			lupa.css('display','block');
			cDsPercep.css('display','block');
		}

	}else if (in_array(operacao,['C_DADOS_PROP_PJ'])){

		nomeForm = 'frmDadosPropPj';
		altura   = '135';
		largura  = '460px';

		var cTodos  = $('input','#'+nomeForm);
		var rRotulo = $('label[for="vlmedfat"],label[for="perfatcl"],label[for="vlalugue"]','#'+nomeForm );
		var rMedia  = $('#vlmedfat2','#'+nomeForm);

		var cCampos = $('#vlmedfat,#perfatcl,#vlalugue','#'+nomeForm );
		var cFatura = $('#vlmedfat','#'+nomeForm );
		var cConFat = $('#perfatcl','#'+nomeForm );
		var cAlugue = $('#vlalugue','#'+nomeForm );

		cFatura.addClass('moeda')
		cConFat.addClass('porcento')
		cAlugue.addClass('moeda')

		rRotulo.addClass('rotulo').css('width','240px');
		rMedia.addClass('rotulo-linha');
		cCampos.css('width','85px');

		cTodos.desabilitaCampo();

	}else if (in_array(operacao,['C_ALIENACAO'])){

		nomeForm = 'frmAlienacao';
		altura   = '215px';
		largura  = '452px';

		var cTodos    = $('select,input','#'+nomeForm);
		var rRotulo   = $('label[for="dscatbem"],label[for="dsbemfin"],label[for="dscorbem"],label[for="ufdplaca"],label[for="nrrenava"],label[for="nrmodbem"]','#'+nomeForm );
		var rNrBem    = $('#lsbemfin','#'+nomeForm);
		var rVlBem    = $('label[for="vlmerbem"]','#'+nomeForm);
		var rTpCHassi = $('label[for="tpchassi"]','#'+nomeForm);
		var rLinha    = $('label[for="dschassi"],label[for="uflicenc"],label[for="nrcpfbem"]','#'+nomeForm);
		var rAnoFab   = $('label[for="nranobem"]','#'+nomeForm);

		var cCateg	   = $('#dscatbem','#'+nomeForm);
		var cVlMercad  = $('#vlmerbem','#'+nomeForm);
		var cDesc 	   = $('#dsbemfin','#'+nomeForm);
		var cTpChassi  = $('#tpchassi','#'+nomeForm);
		var cCor 	   = $('#dscorbem','#'+nomeForm);
		var cChassi    = $('#dschassi','#'+nomeForm);
		var cUfPLaca   = $('#ufdplaca','#'+nomeForm);
		var cNrPlaca   = $('#nrdplaca','#'+nomeForm);
		var cUfLicenc  = $('#uflicenc','#'+nomeForm);
		var cRenavan   = $('#nrrenava','#'+nomeForm);
		var cAnoFab	   = $('#nranobem','#'+nomeForm);
		var cAnoMod	   = $('#nrmodbem','#'+nomeForm);
		var cCPF	   = $('#nrcpfbem','#'+nomeForm);

		rRotulo.addClass('rotulo').css('width','67px');
		rNrBem.css('width','245px');
		rVlBem.css('width','140px');
		rTpCHassi.addClass('rotulo-linha');
		rLinha.css('width','103px');
		rAnoFab.addClass('rotulo-linha');

		cCateg.addClass('').css('width','146px');
		cVlMercad.addClass('moeda').css('width','87px');
		cDesc.addClass('').css('width','215px');
		cTpChassi.addClass('').css('width','87px');
		cCor.addClass('').css('width','376px');
		cChassi.addClass('').css('width','162px');
		cUfPLaca.addClass('').css('width','35px');
		cNrPlaca.addClass('placa').css('width','70px');
		cUfLicenc.addClass('').css('width','45px');
		cRenavan.addClass('renavan').css('width','108px');
		cAnoFab.addClass('').css('width','60px');
		cAnoMod.addClass('').css('width','108px');
		cCPF.addClass('cpf').css('width','162px');

		if ( operacao == 'C_ALIENACAO'){
			cTodos.desabilitaCampo();
		}
	//* 001: alterado a função controlaLayout() para formata os campos de endereco e contato.
	}else if (in_array(operacao,['C_INTEV_ANU'])){

		nomeForm = 'frmIntevAnuente';
		altura   = '387px';
		largura  = '498px';

		var cTodos    = $('input,select','#'+nomeForm+' fieldset:eq(0)');

		var rRotulo = $('label[for="nrctaava"],label[for="nmdavali"],label[for="tpdocava"]','#'+nomeForm );

		var rCpf    = $('label[for="nrcpfcgc"]','#'+nomeForm );
		var rNacio  = $('label[for="dsnacion"]','#'+nomeForm );

		var cConta = $('#nrctaava','#'+nomeForm);
		var cCPF   = $('#nrcpfcgc','#'+nomeForm);
		var cNome  = $('#nmdavali','#'+nomeForm);
		var cDoc   = $('#tpdocava','#'+nomeForm);
		var cNrDoc = $('#nrdocava','#'+nomeForm);
		var cNacio = $('#dsnacion','#'+nomeForm);

		rRotulo.addClass('rotulo').css('width','40px');
		rCpf.css('width','45px');
		rNacio.css('width','45px');

		cConta.addClass('conta pesquisa').css('width','115px');
		cCPF.addClass('cpf').css('width','134px');
		cNome.addClass('alphanum').css('width','255px').attr('maxlength','40');
		cDoc.css('width','50px');
		cNrDoc.addClass('alphanum').css('width','202px').attr('maxlength','40');
		cNacio.addClass('pesquisa alphanum').css('width','114px').attr('maxlength','13');

		var cTodos_1    = $('input,select','#'+nomeForm+' fieldset:eq(1)');

		var rRotulo_1 = $('label[for="nmconjug"],label[for="tpdoccjg"]','#'+nomeForm );
		var rCpf_1    = $('label[for="nrcpfcjg"]','#'+nomeForm );

		var cConj    = $('#nmconjug','#'+nomeForm);
		var cCPF_1   = $('#nrcpfcjg','#'+nomeForm);
		var cDoc_1   = $('#tpdoccjg','#'+nomeForm);
		var cNrDoc_1 = $('#nrdoccjg','#'+nomeForm);

		rRotulo_1.addClass('rotulo').css('width','50px');
		rCpf_1.addClass('').css('width','40px');

		cConj.addClass('alphanum').css('width','250px').attr('maxlength','40');
		cCPF_1.addClass('cpf').css('width','134px');
		cDoc_1.css('width','50px');
		cNrDoc_1.addClass('alphanum').css('width','197px').attr('maxlength','40');

		var cTodos_2    = $('input, select','#'+nomeForm+' fieldset:eq(2)');
		var cTodos_3    = $('input','#'+nomeForm+' fieldset:eq(3)');

		var rCep	= $('label[for="nrcepend"]','#'+nomeForm);
		var rEnd	= $('label[for="dsendre1"]','#'+nomeForm);
		var rNum	= $('label[for="nrendere"]','#'+nomeForm);
		var rCom	= $('label[for="complend"]','#'+nomeForm);
		var rCax	= $('label[for="nrcxapst"]','#'+nomeForm);
		var rBai	= $('label[for="dsendre2"]','#'+nomeForm);
		var rEst	= $('label[for="cdufresd"]','#'+nomeForm);
		var rCid	= $('label[for="nmcidade"]','#'+nomeForm);

		var rTel	= $('label[for="nrfonres"]','#'+nomeForm);
		var rEma	= $('label[for="dsdemail"]','#'+nomeForm);

		// endereco
		rCep.addClass('rotulo').css('width','50px');
		rEnd.addClass('rotulo-linha').css('width','35px');
		rNum.addClass('rotulo').css('width','50px');
		rCom.addClass('rotulo-linha').css('width','52px');
		rCax.addClass('rotulo').css('width','50px');
		rBai.addClass('rotulo-linha').css('width','52px');
		rEst.addClass('rotulo').css('width','50px');
		rCid.addClass('rotulo-linha').css('width','52px');

		// telefone e email
		rTel.addClass('rotulo-linha');
		rEma.addClass('rotulo').css('width','55px');

		var cCep	= $('#nrcepend','#'+nomeForm);
		var cEnd	= $('#dsendre1','#'+nomeForm);
		var cNum	= $('#nrendere','#'+nomeForm);
		var cCom	= $('#complend','#'+nomeForm);
		var cCax	= $('#nrcxapst','#'+nomeForm);
		var cBai	= $('#dsendre2','#'+nomeForm);
		var cEst	= $('#cdufresd','#'+nomeForm);
		var cCid	= $('#nmcidade','#'+nomeForm);

		var cTel	= $('#nrfonres','#'+nomeForm);
		var cEma	= $('#dsdemail','#'+nomeForm);

		// endereco
		cCep.addClass('cep pesquisa').css('width','65px').attr('maxlength','9');
		cEnd.addClass('alphanum').css('width','300px').attr('maxlength','40');
		cNum.addClass('numerocasa').css('width','65px').attr('maxlength','7');
		cCom.addClass('alphanum').css('width','300px').attr('maxlength','40');
		cCax.addClass('caixapostal').css('width','65px').attr('maxlength','6');
		cBai.addClass('alphanum').css('width','300px').attr('maxlength','40');
		cEst.css('width','65px');
		cCid.addClass('alphanum').css('width','300px').attr('maxlength','25');

		// telefone e email
		cTel.css('width','150px').attr('maxlength','20');
		cEma.css('width','237px').attr('maxlength','30');

		cTodos.desabilitaCampo();
		cTodos_1.desabilitaCampo();
		cTodos_2.desabilitaCampo();
		cTodos_3.desabilitaCampo();

	}else if (in_array(operacao,['C_PAG_PREST_PREJU'])){

		nomeForm = 'frmVlParcPreju';
		altura   = '210px';
		largura  = '260px';
		var cAbono  = $('#vlabono','#'+nomeForm);
		var cPagto = $('#vlpagto','#'+nomeForm);
		
	}else if (in_array(operacao,['C_PAG_PREST'])){

		nomeForm = 'frmVlParc';
		altura   = '295px';
		largura  = '780px';

		var rTotAtual  = $('label[for="totatual"]','#'+nomeForm );
		var cTotAtual  = $('#totatual','#'+nomeForm);
		var rTotPagmto = $('label[for="totpagto"]','#'+nomeForm );
		var cTotPagmto = $('#totpagto','#'+nomeForm);
		var rVldifpar  = $('label[for="vldifpar"]','#'+nomeForm );
		var cVldifpar  = $('#vldifpar','#'+nomeForm);		
		var rVlpagmto  = $('label[for="vlpagmto"]','#frmVlPagar');
		var cVlpagmto  = $('#vlpagmto','#frmVlPagar');
		
		var rPagtaval  = $('label[for="pagtaval"]','#'+nomeForm);
		var cPagtaval  = $('#pagtaval','#'+nomeForm);
		
		rTotAtual.addClass('rotulo').css({'width':'110px','padding-top':'3px','padding-bottom':'3px'  });
		rVlpagmto.addClass('rotulo').css({'width':'80px','padding-top':'3px','padding-bottom':'3px'});

		if ( $.browser.msie ) {
			rTotPagmto.addClass('rotulo').css( {'width':'80px' , 'margin-left':'385px' } );
			rVldifpar.addClass('rotulo').css({'width':'70px','padding-bottom':'5px' , 'margin-left':'587px' });
		    cTotAtual.addClass('campo').css({'width':'70px','padding-top':'3px','padding-bottom':'3px'   });
			cVlpagmto.addClass('campo').css({'width':'70px','margin-right':'10px'});
			cTotPagmto.addClass('campo').css({'width':'70px','padding-top':'3px','padding-bottom':'3px' , 'margin-left':'09px'  });
			cVldifpar.addClass('campo').css({'width':'70px','margin-left':'0px'});
		} else{
			rTotPagmto.addClass('rotulo').css( {'width':'80px' , 'margin-left':'392px' } );
			rVldifpar.addClass('rotulo').css({'width':'70px','padding-bottom':'5px' , 'margin-left':'600px' });
			cTotAtual.addClass('campo').css({'width':'70px','padding-top':'3px','padding-bottom':'3px', 'margin-right':'25px'});
			cVlpagmto.addClass('campo').css({'width':'70px','margin-right':'10px'});
			cTotPagmto.addClass('campo').css({'width':'70px','padding-top':'3px','padding-bottom':'3px', 'margin-right':'25px'});
			cVldifpar.addClass('campo').css({'width':'70px','margin-right':'10px'});
		}

		cTotPagmto.addClass('rotulo moeda').desabilitaCampo();
		cVldifpar.addClass('rotulo moeda').desabilitaCampo();
		cTotAtual.addClass('rotulo moeda').desabilitaCampo();;
		cVlpagmto.addClass('rotulo moeda');
		
		// Define se mostra o campo "Pagamento Avalista"
		if (flgPagtoAval){
			rPagtaval.show();
			cPagtaval.show();
		}else{						
			rPagtaval.hide();
			cPagtaval.hide();
		}
		
		// Configurações da tabela
		var divTabela    = $('#divTabela');
		var divRegistro = $('div.divRegistros', divTabela );
		var tabela      = $('table', divRegistro );

		divRegistro.css({'height':'160px','border-bottom':'1px dotted #777','padding-bottom':'2px'});
		divTabela.css({'border':'1px solid #777', 'margin-bottom':'3px', 'margin-top':'3px'});

		$('tr.sublinhado > td',divRegistro).css({'text-decoration':'underline'});

		var ordemInicial = new Array();

		var arrayLargura = new Array();
		arrayLargura[0] = '13px';
		arrayLargura[1] = '55px';
		arrayLargura[2] = '55px';
		arrayLargura[3] = '52px';
		arrayLargura[4] = '53px';
		arrayLargura[5] = '43px';
		arrayLargura[6] = '73px';
		arrayLargura[7] = '60px';
		arrayLargura[8] = '45px';
		arrayLargura[9] = '57px';

		var arrayAlinha = new Array();
		arrayAlinha[0] = 'center';
		arrayAlinha[1] = 'center';
		arrayAlinha[2] = 'center';
		arrayAlinha[3] = 'right';
		arrayAlinha[4] = 'right';
		arrayAlinha[5] = 'right';
		arrayAlinha[6] = 'right';
		arrayAlinha[7] = 'right';
		arrayAlinha[8] = 'right';
		arrayAlinha[9] = 'right';
		arrayAlinha[10] = 'center';

		tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha, '' );

		$("th:eq(0)", tabela).removeClass();
		$("th:eq(0)", tabela).unbind('click');

		// Adiciona função que ao selecionar o checkbox header, marca/desmarca todos os checkboxs da tabela

		// Click do chekbox de Todas as parcelas
		 $("input[type=checkbox][name='checkTodos']").unbind('click').bind('click', function (){

			var selec = this.checked;

			$("input[type=checkbox][name='checkParcelas[]']").prop("checked", selec );

			$("input[type=checkbox][name='checkParcelas[]']").each(function() {
				habilitaDesabilitaCampo(this, false);
			});

			recalculaTotal();

			vlpagpar = "";

			$("input[type=text][name='vlpagpar[]']").each(function() {
				nrParcela = this.id.split("_")[1];
				vlPagar = this.value;

				vlpagpar =  (vlpagpar == "") ?  nrParcela + ";" + vlPagar : vlpagpar + "|" + nrParcela + ";" + vlPagar;
			});

			desconto(0);

			// Limpar Valor a pagar
			cVlpagmto.val("");

		});

		// Desabilita o campo 'Valor a antecipar' e define o click do checkbox para habilitar/desabilitar o campo
		$("input[type=text][name='vlpagpar[]']").each(function() {
			nrParcela = this.id.split("_")[1];
			$('#vlpagpar_'+nrParcela , tabela).addClass('rotulo moeda');
			$('#vlpagpar_'+nrParcela , tabela).css({'width':'70px'}).desabilitaCampo();
		});

		$("input[name='checkParcelas[]']",tabela).unbind('click').bind('click', function () {
			nrParcela = this.id.split("_")[1];
			habilitaDesabilitaCampo(this,true);			
			desconto(nrParcela);
			cVlpagmto.val("");
		});

		$("input[type=text][name='vlpagpar[]']").blur(function() {
			recalculaTotal();
			nrParcela = this.id.split("_")[1];

			if (!$(this).prop("disabled")){
				desconto(nrParcela);
			}
			
			cVlpagmto.val("");
		});

		cVlpagmto.unbind('blur').bind('blur', function () {
			atualizaParcelas();
			vlpagpar = "";
			$("input[type=text][name='vlpagpar[]']").each(function() {
				nrParcela = this.id.split("_")[1];
				vlPagar   = this.value;
				vlpagpar  =  (vlpagpar == "") ?  nrParcela + ";" + vlPagar : vlpagpar + "|" + nrParcela + ";" + vlPagar;
			});
		});

		cVlpagmto.unbind('keypress').bind('keypress', function(e) {			
			// Se é a tecla ENTER, 
			if (( e.keyCode == 13 ) || (e.keyCode == 9)){
				desconto(0);
			}
		});
		
		valorTotAPagar  = 0;
		$("input[type=hidden][name='vlpagpar[]']").each(function() {
			// Valor total a pagar
			valorTotAPagar = valorTotAPagar + parseFloat(this.value.replace(",","."));
		});

		valorTotAtual = 0;
		$("input[type=hidden][name='vlatupar[]']").each(function() {
			// Valor total a atual
			valorTotAtual += retiraMascara ( this.value );
		});

		$("input[type=hidden][name='vlmtapar[]']").each(function() {
			// Valor total a atual
			valorTotAtual += retiraMascara ( this.value );
		});

		$("input[type=hidden][name='vlmrapar[]']").each(function() {
			// Valor total a atual
			valorTotAtual +=  retiraMascara ( this.value );
		});

		$('#totatual','#frmVlParc').val(valorTotAtual.toFixed(2).replace(".",",")) ;
		$('#totpagto','#frmVlParc').val('0,00');
		$('#vldifpar','#frmVlParc').val('0,00');
		
	} else  if (in_array(operacao,['C_MICRO_PERG'])) {
			
		nomeForm = 'frmQuestionario';
		altura   = '470px';
		largura  = '500px';
			
		var rTodos = $('label','#'+nomeForm);
		var cTodos = $("select,input",'#'+nomeForm);
		var cDescricao = $('input[name="descricao"]','#'+nomeForm);
		var cInteiros  = $('input[name="inteiro"]',"#"+nomeForm);
		
		rTodos.addClass('rotulo-linha').css('width','55%');
		cTodos.addClass('campo').css({'width':'40%','margin-left':'10px'});
		cDescricao.attr('maxlength','50');
		cInteiros.addClass('campo inteiro').css({'text-align':'right'}).setMask('INTEGER','zzz.zz9','.','');
		
		cTodos.desabilitaCampo();
	
	} else  if (in_array(operacao,['PORTAB_CRED_C'])) {
	
		nomeForm = 'frmPortabilidadeCredito';            
		largura = '465px';            
		altura  = '235px';
		
		/* habilita nr.portabilidade e situacao */
		$('label[for="nrunico_portabilidade"]','#frmPortabilidadeCredito').show();
		$('#nrunico_portabilidade','#frmPortabilidadeCredito').show();
		$('label[for="dssit_portabilidade"]','#frmPortabilidadeCredito').show();
		$('#dssit_portabilidade','#frmPortabilidadeCredito').show();
				
		//formata o campo CNPJ IF Credora
		$("#nrcnpjbase_if_origem", "#frmPortabilidadeCredito").addClass('campoTelaSemBorda').attr('disabled', 'disabled');
		//formata o nome da instituicao
		$("#nmif_origem", "#frmPortabilidadeCredito").addClass('campoTelaSemBorda').attr('disabled', 'disabled');
		//formata o campo de numero de contrato
		$("#nrcontrato_if_origem", "#frmPortabilidadeCredito").addClass('campoTelaSemBorda').attr('disabled', 'disabled');
		//formata o campo de modalidade
		$("#cdmodali_portabilidade", "#frmPortabilidadeCredito").addClass('campoTelaSemBorda').attr('disabled', 'disabled');
		//formata o campo de numero unico portabilidade
		$("#nrunico_portabilidade", "#frmPortabilidadeCredito").addClass('campoTelaSemBorda').attr('disabled', 'disabled');
		//formata o campo situacao da portabilidade
		$("#dssit_portabilidade", "#frmPortabilidadeCredito").addClass('campoTelaSemBorda').attr('disabled', 'disabled');
		//seta a acao do botao continuar
		$("#btSalvar", "#divBotoesFormPortabilidade").unbind('click').bind('click', function(){
			controlaOperacao('TC');
		});			
		//seta a acao do botao voltar na tela de Portabilidade (Prestacoes)
		$("#btVoltar", "#divBotoesFormPortabilidade").unbind('click').bind('click', function(){
			controlaOperacao('');
		});		
		
	}

	divRotina.css('width',largura);
	$('#divConteudoOpcao').css({'height':altura,'width':largura});

	layoutPadrao();
	
	/* Na tela de pagamento das parcelas, nao podemos disparar o evento onblur */
	if (nomeForm != 'frmVlParc'){
		$('input','#'+nomeForm).trigger('blur');	
	}

	hideMsgAguardo();
	bloqueiaFundo(divRotina);
	removeOpacidade('divConteudoOpcao');
	divRotina.centralizaRotinaH();
	controlaFoco(operacao);
	return false;
}

//Função para controle de navegação
function controlaFoco() {
    $('#divConteudoOpcao').each(function () {
        $(this).find("#divBotoes > a").addClass("FluxoNavega");
        $(this).find("#divBotoes > a").first().addClass("FirstInputModal").focus();
        $(this).find("#divBotoes > a").last().addClass("LastInputModal");
    });

    //Se estiver com foco na classe FluxoNavega
    $(".FluxoNavega").focus(function () {
        $(this).bind('keydown', function (e) {
            if (e.keyCode == 27) {
                fechaRotina($('#divUsoGenerico'), divRotina).click();
                fechaRotina($('#divRotina')).click();
                encerraRotina().click();
            }
        });
    });

    //Se estiver com foco na classe LastInputModal
    $(".LastInputModal").focus(function () {
        var pressedShift = false;

        $(this).bind('keyup', function (e) {
            if (e.keyCode == 16) {
                pressedShift = false;//Quando tecla shift for solta passa valor false 
            }
        })

        $(this).bind('keydown', function (e) {
            e.stopPropagation();
            e.preventDefault();

            if (e.keyCode == 13) {
                $(".LastInputModal").click();
            }
            if (e.keyCode == 16) {
                pressedShift = true;//Quando tecla shift for pressionada passa valor true 
            }
            if ((e.keyCode == 9) && pressedShift == true) {
                return setFocusCampo($(target), e, false, 0);
            }
            else if (e.keyCode == 9) {
                $(".FirstInputModal").focus();
            }
        });
    });

    $(".FirstInputModal").focus();
}

function atualizaTela(){

	if (in_array(operacao,['TC'])){

		$('#nrctremp','#frmDadosPrest').val( arrayRegistros['nrctremp'] );
		$('#cdpesqui','#frmDadosPrest').val( arrayRegistros['cdpesqui'] );
		$('#qtaditiv','#frmDadosPrest').val( arrayRegistros['qtaditiv'] );
		$('#vlemprst','#frmDadosPrest').val( arrayRegistros['vlemprst'] );
		$('#txmensal','#frmDadosPrest').val( arrayRegistros['txmensal'] );
		$('#txjuremp','#frmDadosPrest').val( arrayRegistros['txjuremp'] );
		$('#vlsdeved','#frmDadosPrest').val( arrayRegistros['vlsdeved'] );
		$('#vljurmes','#frmDadosPrest').val( arrayRegistros['vljurmes'] );
		$('#vlpreemp','#frmDadosPrest').val( arrayRegistros['vlpreemp'] );
		$('#vljuracu','#frmDadosPrest').val( arrayRegistros['vljuracu'] );
		$('#vlprepag','#frmDadosPrest').val( arrayRegistros['vlprepag'] );
		$('#dspreapg','#frmDadosPrest').val( arrayRegistros['dspreapg'] );
		$('#vlpreapg','#frmDadosPrest').val( arrayRegistros['vlpreapg'] );
		$('#qtmesdec','#frmDadosPrest').val( arrayRegistros['qtmesdec'] );
		$('#dslcremp','#frmDadosPrest').val( arrayRegistros['dslcremp'] );
		$('#dsfinemp','#frmDadosPrest').val( arrayRegistros['dsfinemp'] );
		$('#dsdaval1','#frmDadosPrest').val( arrayRegistros['dsdaval1'] );
		$('#dsdaval2','#frmDadosPrest').val( arrayRegistros['dsdaval2'] );
		$('#dsdpagto','#frmDadosPrest').val( arrayRegistros['dsdpagto'] );
		$('#vlmtapar','#frmDadosPrest').val( arrayRegistros['vlmtapar'] );
		$('#vlmrapar','#frmDadosPrest').val( arrayRegistros['vlmrapar'] );
		$('#vltotpag','#frmDadosPrest').val( arrayRegistros['vltotpag'] );

	}else if (in_array(operacao,['C_PREJU'])){

		$('#dtprejuz','#frmPreju').val( arrayRegistros['dtprejuz'] );
		$('#vlrabono','#frmPreju').val( arrayRegistros['vlrabono'] );
		$('#vlprejuz','#frmPreju').val( arrayRegistros['vlprejuz'] );
		$('#vljrmprj','#frmPreju').val( arrayRegistros['vljrmprj'] );
		$('#slprjori','#frmPreju').val( arrayRegistros['slprjori'] );
		$('#vljraprj','#frmPreju').val( arrayRegistros['vljraprj'] );
		$('#vlrpagos','#frmPreju').val( arrayRegistros['vlrpagos'] );
		$('#vlacresc','#frmPreju').val( arrayRegistros['vlacresc'] );
		$('#vlsdprej','#frmPreju').val( arrayRegistros['vlsdprej'] );
		$('#qtdiaatr','#frmPreju').val( arrayRegistros['qtdiaatr'] );
		
		/* Daniel */
		$('#vlttmupr','#frmPreju').val( arrayRegistros['vlttmupr'] );
		$('#vlttjmpr','#frmPreju').val( arrayRegistros['vlttjmpr'] );
		$('#vlpgmupr','#frmPreju').val( arrayRegistros['vlpgmupr'] );
		$('#vlpgjmpr','#frmPreju').val( arrayRegistros['vlpgjmpr'] );

		// Tipo de risco
		$('#tpdrisco','#frmPreju').val( utf8_decode(arrayRegistros['tpdrisco']) );

		/* Novo campo*/
		//$('#vlsdprej','#frmPreju').val( arrayRegistros['vlsdpjtl'] );
		
	}else if (in_array(operacao,['C_NOVA_PROP','C_NOVA_PROP_V'])){

		$('#nivrisco','#frmNovaProp').val( arrayProposta['nivrisco'] );
		$('#nivcalcu','#frmNovaProp').val( arrayProposta['nivcalcu'] );
		$('#vlemprst','#frmNovaProp').val( arrayProposta['vlemprst'] );
		$('#cdlcremp','#frmNovaProp').val( arrayProposta['cdlcremp'] );
		$('#vlpreemp','#frmNovaProp').val( arrayProposta['vlpreemp'] );
		$('#cdfinemp','#frmNovaProp').val( arrayProposta['cdfinemp'] );
		$('#qtpreemp','#frmNovaProp').val( arrayProposta['qtpreemp'] );
		$('#idquapro','#frmNovaProp').val( arrayProposta['idquapro'] );
		$('#flgpagto','#frmNovaProp').val( arrayProposta['flgpagto'] );
		$('#percetop','#frmNovaProp').val( arrayProposta['percetop'] );
		$('#qtdialib','#frmNovaProp').val( arrayProposta['qtdialib'] );
		$('#dtdpagto','#frmNovaProp').val( arrayProposta['dtdpagto'] );
		$('#flgimppr','#frmNovaProp').val( arrayProposta['flgimppr'] );
		$('#flgimpnp','#frmNovaProp').val( arrayProposta['flgimpnp'] );
		$('#dsctrliq','#frmNovaProp').val( arrayProposta['dsctrliq'] );
		$('#dsfinemp','#frmNovaProp').val( arrayProposta['dsfinemp'] );
		$('#dtlibera','#frmNovaProp').val( arrayProposta['dtlibera'] );
		$('#tpemprst','#frmNovaProp').val( arrayProposta['tpemprst'] );
		$('#dslcremp','#frmNovaProp').val( arrayProposta['dslcremp'] );
		$('#dsquapro','#frmNovaProp').val( arrayProposta['dsquapro'] );

	} else if (in_array(operacao,['C_COMITE_APROV'])){

		$('#dsobscmt','#frmComiteAprov').html( arrayProposta['dsobscmt'] );
		$('#dsobserv','#frmComiteAprov').html( arrayProposta['dsobserv'] );

	} else if (in_array(operacao,['C_DADOS_PROP_PJ'])){

		$('#vlmedfat','#frmDadosPropPj').val( arrayRendimento['vlmedfat'] );
		$('#perfatcl','#frmDadosPropPj').val( arrayRendimento['perfatcl'] );
		$('#vlalugue','#frmDadosPropPj').val( arrayRendimento['vlalugue'] );

	} else if (in_array(operacao,['C_DADOS_PROP'])){

		$('#vlsalari','#frmDadosProp').val( arrayRendimento['vlsalari'] );
		$('#vloutras','#frmDadosProp').val( arrayRendimento['vloutras'] );


		for (var i = 1; i <= contRend; i++) {
			$('#tpdrend'+i,'#frmDadosProp').val( arrayRendimento['tpdrend'+i] );
			$('#dsdrend'+i,'#frmDadosProp').val( arrayRendimento['dsdrend'+i] );
			$('#vldrend'+i,'#frmDadosProp').val( arrayRendimento['vldrend'+i] );
		}

		$('#vlsalcon','#frmDadosProp').val( arrayRendimento['vlsalcon'] );
		$('#nmextemp','#frmDadosProp').val( arrayRendimento['nmextemp'] );
		$('#perfatcl','#frmDadosProp').val( arrayRendimento['perfatcl'] );
		$('#vlmedfat','#frmDadosProp').val( arrayRendimento['vlmedfat'] );
		$('#inpessoa','#frmDadosProp').val( arrayRendimento['inpessoa'] );
		$('#flgconju','#frmDadosProp').val( arrayRendimento['flgconju'] );
		$('#nrctacje','#frmDadosProp').val( arrayRendimento['nrctacje'] );
		$('#nrcpfcjg','#frmDadosProp').val( arrayRendimento['nrcpfcjg'] );
		if (arrayRendimento['flgdocje'] == 'yes' ){
			$('#flgYes','#frmDadosProp').prop('checked',true);
		} else {
			$('#flgNo','#frmDadosProp').prop('checked' ,true);
		}
		$('#vlalugue','#frmDadosProp').val( arrayRendimento['vlalugue'] );

	// * 002: alterado a função contIntervis atualizaTela() para que seja colocado os valores nos 3 novos campos do endereco
	}else if (in_array(operacao,['C_DADOS_AVAL'])){

		$('#nrctaava','#frmDadosAval').val( arrayAvalistas[contAvalistas]['nrctaava'] );
		$('#dsnacion','#frmDadosAval').val( arrayAvalistas[contAvalistas]['dsnacion'] );
		$('#tpdocava','#frmDadosAval').val( arrayAvalistas[contAvalistas]['tpdocava'] );
		$('#nmconjug','#frmDadosAval').val( arrayAvalistas[contAvalistas]['nmconjug'] );
		$('#tpdoccjg','#frmDadosAval').val( arrayAvalistas[contAvalistas]['tpdoccjg'] );
		$('#dsendre1','#frmDadosAval').val( arrayAvalistas[contAvalistas]['dsendre1'] );
		$('#nrfonres','#frmDadosAval').val( arrayAvalistas[contAvalistas]['nrfonres'] );
		$('#nmcidade','#frmDadosAval').val( arrayAvalistas[contAvalistas]['nmcidade'] );
		$('#nrcepend','#frmDadosAval').val( arrayAvalistas[contAvalistas]['nrcepend'] );
		$('#vlrenmes','#frmDadosAval').val( arrayAvalistas[contAvalistas]['vlrenmes'] );
		$('#nmdavali','#frmDadosAval').val( arrayAvalistas[contAvalistas]['nmdavali'] );
		$('#nrcpfcgc','#frmDadosAval').val( arrayAvalistas[contAvalistas]['nrcpfcgc'] );
		$('#nrdocava','#frmDadosAval').val( arrayAvalistas[contAvalistas]['nrdocava'] );
		$('#nrcpfcjg','#frmDadosAval').val( arrayAvalistas[contAvalistas]['nrcpfcjg'] );
		$('#nrdoccjg','#frmDadosAval').val( arrayAvalistas[contAvalistas]['nrdoccjg'] );
		$('#dsendre2','#frmDadosAval').val( arrayAvalistas[contAvalistas]['dsendre2'] );
		$('#dsdemail','#frmDadosAval').val( arrayAvalistas[contAvalistas]['dsdemail'] );
		$('#cdufresd','#frmDadosAval').val( arrayAvalistas[contAvalistas]['cdufresd'] );
		$('#vledvmto','#frmDadosAval').val( arrayAvalistas[contAvalistas]['vledvmto'] );
		$('#nrendere','#frmDadosAval').val( arrayAvalistas[contAvalistas]['nrendere'] );
		$('#complend','#frmDadosAval').val( arrayAvalistas[contAvalistas]['complend'] );
		$('#nrcxapst','#frmDadosAval').val( arrayAvalistas[contAvalistas]['nrcxapst'] );
		$('#qtpromis','#frmDadosAval').val( arrayProposta['qtpromis']);
		
		$('#inpessoa','#frmDadosAval').val( arrayAvalistas[contAvalistas]['inpessoa'] ); // Daniel
		$('#dtnascto','#frmDadosAval').val( arrayAvalistas[contAvalistas]['dtnascto'] ); // Daniel
		
		if ( $('#inpessoa','#frmDadosAval').val() == 1 ) {
			$('#dspessoa','#frmDadosAval').val('FISICA');
		}
		
		if ( $('#inpessoa','#frmDadosAval').val() == 2 ) {
			$('#dspessoa','#frmDadosAval').val('JURIDICA');
		}
		
		contAvalistas++;
		
		$('legend:first','#frmDadosAval').html('Dados dos Avalistas/Fiadores ' + contAvalistas);

	} else if (in_array(operacao,['C_ALIENACAO','A_ALIENACAO'])){

		strSelect(arrayAlienacoes[contAlienacao]['dscatbem'], 'dscatbem','frmAlienacao');

		$('#dscatbem','#frmAlienacao').val( arrayAlienacoes[contAlienacao]['dscatbem'] );
		$('#dsbemfin','#frmAlienacao').val( arrayAlienacoes[contAlienacao]['dsbemfin'] );
		$('#dscorbem','#frmAlienacao').val( arrayAlienacoes[contAlienacao]['dscorbem'] );
		$('#dschassi','#frmAlienacao').val( arrayAlienacoes[contAlienacao]['dschassi'] );
		$('#nranobem','#frmAlienacao').val( arrayAlienacoes[contAlienacao]['nranobem'] );
		$('#nrmodbem','#frmAlienacao').val( arrayAlienacoes[contAlienacao]['nrmodbem'] );
		$('#nrdplaca','#frmAlienacao').val( arrayAlienacoes[contAlienacao]['nrdplaca'] );
		$('#nrrenava','#frmAlienacao').val( arrayAlienacoes[contAlienacao]['nrrenava'] );
		$('#tpchassi','#frmAlienacao').val( arrayAlienacoes[contAlienacao]['tpchassi'] );
		$('#ufdplaca','#frmAlienacao').val( arrayAlienacoes[contAlienacao]['ufdplaca'] );
		$('#nrcpfbem','#frmAlienacao').val( arrayAlienacoes[contAlienacao]['nrcpfbem'] );
		$('#dscpfbem','#frmAlienacao').val( arrayAlienacoes[contAlienacao]['dscpfbem'] );
		$('#vlmerbem','#frmAlienacao').val( arrayAlienacoes[contAlienacao]['vlmerbem'] );
		$('#idalibem','#frmAlienacao').val( arrayAlienacoes[contAlienacao]['idalibem'] );

		$('#lsbemfin','#frmAlienacao').html( arrayAlienacoes[contAlienacao]['lsbemfin'] );

		contAlienacao++;

	// * 002: alterado a função contIntervis atualizaTela() para que seja colocado os valores nos 3 novos campos do endereco
	}else if (in_array(operacao,['C_INTEV_ANU','A_INTEV_ANU'])){

		$('#nrctaava','#frmIntevAnuente').val( arrayIntervs[contIntervis]['nrctaava'] );
		$('#dsnacion','#frmIntevAnuente').val( arrayIntervs[contIntervis]['dsnacion'] );
		$('#tpdocava','#frmIntevAnuente').val( arrayIntervs[contIntervis]['tpdocava'] );
		$('#nmconjug','#frmIntevAnuente').val( arrayIntervs[contIntervis]['nmconjug'] );
		$('#tpdoccjg','#frmIntevAnuente').val( arrayIntervs[contIntervis]['tpdoccjg'] );
		$('#dsendre1','#frmIntevAnuente').val( arrayIntervs[contIntervis]['dsendre1'] );
		$('#nrfonres','#frmIntevAnuente').val( arrayIntervs[contIntervis]['nrfonres'] );
		$('#nmcidade','#frmIntevAnuente').val( arrayIntervs[contIntervis]['nmcidade'] );
		$('#nrcepend','#frmIntevAnuente').val( arrayIntervs[contIntervis]['nrcepend'] );
		$('#vlrenmes','#frmIntevAnuente').val( arrayIntervs[contIntervis]['vlrenmes'] );
		$('#nmdavali','#frmIntevAnuente').val( arrayIntervs[contIntervis]['nmdavali'] );
		$('#nrcpfcgc','#frmIntevAnuente').val( arrayIntervs[contIntervis]['nrcpfcgc'] );
		$('#nrdocava','#frmIntevAnuente').val( arrayIntervs[contIntervis]['nrdocava'] );
		$('#nrcpfcjg','#frmIntevAnuente').val( arrayIntervs[contIntervis]['nrcpfcjg'] );
		$('#nrdoccjg','#frmIntevAnuente').val( arrayIntervs[contIntervis]['nrdoccjg'] );
		$('#dsendre2','#frmIntevAnuente').val( arrayIntervs[contIntervis]['dsendre2'] );
		$('#dsdemail','#frmIntevAnuente').val( arrayIntervs[contIntervis]['dsdemail'] );
		$('#cdufresd','#frmIntevAnuente').val( arrayIntervs[contIntervis]['cdufresd'] );
		$('#vledvmto','#frmIntevAnuente').val( arrayIntervs[contIntervis]['vledvmto'] );
		$('#nrendere','#frmIntevAnuente').val( arrayIntervs[contIntervis]['nrendere'] );
		$('#complend','#frmIntevAnuente').val( arrayIntervs[contIntervis]['complend'] );
		$('#nrcxapst','#frmIntevAnuente').val( arrayIntervs[contIntervis]['nrcxapst'] );
		
		contIntervis++;

		$('legend:first','#frmIntevAnuente').html('Dados do Interveniente Anuente ' + contIntervis);

	}else if (in_array(operacao,['C_PROT_CRED','A_PROT_CRED'])){

		$('#nrperger','#frmOrgProtCred').val( arrayProtCred['nrperger'] );
		$('#dsperger','#frmOrgProtCred').val( arrayProtCred['dsperger'] );
		$('#dtcnsspc','#frmOrgProtCred').val( arrayProtCred['dtcnsspc'] );
		$('#nrinfcad','#frmOrgProtCred').val( arrayProtCred['nrinfcad'] );
		$('#dsinfcad','#frmOrgProtCred').val( arrayProtCred['dsinfcad'] );
		$('#dtdrisco','#frmOrgProtCred').val( arrayProtCred['dtdrisco'] );
		$('#vltotsfn','#frmOrgProtCred').val( arrayProtCred['vltotsfn'] );
		$('#qtopescr','#frmOrgProtCred').val( arrayProtCred['qtopescr'] );
		$('#qtifoper','#frmOrgProtCred').val( arrayProtCred['qtifoper'] );
		$('#nrliquid','#frmOrgProtCred').val( arrayProtCred['nrliquid'] );
		$('#dsliquid','#frmOrgProtCred').val( arrayProtCred['dsliquid'] );
		$('#vlopescr','#frmOrgProtCred').val( arrayProtCred['vlopescr'] );
		$('#vlrpreju','#frmOrgProtCred').val( arrayProtCred['vlrpreju'] );
		$('#nrpatlvr','#frmOrgProtCred').val( arrayProtCred['nrpatlvr'] );
		$('#dspatlvr','#frmOrgProtCred').val( arrayProtCred['dspatlvr'] );
		$('#nrgarope','#frmOrgProtCred').val( arrayProtCred['nrgarope'] );
		$('#dsgarope','#frmOrgProtCred').val( arrayProtCred['dsgarope'] );
		$('#dtoutspc','#frmOrgProtCred').val( arrayProtCred['dtoutspc'] );
		$('#dtoutris','#frmOrgProtCred').val( arrayProtCred['dtoutris'] );
		$('#vlsfnout','#frmOrgProtCred').val( arrayProtCred['vlsfnout'] );
		$('#flgcentr','#frmOrgProtCred').val( arrayProtCred['flgcentr'] );
		$('#flgcoout','#frmOrgProtCred').val( arrayProtCred['flgcoout'] );

	}else if (in_array(operacao,['C_HIPOTECA','A_HIPOTECA'])){

		strSelect(arrayHipotecas[contHipotecas]['dscatbem'], 'dscatbem','frmHipoteca');

		$('#lsbemfin','#frmHipoteca').html(arrayHipotecas[contHipotecas]['lsbemfin']);

		$('#dscatbem','#frmHipoteca').val( arrayHipotecas[contHipotecas]['dscatbem'] );
		$('#dsbemfin','#frmHipoteca').val( arrayHipotecas[contHipotecas]['dsbemfin'] );
        $('#dscorbem','#frmHipoteca').val( arrayHipotecas[contHipotecas]['dscorbem'] );
        $('#idseqhip','#frmHipoteca').val( arrayHipotecas[contHipotecas]['idseqhip'] );
        $('#vlmerbem','#frmHipoteca').val( arrayHipotecas[contHipotecas]['vlmerbem'] );

		contHipotecas++;

	}

	return false;

}

function strSelect(str, campo, form){

	var arrayOption = new Array();
	var select      = $('#'+campo,'#'+form);

	arrayOption = str.split(',');

	for ( i in arrayOption){
		select.append('<option value="'+arrayOption[i]+'">'+arrayOption[i]+'</option>');
	}

	return false;

}

function mostraTabelaBens( operacaoBem, operacao ) {

	showMsgAguardo('Aguarde, buscando bens...');

	exibeRotina($('#divUsoGenerico'));

	limpaDivGenerica();

	// Executa script de confirmação através de ajax
	$.ajax({
		type: 'POST',
		dataType: 'html',
		url: UrlSite + 'telas/atenda/prestacoes/cooperativa/bens.php',
		data: {
			operacao: operacao,
			redirect: 'html_ajax'
			},
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError('error','Não foi possível concluir a requisição.','Alerta - Ayllos',"blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
		success: function(response) {
			$('#divUsoGenerico').html(response);
			controlaOperacaoBens(operacaoBem, operacao);
		}
	});
	return false;
}

function mostraTelaPagamentoAvalista() {

	showMsgAguardo('Aguarde, abrindo pagamento avalista...');	
	exibeRotina($('#divUsoGenerico'));	
	limpaDivGenerica();
	
	// Executa script de confirmação através de ajax
	$.ajax({
		type: 'POST',
		dataType: 'html',
		url: UrlSite + 'telas/atenda/prestacoes/cooperativa/pagamento_avalista.php',
		data: {
			nrdconta: nrdconta,
			idseqttl: idseqttl,
			nrctremp: nrctremp,
			redirect: 'html_ajax'
		},
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError('error','Não foi possível concluir a requisição.','Alerta - Ayllos',"blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
		success: function(response) {
			if ( response.indexOf('showError("error"') == -1 ) {
				$('#divUsoGenerico').html(response);				
			} else {
				eval( response );
				controlaFoco( operacao );
			}
		}
	});
	return false;
}

function controlaLayoutPagamentoAvalista(){
	
	$('#divOutrosAvalistas').hide();
	$('#nrseqavl1','#frmDadosPagAval').attr('checked',true);
	
	// Click do chekbox de Todas as parcelas
	$("input[type=checkbox][name='outrosAvalistas']").unbind('click').bind('click', function (){
		if (this.checked){
			$('#divOutrosAvalistas').show();
		}else{
			$('#divOutrosAvalistas').hide();
			$('#nrseqavl1','#frmDadosPagAval').attr('checked',true);
		}
	});
	
	var divRegistro = $('#divSelecaoAvalista');
	var tabela      = $('table',divRegistro);
	var linha       = $('table > tbody > tr', divRegistro);	
	divRegistro.css({'height':'50px'});
	
	var ordemInicial = new Array();
	ordemInicial = [[0,0]];
	
	var arrayLargura = new Array();
	arrayLargura[0] = '25px';
	arrayLargura[1] = '120px';
	
	var arrayAlinha = new Array();
	arrayAlinha[0] = 'left';
	arrayAlinha[1] = 'left';
	arrayAlinha[2] = 'left';
	tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha, '' );
		
	hideMsgAguardo();	
	bloqueiaFundo($('#divUsoGenerico'));
	return false;
}

//Controla as operações da descrição de bens
function controlaOperacaoBens(operacao, operacaoPrinc) {

	var msgOperacao = '';

	switch (operacao) {
		// Mostra a tabela de bens
		case 'BT':
			// Oculto o formulario e mostro a tabela
			msgOperacao = 'abrindo tabela de bens';
			break;
		default:
           	break;
	}
	showMsgAguardo('Aguarde, ' + msgOperacao + ' ...');
	controlaLayoutBens(operacao, operacaoPrinc);
	return false;
}

// Controla o layout da descrição de bens
function controlaLayoutBens( operacao, operacaoPrinc ) {

	$('#divProcBensTabela').css('display','block');
	$('#divProcBensFormulario').css('display','none');

	// Formata o tamanho da tabela
	$('#divProcBensTabela').css({'height':'215px','width':'517px'});

	// Monta Tabela dos Itens
	$('#divProcBensTabela > div > table > tbody').html('');

	for( var i in arrayBensAssoc ) {
		desc = ( arrayBensAssoc[i]['dsrelbem'].length > 16 ) ? arrayBensAssoc[i]['dsrelbem'].substr(0,17)+'...' : arrayBensAssoc[i]['dsrelbem'] ;
		$('#divProcBensTabela > div > table > tbody').append('<tr></tr>');
		$('#divProcBensTabela > div > table > tbody > tr:last-child').append('<td><span>'+arrayBensAssoc[i]['dsrelbem']+'</span>'+ desc+'<input type="hidden" id="indarray" name="indarray" value="'+i+'" /></td>').css({'text-transform':'uppercase'});
		$('#divProcBensTabela > div > table > tbody > tr:last-child').append('<td><span>'+arrayBensAssoc[i]['persemon'].replace(',','.')+'</span>'+number_format(parseFloat(arrayBensAssoc[i]['persemon'].replace(',','.')),2,',','.')+'</td>');
		$('#divProcBensTabela > div > table > tbody > tr:last-child').append('<td>'+arrayBensAssoc[i]['qtprebem']+'</td>');
		$('#divProcBensTabela > div > table > tbody > tr:last-child').append('<td><span>'+arrayBensAssoc[i]['vlprebem'].replace(',','.')+'</span>'+number_format(parseFloat(arrayBensAssoc[i]['vlprebem'].replace(/[.R$ ]*/g,'').replace(',','.')),2,',','.')+'</td>');
		$('#divProcBensTabela > div > table > tbody > tr:last-child').append('<td><span>'+arrayBensAssoc[i]['vlrdobem'].replace(',','.')+'</span>'+number_format(parseFloat(arrayBensAssoc[i]['vlrdobem'].replace(/[.R$ ]*/g,'').replace(',','.')),2,',','.')+'</td>');
	}

	var divRegistro = $('#divProcBensTabela > div.divRegistros');
	var tabela      = $('table', divRegistro );

	divRegistro.css('height','150px');

	var ordemInicial = new Array();
	ordemInicial = [[0,0]];

	var arrayLargura = new Array();
	arrayLargura[0] = '160px';
	arrayLargura[1] = '60px';
	arrayLargura[2] = '60px';
	arrayLargura[3] = '83px';

	var arrayAlinha = new Array();
	arrayAlinha[0] = 'left';
	arrayAlinha[1] = 'right';
	arrayAlinha[2] = 'right';
	arrayAlinha[3] = 'right';
	arrayAlinha[4] = 'right';

	tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha, '' );

	layoutPadrao();
	hideMsgAguardo();
	bloqueiaFundo($('#divUsoGenerico'));
	return false;
}

function initArrayBens(operacao){

	arrayBensAssoc.length = 0;

	if (operacao == 'C_BENS_ASSOC' ){

		for ( i in arrayBensAss ){
			eval('var arrayAux'+i+' = new Object();');
			for ( campo in arrayBensAss[0] ){
				eval('arrayAux'+i+'[\''+campo+'\']= arrayBensAss['+i+'][\''+campo+'\'];');
			}
			eval('arrayBensAssoc['+i+'] = arrayAux'+i+';');
		}

	}

	return false;
}

function fechaBens(){

	if( arrayBensAssoc.length > 0){
		var descBem = arrayBensAssoc[0]['dsrelbem'];
		$('#dsrelbem','#frmDadosProcuradores').val(descBem.toUpperCase());
	}else{
		$('#dsrelbem','#frmDadosProcuradores').val('');
	}
	$('#divProcBensFormulario').remove();
	
	fechaRotina($('#divUsoGenerico'),$('#divRotina'));

	var tplcremp = (typeof arrayProposta == 'undefined') ? 1 : arrayProposta['tplcremp'];
			
	if  (tplcremp == 1) {
		controlaOperacao('C_PROT_CRED');
	}
	else if (tplcremp == 2) {
		controlaOperacao('C_ALIENACAO'); 
	}
	else {
		controlaOperacao('C_HIPOTECA');
	}
	
	
	return false;
}

function limpaDivGenerica(){

	$('#tbbens').remove();
	$('#altera').remove();
	$('#tbfat').remove();
	$('#tbImp').remove();
	$('#tdNP').remove();
	$('#tbfiador').remove();
	$('#tbprestacoes').remove();
	
	$('#tdAntecip').remove(); // Daniel
	
	return false;
}

function mostraExtrato( operacao ) {

	showMsgAguardo('Aguarde, abrindo extrato...');
	exibeRotina($('#divUsoGenerico'));

	tpemprst = arrayRegistros['tpemprst'];

	limpaDivGenerica();

	if  (tpemprst == 1) {
		verificaTipoEmprestimo();
		return;
	}

	// Executa script de confirmação através de ajax
	$.ajax({
		type: 'POST',
		dataType: 'html',
		url: UrlSite + 'telas/atenda/prestacoes/cooperativa/form_extrato_data.php',
		data: {
			operacao: operacao,
			tpemprst: tpemprst,
			redirect: 'html_ajax'
			},
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError('error','Não foi possível concluir a requisição.','Alerta - Ayllos',"blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
		success: function(response) {
			$('#divUsoGenerico').html(response);
			layoutPadrao();
			hideMsgAguardo();
			bloqueiaFundo($('#divUsoGenerico'));
		}
	});

	return false;
}

function validaImpressao( operacao ){

	showMsgAguardo('Aguarde, validando impressão...');
        
	// Executa script de confirmação através de ajax
	$.ajax({
		type: 'POST',
		url: UrlSite + 'telas/atenda/prestacoes/cooperativa/valida_impressao.php',
		data: {
			nrdconta: nrdconta, idseqttl: idseqttl,
			recidepr: nrdrecid, operacao: operacao,
			tplcremp: tplcremp, redirect: 'script_ajax'
		},
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','bloqueiaFundo(divRotina)');
		},
		success: function(response) {
			try {

				if ( response.indexOf('showError("error"') == -1 ) {

					hideMsgAguardo();
					bloqueiaFundo(divRotina);

					eval(response);

				} else {

					hideMsgAguardo();
					eval( response );
				}


			} catch(error) {
				hideMsgAguardo();
				showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','bloqueiaFundo(divRotina)');
			}
		}
	});

	return false;
}

//Função para chamar Confirmação 
function confirmaPagamento() {
	var metodoSim = "verificaAbreTelaPagamentoAvalista();";
	var metodoNao = "hideMsgAguardo(); blockBackground(parseInt($('#divRotina').css('z-index')));";

	parcelasPagar = new Array();
	$("input[type=checkbox][name='checkParcelas[]']").each(function(){
		nrParcela = this.id.split("_")[1];
		parcelasPagar.push(nrParcela);
	});
	
	parcelasPagas = new Array();
	$("input[type=checkbox][name='checkParcelas[]']:checked").each(function(){
		nrParcela = this.id.split("_")[1];
		parcelasPagas.push(nrParcela);
	});
	if (parcelasPagar.length == parcelasPagas.length) {
		showConfirmacao("Confirma liquidação do contrato?","Confirma&ccedil;&atilde;o - Ayllos",metodoSim,metodoNao,"sim.gif","nao.gif");
	}else{
		showConfirmacao("Confirma o pagamento da(s) parcela(s): "+parcelasPagas+"?","Confirma&ccedil;&atilde;o - Ayllos",metodoSim,metodoNao,"sim.gif","nao.gif");
	}
	return false;
}

// Função para verificar se abre a tela de pagamento de avalista
function verificaAbreTelaPagamentoAvalista(){

	var cPagtaval  = $('input:checkbox[name=pagtaval]:checked','#frmVlParc');
	if (cPagtaval.val()){
		mostraTelaPagamentoAvalista();
	}else{
		geraPagamentos();
	}
}

function verificarImpAntecip() {

	// Se há dados de antecipação
	if (qtdregis1 > 0){
		showError("inform",'Pagamento efetuado com sucesso.',"Alerta - Ayllos","showMsgAutorizacaoAntecipacao();");
	} else {
	    showError("inform",'Pagamento efetuado com sucesso.',"Alerta - Ayllos","controlaOperacao('C_PAG_PREST');");
	}
}

function showMsgAutorizacaoAntecipacao(){
	showConfirmacao('Deseja imprimir a autorização para antecipação?','Confirma&ccedil;&atilde;o - Ayllos','realizaImpressao(true);','realizaImpressao(false);','sim.gif','nao.gif');
}

function validaPagamentoPreju(){
	showConfirmacao('Deseja continuar?','Confirma&ccedil;&atilde;o - Ayllos','pagPrestPreju();','','sim.gif','nao.gif');
}

function pagPrestPreju (){
	showMsgAguardo('Aguarde, validando prejuizo...');

	var valordopagto = retiraMascara($($('form#frmVlParcPreju').find('input')[0]).val());
	var valordoabono = retiraMascara($($('form#frmVlParcPreju').find('input')[1]).val());	
	
	// Carrega conteúdo da opção através do Ajax
	$.ajax({
		type: 'POST',
		dataType: 'html',
		url: UrlSite + 'telas/atenda/prestacoes/cooperativa/pagto_prejuizo.php',
		data: {
			nrdconta: nrdconta,
			nrctremp: nrctremp,
			vldabono: valordoabono,
			vlpagmto: valordopagto,
			redirect: 'html_ajax'
		},
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError('error','N&atilde;o foi possível concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','bloqueiaFundo(divRotina)');
		},
		success: function(response) {
			hideMsgAguardo();
			eval( response );
			return false;
		}
	});
}

function validaPagamento(){

	
	showMsgAguardo('Aguarde, validando pagamento...');
	var vlapagar = $('#totpagto', '#frmVlParc').val();
	
	// Carregar os dados de antecipação
	verificaAntecipacaopgto();
	
	// Executa script de confirmação através de ajax
	$.ajax({
		type: 'POST',
		url: UrlSite + 'telas/atenda/prestacoes/cooperativa/valida_pagamentos_geral.php',
		data: {
			nrdconta: nrdconta,
			vlapagar: vlapagar,
			nrctremp: nrctremp,
			redirect: 'script_ajax'
		},
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','bloqueiaFundo(divRotina)');
		},
		success: function(response) {
			eval(response);
		}
	});
	
	return false;
}

function mostraDivPortabilidade( operacao ) {

	showMsgAguardo('Aguarde, abrindo portabilidade...');

    limpaDivGenerica();

    exibeRotina($('#divUsoGenerico'));

    // Executa script de confirmação através de ajax
    $.ajax({
        type: 'POST',
        dataType: 'html',
        url: UrlSite + 'telas/atenda/prestacoes/cooperativa/portabilidade.php',
        data: {
            operacao: operacao,
            nrdconta: nrdconta,
            nrctremp: nrctremp,
            redirect: 'html_ajax'
            },
        error: function(objAjax,responseError,objExcept) {
            hideMsgAguardo();
            showError('error','Não foi possível concluir a requisição.','Alerta - Ayllos',"blockBackground(parseInt($('#divRotina').css('z-index')))");
        },
        success: function(response) {
            $('#divUsoGenerico').html(response);
            layoutPadrao();
            hideMsgAguardo();
            bloqueiaFundo($('#divUsoGenerico'));
        }
    });

	return false;
}

function imprimeExtratoPortabilidade() {
	var action = UrlSite + 'telas/atenda/prestacoes/cooperativa/portabilidade_extrato.php';
	$('#sidlogin','#frmImprimir').val( $('#sidlogin','#frmMenu').val() );
    $('#nrdconta','#frmImprimir').val( nrdconta );
    $('#nrctremp','#frmImprimir').val( nrctremp );
	carregaImpressaoAyllos("frmImprimir",action,"bloqueiaFundo($('#divUsoGenerico'));");
	return false;
}

function aprovarPortabilidade() {
    // Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, aprovando a portabilidade...");
    
    var nrunico_portabilidade = $('#nrunico_portabilidade','#frmPortAprv').val();

    // Executa script de confirmação através de ajax
    $.ajax({
        type: 'POST',
        dataType: 'html',
        url: UrlSite + 'telas/atenda/prestacoes/cooperativa/portabilidade_aprovar.php',
        data: {
            operacao:              operacao,
            nrdconta:              nrdconta,
            nrctremp:              nrctremp,
            nrunico_portabilidade: nrunico_portabilidade,
            redirect: 'html_ajax'
            },
        error: function(objAjax,responseError,objExcept) {
            hideMsgAguardo();
            showError('error','Não foi possível concluir a requisição.','Alerta - Ayllos',"blockBackground(parseInt($('#divRotina').css('z-index')))");
        },
        success: function(response) {
            $('#divUsoGenerico').html(response);
            layoutPadrao();
            hideMsgAguardo();
            bloqueiaFundo($('#divUsoGenerico'));
        }
    });
    
    return false;
}

function mostraDivPortabilidadeAprovar( operacao ) {

	showMsgAguardo('Aguarde, abrindo portabilidade...');

    limpaDivGenerica();

    exibeRotina($('#divUsoGenerico'));

    // Executa script de confirmação através de ajax
    $.ajax({
        type: 'POST',
        dataType: 'html',
        url: UrlSite + 'telas/atenda/prestacoes/cooperativa/portabilidade_aprovar_form.php',
        data: {
            operacao: operacao,
            nrdconta: nrdconta,
            nrctremp: nrctremp,
            redirect: 'html_ajax'
            },
        error: function(objAjax,responseError,objExcept) {
            hideMsgAguardo();
            showError('error','Não foi possível concluir a requisição.','Alerta - Ayllos',"blockBackground(parseInt($('#divRotina').css('z-index')))");
        },
        success: function(response) {
            $('#divUsoGenerico').html(response);
            layoutPadrao();
            hideMsgAguardo();
            bloqueiaFundo($('#divUsoGenerico'));
            
            $('#nrunico_portabilidade','#frmPortAprv').css('width','160px').attr('maxlength','21').focus();
        }
    });

	return false;
}

function mostraDivImpressao( operacao ) {

	showMsgAguardo('Aguarde, abrindo impressão...');

    limpaDivGenerica();

    exibeRotina($('#divUsoGenerico'));

    // Executa script de confirmação através de ajax
    $.ajax({
        type: 'POST',
        dataType: 'html',
        url: UrlSite + 'telas/atenda/prestacoes/cooperativa/impressao.php',
        data: {
            operacao: operacao,
            flgimppr: flgimppr,
            flgimpnp: flgimpnp,
            cdorigem: cdorigem,
            redirect: 'html_ajax'
            },
        error: function(objAjax,responseError,objExcept) {
            hideMsgAguardo();
            showError('error','Não foi possível concluir a requisição.','Alerta - Ayllos',"blockBackground(parseInt($('#divRotina').css('z-index')))");
        },
        success: function(response) {
            $('#divUsoGenerico').html(response);
            layoutPadrao();
            hideMsgAguardo();
            bloqueiaFundo($('#divUsoGenerico'));
        }
    });

    divRotina.css('width','280');
    $('#divConteudoOpcao','#tbImp').css({'height':'200px','width':'280'});

    $('input','#tbImp > #divConteudoOpcao').css({'clear':'left'});

	return false;
}

// Função para verificar a opção de impressão
function verificaImpressao(par_idimpres){
    
	idimpres = par_idimpres;

	if ( idimpres >= 1 && idimpres <= 9 ) {
	
		if ( idimpres == 5 ) {

			var metodo = '';

			imprimirRating(false,90,nrctremp,"divConteudoOpcao","bloqueiaFundo(divRotina);");

			if ( $('#divAguardo').css('display') == 'block' ){
				metodo = $('#divAguardo');
			}else{
				metodo = $('#divRotina');
			}

			fechaRotina($('#divUsoGenerico'),metodo);
			
		}
		else
		if (in_array(idimpres, [7, 8, 9])) { //pre-aprovado
			carregarImpresso();		
		}
		else {

			if ( ( flgimpnp == 'yes' ) && in_array(idimpres,[1,4]) ) {
				mostraNP(idimpres);
			} else {
				promsini = 1;
				
				if  (idimpres == 2 && arrayRegistros['qtimpctr'] >= 1) {
					pedeSenhaCoordenador(2,'mostraEmail();','');	
				} else {
					mostraEmail();
				}	
				
				if (idimpres == 2) {
					arrayRegistros['qtimpctr'] = arrayRegistros['qtimpctr'] + 1;	
				}
				
			}
		}
	}else{
		showError('error','Opção de impressão inválida','Alerta - Ayllos',"blockBackground(parseInt($('#divRotina').css('z-index')))");
	}

	return false;
}

// Função para fechamento da tela de impressão
function fechaImpressao(operacao){

	fechaRotina($('#divUsoGenerico'),$('#divRotina'));

	if (operacao != 'fechar') { controlaOperacao(operacao); }

	return false;

}

// Função para número inicial de nota promissória
function mostraNP( operacao ) {

	showMsgAguardo('Aguarde, abrindo impressão...');
	exibeRotina($('#divUsoGenerico'));
    
	limpaDivGenerica();
     
	// Executa script de confirmação através de ajax
	$.ajax({
		type: 'POST',
		dataType: 'html',
		url: UrlSite + 'telas/atenda/prestacoes/cooperativa/nota_promissoria.php',
		data: {
			operacao: operacao,
			redirect: 'html_ajax'
			},
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError('error','Não foi possível concluir a requisição.','Alerta - Ayllos',"blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
		success: function(response) {
			$('#divUsoGenerico').html(response);
			layoutPadrao();
			hideMsgAguardo();
			bloqueiaFundo($('#divUsoGenerico'));
		}
	});

	return false;
}

// Função que tratar fechamento da confirmação da promissória inicial
function fechaNP(operacao){

	if ( qtpromis < $('#nrpromini' , '#frmNotaini').val() ){
		showError('error','Número de nota promissória inicial inválido','Alerta - Ayllos',"bloqueiaFundo($('#divUsoGenerico'));");
		return false;
	}

	promsini = $('#nrpromini' , '#frmNotaini').val();

	fechaRotina($('#divUsoGenerico'),$('#divRotina'));

	mostraEmail();

	return false;

}

//Função para chamar Confirmação de E-mail
function mostraEmail() {

	// Verificar se deve permitir envio de email para o comite
    if (flmail_comite == 1) {
	var metodoSim = "flgemail=true;carregarImpresso();";
	var metodoNao = "flgemail=false;carregarImpresso();";

	showConfirmacao("Efetuar envio de e-mail para Sede?","Confirma&ccedil;&atilde;o - Ayllos",metodoSim,metodoNao,"sim.gif","nao.gif");
    } else  
        {  
          flgemail=false;
          carregarImpresso();
        } 
	return false;

}

// Função para envio de formulário de impressao
function carregarImpresso(){

	fechaRotina($('#divUsoGenerico'),$('#divRotina'));

	$('#idimpres','#formEmpres').remove();
	$('#promsini','#formEmpres').remove();
	$('#flgemail','#formEmpres').remove();
	$('#nrdrecid','#formEmpres').remove();
	$('#nrdconta','#formEmpres').remove();
	$('#sidlogin','#formEmpres').remove();

	// Insiro input do tipo hidden do formulário para enviá-los posteriormente
	$('#formEmpres').append('<input type="hidden" id="idimpres" name="idimpres" />');
	$('#formEmpres').append('<input type="hidden" id="promsini" name="promsini" />');
	$('#formEmpres').append('<input type="hidden" id="flgemail" name="flgemail" />');
	$('#formEmpres').append('<input type="hidden" id="nrdrecid" name="nrdrecid" />');
	$('#formEmpres').append('<input type="hidden" id="nrdconta" name="nrdconta" />');
	$('#formEmpres').append('<input type="hidden" id="nrctremp" name="nrctremp" />');
	$('#formEmpres').append('<input type="hidden" id="sidlogin" name="sidlogin" />');

	// Agora insiro os devidos valores nos inputs criados
	$('#idimpres','#formEmpres').val( idimpres );
	$('#promsini','#formEmpres').val( promsini );
	$('#flgemail','#formEmpres').val( flgemail );
	$('#nrdrecid','#formEmpres').val( nrdrecid );
	$('#nrdconta','#formEmpres').val( nrdconta );
	$('#nrctremp','#formEmpres').val( nrctremp );
	$('#sidlogin','#formEmpres').val( $('#sidlogin','#frmMenu').val() );
    
	var action = UrlSite + 'telas/atenda/prestacoes/cooperativa/imprimir_dados.php';

	carregaImpressaoAyllos("formEmpres",action,"bloqueiaFundo(divRotina);");

	return false;
}


function verificaTipoEmprestimo()
{
	var mtSimplificado = 'intpextr=1;imprimirExtrato();';
	var mtDetalhado    = 'intpextr=2;imprimirExtrato();';

	showConfirmacao('Escolha o tipo de relat&oacute;rio','Confirma&ccedil;&atilde;o - Ayllos',mtSimplificado,mtDetalhado,'simplificado.gif','detalhado.gif');
}

// Função para envio de formulário de impressao
function imprimirExtrato(){

	fechaRotina($('#divUsoGenerico'),$('#divRotina'));

	$('#sidlogin','#formEmpres').remove();
	$('#idseqttl','#formEmpres').remove();
	$('#nrctremp','#formEmpres').remove();
	$('#nrdconta','#formEmpres').remove();
	$('#intpextr','#formEmpres').remove();

	// Insiro input do tipo hidden do formulário para enviá-los posteriormente
	$('#formEmpres').append('<input type="hidden" id="sidlogin" name="sidlogin" />');
	$('#formEmpres').append('<input type="hidden" id="idseqttl" name="idseqttl" />');
	$('#formEmpres').append('<input type="hidden" id="nrctremp" name="nrctremp" />');
	$('#formEmpres').append('<input type="hidden" id="nrdconta" name="nrdconta" />');
	$('#formEmpres').append('<input type="hidden" id="intpextr" name="intpextr" />');

	// Agora insiro os devidos valores nos inputs criados
	$('#sidlogin','#formEmpres').val( $('#sidlogin','#frmMenu').val() );
	$('#idseqttl','#formEmpres').val( idseqttl );
	$('#nrctremp','#formEmpres').val( nrctremp );
	$('#nrdconta','#formEmpres').val( nrdconta );
	$('#intpextr','#formEmpres').val( intpextr );

	var action = UrlSite + 'telas/atenda/prestacoes/cooperativa/imprimir_extrato.php';

	carregaImpressaoAyllos("formEmpres",action,"bloqueiaFundo(divRotina);");

	return false;
}


// Habilita e desabilita os campos de acordo com o checkbox
function habilitaDesabilitaCampo(object, flgRecalcula , nrParcela)
{
	var divTabela   = $('#divTabela');
	var divRegistro = $('div.divRegistros', divTabela );
	var tabela      = $('table', divRegistro );

	if(typeof(nrParcela) == 'undefined')
	{
		if(typeof(object.id) == 'undefined')
			nrParcela = this.id.split("_")[1];
		else
			nrParcela = object.id.split("_")[1];
	}

	if($('#check_'+nrParcela+':checked', tabela).val() == 'on'){

		$('#vlpagpar_'+nrParcela , tabela).habilitaCampo();
		// Manipulação de dados referente aos campos do valor de antecipação de parcelas
		valorAtual    = retiraMascara($('#vlatupar_'+nrParcela , tabela).val());
		valorMulta    = retiraMascara($('#vlmtapar_'+nrParcela , tabela).val());
		valorMora	  = retiraMascara($('#vlmrapar_'+nrParcela , tabela).val());

		valorAtual +=  valorMulta + valorMora;

		$('#vlpagpar_'+nrParcela , tabela  ).val(valorAtual.toFixed(2).replace(".",","));

	} else {
		$('#vlpagpar_'+nrParcela , tabela).val('0,00').desabilitaCampo();
	}

	$("#vlpagan_" + nrParcela,tabela).val ( $('#vlpagpar_'+nrParcela , divTabela).val() );

	if (flgRecalcula) {
		recalculaTotal();
	}

}

function retiraMascara(numero)
{
	numero = parseFloat(numero.replace(".","").replace(",","."));
	return numero;
}

// Recalcula o valor total
function recalculaTotal()
{
	valorAPagar = 0;

	$("input[type=text][name='vlpagpar[]']").each(function() {
		valorAPagar = valorAPagar + retiraMascara($(this).val());
	});

	$('#totpagto','#frmVlParc').val(valorAPagar.toFixed(2).replace(".",","));
	$('#vldifpar','#frmVlParc').val('0,00');

}


// Atualiza o valor das parcelas, caso seja informado o campo total a pagar
function atualizaParcelas()
{
	var valorTotPgto = retiraMascara($('#vlpagmto','#frmVlPagar').val());
	var divTabela   = $('#divTabela');
	var divRegistro = $('div.divRegistros', divTabela );
	var tabela      = $('table', divRegistro );
	var valorPagar    = 0;
	$('#totpagto', '#totpagto').val("0,00");

	// Desmarca todas as parcelas
	$("input[type=checkbox][name='checkParcelas[]']").each(function() {
		if(this.checked == true)
		{
			this.checked = false;
			habilitaDesabilitaCampo(this,false);
		}
	})

	recalculaTotal();

	if(valorTotPgto > 0)
	{
		var diferenca = false;
		parcela = 1;

		while(!diferenca)
		{
			nrParcela = $('#parcela_'+parcela , tabela).val();
			if(typeof($('#vlatupar_'+nrParcela , tabela).val()) == 'undefined'){
				diferenca = true;
			}
			else
			{
				valorAtual = retiraMascara($('#vlatupar_'+nrParcela , tabela).val());
				valorPagar  = retiraMascara($('#vlpagpar_'+nrParcela , tabela).val());

				if(valorTotPgto >= valorAtual)
				{
					$('#check_'+nrParcela , tabela).prop('checked', true);
					habilitaDesabilitaCampo('', true, nrParcela);
					valorAtual = retiraMascara($('#vlatupar_'+nrParcela , tabela).val());
					valorPagar  = retiraMascara($('#vlpagpar_'+nrParcela , tabela).val());
					valorTotPgto = valorTotPgto - valorPagar;
				}
				else
					diferenca = true;
			}

			parcela++;
		}

		$('#vldifpar','#frmVlParc').val(valorTotPgto.toFixed(2).replace(".",","));

	}
}

function geraPagamentos()
{
	var divTabela   = $('#divTabela');
	var divRegistro = $('div.divRegistros', divTabela );
	var tabela      = $('table', divRegistro );
	var totatual    = $('#totatual','#frmVlParc').val();
	var totpagto    = $('#totpagto','#frmVlParc').val();
	
	var nrseqavl = 0;
	var campospc = 'cdcooper|nrdconta|nrctremp|nrparepr|vlpagpar';
	var dadosprc = '';
	
	if ($('#divUsoGenerico').css('visibility') == 'visible') {
		nrseqavl = $('input:radio[name=nrseqavl]:checked','#frmDadosPagAval').val();
	}
	
	$("input[type=checkbox][name='checkParcelas[]']").each(function() {
		checked = false;
		checked = this.checked;
		if(checked != false)
		{
			nrParcela = this.id.split("_")[1];

			dadosprc  += $('#cdcooper_'+nrParcela , tabela).val()+';'+$('#nrdconta_'+nrParcela , tabela).val()+';'+$('#nrctremp_'+nrParcela , tabela).val()+';';
			dadosprc  += $('#nrparepr_'+nrParcela , tabela).val()+';'+$('#vlpagpar_'+nrParcela , tabela).val()+'|';
		}
	});

	// Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, gerando pagamento ...");

	// Carrega conteúdo da opção através de ajax
	$.ajax({
		type: "POST",
		dataType: 'html',
		url: UrlSite + "telas/atenda/prestacoes/cooperativa/gera_pagamentos.php",
		data: {
		    nrdconta: nrdconta,	nrctremp: nrctremp,
			campospc: campospc, dadosprc: dadosprc,
			idseqttl: idseqttl, totatual: totatual,
			totpagto: totpagto, nrseqavl: nrseqavl,
			redirect: "html_ajax" // Tipo de retorno do ajax
		},
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message + ".","Alerta - Ayllos","$('#nrsennov','#frmEskeci').focus()");
		},
		success: function(response) {
		    /*imprimir relatorio de antecipacao das prestacoes pagas*/	 		    					
			hideMsgAguardo();			
			eval(response);
					
			
		}
	});
};

function verificaDesconto(campo , flgantec , parcela) {

	var vlpagan = $("#vlpagan_" + parcela,"#divTabela");

	if (isHabilitado(campo) && retiraMascara(vlpagan.val()) != retiraMascara(campo.val()) && flgantec == 'yes') {
		desconto(parcela);
	}

	vlpagan.val(campo.val());

}

function desconto (parcela) {

	if  (parcela != 0) {
		vlpagpar = parcela + ";" + $("#vlpagpar_" + parcela ,"#divTabela").val();
	}

	controlaOperacao("C_DESCONTO");

}


function verificaAntecipacao() {

    showMsgAguardo('Aguarde, abrindo impressão...');
	//exibeRotina($('#divUsoGenerico'));

	limpaDivGenerica();

	// Executa script de confirmação através de ajax
	$.ajax({
		type: 'POST',
		dataType: 'html',
		url: UrlSite + 'telas/atenda/prestacoes/cooperativa/antecipacao.php',
		data: {
			operacao: operacao,
			redirect: 'html_ajax'
			},
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError('error','Não foi possível concluir a requisição.','Alerta - Ayllos',"blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
		success: function(response) {
			$('#divUsoGenerico').html(response);
			
			$('#nrctremp','#frmAntecipacao').val($('#nrctremp','#frmDadosPrest').val());
			$('#vlpreemp','#frmAntecipacao').val($('#vlpreemp','#frmDadosPrest').val());
	
			carregaAntecipacao();
			/*
			layoutPadrao();
			exibeRotina($('#divUsoGenerico'));
			hideMsgAguardo();
			bloqueiaFundo($('#divUsoGenerico'));
			*/
		}
	});
 
	return false;
 
}


function carregaAntecipacao() {

	var nrdconta = normalizaNumero($('#nrdconta','#frmCabAtenda').val());
	var nrctremp = normalizaNumero($('#nrctremp','#frmAntecipacao').val());
		
	// Executa script de confirmação através de ajax
	$.ajax({
		type: 'POST',
		dataType: 'html',
		url: UrlSite + 'telas/atenda/prestacoes/cooperativa/busca_antecipacao.php',
		data: {
			nrdconta: nrdconta,
			nrctremp: nrctremp,
			redirect: 'html_ajax'
			},
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError('error','Não foi possível concluir a requisição.','Alerta - Ayllos',"blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
		success: function(response) {
			
			$('#divParcelasAntecipadas').html(response);
			
			formataTabelaAntecipacao();
			controlaCheck();
			
			layoutPadrao();
			exibeRotina($('#divUsoGenerico'));
			hideMsgAguardo();
			bloqueiaFundo($('#divUsoGenerico'));
		}
	});
	
	return false;
//nrctremp
}


function formataTabelaAntecipacao() {

	var divRegistro = $('div.divRegistros','#divParcelasAntecipadas');		
	var tabela      = $('table', divRegistro );
	var linha       = $('table > tbody > tr', divRegistro );
			
	divRegistro.css({'height':'180px','width':'100%'});
	
	var ordemInicial = new Array();
//	ordemInicial = [[1,0]];	
	
	var arrayLargura = new Array();
	arrayLargura[0] = '20px';
	arrayLargura[1] = '60px';
	arrayLargura[2] = '105px';
	arrayLargura[3] = '105px';
	
		
	var arrayAlinha = new Array();
	arrayAlinha[0] = 'center';
	arrayAlinha[1] = 'center';
	arrayAlinha[2] = 'center';
	arrayAlinha[3] = 'center';
	arrayAlinha[4] = 'right';
	
	var metodoTabela = '';
			
	tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha, metodoTabela );
	
	$("th:eq(0)", tabela).removeClass();
	$("th:eq(0)", tabela).unbind('click');
	
	return false;
}


function controlaCheck() {

	$('#checkTodos','#divParcelasAntecipadas').unbind('click').bind('click', function(e) {
		
		if( $(this).prop("checked") == true ){
			$(this).val("yes");	
			$('input[type="checkbox"],select','#divParcelasAntecipadas').each(function(e){				
				if( $(this).prop("id") != "checkTodos"  ){
				    $(this).prop("checked",true);
					$(this).trigger("click");
					$(this).prop("checked",true);
				}	
			});
		} else {
		
			$(this).val("no");	
				$('input[type="checkbox"],select','#divParcelasAntecipadas').each(function(e){				
					if( $(this).prop("id") != "checkTodos"  ){
						$(this).prop("checked",false);
						$(this).trigger("click");
						$(this).prop("checked",false);
					}	
				});
		}
			
	});
	
}
	
/*imprimir relatorio de antecipacao das prestacoes pagas*/
function verificaAntecipacaopgto() {

	var divTabela   = $('#divTabela');
	var divRegistro = $('div.divRegistros', divTabela );
	var tabela      = $('table', divRegistro );
	var nrdconta    = normalizaNumero($('#nrdconta','#frmCabAtenda').val());
	var nrctremp    = 0;
	var qtdregis 	= 0;
	var dtmvtolt    = $('#glbdtmvtolt','#frmAntecipapgto').val();
	var dtparcel	= dtmvtolt; // recebe dtmvtolt, apenas para inicialização
	
	// Limpa variaveis das listas
	lstdtvcto = '';
	lstdtpgto = '';
	lstparepr = '';
	lstvlrpag = '';	
	
	// ler informações dos registros marcados
	$("input[type=checkbox][name='checkParcelas[]']").each(function() {
		checked = false;
		checked = this.checked;
		if(checked != false)
		{
			// Guardar o indice da parcela
			nrParcela = this.id.split("_")[1];	
			
			// carrega a data da parcela para a variável
			dtparcel = $('#dtvencto_'+nrParcela , tabela).val();
		   
			// Criar as variáveis com as datas para comparação
			// Movimento
	        var dtcompar1 = parseInt(dtmvtolt.split("/")[2].toString() + dtmvtolt.split("/")[1].toString() + dtmvtolt.split("/")[0].toString()); 
		    // Parcela
			var dtcompar2 = parseInt(dtparcel.split("/")[2].toString() + dtparcel.split("/")[1].toString() + dtparcel.split("/")[0].toString()); 
		
		
			// incluir como antecipado somente se a data de vencto for maior que a data de movimento(pagamento)
			if (dtcompar1 <  dtcompar2) 
			{
				// montar listas que serão passadas por parametro
				nrctremp  = normalizaNumero($('#nrctremp_'+nrParcela , tabela).val());
				lstdtvcto += $('#dtvencto_'+nrParcela , tabela).val() + ';';							     
				lstdtpgto += ';'; 	
				lstparepr += $('#nrparepr_'+nrParcela , tabela).val() + ';';			
				lstvlrpag += $('#vlpagpar_'+nrParcela , tabela).val() + ';';
				//contar registros
				qtdregis++;		
		 	}	
		}
	});	
		
	// Retirar espacos
	$.trim(lstdtvcto);
	$.trim(lstdtpgto);
	$.trim(lstparepr);
	$.trim(lstvlrpag);
	
	// Retirar ultimo ; de cada lista.
	lstdtvcto = lstdtvcto.substr(0,lstdtvcto.length - 1);
	lstdtpgto = lstdtpgto.substr(0,lstdtpgto.length - 1);
	lstparepr = lstparepr.substr(0,lstparepr.length - 1);
	lstvlrpag = lstvlrpag.substr(0,lstvlrpag.length - 1);
	
	nrctremp1  = nrctremp;
	qtdregis1  = qtdregis;
	nrdconta1  = nrdconta;
	lstdtvcto1 = lstdtvcto;
	lstdtpgto1 = lstdtpgto;
	lstparepr1 = lstparepr;
	lstvlrpag1 = lstvlrpag;
		
}

function realizaImpressao(idAntecipacao) {

	// Se estiver indicado true para a antecipação
	if (idAntecipacao == true) {
		carregarImpressoAntecipacao('frmAntecipapgto');
	} else {
		//Controlar a operação da tela
		controlaOperacao('C_PAG_PREST');
	}
	
	return false;
}

function imprimirAntecipacao() {

    // Quantidade de parcelas exibidas na tela
	var qtparepr = $('#qtparepr','#divParcelasAntecipadas').val();
	
	var nrdconta = normalizaNumero($('#nrdconta','#frmCabAtenda').val());
	var nrctremp = normalizaNumero($('#nrctremp','#frmAntecipacao').val());
	
	// Limpa variaveis das listas
	lstdtvcto = '';
	lstdtpgto = '';
	lstparepr = '';
	lstvlrpag = '';
	
	var qtdregis = 0;
	
	// Efetua leitura dos registros que foram selecionados
	for (var i=1;i<=qtparepr;i++){ 
		
		if( $('#flgcheck'+i,'#divParcelasAntecipadas').prop('checked') == true ){
		
			 lstdtvcto = lstdtvcto + $('#dtvencto'+i,'#divParcelasAntecipadas').val() + ';'; 
			 lstdtpgto = lstdtpgto + $('#dtpagemp'+i,'#divParcelasAntecipadas').val() + ';'; 
			 lstparepr = lstparepr + $('#nrparepr'+i,'#divParcelasAntecipadas').val() + ';'; 
			 lstvlrpag = lstvlrpag + $('#vllanmto'+i,'#divParcelasAntecipadas').val() + ';'; 
			 
			 qtdregis++;
			
		}	
	}

	// Retirar espacos
	$.trim(lstdtvcto);
	$.trim(lstdtpgto);
	$.trim(lstparepr);
	$.trim(lstvlrpag);
	
	// Retirar ultimo ; de cada lista.
	lstdtvcto = lstdtvcto.substr(0,lstdtvcto.length - 1);
	lstdtpgto = lstdtpgto.substr(0,lstdtpgto.length - 1);
	lstparepr = lstparepr.substr(0,lstparepr.length - 1);
	lstvlrpag = lstvlrpag.substr(0,lstvlrpag.length - 1);
	
	nrctremp1  = nrctremp;
	qtdregis1  = qtdregis;
	nrdconta1  = nrdconta;
	lstdtvcto1 = lstdtvcto;
	lstdtpgto1 = lstdtpgto;
	lstparepr1 = lstparepr;
	lstvlrpag1 = lstvlrpag;
	
	if (qtdregis > 0) {
	  carregarImpressoAntecipacao('frmAntecipacao');
	} else {
	  return;
	}
	
}


function carregarImpressoAntecipacao(vr_nmform){
    
	fechaRotina($('#divUsoGenerico'),$('#divRotina'));
   
	$('#sidlogin','#' + vr_nmform).remove();
	$('#nrctremp1','#' + vr_nmform).remove();
	$('#qtdregis1','#' + vr_nmform).remove();
	$('#nrdconta1','#' + vr_nmform).remove();
	$('#lstdtvcto1','#' + vr_nmform).remove();
	$('#lstdtpgto1','#' + vr_nmform).remove();
	$('#lstparepr1','#' + vr_nmform).remove();
	$('#lstvlrpag1','#' + vr_nmform).remove();

	// Insiro input do tipo hidden do formulário para enviá-los posteriormente
	$('#' + vr_nmform).append('<input type="hidden" id="nrctremp1" name="nrctremp1" />');
	$('#' + vr_nmform).append('<input type="hidden" id="qtdregis1" name="qtdregis1" />');
	$('#' + vr_nmform).append('<input type="hidden" id="nrdconta1" name="nrdconta1" />');
	$('#' + vr_nmform).append('<input type="hidden" id="lstdtvcto1" name="lstdtvcto1" />');
	$('#' + vr_nmform).append('<input type="hidden" id="lstdtpgto1" name="lstdtpgto1" />');
	$('#' + vr_nmform).append('<input type="hidden" id="lstparepr1" name="lstparepr1" />');
	$('#' + vr_nmform).append('<input type="hidden" id="lstvlrpag1" name="lstvlrpag1" />');
	$('#' + vr_nmform).append('<input type="hidden" id="sidlogin" name="sidlogin" />');
		
	// Agora insiro os devidos valores nos inputs criados
	$('#nrctremp1','#' + vr_nmform).val(  nrctremp1 );
	$('#qtdregis1','#' + vr_nmform).val(  qtdregis1 );
	$('#nrdconta1','#' + vr_nmform).val(  nrdconta1 );
	$('#lstdtvcto1','#' + vr_nmform).val( lstdtvcto1 );
	$('#lstdtpgto1','#' + vr_nmform).val( lstdtpgto1 );
	$('#lstparepr1','#' + vr_nmform).val( lstparepr1 );
	$('#lstvlrpag1','#' + vr_nmform).val( lstvlrpag1 );
	$('#sidlogin','#' + vr_nmform).val( $('#sidlogin','#frmMenu').val() );

	var action = UrlSite + 'telas/atenda/prestacoes/cooperativa/imprimir_antecipacao.php';

	//variavel para os comandos de controle
	var controle = 'bloqueiaFundo(divRotina);';
	
	if (vr_nmform == 'frmAntecipapgto') {
	  controle += ' controlaOperacao(\'C_PAG_PREST\');';
	}
	
	carregaImpressaoAyllos(vr_nmform, action, controle);

	return false;
}

function controlaSocios (operacao, cdcooper, idSocio , qtSocios) {
	if  (idSocio > qtSocios) {
		controlaOperacao('C_COMITE_APROV');		
	}
	else {
		controlaOperacao("C_PROTECAO_SOC");
	}

}

function prejuizoRetorno() {

	acessaOpcaoAba( 0, 0, 0, glb_nriniseq, glb_nrregist);
	return false;
}

function confirmaPrejuizo(){

	$('table > tbody > tr', 'div.divRegistros').each( function() {
		if ( $(this).hasClass('corSelecao') ) {

			if (typeof $('#nrctremp', $(this) ).val() != 'undefined'){
				nrctremp = $('#nrctremp', $(this) ).val();
			}
		}
	});
	
	// Verifica se existe algum contrato selecionado.
	if ( nrctremp == '' ) { return false; }

	// Solicita confirmacao para executar a rotina
	showConfirmacao('Confirmar opera&ccedil;&atilde;o?','Confirma&ccedil;&atilde;o - Ayllos','controlaOperacao(\'C_TRANSF_PREJU\');','bloqueiaFundo($(\'#divRotina\'));','sim.gif','nao.gif');
	return false;

}

function confirmaDesfazPrejuizo(){

	$('table > tbody > tr', 'div.divRegistros').each( function() {
		if ( $(this).hasClass('corSelecao') ) {

			if (typeof $('#nrctremp', $(this) ).val() != 'undefined'){
				nrctremp = $('#nrctremp', $(this) ).val();
			}
		}
	});
	
	// Verifica se existe algum contrato selecionado.
	if ( nrctremp == '' ) { return false; }

	// Solicita confirmacao para executar a rotina
	showConfirmacao('Desfazer Transferencia para Prejuizo?','Confirma&ccedil;&atilde;o - Ayllos','controlaOperacao(\'C_DESFAZ_PREJU\');','bloqueiaFundo($(\'#divRotina\'));','sim.gif','nao.gif');
	return false;

}


/**
 * @param Integer cdcooper
 * @param Integer nrdconta
 * @param Integer nrctremp
 * @param String tipo_consulta ('PROPOSTA', 'CONTRATO')
 * @returns Carrega os dados em tela
 */
function carregaCamposPortabilidade(cdcooper, nrdconta, nrctremp,tipo_consulta) 
{

    //showMsgAguardo("Aguarde, carregando dados...");
    if (typeof arrayDadosPortabilidade['nrcnpjbase_if_origem'] == 'undefined' ||
        typeof arrayDadosPortabilidade['nrcontrato_if_origem'] == 'undefined' ||
        typeof arrayDadosPortabilidade['nmif_origem']          == 'undefined' ||
        typeof arrayDadosPortabilidade['cdmodali']             == 'undefined')
    {
		$.ajax({
			type: "POST",
			url: UrlSite + "telas/atenda/emprestimos/portabilidade/ajax_portabilidade.php",
			dataType: "json",
			async: false,
			data: {
				flgopcao: 'CP',
				cdcooper: cdcooper,
				nrdconta: nrdconta,
				nrctremp: nrctremp,
				tipo_consulta: tipo_consulta
			},
			success: function(data) {
				if (data.rows > 0) {
					$.each(data.records, function(i,item) {
						//CNPJ IF Credora
						$("#nrcnpjbase_if_origem", "#frmPortabilidadeCredito").val(item.nrcnpjbase_if_origem);
						//Nome IF Credora
						$("#nmif_origem", "#frmPortabilidadeCredito").val(item.nmif_origem);
						//numero de contrato
						$("#nrcontrato_if_origem", "#frmPortabilidadeCredito").val(item.nrcontrato_if_origem);
						//modalidade
						$("#frmPortabilidadeCredito #cdmodali_portabilidade option").each( function() {
							if ( item.cdmodali == $(this).val() ) {
								$(this).attr('selected', 'selected');
							}
						});
						//numero unico portabilidade
						$("#nrunico_portabilidade", "#frmPortabilidadeCredito").val(item.nrunico_portabilidade);
						//situacao da portabilidade
						$("#dssit_portabilidade", "#frmPortabilidadeCredito").val(item.dssit_portabilidade);
						
						//carrega o array de dados de portabilidade 
						arrayDadosPortabilidade['nrcnpjbase_if_origem'] = $('#nrcnpjbase_if_origem', '#frmPortabilidadeCredito').val();
						arrayDadosPortabilidade['nrcontrato_if_origem'] = $('#nrcontrato_if_origem', '#frmPortabilidadeCredito').val();
						arrayDadosPortabilidade['nmif_origem'] = $('#nmif_origem', '#frmPortabilidadeCredito').val();
						arrayDadosPortabilidade['cdmodali'] = $('#cdmodali_portabilidade', '#frmPortabilidadeCredito').val();
						arrayDadosPortabilidade['nrunico_portabilidade'] = $('#nrunico_portabilidade', '#frmPortabilidadeCredito').val();
						arrayDadosPortabilidade['dssit_portabilidade'] = $('#dssit_portabilidade', '#frmPortabilidadeCredito').val();						
						
					});
					//hideMsgAguardo();
				} else {
					eval(data);
				}
			}
		});
	
	} else {
        //CNPJ IF Credora
        $("#nrcnpjbase_if_origem", "#frmPortabilidadeCredito").val(arrayDadosPortabilidade['nrcnpjbase_if_origem']);
        //Nome IF Credora
        $("#nmif_origem", "#frmPortabilidadeCredito").val(arrayDadosPortabilidade['nmif_origem']);
        //numero de contrato
        $("#nrcontrato_if_origem", "#frmPortabilidadeCredito").val(arrayDadosPortabilidade['nrcontrato_if_origem']);
        //modalidade
        $("#frmPortabilidadeCredito #cdmodali_portabilidade option").each(function() {
            if (arrayDadosPortabilidade['cdmodali'] == $(this).val()) {
                $(this).attr('selected', 'selected');
            }
        });
        //numero unico portabilidade
        $("#nrunico_portabilidade", "#frmPortabilidadeCredito").val(arrayDadosPortabilidade['nrunico_portabilidade']);
        //situacao da portabilidade
        $("#dssit_portabilidade", "#frmPortabilidadeCredito").val(arrayDadosPortabilidade['dssit_portabilidade']);        
    }	
	
}

function direcionaConsulta() {
    
    possuiPortabilidade = $("#tabPrestacao table tr.corSelecao").find("input[id='portabil']").val();
    
    if ( possuiPortabilidade == 'N' ) {
        controlaOperacao('TC');
    } else if ( possuiPortabilidade == 'S' ) {
        controlaOperacao('PORTAB_CRED_C');
    }   
}

function validarLiquidacao(){
	
	var liquidia;
	var inprejui;

	$('table > tbody > tr', 'div.divRegistros').each( function() {
			if ( $(this).hasClass('corSelecao') ) {

				if (typeof $('#nrctremp', $(this) ).val() != 'undefined'){
					nrctremp = $('#nrctremp', $(this) ).val();
				}
				if (typeof $('#liquidia', $(this) ).val() != 'undefined'){
					liquidia = $('#liquidia', $(this) ).val();
				}
				if (typeof $('#inprejuz', $(this) ).val() != 'undefined'){
					inprejui = $('#inprejuz', $(this) ).val();
				}
			/*	if (typeof $('#vlemprst', $(this) ).val() != 'undefined'){
					vlemprst = $('#vlemprst', $(this) ).val();
				}
			*/	
			}
		});
		if ( nrctremp == '' ) { return false; }
	
	
	if ( liquidia == 1 ) {

		showConfirmacao('Deseja Realizar Liquidação do Contrato?','Confirma&ccedil;&atilde;o - Ayllos','exibeValorLiquidacao();','controlaOperacao(\'C_PAG_PREST\');','sim.gif','nao.gif');
		return false;
		
	} else {
	
		if (inprejui == 0)
			controlaOperacao('C_PAG_PREST');
		else
			controlaOperacao('C_PAG_PREST_PREJU');
	
	}

}

function exibeValorLiquidacao(){
	
	var vlemprstMsg;

	$('table > tbody > tr', 'div.divRegistros').each( function() {
			if ( $(this).hasClass('corSelecao') ) {

				if (typeof $('#vlemprst', $(this) ).val() != 'undefined'){
					vlemprstMsg = $('#vlemprst', $(this) ).val();
				}
				
			}
		});

	msg = 'Valor para Liquidação R$ ' + vlemprstMsg;

	showConfirmacao(msg,'Confirma&ccedil;&atilde;o - Ayllos','bloqueiaFundo($(\'#divRotina\'));','confirmarLiquidacao();','voltar.gif','continuar.gif');
	return false;

}

function confirmarLiquidacao(){

	showConfirmacao('Confirma Liquidação do Contrato?','Confirma&ccedil;&atilde;o - Ayllos','controlaOperacao(\'C_LIQ_MESMO_DIA\');','cancelaLiquidacao();','sim.gif','nao.gif');
	return false;

	/* 'bloqueiaFundo($(\'#divRotina\'));' */
	
}

function cancelaLiquidacao(){
	
	showError('inform','Contrato n&atilde;o Liquidado!','Alerta - Ayllos','bloqueiaFundo(divRotina)');
	return false;
	
}

function calcularSaldo(){
	var valVlpagto = parseFloat($('#vlpagto', '#frmVlParcPreju').val().replace(".","").replace(",",".")); valVlpagto = ((!valVlpagto) ? 0 : valVlpagto);
	var valVlprincipal = parseFloat($('#vlprincipal', '#frmVlParcPreju').val().replace(".","").replace(",",".")); valVlprincipal = ((!valVlprincipal) ? 0 : valVlprincipal);
	var valVljuros = parseFloat($('#vljuros', '#frmVlParcPreju').val().replace(".","").replace(",",".")); valVljuros = ((!valVljuros) ? 0 : valVljuros);
	var valVlmulta = parseFloat($('#vlmulta', '#frmVlParcPreju').val().replace(".","").replace(",",".")); valVlmulta = ((!valVlmulta) ? 0 : valVlmulta);
	var valVlabono = parseFloat($('#vlabono', '#frmVlParcPreju').val().replace(".","").replace(",",".")); valVlabono = ((!valVlabono) ? 0 : valVlabono);
	var cVlsaldo = parseFloat($('#vlsaldo', '#frmVlParcPreju')); cVlsaldo = ((!cVlsaldo) ? 0 : cVlsaldo);

	//var resultado = valVlprincipal - valVlpagto - valVljuros - valVlmulta - valVlabono;
	var resultado = valVlprincipal + valVljuros + valVlmulta - valVlpagto - valVlabono;
	
	resultado = resultado.toFixed(2);
	strResultado = resultado.toString().replace(".",",")

	$('#vlsaldo', '#frmVlParcPreju').val(strResultado);
}