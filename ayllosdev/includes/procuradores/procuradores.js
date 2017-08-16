/*
 * FONTE        : procuradores.js
 * CRIAÇÃO      : Alexandre Scola - DB1 Informatica
 * DATA CRIAÇÃO : 09/03/2010 
 * OBJETIVO     : Biblioteca de funções na rotina Representates/Procuradores da tela de CONTAS
 * ALTERAÇÃO    : Adicionado pesquisa CEP. ( Rodolpho/Rogérius. (DB1) ).
                  22/08/2011 - Alterações projeto Grupo Econômico (Guilherme).
 *                25/11/2011 - Alterado validacoes do Grupo Economico; desvinculado campo do
 *                             percentual societario do campo cargo. (Fabricio)
 *                06/02/2012 - Ajuste para não chamar 2 vezes a função mostraPesquisa (Tiago). 
 *				  01/06/2012 - Ajustes referente ao projeto GP - Sócios Menores (Adriano).
 *				  17/10/2012 - Implementado mascara para o campo dsoutren (Daniel).
 *				  16/04/2013 - Ajuste na função abrirRotinaProc para tratar a passagem do parâmetro nmdatela no ajax (Adriano).
 *				  04/07/2013 - Inclusão das opções refentes aos poderes (Jean Michel).
 *				  25/09/2013 - Alteração da função de salvar poderes (Jean Michel).
 *                05/06/2014 - Removido attr('maxlength','200') do campo dsoutren, pois não abria a tela no IE 10. 
 *                             Alterado para nao validar o cpf quando estiver excluindo (Douglas - Chamado 134639)
 *				  29/01/2015 - Removido attr('value','no') do campo flgdepec (Lucas R #241971)
 *                04/08/2015 - Reformulacao cadastral (Gabriel-RKAM).
 *                03/11/2015 - Incluida a funcao selecionaPoder(), PRJ. 131 - Ass. Conjunta (Jean Michel).
 *                26/08/2016 - Inclusao da function validaResponsaveis e alteracao controlaOperacaoPoderes, SD 510426 (Jean Michel).
 *				  10/02/2017 - Ajuste realizado para remover caracteres invalidos de "Outros poderes". SD 558355 (Kelvin).
 *                25/04/2017 - Alterado campo dsnacion para cdnacion. (Projeto 339 - Odirlei-AMcom)
 *                12/06/2017 - Ajuste devido ao aumento do formato para os campos crapass.nrdocptl, crapttl.nrdocttl, 
			                   crapcje.nrdoccje, crapcrl.nridenti e crapavt.nrdocava
							  (Adriano - P339).

 */
var flgAcessoRotina = true; // Flag para validar acesso as rotinas da tela CONTAS
var nrcpfcgc_proc = ''; 
var nrdctato = '';
var nrdrowid = '';
var nrctremp = '';
var nrctremp = '';
var cddopcao_proc = 'C'; 
var cpfaux 	 = '';
var indarray = '';
var indarray_proc = '';
var operacao_proc = ''; 
var nomeFormProc = 'frmDadosProcuradores'; 
var arrayBens =  new Array();
var cargo;
var dscritica;
var dtnascto;
var nrdeanos_proc = 0;
var aux_sovalida = false; 
var aux_dscdaope = '';
var criaTabela  = 'CT'; //Variável para controlar quando a tabela referente ao arrayFilhos será alimentada e apresentada na tela
var cpfPoderes = 0;
var flgPoderes = false;
var flgassco = false;

var flgpoderC1 = false;
var flgpoderI1 = false;
var flgpoderC2 = false;
var flgpoderI2 = false;
var flgpoderC3 = false;
var flgpoderI3 = false;
var flgpoderC4 = false;
var flgpoderI4 = false;
var flgpoderC5 = false;
var flgpoderI5 = false;
var flgpoderC6 = false;
var flgpoderI6 = false;
var flgpoderC7 = false;
var flgpoderI7 = false;
var flgpoderC8 = false;
var flgpoderI8 = false;
var flgpoderC9 = false;
var flgpoderI9 = false;

if(nmrotina != 'MATRIC'){
		
	var verrespo = false; //Variável global para indicar se deve validar ou nao os dados dos Resp.Legal na BO55
	var permalte = false; // Está variável sera usada para controlar se a "Alteração/Exclusão/Inclusão - Resp. Legal" deverá ser feita somente na tela contas
	var aux_cdrotina = ''; //Armazena a operacao corrente da tela para quando for chamar a rotina resp. legal 
	var aux_operacao = ''; // Armazena a operação da tela
	var arrayBensMatric   = new Array(); // Variável global para armazenar os bens dos procuradores
	var arrayFilhosAvtMatric = new Array(); // Variável global para armazenar os procuradores
	var dtmvtolt = ''; // Armazena a data atual do sistema
	
}

/*OBS.: Devido a tela procuradores estar sendo chamada por mais de uma rotina, o nome das funções, 
        variáveis globais deste fonte devem ser diferenciadas dos fontes da rotina origem.*/


 
function acessaOpcaoAbaProc(nrOpcoes,id,opcao){ 
	
	if(nmrotina == "MATRIC"){
		aux_operacao = operacao;
	}

	// Mostra mensagem de aguardo
	showMsgAguardo('Aguarde, carregando representante/procurador ...');
	
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
		
		$('#linkAba'   + i).attr('class','txtNormalBold');
		$('#imgAbaEsq' + i).attr('src',UrlImagens + 'background/mnu_nle.gif');			
		$('#imgAbaDir' + i).attr('src',UrlImagens + 'background/mnu_nld.gif');
		$('#imgAbaCen' + i).css('background-color','#C6C8CA');
		
	}
				
	// Carrega conteúdo da opção através do Ajax
	$.ajax({		
		type: 'POST', 
		dataType: 'html',
		url: UrlSite + 'includes/procuradores/principal.php',
		data: {
			nrdconta     : nrdconta,
			idseqttl     : idseqttl,
			nrcpfcgc_proc: nrcpfcgc_proc,
			nrdctato     : nrdctato,
			nrdrowid     : nrdrowid,
			cddopcao_proc: cddopcao_proc,
			operacao_proc: operacao_proc,
			aux_operacao : aux_operacao,
			flgcadas     : flgcadas,
			nmdatela     : nmdatela,
			nmrotina     : nmrotina,
			redirect     : 'html_ajax'
		},		
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','bloqueiaFundo(divRotina)');
		},
		success: function(response) {
			if ( response.indexOf('showError("error"') == -1 ) {
				$('#divConteudoOpcao').html(response);
			} else {
				eval( response );
				controlaFocoProc( operacao_proc );
			}
			
			/* teste */
			controlaSocioProprietario();
						
			return false;	
		}
	});
}

// Função para acessar a rotina Responsavel Legal
function abrirRotinaProc(nomeValidar,nomeTitulo,nomeScript,nomeURL,ope) {

	operacao_proc = ope;
	permalte = false;
	dtdenasc = $('#dtnascto','#'+nomeFormProc).val();
	cdhabmen = $('#inhabmen','#'+nomeFormProc).val();
			
		
	// Verifica se é uma chamada válida
	if (!flgAcessoRotina) {
		return false;
	}		
	
	// Mostra mensagem de aguardo	
	showMsgAguardo("Aguarde, carregando  " + nomeTitulo + " ...");

	var urlscript = UrlSite + "includes/" + nomeScript + "/" + nomeScript;
	var url = UrlSite + "telas/contas/" + nomeScript + "/" + nomeURL;
		
	// Carrega biblioteca javascript da rotina
	// Ao carregar efetua chamada do conteúdo da rotina através de ajax
	$.getScript(urlscript + ".js",function() {
		$.ajax({
			type: "POST",
			dataType: "html",
			url: url + ".php",
			data: {
				nrdconta: nrdconta,
				idseqttl: idseqttl,
				nmdatela: (( nmrotina != 'MATRIC' ) ? 'CONTAS' : nmrotina),
				nmrotina: nomeValidar,
				redirect: "html_ajax" // Tipo de retorno do ajax
			},
			error: function(objAjax,responseError,objExcept) {
				hideMsgAguardo();
				showError("error","Não foi possível concluir a requisição.","Alerta - Ayllos","");
			},
			success: function(response) {
				$("#divConteudoOpcao").css('display','none');
				$("#divOpcoesDaOpcao1").css('display','block');
				$("#divOpcoesDaOpcao1").html(response);
				
				$('.fecharRotina').click( function() {
					if(nmrotina == "MATRIC"){
						
						idseqttl = $('input[name="inpessoa"]:checked','#frmCabMatric').val();
											
					}else{
					
						idseqttl = $('#idseqttl','#frmCabContas').val();
						
					}
					
					fechaRotina(divRotina);
					return false;
					
				});	
			}				 
		}); 
	});
}

function guarda (dsproftl) {
	
	cargo = dsproftl;

}

function controlaOperacaoProc( operacao_proc ){
	
	if ( operacao_proc != 'EV' && operacao_proc !='EC' && !verificaContadorSelect() ) return false;
	
	// Se não possui acesso para alterar, emitir mensagem	
	if ( (operacao_proc == 'TC') && (flgConsultar != '1') ) { showError('error','Seu usu&aacute;rio n&atilde;o possui permiss&atilde;o de consulta.'               ,'Alerta - Ayllos','bloqueiaFundo(divRotina)'); return false; }
	if ( (operacao_proc == 'TA') && (flgAlterar   != '1') ) { showError('error','Seu usu&aacute;rio n&atilde;o possui permiss&atilde;o de altera&ccedil;&atilde;o.','Alerta - Ayllos','bloqueiaFundo(divRotina)'); return false; }	
	if ( (operacao_proc == 'TI') && (flgIncluir   != '1') ) { showError('error','Seu usu&aacute;rio n&atilde;o possui permiss&atilde;o de inclus&atilde;o.'        ,'Alerta - Ayllos','bloqueiaFundo(divRotina)'); return false; }
	if ( (operacao_proc == 'TX') && (flgExcluir   != '1') ) { showError('error','Seu usu&aacute;rio n&atilde;o possui permiss&atilde;o de exclux&atilde;o.'        ,'Alerta - Ayllos','bloqueiaFundo(divRotina)'); return false; }
	if ( (operacao_proc == 'TP') && (flgExcluir   != '1') ) { showError('error','Seu usu&aacute;rio n&atilde;o possui permiss&atilde;o de poderes.'        ,'Alerta - Ayllos','bloqueiaFundo(divRotina)'); return false; }
	
	if ( in_array(operacao_proc,['TC','TA','TX','TP']) ) {
	
		nrcpfcgc_proc 	= '';
		nrdctato 	    = '';
		nrdrowid 	    = '';
		
		$('table > tbody > tr', 'div.divRegistros').each( function() {
								
			if ( $(this).hasClass('corSelecao') || normalizaNumero(cpfPoderes) == $('input[name="nrcpfcgc"]', $(this) ).val() ) {
				nrcpfcgc_proc = $('input[name="nrcpfcgc"]', $(this) ).val();
				nrdctato = $('input[name="nrdctato"]', $(this) ).val();
				nrdrowid = $('input[name="nrdrowid"]', $(this) ).val();
				nrctremp = $('input[name="nrctremp"]', $(this) ).val();	
			}
			
		});	
											
		if ( nrcpfcgc_proc == '' && nrdctato == '' ) { return false; }
		
	}

	if ( in_array(operacao_proc,['TC','TA','TX']) ) {	
	
		if(nmrotina == "MATRIC" && idseqttl == 2){
				
			indarray_proc = retornaIndiceSelecionadoProc();	
			
			if ( indarray_proc == ''){ 
				return false; 
			}else{
				
				nrctremp = arrayFilhosAvtMatric[indarray_proc]["idseqttl"];
				
			}
		
		}		
	}	
	
	//controlaSocioProprietario();
		
	var msgOperacao = '';	
	
	switch (operacao_proc) {
		// Consulta tabela para consulta formulário
		case 'TC':
			msgOperacao = 'Aguarde, abrindo formulário ...';
			operacao_proc 	= 'CF'; //consulta formulario
			cddopcao_proc    = 'C';	
			break;			
		// Consulta formulário para consulta tabela
		case 'CT': 
		case 'CTP':
			msgOperacao = 'Aguarde, abrindo tabela ...';
			flgPoderes      = (operacao_proc == 'CTP');
			operacao_proc 	= 'CT';	//consulta tabela
			nrcpfcgc_proc 	= '';
			nrdctato 	= '';
			nrdrowid 	= '';
			cddopcao_proc    = 'C';	
			break;				
		// Consulta tabela para alteração
		case 'TA': 
			msgOperacao = 'Aguarde, abrindo formulário ...';
			operacao_proc 	= 'A';
			cddopcao_proc    = 'A';
			break;
		// Alteração para consulta tabela 		
		case 'AT': 
			showConfirmacao('Deseja cancelar altera&ccedil;&atilde;o?','Confirma&ccedil;&atilde;o - Ayllos','controlaOperacaoProc()','bloqueiaFundo(divRotina)','sim.gif','nao.gif');
			return false;
			break;
		// Formulario em modo inclusão para tabela consulta		
		case 'IT': 
           showConfirmacao('Deseja cancelar inclus&atilde;o?','Confirma&ccedil;&atilde;o - Ayllos','controlaOperacaoProc()','bloqueiaFundo(divRotina)','sim.gif','nao.gif');
			return false;
            break;	
		// Tabela consulta para inclusão		
		case 'TI':
			msgOperacao = 'Aguarde, abrindo formulário ...';
			operacao_proc 	= 'I'; 
			nrcpfcgc_proc 	= '';
			nrdctato 	= '';
			nrdrowid 	= '';
			cddopcao_proc    = 'I';	
			break;
		// Formulario de inclução com os dados de retorno da busca por CONTA ou CPF	
		case 'TB':
			msgOperacao = 'Aguarde, abrindo formulário ...';
			operacao_proc 	= 'IB'; 
			cddopcao_proc    = 'I';	
			break;
		// Formulario de inclução com os dados de retorno da busca por CONTA ou CPF	
		case 'TP':
			msgOperacao = 'Aguarde, abrindo formulário ...';
			operacao_proc 	= 'P'; 
			cddopcao_proc	= 'P';	
			flgPoderes      = false;
			break;	
		// Alteração para validação: Salvando alteração
		case 'AV': 
			manterRotinaProc('VA');
			return false;
			break;
		// Formulario em modo inclusão para validação: Incluindo procurador	
		case 'IV':
			manterRotinaProc('VI');
			return false;
			break;
		// Abre o form. consulta para formulario em modo exclusão	
		case 'TX': 
			msgOperacao = 'Aguarde, abrindo formulário ...';
			cddopcao_proc    = 'E';	
			break;	
		// Tabela consulta para formulario em modo exclusão	
		case 'EV':
			manterRotinaProc(operacao_proc);
			return false;
            break;
		case 'E':
			manterRotinaProc(operacao_proc);
			return false;
            break;
		// Dados validados. Altera dados. 
		case 'VA': 
			manterRotinaProc('A');
			return false;
            break;
		//Dados validados. Inclui dados.	
		case 'VI': 
			manterRotinaProc('I');
			return false;
            break;		
		case 'PI': //Validar dthabmen, inhabmen, dtnascto
			manterRotinaProc('PI'); 
			return false; 
			break;	
		default:  
			msgOperacao = 'Aguarde, abrindo tela ...'
			operacao_proc 	= 'CT';
			nrcpfcgc_proc 	= '';
			nrdrowid 	= '';
			nrdctato 	= '';
			cddopcao_proc 	= 'C';
			
	}
	
	// $('#divConteudoOpcao').css({'-moz-opacity':'0','filter':'alpha(opacity=0)','opacity':'0'});
	$('.divRegistros').remove();
	showMsgAguardo(msgOperacao);
		
	// Executa script de confirmação através de ajax
	$.ajax({		
		type: 'POST',
		dataType: 'html',
		url: UrlSite + 'includes/procuradores/principal.php', 
		data: {
			nrdconta     : nrdconta, 
			idseqttl     : idseqttl, 
			nrcpfcgc_proc: nrcpfcgc_proc,
			nrcpfcgc     : nrcpfcgc_proc,
			nrdctato     : nrdctato, 
			nrdrowid     : nrdrowid, 
			cddopcao_proc: cddopcao_proc,
			operacao_proc: operacao_proc, 
			nmdatela     : nmdatela,
			nmrotina     : nmrotina,
			aux_operacao : aux_operacao,
			flgcadas     : flgcadas,
			redirect     : 'script_ajax'			
		}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError('error','Não foi possível concluir a requisição.','Alerta - Ayllos','bloqueiaFundo(divRotina)');
		},
		success: function(response) {
			if ( response.indexOf('showError("error"') == -1 ) {				
				$('#divConteudoOpcao').html(response);
							
				if (flgPoderes) {
					controlaOperacaoProc('TP');
				}	
							
			} else {
				eval( response );
				controlaFocoProc( operacao_proc );
			}
			
			controlaSocioProprietario();
			
			return false;	
		}				
	});	
}

