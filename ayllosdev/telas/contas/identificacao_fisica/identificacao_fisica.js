/*!
 * FONTE        : identificacao_fisica.js
 * CRIAÇÃO      : Rodolpho Telmo (DB1)
 * DATA CRIAÇÃO : Fevereiro/2010 
 * OBJETIVO     : Biblioteca de funções na rotina IDENTIFICAÇÃO FÍSICA da tela de CONTAS
 * --------------
 * ALTERAÇÕES   :
 * --------------
 * 001: [10/02/2010] Rodolpho Telmo (DB1): Criada a função buscaCPF
 * 002: [10/02/2010] Rodolpho Telmo (DB1): Criada função controlaFormulario
 * 003: [10/02/2010] Rodolpho Telmo (DB1): Criação da função incluiMascaras()
 * 004: [24/03/2010] Rodolpho Telmo (DB1): Alterada funções para as do novo padrão
 * 005: [29/03/2010] Rodolpho Telmo (DB1): Criado novo parâmetro "nrctattl" para controlarmos campos habilitados/desabilitados
 * 006: [30/03/2010] Rodolpho Telmo (DB1): Criada função controlaFoco()
 * 007: [26/04/2010] Rodolpho Telmo (DB1): Retirada função "revisaoCadastral", agora se encontra no arquivo funcoes.js
 * 008: [11/02/2011] Gabriel Ramirez     : Aumentar nome do cooperado para 50 posicoes. 
 * 009: [06/02/2012] Tiago Machado       : unbind do click que adiciona a função mostra pesquisa
 * 010: [04/05/2012] Adriano			 : Ajustes referente ao projeto GP - Socios Menores.
 * 011: [23/08/2013] David               : Incluir campo UF Naturalidade - cdufnatu 
 * 012: [01/09/2015] Gabriel (RKAM)      : Reformulacao cadastral.
 * 013: [30/05/2016] Kelvin 			 : Incluso a rotina para tratar caracteres invalidos do campo nmextemp. SD (442417)
 * 014: [20/04/2017] Adriano             : Ajuste para retirar o uso de campos removidos da tabela crapass, crapttl, crapjur e 
    							           ajuste devido ao aumento do formato para os campos crapass.nrdocptl, crapttl.nrdocttl, 
			                               crapcje.nrdoccje, crapcrl.nridenti e crapavt.nrdocava
 * 015: [25/04/2017] Odirlei(AMcom)	     : Alterado campo dsnacion para cdnacion. (Projeto 339)
 * 016: [31/07/2017](Odirlei-AMcom)      : Aumentado campo dsnatura de 25 para 50, PRJ339-CRM .	 
 * 017: [12/08/2015] Lombardi            : Criada a função dossieDigidoc.
 * 018: [25/09/2017] Kelvin			     : Adicionado uma lista de valores para carregar orgao emissor. (PRJ339)			                         
 */
 
  
var operacao = ''; // Armazena a operação corrente da tela
var aux_operacao = ''; // Armazena a operação da tela
var nrcpfcgc = ''; // Nr. CPF
var cdgraupr = ''; // Código do Grau de Parentesco
var nomeForm = 'frmDadosIdentFisica';
var nrdeanos = 0 ; 
var UrlImagens;
var msgAlert = "";
var dtmvtolt = "";
var flgContinuar = false;

var nrcpfcgc_aux = ''; 
var cdgraupr_aux = ''; 

exibeAlerta = false;

function acessaOpcaoAba(nrOpcoes,id,opcao) {  

	showMsgAguardo('Aguarde, abrindo rotina ...');
	
	$("#divOpcoesDaOpcao1").css('display','none');
	
	for (var i = 0; i < nrOpcoes; i++) {
		if (id == i) { 
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
	
		
	$.ajax({		
		type: 'POST', 
		dataType: 'html',
		url: UrlSite + 'telas/contas/identificacao_fisica/principal.php',
		data: {
			nrdconta: nrdconta,
			idseqttl: idseqttl,
			operacao: operacao,
			nrcpfcgc: nrcpfcgc, 
			cdgraupr: cdgraupr,
			flgcadas: flgcadas,
			redirect: 'html_ajax'
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


// Função para acessar rotinas da tela CONTAS
function abrirRotina(nomeValidar,nomeTitulo,nomeScript,nomeURL,ope) {

	operacao = ope;
	dtdenasc = $('#dtnasttl','#'+nomeForm).val();
	cdhabmen = $('#inhabmen','#'+nomeForm).val();
			
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
				nmdatela: "CONTAS",
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
					idseqttl = $('#idseqttl','#frmCabContas').val();
					fechaRotina(divRotina);
					return false;
				});	
			}				 
		}); 
	});
}


