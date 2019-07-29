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
 * 040: [25/05/2017] Permitir gerar extrato de Pos-Fixado. (Jaison/James - PRJ298)
 * 040: [22/06/2017] Alterado para mostrar frame de portabilidade independente de ter selecionado um contrato ou não. (Projeto 357 - Reinert)
 * 041: [13/06/2017] Ajuste devido ao aumento do formato para os campos crapass.nrdocptl, crapttl.nrdocttl, 
			         crapcje.nrdoccje, crapcrl.nridenti e crapavt.nrdocava
					 (Adriano - P339).
 * 042: [05/10/2017] Adicionado campo vliofcpl no formulário (Diogo - MoutS - Projeto 410 - RF 23)
 * 043: [11/10/2017] Liberacao da melhoria 442 (Heitor - Mouts)
 * 044: [13/12/2017] Passagem do idcobope e acionamento da GAROPC. (Jaison/Marcos Martini - PRJ404)
 * 045: [17/01/2018] Incluído novo campo (Qualif Oper. Controle) (Diego Simas - AMcom)
 * 046: [24/01/2018] Incluído tratamento para o nível de risco original (Reginaldo - AMcom)
 * 047: [07/06/2018} P410 - Incluido tela de resumo da contratação + declaração isenção imóvel - Arins/Martini - Envolti    
 * 048: [27/06/2018] Ajustes JS para execução do Ayllos em modo embarcado no CRM. (Christian Grosch - CECRED)
 * 047: [22/05/2018] Ajuste para calcular o desconto parcial da parcela - P298 Pos Fixado. (James)
 * 048: [03/07/2018] Marcos (Envolti): Inclusão de campos de IOF do Prejuízo
 * 049: [22/05/2018] Ajuste para calcular o desconto parcial da parcela - P298 Pos Fixado. (James)
 * 050: [07/06/2018] Tratamento para nao permitir desfazer efetivação de emprestimo CDC. PRJ439 (Odirlei-AMcom)
 * 049: [01/08/2018] Ajuste para apresentar valores negativos na tela de prejuizo - INC0019253. (Andre Bohn - MoutS)
 * 050: [12/09/2018] P442 - Ajustes nos tamanhos de tela e mascaras para apresentacao de Consultas Automatizadas novas (Diogo-Envolti)
 * 047: [09/07/2018] Criado opção para tela de controles (Qualificação da Operação e Contratos Liquidados)
 *	   			   	 PJ450 - Diego Simas (AMcom)
 * 048: [20/08/2018] Ajustado a função mostraExtrato para não exibir o conteúdo carregado em telas anteriores da divUsoGenerico
 *                   PJ450 - Diego Simas (AMcom)  
 * 049: [19/11/2018] Alterado layout da tela frmNovaProp (Dados da Solicitação), tela Garantias (agora Rating)
 *                    Avalistas, Interveniente e Dados da Alienação(frmHipoteca) - PRJ 438. (Mateus Z / Mouts)
 * 050: [10/05/2019] P438 Bloqueio da impressao do contrato para linhas 7080 e 7081. (Douglas Pagel / AMcom)
 * 051: [25/05/2019] - PRJ298.2.2 - Pagamento do prejuízo de forma manual - Nagasava (Supero)
 * 052: [02/07/2019] Incluida mensagem na tela de consulta do prejuízo quando o contrato Pós-Fixado for transferido para prejuízo
 *                   P298.3 Pos Fixado (Darlei Zillmer / Supero)
 * 053: [28/06/2019] Ajuste para que ao final do fluxo de consulta volte para a tabela de prestações PRJ 438 (Mateus Z / Mouts)
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
var cdlcremp  = 0;
var qttolatr  = 0;
var dtvencto  = '';

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
var nrparepr_pos  = 0;
var vlpagpar_pos  = 0;
var glb_nriniseq  = 1;
var glb_nrregist  = 50;
var idSocio 	  = 0;
var flmail_comite = 0;

var arrayBensAssoc = new Array();
var arrayDadosPortabilidade = new Array();

var valorTotAPagar, valorAtual , valorTotAtual;

var nrctremp1, qtdregis1, nrdconta1, lstdtvcto1, lstdtpgto1, lstparepr1, lstvlrpag1;

var aux_fluxo = Array(); //bruno - prj - 438 - sprint 6 - voltar
var aux_inpessoa = "";