function manterRotinaProc(operacao_proc) {

	nrcpfcgc_proc = $('#nrcpfcgc','#frmDadosProcuradores').val();
	nrcpfcgc_proc = normalizaNumero( nrcpfcgc_proc );

	/* Quando estiver sendo excluido nao vamos validar o cpf */
	if( operacao_proc != 'EV' &&  operacao_proc != 'E' && !validaCpfCnpj(nrcpfcgc_proc,1) ) { 
		showError('error','CPF inv&aacute;lido.','Alerta - Ayllos','bloqueiaFundo(divRotina,\'nrcpfcgc\',\'frmDadosProcuradores\');'); 
		return false; 
	}
	
	hideMsgAguardo();		
	var msgOperacao = '';
	
	switch (operacao_proc) {	
	
		case 'A' : msgOperacao = 'Aguarde, alterando ...'; break;
		case 'I' : msgOperacao = 'Aguarde, incluindo ...'; break;
		case 'VA': msgOperacao = 'Aguarde, validando alteração ...'; break;
		case 'VI': msgOperacao = 'Aguarde, validando inclusão ...'; break;			
		case 'EV': msgOperacao = 'Aguarde, validando exclusão ...'; break;				
		case 'E':  msgOperacao = 'Aguarde, excluindo ...'; break;				
		case 'PI': msgOperacao = 'Aguarde, validando alteração ...'; break;						
		default: return false; break;
		
	}
	
	showMsgAguardo( msgOperacao );
	
	// Recebendo valores do formulário
	nrcpfcgc_proc = $('#nrcpfcgc','#frmDadosProcuradores').val();
	nrdctato = $('#nrdctato','#frmDadosProcuradores').val();
	cdoeddoc = $('#cdoeddoc','#frmDadosProcuradores').val(); 
	dtnascto = $('#dtnascto','#frmDadosProcuradores').val(); 
	dthabmen = $('#dthabmen','#frmDadosProcuradores').val(); 
	inhabmen = $('#inhabmen','#frmDadosProcuradores').val(); 
	dtemddoc = $('#dtemddoc','#frmDadosProcuradores').val(); 
	dtadmsoc = $('#dtadmsoc','#frmDadosProcuradores').val();
	nmdavali = $('#nmdavali','#frmDadosProcuradores').val(); 
	nrdocava = $('#nrdocava','#frmDadosProcuradores').val(); 
	cdnacion = $('#cdnacion','#frmDadosProcuradores').val(); 
	dsnatura = $('#dsnatura','#frmDadosProcuradores').val(); 
	complend = $('#complend','#frmDadosProcuradores').val(); 
	nmcidade = $('#nmcidade','#frmDadosProcuradores').val(); 
	nmbairro = $('#nmbairro','#frmDadosProcuradores').val(); 
	dsendres = $('#dsendres','#frmDadosProcuradores').val(); 
	nmpaicto = $('#nmpaicto','#frmDadosProcuradores').val(); 
	nmmaecto = $('#nmmaecto','#frmDadosProcuradores').val(); 
	nrendere = $('#nrendere','#frmDadosProcuradores').val(); 
	nrcepend = $('#nrcepend','#frmDadosProcuradores').val(); 
	dsrelbem = $('#dsrelbem','#frmDadosProcuradores').val(); 
	dtvalida = $('#dtvalida','#frmDadosProcuradores').val(); 
	vledvmto = $('#vledvmto','#frmDadosProcuradores').val();	
	nrcxapst = $('#nrcxapst','#frmDadosProcuradores').val();
	fltemcrd = $('#fltemcrd','#frmDadosProcuradores').val(); // Renato Darosci - 10/02/2015
	
	persocio = ($('#persocio','#frmDadosProcuradores').val() != "") ? $('#persocio','#frmDadosProcuradores').val() : 0;

	tpdocava = $('#tpdocava > option:selected','#frmDadosProcuradores').val(); 
	cdufddoc = $('#cdufddoc > option:selected','#frmDadosProcuradores').val();
	cdestcvl = $('#cdestcvl > option:selected','#frmDadosProcuradores').val();
	cdufresd = $('#cdufresd > option:selected','#frmDadosProcuradores').val();
	dsproftl = $('#dsproftl > option:selected','#frmDadosProcuradores').val(); 	
	
	flgdepec = ($('#flgdepec > option:selected','#frmDadosProcuradores').val() != null) ? $('#flgdepec','#frmDadosProcuradores').val() : 'no';
	
	vloutren = ($('#vloutren','#frmDadosProcuradores').val() != null) ? $('#vloutren','#frmDadosProcuradores').val() : 0;
	dsoutren = $('#dsoutren','#frmDadosProcuradores').val();
	
	nrdctato = normalizaNumero( nrdctato );
	nrendere = normalizaNumero( nrendere );
	nrcepend = normalizaNumero( nrcepend );
	nrcxapst = normalizaNumero( nrcxapst );
    persocio = normalizaNumero( persocio );
	vloutren = normalizaNumero( vloutren );
	
	cdoeddoc = trim( cdoeddoc );
	nmdavali = trim( nmdavali );
	nrdocava = trim( nrdocava );
	cdnacion = trim( cdnacion );
	dsnatura = trim( dsnatura );
	complend = trim( complend );
	nmcidade = trim( nmcidade );
	nmbairro = trim( nmbairro );
	dsendres = trim( dsendres );
	nmpaicto = trim( nmpaicto );
	nmmaecto = trim( nmmaecto );
	dsproftl = trim( dsproftl );
	flgdepec = trim( flgdepec );
	dsoutren = trim( dsoutren );
	
	var camposXML = '';
	camposXML = retornaCampos( arrayBens, '|' );
		
	var dadosXML = '';
	dadosXML = retornaValores( arrayBens, ';', '|', camposXML );
	
	// Tratamento para os radio do sexo
	var sexoMas = $('#sexoMas','#frmDadosProcuradores').prop('checked');
	var sexoFem = $('#sexoFem','#frmDadosProcuradores').prop('checked');	
	
	if(sexoMas) {
		var cdsexcto = '1';
		
	}else if (sexoFem) {
		var cdsexcto = '2';
		
	}else {
		var cdsexcto = '';
		
	}
		
	// Executa script de confirmação através de ajax
	$.ajax({		
		type: 'POST',
		url: UrlSite + 'includes/procuradores/manter_rotina.php', 		
		data: {			
			nrcpfcgc_proc: nrcpfcgc_proc, cdoeddoc: cdoeddoc, dtnascto: dtnascto, 
			dtemddoc: dtemddoc,	dtadmsoc: dtadmsoc,	nrdctato: nrdctato, 
			nmdavali: nmdavali,	cdufddoc: cdufddoc, tpdocava: tpdocava, 
			nrdocava: nrdocava,	cdestcvl: cdestcvl,	cdnacion: cdnacion, 
			dsnatura: dsnatura,	complend: complend, nmcidade: nmcidade, 
			nmbairro: nmbairro,	dsendres: dsendres,	nmpaicto: nmpaicto, 
			nmmaecto: nmmaecto,	nrendere: nrendere,	nrcepend: nrcepend, 
			dsrelbem: dsrelbem,	dsproftl: dsproftl,	dtvalida: dtvalida, 
			vledvmto: vledvmto,	cdsexcto: cdsexcto,	cdufresd: cdufresd,
			nrdconta: nrdconta, idseqttl: idseqttl, dadosXML: dadosXML, 
			camposXML: camposXML, nrcxapst: nrcxapst, nrdrowid: nrdrowid, 
			persocio: persocio, flgdepec: flgdepec, permalte: permalte,
			vloutren: vloutren, dsoutren: dsoutren, verrespo: verrespo, fltemcrd: fltemcrd,
			operacao_proc: operacao_proc, dthabmen: dthabmen, arrayFilhos: arrayFilhos,
			arrayBensMatric: arrayBensMatric, arrayFilhosAvtMatric: arrayFilhosAvtMatric,
			nmrotina: nmrotina, inhabmen: inhabmen, redirect: 'script_ajax'
		}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','bloqueiaFundo(divRotina)');
		},
		success: function(response) {
			try {
				eval(response);
			} catch(error) {
				hideMsgAguardo();
				showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','bloqueiaFundo(divRotina)');
			}
		}				
	});
	
}

function estadoInicialProc() {

	var cNrConta		= $('#nrdctato','#frmDadosProcuradores');
	var cCPF			= $('#nrcpfcgc','#frmDadosProcuradores');
	var camposGrupo2	= $('#nmdavali,#dtnascto,#tpdocava,#cdufddoc,#cdestcvl,#dthabmen,#inhabmen,#nrdocava,#cdoeddoc,#cdufresd,#dtemddoc,#cdnacion,#dsnatura,#dsendres,#nrendere,#complend,#nmbairro,#nrcepend,#nmcidade,#nmmaecto,#nmpaicto,#vledvmto,#nrcxapst','#frmDadosProcuradores');
	var camposGrupo3	= $('#dtvalida, #dtadmsoc, #dsproftl','#frmDadosProcuradores');	
	var sexo			= $('input[name="cdsexcto"]');	
	var cDescBem		= $('#dsrelbem','#frmDadosProcuradores');
    var cDescnac		= $('#dsnacion','#frmDadosProcuradores');
	
	
	$('#frmDadosProcuradores').limpaFormulario();
	cNrConta.habilitaCampo();
	cCPF.desabilitaCampo();
	camposGrupo2.desabilitaCampo();
	camposGrupo3.desabilitaCampo();
	sexo.desabilitaCampo();	
	cDescBem.desabilitaCampo();
    cDescnac.desabilitaCampo();
	
	controlaSocioProprietario();
	removeOpacidade('divConteudoOpcao');
		
	cNrConta.focus();
	
}