function controlaOperacao( novaOp ) {

	if( !verificaSemaforo() ) { return false; }
	
	operacao = ( typeof novaOp != 'undefined' ) ? novaOp : operacao;
		
	// Verifica permissões de acesso
	if ( (operacao == 'CA' || operacao == 'BA') && (flgAlterar != '1') ) { showError('error','Seu usu&aacute;rio n&atilde;o possui permiss&atilde;o de altera&ccedil;&atilde;o.','Alerta - Ayllos','semaforo--;bloqueiaFundo(divRotina)'); return false; } 
	if ( (operacao == 'CI' || operacao == 'BI') && (flgIncluir != '1') ) { showError('error','Seu usu&aacute;rio n&atilde;o possui permiss&atilde;o de inclus&atilde;o.','Alerta - Ayllos','semaforo--;bloqueiaFundo(divRotina)'); return false; }	
	
		
	var mensagem = '';
	
	switch (operacao) {			
		
		case 'CA': liberaOperacao(); return false; break;	
		case 'CI': liberaOperacao(); return false; break;	
		
		case 'AC': showConfirmacao('Deseja cancelar opera&ccedil;&atilde;o?','Confirma&ccedil;&atilde;o - Ayllos','semaforo--;controlaOperacao(\'\')','semaforo--;operacao=\'CA\';bloqueiaFundo(divRotina)','sim.gif','nao.gif'); return false; break;						
		case 'IC': showConfirmacao('Deseja cancelar opera&ccedil;&atilde;o?','Confirma&ccedil;&atilde;o - Ayllos','semaforo--;controlaOperacao(\'\')','semaforo--;operacao=\'CI\';bloqueiaFundo(divRotina)','sim.gif','nao.gif'); return false; break;
		
		case 'AV': manterRotina(); return false; break;			
		case 'VA': manterRotina(); return false; break;	
		case 'IV': manterRotina(); return false; break;	
		case 'VI': manterRotina(); return false; break;	
		case 'PI': manterRotina(); return false; break;	
		
		case 'FA':
			mensagem = 'Aguarde, finalizando altera&ccedil;&atilde;o ...';
			idseqttl = $('#idseqttl','#frmCabContas').val();
			nrcpfcgc = '';
			cdgraupr = '';	
			obtemCabecalho( idseqttl, false, true );
			break;				
		case 'FI':
			mensagem = 'Aguarde, finalizando inclus&atilde;o ...';			
			idseqttl = $('#idseqttl > option','#frmCabContas').length + 1;
			nrcpfcgc = '';
			cdgraupr = '';
			obtemCabecalho( idseqttl, false, true );
			break;				
		
		case 'BI': mensagem = 'Aguarde, buscando dados ...'; break;		
		case 'BA': mensagem = 'Aguarde, buscando dados ...'; break;
		
		// Qualquer outro valor: Cancelando Operação
		default: 
			mensagem = 'Aguarde, abrindo formulário ...';
			idseqttl = $('#idseqttl','#frmCabContas').val();
			nrcpfcgc = '';
			cdgraupr = '';
			break;			
	}
	
	showMsgAguardo( mensagem );
	
	nrcpfcgc = normalizaNumero( nrcpfcgc );
	
	
	// Executa script de através de ajax
	$.ajax({		
		type: 'POST',
		dataType: 'html',
		url: UrlSite + 'telas/contas/identificacao_fisica/principal.php', 
		data: {
			nrdconta: nrdconta, idseqttl: idseqttl, operacao: operacao,
			nrcpfcgc: nrcpfcgc, cdgraupr: cdgraupr,	flgcadas: flgcadas, 
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
				controlaFoco();
			}
			return false;	
		}				
	});			
}


function controlaBotoes() {
		
	// Primeiro esconde todos os botões
	$('input','#divBotoes').css('display','none');
		
		
	if( operacao == 'BA' || operacao == 'CA' || operacao == 'A'){ 
			
		if(msgAlert == ''){
						
			if( ( ( $('#inhabmen','#'+nomeForm).val() == 0 && nrdeanos < 18) || $('#inhabmen','#'+nomeForm).val() == 2) && idseqttl == 1) {
				$('#btProsseguirAlt','#divBotoes').attr('src',UrlImagens + 'botoes/prosseguir.gif'); 
				
				$('#btProsseguirAlt','#divBotoes').unbind("click").bind("click",( function() {
					keypressCPF();
				}));
				
				if (flgcadas != 'M') {
					$('#btConcluirAlt','#divBotoes').attr('src',UrlImagens + 'botoes/prosseguir.gif'); 
				}
				
				$('#btConcluirAlt','#divBotoes').unbind("click").bind("click",( function() {
					controlaOperacao('AV');
				}));

			}else{

				$('#btProsseguirAlt','#divBotoes').attr('src',UrlImagens + 'botoes/concluir.gif');
				$('#btProsseguirAlt','#divBotoes').unbind("click").bind("click",( function() {
					keypressCPF();
				}));
				
				if (flgcadas != 'M') {
					$('#btConcluirAlt','#divBotoes').attr('src',UrlImagens + 'botoes/concluir.gif');	
				}				
				
				$('#btConcluirAlt','#divBotoes').unbind("click").bind("click",( function() {
					controlaOperacao('AV');
				}));
			}
			
		}else{
			$('#btProsseguirAlt','#divBotoes').attr('src',UrlImagens + 'botoes/concluir.gif');
			$('#btProsseguirAlt','#divBotoes').unbind("click").bind("click",( function() {
				keypressCPF();
			}));
				
			if (flgcadas != 'M') {
				$('#btConcluirAlt','#divBotoes').attr('src',UrlImagens + 'botoes/concluir.gif');
			}
			$('#btConcluirAlt','#divBotoes').unbind("click").bind("click",( function() {
				controlaOperacao('AV');
			}));
					
		}
		
	}	
		
	// Agora dependendo da operação exibe uma classe de botões
	switch (operacao) {
	
		case 'FC': $('.opConsulta'	,'#divBotoes').css('display','inline'); break;
		case 'FI': $('.opConsulta, .opContinuar','#divBotoes').css('display','inline'); break;
		case 'FA': $('.opConsulta, .opContinuar','#divBotoes').css('display','inline'); break;		
		case 'BI': $('.opInclusao'	,'#divBotoes').css('display','inline'); break;		
		case 'I' : $('.opInclusao'	,'#divBotoes').css('display','inline'); break;		
		case 'CA': 
			if ( retornaRelacionamento() == 0 ) {
				$('.opAlteracao','#divBotoes').css('display','inline'); 
			} else {				
				$('.opAlterar'	,'#divBotoes').css('display','inline'); 
			}
			
			$('.opContinuar','#divBotoes').css('display','inline');
			
			break;
		case 'CI': $('.opIncluir'	,'#divBotoes').css('display','inline'); break;			
		case 'BA': $('.opAlteracao'	,'#divBotoes').css('display','inline'); break;
		case 'A' : $('.opAlteracao'	,'#divBotoes').css('display','inline'); break;		
		default  : $('.opConsulta , .opContinuar','#divBotoes').css('display','inline'); break;
		
	}
}