function cpfMascara(val) { 
	return val.replace(/\D/g, '').length > 11 ? '99.999.999/9999-99' : '999.999.999-99';
}
	

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
			showError('error','N&atilde;o foi possível concluir a requisi&ccedil;&atilde;o.','Alerta - Aimaro','bloqueiaFundo(divRotina)');
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

	//bruno - prj - 438 - sprint 6
	/*if(aux_fluxo.indexOf('TC') > -1 && operacao == 'TC'){
		aux_fluxo = Array();
	}
	aux_fluxo.push(operacao);*/

	//bruno - prj 438 - sprint 6 - sumir campos rating
	aux_inpessoa = inpessoa;
	var mensagem = '';
	var iddoaval_busca = 0;
	var inpessoa_busca = 0;
	var nrdconta_busca = 0;
	var nrcpfcgc_busca = 0;
	var qtpergun = 0;
	var nrseqrrq = 0;
	var vlprecar = '';

	if ( in_array(operacao,['']) ) {
		nrctremp = '';
	}

    // validacao de contingencia Integracao CDC
    var flintcdc       = $("#tabPrestacao table tr.corSelecao").find("input[id='flintcdc']").val();
    var inintegra_cont = $("#tabPrestacao table tr.corSelecao").find("input[id='inintegra_cont']").val();
    var tpfinali       = $("#tabPrestacao table tr.corSelecao").find("input[id='tpfinali']").val();
    var cdoperad       = $("#tabPrestacao table tr.corSelecao").find("input[id='cdoperad']").val();

	if(tpfinali == 3 && cdoperad=='AUTOCDC'){
        
        // botao Registrar GRV
		if (operacao == 'D_EFETIVA'){
				showError('error', 'Não é permitido desfazer efetivação, proposta com origem na integração CDC!', 'Alerta - Aimaro', "hideMsgAguardo(); blockBackground(parseInt($('#divRotina').css('z-index')));");
				return false;			
		// botao efetivar
		}
    }

  
	if ( in_array(operacao,['TC','IMP', 'C_PAG_PREST', 'C_PAG_PREST_POS', 'D_EFETIVA', 'C_TRANSF_PREJU', 'C_DESFAZ_PREJU', 'PORTAB_CRED', 'PORTAB_CRED_C', 'C_LIQ_MESMO_DIA', 'ALT_QUALIFICA', 'CONTROLES', 'CON_CONTRATOS_LIQ'] ) ) {

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

				if (typeof $('#cdlcremp', $(this) ).val() != 'undefined'){
					cdlcremp = $('#cdlcremp', $(this) ).val();
			}

				if (typeof $('#qttolatr', $(this) ).val() != 'undefined'){
					qttolatr = $('#qttolatr', $(this) ).val();
				}
			}
		});
		if ( nrctremp == '' && operacao != 'PORTAB_CRED') { return false; }
	}

	switch (operacao) {
		case 'IMP' :
			validaImpressao(operacao);
			return false;
			break;
		case 'C_DESCONTO':
		case 'C_DESCONTO_POS':
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
				showError('error','N&atilde;o existem informa&ccedil;&otilde;es complementares para este contrato.','Alerta - Aimaro','bloqueiaFundo(divRotina)');
				return false;
			}
			idSocio = 0;
			mensagem = 'abrindo consultar ...';
			operacao = 'C_NOVA_PROP';
			break;
		case 'C_BENS_ASSOC' :
			//initArrayBens('C_BENS_ASSOC');
			//mostraTabelaBens('BT','C_BENS_ASSOC');

			//bruno - prj - 438 - sprint 6 - ocultação telas
			fechaBens();
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
			//initArrayBens('C_BENS_ASSOC');
			//mostraTabelaBens('BT','C_BENS_ASSOC');

			//bruno - prj - 438 - sprint 6 - ocultação telas
			fechaBens();
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
		/*case 'C_PAG_PREST' : */
		case 'C_PAG_PREST_POS' :
			fechaRotina($('#divUsoGenerico'),$('#divRotina'));
			//if(tpemprst != 1 && tpemprst != 2){
            if( tpemprst != 2){
				showError('error','O produto n&atilde;o possui essa op&ccedil;&atilde;o.','Alerta - Aimaro','bloqueiaFundo(divRotina)');
				return false;
			}
            break;
			/*mensagem = 'abrindo pagamento ...';*/
		case 'C_PAG_PREST_PREJU':
			fechaRotina($('#divUsoGenerico'),$('#divRotina'));
			mensagem = 'abrindo pagamento de prejuizo...';
			break;
		case 'C_PAG_PREST_POS_PRJ':
			fechaRotina($('#divUsoGenerico'),$('#divRotina'));
			mensagem = 'abrindo pagamento de prejuizo pos...';
			break;
		case 'D_EFETIVA' :
			mensagem = 'validando informa&ccedil;&otilde;es';
			cddopcao = 'D';
			break;
		case 'E_EFETIVA' :
			showConfirmacao('Confirmar opera&ccedil;&atilde;o?','Confirma&ccedil;&atilde;o - Aimaro','controlaOperacao("TD_EFETIVA");','controlaOperacao("")','sim.gif','nao.gif');
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
				showError('error','O produto n&atilde;o possui essa op&ccedil;&atilde;o.','Alerta - Aimaro','bloqueiaFundo(divRotina)');
				return false;
			}
			*/					
			mensagem = 'Transferindo Contrato para Prejuizo...';
			cddopcao = 'U';
			break;	
		case 'C_DESFAZ_PREJU' :
			if(tpemprst != 1){
				showError('error','O produto n&atilde;o possui essa op&ccedil;&atilde;o.','Alerta - Aimaro','bloqueiaFundo(divRotina)');
				return false;
			}
								
			mensagem = 'Desfazendo Transferencia para Prejuizo...';
			cddopcao = 'Q';
			break;
		case 'PORTAB_CRED' :
			mostraDivPortabilidade(operacao);
			return false;
			break;
		case 'CONTROLES':
			mostraDivControles(operacao);
			return false;
			break;
		case 'CON_QUALIFICA':
		case 'ALT_QUALIFICA':
			mostraDivQualificaControle(operacao);
			return false;
			break;
		case 'CON_CONTRATOS_LIQ':
			mostraDivContratosALiquidar(operacao);
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
		case 'C_GAROPC' :
            if (normalizaNumero(arrayProposta['idcobope']) > 0) {
                abrirTelaGAROPC();
            } else {
                controlaOperacao('C_DADOS_AVAL');
            }
            return false;
			break;
		case 'C_HISTORICO_GRAVAMES' :
			mostraTabelaHistoricoGravames();
			return false;
			break;
			
		default   :
			cddopcao = 'C';
			mensagem = 'abrindo consultar...';
			
			arrayDadosPortabilidade = new Array();			
			break;
	}
	
	if (operacao != 'C_DESCONTO' && operacao != 'C_DESCONTO_POS' && operacao != 'C_LIQ_MESMO_DIA') {
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
            dtvencto: dtvencto,
			nrparepr_pos: nrparepr_pos,
			vlpagpar_pos: vlpagpar_pos,
            cdlcremp: cdlcremp,
            qttolatr: qttolatr,
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
			cdlcremp : cdlcremp,
			redirect: 'html_ajax'
		},
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError('error','N&atilde;o foi possível concluir a requisi&ccedil;&atilde;o.','Alerta - Aimaro','bloqueiaFundo(divRotina)');
		},
		success: function(response) {
		
			if ( response.indexOf('showError("error"') == -1 ) {
				if (operacao == 'C_DESCONTO' || operacao == 'C_DESCONTO_POS') {
					eval( response );
					hideMsgAguardo();
					bloqueiaFundo(divRotina);
				} else {

					//bruno - prj - 438 - sprint 6 - ocultação
					if(in_array(operacao,Array('C_DADOS_PROP','C_DADOS_PROP_PJ'))){
						eval(response);
						//aux_fluxo.pop(); //bruno - prj - 438 - sprint 6 - voltar
						return false;
					}else if(in_array(operacao,Array('C_PROTECAO_TIT','C_PROTECAO_AVAL','C_PROTECAO_CONJ','C_PROTECAO_SOC'))){
						eval(response);
						//aux_fluxo.pop(); //bruno - prj - 438 - sprint 6 - voltar
						return false;
					}else if(operacao == 'C_COMITE_APROV'){
						eval(response);
						//aux_fluxo.pop(); //bruno - prj - 438 - sprint 6 - voltar
						return false;
					}else if(operacao == 'C_PROT_CRED'){
						// PRJ 438 - Sprint 13 - Ajuste para que ao final do fluxo volte para a tabela de prestações (Mateus Z / Mouts)
						controlaOperacao('');
						return false;
					}


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
		if($('label[for="dsmorapos"]').css('display') == 'block'){
            altura   = '310px';
        }else{
            altura   = '270px';
        }
		largura  = '485px';
		
		
		var rRotulos     = $('label[for="dtprejuz"],label[for="vlprejuz"],label[for="slprjori"],label[for="vlrpagos"],label[for="vlttmupr"],label[for="vlttjmpr"],label[for="vltiofpr"],label[for="vlsdprej"]','#'+nomeForm);
		var cTodos       = $('select,input','#'+nomeForm);

		var rRotuloLinha = $('label[for="vlacresc"],label[for="vljraprj"],label[for="vljrmprj"],label[for="vlrabono"],label[for="vlpgmupr"],label[for="vlpgjmpr"],label[for="vlpiofpr"],label[for="tpdrisco"],label[for="nrdiaatr"]','#'+nomeForm);

		var cTodosMoeda  = $('#vlrabono,#vlprejuz,#vljrmprj,#slprjori,#vljraprj,#vlrpagos,#vlacresc,#vlsdprej,#vlttmupr,#vlpgmupr,#vlttjmpr,#vlpgjmpr,#vlpiofpr,#vltiofpr,#vliofcpl','#'+nomeForm);


		cTodosMoeda.addClass('monetario');
		cTodos.addClass('campo').css('width','123px');

		$('#nrdiaatr').css('text-align','right');
		$('#dtprejuz').css('text-align','right');

		rRotulos.addClass('rotulo').css('width','95px');
		rRotuloLinha.addClass('rotulo-linha').css('width','112px');;

		cTodos.desabilitaCampo();

		if (tpemprst == 2) {
		    $('label[for="tpdrisco"]').hide();
		    $('#tpdrisco').hide();
		} else {
		    $('label[for="nrdiaatr"]').hide();
		    $('#nrdiaatr').hide();
		}

	} else if ( in_array(operacao,['TC']) ) {

		nomeForm = 'frmDadosPrest';
		altura   = '500px';
		largura  = '495px';

		var rRotulos     = $('label[for="nrctremp"],label[for="qtaditiv"],label[for="vlemprst"],label[for="vlsdeved"],label[for="vlpreemp"],label[for="vlprepag"],label[for="vlpreapg"],label[for="dslcremp"],label[for="dsdaval1"],label[for="dsdaval2"],label[for="dsdpagto"],label[for="dsfinemp"],label[for="vlmtapar"],label[for="vlmrapar"],label[for="vltotpag"],label[for="vliofcpl"]','#'+nomeForm);
		var cTodos       = $('select,input','#'+nomeForm);

        var rRotulosPosFixado = $('label[for="tpatuidx"],label[for="idcarenc"],label[for="dtcarenc"]','#'+nomeForm);
        var cPosFixado   = $('#tpatuidx, #idcarenc, #dtcarenc, #nrdiacar','#'+nomeForm);

		var rRotuloLinha = $('label[for="cdpesqui"],label[for="txmensal"],label[for="txjuremp"],label[for="vljurmes"],label[for="vljuracu"],label[for="dspreapg"],label[for="qtmesdec"]','#'+nomeForm);

		var cPesquisa 	= $('#cdpesqui','#'+nomeForm);
		var rPesquisa   = $('label[for="cdpesqui"]','#'+nomeForm );
		var r_Linha2    = $('label[for="txmensal"],label[for="txjuremp"],label[for="vljurmes"],label[for="vljuracu"],label[for="dspreapg"],label[for="qtmesdec"]','#'+nomeForm );
		var cTodosGr    = $('#dsdaval1,#dsdaval2,#dsdpagto,#dslcremp,#dsfinemp','#'+nomeForm);

		var cMoeda      = $('#vlemprst,#vlsdeved,#vlpreemp,#vlprecar,#vlprepag,#vlpreapg,#vljuracu,#vljurmes,#vlmtapar,#vlmrapar,#vltotpag,#vliofcpl','#'+nomeForm);
		var cContrato   = $('#nrctremp','#'+nomeForm);
		var cTaxaMes	= $('#txmensal','#'+nomeForm);
		var cTaxaJuros  = $('#txjuremp','#'+nomeForm);
		var cMesesDeco  = $('#qtmesdec','#'+nomeForm);
		var cQtAditiv   = $('#qtaditiv','#'+nomeForm);
		var cVlIofCpl   = $('#vliofcpl','#'+nomeForm);

		cQtAditiv.addClass('inteiro');
		cTaxaMes.addClass('porcento_7');
		cTaxaJuros.addClass('porcento_7');
		cContrato.setMask('INTEGER','zzz.zzz.zz9','.','');
		cMesesDeco.addClass('inteiro');

		cMoeda.addClass('moeda');
		cTodos.addClass('campo').css('width','131px');
        cPosFixado.css('width','110px');

		rRotulos.addClass('rotulo').css('width','85px');
		rRotuloLinha.addClass('rotulo-linha').css('width','112px');
        rRotulosPosFixado.addClass('rotulo-linha').css('width','144px');
        $('label[for="nrdiacar"]','#'+nomeForm).addClass('rotulo').css('width','366px');

		// Hack IE
		if ( $.browser.msie ) {
			cTodosGr.css({'width':'388px'});
		} else {
			cTodosGr.css({'width':'391px'});
		}

		r_Linha2.css('width','123px');
		rPesquisa.css('width','60px');
		cPesquisa.css({'width':'194px'});

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
		altura   = tpemprst == 2 ? '300px' : '255px';
		largura  = '700px';

		inconfir = 1;

		var rRotulos     = $('label[for="nivrisco"],label[for="qtpreemp"],label[for="vlpreemp"],label[for="vlemprst"],label[for="tpemprst"],label[for="flgimppr"],label[for="dsctrliq"],label[for="cdlcremp"]','#'+nomeForm );
		var cTodos       = $('select,input'    ,'#'+nomeForm);
		var rCet     	 = $('label[for="percetop"]','#'+nomeForm );
		var rDiasUteis   = $('#duteis','#'+nomeForm );
		var cCodigo		 = $('#cdfinemp,#idquapro,#idquaprc,#cdlcremp','#'+nomeForm);
		var cDescricao   = $('#dsfinemp,#dsquapro,#dsquaprc,#dslcremp','#'+nomeForm);

		var rNivelRic    = $('label[for="nivrisco"]','#'+nomeForm);
		var rRiscoCalc   = $('label[for="nivcalcu"]','#'+nomeForm);
		var rVlEmpr      = $('label[for="vlemprst"]','#'+nomeForm);
		var rLnCred      = $('label[for="cdlcremp"]','#'+nomeForm);
		var rDsLnCred    = $('label[for="dslcremp"]','#'+nomeForm);
		var rVlPrest     = $('label[for="vlpreemp"]','#'+nomeForm);
		var rVlPreCar    = $('label[for="vlprecar"]','#'+nomeForm);
		var rFinali      = $('label[for="cdfinemp"]','#'+nomeForm);
		var rDsFinali    = $('label[for="dsfinemp"]','#'+nomeForm);
		var rQtParc      = $('label[for="qtpreemp"]','#'+nomeForm);
		var rQualiParc   = $('label[for="idquapro"]','#'+nomeForm);
		var rDsQualiParc = $('label[for="dsquapro"]','#'+nomeForm);
		var rQualiParcC  = $('label[for="idquaprc"]', '#' + nomeForm);
		var rDsQualiParcC = $('label[for="dsquaprc"]', '#' + nomeForm);

		var rDebitar     = $('label[for="flgpagto"]','#'+nomeForm);
		var rPercCET	 = $('label[for="percetop"]','#'+nomeForm);
		var rLiberar 	 = $('label[for="qtdialib"]','#'+nomeForm);

		var rDtPgmento   = $('label[for="dtdpagto"]','#'+nomeForm);
        var rIdFinIof   = $('label[for="idfiniof"]','#'+nomeForm);
		var rProposta    = $('label[for="flgimppr"]','#'+nomeForm);
		var rNtPromis    = $('label[for="flgimpnp"]','#'+nomeForm);
		var rLiquidacoes = $('label[for="dsctrliq"]','#'+nomeForm);
		var rDtLiberar   = $('label[for="dtlibera"]','#'+nomeForm);
        var rIdcarenc = $('label[for="idcarenc"]', '#' + nomeForm);
        var rDtcarenc = $('label[for="dtcarenc"]', '#' + nomeForm);
        var rTpemprst = $('label[for="tpemprst"]', '#' + nomeForm);
        var rFlgdocje = $('label[for="flgdocje"]', '#' + nomeForm);

		var cNivelRic    = $('#nivrisco','#'+nomeForm);
		var cRiscoCalc   = $('#nivcalcu','#'+nomeForm);
		var cVlEmpr      = $('#vlemprst','#'+nomeForm);
		var cLnCred      = $('#cdlcremp','#'+nomeForm);
		var cDsLnCred    = $('#dslcremp','#'+nomeForm);
		var cVlPrest     = $('#vlpreemp','#'+nomeForm);
		var cVlPreCar   = $('#vlprecar','#'+nomeForm);
		var cFinali      = $('#cdfinemp','#'+nomeForm);
		var cDsFinali    = $('#dsfinemp','#'+nomeForm);
		var cQtParc      = $('#qtpreemp','#'+nomeForm);
		var cQualiParc   = $('#idquapro','#'+nomeForm);
		var cDsQualiParc = $('#dsquapro','#'+nomeForm);
		var cQualiParcC  = $('#idquaprc', '#' + nomeForm);
		var cDsQualiParcC = $('#dsquaprc', '#' + nomeForm);
		var cDebitar     = $('#flgpagto','#'+nomeForm);
		var cPercCET	 = $('#percetop','#'+nomeForm);
		var cTipoEmpr 	 = $('#tpemprst','#'+nomeForm);
		var cLiberar 	 = $('#qtdialib','#'+nomeForm);
		var cDtlibera    = $('#dtlibera','#'+nomeForm);
		var cDtPgmento   = $('#dtdpagto','#'+nomeForm);
        var cIdFinIof   = $('#idfiniof','#'+nomeForm);
		var cProposta    = $('#flgimppr','#'+nomeForm);
		var cNtPromis    = $('#flgimpnp','#'+nomeForm);
		var cLiquidacoes = $('#dsctrliq','#'+nomeForm);
        var cIdcarenc = $('#idcarenc', '#' + nomeForm);
        var cDtcarenc = $('#dtcarenc', '#' + nomeForm);
        var cCoresp   = $('#flgdocje','#'+nomeForm);

		var rDsratpro = $('label[for="dsratpro"]','#'+nomeForm);
		var rDsratatu = $('label[for="dsratatu"]','#'+nomeForm);

		var cDsratpro = $('#dsratpro','#'+nomeForm);
		var cDsratatu = $('#dsratatu','#'+nomeForm);
		
		cNivelRic.addClass('rotulo').css('width','90px');
        cRiscoCalc.addClass('').css('width','108px');
        cVlEmpr.addClass('rotulo moeda').css('width','90px');
        cLnCred.css('width','35px').attr('maxlength','3');
        cDsLnCred.css('width','108px');
        cVlPrest.addClass('moeda').css('width','90px');
        cVlPreCar.addClass('moeda').css('width','90px');
        cFinali.addClass('rotulo').css('width','35px');
        cDsFinali.css('width','108px');
        cQtParc.addClass('rotulo').css('width','50px').setMask('INTEGER','zz9','','');
        cQualiParc.addClass('rotulo').css('width','35px');
        cDsQualiParc.addClass('').css('width','108px');
        cQualiParcC.addClass('rotulo').css('width', '35px');
		cDsQualiParcC.addClass('').css('width', '108px');
        cDebitar.addClass('rotulo').css('width','90px');
        cPercCET.addClass('porcento').css('width','45px');
        cTipoEmpr.addClass('rotulo').css('width','90px');
        cLiberar.addClass('rotulo inteito').css('width','45px').attr('maxlength','3');
        cDtlibera.css('width','108px').setMask("DATE","","","divRotina");
		cDtPgmento.css('width','108px').setMask("DATE","","","divRotina");
        cProposta.addClass('rotulo').css('width','108px');
		cNtPromis.addClass('').css('width','108px');
		cLiquidacoes.addClass('rotulo alphanum').css('width','320px');
        cIdcarenc.css('width', '108px');
        cDtcarenc.css('width', '108px');

		rRotulos.addClass('rotulo').css('width','75px');
		rDtLiberar.css('width','321px');


		rLiberar.css('width','153px');
		rProposta.css('width','75px');

		rRiscoCalc.addClass('').css('width','153px');
		rLnCred.addClass('').css('width','140px');
		rFinali.addClass('').css('width','140px');
		rQualiParc.addClass('rotulo-linha').css('width','276px');
        rQualiParcC.addClass('rotulo-linha').css('width', '200px');
		rPercCET.addClass('rotulo-linha').css('width','276px');
        rIdFinIof.addClass('rotulo-linha').css('width','276px');
		rDtPgmento.addClass('rotulo').css('width','140px');
		rNtPromis.addClass('rotulo-linha').css('width', '132px');
		rDiasUteis.addClass('rotulo-linha');
        rIdcarenc.addClass('rotulo').css('width', '140px');
        rDtcarenc.addClass('rotulo').css('width', '140px');
        rDebitar.addClass('rotulo-linha').css('width','276px');
        rVlEmpr.css('width','140px');
        rNivelRic.css('width','140px');
        rTpemprst.css('width','140px');
        rVlPrest.css('width','140px');
        rQtParc.css('width','140px');
        rLiquidacoes.css('width','140px');
        rFlgdocje.addClass('rotulo-linha').css('width','259px');
		rVlPreCar.addClass('rotulo-linha').css('width','259px');

		rDsratpro.addClass('rotulo-linha').css('width','200px');
		rDsratatu.addClass('rotulo-linha').css('width','316px');
		cDsratpro.addClass('rotulo').css('width','108px');
		cDsratatu.addClass('rotulo').css('width','108px');

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

        if (tpemprst == 2) { // Se for Pos-Fixado
            $("#linCarencia", "#frmNovaProp").show();
            rVlPreCar.show();
            cVlPreCar.show();
        } else {
            $("#linCarencia", "#frmNovaProp").hide();
            rVlPreCar.hide();
            cVlPreCar.hide();
        }

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

		var inpessoa = $('#inpessoa','#'+nomeForm).val();
		// PRJ 438 - Sprint 6 - Alteração no layout da tela Avalistas
		altura  = inpessoa == 1 ? '480px' : '410px';
        largura = '508px';

		var cTodos  = $('select,input','#'+nomeForm+' fieldset:eq(0)');

		var rRotulo = $('label[for="qtpromis"],label[for="nmdavali"],label[for="tpdocava"],label[for="nrctaava"],label[for="inpessoa"],label[for="nrcpfcgc"],label[for="dsnacion"]','#'+nomeForm );
		var rDtnascto    = $('label[for="dtnascto"]','#'+nomeForm );

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

		rRotulo.addClass('rotulo').css('width','80px');
		rDtnascto.addClass('rotulo-linha');

		cQntd.css('width','60px').setMask('INTEGER','zz9','','');
		cConta.addClass('conta pesquisa').css('width','115px');
		cCPF.css('width','134px');
		cNome.addClass('alphanum').css('width','255px').attr('maxlength','40');
		cDoc.css('width','50px');
		cNrDoc.addClass('alphanum').css('width','202px').attr('maxlength','40');
		cNacio.addClass('alphanum').css('width','114px').attr('maxlength','13');
		
		cInpessoa.css('width','20px').setMask('INTEGER','9','',''); // Daniel
		cDspessoa.css('width','145px'); // Daniel
		cDtnascto.css('width','70px'); // Daniel

		var cTodos_1    = $('select,input','#'+nomeForm+' fieldset:eq(1)');

		var rRotulo_1 = $('label[for="nmconjug"],label[for="tpdoccjg"],label[for="nrctacjg"]','#'+nomeForm );
		var rCpf_1    = $('label[for="nrcpfcjg"]','#'+nomeForm );
		var rVlrencjg = $('label[for="vlrencjg"]', '#' + nomeForm);

		var cConj    = $('#nmconjug','#'+nomeForm);
		var cCPF_1   = $('#nrcpfcjg','#'+nomeForm);
		var cDoc_1   = $('#tpdoccjg','#'+nomeForm);
		var cNrDoc_1 = $('#nrdoccjg','#'+nomeForm);
		var cNrctacjg = $('#nrctacjg', '#' + nomeForm);
		var cVlrencjg = $('#vlrencjg', '#' + nomeForm);

		rRotulo_1.addClass('rotulo').css('width','50px');
		rCpf_1.addClass('').css('width','117px');
		rVlrencjg.addClass('rotulo-linha').css('width', '70px');

		cConj.addClass('alphanum').css('width','200px').attr('maxlength','40');
		cCPF_1.css('width','134px');
		cDoc_1.css('width','50px');
		cNrDoc_1.addClass('alphanum').css('width','197px').attr('maxlength','40');
		cNrctacjg.addClass('conta');
		cVlrencjg.addClass('moeda').css('width', '100px');

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
		rTel.addClass('rotulo');
		rEma.addClass('rotulo-linha').css('width','55px');

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
		cTel.css('width','100px').attr('maxlength','20');
		cEma.css('width','237px').attr('maxlength','30');

		var cTodos_4    = $('select,input','#'+nomeForm+' fieldset:eq(4)');

		var rRenda = $('label[for="vlrenmes"]', '#' + nomeForm);
		rRenda.addClass('rotulo').css('width', '120px');
		var cRenda = $('#vlrenmes', '#' + nomeForm);
		cRenda.addClass('moeda').css('width', '130px');

		cTodos.desabilitaCampo();
		cTodos_1.desabilitaCampo();
		cTodos_2.desabilitaCampo();
		cTodos_3.desabilitaCampo();
		cTodos_4.desabilitaCampo();

		// PRJ 438 - Sprint 6 - Se for pessoa juridica, altera o label dos campos e esconder os dados do conjuge
		if(inpessoa == 2){ // pessoa juridica
			$('label[for="nrcpfcgc"]','#'+nomeForm).text('C.N.P.J:');
			$('label[for="nmdavali"]','#'+nomeForm).text('Razão Social:');
			$('label[for="dtnascto"]','#'+nomeForm).text('Data da Abertura:');
			$('label[for="vlrenmes"]','#'+nomeForm).css('width', '150px').text('Faturamente Médio Mensal:');
			$('#fsetConjugeAval','#'+nomeForm).hide();
      		//$(cNacio).hide(); //bruno - prj 438 - bug 14476
		}

		//bruno - prj 438 - bug 14652
		if($('#nrctaava','#frmDadosAval').val() == "" || $('#nrctaava','#frmDadosAval').val() == "0"){
			$(cDtnascto).show();
			$(rDtnascto).show();
			$(cEma).show();
			$(rEma).show();
			if(inpessoa == '1'){ //bruno - prj 438 - bug 14749
				$(rDtnascto).text('Data Nasc.:');
			}else if(inpessoa == '2'){
				$(rDtnascto).text('Data de Abertura:');
			}
		}else{
			$(cDtnascto).hide();
			$(rDtnascto).hide();
		$(cEma).hide();
		$(rEma).hide();
		}


	} else if (in_array(operacao,['C_PROTECAO_TIT','C_PROTECAO_AVAL','C_PROTECAO_CONJ','C_PROTECAO_SOC'])){

		altura   = '550px';
		largura  = '510px';
	
		formata_protecao (operacao, arrayProtCred['nrinfcad'] , arrayProtCred['dsinfcad'] );
		
			
	} else if (in_array(operacao,['C_HIPOTECA'])){

		nomeForm = 'frmHipoteca';
        altura = '345px';
        largura = '480px';

		var cTodos  = $('select,input' ,'#'+nomeForm);
        var rRotulo = $('label[for="dscatbem"],label[for="dsbemfin"],label[for="vlmerbem"],label[for="dsclassi"],label[for="vlrdobem"]', '#' + nomeForm);
        var rRotuloLinha = $('label[for="vlareuti"],label[for="vlaretot"],label[for="nrmatric"]', '#' + nomeForm);
        var rRotuloEnd = $('label[for="nrcepend"],label[for="nrendere"],label[for="nmbairro"],label[for="nmcidade"]', '#' + nomeForm);
		var rTitulo = $('#lsbemfin','#'+nomeForm );
        var rCom = $('label[for="dscompend"]', '#' + nomeForm);
        var rEnd = $('label[for="dsendere"]', '#' + nomeForm);
        var rUf  = $('label[for="cdufende"]', '#' + nomeForm);

		var cCateg  = $('#dscatbem','#'+nomeForm);
		var cVlMerc = $('#vlmerbem','#'+nomeForm);
		var cDesc  	= $('#dsbemfin','#'+nomeForm);
        var cVlvend = $('#vlrdobem', '#' + nomeForm);
        var cMatric = $('#nrmatric', '#' + nomeForm);
        var cAreaUtil = $('#vlareuti', '#' + nomeForm);
        var cAreaTot = $('#vlaretot', '#' + nomeForm);
        var cClassif = $('#dsclassi', '#' + nomeForm);     

	    // CAMPOS - ENDEREÇO
		var cCep	= $('#nrcepend', '#' + nomeForm);
		var cEnd	= $('#dsendere', '#' + nomeForm);
		var cNum	= $('#nrendere', '#' + nomeForm);
		var cCom	= $('#dscompend', '#' + nomeForm);
		var cBai	= $('#nmbairro', '#' + nomeForm);
		var cEst	= $('#cdufende', '#' + nomeForm);
		var cCid	= $('#nmcidade', '#' + nomeForm);    

        rRotulo.addClass('rotulo').css('width', '80px');
        rRotuloLinha.addClass('rotulo-linha').css('width', '80px');
		rTitulo.addClass('').css({'width':'253px','clear':'both'});
        //Endereço
        rRotuloEnd.addClass('rotulo').css('width', '41px');
        rCom.addClass('rotulo-linha').css('width','50px');
        rEnd.addClass('rotulo-linha').css('width','30px');
        rUf.addClass('rotulo-linha').css('width','56px');

        cCateg.css('width', '132px');
        cClassif.css('width', '132px');
		cVlMerc.addClass('moeda').css('width','132px');
        cVlvend.addClass('moeda').css('width', '132px');
        cMatric.attr('maxlength', '10');
        cAreaUtil.attr('maxlength', '10');
        cAreaTot.attr('maxlength', '10');
        cDesc.addClass('alphanum').css('width', '365px').attr('maxlength', '50');
        cNum.addClass('alphanum').css('width', '65px');
        cCom.addClass('alphanum').css('width', '275px').attr('maxlength', '50');
	    cCep.addClass('cep pesquisa').css('width','65px').attr('maxlength','9');
		cEnd.addClass('alphanum').css('width','275px').attr('maxlength','40');
		cBai.addClass('alphanum').css('width','270px').attr('maxlength','40');	
		cEst.css('width','62px');
		cCid.addClass('alphanum').css('width','270px').attr('maxlength','25'); 

		cTodos.desabilitaCampo();


	}else if (in_array(operacao,['C_PROT_CRED'])){

		nomeForm = 'frmOrgProtCred';
		altura   = ( inpessoa == 1 ) ? '140px': '160px' ;
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

		//bruno - prj 438 - sprint 6 - esconder campo rating
		if (aux_inpessoa == 1){ //PF
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

		}else{ //PJ (2||3)
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

		nomeForm = 'frmTipo';
		altura   = '350px';//'215px';
		largura  = '630px';//'452px';
		$('#dssitgrv').parent().css({"margin-top": "20px"});

		var cTodos    = $('select,input','#'+nomeForm);
		var rRotulo   = $('label[for="dscatbem"],label[for="dsbemfin"],label[for="dscorbem"],label[for="ufdplaca"],label[for="nrrenava"],label[for="nrmodbem"]','#'+nomeForm );
		var rNrBem    = $('#lsbemfin','#'+nomeForm);
		var rVlBem    = $('label[for="vlmerbem"]','#'+nomeForm);
		var rTpCHassi = $('label[for="tpchassi"]','#'+nomeForm);
		var rLinha    = $('label[for="dschassi"],label[for="uflicenc"],label[for="nrcpfbem"]','#'+nomeForm);
		var rAnoFab   = $('label[for="nranobem"]','#'+nomeForm);
/*
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
		cCPF.css('width','162px');
*/
		if ( operacao == 'C_ALIENACAO'){
			cTodos.desabilitaCampo();
		}
	//* 001: alterado a função controlaLayout() para formata os campos de endereco e contato.
	}else if (in_array(operacao,['C_INTEV_ANU'])){

		nomeForm = 'frmIntevAnuente';

		var inpessoa = $('#inpessoa','#'+nomeForm).val();

		altura   = inpessoa == 2 ? '387px' : '430px';
		largura  = '498px';

		var cTodos    = $('input,select','#'+nomeForm+' fieldset:eq(0)');

		var rRotulo   = $('label[for="qtpromis"],label[for="nmdavali"],label[for="tpdocava"],label[for="nrctaava"],label[for="inpessoa"],label[for="nrcpfcgc"],label[for="dsnacion"]','#'+nomeForm );

		var rCpf    = $('label[for="nrcpfcgc"]','#'+nomeForm );
		var rNacio  = $('label[for="dsnacion"]','#'+nomeForm );

		var cConta = $('#nrctaava','#'+nomeForm);
		var cCPF   = $('#nrcpfcgc','#'+nomeForm);
		var cNome  = $('#nmdavali','#'+nomeForm);
		var cDoc   = $('#tpdocava','#'+nomeForm);
		var cNrDoc = $('#nrdocava','#'+nomeForm);
		var cNacio = $('#dsnacion','#'+nomeForm);
		var cInpessoa =  $('#inpessoa','#'+nomeForm);
		var cDspessoa =  $('#dspessoa','#'+nomeForm);

		//bruno - prj 438 - bug 14585
        var cDtnascto = $('#dtnascto', '#' + nomeForm);
        var rDtnascto = $('label[for="dtnascto"]', '#' + nomeForm);
        cDtnascto.addClass('data').css({'width': '100px'}); //Adicionando mascara para data e fixando tamanho do campo em 100px
        //fim alteração bug 14585 cdnacion

		rRotulo.addClass('rotulo').css('width','80px');

		cConta.addClass('conta pesquisa').css('width','115px');
		cCPF.css('width','134px');
		cNome.addClass('alphanum').css('width','255px').attr('maxlength','40');
		cDoc.css('width','50px');
		cNrDoc.addClass('alphanum').css('width','202px').attr('maxlength','40');
		cNacio.addClass('pesquisa alphanum').css('width','114px').attr('maxlength','13');
		cInpessoa.css('width','20px').setMask('INTEGER','9','','');
		cDspessoa.css('width','145px');

		var cTodos_1    = $('input,select','#'+nomeForm+' fieldset:eq(1)');

		var rRotulo_1 = $('label[for="nmconjug"],label[for="tpdoccjg"],label[for="nrctacjg"]','#'+nomeForm );
		var rCpf_1    = $('label[for="nrcpfcjg"]','#'+nomeForm );
		var rVlrencjg = $('label[for="vlrencjg"]', '#' + nomeForm);

		var cConj    = $('#nmconjug','#'+nomeForm);
		var cCPF_1   = $('#nrcpfcjg','#'+nomeForm);
		var cDoc_1   = $('#tpdoccjg','#'+nomeForm);
		var cNrDoc_1 = $('#nrdoccjg','#'+nomeForm);
		var cVlrencjg = $('#vlrencjg', '#' + nomeForm);

		rRotulo_1.addClass('rotulo').css('width','50px');
		rCpf_1.addClass('').css('width','40px');
		rVlrencjg.addClass('rotulo-linha').css('width', '70px');

		cConj.addClass('alphanum').css('width','250px').attr('maxlength','40');
		cCPF_1.css('width','134px');
		cDoc_1.css('width','50px');
		cNrDoc_1.addClass('alphanum').css('width','197px').attr('maxlength','40');
		cVlrencjg.addClass('moeda').css('width', '100px');

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
		rTel.addClass('rotulo');
		rEma.addClass('rotulo-linha').css('width','55px');

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
		cTel.css('width','100px').attr('maxlength','20');
		cEma.css('width','237px').attr('maxlength','30');

		cTodos.desabilitaCampo();
		cTodos_1.desabilitaCampo();
		cTodos_2.desabilitaCampo();
		cTodos_3.desabilitaCampo();

		// PRJ 438 - Sprint 6 - Se for pessoa juridica, altera o label dos campos e esconder os dados do conjuge
		if(inpessoa == 2){ // pessoa juridica
			$('label[for="nrcpfcgc"]','#'+nomeForm).text('C.N.P.J:');
			$('label[for="nmdavali"]','#'+nomeForm).text('Razão Social:');
			$('#fsetConjugeInterv','#'+nomeForm).hide();
		}

		

		//bruno - prj 438 - bug 14652
		if($('#nrctaava','#frmIntevAnuente').val() == "" || $('#nrctaava','#frmIntevAnuente').val() == "0"){
			$(cDtnascto).show();
			$(rDtnascto).show();
			$(cEma).show();
			$(rEma).show();
			if(inpessoa == '1'){ //bruno - prj 438 - bug 14749
				$(rDtnascto).text('Data Nasc.:');
			}else if(inpessoa == '2'){
				$(rDtnascto).text('Data de Abertura:');
			}
		}else{
			$(cDtnascto).hide();
			$(rDtnascto).hide();
			$(cEma).hide();
			$(rEma).hide();
		}

	}else if (in_array(operacao,['C_PAG_PREST_PREJU'])){

		nomeForm = 'frmVlParcPreju';
		altura   = '240px';
		largura  = '260px';
		var cAbono  = $('#vlabono','#'+nomeForm);
		var cPagto = $('#vlpagto','#'+nomeForm);
		
	}else if (in_array(operacao,['C_PAG_PREST_POS_PRJ'])){
		
		nomeForm = 'frmVlParcPrejuPos';
		altura   = '240px';
		largura  = '260px';
		var cAbono  = $('#vlabono','#'+nomeForm);
		var cPagto = $('#vlpagto','#'+nomeForm);
		
	}else if (in_array(operacao,['C_PAG_PREST'])){

		nomeForm = 'frmVlParc';
		altura   = '305px';
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
		arrayLargura[9] = '42px';

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

		$("input[type=hidden][name='vliofcpl[]']").each(function() {
			// Valor total a atual
			valorTotAtual +=  retiraMascara ( this.value );
		});

		$('#totatual','#frmVlParc').val(valorTotAtual.toFixed(2).replace(".",",")) ;
		$('#totpagto','#frmVlParc').val('0,00');
		$('#vldifpar','#frmVlParc').val('0,00');
		
	} else if (in_array(operacao,['C_PAG_PREST_POS'])) {

		nomeForm = 'frmVlParc';
		altura   = '295px';
		largura  = '710px';

		var rTotAtual  = $('label[for="totatual"]','#'+nomeForm );
		var cTotAtual  = $('#totatual','#'+nomeForm);
		var rTotPagmto = $('label[for="totpagto"]','#'+nomeForm );
		var cTotPagmto = $('#totpagto','#'+nomeForm);
		var rVlpagmto  = $('label[for="vlpagmto"]','#frmVlPagar');
		var cVlpagmto  = $('#vlpagmto','#frmVlPagar');
		
		var rPagtaval  = $('label[for="pagtaval"]','#'+nomeForm);
		var cPagtaval  = $('#pagtaval','#'+nomeForm);
		
		rTotAtual.addClass('rotulo').css({'width':'110px','padding-top':'3px','padding-bottom':'3px'  });
		rVlpagmto.addClass('rotulo').css({'width':'80px','padding-top':'3px','padding-bottom':'3px'});

		if ( $.browser.msie ) {
			rTotPagmto.addClass('rotulo').css( {'width':'80px' , 'margin-left':'315px' } );
			cTotAtual.addClass('campo').css({'width':'70px','padding-top':'3px','padding-bottom':'3px'   });
			cVlpagmto.addClass('campo').css({'width':'70px','margin-right':'10px'});
			cTotPagmto.addClass('campo').css({'width':'70px','padding-top':'3px','padding-bottom':'3px' , 'margin-left':'09px'  });
		} else{
			rTotPagmto.addClass('rotulo').css( {'width':'80px' , 'margin-left':'322px' } );
			cTotAtual.addClass('campo').css({'width':'70px','padding-top':'3px','padding-bottom':'3px', 'margin-right':'25px'});
			cVlpagmto.addClass('campo').css({'width':'70px','margin-right':'10px'});
			cTotPagmto.addClass('campo').css({'width':'70px','padding-top':'3px','padding-bottom':'3px', 'margin-right':'25px'});
		}

		cTotPagmto.addClass('rotulo moeda').desabilitaCampo();
		cTotAtual.addClass('rotulo moeda').desabilitaCampo();
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
		arrayLargura[6] = '60px';
		arrayLargura[7] = '45px';
		arrayLargura[8] = '57px';

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
		arrayAlinha[9] = 'center';

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

			$("input[type=text][name='vlpagpar[]']").each(function() {
				nrParcela = this.id.split("_")[1];
				var vlr = selec ? $('#check_' + nrParcela).attr('vldescto') : '0,00';
                descontoPos(nrParcela,vlr);
			});

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
            var vlr = $(this).is(':checked') ? $(this).attr('vldescto') : '0,00';
            descontoPos(nrParcela,vlr);
			cVlpagmto.val("");
		});

		$("input[type=text][name='vlpagpar[]']").blur(function() {
			recalculaTotal();
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

		$("input[type=hidden][name='vliofcpl[]']").each(function() {
			// Valor total a atual
			valorTotAtual +=  retiraMascara ( this.value );
		});

		$('#totatual','#frmVlParc').val(valorTotAtual.toFixed(2).replace(".",",")) ;
		$('#totpagto','#frmVlParc').val('0,00');
		
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
		
	} else if (in_array(operacao, ['C_DEMONSTRATIVO_EMPRESTIMO'])){
		 nomeForm = 'frmDemonstracaoEmprestimo';
		 largura = '345px';
		 if (tpemprst == 2) {
			altura = '230px';
		 } else {
		 altura = '205px';
		 }

		 var rVlemprst = $('label[for="vlemprst"]', '#' + nomeForm);
		 var rVliofepr = $('label[for="vliofepr"]', '#' + nomeForm);
		 var rVlrtarif = $('label[for="vlrtarif"]', '#' + nomeForm);
		 var rVlrtotal = $('label[for="vlrtotal"]', '#' + nomeForm);
		 var rVlpreemp = $('label[for="vlpreemp"]', '#' + nomeForm);
		 var rVlprecar = $('label[for="vlprecar"]', '#' + nomeForm);
		 var rPercetop = $('label[for="percetop"]', '#' + nomeForm);

		 var cVlemprst = $('#vlemprst', '#' + nomeForm);
		 var cVliofepr = $('#vliofepr', '#' + nomeForm);
		 var cVlrtarif = $('#vlrtarif', '#' + nomeForm);
		 var cVlrtotal = $('#vlrtotal', '#' + nomeForm);
		 var cVlpreemp = $('#vlpreemp', '#' + nomeForm);
		 var cVlprecar = $('#vlprecar', '#' + nomeForm);
		 var cPercetop = $('#percetop', '#' + nomeForm);

		 rVlemprst.addClass('rotulo').css('width', '100px');
		 rVliofepr.addClass('rotulo').css('width', '100px');
		 rVlrtarif.addClass('rotulo').css('width', '100px');
		 rVlrtotal.addClass('rotulo').css('width', '100px');
		 rVlpreemp.addClass('rotulo').css('width', '100px');
		 rVlprecar.addClass('rotulo').css('width', '100px');
		 rPercetop.addClass('rotulo').css('width', '100px');

		 cVlemprst.addClass('moeda');
		 cVliofepr.addClass('moeda');
		 cVlrtarif.addClass('moeda');
		 cVlrtotal.addClass('moeda');
		 cVlpreemp.addClass('moeda');
		 cVlprecar.addClass('moeda');
		 cPercetop.addClass('moeda');

		 cVlemprst.desabilitaCampo();
		 cVliofepr.desabilitaCampo();
		 cVlrtarif.desabilitaCampo();
		 cVlrtotal.desabilitaCampo();
		 cVlpreemp.desabilitaCampo();
		 cVlprecar.desabilitaCampo();
		 cPercetop.desabilitaCampo();
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

//Função para formatar tabela de Contratos Liquidados
function formataContratosLiq(){
	var divRegistro = $('div.divRegistros','#divUsoGenerico');
	//var divRegistro = $('div.divRegistrosCL');
	var tabela = $('table', divRegistro);
	var linha = $('table > tbody > tr', divRegistro);

	divRegistro.css({ 'height': '160px', 'width': '750px' });

	var ordemInicial = new Array();
	ordemInicial = [[0, 0]];

	var arrayLargura = new Array();
	arrayLargura[0] = '30px';
	arrayLargura[1] = '50px';
	arrayLargura[2] = '51px';
	arrayLargura[3] = '60px';
	arrayLargura[4] = '100px';
	arrayLargura[5] = '60px';
	arrayLargura[6] = '70px';
	arrayLargura[7] = '50px';
	arrayLargura[8] = '70px';
	arrayLargura[9] = '70px';


	var arrayAlinha = new Array();
	arrayAlinha[0] = 'center';
	arrayAlinha[1] = 'center';
	arrayAlinha[2] = 'center';
	arrayAlinha[3] = 'center';
	arrayAlinha[4] = 'center';
	arrayAlinha[5] = 'center';
	arrayAlinha[6] = 'center';
	arrayAlinha[7] = 'center';
	arrayAlinha[8] = 'center';
	arrayAlinha[9] = 'center';

	tabela.formataTabela(ordemInicial, arrayLargura, arrayAlinha);
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
                encerraRotina();
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
		$('#vliofcpl','#frmDadosPrest').val( arrayRegistros['vliofcpl'] );

        // Se for Pos-Fixado
        if (tpemprst == 2) {
            $('#tpatuidx','#frmDadosPrest').val( arrayRegistros['tpatuidx'] );
            $('#idcarenc','#frmDadosPrest').val( arrayRegistros['idcarenc'] );
            $('#dtcarenc','#frmDadosPrest').val( arrayRegistros['dtcarenc'] );
            $('#nrdiacar','#frmDadosPrest').val( arrayRegistros['nrdiacar'] );
        }

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
		$('#vliofcpl','#frmPreju').val( arrayRegistros['vliofcpl'] );
		
		/* Daniel */
		$('#vlttmupr','#frmPreju').val( arrayRegistros['vlttmupr'] );
		$('#vlttjmpr','#frmPreju').val( arrayRegistros['vlttjmpr'] );
		$('#vlpgmupr','#frmPreju').val( arrayRegistros['vlpgmupr'] );
		$('#vlpgjmpr','#frmPreju').val( arrayRegistros['vlpgjmpr'] );

		// Tipo de risco
		$('#tpdrisco','#frmPreju').val( utf8_decode(arrayRegistros['tpdrisco']) );

    // IOF Prejuizo
    $('#vltiofpr','#frmPreju').val( utf8_decode(arrayRegistros['vltiofpr']) );
    $('#vlpiofpr','#frmPreju').val( utf8_decode(arrayRegistros['vlpiofpr']) );
		
        $('#nrdiaatr','#frmPreju').val( utf8_decode(arrayRegistros['nrdiaatr']) );
		
        // Incluida mensagem na tela de consulta do prejuízo quando o contrato Pós-Fixado for transferido para prejuízo
        if(parseInt(arrayRegistros['tpemprst']) == 2 && parseFloat(arrayRegistros['vlttjmpr']) > 0){
            $('label[for="dsmorapos"]').css('display', 'block');
            $('label[for="vlttjmpr"]').html('* Juros de Mora:');
        }
		
	}else if (in_array(operacao,['C_NOVA_PROP','C_NOVA_PROP_V'])){

		$('#nivrisco','#frmNovaProp').val( arrayProposta['nivriori'] != '' ? arrayProposta['nivriori'] : arrayProposta['nivrisco']);
		$('#nivcalcu','#frmNovaProp').val( arrayProposta['nivcalcu'] );
		$('#vlemprst','#frmNovaProp').val( arrayProposta['vlemprst'] );
		$('#cdlcremp','#frmNovaProp').val( arrayProposta['cdlcremp'] );
		$('#vlpreemp','#frmNovaProp').val( arrayProposta['vlpreemp'] );
		$('#vlprecar','#frmNovaProp').val( arrayProposta['vlprecar'] );
		$('#cdfinemp','#frmNovaProp').val( arrayProposta['cdfinemp'] );
		$('#qtpreemp','#frmNovaProp').val( arrayProposta['qtpreemp'] );
		$('#idquapro','#frmNovaProp').val( arrayProposta['idquapro'] );
		$('#idquaprc','#frmNovaProp').val( arrayProposta['idquaprc'] );
		$('#flgpagto','#frmNovaProp').val( arrayProposta['flgpagto'] );
		$('#percetop','#frmNovaProp').val( arrayProposta['percetop'] );
		$('#qtdialib','#frmNovaProp').val( arrayProposta['qtdialib'] );
		$('#dtdpagto','#frmNovaProp').val( arrayProposta['dtdpagto'] );
        $('#idfiniof','#frmNovaProp').val( arrayProposta['idfiniof'] );
		$('#flgimppr','#frmNovaProp').val( arrayProposta['flgimppr'] );
		$('#flgimpnp','#frmNovaProp').val( arrayProposta['flgimpnp'] );
		$('#dsctrliq','#frmNovaProp').val( arrayProposta['dsctrliq'] );
		$('#dsfinemp','#frmNovaProp').val( arrayProposta['dsfinemp'] );
		$('#dtlibera','#frmNovaProp').val( arrayProposta['dtlibera'] );
		$('#tpemprst','#frmNovaProp').val( arrayProposta['tpemprst'] );
		$('#dslcremp','#frmNovaProp').val( arrayProposta['dslcremp'] );
		$('#dsquapro','#frmNovaProp').val( arrayProposta['dsquapro'] );
		$('#dsquaprc','#frmNovaProp').val( arrayProposta['dsquaprc'] );
		$('#dsratpro','#frmNovaProp').val( arrayProposta['dsratpro'] );
		$('#dsratatu','#frmNovaProp').val( arrayProposta['dsratatu'] );

        // Se for Pos-Fixado
        if (tpemprst == 2) {
            $('#idcarenc','#frmNovaProp').val( arrayProposta['idcarenc'] );
            $('#dtcarenc','#frmNovaProp').val( arrayProposta['dtcarenc'] );
        }

        // PRJ 438 - Sprint 6
        if (arrayRendimento['flgdocje'] == 'yes' ){
			$('#flgYes','#frmNovaProp').prop('checked',true);
		} else {
			$('#flgNo','#frmNovaProp').prop('checked' ,true);
		}

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
		
		$('#nrcpfcgc','#frmDadosAval').setMask('INTEGER',cpfMascara($('#nrcpfcgc','#frmDadosAval').val()),'.','');
		
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
		
		// PRJ 438
        $('#vlrencjg', '#frmDadosAval').val(arrayAvalistas[contAvalistas]['vlrencjg']);
        $('#nrctacjg', '#frmDadosAval').val(arrayAvalistas[contAvalistas]['nrctacjg']);
		
		if ( $('#inpessoa','#frmDadosAval').val() == 1 ) {
			$('#dspessoa','#frmDadosAval').val('FISICA');
		}
		
		if ( $('#inpessoa','#frmDadosAval').val() == 2 ) {
			$('#dspessoa','#frmDadosAval').val('JURIDICA');
		}
		
		contAvalistas++;
		
		$('legend:first','#frmDadosAval').html('Dados dos Avalistas/Fiadores ' + contAvalistas);

	} else if (in_array(operacao,['C_ALIENACAO','A_ALIENACAO'])) {
		nomeForm = 'frmTipo';



		//bruno - prj 438 - bug 14164
		// $('#dscatbem','#'+nomeForm).append($('<option>', {
		// 	value: "EQUIPAMENTO",
		// 	text: "Equipamento"
		// }));$('#dscatbem','#'+nomeForm).append($('<option>', {
		// 	value: "MAQUINA DE COSTURA",
		// 	text: "Máquina de Costura"
		// }));
		if($("#dscatbem option[value='MAQUINA E EQUIPAMENTO']").length == 0){
			$('#dscatbem','#frmTipo').append($('<option>', {
				value: "MAQUINA E EQUIPAMENTO",
				text: "Máquina e Equipamento"
		}));
		}

		if (arrayAlienacoes[contAlienacao]['vlrdobem']) {
			var vlrdobemtmp = arrayAlienacoes[contAlienacao]['vlrdobem'];
		} else {
			var vlrdobemtmp = arrayAlienacoes[contAlienacao]['vlmerbem'];
		}

		if (arrayAlienacoes[contAlienacao]['nrcpfcgc']) {
			var nrcpfcgctmp = arrayAlienacoes[contAlienacao]['nrcpfcgc'];
		} else {
			var nrcpfcgctmp = arrayAlienacoes[contAlienacao]['nrcpfbem'];
		}

		var nrmodbemtmp = arrayAlienacoes[contAlienacao]['nrmodbem'];

		if (arrayAlienacoes[contAlienacao]['dstpcomb']) {
			nrmodbemtmp = nrmodbemtmp + " " + arrayAlienacoes[contAlienacao]['dstpcomb'];
		}

		$('#vlrdobem').maskMoney();
		$('#vlfipbem').maskMoney();

		//strSelect(arrayAlienacoes[contAlienacao]['dscatbem'], 'dscatbem',nomeForm);

		//bruno - prj 438 - bug 14149
		if(arrayAlienacoes[contAlienacao]['dscatbem'] == "EQUIPAMENTO" || arrayAlienacoes[contAlienacao]['dscatbem'] == "MAQUINA DE COSTURA"){ //PRJ 438 - Bruno
			arrayAlienacoes[contAlienacao]['dscatbem'] = "MAQUINA E EQUIPAMENTO";
		}
		$("#frmTipo #dscatbem option").each(function() { //Seleciona a opção que estiver gravada no banco
			if (arrayAlienacoes[contAlienacao]['dscatbem'] == $(this).val()) {
				$(this).attr('selected', 'selected');

				if(arrayAlienacoes[contAlienacao]['dscatbem'] == "MAQUINA E EQUIPAMENTO"){ //PRJ - 438 - Bruno
					hideCamposCategoriaVeiculos();
				}
			}
		});

		$('#dscatbem','#'+nomeForm).val( arrayAlienacoes[contAlienacao]['dscatbem'] );
		//$('#dsbemfin','#'+nomeForm).val( arrayAlienacoes[contAlienacao]['dsbemfin'] );
		$('#dscorbem','#'+nomeForm).val( arrayAlienacoes[contAlienacao]['dscorbem'] );
		$('#dschassi','#'+nomeForm).val( arrayAlienacoes[contAlienacao]['dschassi'] );
		$('#nranobem','#'+nomeForm).val( arrayAlienacoes[contAlienacao]['nranobem'] );
		$('#nrmodbem','#'+nomeForm).val( arrayAlienacoes[contAlienacao]['nrmodbem'] );
		$('#nrdplaca','#'+nomeForm).val( arrayAlienacoes[contAlienacao]['nrdplaca'] );
		$('#nrrenava','#'+nomeForm).val( arrayAlienacoes[contAlienacao]['nrrenava'] );
		$('#tpchassi','#'+nomeForm).val( arrayAlienacoes[contAlienacao]['tpchassi'] );
		$('#ufdplaca','#'+nomeForm).val( arrayAlienacoes[contAlienacao]['ufdplaca'] );
		//$('#nrcpfbem','#'+nomeForm).val( arrayAlienacoes[contAlienacao]['nrcpfbem'] );
		//$('#dscpfbem','#'+nomeForm).val( arrayAlienacoes[contAlienacao]['dscpfbem'] );
		//$('#vlmerbem','#'+nomeForm).val( arrayAlienacoes[contAlienacao]['vlmerbem'] );
		//$('#idalibem','#'+nomeForm).val( arrayAlienacoes[contAlienacao]['idalibem'] );

		$('#dstipbemC','#'+nomeForm).val( arrayAlienacoes[contAlienacao]['dstipbem'] );
		$('#dsmarbemC','#'+nomeForm).val( arrayAlienacoes[contAlienacao]['dsmarbem'] );
		$('#dsbemfinC','#'+nomeForm).val( arrayAlienacoes[contAlienacao]['dsbemfin'] );
		$('#vlfipbem','#'+nomeForm).val( arrayAlienacoes[contAlienacao]['vlfipbem'] ).trigger('mask.maskMoney');
		$('#dssitgrv','#'+nomeForm).val( arrayAlienacoes[contAlienacao]['dssitgrv'] );

		$('#vlrdobem','#'+nomeForm).val( vlrdobemtmp ).trigger('mask.maskMoney');
		$('#nrcpfcgc','#'+nomeForm).val( nrcpfcgctmp );
		$('#nrmodbemC','#'+nomeForm).val( nrmodbemtmp );

		if ( nrcpfcgctmp.length < 9 ) {
			$('#nrcpfcgc', '#'+nomeForm).setMask('INTEGER', 'zzzzzzzzzzzzzz','','');
		} else if( nrcpfcgctmp.length < 12 ) {
			$('#nrcpfcgc', '#'+nomeForm).setMask('INTEGER','999.999.999-99','.-','');
		} else {
			$('#nrcpfcgc', '#'+nomeForm).setMask('INTEGER','zz.zzz.zzz/zzzz-zz','/.-','');
		}

		$('#nrrenava', '#'+nomeForm).mask('AAA.AAA.AAA.AAA', {reverse: true});

		$("#dsmarbemC").show();
		$("#dsbemfinC").show();
		$("#nrmodbemC").show();
		$("#dsmarbem").hide();
		$("#dsbemfin").hide();
		$("#nrmodbem").hide();

		if (in_array(arrayAlienacoes[contAlienacao]['dscatbem'], ['AUTOMOVEL', 'CAMINHAO', 'MOTO', 'OUTROS VEICULOS'])) {
			$("#btHistoricoGravame").show();
		}

		$("#"+nomeForm+" #dstipbem option").each(function() {
			if (arrayAlienacoes[contAlienacao]['dstipbem'] == $(this).val()) {
				$(this).attr('selected', 'selected');
			}
		});
		$("#"+nomeForm+" #tpchassi option").each(function() {
			if (arrayAlienacoes[contAlienacao]['tpchassi'] == $(this).val()) {
				$(this).attr('selected', 'selected');
			}
		});
		$("#"+nomeForm+" #ufdplaca option").each(function() {
			if (arrayAlienacoes[contAlienacao]['ufdplaca'] == $(this).val()) {
				$(this).attr('selected', 'selected');
			}
		});
		$("#"+nomeForm+" #uflicenc option").each(function() {
			if (arrayAlienacoes[contAlienacao]['uflicenc'] == $(this).val()) {
				$(this).attr('selected', 'selected');
			}
		});

		$('#lsbemfin','#'+nomeForm).html( arrayAlienacoes[contAlienacao]['lsbemfin'] );
		$('#lsbemfin').css({'width': '100%', 'text-align': 'center'});

		//$('#nrcpfbem','#'+nomeForm).setMask('INTEGER',cpfMascara($('#nrcpfbem','#'+nomeForm).val()),'.','');

		//bruno - prj 438 - BUG 14149
		if(in_array(arrayAlienacoes[contAlienacao]['dscatbem'],['EQUIPAMENTO', 'MAQUINA DE COSTURA', 'MAQUINA E EQUIPAMENTO'])){
			$('#dschassiE', '#frmTipo').val(arrayAlienacoes[contAlienacao]['dschassi']);
			$('#nrmodbemE','#frmTipo').val( nrmodbemtmp);
			$('#dsbemfinE','#frmTipo').val( arrayAlienacoes[contAlienacao]['dsbemfin'] );
			$('#dsmarbemE','#frmTipo').val( arrayAlienacoes[contAlienacao]['dsmarbem'] ); 
			$('#dsmarceq','#frmTipo').val(arrayAlienacoes[contAlienacao]['dsmarceq']);
			$('#nrnotanf','#frmTipo').val(arrayAlienacoes[contAlienacao]['nrnotanf']);
            $('#vlrdobemE', '#frmTipo').val( vlrdobemtmp ).trigger('mask.maskMoney');
		    $('#nrcpfcgcE', '#frmTipo').val( nrcpfcgctmp );
		}
		//bruno - prj 438 - BUG 14149

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
		
		// PRJ 438
        $('#nrctacjg', '#frmIntevAnuente').val(arrayIntervs[contIntervis]['nrctacjg']);
        $('#inpessoa', '#frmIntevAnuente').val(arrayIntervs[contIntervis]['inpessoa']);
        $('#dtnascto', '#frmIntevAnuente').val(arrayIntervs[contIntervis]['dtnascto']);

		if ( $('#inpessoa','#frmIntevAnuente').val() == 1 ) {
			$('#dspessoa','#frmIntevAnuente').val('FISICA');
		}
		
		if ( $('#inpessoa','#frmIntevAnuente').val() == 2 ) {
			$('#dspessoa','#frmIntevAnuente').val('JURIDICA');
		}		
		
		$('#nrcpfcgc','#frmIntevAnuente').setMask('INTEGER',cpfMascara($('#nrcpfcgc','#frmIntevAnuente').val()),'.','');
		
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
        // PRJ 438 - Sprint 6
        $('#vlrdobem', '#frmHipoteca').val(arrayHipotecas[contHipotecas]['vlrdobem']);
        $('#nrmatric', '#frmHipoteca').val(arrayHipotecas[contHipotecas]['nrmatric']);
        $('#vlareuti', '#frmHipoteca').val(arrayHipotecas[contHipotecas]['vlareuti']);
        $('#vlaretot', '#frmHipoteca').val(arrayHipotecas[contHipotecas]['vlaretot']);
        $('#dsclassi', '#frmHipoteca').val(arrayHipotecas[contHipotecas]['dsclassi']);
        $('#nrcepend', '#frmHipoteca').val(arrayHipotecas[contHipotecas]['nrcepend']);
        $('#dsendere', '#frmHipoteca').val(arrayHipotecas[contHipotecas]['dsendere']);
        $('#nrendere', '#frmHipoteca').val(arrayHipotecas[contHipotecas]['nrendere']);
        $('#dscompend', '#frmHipoteca').val(arrayHipotecas[contHipotecas]['dscompend']);
        $('#nmbairro', '#frmHipoteca').val(arrayHipotecas[contHipotecas]['nmbairro']);
        $('#cdufende', '#frmHipoteca').val(arrayHipotecas[contHipotecas]['cdufende']);
        $('#nmcidade', '#frmHipoteca').val(arrayHipotecas[contHipotecas]['nmcidade']);        

		contHipotecas++;

	} else if (in_array(operacao, ['C_DEMONSTRATIVO_EMPRESTIMO'])) {
			$('#vlemprst', '#frmDemonstracaoEmprestimo').val(arrayProposta['vlemprst']);
			$('#vliofepr', '#frmDemonstracaoEmprestimo').val(arrayProposta['vliofepr']);
			$('#vlrtarif', '#frmDemonstracaoEmprestimo').val(arrayProposta['vlrtarif']);
			$('#vlrtotal', '#frmDemonstracaoEmprestimo').val(arrayRegistros['vlemprst']);
			$('#percetop', '#frmDemonstracaoEmprestimo').val(arrayProposta['percetop']);
			$('#vlpreemp', '#frmDemonstracaoEmprestimo').val(arrayProposta['vlpreemp']);
			$('#vlprecar', '#frmDemonstracaoEmprestimo').val(arrayProposta['vlprecar']);
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
			showError('error','Não foi possível concluir a requisição.','Alerta - Aimaro',"blockBackground(parseInt($('#divRotina').css('z-index')))");
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
			showError('error','Não foi possível concluir a requisição.','Alerta - Aimaro',"blockBackground(parseInt($('#divRotina').css('z-index')))");
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

function mostraTabelaHistoricoGravames( nriniseq, nrregist ) {

	showMsgAguardo('Aguarde, buscando hist&oacute;rico...');
	limpaDivGenerica();
$('#divUsoGenerico').css({ 'width': '90em', 'left': '19em' });
	exibeRotina($('#divUsoGenerico'));

	var dschassi = $("#dschassi","#frmTipo").val();
	var cdcoptel = cdcooper;
	var nrctrpro = nrctremp;

	// Executa script de confirmação através de ajax
	$.ajax({
		type: 'POST',
		dataType: 'html',
		url: UrlSite + 'telas/manbem/historico_gravames.php',
		//url: UrlSite + 'telas/atenda/prestacoes/cooperativa/historico_gravames.php',
		data: {
			operacao: operacao,
			nrdconta: nrdconta,
			nrctrpro: nrctrpro,
			dschassi: dschassi,
			cdcoptel: cdcoptel,
			nriniseq: nriniseq,
			nrregist: nrregist,
			redirect: 'html_ajax'
			},
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError('error', 'Não foi possível concluir a requisição.', 'Alerta - Aimaro', "blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
		success: function(response) {
			$('#divUsoGenerico').html(response);
			controlaLayoutHistoricoGravames( );
		}
	});
	return false;
}

function controlaLayoutHistoricoGravames() {
	$('#divUsoGenerico').css({ 'width': '93em', 'left': '19em' });
	var divRegistro = $('#divDetGravTabela');
	var tabela      = $('table',divRegistro);
	var linha       = $('table > tbody > tr', divRegistro);
	divRegistro.css({'height':'250px'});
	$('div.divRegistros').css({'height':'200px'});
	$('div.divRegistros table tr td:nth-of-type(8)').css({'text-transform':'uppercase'});
	$('div.divRegistros .dtenvgrv').css({'width':'25px'});
	$('div.divRegistros .dtretgrv').css({'width':'25px'});

	var ordemInicial = new Array();
	ordemInicial = [[0,0]];	
	
	var arrayLargura = new Array();
	// arrayLargura[0] = '30px';
	// arrayLargura[1] = '20px';
	// arrayLargura[2] = '60px';
	// arrayLargura[3] = '40px';
	// arrayLargura[4] = '55px';
	// arrayLargura[5] = '50px';
	// arrayLargura[6] = '115px';
	// arrayLargura[7] = '';
	// arrayLargura[8] = '25px';
	// arrayLargura[9] = '25px';
	// arrayLargura[10] = '55px';
	arrayLargura[0] = '31px';  	//Coop
	arrayLargura[1] = '30px';	//PA
	arrayLargura[2] = '101px';	//Operação
	arrayLargura[3] = '48px';	//Lote
	arrayLargura[4] = '65px';	//Conta/DV
	arrayLargura[5] = '65px';	//Contrato
	arrayLargura[6] = '140px';	//Chassi
	arrayLargura[7] = '190px';	//Bem
	arrayLargura[8] = '91px';	//Data Envio
	arrayLargura[9] = '91px';	//Data Ret
	arrayLargura[10] = '';		//Situação
	arrayLargura[11] = '14px'; // Fixo para definir o tamanho da coluna do campo da ordenação inicial que fica sobre a barra de rolagem
	
	var arrayAlinha = new Array();
	// arrayAlinha[0] = 'right';
	// arrayAlinha[1] = 'right';
	// arrayAlinha[2] = 'left';
	// arrayAlinha[3] = 'right';
	// arrayAlinha[4] = 'right';
	// arrayAlinha[5] = 'right';
	// arrayAlinha[6] = 'center';
	// arrayAlinha[7] = 'left';
	// arrayAlinha[8] = 'left';
	// arrayAlinha[9] = 'left';
	// arrayAlinha[10] = 'left';
	arrayAlinha[0] = 'center';
    arrayAlinha[1] = 'center';
    arrayAlinha[2] = 'center';
    arrayAlinha[3] = 'center';
    arrayAlinha[4] = 'center';
    arrayAlinha[5] = 'center';
    arrayAlinha[6] = 'center';
	arrayAlinha[7] = 'center';
	arrayAlinha[8] = 'center';
	arrayAlinha[9] = 'center';
	arrayAlinha[10] = 'left';
	tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha, '' );

	for( var i in arrayLargura ) {
		$('td:eq('+i+')', tabela ).css('width', arrayLargura[i] );
	}

	layoutPadrao();
	hideMsgAguardo();
	bloqueiaFundo($('#divUsoGenerico'));
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

	$('#tbdetgra').remove(); // Christian Grauppe
	$('#tdAntecip').remove(); // Daniel
	
	return false;
}

function mostraExtrato( operacao ) {

	showMsgAguardo('Aguarde, abrindo extrato...');

	tpemprst = arrayRegistros['tpemprst'];

	if (tpemprst == 0) {
	    exibeRotina($('#divUsoGenerico'));
	    limpaDivGenerica();
	}

	if  (tpemprst == 1 || tpemprst == 2) {
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
			showError('error','Não foi possível concluir a requisição.','Alerta - Aimaro',"blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
		success: function(response) {
			hideMsgAguardo();
			$('#divUsoGenerico').html(response);
			exibeRotina($('#divUsoGenerico'));
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
			showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Aimaro','bloqueiaFundo(divRotina)');
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
				showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Aimaro','bloqueiaFundo(divRotina)');
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
		showConfirmacao("Confirma liquidação do contrato?","Confirma&ccedil;&atilde;o - Aimaro",metodoSim,metodoNao,"sim.gif","nao.gif");
	}else{
		showConfirmacao("Confirma o pagamento da(s) parcela(s): "+parcelasPagas+"?","Confirma&ccedil;&atilde;o - Aimaro",metodoSim,metodoNao,"sim.gif","nao.gif");
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

	var nmfuncao;

	// Se há dados de antecipação
	if (qtdregis1 > 0){
		nmfuncao = "showMsgAutorizacaoAntecipacao();";
	} else {
	    nmfuncao = "controlaOperacao('C_PAG_PREST');";
        if (tpemprst == 2) { // Pos-Fixado
            nmfuncao = "controlaOperacao('C_PAG_PREST_POS');";
        }
	}
    showError("inform",'Pagamento efetuado com sucesso.',"Alerta - Aimaro",nmfuncao);
}

function showMsgAutorizacaoAntecipacao(){
	showConfirmacao('Deseja imprimir a autorização para antecipação?','Confirma&ccedil;&atilde;o - Aimaro','realizaImpressao(true);','realizaImpressao(false);','sim.gif','nao.gif');
}

function validaPagamentoPreju(){

	var vlprincipal = retiraMascara($('#vlprincipal', '#frmVlParcPreju').val()) || 0;
	var vljuros     = retiraMascara($('#vljuros'    , '#frmVlParcPreju').val()) || 0;
	var vlmulta     = retiraMascara($('#vlmulta'    , '#frmVlParcPreju').val()) || 0;
    var vlrdiof     = retiraMascara($('#vlrdiof'    , '#frmVlParcPreju').val()) || 0;
	var vlpagto     = retiraMascara($('#vlpagto'    , '#frmVlParcPreju').val()) || 0;
	var vlabono     = retiraMascara($('#vlabono'    , '#frmVlParcPreju').val()) || 0;

	//Validar para não permitir que todos os campos estejam vazios/zerados
	if(vlpagto > 0 || vlabono > 0) {
		if(vlprincipal > 0 || vljuros > 0 || vlmulta > 0 || vlrdiof > 0){
	showConfirmacao('Confirma pagamento do prejuízo?','Confirma&ccedil;&atilde;o - Aimaro','pagPrestPreju();','$(\'#btVoltar\').click();','sim.gif','nao.gif');
		}else{
			showError('error','Contrato liquidado.','Alerta - Aimaro','bloqueiaFundo(divRotina)');
		}
	} else {
		showError('error','Atenção! Informe valor de pagamento.','Alerta - Aimaro','bloqueiaFundo(divRotina)');
	}
}

function validaPagamentoPrejuPos(){

	var vlprincipal = retiraMascara($('#vlprincipal', '#frmVlParcPreju').val()) || 0;
	var vljuros     = retiraMascara($('#vljuros'    , '#frmVlParcPreju').val()) || 0;
	var vlmulta     = retiraMascara($('#vlmulta'    , '#frmVlParcPreju').val()) || 0;
    var vlrdiof     = retiraMascara($('#vlrdiof'    , '#frmVlParcPreju').val()) || 0;
	var vlpagto     = retiraMascara($('#vlpagto'    , '#frmVlParcPreju').val()) || 0;
	var vlabono     = retiraMascara($('#vlabono'    , '#frmVlParcPreju').val()) || 0;

	//Validar para não permitir que todos os campos estejam vazios/zerados
	if(vlpagto > 0 || vlabono > 0) {
		if(vlprincipal > 0 || vljuros > 0 || vlmulta > 0 || vlrdiof > 0){
	showConfirmacao('Confirma pagamento do prejuízo?','Confirma&ccedil;&atilde;o - Aimaro','pagPrestPrejuPos();','$(\'#btVoltar\').click();','sim.gif','nao.gif');
		}else{
			showError('error','Contrato liquidado.','Alerta - Aimaro','bloqueiaFundo(divRotina)');
		}
	} else {
		showError('error','Atenção! Informe valor de pagamento.','Alerta - Aimaro','bloqueiaFundo(divRotina)');
	}
}

function pagPrestPreju (){
	showMsgAguardo('Aguarde, validando prejuizo...');

	var valordopagto = retiraMascara($($('form#frmVlParcPreju').find('input')[4]).val()) || 0;
	var valordoabono = retiraMascara($($('form#frmVlParcPreju').find('input')[5]).val()) || 0;
	
	var vlprincipal = retiraMascara($($('form#frmVlParcPreju').find('input')[0]).val()) || 0;
	var vljuros = retiraMascara($($('form#frmVlParcPreju').find('input')[1]).val()) || 0;
	var vlmulta = retiraMascara($($('form#frmVlParcPreju').find('input')[2]).val()) || 0;
    var vlrdiof = retiraMascara($($('form#frmVlParcPreju').find('input')[3]).val()) || 0;
	
	var totalDivida = (vlprincipal + vljuros + vlmulta + vlrdiof) || 0;
	var totalArredondamento = parseFloat(totalDivida.toFixed(2));
	var totalPagamento = (valordopagto + valordoabono) || 0;
	
	if (valordopagto > totalArredondamento){
		hideMsgAguardo();
		showError('error','Pagamento não permitido, valor informado é superior ao saldo devedor do contrato.','Alerta - Aimaro','bloqueiaFundo(divRotina)');
		return false;
	}
	
	if (valordoabono > totalDivida){
		hideMsgAguardo();
		showError('error','Pagamento não permitido, valor do abono informado é superior ao saldo devedor do contrato.','Alerta - Aimaro','bloqueiaFundo(divRotina)');
		return false;
	}
	
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
			showError('error','N&atilde;o foi possível concluir a requisi&ccedil;&atilde;o.','Alerta - Aimaro','bloqueiaFundo(divRotina)');
		},
		success: function(response) {
			hideMsgAguardo();
			eval( response );
			return false;
		}
	});
}

function pagPrestPrejuPos (){
	showMsgAguardo('Aguarde, validando prejuizo...');

	var valordopagto = (retiraMascara($('#vlpagto', '#frmVlParcPreju').val()) || 0);
	var valordoabono = (retiraMascara($('#vlabono', '#frmVlParcPreju').val()) || 0);
	
	var vlprincipal = (retiraMascara($('#vlprincipal', '#frmVlParcPreju').val()) || 0);
	var vljuros = (retiraMascara($('#vljuros', '#frmVlParcPreju').val()) || 0);
	var vlmulta = (retiraMascara($('#vlmulta', '#frmVlParcPreju').val()) || 0);
    var vlrdiof = (retiraMascara($('#vlrdiof', '#frmVlParcPreju').val()) || 0);
	
	var totalDivida = (vlprincipal + vljuros + vlmulta + vlrdiof) || 0;
	var totalArredondamento = parseFloat(totalDivida.toFixed(2));
	var totalPagamento = (valordopagto + valordoabono) || 0;
	
	if (valordopagto > totalArredondamento){
		hideMsgAguardo();
		showError('error','Pagamento não permitido, valor informado é superior ao saldo devedor do contrato.','Alerta - Aimaro','bloqueiaFundo(divRotina)');
		return false;
	}
	
	if (valordoabono > totalDivida){
		hideMsgAguardo();
		showError('error','Pagamento não permitido, valor do abono informado é superior ao saldo devedor do contrato.','Alerta - Aimaro','bloqueiaFundo(divRotina)');
		return false;
	}
	
	// Carrega conteúdo da opção através do Ajax
	$.ajax({
		type: 'POST',
		dataType: 'html',
		url: UrlSite + 'telas/atenda/prestacoes/cooperativa/pagto_prejuizo_pos.php',
		data: {
			nrdconta: nrdconta,
			nrctremp: nrctremp,
			vldabono: valordoabono,
			vlpagmto: valordopagto,
			redirect: 'html_ajax'
		},
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError('error','N&atilde;o foi possível concluir a requisi&ccedil;&atilde;o.','Alerta - Aimaro','bloqueiaFundo(divRotina)');
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
			showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Aimaro','bloqueiaFundo(divRotina)');
		},
		success: function(response) {
			eval(response);
		}
	});
	
	return false;
}

function validaPagamentoPos(){

	
	showMsgAguardo('Aguarde, validando pagamento...');
	var vlapagar = $('#totpagto', '#frmVlParc').val();
	
	// Carregar os dados de antecipação
	verificaAntecipacaopgto();
	
	// Executa script de confirmação através de ajax
	$.ajax({
		type: 'POST',
		url: UrlSite + 'telas/atenda/prestacoes/cooperativa/valida_pagamentos_pos.php',
		data: {
			nrdconta: nrdconta,
			nrctremp: nrctremp,
			vlapagar: converteMoedaFloat(vlapagar),
			redirect: 'script_ajax'
		},
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Aimaro','bloqueiaFundo(divRotina)');
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
            showError('error','Não foi possível concluir a requisição.','Alerta - Aimaro',"blockBackground(parseInt($('#divRotina').css('z-index')))");
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

function mostraDivControles(operacao) {

	showMsgAguardo('Aguarde, abrindo controles...');

	limpaDivGenerica();

	exibeRotina($('#divUsoGenerico'));

	// Executa script de confirmação através de ajax
	$.ajax({
		type: 'POST',
		dataType: 'html',
		url: UrlSite + 'telas/atenda/prestacoes/cooperativa/controles.php',
		data: {			
			redirect: 'html_ajax'
		},
		error: function (objAjax, responseError, objExcept) {
			hideMsgAguardo();
			showError('error', 'NÃ£o foi possÃ­vel concluir a requisiÃ§Ã£o.', 'Alerta - Ayllos', "blockBackground(parseInt($('#divRotina').css('z-index')))");
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

function mostraDivQualificaControle(operacao) {

	showMsgAguardo('Aguarde, abrindo qualifica&ccedil;&atilde;o...');

	limpaDivGenerica();

	exibeRotina($('#divUsoGenerico'));

	var idquaprc = $('#idquaprc').val();	
	var idquapro = $('#idquapro').val();	

	// Executa script de confirmação através de ajax
	$.ajax({
		type: 'POST',
		dataType: 'html',
		url: UrlSite + 'telas/atenda/prestacoes/cooperativa/controleQualificacao.php',
		data: {
			operacao: operacao,
			nrdconta: nrdconta,
			nrctremp: nrctremp,
			idquaprc: idquaprc,	
			idquapro: idquapro,	
			redirect: 'html_ajax'
		},
		error: function (objAjax, responseError, objExcept) {
			hideMsgAguardo();
			showError('error', 'NÃ£o foi possÃ­vel concluir a requisiÃ§Ã£o.', 'Alerta - Aimaro', "blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
		success: function (response) {
			$('#divUsoGenerico').html(response);
			layoutPadrao();
			hideMsgAguardo();
			bloqueiaFundo($('#divUsoGenerico'));
            $('#idquaprc', '#frmControleQual').focus(); 												
        }
    });

	return false;
}

function gravaContratosLiquidados(){
	
	var dsliquid = dsctrliqCL;

	if(dsliquid != ""){
		showConfirmacao("Confirma o vínculo do(s) Contrato(s) Liquidado(s): "+
						dsliquid+
						" com o contrato "+
						nrctremp+"?",
						"Confirma&ccedil;&atilde;o - Ayllos",
						"gravaContratosLiqDef();",
						"return false;",
						"sim.gif",
						"nao.gif");
	}

	return false;
	
}

function gravaContratosLiqDef(){

	showMsgAguardo('Aguarde, gravando contratos liquidados...');
	
	// Executa script de confirmação através de ajax
	$.ajax({
		type: 'POST',
		dataType: 'html',
		url: UrlSite + 'telas/atenda/prestacoes/cooperativa/gravaContratosLiquidados.php',
		data: {
			cdcooper: cdcooper, 
			nrdconta: nrdconta,
			nrctremp: nrctremp,
			dsliquid: dsctrliqCL,	
			redirect: 'html_ajax'
		},
		error: function (objAjax, responseError, objExcept) {
			hideMsgAguardo();
			showError('error', 'NÃ£o foi possÃ­vel concluir a requisiÃ§Ã£o.', 'Alerta - Ayllos', "blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
		success: function (response) {
			$('#divUsoGenerico').html(response);
			layoutPadrao();
			hideMsgAguardo();
			bloqueiaFundo($('#divUsoGenerico'));            
        }
    });

	return false;	
}

function mostraDivContratosALiquidar(){

	showMsgAguardo('Aguarde, abrindo Contratos Liquidados...');

	limpaDivGenerica();
    
	exibeRotina($('#divUsoGenerico'));

	// Executa script de confirmação através de ajax
	$.ajax({
		type: 'POST',
		dataType: 'html',
		url: UrlSite + 'telas/atenda/prestacoes/cooperativa/contratosALiquidar.php',
		data: {
			cdcooper: cdcooper,
			nrdconta: nrdconta,
			nrctremp: nrctremp,
			redirect: 'html_ajax'
		},
		error: function (objAjax, responseError, objExcept) {
			hideMsgAguardo();
			showError('error', 'NÃ£o foi possÃ­vel concluir a requisiÃ§Ã£o.', 'Alerta - Ayllos', "blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
		success: function (response) {			
			$('#divUsoGenerico').html(response);
			//layoutPadrao();
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
            showError('error','Não foi possível concluir a requisição.','Alerta - Aimaro',"blockBackground(parseInt($('#divRotina').css('z-index')))");
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
            showError('error','Não foi possível concluir a requisição.','Alerta - Aimaro',"blockBackground(parseInt($('#divRotina').css('z-index')))");
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
            nrdconta: nrdconta,
            nrctremp: nrctremp,
            flgimppr: flgimppr,
            flgimpnp: flgimpnp,
            cdorigem: cdorigem,
            redirect: 'html_ajax'
            },
        error: function(objAjax,responseError,objExcept) {
            hideMsgAguardo();
            showError('error','Não foi possível concluir a requisição.','Alerta - Aimaro',"blockBackground(parseInt($('#divRotina').css('z-index')))");
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

	// Se a opção de impressão for Contrato,Contrato Não Negociável,CET,Proposta,Consultas,Política então
	//valida se o contrato não foi migrado. Se contratoMigrado for diferente de zero, então
	//o valor de contratoMigrado é justamente o código do novo contrato
	// Augusto - Supero
	if (contratoMigrado != "0" && (idimpres == 2  || idimpres == 8 || idimpres == 6 || idimpres == 3 || idimpres == 7 || idimpres == 11)) {
		showError("inform",'Consulta dispon&iacute;vel no contrato: '+contratoMigrado,"Alerta - Ayllos","");
		return false;
	}

	//Bloqueio temporario para linhas de canais digitais. P438
	if (idimpres == 9 && (arrayRegistros['cdlcremp'] == 7080 || arrayRegistros['cdlcremp'] == 7081) ) {
		showError("inform",'Via do contrato digital dispon&iacute;vel no Smartshare!',"Alerta - Ayllos","");
		return false;
	}

	if ( idimpres >= 1 && idimpres <= 57 ) {
	
		if ( idimpres == 5 ) {

			var metodo = '';

			imprimirRating(false,90,nrctremp,"divConteudoOpcao","bloqueiaFundo(divRotina);");

			if ( $('#divAguardo').css('display') == 'block' ){
				metodo = $('#divAguardo');
			}else{
				metodo = $('#divRotina');
			}

			fechaRotina($('#divUsoGenerico'),metodo);
			
		} else if ( idimpres == 10 ) {
			var metodo = '';

			imprimirRatingProposta(false,90,nrctremp,"divConteudoOpcao","bloqueiaFundo(divRotina);");

			if ( $('#divAguardo').css('display') == 'block' ){
				metodo = $('#divAguardo');
			}else{
				metodo = $('#divRotina');
		}

			fechaRotina($('#divUsoGenerico'),metodo);
		}
		else
		if (in_array(idimpres, [7, 8, 9, 11, 57])) { //pre-aprovado
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
		showError('error','Opção de impressão inválida','Alerta - Aimaro',"blockBackground(parseInt($('#divRotina').css('z-index')))");
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
			showError('error','Não foi possível concluir a requisição.','Alerta - Aimaro',"blockBackground(parseInt($('#divRotina').css('z-index')))");
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
		showError('error','Número de nota promissória inicial inválido','Alerta - Aimaro',"bloqueiaFundo($('#divUsoGenerico'));");
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

	showConfirmacao("Efetuar envio de e-mail para Sede?","Confirma&ccedil;&atilde;o - Aimaro",metodoSim,metodoNao,"sim.gif","nao.gif");
    } else  
        {  
          flgemail=false;
          carregarImpresso();
        } 
	return false;

}

// Função para envio de formulário de impressao
function carregarImpresso(){
	var nrcpfcgc = normalizaNumero($("#nrcpfcgc", "#frmCabAtenda").val());

	fechaRotina($('#divUsoGenerico'),$('#divRotina'));

	$('#idimpres','#formEmpres').remove();
	$('#promsini','#formEmpres').remove();
	$('#flgemail','#formEmpres').remove();
	$('#nrdrecid','#formEmpres').remove();
	$('#nrdconta','#formEmpres').remove();
	$('#sidlogin','#formEmpres').remove();
	$('#nrcpfcgc','#formEmpres').remove();

	// Insiro input do tipo hidden do formulário para enviá-los posteriormente
	$('#formEmpres').append('<input type="hidden" id="idimpres" name="idimpres" />');
	$('#formEmpres').append('<input type="hidden" id="promsini" name="promsini" />');
	$('#formEmpres').append('<input type="hidden" id="flgemail" name="flgemail" />');
	$('#formEmpres').append('<input type="hidden" id="nrdrecid" name="nrdrecid" />');
	$('#formEmpres').append('<input type="hidden" id="nrdconta" name="nrdconta" />');
	$('#formEmpres').append('<input type="hidden" id="nrctremp" name="nrctremp" />');
	$('#formEmpres').append('<input type="hidden" id="sidlogin" name="sidlogin" />');
	$('#formEmpres').append('<input type="hidden" id="nrcpfcgc" name="nrcpfcgc" />');

	// Agora insiro os devidos valores nos inputs criados
	$('#idimpres','#formEmpres').val( idimpres );
	$('#promsini','#formEmpres').val( promsini );
	$('#flgemail','#formEmpres').val( flgemail );
	$('#nrdrecid','#formEmpres').val( nrdrecid );
	$('#nrdconta','#formEmpres').val( nrdconta );
	$('#nrctremp','#formEmpres').val( nrctremp );
	$('#sidlogin','#formEmpres').val( $('#sidlogin','#frmMenu').val() );
	$('#nrcpfcgc','#formEmpres').val( nrcpfcgc );
	
	$('#nrcpfcgc','#formEmpres').setMask('INTEGER',cpfMascara($('#nrcpfcgc','#formEmpres').val()),'.','');
    
	var action = UrlSite + 'telas/atenda/prestacoes/cooperativa/imprimir_dados.php';

	carregaImpressaoAyllos("formEmpres",action,"bloqueiaFundo(divRotina);");

	return false;
}


function verificaTipoEmprestimo()
{
	var mtSimplificado = 'intpextr=1;imprimirExtrato();';
	var mtDetalhado    = 'intpextr=2;imprimirExtrato();';

	showConfirmacao('Escolha o tipo de relat&oacute;rio','Confirma&ccedil;&atilde;o - Aimaro',mtSimplificado,mtDetalhado,'simplificado.gif','detalhado.gif');
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
		valorIOF	  = retiraMascara($('#vliofcpl_'+nrParcela , tabela).val());

		valorAtual +=  valorMulta + valorMora + valorIOF;

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
    var nmscript = 'gera_pagamentos.php';
	
    if (tpemprst == 2) { // Se for Pos-Fixado
        nmscript = 'gera_pagamentos_pos.php';
    }
	
	if ($('#divUsoGenerico').css('visibility') == 'visible') {
		nrseqavl = $('input:radio[name=nrseqavl]:checked','#frmDadosPagAval').val();
	}
	
	$("input[type=checkbox][name='checkParcelas[]']").each(function() {
		checked = false;
		checked = this.checked;
		if(checked != false)
		{
			nrParcela = this.id.split("_")[1];

			if (tpemprst == 1) { // Se for PP
			dadosprc  += $('#cdcooper_'+nrParcela , tabela).val()+';'+$('#nrdconta_'+nrParcela , tabela).val()+';'+$('#nrctremp_'+nrParcela , tabela).val()+';';
			dadosprc  += $('#nrparepr_'+nrParcela , tabela).val()+';'+$('#vlpagpar_'+nrParcela , tabela).val()+'|';
            } else if (tpemprst == 2) { // Se for Pos-Fixado
                dadosprc  += (dadosprc == '' ? '' : '|') + $('#nrparepr_'+nrParcela , tabela).val() + ';' + $('#vlpagpar_'+nrParcela , tabela).val().replace(/\./g, '');
            }
		}
	});

	// Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, gerando pagamento ...");

	// Carrega conteúdo da opção através de ajax
	$.ajax({
		type: "POST",
		dataType: 'html',
		url: UrlSite + "telas/atenda/prestacoes/cooperativa/" + nmscript,
		data: {
		    nrdconta: nrdconta,	nrctremp: nrctremp,
			campospc: campospc, dadosprc: dadosprc,
			idseqttl: idseqttl, totatual: totatual,
			totpagto: totpagto, nrseqavl: nrseqavl,
			redirect: "html_ajax" // Tipo de retorno do ajax
		},
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message + ".","Alerta - Aimaro","$('#nrsennov','#frmEskeci').focus()");
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

function verificaDescontoPos(campo , insitpar , parcela) {

	var vlpagan = $("#vlpagan_" + parcela,"#divTabela");

	if (isHabilitado(campo) && retiraMascara(vlpagan.val()) != retiraMascara(campo.val()) && insitpar == 3) { // 3 - A Vencer
        nrparepr_pos = parcela;
        vlpagpar_pos = converteMoedaFloat(campo.val());
        controlaOperacao("C_DESCONTO_POS");
	}
	vlpagan.val(campo.val());

}

function desconto (parcela) {

	if  (parcela != 0) {
		vlpagpar = parcela + ";" + $("#vlpagpar_" + parcela ,"#divTabela").val();
	}

	controlaOperacao("C_DESCONTO");

}

function descontoPos (parcela,valor) {
	$('#vldespar_' + parcela ,'#divTabela').html(valor);
}

function atribuiDescControle (idQuaPrc) {
	switch(idQuaPrc){		
		case 1:
			return "Operacao Normal";
			break;
		case 2:
			return "Renovacao Credito";
			break;
		case 3:
			return "Renegociacao Credito";
			break;
		case 4:
			return "Composicao Divida";
			break;
		case 5:
			return "Cessao de Cartao";
			break;
		default:
			return "Operacao Inexistente";
			break;
	}
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
			showError('error','Não foi possível concluir a requisição.','Alerta - Aimaro',"blockBackground(parseInt($('#divRotina').css('z-index')))");
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
			showError('error','Não foi possível concluir a requisição.','Alerta - Aimaro',"blockBackground(parseInt($('#divRotina').css('z-index')))");
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
        var nmoperac = 'C_PAG_PREST';
        if (tpemprst == 2) { // Pos-Fixado
            nmoperac = 'C_PAG_PREST_POS';
        }
		//Controlar a operação da tela
		controlaOperacao(nmoperac);
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
        var nmoperac = 'C_PAG_PREST';
        if (tpemprst == 2) { // Pos-Fixado
            nmoperac = 'C_PAG_PREST_POS';
        }
        controle += ' controlaOperacao(\'' + nmoperac + '\');';
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
	showConfirmacao('Confirmar opera&ccedil;&atilde;o?','Confirma&ccedil;&atilde;o - Aimaro','controlaOperacao(\'C_TRANSF_PREJU\');','bloqueiaFundo($(\'#divRotina\'));','sim.gif','nao.gif');
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
	showConfirmacao('Desfazer Transferencia para Prejuizo?','Confirma&ccedil;&atilde;o - Aimaro','controlaOperacao(\'C_DESFAZ_PREJU\');','bloqueiaFundo($(\'#divRotina\'));','sim.gif','nao.gif');
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
	var linValor;

	$('table > tbody > tr', 'div.divRegistros').each( function() {
			if ( $(this).hasClass('corSelecao') ) {

			linValor = parseInt($('td:first', $(this)).text().split(' ')[0].trim());

				if (typeof $('#nrctremp', $(this) ).val() != 'undefined'){
					nrctremp = $('#nrctremp', $(this) ).val();
				}
				if (typeof $('#liquidia', $(this) ).val() != 'undefined'){
					liquidia = $('#liquidia', $(this) ).val();
				}
			
			if (typeof $('#inprejuz', $(this) ).val() != 'undefined'){
				inprejui = $('#inprejuz', $(this) ).val();
			}

				if (typeof $('#tpemprst', $(this) ).val() != 'undefined'){
					tpemprst = $('#tpemprst', $(this) ).val();
				}
            if (typeof $('#vlsdprej', $(this) ).val() != 'undefined'){
              vlsdprej = $('#vlsdprej', $(this) ).val();
            }
				
		    /*	
		    if (typeof $('#vlemprst', $(this) ).val() != 'undefined'){
				vlemprst = $('#vlemprst', $(this) ).val();
			} */
			}
		});
		if ( nrctremp == '' ) { return false; }
		
		if ( vlsdprej == 0 && inprejui == 1) { 
		
		// showError('inform','Contrato n&atilde;o possui Saldo Prejuizo!','Alerta - Aimaro','bloqueiaFundo(divRotina)');
		showError('error', 'Contrato n&atilde;o possui Saldo Prejuizo.', 'Alerta - Aimaro', 'bloqueiaFundo(divRotina)');
		
		return false; }
	
	if (tpemprst == 2) { // Pos-Fixado
		if (inprejui == 0){
		controlaOperacao('C_PAG_PREST_POS');
		}else {
			controlaOperacao('C_PAG_PREST_POS_PRJ');
		}
	} else {
	if ( liquidia == 1 ) {
		showConfirmacao('Deseja Realizar Liquidação do Contrato?','Confirma&ccedil;&atilde;o - Aimaro','exibeValorLiquidacao();','controlaOperacao(\'C_PAG_PREST\');','sim.gif','nao.gif');
		return false;
	} 
	else {
		//nova regra
		//if (linValor == 100 && inprejui == 1) {
		//controlaOperacao('C_PAG_PREST');
		//}
		if (inprejui == 0){
		controlaOperacao('C_PAG_PREST');
		}
		else {
			controlaOperacao('C_PAG_PREST_PREJU');
	}

	}
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

	showConfirmacao(msg,'Confirma&ccedil;&atilde;o - Aimaro','bloqueiaFundo($(\'#divRotina\'));','confirmarLiquidacao();','voltar.gif','continuar.gif');
	return false;

}

function confirmarLiquidacao(){

	showConfirmacao('Confirma Liquidação do Contrato?','Confirma&ccedil;&atilde;o - Aimaro','controlaOperacao(\'C_LIQ_MESMO_DIA\');','cancelaLiquidacao();','sim.gif','nao.gif');
	return false;

	/* 'bloqueiaFundo($(\'#divRotina\'));' */
	
}

function cancelaLiquidacao(){
	
	showError('inform','Contrato n&atilde;o Liquidado!','Alerta - Aimaro','bloqueiaFundo(divRotina)');
	return false;
	
}

function abrirTelaGAROPC() {

    showMsgAguardo('Aguarde, carregando ...');

    exibeRotina($('#divUsoGAROPC'));
    $('#divRotina').css({'display':'none'});

    // Carrega conteúdo da opção através do Ajax
    $.ajax({
        type: 'POST',
        dataType: 'html',
        url: UrlSite + 'telas/garopc/garopc.php',
        data: {
            nmdatela     : 'PRESTACOES',
            tipaber      : 'C',
            nrdconta     : nrdconta,
            tpctrato     : 90,
            idcobert     : arrayProposta['idcobope'],
            dsctrliq     : 0,
            codlinha     : arrayProposta['cdlcremp'],
            vlropera     : number_format(converteMoedaFloat(arrayProposta['vlemprst']),2,',','.'),
            divanterior  : 'divRotina',
            ret_nomcampo : '',
            ret_nomformu : '',
            ret_execfunc : '$(\\\'#divRotina\\\').css({\\\'display\\\':\\\'block\\\'});' + 
						   'bloqueiaFundo($(\\\'#divRotina\\\'));' + 
						   'controlaOperacao(\\\'C_DADOS_AVAL\\\');',
            ret_voltfunc : 'controlaOperacao(\'C_INICIO\');',
            ret_errofunc : '$(\\\'#divRotina\\\').css({\\\'display\\\':\\\'block\\\'});' +
                           'bloqueiaFundo($(\\\'#divRotina\\\'));',
			redirect     : 'html_ajax'
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Aimaro', 'bloqueiaFundo(divRotina)');
        },
        success: function (response) {
			hideMsgAguardo();
            $('#divUsoGAROPC').html(response);
            bloqueiaFundo($('#divUsoGAROPC'));
        }
    });
}

function calcularSaldo(){

	var vlprincipal = retiraMascara($('#vlprincipal', '#frmVlParcPreju').val()) || 0;
	var vljuros     = retiraMascara($('#vljuros'    , '#frmVlParcPreju').val()) || 0;
	var vlmulta     = retiraMascara($('#vlmulta'    , '#frmVlParcPreju').val()) || 0;
  var vlrdiof     = retiraMascara($('#vlrdiof'    , '#frmVlParcPreju').val()) || 0;
	var vlpagto     = retiraMascara($('#vlpagto'    , '#frmVlParcPreju').val()) || 0;
	var vlabono     = retiraMascara($('#vlabono'    , '#frmVlParcPreju').val()) || 0;

	var vlsaldo = (vlprincipal + vljuros + vlmulta + vlrdiof) - (vlpagto + vlabono);

	$('#vlsaldo', '#frmVlParcPreju').val(vlsaldo.toFixed(2).replace(".",","));

	$('#vlsaldo').trigger('blur');
}

/*
	Autor: Bruno luiz katzjarowski;
	prj 438 - bug 14164
	Esconder mostrar campos para a categoria MAQUINA E EQUIPMENTO 

	@param hide boolean true => mostrar field maquina e equipamento | false => esconder maquina e equipamento
	@return void
*/
function hideCamposCategoriaVeiculos(hide){ //PRJ 438 - Bruno
	if(typeof hide == "undefined"){
		hide = true;
	}
	if(hide){
		$('.fieldVeiculos').hide();
		$('.fieldMaquinaEquipamento').show();
	}else{
		$('.fieldMaquinaEquipamento').hide();
		$('.fieldVeiculos').show();
	}
}