function controlaLayoutProc( operacao_proc ) {
	
	altura  = "0";
	largura = "0";
	
	if(operacao_proc == 'CT'){
		altura 	= '205px';
		largura = '750px';
	}else if(operacao_proc == 'P'){
		altura 	= '360px';
		largura = '570px';
	}else{
		altura 	= '620px';
		largura = '575px';
	}
	
	divRotina.css('width',largura);	
	$('#divConteudoOpcao').css('height',altura);		
		
	if ( operacao_proc == 'CT' ) {
	
		var divRegistro = $('div.divRegistros');		
		var tabela      = $('table', divRegistro );
		var linha       = $('table > tbody > tr', divRegistro );
					
		divRegistro.css('height','150px');
		
		var ordemInicial = new Array();
		ordemInicial = [[0,0]];
		
		var arrayLargura = new Array();
		arrayLargura[0] = '70px';
		arrayLargura[1] = '135px';
		arrayLargura[2] = '125px';
		arrayLargura[3] = '100px';
		arrayLargura[4] = '60px';
		
		var arrayAlinha = new Array();
		arrayAlinha[0] = 'right';
		arrayAlinha[1] = 'left';
		arrayAlinha[2] = 'right';
		arrayAlinha[3] = 'right';
		arrayAlinha[4] = 'center';
		arrayAlinha[5] = 'left';
		
		tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha, 'controlaOperacaoProc(\'TC\');' );		
		
	} else {
		
		// FIELDSET IDENTIFICAÇÃO
		var cNrConta		= $('#nrdctato','#frmDadosProcuradores');
		var cCPF			= $('#nrcpfcgc','#frmDadosProcuradores');
		var cNomeProcurador	= $('#nmdavali','#frmDadosProcuradores');
		var cDtNascimento	= $('#dtnascto','#frmDadosProcuradores');	
		var cDthabmen		= $('#dthabmen','#frmDadosProcuradores');
		var cInhabmen		= $('#inhabmne','#frmDadosProcuradores');
		var cTpDocumento	= $('#tpdocava','#frmDadosProcuradores');
		var cDocumento		= $('#nrdocava','#frmDadosProcuradores');
		var cOrgEmissor		= $('#cdoeddoc','#frmDadosProcuradores');	
		var cEstados		= $('#cdufddoc','#frmDadosProcuradores');	
		var cDataEmissao	= $('#dtemddoc','#frmDadosProcuradores');
		var cEstadoCivil	= $('#cdestcvl','#frmDadosProcuradores');
		var cNacionalidade	= $('#dsnacion','#frmDadosProcuradores');
        var cCodnacionali	= $('#cdnacion','#frmDadosProcuradores');
		var cNaturalidade	= $('#dsnatura','#frmDadosProcuradores');
		
		cNrConta.css('width','70px').addClass('conta pesquisa');
		cCPF.css('width','98px').addClass('cpf');
		cNomeProcurador.css('width','307px').addClass('alphanum').attr('maxlength','40');
		cDtNascimento.css('width','78px').addClass('data');	
		cDthabmen.css('width','76px').addClass('data');
		cInhabmen.css('width','273px');
		cTpDocumento.css('width','40px');
		cDocumento.addClass('alphanum').css('width','400px').attr('maxlength','40');
		cOrgEmissor.addClass('alphanum').css('width','52px').attr('maxlength','5');
		cEstados.css('width','45px');
		cDataEmissao.addClass('data').css('width','70px');
		cEstadoCivil.css('width','298px');
		cNacionalidade.css('width','140px');
        cCodnacionali.css('width','65px');
		cNaturalidade.css('width','200px');
		
		// FIELDSET ENDEREÇO
	
		// rotulo endereco
		var rCep		= $('label[for="nrcepend"]','#'+nomeFormProc);
		var rEnd		= $('label[for="dsendres"]','#'+nomeFormProc);
		var rNum		= $('label[for="nrendere"]','#'+nomeFormProc);
		var rCom		= $('label[for="complend"]','#'+nomeFormProc);
		var rCax		= $('label[for="nrcxapst"]','#'+nomeFormProc);	
		var rBai		= $('label[for="nmbairro"]','#'+nomeFormProc);
		var rEst		= $('label[for="cdufresd"]','#'+nomeFormProc);	
		var rCid		= $('label[for="nmcidade"]','#'+nomeFormProc);
		
		rCep.addClass('rotulo').css('width','70px');
		rEnd.addClass('rotulo-linha').css('width','35px');
		rNum.addClass('rotulo').css('width','70px');
		rCom.addClass('rotulo-linha').css('width','52px');
		rCax.addClass('rotulo').css('width','70px');
		rBai.addClass('rotulo-linha').css('width','52px');
		rEst.addClass('rotulo').css('width','70px');
		rCid.addClass('rotulo-linha').css('width','52px');
		
		// campo endereco
		var cCep		= $('#nrcepend','#'+nomeFormProc);
		var cEnd		= $('#dsendres','#'+nomeFormProc);
		var cNum		= $('#nrendere','#'+nomeFormProc);
		var cCom		= $('#complend','#'+nomeFormProc);
		var cCax		= $('#nrcxapst','#'+nomeFormProc);		
		var cBai		= $('#nmbairro','#'+nomeFormProc);
		var cEst		= $('#cdufresd','#'+nomeFormProc);	
		var cCid		= $('#nmcidade','#'+nomeFormProc);

		cCep.addClass('cep pesquisa').css('width','72px').attr('maxlength','9');
		cEnd.addClass('alphanum').css('width','317px').attr('maxlength','40');
		cNum.addClass('numerocasa').css('width','72px').attr('maxlength','7');
		cCom.addClass('alphanum').css('width','317px').attr('maxlength','40');	
		cCax.addClass('caixapostal').css('width','72px').attr('maxlength','6');	
		cBai.addClass('alphanum').css('width','317px').attr('maxlength','40');	
		cEst.css('width','72px');	
		cCid.addClass('alphanum').css('width','317px').attr('maxlength','25');

		var endDesabilita = $('#dsendres,#cdufresd,#nmbairro,#nmcidade','#'+nomeFormProc);

			
		// FIELDSET FILIAÇÃO	
		$('#nmpaicto,#nmmaecto','#frmDadosProcuradores').css('width','444px').addClass('alphanum').attr('maxlength','40');
	
		// FIELDSET PARTICIPAÇÃO
		$('label[for="persocio"]','#'+nomeFormProc).addClass('rotulo').css('width','80px');
		$('label[for="flgdepec"]','#'+nomeFormProc).addClass('rotulo-linha');
		$('#persocio','#frmDadosProcuradores').css('width','50px').addClass('porcento').attr('maxlength','6');	
		$('#flgdepec','#frmDadosProcuradores').css('width','50px');	
		var grupoParticipacao = $('#persocio,#flgdepec','#frmDadosProcuradores');
		
		// FIELDSET OUTRAS FONTES DE RENDA
		$('label[for="vloutren"]','#frmDadosProcuradores').addClass('rotulo-linha');
		$('label[for="dsoutren"]','#frmDadosProcuradores').addClass('rotulo-linha');
		$('#vloutren','#frmDadosProcuradores').addClass('moeda_6').css('width','70px');
		$('#dsoutren','#frmDadosProcuradores').addClass('alphanum').css('width','294px').css('overflow-y','scroll').css('overflow-x','hidden').css('height','75');
		$('#dsoutren','#frmDadosProcuradores').setMask("STRING","200",charPermitido(),"");
		
		// FIELDSET OPERAÇÃO	
		var cDescBem		= $('#dsrelbem','#frmDadosProcuradores');
		var cCargo			= $('#dsproftl','#frmDadosProcuradores');
		var cEndividamento  = $('#vledvmto','#frmDadosProcuradores');
		var cDtVigencia  	= $('#dtvalida','#frmDadosProcuradores');
		var cDtAdmissao  	= $('#dtadmsoc','#frmDadosProcuradores');
		
		cDescBem.css('width','178px');
		cCargo.css('width','182px');
		cEndividamento.css('width','120px');
		cDtAdmissao.css('width','75px');
		cDtVigencia.css('width','76px');
		
		
		// CONTROLA LARGURA PARA FORMULÁRIO DE BENS
		$('label','#frmProcBens').css({'width':'195px'}).addClass('rotulo');
		$('#dsrelbem','#frmProcBens').css({'width':'275px'});
		$('#persemon,#qtprebem','#frmProcBens').css({'width':'40px'});			
		
		// INICIA CONTROLE DA TELA
		var camposGrupo2  = $('#nmdavali,#dtnascto,#tpdocava,#cdufddoc,#dthabmen,#inhabmen,#cdestcvl,#nrdocava,#cdoeddoc,#cdufresd,#dtemddoc,#cdnacion,#dsnatura,#dsendres,#nrendere,#complend,#nmbairro,#nrcepend,#nmcidade,#nmmaecto,#nmpaicto,#vledvmto,#nrcxapst','#frmDadosProcuradores');
		var camposGrupo3  = $('#dtvalida, #dtadmsoc, #dsproftl','#frmDadosProcuradores');		
		var sexo 		  = $('input[name="cdsexcto"]');
		var cCampos       = $('#vloutren,#dsoutren','#frmDadosProcuradores');


		// Sempre inicia com tudo bloqueado
		cNrConta.desabilitaCampo();
		cCPF.desabilitaCampo();
		camposGrupo2.desabilitaCampo();
		camposGrupo3.desabilitaCampo();
		grupoParticipacao.desabilitaCampo();
		sexo.desabilitaCampo();	
		cDescBem.desabilitaCampo();	
		cCampos.desabilitaCampo();
        cNacionalidade.desabilitaCampo();
		
				
		switch (operacao_proc) {
			
			// Caso é inclusão, limpar dados do formulário					
			case 'I': 
				$('#frmDadosProcuradores').limpaFormulario();
				montaSelect('b1wgen0059.p','busca_cargos','dsproftl','dsdcargo','dsdcargo','');
				montaSelect('b1wgen0059.p','busca_estado_civil','cdestcvl','cdestcvl','cdestcvl;dsestcvl','');				
				cNrConta.habilitaCampo();
				break;
				
			//Caso é inclusão, apos a busca de dados pela conta ou pelo CPF 
			case 'IB':
				//Se o nº da conta for igual a 0 ou vazio então o formulario é desbloqueado para preenchimento 
				if ( cNrConta.val() == '0' || cNrConta.val() == '' ){
					camposGrupo2.habilitaCampo();
					sexo.habilitaCampo();	
					cDescBem.habilitaCampo();
					cDescBem.prop('disabled',true);					
					endDesabilita.desabilitaCampo();	
					
					if( $('#cdestcvl','#'+nomeFormProc).val() == "2" ||
						$('#cdestcvl','#'+nomeFormProc).val() == "3" ||
						$('#cdestcvl','#'+nomeFormProc).val() == "4" || 
						$('#cdestcvl','#'+nomeFormProc).val() == "8" || 
						$('#cdestcvl','#'+nomeFormProc).val() == "9" || 
						$('#cdestcvl','#'+nomeFormProc).val() == "11" ){
					
						$('#inhabmen','#'+nomeFormProc).desabilitaCampo();
						$('#dthabmen','#'+nomeFormProc).desabilitaCampo();
			
					}else{			
					
						( $('#inhabmen','#'+nomeFormProc).val() != 1 ) ? $('#dthabmen','#'+nomeFormProc).desabilitaCampo() : $('#dthabmen','#'+nomeFormProc).habilitaCampo();
						
					}

					
				}
				camposGrupo3.habilitaCampo();
				break;
				
			// Caso é alteração, se conta = 0, libera grupo 2 e 3, senão libera somente grupo 3 	
			case 'A': 
				if ( nrdctato == 0 ) {
					camposGrupo2.habilitaCampo();
					sexo.habilitaCampo();
					camposGrupo3.habilitaCampo();
					cDescBem.habilitaCampo();			
					cDescBem.prop('disabled',true);
					endDesabilita.desabilitaCampo();	
					
					if( $('#cdestcvl','#'+nomeFormProc).val() == "2" ||
						$('#cdestcvl','#'+nomeFormProc).val() == "3" ||
						$('#cdestcvl','#'+nomeFormProc).val() == "4" || 
						$('#cdestcvl','#'+nomeFormProc).val() == "8" || 
						$('#cdestcvl','#'+nomeFormProc).val() == "9" || 
						$('#cdestcvl','#'+nomeFormProc).val() == "11" ){
					
						$('#inhabmen','#'+nomeFormProc).desabilitaCampo();
						$('#dthabmen','#'+nomeFormProc).desabilitaCampo();
			
					}else{			
					
						( $('#inhabmen','#'+nomeFormProc).val() != 1 ) ? $('#dthabmen','#'+nomeFormProc).desabilitaCampo() : $('#dthabmen','#'+nomeFormProc).habilitaCampo();
						
					}
					
									
				} else {
					camposGrupo3.habilitaCampo();
				}
				break;
				
			// Caso é exclusão, lista o formulário e bloqueia todos os campos
			case 'FX': 
				cNrConta.desabilitaCampo();
				cCPF.desabilitaCampo();
				camposGrupo2.desabilitaCampo();
				sexo.desabilitaCampo();
				camposGrupo3.desabilitaCampo();
				break;	
			
			default: 
				cDescBem.desabilitaCampo(); 
				break;
		}	
		
		// Ao dar foco no bens já abre janela
		cDescBem.unbind('focusin').bind('focusin', function() {
			mostraTabelaBens('BT');
			cDtVigencia.focus();
		});
	
		// Se operação é diferente de "I" monto os selects usados na tela
		if ( operacao_proc != 'I' ) {
		
			montaSelect('b1wgen0059.p','busca_cargos','dsproftl','dsdcargo','dsdcargo',dsProfissao);
			montaSelect('b1wgen0059.p','busca_estado_civil','cdestcvl','cdestcvl','cdestcvl;dsestcvl',estadoCivil);				
		}

		// Controle do número da conta
		cNrConta.unbind('keypress').bind('keypress', function(e){ 	
		
			if ( divError.css('display') == 'block' ) { return false; }		
			
			// Se é a tecla ENTER, verificar numero conta e realizar as devidas operações
			if ( e.keyCode == 13 ) {		
				
				// Armazena o número da conta na variável global
				nrdctato = normalizaNumero( $(this).val() );
			
				// Verifica se o número da conta é vazio
				if ( nrdctato == 0 ) { 
					$(this).desabilitaCampo();
					cCPF.habilitaCampo();
					cCPF.focus();
					return false; 
				}
					
				// Verifica se a conta é válida
				if ( !validaNroConta(nrdctato) ) { showError('error','Conta/dv inválida.','Alerta - Ayllos','focaCampoErro(\'nrdctato\',\'frmDadosProcuradores\');'); return false; }
				
				// Se chegou até aqui, a conta é diferente do vazio e é válida, então realizar a operação desejada
				nrcpfcgc_proc = '';				
				nrdrowid = '';				
				showMsgAguardo('Aguarde, buscando dados do representante...');					
				controlaOperacaoProc('TB');
			} 
		});

		
		// Controle para informar dados de socio proprietario
		cCargo.unbind('blur').bind('blur', function(e){ 	
		
			if ( divError.css('display') == 'block' ) { return false; }		
			
			if ($('#dsproftl > option:selected','#frmDadosProcuradores').val() != "")
				cargo = $('#dsproftl > option:selected','#frmDadosProcuradores').val();
			/*Fabricio*/	
			if ((cargo == "SOCIO/PROPRIETARIO") && (dscritica != "")) {
				showError('error',dscritica,'Alerta - Ayllos','bloqueiaFundo(divRotina);controlaOperacaoProc()');
				return false;
			}
			
			controlaSocioProprietario();
		});	
		
		$('#flgdepec','#frmDadosProcuradores').unbind('blur').bind('blur', function(e){ 	
		
			if ( divError.css('display') == 'block' ) { return false; }		
				
			controlaSocioProprietario();
		});

		$('#persocio','#frmDadosProcuradores').unbind('blur').bind('blur', function(e){ 	
		
			if ( divError.css('display') == 'block' ) { return false; }
				
			controlaSocioProprietario();
		});
			
		$('#persocio','#frmDadosProcuradores').unbind("keydown").bind("keydown",function(e) {		
			if (e.keyCode == 13) {
				$('#persocio','#frmDadosProcuradores').blur();
				return false;
			}	 
		});	
		
		// Controle no CPF
		cCPF.unbind('keypress').bind('keypress', function(e){ 	
		
			if ( divError.css('display') == 'block' ) { return false; }		
			
			// Se é a tecla ENTER, verificar numero conta e realizar as devidas operações
			if ( e.keyCode == 13 ) {		
				
				// Armazena o número da conta na variável global
				cpf = normalizaNumero( $(this).val() );
			
				// Verifica se o número da conta é vazio
				if ( cpf == 0 ) { return false; }
					
				// Verifica se a conta é válida
				if ( !validaCpfCnpj(cpf ,1) ) { showError('error','CPF inv&aacute;lido.','Alerta - Ayllos','focaCampoErro(\'nrcpfcgc\',\'frmDadosProcuradores\');'); return false; }
				
				// Se chegou até aqui, a conta é diferente do vazio e é válida, então realizar a operação desejada
				cpfaux 		= cpf;	
				nrcpfcgc_proc 	= cpf;
				nrdctato 	= 0;
				nrdrowid 	= '';
				showMsgAguardo('Aguarde, buscando dados do representante...');
				controlaOperacaoProc('TB');
			} 
		});				
		
		
		//Controle para verificar idade e permitir acesso a tela Resp. Legal
		cDtNascimento.unbind('change').bind('change', function() { 
			aux_dscdaope = operacao_proc;
			controlaOperacaoProc('PI');
						
		});
		
		cDthabmen.unbind('change').bind('change', function() { 
			aux_dscdaope = operacao_proc;
			controlaOperacaoProc('PI');
						
		});
		
		$('#inhabmen','#frmDadosProcuradores').unbind('change').bind('change', function() {
		
			if( $(this).val() != 1 ){
				cDthabmen.desabilitaCampo();
				cDthabmen.val('');
				cTpDocumento.focus();
			}else{
				cDthabmen.habilitaCampo().focus();
			}
			
			aux_dscdaope = operacao_proc;
			controlaOperacaoProc('PI');
			
		});
				
				
		cEstadoCivil.unbind('keypress').bind('keypress', function(e){
			
			if(e.keyCode == 13){
		
			//Quando estado civil for "Casado" e idade for menor que 18 anos, a pessoa passa automaticamente a ser emancipada.
			if(($(this).val() == "2"                             ||
				$(this).val() == "3"                             ||
				$(this).val() == "4"                             || 
				$(this).val() == "8"                             || 
				$(this).val() == "9"                             || 
				$(this).val() == "11" )                          &&  
				nrdeanos_proc < 18	                             &&
				$('#inhabmen','#frmDadosProcuradores').val() == 0){
			
				$('#inhabmen','#frmDadosProcuradores').val(1).habilitaCampo();
				cDthabmen.val(dtmvtolt).habilitaCampo();
	
			}else{
				$('#inhabmen','#frmDadosProcuradores').habilitaCampo();
				cDthabmen.habilitaCampo();
			}
			
			
			aux_dscdaope = operacao_proc;		
			controlaOperacaoProc('PI');
			
		}
			
		});
		
		cEstadoCivil.unbind('change').bind('change',function() {
					
			//Quando estado civil for "Casado" e idade for menor que 18 anos, a pessoa passa automaticamente a ser emancipada.
			if(($(this).val() == "2"                             ||
				$(this).val() == "3"                             ||
				$(this).val() == "4"                             || 
				$(this).val() == "8"                             || 
				$(this).val() == "9"                             || 
				$(this).val() == "11" )                          &&
				nrdeanos_proc < 18                               &&
				$('#inhabmen','#frmDadosProcuradores').val() == 0){
							
				$('#inhabmen','#frmDadosProcuradores').val(1).habilitaCampo();
				cDthabmen.val(dtmvtolt).habilitaCampo();

			}else{
				$('#inhabmen','#frmDadosProcuradores').habilitaCampo();
				cDthabmen.habilitaCampo();
				 
			}
			
			aux_dscdaope = operacao_proc;
			controlaOperacaoProc('PI');
								
		});
		
		cEstadoCivil.unbind('focusout').bind('focusout',function() {
					
			//Quando estado civil for "Casado" e idade for menor que 18 anos, a pessoa passa automaticamente a ser emancipada.
			if(($(this).val() == "2"                             ||
				$(this).val() == "3"                             ||
				$(this).val() == "4"                             || 
				$(this).val() == "8"                             || 
				$(this).val() == "9"                             || 
				$(this).val() == "11" )                          &&
				nrdeanos_proc < 18                               &&
				$('#inhabmen','#frmDadosProcuradores').val() == 0){
							
				$('#inhabmen','#frmDadosProcuradores').val(1).habilitaCampo();
				cDthabmen.val(dtmvtolt).habilitaCampo();

			}else{
				$('#inhabmen','#frmDadosProcuradores').habilitaCampo();
				cDthabmen.habilitaCampo();
				 
			}
			
			aux_dscdaope = operacao_proc;
			controlaOperacaoProc('PI');
								
		});
		
		cEndividamento.unbind('keypress').bind('keypress', function(e){
			
			if(e.keyCode == 13){
				cDtVigencia.focus();
				return false;
			}
			
		});
		
		
		layoutPadrao();
		controlaPesquisasProc();
		
	}
	
	$('#nrdctato','#frmDadosProcuradores').trigger('blur');
	$('#nrcpfcgc','#frmDadosProcuradores').trigger('blur');
	$('#nrendere','#frmDadosProcuradores').trigger('blur');
	$('#nrcepend','#frmDadosProcuradores').trigger('blur');
	$('#nrcxapst','#frmDadosProcuradores').trigger('blur');
	$('#dsproftl','#frmDadosProcuradores').trigger('blur');

	hideMsgAguardo();
	controlaBotoesProc(operacao_proc);
	bloqueiaFundo(divRotina);
	removeOpacidade('divConteudoOpcao');
	controlaFocoProc(operacao_proc);
	divRotina.centralizaRotinaH();
		
	return false;	
}