function controlaContinuar() {
	
	flgContinuar = true;
	
	if ($("#btAlterar","#divBotoes").css('display').substr(0,6) == 'inline') {
		proximaRotina();
	} else {
		controlaOperacao('AV');
	}	
	
}

function retornaRelacionamento() {

	var aux = $('#cdgraupr','#'+nomeForm).val();
	aux = ( aux === null ) ? '' : aux;
	
	return aux;
	
}

function liberaOperacao() {
		
	var formulario		= $('#'+nomeForm);
	var cCPF			= $('#nrcpfcgc','#'+nomeForm);
	var cNomeTitular	= $('#nmextttl','#'+nomeForm);	
	var cNatureza		= $('#inpessoa','#'+nomeForm);	
	var cUfNatural      = $('#cdufnatu','#'+nomeForm);
	var camposGrupo1	= $('#cdgraupr, #nrcpfcgc','#'+nomeForm);	
	var camposGrupo2	= $('#nmextttl,#cdsitcpf,#dtcnscpf,#tpdocttl,#nrdocttl,#cdoedttl,#cdufdttl,#dtemdttl,#tpnacion,#cdnacion,#dtnasttl,#dsnatura,#cdufnatu,#inhabmen,#dthabmen,#cdestcvl,#grescola,#cdfrmttl,#nmcertif,#nmtalttl,#qtfoltal,input[name=\'cdsexotl\']','#'+nomeForm);
	
	
	// ALTERAÇÃO
	if ( operacao == 'CA' ) {		

		// Se É o primeiro titular, libera todos campos menos os campos tipo relacionamento e CPF
		// Se NÃO É o primeiro titular, libera libera somente os campos tipo relacionamento e CPF
		if ( retornaRelacionamento() == 0 ) { 
			camposGrupo2.habilitaCampo(); 
			cNomeTitular.desabilitaCampo();
			
			if( $('#cdestcvl','#'+nomeForm).val() == "2" ||
				$('#cdestcvl','#'+nomeForm).val() == "3" ||
				$('#cdestcvl','#'+nomeForm).val() == "4" || 
				$('#cdestcvl','#'+nomeForm).val() == "8" || 
				$('#cdestcvl','#'+nomeForm).val() == "9" || 
				$('#cdestcvl','#'+nomeForm).val() == "11" ){
			
				$('#inhabmen','#'+nomeForm).desabilitaCampo();
				$('#dthabmen','#'+nomeForm).desabilitaCampo();
	
			}else{			
			
				( $('#inhabmen','#'+nomeForm).val() != 1 ) ? $('#dthabmen','#'+nomeForm).desabilitaCampo() : $('#dthabmen','#'+nomeForm).habilitaCampo();
				
			}
			
		} else {		
			camposGrupo1.habilitaCampo();
		}
	
	// INCLUSÃO
	} else if ( operacao == 'CI') {	
		
		// Não permitir mais do que 4 titulares em uma conta
		if ( $('#idseqttl > option','#frmCabContas').length >= 4 ) {
			showError('error','Limite m&aacute;ximo de 4 (quatro) titulares por conta atingido.','Alerta - Ayllos','semaforo--;bloqueiaFundo(divRotina)');
			return false;
		} else {
			formulario.limpaFormulario();
			cUfNatural.val("");
			camposGrupo1.habilitaCampo();
			camposGrupo2.desabilitaCampo();
			cNatureza.val('1 - FISICA');
		}		
	}
	
	controlaBotoes();
	semaforo--;
	controlaPesquisas();
	controlaFoco();	
}