function controlaFocoProc(operacao_proc) {

	if(in_array(operacao_proc,['CT','',])) {
		$('#btAlterar','#divBotoesTabProc').focus();
	}else if ( operacao_proc == 'CF' ) {
		$('#btVoltarCns','#divBotoesFormProc').focus();
	}else if ( operacao_proc == 'A' ) {
		$('#btVoltarAlt','#divBotoesFormProc').focus();
	}else if ( operacao_proc == 'I' || operacao_proc == 'IB' ) {
		$('.campo:first','#'+nomeFormProc).focus();
	}
	
	return false;
}

function controlaPesquisasProc() {

	// Variável local para guardar o elemento anterior
	var campoAnterior = '';
	var bo, procedure, titulo, qtReg, filtros, colunas;	
	var camposOrigem = 'nrcepend;dsendres;nrendere;complend;nrcxapst;nmbairro;cdufresd;nmcidade';	
	
	bo = 'b1wgen0059.p';
	
	// Atribui a classe lupa para os links de desabilita todos
	var lupas = $('a:not(.lupaBens)','#frmDadosProcuradores');
	lupas.addClass('lupa').css('cursor','auto');	
	// Percorrendo todos os links
	lupas.each( function() {
	
		if ( !$(this).prev().hasClass('campoTelaSemBorda') ) $(this).css('cursor','pointer');		
		
		$(this).unbind("click").bind("click",( function() {
			if ( $(this).prev().hasClass('campoTelaSemBorda') ) {
				return false;
			} else {			
				// Obtenho o nome do campo anterior
				campoAnterior = $(this).prev().attr('name');		
				
				// Nr. Conta Procurador
				if ( campoAnterior == 'nrdctato' ) {
					mostraPesquisaAssociado('nrdctato','frmDadosProcuradores',divRotina);
					return false;					
				
				// Nacionalidade
				} else if ( campoAnterior == 'cdnacion' ) {
					bo			= 'b1wgen0059.p';
					procedure	= 'busca_nacionalidade';
					titulo      = 'Nacionalidade';
					qtReg		= '50';
					filtros 	= 'Codigo;cdnacion;30px;N;;N|Nacionalidade;dsnacion;200px;S;';
					colunas 	= 'Codigo;cdnacion;15%;left|Descrição;dsnacion;85%;left';
					mostraPesquisa(bo,procedure,titulo,qtReg,filtros,colunas,divRotina);
					return false;				
				// Naturalidade
				} else if ( campoAnterior == 'dsnatura' ) {
					bo			= 'b1wgen0059.p';
					procedure	= 'Busca_Naturalidade';
					titulo      = 'Naturalidade';
					qtReg		= '50';
					filtros 	= 'Naturalidade;dsnatura;200px;S;';
					colunas 	= 'Naturalidade;dsnatura;100%;left';
					mostraPesquisa(bo,procedure,titulo,qtReg,filtros,colunas,divRotina);
					return false;
				// CEP	
				} else if ( campoAnterior == 'nrcepend' ) {
					mostraPesquisaEndereco(nomeFormProc, camposOrigem, divRotina);
					return false;					
				}  		
			}
		}));
	});
	// Controle da lupaBens
	var lupaBens = $('.lupaBens','#frmDadosProcuradores');
	// Somente estará habilitada quando o campo "NOME" estiver habilitado
	if ( $('#nmdavali','#frmDadosProcuradores').hasClass('campoTelaSemBorda') ) {
		lupaBens.css('cursor','auto');
		lupaBens.click( function() { return false; } );
	} else {
		lupaBens.css('cursor','pointer');
		lupaBens.click( function() { mostraTabelaBens('BT'); return false; } );
	}
	
	// Cep
	$('#nrcepend','#'+nomeFormProc).buscaCEP(nomeFormProc, camposOrigem, divRotina);
	
    //  Nacionalidade
	$('#cdnacion','#'+nomeFormProc).unbind('change').bind('change',function() {
		procedure	= 'BUSCAR_NACIONALIDADE';
		titulo      = ' Nacionalidade';
		filtrosDesc = '';
		buscaDescricao('CADA0001',procedure,titulo,$(this).attr('name'),'dsnacion',$(this).val(),'dsnacion',filtrosDesc,nomeFormProc);        
	return false;
	});
	
	return false;
}

function controlaSocioProprietario(){

	var grupoParticipacao = $('#persocio,#flgdepec','#frmDadosProcuradores');
	var grupoOutrasFontesRenda = $('#vloutren,#dsoutren','#'+nomeFormProc);
	var divDadosSocioProp = $('#divDadosSocioProp');
	
	var flgdepec = $('#flgdepec','#frmDadosProcuradores');
		
	if  (cddopcao_proc != "E" && cddopcao_proc != "C") {
			
		grupoParticipacao.habilitaCampo();
		
		if ((parseFloat(($('#persocio','#frmDadosProcuradores').val().replace(".","")).replace(",",".")) >= 
															parseFloat((vlpercsocio.replace(".","")).replace(",","."))) &&
															(parseFloat((vlpercsocio.replace(".","")).replace(",",".")) > 0)){
			if ($('#flgdepec > option:selected','#frmDadosProcuradores').val() != "yes"){
				grupoOutrasFontesRenda.habilitaCampo();
			} else {
				grupoOutrasFontesRenda.limpaFormulario();
				grupoOutrasFontesRenda.desabilitaCampo();
			}
		} else {
			flgdepec.limpaFormulario();
			grupoOutrasFontesRenda.limpaFormulario();
			flgdepec.desabilitaCampo();
			grupoOutrasFontesRenda.desabilitaCampo();
			
		}
	}
	
	controlaPesquisasProc();
}