function manterRotina() {

	semaforo--;
	hideMsgAguardo();		
	
	var mensagem = '';
	
	switch (operacao) {	
	
		case 'VA': mensagem = 'Aguarde, alterando ...'; break;
		case 'VI': mensagem = 'Aguarde, incluindo ... '; break;
		case 'AV': mensagem = 'Aguarde, validando alteração ...'; break;						
		case 'IV': mensagem = 'Aguarde, validando inclusão ...'; break;						
		case 'PI': mensagem = 'Aguarde, validando alteração ...'; break;						
		default: return false; break;
		
	}
	
	showMsgAguardo( mensagem );
	
	// Recebendo valores do formulário
	var cdgraupr = $('#cdgraupr','#'+nomeForm).val();	
	var nrcpfcgc = $('#nrcpfcgc','#'+nomeForm).val();	
	var nmextttl = $('#nmextttl','#'+nomeForm).val();
	var cdsitcpf = $('#cdsitcpf','#'+nomeForm).val();
	var dtcnscpf = $('#dtcnscpf','#'+nomeForm).val();    
	var tpdocttl = $('#tpdocttl','#'+nomeForm).val();
	var nrdocttl = $('#nrdocttl','#'+nomeForm).val();
	var cdoedttl = $('#cdoedttl','#'+nomeForm).val();
	var cdufdttl = $('#cdufdttl','#'+nomeForm).val();
	var dtemdttl = $('#dtemdttl','#'+nomeForm).val();
	var tpnacion = $('#tpnacion','#'+nomeForm).val();
    var cdnacion = $('#cdnacion','#'+nomeForm).val();
	var dsnacion = $('#dsnacion','#'+nomeForm).val();
	var dtnasttl = $('#dtnasttl','#'+nomeForm).val();
	var dsnatura = $('#dsnatura','#'+nomeForm).val();
	var cdufnatu = $('#cdufnatu option:selected','#'+nomeForm).val();	
	var inhabmen = $('#inhabmen','#'+nomeForm).val();
	var dthabmen = $('#dthabmen','#'+nomeForm).val();
	var cdestcvl = $('#cdestcvl','#'+nomeForm).val();
	var grescola = $('#grescola','#'+nomeForm).val();	
	var cdfrmttl = $('#cdfrmttl','#'+nomeForm).val();
	var nmcertif = $('#nmcertif','#'+nomeForm).val();	
	var nmtalttl = $('#nmtalttl','#'+nomeForm).val();
	var qtfoltal = $('#qtfoltal','#'+nomeForm).val();	
	var nrctattl = $('#nrctattl','#'+nomeForm).val();	
	var cdsexotl = $('input[name="cdsexotl"]:checked','#'+nomeForm).val();
	var cdnatopc = $('#cdnatopc','#'+nomeForm).val();
	var cdocpttl = $('#cdocpttl','#'+nomeForm).val();
	var tpcttrab = $('#tpcttrab','#'+nomeForm).val();
	var nmextemp = removeCaracteresInvalidos($('#nmextemp','#'+nomeForm).val());
	var nrcpfemp = $('#nrcpfemp','#'+nomeForm).val();
	var dsproftl = $('#dsproftl','#'+nomeForm).val();
	var cdnvlcgo = $('#cdnvlcgo','#'+nomeForm).val();
	var cdturnos = $('#cdturnos','#'+nomeForm).val();
	var dtadmemp = $('#dtadmemp','#'+nomeForm).val();
	var vlsalari = $('#vlsalari','#'+nomeForm).val();
	
	nrcpfcgc = normalizaNumero( nrcpfcgc );	
	nrdconta = normalizaNumero( nrdconta );	
	nrctattl = normalizaNumero( nrctattl );	
		
	nmextttl = trim( nmextttl );
	nrdocttl = trim( nrdocttl );
	cdoedttl = trim( cdoedttl );
	nmtalttl = trim( nmtalttl );	
	nmcertif = trim( nmcertif );	


	/*!
	 * ALTERAÇÃO : 005
	 * OBJETIVO  : Quando altera/inclui um titular, caso o titular já é cadastrado no sistema, e não é titular somente 
	 *             desta conta, então não validar os dados, e também não habilitar os campos para edição. 
	 *             Caso é um CPF que não exite, ou o "Nr. Conta" deste titular é igual o número da conta que esta sendo 
	 *             manipulado, então validar dados e permitir edição dos dados.
	 *             A validação dos dados se dá no arquivo "manter_rotina.php"
	 */
	 	 
		 		 
	$.ajax({		
		type: 'POST',
		url: UrlSite + 'telas/contas/identificacao_fisica/manter_rotina.php', 		
		data: {
			nrdconta: nrdconta, idseqttl: idseqttl, cdgraupr: cdgraupr,	nrcpfcgc: nrcpfcgc, nmextttl: nmextttl, cdsitcpf: cdsitcpf,
			dtcnscpf: dtcnscpf, tpdocttl: tpdocttl, nrdocttl: nrdocttl,	cdoedttl: cdoedttl, cdufdttl: cdufdttl, dtemdttl: dtemdttl,
			tpnacion: tpnacion, cdnacion: cdnacion, dtnasttl: dtnasttl,	dsnatura: dsnatura, inhabmen: inhabmen, dthabmen: dthabmen,
			cdestcvl: cdestcvl, grescola: grescola, cdfrmttl: cdfrmttl,	nmcertif: nmcertif, nmtalttl: nmtalttl, qtfoltal: qtfoltal,
			cdsexotl: cdsexotl,	operacao: operacao, nrctattl: nrctattl,	cdnatopc: cdnatopc, cdocpttl: cdocpttl, tpcttrab: tpcttrab,
			nmextemp: nmextemp, nrcpfemp: nrcpfemp, dsproftl: dsproftl,	cdnvlcgo: cdnvlcgo, cdturnos: cdturnos,
			dtadmemp: dtadmemp, vlsalari: vlsalari, verrespo: verrespo, permalte: permalte, cdufnatu: cdufnatu, flgcadas: flgcadas,
			flgContinuar: flgContinuar, arrayFilhos: arrayFilhos,     redirect: 'script_ajax'
		}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','bloqueiaFundo(divRotina)');
		},
		success: function(response) {
			try {
				eval(response);
								
				// Se esta fazendo o cadastro apos MATRIC, fechar rotina e ir pra proxima
				if ( (operacao == 'VA' && flgcadas == "M") || (operacao == 'VA' && flgContinuar) ) {
					flgContinuar = false;
					proximaRotina();
				}
				
				return false;
			} catch(error) {
				hideMsgAguardo();
				showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','bloqueiaFundo(divRotina)');
			}
		}				
	});
}

function controlaLayout() {	
				
	$('#divConteudoOpcao').fadeTo(1,0.01);
	$('#divConteudoOpcao').css('height','400px');
	$('#divConteudoOpcao').css('width','540px');
	
	// FIELDSET IDENTIFICAÇÃO
	var rRotulos_1		= $('label[for=\'cdgraupr\'],label[for=\'nmextttl\'],label[for=\'cdsitcpf\'],label[for=\'tpdocttl\']','#'+nomeForm);
	var rRelacionamento = $('label[for=\'cdgraupr\']','#'+nomeForm);
	var rNomeTitular 	= $('label[for=\'nmextttl\']','#'+nomeForm);
	var rSituacao		= $('label[for=\'cdsitcpf\']','#'+nomeForm);
	var rDocumento		= $('label[for=\'tpdocttl\']','#'+nomeForm);
	var rCPF 			= $('label[for=\'nrcpfcgc\']','#'+nomeForm);
	var rDtConsulta		= $('label[for=\'dtcnscpf\']','#'+nomeForm);
	var rNatureza		= $('label[for=\'inpessoa\']','#'+nomeForm);
	var rOrgEmissor		= $('label[for=\'cdoedttl\']','#'+nomeForm);
	var rUfEmissor		= $('label[for=\'cdufdttl\']','#'+nomeForm);
	var rDtEmissao		= $('label[for=\'dtemdttl\']','#'+nomeForm); 
	
	rRotulos_1.addClass('rotulo');
	rNomeTitular.css('width','73px');
	rSituacao.css('width','73px');
	rDocumento.css('width','73px');
	rRelacionamento.css('width','223px');
	rCPF.css('width','44px');
	rDtConsulta.css('width','102px');
	rNatureza.css('width','71px');
	rOrgEmissor.css('width','73px');
	rDtEmissao.css('width','68px');
	
	// var cRelacionamento	= $('select[name=\'cdgraupr\']','#'+nomeForm);
	var cRelacionamento	= $('#cdgraupr','#'+nomeForm);
	var cCPF			= $('#nrcpfcgc','#'+nomeForm);
	var cNomeTitular	= $('#nmextttl','#'+nomeForm);
	var cSituacao		= $('#cdsitcpf','#'+nomeForm);	
	var cDtConsulta		= $('#dtcnscpf','#'+nomeForm);	
	var cNatureza		= $('#inpessoa','#'+nomeForm);		
	var cTpDocumento	= $('#tpdocttl','#'+nomeForm);
	var cDocumento		= $('#nrdocttl','#'+nomeForm);
	var cOrgEmissor		= $('#cdoedttl','#'+nomeForm);
	var cEstados		= $('#cdufdttl','#'+nomeForm);
	var cDataEmissao	= $('#dtemdttl','#'+nomeForm);
	
	cRelacionamento.css('width','148px');	
	cCPF.addClass('cpf').css('width','100px');	
	cNomeTitular.addClass('alphanum').css('width','445px').attr('maxlength','50');
	cSituacao.css('width','125px');	
	cDtConsulta.addClass('data').css('width','68px');
	cNatureza.css('width','73px');	
	cTpDocumento.css('width','40px');
	cDocumento.addClass('alphanum').css({'width':'400px','text-align':'right'}).attr('maxlength','40');
	cOrgEmissor.addClass('alpha').css('width','60px').attr('maxlength','7');
	cEstados.css('width','41px');
	cDataEmissao.addClass('data').css('width','73px');
	
	// FIELDSET PERFIL
	var rRotulos_2		= $('label[for=\'tpnacion\'],label[for=\'cdnacion\'],label[for=\'dsnatura\'],label[for=\'inhabmen\'],label[for=\'cdestcvl\'],label[for=\'grescola\'],label[for=\'cdfrmttl\'],label[for=\'nmtalttl\']','#'+nomeForm);	
	var rDtNascimento	= $('label[for=\'dtnasttl\']','#'+nomeForm);	
	var rDtEmancipacao	= $('label[for=\'dthabmen\']','#'+nomeForm);	
	var rSexo			= $('label[for=\'cdsexotl\']','#'+nomeForm);	
	var rUfNatural      = $('label[for=\'cdufnatu\']','#'+nomeForm);
	
	rRotulos_2.addClass('rotulo').css('width','73px');
	rDtNascimento.css('width','101px');
	rDtEmancipacao.css('width','118px');
	rSexo.addClass('rotulo').css('width','73px');
	rUfNatural.css('width','29px');
	
	var cDescricoes		= $('#dsescola,#dsestcvl,#destpnac','#'+nomeForm);
	var cDesNacional	= $('#dsnacion','#'+nomeForm);
    var cCdNacional	    = $('#cdnacion','#'+nomeForm);
	var cDesNatural		= $('#dsnatura','#'+nomeForm);
	var cUfNatural		= $('#cdufnatu','#'+nomeForm);
	var cDesCursoSup	= $('#rsfrmttl','#'+nomeForm);
	var cDtNascimento	= $('#dtnasttl','#'+nomeForm);
	var cRespLegal		= $('#inhabmen','#'+nomeForm);
	var cDtEmancipacao	= $('#dthabmen','#'+nomeForm);
	var cNrCertificado	= $('#nmcertif','#'+nomeForm);
	var cNomeTalao		= $('#nmtalttl','#'+nomeForm);
	var cFolhasTalao	= $('#qtfoltal','#'+nomeForm);
	var cSexo			= $('input[name=\'cdsexotl\']','#'+nomeForm);	
	var codigo 			= $('#cdestcvl,#grescola,#cdfrmttl','#'+nomeForm);
	var cCdestcvl 		= $('#cdestcvl','#'+nomeForm);	
	
	cDescricoes.addClass('descricao').css('width','388px');
	cDesCursoSup.addClass('descricao').css('width','197px');	
	cDesNacional.addClass('alpha').css('width','388px').attr('maxlength','15');
    //cCdNacional.addClass('inteiro').css('width','56px').attr('maxlength','5');
	cDesNatural.addClass('alpha pesquisa').css('width','182px').attr('maxlength','50');		
	cDtNascimento.addClass('data').css('width','65px');
	cRespLegal.css('width','256px');
	cDtEmancipacao.addClass('data').css('width','68px');		
	cNrCertificado.addClass('alphanum').css({'width':'106px','text-align':'right'}).attr('maxlength','25');
	cNomeTalao.addClass('alphanum').css('width','320px').attr('maxlength','40');
	cFolhasTalao.addClass('inteiro').css('width','30px').attr('maxlength','2');
		
	// DEFININDO OS GRUPOS DE VARIÁVEIS
	var camposGrupo1	= $('#cdgraupr, #nrcpfcgc','#'+nomeForm);
	var camposGrupo2	= $('#nmextttl,#cdsitcpf,#dtcnscpf,#tpdocttl,#nrdocttl,#cdoedttl,#cdufdttl,#dtemdttl,#tpnacion,#cdnacion,#dtnasttl,#dsnatura,#cdufnatu,#inhabmen,#dthabmen,#cdestcvl,#grescola,#cdfrmttl,#nmcertif,#nmtalttl,#qtfoltal','#'+nomeForm);
	var nrctattl 		= $('#nrctattl','#'+nomeForm).val();			
	
	// INICIA COM TUDO BLOQUEADO	
	camposGrupo1.desabilitaCampo();
	camposGrupo2.desabilitaCampo();
	cSexo.desabilitaCampo();
    cDesNacional.desabilitaCampo();
	cNatureza.desabilitaCampo();
	
	controlaFocoEnter(nomeForm);
	
	
	switch(operacao) {
		// Consulta Alteração
		case 'CA': 			
			if ( idseqttl == '1' ) { // Se é o primeiro titular
				camposGrupo2.habilitaCampo();
				cSexo.habilitaCampo();
								
			} else {
				camposGrupo1.habilitaCampo();
			}			
			break;	
		 
		 // Consulta Inclusão
		case 'CI': camposGrupo1.habilitaCampo(); break;					
		
		// Busca Alteração e Busca Inclusão
		case 'BA': 
		case 'BI': 				
			// Se o titular é desta conta ou este novo titular não possui nenhuma conta associada a ele
			// então habilitar os campos para edição.
			if ( (nrctattl == nrdconta) || (nrctattl == 0) ) {
				camposGrupo2.habilitaCampo();
				cSexo.habilitaCampo();
				cNatureza.val('1 - FISICA');
								
			} else {	
				// if ( operacao == 'BI' ) camposGrupo1.habilitaCampo();
			}
			if ( cRelacionamento.val() == '' ) { 
				$('#cdgraupr option:selected','#'+nomeForm).val('');
				cRelacionamento.val( cdgraupr_aux );
			}
			cCPF.val( nrcpfcgc_aux );			
			
			if ( idseqttl == '1' ) { cFolhasTalao.habilitaCampo(); } else { cFolhasTalao.desabilitaCampo(); } 
			
			break;
			
		default: 		
			break;
	}
	
	// Controle no CPF
	cCPF.unbind('keydown').bind('keydown', function(e) { 		
		if ( divError.css('display') == 'block' ) { return false; }		
		if ( e.keyCode == 13 ) { keypressCPF();	return false;}
	});	
	
	//Controle para verificar idade e permitir acesso a tela Resp. Legal
	cDtNascimento.unbind('change').bind('change', function() { 
		
		if(idseqttl == 1){
			controlaOperacao('PI');
		}
		
	});
	
	cRespLegal.unbind('change').bind('change', function() { 
		
		if( $(this).val() != 1 ){
			cDtEmancipacao.desabilitaCampo();
			cDtEmancipacao.val('');
			cCdestcvl.focus();
		}else{
			cDtEmancipacao.habilitaCampo();
		}
		
		if(idseqttl == 1){
			controlaOperacao('PI');
		}
							
	});
	
	cDtEmancipacao.unbind('change').bind('change', function() {
	
		if(idseqttl == 1){
			controlaOperacao('PI');
		}
		
	});
	
	
	cCdestcvl.unbind('keydown').bind('keydown', function(e){
	
		if(e.keyCode == 13){
			
			//Quando estado civil atender a condição abaixo então, os campos dthabmen, inhabmen devem ser desabilitados. Quando casado,
			//a pessoa é automaticamente emancipada.
			if(($(this).val() == "2"    ||
				$(this).val() == "3"    ||
				$(this).val() == "4"    || 
				$(this).val() == "8"    || 
				$(this).val() == "9"    || 
				$(this).val() == "11" ) &&
				nrdeanos < 18		    &&
				cRespLegal.val() == 0){
			
				cRespLegal.val(1).habilitaCampo();;
				cDtEmancipacao.val(dtmvtolt).habilitaCampo();
	
			}else{
				cRespLegal.habilitaCampo();;
				cDtEmancipacao.habilitaCampo();
			}
			
			if(idseqttl == 1){
				controlaOperacao('PI');
			}
		}
	
	});
	
	cFolhasTalao.unbind("keydown").bind("keydown",function(e) {
		if (e.keyCode == 13) {
			$("#btConcluirAlt","#divBotoes").trigger("click");
			return false;
		}	
	});
		
		
	controlaPesquisas();
	layoutPadrao();
	codigo.unbind('blur').bind('blur', function() { controlaPesquisas(); });		
	cCPF.trigger('blur');
	controlaBotoes();
	hideMsgAguardo();
	bloqueiaFundo(divRotina);
	removeOpacidade('divConteudoOpcao');
	highlightObjFocus($('#frmDadosIdentFisica'));
	controlaFocoEnter("frmDadosIdentFisica");
	controlaFoco();
	return false;	
}