//Monta a div e mostra a tabela de descrição de bens
function mostraTabelaBens( operacao_proc ) {

	showMsgAguardo('Aguarde, buscando bens...');
	
	exibeRotina($('#divUsoGenerico'));
	
	$('#tbbens').remove();
	// Executa script de confirmação através de ajax
	$.ajax({		
		type: 'POST',
		dataType: 'html',
		url: UrlSite + 'includes/procuradores/bens.php', 
		data: {
			operacao_proc: operacao_proc,
			redirect: 'html_ajax'			
			}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError('error','Não foi possível concluir a requisição.','Alerta - Ayllos',"blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
		success: function(response) {
			$('#divUsoGenerico').html(response);
			controlaOperacaoBens(operacao_proc);			
		}				
	});
	
	return false;
	
}

//Controla as operações da descrição de bens
function controlaOperacaoBens(operacao_proc) {
	
	var msgOperacao = '';	
	
	if ( operacao_proc == 'BF' || operacao_proc == 'E' ) {
		indarray = '';
		$('table > tbody > tr', '#divProcBensTabela > div.divRegistros').each( function() {
			if ( $(this).hasClass('corSelecao') ) {
				indarray = $('input', $(this) ).val();
			}
		});	
		if ( indarray == '' ) { return false; }
	}

	switch (operacao_proc) {
	
		//Mostra o formulario de bens
		case 'BF':
		
			//Oculto a tabela e mostro o formulario
			$('#divProcBensFormulario').css('display','block');
			$('#divProcBensTabela').css('display','none');
			
			//Preencho o formulario com os dados do bem selecionado;
			$('input[name="dsrelbem"]','#divProcBensFormulario').val(arrayBens[indarray]['dsrelbem']);
			$('input[name="persemon"]','#divProcBensFormulario').val(arrayBens[indarray]['persemon']);
			$('input[name="qtprebem"]','#divProcBensFormulario').val(arrayBens[indarray]['qtprebem']);
			$('input[name="vlprebem"]','#divProcBensFormulario').val(arrayBens[indarray]['vlprebem']);
			$('input[name="vlrdobem"]','#divProcBensFormulario').val(arrayBens[indarray]['vlrdobem']);
			msgOperacao = 'abrindo bens';
			break;
		
		//Inclusão. Mostra formulario de bens vazio.	
		case 'BI':
		
			if ( arrayBens.length < 6 ) {
				$('#divProcBensFormulario').css('display','block');
				$('#divProcBensTabela').css('display','none');
				msgOperacao = 'abrindo formulário de bens';
			}else{
				showError('error','Limite de cadastramento atingido','Alerta - Ayllos',"bloqueiaFundo($('#divUsoGenerico'));");				
				return false;
			}
			
			break;
		
		// Mostra a tabela de bens	
		case 'BT':
		
			// Oculto o formulario e mostro a tabela
			msgOperacao = 'abrindo tabela de bens';
			break;
			
		case 'BR':
		
			// Oculto o formulario e mostro a tabela
			showConfirmacao('Deseja cancelar opera&ccedil;&atilde;o?','Confirma&ccedil;&atilde;o - Ayllos','mostraTabelaBens(\'BT\')','bloqueiaFundo($(\'#divUsoGenerico\'))','sim.gif','nao.gif');
			return false;
			break;
		
		//Excluindo bem do Array	
		case 'E':
		
			showMsgAguardo('Aguarde, excluindo ...');	
			
			if(nmrotina == "MATRIC" && idseqttl == 2){
			
				arrayBens[indarray]['cddopcao'] = 'E';
				arrayBens[indarray]['deletado'] = true;
				
			}else{
			
				arrayBens.splice(indarray,1);
				
			}
			
			mostraTabelaBens('BT');
			return false;
			break;
		
		//Salvando alterações do bem no Array	
		case 'AS':
		
			arrayBens[indarray]['dsrelbem'] = $('input[name="dsrelbem"]','#divProcBensFormulario').val();
			arrayBens[indarray]['persemon'] = $('input[name="persemon"]','#divProcBensFormulario').val();
			arrayBens[indarray]['qtprebem'] = $('input[name="qtprebem"]','#divProcBensFormulario').val();
			arrayBens[indarray]['vlprebem'] = $('input[name="vlprebem"]','#divProcBensFormulario').val();
			arrayBens[indarray]['vlrdobem'] = $('input[name="vlrdobem"]','#divProcBensFormulario').val();			
			
			if(nmrotina == "MATRIC" && idseqttl == 2){
			
				arrayBens[indarray]['cddopcao'] = 'A';		
				
			}
			
			mostraTabelaBens('BT');
			return false
			break;
		
		//Salvando inclusões do bem no Array		
		case 'IS':
		
			i = arrayBens.length;
			eval('var arrayBem'+i+' = new Object();');
			eval('arrayBem'+i+'["dsrelbem"] = $(\'input[name="dsrelbem"]\',\'#divProcBensFormulario\').val();');
			eval('arrayBem'+i+'["cdsequen"] = $(\'input[name="cdsequen"]\',\'#divProcBensFormulario\').val();');
			eval('arrayBem'+i+'["persemon"] = $(\'input[name="persemon"]\',\'#divProcBensFormulario\').val();');
			eval('arrayBem'+i+'["qtprebem"] = $(\'input[name="qtprebem"]\',\'#divProcBensFormulario\').val();');
			eval('arrayBem'+i+'["vlprebem"] = $(\'input[name="vlprebem"]\',\'#divProcBensFormulario\').val();');
			eval('arrayBem'+i+'["vlrdobem"] = $(\'input[name="vlrdobem"]\',\'#divProcBensFormulario\').val();');			
			
			if(nmrotina == "MATRIC" && idseqttl == 2){
			
				eval('arrayBem'+i+'["cpfdoben"] = $("#nrcpfcgc","#frmDadosProcuradores").val();');			
				eval('arrayBem'+i+'["deletado"] = false;');			
				eval('arrayBem'+i+'["cddopcao"] = "I";');
				
			}
			
			eval('arrayBens['+i+'] = arrayBem'+i+';');			
			mostraTabelaBens('BT');
			return false
			break;	
			
		default:  
           	break;
	}
	
	showMsgAguardo('Aguarde, ' + msgOperacao + ' ...');	
	controlaLayoutBens(operacao_proc);	
	return false;
	
}

// Controla o layout da descrição de bens
function controlaLayoutBens( operacao_proc ) {

	//$('#divUsoGenerico').fadeTo(1,0.01);
	
	// Operação consultando
	if (operacao_proc == 'BT') {	
	
		$('#divProcBensTabela').css('display','block');
		$('#divProcBensFormulario').css('display','none');
		
		// Formata o tamanho da tabela
		$('#divProcBensTabela').css({'height':'215px','width':'517px'});
		
		// Monta Tabela dos Itens
		$('#divProcBensTabela > div > table > tbody').html('');		
		
		for( var i in arrayBens ) {
								
			if(nmrotina == "MATRIC" && idseqttl == 2){
				
				if(arrayBens[i]['deletado'] == false 										     &&
				  ((indarray_proc != ''														     &&
				   arrayBens[i]['nrdrowid'] == arrayFilhosAvtMatric[indarray_proc]['nrdrowid']   &&
				   arrayBens[i]['cpfdoben'] == arrayFilhosAvtMatric[indarray_proc]['nrcpfcgc'] ) ||
				   arrayBens[i]['cpfdoben'] == $("#nrcpfcgc","#frmDadosProcuradores").val() )){
								   
				    desc = ( arrayBens[i]['dsrelbem'].length > 16 ) ? arrayBens[i]['dsrelbem'].substr(0,17)+'...' : arrayBens[i]['dsrelbem'] ;
					$('#divProcBensTabela > div > table > tbody').append('<tr></tr>');										
					$('#divProcBensTabela > div > table > tbody > tr:last-child').append('<td><span>'+arrayBens[i]['dsrelbem']+'</span>'+ desc+'<input type="hidden" id="indarray" name="indarray" value="'+i+'" /></td>').css({'text-transform':'uppercase'});
					$('#divProcBensTabela > div > table > tbody > tr:last-child').append('<td>'+number_format(parseFloat(arrayBens[i]['persemon'].replace(',','.')),2,',','.')+'</td>');
					$('#divProcBensTabela > div > table > tbody > tr:last-child').append('<td>'+arrayBens[i]['qtprebem']+'</td>');
					$('#divProcBensTabela > div > table > tbody > tr:last-child').append('<td>'+number_format(parseFloat(arrayBens[i]['vlprebem'].replace(/[.R$ ]*/g,'').replace(',','.')),2,',','.')+'</td>');
					$('#divProcBensTabela > div > table > tbody > tr:last-child').append('<td>'+number_format(parseFloat(arrayBens[i]['vlrdobem'].replace(/[.R$ ]*/g,'').replace(',','.')),2,',','.')+'</td>');
				   
				   }
			
			}else{
			
				desc = ( arrayBens[i]['dsrelbem'].length > 16 ) ? arrayBens[i]['dsrelbem'].substr(0,17)+'...' : arrayBens[i]['dsrelbem'] ;
				$('#divProcBensTabela > div > table > tbody').append('<tr></tr>');										
				$('#divProcBensTabela > div > table > tbody > tr:last-child').append('<td><span>'+arrayBens[i]['dsrelbem']+'</span>'+ desc+'<input type="hidden" id="indarray" name="indarray" value="'+i+'" /></td>').css({'text-transform':'uppercase'});
				$('#divProcBensTabela > div > table > tbody > tr:last-child').append('<td>'+number_format(parseFloat(arrayBens[i]['persemon'].replace(',','.')),2,',','.')+'</td>');
				$('#divProcBensTabela > div > table > tbody > tr:last-child').append('<td>'+arrayBens[i]['qtprebem']+'</td>');
				$('#divProcBensTabela > div > table > tbody > tr:last-child').append('<td>'+number_format(parseFloat(arrayBens[i]['vlprebem'].replace(/[.R$ ]*/g,'').replace(',','.')),2,',','.')+'</td>');
				$('#divProcBensTabela > div > table > tbody > tr:last-child').append('<td>'+number_format(parseFloat(arrayBens[i]['vlrdobem'].replace(/[.R$ ]*/g,'').replace(',','.')),2,',','.')+'</td>');
				
			}
			
		}		
				
		var divRegistro = $('#divProcBensTabela > div.divRegistros');		
		var tabela      = $('table', divRegistro );
	
		divRegistro.css('height','150px');
		
		var ordemInicial = new Array();
		ordemInicial = [[1,1], [0,1]];
		
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
		
		tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha, 'controlaOperacaoBens(\'BF\');' );
	
	//  Operação Alterando/Incluindo - Formatando o formulário
	} else {
	
		var persemon, qtprebem, vlrdobem;
		
		var cTodos      = $('#dsrelbem,#persemon,#qtprebem,#vlprebem,#vlrdobem','#frmProcBens');
		var cDescricao  = $('#dsrelbem','#frmProcBens');
		var cPercentual = $('#persemon','#frmProcBens');
		var cQtParcela  = $('#qtprebem','#frmProcBens');
		var cVlParcela  = $('#vlprebem','#frmProcBens');
		var cVlBem      = $('#vlrdobem','#frmProcBens');	
		
		// Controla largura dos campos
		$('label','#frmProcBens').css({'width':'195px'}).addClass('rotulo');
		cDescricao.css({'width':'275px'});
		cPercentual.css({'width':'50px'});
		cQtParcela.css({'width':'50px'});
		cVlParcela.css({'width':'135px'});
		cVlBem.css({'width':'135px'});	
		
		// Caso é inclusão, limpar dados do formulário
		if ( operacao_proc == 'BI' ) {
		
			$('#frmProcBens').limpaFormulario();
			$('input[name="incluir"]','#divProcBensFormulario').unbind('click');
			$('input[name="incluir"]','#divProcBensFormulario').click( function() { validaBens('IS'); return false; } );
			
		} else if ( operacao_proc == 'BF') {
		
			$('input[name="incluir"]','#divProcBensFormulario').unbind('click');
			$('input[name="incluir"]','#divProcBensFormulario').click( function() { validaBens('AS'); return false; } );
			
		}
	
		// Formata o tamanho do Formulário
		$('#divProcBensFormulario').css({'height':'165px','width':'517px'});
		
		// Adicionando as classes
		cTodos.removeClass('campoErro').habilitaCampo();
		
		// Se percentual sem ônus = 100, trava os campos "qtprebem" e "vlprebem"
		persemon = cPercentual.val();
		persemon = (typeof persemon == 'undefined') ? 0 : persemon.replace(',','.');
		persemon = parseFloat( persemon );

		if ( persemon == 100 ) {
			cQtParcela.unbind().val(0).desabilitaCampo();
			cVlParcela.unbind().val(0,00).desabilitaCampo();
		}		
		
		// Valida Percentual sem Ônus
		cPercentual.change(function () {			
			persemon = parseFloat( cPercentual.val().replace(',','.') );			
			// Se maior do que 100, mostra mensagem de erro e retorna o foco no mesmo campo
			if ( persemon > 100 ) {
				showError('error','Valor Percentual sem &ocirc;nus deve ser menor ou igual a 100,00.','Alerta - Ayllos','bloqueiaFundo($("#divUsoGenerico"),\'persemon\',\'frmProcBens\')');
			} else {
				cPercentual.removeClass('campoErro');
				if ( persemon == 100 ) {
					cQtParcela.unbind().val(0).desabilitaCampo();
					cVlParcela.unbind().val(0,00).desabilitaCampo();
					layoutPadrao();	
				} else {						
					cQtParcela.habilitaCampo();
					cVlParcela.habilitaCampo();
					cQtParcela.focus();				
				}
			}
		});	

		// Valida Quantidade de parcelas
		// Ao mudar a Quantidade de parcelas, não permitir valores menores ou iguais a zero
		cQtParcela.change(function () {
			if ( $(this).hasClass('campo') ) { 
				qtprebem = parseFloat( cQtParcela.val().replace(',','.').replace('','0') );
				if ( qtprebem <= 0 )	{
					showError('error','Parcelas a pagar deve ser maior que zero.','Alerta - Ayllos','bloqueiaFundo($("#divUsoGenerico"),\'qtprebem\',\'frmProcBens\')');
				} else {
					cQtParcela.removeClass('campoErro');
				}
			}
		});
		
		// Valida Valor das parcelas
		cVlParcela.change(function () {
			if ( $(this).hasClass('campo') ) { 
				vlprebem = parseFloat( cVlParcela.val().replace(',','.').replace('','0') );
				if ( vlprebem <= 0 ) {
					showError('error','Valor da parcela deve ser maior que zero.','Alerta - Ayllos','bloqueiaFundo($("#divUsoGenerico"),\'vlprebem\',\'frmProcBens\')');
				} else {
					cVlParcela.removeClass('campoErro');
				}
			}
		});		
		
		// Valida Valor do Bem
		cVlBem.change(function () {
			vlrdobem = parseFloat( cVlBem.val().replace(',','.').replace('','0') );
			if ( vlrdobem <= 0 ) {
				showError('error','Valor do Bem deve ser maior que zero.','Alerta - Ayllos','bloqueiaFundo($("#divUsoGenerico"),\'vlrdobem\',\'frmProcBens\')');
			} else {
				cVlBem.removeClass('campoErro');
			}
		});			
	}	
	
	layoutPadrao();	
	hideMsgAguardo();
	bloqueiaFundo($('#divUsoGenerico'));	
	// removeOpacidade('divUsoGenerico');
	if (operacao_proc != 'BT') { $('#dsrelbem','#divProcBensFormulario').focus(); }
	return false;
	
}

// Função que recebe o ArraBens e monta uma string para gravar no BD
function montaString(array){

	var str = '';
	
	for (var i=0; i < array.length ; i++){
	
		str += trim(array[i]['dsrelbem']);
		str += ';'+array[i]['persemon'];
		str += ';'+array[i]['qtprebem'];
		str += ';'+array[i]['vlprebem'];
		str += ';'+array[i]['vlrdobem'];
		str += ';|';
		
	}
	
	return str;
	
}

function validaBens(operacao_proc){
	
	var dsrelbem, persemon, qtprebem, vlprebem, vlrdobem;	
	
	var cTodos      = $('#dsrelbem,#persemon,#qtprebem,#vlprebem,#vlrdobem','#frmProcBens');
	var cDescricao  = $('#dsrelbem','#frmProcBens');
	var cPercentual = $('#persemon','#frmProcBens');
	var cQtParcela  = $('#qtprebem','#frmProcBens');
	var cVlParcela  = $('#vlprebem','#frmProcBens');
	var cVlBem      = $('#vlrdobem','#frmProcBens');	

	cTodos.removeClass('campoErro');

	// Recebe todos os valores em variáveis
	dsrelbem = trim( cDescricao.val() );
	persemon = cPercentual.val().replace(',','.');
	qtprebem = cQtParcela.val().replace('','0');
	vlprebem = parseFloat( cVlParcela.val().replace(',','.').replace('','0') );
	vlrdobem = parseFloat( cVlBem.val().replace(',','.').replace('','0') );
	
	// Descrição do bem não pode ser vazia
	if ( dsrelbem == '' ) { showError('error','Descri&ccedil;&atilde;o do bem deve se preenchido.','Alerta - Ayllos','bloqueiaFundo($("#divUsoGenerico"),\'dsrelbem\',\'frmProcBens\')');return false; } 
	
	// Não aceita percentual sem ônus maior do que 100%	
	if ( persemon > 100 ) {	showError('error','Percentual sem &ocirc;nus deve ser menor ou igual a 100,00.','Alerta - Ayllos','bloqueiaFundo($("#divUsoGenerico"),\'persemon\',\'frmProcBens\')');return false; }
	
	// Se percentual sem ônus for 100%, então qtde. e valor das parcelas deve ser zero
	if ( ( persemon == 100 ) && ( qtprebem > 0 ) ) {showError('error','Parcelas a pagar deve ser zero.','Alerta - Ayllos','bloqueiaFundo($("#divUsoGenerico"),\'qtprebem\',\'frmProcBens\')');return false; }
	if ( ( persemon == 100 ) && ( vlprebem > 0 ) ) {showError('error','Valor da parcela deve ser zero.','Alerta - Ayllos','bloqueiaFundo($("#divUsoGenerico"),\'vlprebem\',\'frmProcBens\')');return false; }

	// Se percentual sem ônus for menor do que 100%, então qtde. e valor das parcelas devem ser maiores do que zero
	if ( ( persemon < 100 ) && ( qtprebem == 0 ) ) {showError('error','Parcelas a pagar deve ser maior que zero.','Alerta - Ayllos','bloqueiaFundo($("#divUsoGenerico"),\'qtprebem\',\'frmProcBens\')');return false; }
	if ( ( persemon < 100 ) && ( vlprebem == 0 ) ) {showError('error','Parcelas a pagar deve ser maior que zero.','Alerta - Ayllos','bloqueiaFundo($("#divUsoGenerico"),\'vlprebem\',\'frmProcBens\')');return false; }
	
	// Valida valor do bem
	if( vlrdobem <= 0 ) {showError('error','Valor do Bem deve ser maior que zero.','Alerta - Ayllos','bloqueiaFundo($("#divUsoGenerico"),\'vlrdobem\',\'frmProcBens\')');return false; }
	
	controlaOperacaoBens(operacao_proc);
	return false;
}

function controlaBotoesProc(operacao_proc) {
		
	// Primeiro esconde todos os botões
	$('input','#divBotoesFormProc').css('display','none');
	
	if(nmrotina != "MATRIC"){
		aux_cdrotina = operacao_proc;
	}
	
	if( operacao_proc == 'CF'){ 
				
		$('#btVoltarCns','#divBotoesFormProc').attr('src',UrlImagens + 'botoes/voltar.gif'); 
			
		$('#btVoltarCns','#divBotoesFormProc').unbind("click").bind("click",( function() {
			controlaOperacaoProc('CT');
			
		}));
		
		$('#btVoltarCns','#divBotoesFormProc').css('display','inline');
		
						
		if(  ( $('#inhabmen','#'+nomeFormProc).val() == 0 && nrdeanos_proc < 18) || $('#inhabmen','#'+nomeFormProc).val() == 2) {
				
			$('#btProsseguirCns','#divBotoesFormProc').attr('src',UrlImagens + 'botoes/prosseguir.gif'); 
			
			$('#btProsseguirCns','#divBotoesFormProc').unbind("click").bind("click",( function() {
				abrirRotinaProc('RESPONSAVEL LEGAL','Responsavel Legal','responsavel_legal','responsavel_legal2','SC');
				
			}));
			
			$('#btProsseguirCns','#divBotoesFormProc').css('display','inline');
			
		}
		
	}else if(operacao_proc == 'A'){
								
			if( ( $('#inhabmen','#'+nomeFormProc).val() == 0 && nrdeanos_proc < 18) || $('#inhabmen','#'+nomeFormProc).val() == 2) {
				
				$('#btVoltarAlt','#divBotoesFormProc').attr('src',UrlImagens + 'botoes/voltar.gif'); 
			
				$('#btVoltarAlt','#divBotoesFormProc').unbind("click").bind("click",( function() {
					controlaOperacaoProc('AT');
				}));
				
				$('#btSalvarAlt','#divBotoesFormProc').attr('src',UrlImagens + 'botoes/prosseguir.gif'); 
			
				$('#btSalvarAlt','#divBotoesFormProc').unbind("click").bind("click",( function() {
				
					aux_sovalida = false;
					verrespo = false;
					controlaOperacaoProc('AV');
										
				}));
				
				$('#btVoltarAlt','#divBotoesFormProc').css('display','inline');
				$('#btSalvarAlt','#divBotoesFormProc').css('display','inline');
			
			}else{
			
				$('#btVoltarAlt','#divBotoesFormProc').attr('src',UrlImagens + 'botoes/voltar.gif'); 
			
				$('#btVoltarAlt','#divBotoesFormProc').unbind("click").bind("click",( function() {
					controlaOperacaoProc('AT');
				}));
				
				$('#btSalvarAlt','#divBotoesFormProc').attr('src',UrlImagens + 'botoes/concluir.gif'); 
			
				$('#btSalvarAlt','#divBotoesFormProc').unbind("click").bind("click",( function() {
					controlaOperacaoProc('AV');

				}));
				
				$('#btVoltarAlt','#divBotoesFormProc').css('display','inline');
				$('#btSalvarAlt','#divBotoesFormProc').css('display','inline');
			
			}
	
	}else if( operacao_proc == 'I' || operacao_proc == 'IB' ) { 
						
			if(  ( $('#inhabmen','#'+nomeFormProc).val() == 0 && nrdeanos_proc < 18) || $('#inhabmen','#'+nomeFormProc).val() == 2) {
			
							
				$('#btVoltarInc','#divBotoesFormProc').attr('src',UrlImagens + 'botoes/voltar.gif'); 
			
				$('#btVoltarInc','#divBotoesFormProc').unbind("click").bind("click",( function() {
					controlaOperacaoProc('IT');
				}));
				
				$('#btLimparInc','#divBotoesFormProc').attr('src',UrlImagens + 'botoes/limpar.gif'); 
			
				$('#btLimparInc','#divBotoesFormProc').unbind("click").bind("click",( function() {
					estadoInicialProc();
				}));
				
				$('#btSalvarInc','#divBotoesFormProc').attr('src',UrlImagens + 'botoes/prosseguir.gif'); 
			
				$('#btSalvarInc','#divBotoesFormProc').unbind("click").bind("click",( function() {
				
					aux_sovalida = false;
					verrespo = false;
					controlaOperacaoProc('IV');
										
				}));
				
				$('#btVoltarInc','#divBotoesFormProc').css('display','inline');
				$('#btLimparInc','#divBotoesFormProc').css('display','inline');
				$('#btSalvarInc','#divBotoesFormProc').css('display','inline');
				
			}else{	
			
						
				$('#btVoltarInc','#divBotoesFormProc').attr('src',UrlImagens + 'botoes/voltar.gif'); 
			
				$('#btVoltarInc','#divBotoesFormProc').unbind("click").bind("click",( function() {
					controlaOperacaoProc('IT');
				}));
				
				$('#btLimparInc','#divBotoesFormProc').attr('src',UrlImagens + 'botoes/limpar.gif'); 
			
				$('#btLimparInc','#divBotoesFormProc').unbind("click").bind("click",( function() {
					estadoInicialProc();

				}));
				
				$('#btSalvarInc','#divBotoesFormProc').attr('src',UrlImagens + 'botoes/concluir.gif'); 
			
				$('#btSalvarInc','#divBotoesFormProc').unbind("click").bind("click",( function() {
					controlaOperacaoProc('IV');
					
				}));
					
				$('#btVoltarInc','#divBotoesFormProc').css('display','inline');
				$('#btLimparInc','#divBotoesFormProc').css('display','inline');
				$('#btSalvarInc','#divBotoesFormProc').css('display','inline');
					
			}
			
	}
	
}

// Função para voltar para o div anterior conforme parâmetros
function voltaDiv(esconder,mostrar,qtdade,titulo,rotina,novotam,novalar) {	

	if(rotina != undefined && rotina != "") {
	
		// Executa script de alteração de nome da rotina na seção através de ajax
		$.ajax({		
			type: "POST",
			url: UrlSite + "includes/procuradores/altera_secao_nmrotina.php",
			data: {
				nmrotina: rotina
			}, 
			error: function(objAjax,responseError,objExcept) {
				hideMsgAguardo();
				showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
			}
		});	
		
	}
	
	if(novotam == "undefined" || novotam == 0){
		tamanho = 345;
	}else{
		tamanho = novotam;
	}
	
	if(novalar == "undefined" || novalar == 0){
		largura = 538;
	}else{
		largura = novalar;
	}
			
	if (titulo != undefined || titulo != "") {
		$("#tdTitRotina").html(titulo);
	}
	
	if(nmrotina != 'MATRIC'){
		$("#divConteudoOpcao").css("height",tamanho);
		$("#divConteudoOpcao").css("width",largura);
	}
	
	if (mostrar == 0) {
	
		for (var i = 1; i <= qtdade;i++) {
			$("#divOpcoesDaOpcao"+i).css("display","none");
						
		}		
		
		if(nmrotina != 'MATRIC'){
			$("#divConteudoOpcao").css("display","block");
		}
		
	} else {
	
		if(nmrotina != 'MATRIC'){
			$("#divConteudoOpcao").css("display","none");
		}
		
		for (var i = 1; i <= qtdade;i++) {
			$("#divOpcoesDaOpcao"+i).css("display",(mostrar == i ? "block" : "none"));			
		}
		
	}
	
	if(operacao == 'IV'){
		verrespo =  true;
		controlaOperacao('IV');
				
	}else{
		if(operacao == 'AV'){
			verrespo =  true;
			controlaOperacao('AV');
			
		}	
	}
}

function montaTabelaProc() {

	$('div.divRegistros').remove();
	$('table.tituloRegistros','#frmRegistrosProc').remove();
	$('#frmRegistrosProc').append('<div class="divRegistros"></div>');
	$('div.divRegistros','#frmRegistrosProc').append('<table><thead><tr><th>Conta</th><th>Nome</th><th>C.P.F.</th><th>C.I.</th><th>Vig&ecirc;ncia</th><th>Cargo</th></tr></thead><tbody></tbody></table>');
		
	var colunas = new Array();	
	
	for( var i in arrayFilhosAvtMatric ) {
		
		//Mostro somentos os registros não deletados
		if ( !arrayFilhosAvtMatric[i]['deletado'] ){
			
			// Monto o conteúdo de cada coluna 
			var conta = arrayFilhosAvtMatric[i]['cddconta'];
			
			colunas[0] = '<span>'+arrayFilhosAvtMatric[i]['nrdctato']+'</span>'+ conta.replace('-','.') +'<input type="hidden" id="indarray" name="indarray" value="'+i+'" />';
			colunas[0] += '<input type="hidden" id="nrcpfcgc" name="nrcpfcgc" value="'+ arrayFilhosAvtMatric[i]['nrcpfcgc'] +'" /> ';
			colunas[0] += '<input type="hidden" id="nrdctato" name="nrdctato" value="'+ arrayFilhosAvtMatric[i]['nrdctato'] +'" />';
			colunas[0] += '<input type="hidden" id="nrdrowid" name="nrdrowid" value="'+ arrayFilhosAvtMatric[i]['nrdrowid'] +'" />';
			colunas[0] += '<input type="hidden" id="nrctremp" name="nrctremp" value="'+ arrayFilhosAvtMatric[i]['nrctremp'] +'" />';
			
			colunas[1] = ( arrayFilhosAvtMatric[i]['nmdavali'] == null ) ? '' : truncar(arrayFilhosAvtMatric[i]['nmdavali'],12);
			colunas[2] = arrayFilhosAvtMatric[i]['cdcpfcgc'];
			colunas[3] = arrayFilhosAvtMatric[i]['nrdocava'];
			
			var data = ( arrayFilhosAvtMatric[i]['dsvalida'] != 'INDETERM.' ) ? dataParaTimestamp(arrayFilhosAvtMatric[i]['dsvalida']): arrayFilhosAvtMatric[i]['dsvalida'] ;
			
			colunas[4] = '<span>'+data+'</span>'+arrayFilhosAvtMatric[i]['dsvalida'];
			colunas[5] = ( arrayFilhosAvtMatric[i]['dsproftl'] == null ) ? '' : truncar(arrayFilhosAvtMatric[i]['dsproftl'],15);
			
			// Agora monto as coluas com seus repectivos conteúdos
			$('div.divRegistros > table > tbody').append('<tr></tr>');										
			$('div.divRegistros > table > tbody > tr:last-child').append('<td>'+colunas[0]+'</td>').css({'text-transform':'uppercase'});
			$('div.divRegistros > table > tbody > tr:last-child').append('<td>'+colunas[1]+'</td>');
			$('div.divRegistros > table > tbody > tr:last-child').append('<td>'+colunas[2]+'</td>');
			$('div.divRegistros > table > tbody > tr:last-child').append('<td>'+colunas[3]+'</td>');
			$('div.divRegistros > table > tbody > tr:last-child').append('<td>'+colunas[4]+'</td>');
			$('div.divRegistros > table > tbody > tr:last-child').append('<td>'+colunas[5]+'</td>');
			
			
		}
		
	}
	
	return false;
	
}

function formataTabelaProc() {

	var divRegistro = $('div.divRegistros','#frmRegistrosProc');		
	var tabela      = $('table', divRegistro );
	
	divRegistro.css({'height':'150px','border-bottom':'1px solid #777','padding-bottom':'2px'});

	var ordemInicial = new Array();
	ordemInicial = [[1,0]];

	var arrayLargura = new Array();
	arrayLargura[0] = '70px';
	arrayLargura[1] = '125px';
	arrayLargura[2] = '113px';
	arrayLargura[3] = '75px';
	arrayLargura[4] = '60px';

	var arrayAlinha = new Array();
	arrayAlinha[0] = 'right';
	arrayAlinha[1] = 'left';
	arrayAlinha[2] = 'right';
	arrayAlinha[3] = 'right';
	arrayAlinha[4] = 'center';
	arrayAlinha[5] = 'left';

	tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha, 'controlaOperacaoProc(\'TC\')' );
	
	return false;
}

function sincronizaArrayProc(){
	
	arrayBackupBens.length = 0;
	
	for ( i in arrayBensMatric ){
	
		eval('var arrayAux'+i+' = new Object();');
		
		for ( campo in arrayBensMatric[0] ){
		
			eval('arrayAux'+i+'[\''+campo+'\']= arrayBensMatric['+i+'][\''+campo+'\'];');
			
		}
				
		eval('arrayBens['+i+'] = arrayAux'+i+';');
		
	}
	
	return false;
}