function keypressCPF() {

	var cRelacionamento	= $('#cdgraupr','#'+nomeForm);
	var cCPF			= $('#nrcpfcgc','#'+nomeForm);
	
	// Valida Grau de Relacionamento 
	cdgraupr = retornaRelacionamento();
	cdgraupr_aux = cdgraupr;
	
	if ( cdgraupr == '' ) { 
		showError('error','Relacionamento inválido.','Alerta - Ayllos','bloqueiaFundo(divRotina,\'cdgraupr\',\'frmDadosIdentFisica\');'); 
	
		return false; 
		
	}
		
	cRelacionamento.removeClass('campoErro');

	// Valida CPF
	nrcpfcgc = normalizaNumero( cCPF.val() );
	nrcpfcgc_aux = nrcpfcgc;
	
	if ( nrcpfcgc == 0 ) { 
		return false; 
	
	}
	
	if ( !validaCpfCnpj(nrcpfcgc ,1) ) { 
		showError('error','CPF inválido.','Alerta - Ayllos','bloqueiaFundo(divRotina,\'nrcpfcgc\',\'frmDadosIdentFisica\');'); 

		return false; 
		
	}
	
	cCPF.removeClass('campoErro');

	// Armazena a sequencia do titular
	idseqttl = (operacao == 'CI' || operacao == 'BI') ? $('#idseqttl > option','#frmCabContas').length + 1 : $('#idseqttl','#frmCabContas').val();	
	
	if (operacao == 'CA' || operacao == 'BA') { controlaOperacao('BA'); } 
	if (operacao == 'CI' || operacao == 'BI') {	controlaOperacao('BI');	}
	
	return false;
		
}