function carregaDadosProc() { 

	$('input[name="cdestcvl"]','#frmDadosProcuradores').val( arrayFilhosAvtMatric[indarray_proc]['cdestcvl'] );
	$('select[name="cdestcvl"]','#frmDadosProcuradores').val( arrayFilhosAvtMatric[indarray_proc]['cdestcvl'] );
	$('#nrdconta','#frmDadosProcuradores').val( arrayFilhosAvtMatric[indarray_proc]['nrdconta'] );
	$('#nrdctato','#frmDadosProcuradores').val( arrayFilhosAvtMatric[indarray_proc]['nrdctato'] );
	$('#nrcpfcgc','#frmDadosProcuradores').val( arrayFilhosAvtMatric[indarray_proc]['nrcpfcgc'] );
	$('#nmdavali','#frmDadosProcuradores').val( arrayFilhosAvtMatric[indarray_proc]['nmdavali'] );
	$('#dtnascto','#frmDadosProcuradores').val( arrayFilhosAvtMatric[indarray_proc]['dtnascto'] );
	$('select[name="inhabmen"]','#frmDadosProcuradores').val( arrayFilhosAvtMatric[indarray_proc]['inhabmen'] );
    $('#dthabmen','#frmDadosProcuradores').val( arrayFilhosAvtMatric[indarray_proc]['dthabmen'] );		
	$('select[name="tpdocava"]','#frmDadosProcuradores').val( arrayFilhosAvtMatric[indarray_proc]['tpdocava'] );
    $('#nrdocava','#frmDadosProcuradores').val( arrayFilhosAvtMatric[indarray_proc]['nrdocava'] );		
    $('#cdoeddoc','#frmDadosProcuradores').val( arrayFilhosAvtMatric[indarray_proc]['cdoeddoc'] );		
    $('#cdufddoc','#frmDadosProcuradores').val( arrayFilhosAvtMatric[indarray_proc]['cdufddoc'] );		
    $('#dtemddoc','#frmDadosProcuradores').val( arrayFilhosAvtMatric[indarray_proc]['dtemddoc'] );		
    $('#cdsexcto','#frmDadosProcuradores').val( arrayFilhosAvtMatric[indarray_proc]['cdsexcto'] );
	
	if(arrayFilhosAvtMatric[indarray_proc]['cdsexcto'] == 1){
		 $("#sexoMas","#frmDadosProcuradores").prop('checked',true);
	}else{
		if(arrayFilhosAvtMatric[indarray_proc]['cdsexcto'] == 2){
			$("#sexoFem","#frmDadosProcuradores").prop('checked',true);
		}
	
	} 
				
	$('#dsnacion','#frmDadosProcuradores').val( arrayFilhosAvtMatric[indarray_proc]['dsnacion'] );	
    $('#cdnacion','#frmDadosProcuradores').val( arrayFilhosAvtMatric[indarray_proc]['cdnacion'] );	
	$('#dsnatura','#frmDadosProcuradores').val( arrayFilhosAvtMatric[indarray_proc]['dsnatura'] );	
	$('#nrcepend','#frmDadosProcuradores').val( arrayFilhosAvtMatric[indarray_proc]['nrcepend'] );	
	$('#dsendres','#frmDadosProcuradores').val( arrayFilhosAvtMatric[indarray_proc]['dsendres.1'] );	
	$('#nrendere','#frmDadosProcuradores').val( arrayFilhosAvtMatric[indarray_proc]['nrendere'] );	
	$('#complend','#frmDadosProcuradores').val( arrayFilhosAvtMatric[indarray_proc]['complend'] );	
	$('#nrcxapst','#frmDadosProcuradores').val( arrayFilhosAvtMatric[indarray_proc]['nrcxapst'] );	
	$('#nmbairro','#frmDadosProcuradores').val( arrayFilhosAvtMatric[indarray_proc]['nmbairro'] );	
	$('#cdufresd','#frmDadosProcuradores').val( arrayFilhosAvtMatric[indarray_proc]['cdufresd'] );	
	$('#nmcidade','#frmDadosProcuradores').val( arrayFilhosAvtMatric[indarray_proc]['nmcidade'] );	
	$('#nmmaecto','#frmDadosProcuradores').val( arrayFilhosAvtMatric[indarray_proc]['nmmaecto'] );	
	$('#nmpaicto','#frmDadosProcuradores').val( arrayFilhosAvtMatric[indarray_proc]['nmpaicto'] );	
	$('#vledvmto','#frmDadosProcuradores').val( arrayFilhosAvtMatric[indarray_proc]['vledvmto'] );	
	$('#dsrelbem','#frmDadosProcuradores').val( arrayFilhosAvtMatric[indarray_proc]['dsrelbem.1'] );	
	$('#dtvalida','#frmDadosProcuradores').val( arrayFilhosAvtMatric[indarray_proc]['dtvalida'] );	
	$('input[name="dsproftl"]','#frmDadosProcuradores').val( arrayFilhosAvtMatric[indarray_proc]['dsproftl'] );
	$('select[name="dsproftl"]','#frmDadosProcuradores').val( arrayFilhosAvtMatric[indarray_proc]['dsproftl'] );
	$('#dtadmsoc','#frmDadosProcuradores').val( arrayFilhosAvtMatric[indarray_proc]['dtadmsoc'] );	
	$('#persocio','#frmDadosProcuradores').val( arrayFilhosAvtMatric[indarray_proc]['persocio'] );	
	$('select[name="flgdepec"]','#frmDadosProcuradores').val( arrayFilhosAvtMatric[indarray_proc]['flgdepec'] );
    $('#vloutren','#frmDadosProcuradores').val( arrayFilhosAvtMatric[indarray_proc]['vloutren'] );	
    $('#dsoutren','#frmDadosProcuradores').val( arrayFilhosAvtMatric[indarray_proc]['dsoutren'] );	
			
		
}


function controlaArrayProc(op){
	
	hideMsgAguardo();
	showMsgAguardo( 'Aguarde, processando ...' );

	switch (op) {	
		
		case 'VA': 
				
				cpfcgc = normalizaNumero( $('#nrcpfcgc','#frmDadosProcuradores').val()  ) ;
				cddctato = ( $('#nrdctato','#frmDadosProcuradores').val() == '' ) ? 0 : $('#nrdctato','#frmDadosProcuradores').val();	
								
				arrayFilhosAvtMatric[indarray_proc]["nrcpfcgc"] = cpfcgc;
				arrayFilhosAvtMatric[indarray_proc]["nrdctato"] = normalizaNumero(cddctato);
				
				arrayFilhosAvtMatric[indarray_proc]["nmdavali"] = $('#nmdavali','#frmDadosProcuradores').val();
				arrayFilhosAvtMatric[indarray_proc]["dtnascto"] = $('#dtnascto','#frmDadosProcuradores').val();
				arrayFilhosAvtMatric[indarray_proc]["inhabmen"] = $('#inhabmen','#frmDadosProcuradores').val();
				arrayFilhosAvtMatric[indarray_proc]["dthabmen"] = $('#dthabmen','#frmDadosProcuradores').val();
				arrayFilhosAvtMatric[indarray_proc]["tpdocava"] = $('#tpdocava','#frmDadosProcuradores').val();
				arrayFilhosAvtMatric[indarray_proc]["nrdocava"] = $('#nrdocava','#frmDadosProcuradores').val();
				arrayFilhosAvtMatric[indarray_proc]["cdoeddoc"] = $('#cdoeddoc','#frmDadosProcuradores').val();
				arrayFilhosAvtMatric[indarray_proc]["cdufddoc"] = $('#cdufddoc','#frmDadosProcuradores').val();
				arrayFilhosAvtMatric[indarray_proc]["dtemddoc"] = $('#dtemddoc','#frmDadosProcuradores').val();
				
				arrayFilhosAvtMatric[indarray_proc]['cdestcvl'] = $('select[name="cdestcvl"]','#frmDadosProcuradores').val();
							
				if ($("#sexoMas","#frmDadosProcuradores").prop('checked')) {
					arrayFilhosAvtMatric[indarray_proc]['cdsexcto'] = 1;
				}else 
					if ($("#sexoFem","#frmDadosProcuradores").prop('checked')) {
						arrayFilhosAvtMatric[indarray_proc]['cdsexcto'] = 2;
					}
								
				arrayFilhosAvtMatric[indarray_proc]["dsnacion"] = $('#dsnacion','#frmDadosProcuradores').val();
                arrayFilhosAvtMatric[indarray_proc]["cdnacion"] = $('#cdnacion','#frmDadosProcuradores').val();
				arrayFilhosAvtMatric[indarray_proc]["dsnatura"] = $('#dsnatura','#frmDadosProcuradores').val();
				
				arrayFilhosAvtMatric[indarray_proc]['nrcepend'] = normalizaNumero($('#nrcepend','#frmDadosProcuradores').val());
				
				arrayFilhosAvtMatric[indarray_proc]["dsendres.1"] = $('#dsendres','#frmDadosProcuradores').val();
				arrayFilhosAvtMatric[indarray_proc]["nrendere"] = $('#nrendere','#frmDadosProcuradores').val();
				arrayFilhosAvtMatric[indarray_proc]["complend"] = $('#complend','#frmDadosProcuradores').val();
				arrayFilhosAvtMatric[indarray_proc]["nrcxapst"] = $('#nrcxapst','#frmDadosProcuradores').val();
				arrayFilhosAvtMatric[indarray_proc]["nmbairro"] = $('#nmbairro','#frmDadosProcuradores').val();
				arrayFilhosAvtMatric[indarray_proc]["cdufresd"] = $('#cdufresd','#frmDadosProcuradores').val();
				arrayFilhosAvtMatric[indarray_proc]["nmcidade"] = $('#nmcidade','#frmDadosProcuradores').val();
				arrayFilhosAvtMatric[indarray_proc]["nmmaecto"] = $('#nmmaecto','#frmDadosProcuradores').val();
				arrayFilhosAvtMatric[indarray_proc]["nmpaicto"] = $('#nmpaicto','#frmDadosProcuradores').val();
				arrayFilhosAvtMatric[indarray_proc]["vledvmto"] = $('#vledvmto','#frmDadosProcuradores').val();
				arrayFilhosAvtMatric[indarray_proc]["dsrelbem"] = $('#dsrelbem','#frmDadosProcuradores').val();
				arrayFilhosAvtMatric[indarray_proc]["dtvalida"] = $('#dtvalida','#frmDadosProcuradores').val();
				
				if( $('#dtvalida','#frmDadosProcuradores').val() == "12/31/9999"){
					arrayFilhosAvtMatric[indarray_proc]["dsvalida"] = "INDETERMI.";
			    }else{
				    arrayFilhosAvtMatric[indarray_proc]["dsvalida"] = $('#dtvalida','#frmDadosProcuradores').val();
				}	
				
				arrayFilhosAvtMatric[indarray_proc]["dsproftl"] = $('#dsproftl','#frmDadosProcuradores').val();
				arrayFilhosAvtMatric[indarray_proc]["dtadmsoc"] = $('#dtadmsoc','#frmDadosProcuradores').val();
				arrayFilhosAvtMatric[indarray_proc]["persocio"] = $('#persocio','#frmDadosProcuradores').val();
				arrayFilhosAvtMatric[indarray_proc]["flgdepec"] = $('#flgdepec','#frmDadosProcuradores').val();
				arrayFilhosAvtMatric[indarray_proc]["vloutren"] = $('#vloutren','#frmDadosProcuradores').val();
				arrayFilhosAvtMatric[indarray_proc]["dsoutren"] = $('#dsoutren','#frmDadosProcuradores').val();
				arrayFilhosAvtMatric[indarray_proc]["deletado"] = false;
				arrayFilhosAvtMatric[indarray_proc]["cddopcao"] = 'A';
								
				hideMsgAguardo();
				bloqueiaFundo(divRotina);
				controlaOperacaoProc('CT');
								
				return false; 	
				break;
		
		case 'VI': 

				i = arrayFilhosAvtMatric.length;
				
				conta = normalizaNumero( nrdconta );
				cpfcgc = normalizaNumero( $('#nrcpfcgc','#frmDadosProcuradores').val()  ) ;
				cddctato = ( $('#nrdctato','#frmDadosProcuradores').val() == '' ) ? 0 : $('#nrdctato','#frmDadosProcuradores').val();	
				cep = normalizaNumero( $('#nrcepend','#frmDadosProcuradores').val()  ) ;
				
				eval('var regFilhoavt'+i+' = new Object();');
				
				eval('regFilhoavt'+i+'["nrdconta"] = \''+conta+'\';');
				eval('regFilhoavt'+i+'["nrcpfcgc"] = \''+cpfcgc+'\';');
				eval('regFilhoavt'+i+'["cdcpfcgc"] = $(\'#nrcpfcgc\',\'#frmDadosProcuradores\').val();');
				eval('regFilhoavt'+i+'["nrdctato"] = \''+normalizaNumero(cddctato)+'\';');
				eval('regFilhoavt'+i+'["cddconta"] = \''+cddctato+'\';');
				
				eval('regFilhoavt'+i+'["nmdavali"] = $(\'#nmdavali\',\'#frmDadosProcuradores\').val();');
				eval('regFilhoavt'+i+'["dtnascto"] = $(\'#dtnascto\',\'#frmDadosProcuradores\').val();');
				eval('regFilhoavt'+i+'["inhabmen"] = $(\'#inhabmen\',\'#frmDadosProcuradores\').val();');
				eval('regFilhoavt'+i+'["dthabmen"] = $(\'#dthabmen\',\'#frmDadosProcuradores\').val();');
				eval('regFilhoavt'+i+'["tpdocava"] = $(\'#tpdocava\',\'#frmDadosProcuradores\').val();');
				eval('regFilhoavt'+i+'["nrdocava"] = $(\'#nrdocava\',\'#frmDadosProcuradores\').val();');
				eval('regFilhoavt'+i+'["cdoeddoc"] = $(\'#cdoeddoc\',\'#frmDadosProcuradores\').val();');
				eval('regFilhoavt'+i+'["cdufddoc"] = $(\'#cdufddoc\',\'#frmDadosProcuradores\').val();');
				eval('regFilhoavt'+i+'["dtemddoc"] = $(\'#dtemddoc\',\'#frmDadosProcuradores\').val();');
				eval('regFilhoavt'+i+'["cdestcvl"] = $(\'#cdestcvl\',\'#frmDadosProcuradores\').val();');
				eval('regFilhoavt'+i+'["nrctremp"] = 0;');
				eval('regFilhoavt'+i+'["idseqttl"] = \''+nrctremp+'\';');
								
				if ($("#sexoMas","#frmDadosProcuradores").prop('checked')) {
					eval('regFilhoavt'+i+'["cdsexcto"] = 1');
					
				}else if ($("#sexoFem","#frmDadosProcuradores").prop('checked')) {
						   eval('regFilhoavt'+i+'["cdsexcto"] = 2');
								
				}
								
				eval('regFilhoavt'+i+'["dsnacion"] = $(\'#dsnacion\',\'#frmDadosProcuradores\').val();');
                eval('regFilhoavt'+i+'["cdnacion"] = $(\'#cdnacion\',\'#frmDadosProcuradores\').val();');
				eval('regFilhoavt'+i+'["dsnatura"] = $(\'#dsnatura\',\'#frmDadosProcuradores\').val();');
				eval('regFilhoavt'+i+'["nrcepend"] = \''+cep+'\';');
				eval('regFilhoavt'+i+'["dsendres.1"] = $(\'#dsendres\',\'#frmDadosProcuradores\').val();');
				eval('regFilhoavt'+i+'["nrendere"] = $(\'#nrendere\',\'#frmDadosProcuradores\').val();');
				eval('regFilhoavt'+i+'["complend"] = $(\'#complend\',\'#frmDadosProcuradores\').val();');
				eval('regFilhoavt'+i+'["nrcxapst"] = $(\'#nrcxapst\',\'#frmDadosProcuradores\').val();');
				eval('regFilhoavt'+i+'["nmbairro"] = $(\'#nmbairro\',\'#frmDadosProcuradores\').val();');
				eval('regFilhoavt'+i+'["cdufresd"] = $(\'#cdufresd\',\'#frmDadosProcuradores\').val();');
				eval('regFilhoavt'+i+'["nmcidade"] = $(\'#nmcidade\',\'#frmDadosProcuradores\').val();');
				
				eval('regFilhoavt'+i+'["nmmaecto"] = $(\'#nmmaecto\',\'#frmDadosProcuradores\').val();');
				eval('regFilhoavt'+i+'["nmpaicto"] = $(\'#nmpaicto\',\'#frmDadosProcuradores\').val();');
				eval('regFilhoavt'+i+'["vledvmto"] = $(\'#vledvmto\',\'#frmDadosProcuradores\').val();');
				eval('regFilhoavt'+i+'["dsrelbem"] = $(\'#dsrelbem\',\'#frmDadosProcuradores\').val();');
				eval('regFilhoavt'+i+'["dtvalida"] = $(\'#dtvalida\',\'#frmDadosProcuradores\').val();');
				
				if($('#dtvalida','#frmDadosProcuradores').val() == "12/31/9999"){
				    eval('regFilhoavt'+i+'["dsvalida"] = \'INDETERMI.\';');
				}else{
					eval('regFilhoavt'+i+'["dsvalida"] = $(\'#dtvalida\',\'#frmDadosProcuradores\').val();');
				}
				
				eval('regFilhoavt'+i+'["dsproftl"] = $(\'#dsproftl\',\'#frmDadosProcuradores\').val();');
				eval('regFilhoavt'+i+'["dtadmsoc"] = $(\'#dtadmsoc\',\'#frmDadosProcuradores\').val();');
				eval('regFilhoavt'+i+'["persocio"] = $(\'#persocio\',\'#frmDadosProcuradores\').val();');
				eval('regFilhoavt'+i+'["flgdepec"] = $(\'#flgdepec\',\'#frmDadosProcuradores\').val();');
				eval('regFilhoavt'+i+'["vloutren"] = $(\'#vloutren\',\'#frmDadosProcuradores\').val();');
				eval('regFilhoavt'+i+'["dsoutren"] = $(\'#dsoutren\',\'#frmDadosProcuradores\').val();');
				eval('regFilhoavt'+i+'["deletado"] = false;');
				eval('regFilhoavt'+i+'["cddopcao"] = \'I\';');
					
				eval('arrayFilhosAvtMatric['+i+'] = regFilhoavt'+i+';');
				
			
				hideMsgAguardo();
				bloqueiaFundo(divRotina);
				controlaOperacaoProc('CT'); 
								
				return false;	
				break;
		
		case 'EV': 
				arrayFilhosAvtMatric[indarray_proc]['cddopcao'] = 'E' ;
				arrayFilhosAvtMatric[indarray_proc]['deletado'] = true ;
				
				hideMsgAguardo();
				bloqueiaFundo(divRotina);
				controlaOperacaoProc('CT');
				
				return false;
				break;                                                                                             
		                                                                                                       
		default: 
		
		hideMsgAguardo();
		return false; 
		break;                                                                          
	}
	
	return false;
	
}