function controlaPesquisas() {

	// Variável local para guardar o elemento anterior
	var campoAnterior = '';
	var bo, procedure, titulo, qtReg, filtros, colunas, filtrosDesc;	
	
	bo	= 'b1wgen0059.p';
	
	// Atribui a classe lupa para os links de desabilita todos
	$('a','#'+nomeForm).addClass('lupa').css('cursor','auto');
	
	// Percorrendo todos os links
	$('a','#'+nomeForm).each( function(i) {
	
		if ( !$(this).prev().hasClass('campoTelaSemBorda') ) $(this).css('cursor','pointer');
		
		$(this).unbind("click").bind("click",( function() {
            
            campoAnterior = $(this).prev().attr('name');
             
			if ( $(this).prev().hasClass('campoTelaSemBorda') ) {
				return false;
			} else {						
				campoAnterior = $(this).prev().attr('name');
				
				// Tipo Nacionalidade
				if ( campoAnterior == 'tpnacion' ) {
					procedure	= 'busca_tipo_nacionalidade';
					titulo      = 'Tipo Nacionalidade';
					qtReg		= '30';
					filtros 	= 'Cód. Tp. Nacion.;tpnacion;30px;S;0|Tp. Nacion.;destpnac;200px;S;';
					colunas 	= 'Código;tpnacion;20%;right|Tipo Nacionalidade;destpnac;80%;left';
					mostraPesquisa(bo,procedure,titulo,qtReg,filtros,colunas,divRotina);
					return false;
				
				// Orgao Emissor
				} else if (campoAnterior == 'cdoedttl'){			
					procedure	= 'BUSCA_ORGAO_EXPEDIDOR';
					titulo      = 'Org&atilde;o expedidor';
					qtReg		= '30';
					filtrosPesq = 'Código;cdoedttl;100px;S;|Descrição;nmoedttl;200px;S;';
					colunas = 'Código;cdorgao_expedidor;25%;left|Descrição;nmorgao_expedidor;75%;left';
					mostraPesquisa("ZOOM0001", procedure, titulo, qtReg, filtrosPesq, colunas, divRotina);									
					return false;
				// Curso Superior
				} else if ( campoAnterior == 'cdfrmttl' ) {
					procedure	= 'busca_formacao';
					titulo      = 'Curso Superior';
					qtReg		= '30';
					filtros 	= 'Cód. Curso Superior;cdfrmttl;30px;S;0|Curso Superior;rsfrmttl;200px;S;';
					colunas 	= 'Código;cdfrmttl;20%;right|Curso Superior;rsfrmttl;80%;left';
					mostraPesquisa(bo,procedure,titulo,qtReg,filtros,colunas,divRotina);
					return false;

				// Nacionalidade
				} else if ( campoAnterior == 'cdnacion' ) {
					
					var filtrosPesq = "Código;cdnacion;100px;S;0|Descrição;dsnacion;200px;S;";
                    var colunas = 'Código;cdnacion;25%;right|Descrição;dsnacion;75%;left';
                    mostraPesquisa("ZOOM0001", "BUSCANACIONALIDADES", "Nacionalidade", "30", filtrosPesq, colunas, divRotina);
                    
					return false;
				
				// Naturalidade
				} else if ( campoAnterior == 'dsnatura' ) {
					procedure	= 'busca_naturalidade';
					titulo      = 'Naturalidade';
					qtReg		= '50';
					filtros 	= 'Naturalidade;dsnatura;200px;S;';
					colunas 	= 'Naturalidade;dsnatura;100%;left';
					mostraPesquisa(bo,procedure,titulo,qtReg,filtros,colunas,divRotina);
					return false;
					
				// Estado Civil
				} else if ( campoAnterior == 'cdestcvl' ) {
				
					procedure	= 'busca_estado_civil';
					titulo      = 'Estado Civil';
					qtReg		= '30';
					filtros 	= 'Cód. Estado Civil;cdestcvl;30px;S;0|Estado Civil;dsestcvl;200px;S;';
					colunas 	= 'Código;cdestcvl;20%;right|Estado Civil;dsestcvl;80%;left';
					mostraPesquisa(bo,procedure,titulo,qtReg,filtros,colunas,divRotina);
					return false;	

				// Escolaridade
				} else if ( campoAnterior == 'grescola' ) {
					procedure	= 'busca_grau_escolar';
					titulo      = 'Escolaridade';
					qtReg		= '30';
					filtros 	= 'Cód. Escolaridade;grescola;30px;S;0|Escolaridade;dsescola;200px;S;';
					colunas 	= 'Código;grescola;20%;right|Escolaridade;dsescola;80%;left';
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
	
	// Tipo Nacionalidade
	$('#tpnacion','#'+nomeForm).unbind('change').bind('change',function() {
		procedure	= 'busca_tipo_nacionalidade';
		titulo      = 'Tipo Nacionalidade';
		filtrosDesc = '';
		buscaDescricao(bo,procedure,titulo,$(this).attr('name'),'destpnac',$(this).val(),'destpnac',filtrosDesc,'frmDadosIdentFisica');
		return false;
	}); 
	
		
    //  Nacionalidade
	$('#cdnacion','#'+nomeForm).unbind('change').bind('change',function() {
		
		buscaDescricao("ZOOM0001", "BUSCANACIONALIDADES", "Nacionalidade", $(this).attr('name'), 'dsnacion', $(this).val(), 'dsnacion', '', 'frmDadosIdentFisica');
		return false;
		
	}); 
	
		
	// Estado Civil
	$('#cdestcvl','#'+nomeForm).unbind('focusout').bind('focusout',function() {
		
		//Quando estado civil for "Casado" e idade for menor que 18 anos, a pessoa passa automaticamente a ser emancipada.
		if(($(this).val() == "2"                  ||
			$(this).val() == "3"                  ||
			$(this).val() == "4"                  || 
			$(this).val() == "8"                  || 
			$(this).val() == "9"                  || 
			$(this).val() == "11" )               &&
			nrdeanos < 18                         &&
			$('#inhabmen','#'+nomeForm).val() == 0){
					
			 $('#inhabmen','#'+nomeForm).val(1).habilitaCampo();
			 $('#dthabmen','#'+nomeForm).val(dtmvtolt).habilitaCampo();

		}else{
			 $('#inhabmen','#'+nomeForm).habilitaCampo();
			 $('#dthabmen','#'+nomeForm).habilitaCampo();
			 
		}
				
		if(idseqttl == 1){
			controlaOperacao('PI');
		}
	
		procedure	= 'busca_estado_civil';
		titulo      = 'Estado Civil';
		filtrosDesc = '';
		buscaDescricao(bo,procedure,titulo,$(this).attr('name'),'dsestcvl',$(this).val(),'dsestcvl',filtrosDesc,'frmDadosIdentFisica');
		return false;
		
	});
	
	// Escolaridade
	$('#grescola','#'+nomeForm).unbind('change').bind('change',function() {
		procedure	= 'busca_grau_escolar';
		titulo      = 'Escolaridade';
		filtrosDesc = '';
		buscaDescricao(bo,procedure,titulo,$(this).attr('name'),'dsescola',$(this).val(),'dsescola',filtrosDesc,'frmDadosIdentFisica');
		return false;
	});

	// Curso Superior
	$('#cdfrmttl','#'+nomeForm).unbind('change').bind('change',function() {
		procedure	= 'busca_formacao';
		titulo      = 'Curso Superior';
		filtrosDesc = '';
		buscaDescricao(bo,procedure,titulo,$(this).attr('name'),'rsfrmttl',$(this).val(),'rsfrmttl',filtrosDesc,'frmDadosIdentFisica');
		return false;
	});
}

function controlaFoco() {
		
	if (in_array(operacao,['AC','IC','FI','FA',''])) {	
		$('#btAlterar','#divBotoes').focus();
		
	} else if ( operacao == 'CA' && retornaRelacionamento() == 0 ) { 
		if (flgcadas == 'M') {
			$('#grescola','#'+nomeForm).focus();
		} else {
			$('#cdsitcpf','#'+nomeForm).focus();
		}
	
	} else if ( operacao == 'CA' && retornaRelacionamento() != 0 ) { 
		$('#cdgraupr','#'+nomeForm).focus();
		
	} else if ( operacao == 'BA' && retornaRelacionamento() != 0 ) { 
		$('#nmextttl','#'+nomeForm).focus();
	
	} else if ( operacao == 'CI' ) { 
		$('#cdgraupr','#'+nomeForm).focus();
	
	} else if ( operacao == 'BI' ) { 
		$('#nmextttl','#'+nomeForm).focus();
		
	}
	return false;
}


function proximaRotina () {
	hideMsgAguardo();
	acessaOpcaoAbaDados(6,2,'@');		
}

//mostra a tabela de Nacionalidade
function mostraNacionalidade() {
	showMsgAguardo('Aguarde, buscando ...');

	// Executa script de confirmação através de ajax
	$.ajax({		
		type: 'POST', 
		dataType: 'html',
		url: UrlSite + 'includes/nacionalidades/form_nacionalidades.php', 
		data: { redirect: 'html_ajax' }, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();	
			
			showError('error','Não foi possível concluir a requisição.','Alerta - Ayllos',"unblockBackground()");
		},
		success: function(response) {
			hideMsgAguardo();	
			$('#divUsoGenerico').html(response);
			exibeRotina($('#divUsoGenerico'));
			bloqueiaFundo( $('#divUsoGenerico') );			
			return false;
		}				
	});
}

function dossieDigidoc() {
	showMsgAguardo('Aguarde...');

	// Executa script de confirmação através de ajax
	$.ajax({
		type: 'POST',
		dataType: 'html',
		url: UrlSite + 'telas/contas/dossie_digidoc.php',
		data: {
      nrcpfcgc: $('#nrcpfcgc','#'+nomeForm).val(),
      nrdconta: $('#nrctattl','#'+nomeForm).val(),
      redirect: 'html_ajax'
    },
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();

			showError('error','Não foi possível concluir a requisição.','Alerta - Ayllos',"unblockBackground()");
		},
		success: function(response) {
			hideMsgAguardo();
			$('#divUsoGenerico').html(response);
			exibeRotina($('#divUsoGenerico'));
      $('#divUsoGenerico').css({'margin-top': '170px'});
      $('#divUsoGenerico').css({'width': '400px'});
      $('#divUsoGenerico').centralizaRotinaH();
			bloqueiaFundo( $('#divUsoGenerico') );			
      layoutPadrao();

			return false;
		}				
	});
}