function retornaIndiceSelecionadoProc() {	
	
	indice = '';
	
	$('table > tbody > tr','div.divRegistros').each( function() {
		
		if ( $(this).hasClass('corSelecao') ) {	
			indice = $('#indarray', $(this) ).val();	
						
		}
	});	
	
	return indice;
}

function controlaLayoutPoder() {
    
	altura  = '350px';
	largura = '570px';
	divRotina.css('width',largura);	
		
	$('.divRegistros').css('height',altura);
		
	var divRegistro = $('div.divRegistros');		
	var tabela      = $('table', divRegistro );
	var linha       = $('table > tbody > tr', divRegistro );
	
	divRegistro.css('height', '345px');
		
	var ordemInicial = new Array();
	ordemInicial = [[0,0]];
	
	var arrayLargura = new Array();
	arrayLargura[0] = '178px';
	arrayLargura[1] = '190px';
	
	var arrayAlinha = new Array();
	arrayAlinha[0] = 'right';
	arrayAlinha[1] = 'center';
	arrayAlinha[2] = 'center';
	
	tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha, '' );
}

function salvarPoderes(){
	
	var strPoderes = "";
	var dsoutpod = "";
	var flgisola = "no";
	var flgconju = "no";
	
	showMsgAguardo('Aguarde, salvando...');	
	
	
	/*Como a tela foi construida sem validar os dados de entrada, removo os caracteres que invalidam o xml,
	  como também os caracteres "#" e "," que fazem com que a tela não funcione pois a mesma foi montada
	  utilizando os caracteres como separadores de parametros. SD 558355*/	
	dsoutpod += removeCaracteresInvalidos($('#dsoutpod1').val()).replace(/#/g, "")
	dsoutpod += '#' + removeCaracteresInvalidos($('#dsoutpod2').val()).replace(/#/g, "")
	dsoutpod += '#' + removeCaracteresInvalidos($('#dsoutpod3').val()).replace(/#/g, "")
	dsoutpod += '#' + removeCaracteresInvalidos($('#dsoutpod4').val()).replace(/#/g, "")
	dsoutpod += '#' + removeCaracteresInvalidos($('#dsoutpod5').val()).replace(/#/g, "")
	
	
	//Remove as virgulas pois estava ocasionando problemas ao salvar o texto. SD 558355
	dsoutpod = dsoutpod.replace(/,/g, "");
	
	$('table > tbody > tr', 'div.divRegistros').each( function() {
	
		valRadio = $('input:checked', $(this) ).val();
				
		if(dsoutpod == undefined || dsoutpod == ""){
			dsoutpod = ""
		}
		
		if($('input[name="hdnCodPoder"]', $(this) ).val() != 10){
		    if(valRadio == 'iso'){
			    flgconju = "no";
			    flgisola = "yes"
		    } else if (valRadio == 'con') {
		        flgconju = "yes";
		        flgisola = "no"
		    } else {
		        flgconju = "no";
		        flgisola = "no"
		    }
		}else{
			if(valRadio == 'con'){
				flgconju = "yes";
				flgisola = "no";
			}else{
				flgconju = "no";
				flgisola = "no";
			}
		}
		
		if(strPoderes != ""){
			strPoderes += "/"
		}
		
		strPoderes += $('input[name="hdnCodPoder"]', $(this) ).val() + ",";
		strPoderes += flgconju + ",",
		strPoderes += flgisola + ",",
		strPoderes += dsoutpod;
	});
	
	$.ajax({		
		type: 'POST',
		dataType: 'html',
		url: UrlSite + 'includes/procuradores/salva_poderes.php', 		
		data: {			
			strPoderes: strPoderes,nrdconta: nrdconta,
			nrcpfcgc: nrcpfcgc_proc,nrdctato: nrdctato,
			redirect: 'script_ajax'
		}, 
		error:function(objAjax, responseError,objExcept){
			hideMsgAguardo();
		},
		success: function(response) {
							
			if (response != "" &&
				response != 'hideMsgAguardo();showError("error","yes","Alerta - Ayllos","","NaN");' &&
				response != 'hideMsgAguardo();showError("error","no","Alerta - Ayllos","","NaN");'){
				eval(response);
			}else{
				controlaOperacaoProc('CT');
			}
		}	
	});
	
	
}

function controlaOperacaoPoderes(operacao) {
    switch (operacao) {
		
		case 'SP':
			// Oculto o formulario e mostro a tabela
		    //showConfirmacao('Deseja confirmar altera&ccedil;&atilde;o?','Confirma&ccedil;&atilde;o - Ayllos','salvarPoderes()','bloqueiaFundo(divRotina)','sim.gif','nao.gif');
		    validaResponsaveis();
			return false;
			break;
	}
}

function validaResponsaveis() {

    var valRadio;
    var flgconju;
    
    $('table > tbody > tr', 'div.divRegistros').each(function () {

        valRadio = $('input:checked', $(this)).val();
        
        if ($('input[name="hdnCodPoder"]', $(this)).val() == 10) {
          if (valRadio == 'con') {
            flgconju = "yes";            
          } else {
            flgconju = "no";
          }
        }
        
    });

    $.ajax({
        type: 'POST',
        dataType: 'html',
        url: UrlSite + 'includes/procuradores/valida_responsaveis.php',
        data: {
            nrdconta: nrdconta,
            nrcpfcgc: nrcpfcgc_proc,
            nrdctato: nrdctato,
            flgconju: flgconju,
            redirect: 'script_ajax'
        },
        success: function (response) {
            eval(response);
        }
    });
}

function voltarRotina() {
	fechaRotina(divRotina);
	acessaRotina('PARTICIPACAO','Participação Empresas','participacao');
}

function proximaRotina () {
	hideMsgAguardo();
	encerraRotina(false);
	acessaRotina('BENS','Bens','bens');				
}

function selecionaPoder(check){
    
    if (check == 'radPoderC10') {
        if (flgassco) {
            $('#radPoderC10').removeProp('checked');
            flgassco = false;
        } else {
            $('#radPoderC10').prop('checked', 'checked');
            flgassco = true;
        }
    } else if (check == 'radPoderC1' || check == 'radPoderI1') {
        
        if (check == 'radPoderC1' && flgpoderC1) {
            $('#' + check).removeProp('checked');
            flgpoderC1 = false;
        } else if (check == 'radPoderI1' && flgpoderI1) {
            $('#' + check).removeProp('checked');
            flgpoderI1 = false;
        } else if (check == 'radPoderC1' && !(flgpoderC1)) {
            $('#radPoderI1').removeProp('checked');
            $('#' + check).prop('checked', 'checked');
            flgpoderC1 = true;
            flgpoderI1 = false;
        } else if (check == 'radPoderI1' && !(flgpoderI1)) {
            $('#radPoderC1').removeProp('checked');
            $('#' + check).prop('checked', 'checked');
            flgpoderI1 = true;
            flgpoderC1 = false;
        }
    } else if (check == 'radPoderC2' || check == 'radPoderI2') {
        if (check == 'radPoderC2' && flgpoderC2) {
            $('#' + check).removeProp('checked');
            flgpoderC2 = false;
        } else if (check == 'radPoderI2' && flgpoderI2) {
            $('#' + check).removeProp('checked');
            flgpoderI2 = false;
        } else if (check == 'radPoderC2' && !(flgpoderC2)) {
            $('#radPoderI2').removeProp('checked');
            $('#' + check).prop('checked', 'checked');
            flgpoderC2 = true;
            flgpoderI2 = false;
        } else if (check == 'radPoderI2' && !(flgpoderI2)) {
            $('#radPoderC2').removeProp('checked');
            $('#' + check).prop('checked', 'checked');
            flgpoderI2 = true;
            flgpoderC2 = false;
        }
    } else if (check == 'radPoderC3' || check == 'radPoderI3') {
        if (check == 'radPoderC3' && flgpoderC3) {
            $('#' + check).removeProp('checked');
            flgpoderC3 = false;
        } else if (check == 'radPoderI3' && flgpoderI3) {
            $('#' + check).removeProp('checked');
            flgpoderI3 = false;
        } else if (check == 'radPoderC3' && !(flgpoderC3)) {
            $('#radPoderI3').removeProp('checked');
            $('#' + check).prop('checked', 'checked');
            flgpoderC3 = true;
            flgpoderI3 = false;
        } else if (check == 'radPoderI3' && !(flgpoderI3)) {
            $('#radPoderC3').removeProp('checked');
            $('#' + check).prop('checked', 'checked');
            flgpoderI3 = true;
            flgpoderC3 = false;
        }
    } else if (check == 'radPoderC4' || check == 'radPoderI4') {
        if (check == 'radPoderC4' && flgpoderC4) {
            $('#' + check).removeProp('checked');
            flgpoderC4 = false;
        } else if (check == 'radPoderI4' && flgpoderI4) {
            $('#' + check).removeProp('checked');
            flgpoderI4 = false;
        } else if (check == 'radPoderC4' && !(flgpoderC4)) {
            $('#radPoderI4').removeProp('checked');
            $('#' + check).prop('checked', 'checked');
            flgpoderC4 = true;
            flgpoderI4 = false;
        } else if (check == 'radPoderI4' && !(flgpoderI4)) {
            $('#radPoderC4').removeProp('checked');
            $('#' + check).prop('checked', 'checked');
            flgpoderI4 = true;
            flgpoderC4 = false;
        }
    } else if (check == 'radPoderC5' || check == 'radPoderI5') {
        if (check == 'radPoderC5' && flgpoderC5) {
            $('#' + check).removeProp('checked');
            flgpoderC5 = false;
        } else if (check == 'radPoderI5' && flgpoderI5) {
            $('#' + check).removeProp('checked');
            flgpoderI5 = false;
        } else if (check == 'radPoderC5' && !(flgpoderC5)) {
            $('#radPoderI5').removeProp('checked');
            $('#' + check).prop('checked', 'checked');
            flgpoderC5 = true;
            flgpoderI5 = false;
        } else if (check == 'radPoderI5' && !(flgpoderI5)) {
            $('#radPoderC5').removeProp('checked');
            $('#' + check).prop('checked', 'checked');
            flgpoderI5 = true;
            flgpoderC5 = false;
        }
    } else if (check == 'radPoderC6' || check == 'radPoderI6') {
        if (check == 'radPoderC6' && flgpoderC6) {
            $('#' + check).removeProp('checked');
            flgpoderC6 = false;
        } else if (check == 'radPoderI6' && flgpoderI6) {
            $('#' + check).removeProp('checked');
            flgpoderI6 = false;
        } else if (check == 'radPoderC6' && !(flgpoderC6)) {
            $('#radPoderI6').removeProp('checked');
            $('#' + check).prop('checked', 'checked');
            flgpoderC6 = true;
            flgpoderI6 = false;
        } else if (check == 'radPoderI6' && !(flgpoderI6)) {
            $('#radPoderC6').removeProp('checked');
            $('#' + check).prop('checked', 'checked');
            flgpoderI6 = true;
            flgpoderC6 = false;
        }
    } else if (check == 'radPoderC7' || check == 'radPoderI7') {
        if (check == 'radPoderC7' && flgpoderC7) {
            $('#' + check).removeProp('checked');
            flgpoderC7 = false;
        } else if (check == 'radPoderI7' && flgpoderI7) {
            $('#' + check).removeProp('checked');
            flgpoderI7 = false;
        } else if (check == 'radPoderC7' && !(flgpoderC7)) {
            $('#radPoderI7').removeProp('checked');
            $('#' + check).prop('checked', 'checked');
            flgpoderC7 = true;
            flgpoderI7 = false;
        } else if (check == 'radPoderI7' && !(flgpoderI7)) {
            $('#radPoderC7').removeProp('checked');
            $('#' + check).prop('checked', 'checked');
            flgpoderI7 = true;
            flgpoderC7 = false;
        }
    } else if (check == 'radPoderC8' || check == 'radPoderI8') {
        if (check == 'radPoderC8' && flgpoderC8) {
            $('#' + check).removeProp('checked');
            flgpoderC8 = false;
        } else if (check == 'radPoderI8' && flgpoderI8) {
            $('#' + check).removeProp('checked');
            flgpoderI8 = false;
        } else if (check == 'radPoderC8' && !(flgpoderC8)) {
            $('#radPoderI8').removeProp('checked');
            $('#' + check).prop('checked', 'checked');
            flgpoderC8 = true;
            flgpoderI8 = false;
        } else if (check == 'radPoderI8' && !(flgpoderI8)) {
            $('#radPoderC8').removeProp('checked');
            $('#' + check).prop('checked', 'checked');
            flgpoderI8 = true;
            flgpoderC8 = false;
        }
    } else if (check == 'radPoderC9' || check == 'radPoderI9') {
        if (check == 'radPoderC9' && flgpoderC9) {
            $('#' + check).removeProp('checked');
            flgpoderC9 = false;
        } else if (check == 'radPoderI9' && flgpoderI9) {
            $('#' + check).removeProp('checked');
            flgpoderI9 = false;
        } else if (check == 'radPoderC9' && !(flgpoderC9)) {
            $('#radPoderI9').removeProp('checked');
            $('#' + check).prop('checked', 'checked');
            flgpoderC9 = true;
            flgpoderI9 = false;
        } else if (check == 'radPoderI8' && !(flgpoderI8)) {
            $('#radPoderC9').removeProp('checked');
            $('#' + check).prop('checked', 'checked');
            flgpoderI9 = true;
            flgpoderC9 = false;
        }
    }

}