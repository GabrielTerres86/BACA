/*
 * FONTE        : participacao.js
 * CRIAÇÃO      : Guilherme Strube
 * DATA CRIAÇÃO : 31/08/2011
 * OBJETIVO     : Biblioteca de funções na rotina participacao em empresas da tela de CONTAS
 *
 * ALTERAÇÃO    : 04/08/2015 - Reformulacao cadastral (Gabriel-RKAM).
 *
 *                08/01/2018 - Ajuste para carregar nome da empresa do cadastro unificado e não permitir alterar caso possua cadastro completo.
                               P339 - Evandro Guaranha - Mout's 
 *
 */

var nrcpfcgc = '';
var nrdctato = '';
var nrdrowid = '';
var cddopcao = 'C';
var cpfaux 	 = '';
var indarray = '';
var operacao = '';
var nomeForm = 'frmParticipacaoEmpresas';

function acessaOpcaoAba(nrOpcoes,id,opcao) { 
	// Mostra mensagem de aguardo
	showMsgAguardo('Aguarde, carregando dados ...');
	
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
		url: UrlSite + 'telas/contas/participacao/principal.php',
		data: {
			nrdconta: nrdconta,
			idseqttl: idseqttl,
			nrcpfcgc: nrcpfcgc,
			nrdctato: nrdctato,
			nrdrowid: nrdrowid,
			cddopcao: cddopcao,
			operacao: operacao,
			flgcadas: flgcadas,
			redirect: 'html_ajax'
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
				controlaFoco( operacao );
			}
			return false;	
		}
	});
}

function controlaOperacao( operacao ){

	if ( operacao != 'EV' && operacao !='EC' && !verificaContadorSelect() ) return false;
	
	// Se não possui acesso para alterar, emitir mensagem	
	if ( (operacao == 'TC') && (flgConsultar != '1') ) { showError('error','Seu usu&aacute;rio n&atilde;o possui permiss&atilde;o de consulta.'               ,'Alerta - Ayllos','bloqueiaFundo(divRotina)'); return false; }
	if ( (operacao == 'TA') && (flgAlterar   != '1') ) { showError('error','Seu usu&aacute;rio n&atilde;o possui permiss&atilde;o de altera&ccedil;&atilde;o.','Alerta - Ayllos','bloqueiaFundo(divRotina)'); return false; }	
	if ( (operacao == 'TI') && (flgIncluir   != '1') ) { showError('error','Seu usu&aacute;rio n&atilde;o possui permiss&atilde;o de inclus&atilde;o.'        ,'Alerta - Ayllos','bloqueiaFundo(divRotina)'); return false; }
	if ( (operacao == 'TX') && (flgExcluir   != '1') ) { showError('error','Seu usu&aacute;rio n&atilde;o possui permiss&atilde;o de exclux&atilde;o.'        ,'Alerta - Ayllos','bloqueiaFundo(divRotina)'); return false; }
	
	if ( in_array(operacao,['TC','TA','TX']) ) {
		nrcpfcgc 	= '';
		nrdctato 	= '';
		nrdrowid 	= '';
		$('table > tbody > tr', 'div.divRegistros').each( function() {
			if ( $(this).hasClass('corSelecao') ) {
				nrcpfcgc = $('input[name="nrcpfcgc"]', $(this) ).val();
				nrdctato = $('input[name="nrdctato"]', $(this) ).val();
				nrdrowid = $('input[name="nrdrowid"]', $(this) ).val();
			}
		});	
				
		if ( nrcpfcgc == '' && nrdctato == '' ) { return false; }
	}
	
	var msgOperacao = '';		
	switch (operacao) {
		// Consulta tabela para consulta formulário
		case 'TC':
			msgOperacao = 'Aguarde, abrindo formulário ...';
			operacao 	= 'CF'; //consulta formulario
			cddopcao    = 'C';	
			break;			
		// Consulta formulário para consulta tabela
		case 'CT': 
			msgOperacao = 'Aguarde, abrindo tabela ...';
			operacao 	= 'CT';	//consulta tabela
			nrcpfcgc 	= '';
			nrdctato 	= '';
			nrdrowid 	= '';
			cddopcao    = 'C';	
			break;				
		// Consulta tabela para alteração
		case 'TA': 
			msgOperacao = 'Aguarde, abrindo formulário ...';
			operacao 	= 'A';
			cddopcao    = 'A';
			break;
		// Alteração para consulta tabela 		
		case 'AT': 
			showConfirmacao('Deseja cancelar altera&ccedil;&atilde;o?','Confirma&ccedil;&atilde;o - Ayllos','controlaOperacao()','bloqueiaFundo(divRotina)','sim.gif','nao.gif');
			return false;
			break;
		// Formulario em modo inclusão para tabela consulta		
		case 'IT': 
           showConfirmacao('Deseja cancelar inclus&atilde;o?','Confirma&ccedil;&atilde;o - Ayllos','controlaOperacao()','bloqueiaFundo(divRotina)','sim.gif','nao.gif');
			return false;
            break;	
		// Tabela consulta para inclusão		
		case 'TI':
			msgOperacao = 'Aguarde, abrindo formulário ...';
			operacao 	= 'I'; 
			nrcpfcgc 	= '';
			nrdctato 	= '';
			nrdrowid 	= '';
			cddopcao    = 'I';	
			break;
		// Formulario de inclusão com os dados de retorno da busca por CONTA ou CPF	
		case 'TB':
			msgOperacao = 'Aguarde, abrindo formulário ...';
			operacao 	= 'IB'; 
			cddopcao    = 'I';	
			break;
		// Alteração para validação: Salvando alteração
		case 'AV': 
			manterRotina('VA');
			return false;
			break;
		// Formulario em modo inclusão para validação: Incluindo empresa	
		case 'IV':
			manterRotina('VI');
			return false;
			break;
		// Abre o form. consulta para formulario em modo exclusão	
		case 'TX': 
			msgOperacao = 'Aguarde, abrindo formulário ...';
			cddopcao    = 'E';			
			break;	
		// Tabela consulta para formulario em modo exclusão	
		case 'EV':
			manterRotina(operacao);
			return false;
            break;
		case 'E':
			manterRotina(operacao);
			return false;
            break;
		// Dados validados. Altera dados. 
		case 'VA': 
			manterRotina('A');
			return false;
            break;
		//Dados validados. Inclui dados.	
		case 'VI': 
			manterRotina('I');
			return false;
            break;						
		default:  
			msgOperacao = 'Aguarde, abrindo tela ...'
			operacao 	= 'CT';
			nrcpfcgc 	= '';
			nrdrowid 	= '';
			nrdctato 	= '';
			cddopcao 	= 'C';
	}
	// $('#divConteudoOpcao').css({'-moz-opacity':'0','filter':'alpha(opacity=0)','opacity':'0'});
	$('.divRegistros').remove();
	showMsgAguardo(msgOperacao);
			
	// Executa script de confirmação através de ajax
	$.ajax({		
		type: 'POST',
		dataType: 'html',
		url: UrlSite + 'telas/contas/participacao/principal.php', 
		data: {
			nrdconta: nrdconta, idseqttl: idseqttl, nrcpfcgc: nrcpfcgc,
			nrdctato: nrdctato, nrdrowid: nrdrowid, cddopcao: cddopcao,
			operacao: operacao, flgcadas: flgcadas, redirect: 'script_ajax'			
		}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError('error','Não foi possível concluir a requisição.','Alerta - Ayllos','bloqueiaFundo(divRotina)');
		},
		success: function(response) {
			if ( response.indexOf('showError("error"') == -1 ) {
				
				$('#divConteudoOpcao').html(response);
				
				if (operacao == "IB" || 
				    operacao == "A"){
                    
                    // Validar se o nome pode ser alterada
                    buscaNomePessoa_gen($('#nrcpfcgc','#'+nomeForm ).val(),'nmprimtl', nomeForm);                        
                        
                }
				
			} else {
				
				eval( response );
				controlaFoco( operacao );
				
				if (operacao == "IB" || 
				    operacao == "A"){
                    
                    // Validar se o nome pode ser alterada
                    buscaNomePessoa_gen($('#nrcpfcgc','#'+nomeForm ).val(),'nmprimtl', nomeForm);                        
                        
                }
				
				
			}
			return false;	
		}				
	});				
}

function manterRotina(operacao) {

	nrcpfcgc = $('#nrcpfcgc','#frmParticipacaoEmpresas').val();
	nrcpfcgc = normalizaNumero( nrcpfcgc );
	if ( !validaCpfCnpj(nrcpfcgc,2) ) { showError('error','CNPJ inv&aacute;lido.','Alerta - Ayllos','bloqueiaFundo(divRotina,\'nrcpfcgc\',\'frmParticipacaoEmpresas\');'); return false; }
	
	hideMsgAguardo();		
	var msgOperacao = '';
	switch (operacao) {	
		case 'A' : msgOperacao = 'Aguarde, alterando ...'; break;
		case 'I' : msgOperacao = 'Aguarde, incluindo ...'; break;
		case 'VA': msgOperacao = 'Aguarde, validando alteração ...'; break;
		case 'VI': msgOperacao = 'Aguarde, validando inclusão ...'; break;			
		case 'EV': msgOperacao = 'Aguarde, validando exclusão ...'; break;				
		case 'E': msgOperacao = 'Aguarde, excluindo ...'; break;				
		default: return false; break;
	}
	showMsgAguardo( msgOperacao );
	
	// Recebendo valores do formulário 
	nrdctato = normalizaNumero($('#nrdctato','#frmParticipacaoEmpresas').val());
	nmprimtl = trim($('#nmprimtl','#frmParticipacaoEmpresas').val());
	nmfatasi = trim($('#nmfatasi','#frmParticipacaoEmpresas').val());
	cdnatjur = trim($('#cdnatjur','#frmParticipacaoEmpresas').val());
	qtfilial = trim($('#qtfilial','#frmParticipacaoEmpresas').val());
	qtfuncio = trim($('#qtfuncio','#frmParticipacaoEmpresas').val());
	dtiniatv = $('#dtiniatv','#frmParticipacaoEmpresas').val();
	cdseteco = trim($('#cdseteco','#frmParticipacaoEmpresas').val());
	cdrmativ = trim($('#cdrmativ','#frmParticipacaoEmpresas').val());
	dsendweb = trim($('#dsendweb','#frmParticipacaoEmpresas').val());
	persocio = normalizaNumero($('#persocio','#frmParticipacaoEmpresas').val());
	dtadmsoc = $('#dtadmsoc','#frmParticipacaoEmpresas').val();
	vledvmto = normalizaNumero($('#vledvmto','#frmParticipacaoEmpresas').val());
	
	// Tratamento para os radio do sexo
	var sexoMas = $('#sexoMas','#frmParticipacaoEmpresas').prop('checked');
	var sexoFem = $('#sexoFem','#frmParticipacaoEmpresas').prop('checked');	
	
	if (sexoMas) {
		var cdsexcto = '1';
	} else if (sexoFem) {
		var cdsexcto = '2';
	} else {
		var cdsexcto = '';
	}
		
	// Executa script de confirmação através de ajax
	$.ajax({		
		type: 'POST',
		url: UrlSite + 'telas/contas/participacao/manter_rotina.php', 		
		data: {			
			nrcpfcgc: nrcpfcgc,	
			nrdctato: nrdctato,
			nmprimtl: nmprimtl,
			nmfatasi: nmfatasi,
			cdnatjur: cdnatjur,
			qtfilial: qtfilial,
			qtfuncio: qtfuncio,
			dtiniatv: dtiniatv,
			cdseteco: cdseteco,
			cdrmativ: cdrmativ,
			dsendweb: dsendweb,
			persocio: persocio,
			dtadmsoc: dtadmsoc,
			vledvmto: vledvmto,
			nrdconta: nrdconta, 
			idseqttl: idseqttl, 
			nrdrowid: nrdrowid, 
			operacao: operacao, 
			redirect: 'script_ajax'
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

function controlaLayout( operacao ) {

	altura  = (operacao == 'CT') ? '205px' : '270px';
	largura = (operacao == 'CT') ? '580px' : '551px';
	divRotina.css('width',largura);	
	$('#divConteudoOpcao').css('height',altura);		
	
	if ( operacao == 'CT' ) {

		var divRegistro = $('div.divRegistros');		
		var tabela      = $('table', divRegistro );
		var linha       = $('table > tbody > tr', divRegistro );
		
		divRegistro.css('height','150px');
		
		var ordemInicial = new Array();
		ordemInicial = [[0,0]];
		
		var arrayLargura = new Array();
		arrayLargura[0] = '70px';
		arrayLargura[1] = '226px';
		arrayLargura[2] = '100px';
		
		var arrayAlinha = new Array();
		arrayAlinha[0] = 'right';
		arrayAlinha[1] = 'left';
		arrayAlinha[2] = 'right';
		arrayAlinha[3] = 'center';
		
		tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha, 'controlaOperacao(\'TC\');' );
		
	} else {
		
	// FIELDSET IDENTIFICAÇÃO
		var cNrConta		= $('#nrdctato','#frmParticipacaoEmpresas');
		var cCPF			= $('#nrcpfcgc','#frmParticipacaoEmpresas');
		
		cCPF.addClass('cnpj');
		
		
		// Controla largura dos campos
		$('#nmprimtl','#frmParticipacaoEmpresas').css({'width':'424px'});
		$('#nmfatasi','#frmParticipacaoEmpresas').css({'width':'424px'});
		$('#nrcpfcgc','#frmParticipacaoEmpresas').css({'width':'114px'});
		$('#inpessoa,#dtiniatv','#frmParticipacaoEmpresas').css({'width':'101px'});
		$('#qtfuncio','#frmParticipacaoEmpresas').css({'width':'68px'});
		$('#qtfilial','#frmParticipacaoEmpresas').css({'width':'65px'});
		$('#dsendweb','#frmParticipacaoEmpresas').css({'width':'348px','margin-right':'2px'});
		$('label[for="qtfuncio"]','#frmParticipacaoEmpresas').css({'width':'104px'});
		
		cNrConta.css('width','70px').addClass('conta pesquisa');
	
	// FIELDSET PARTICIPAÇÃO
		$('label[for="persocio"]','#'+nomeForm).addClass('rotulo rotulo-90');
		$('#persocio','#frmParticipacaoEmpresas').css('width','50px');
		
		var cEndividamento  = $('#vledvmto','#frmParticipacaoEmpresas');
		var cDtAdmissao  	= $('#dtadmsoc','#frmParticipacaoEmpresas');
		
		cEndividamento.css('width','120px');
		cDtAdmissao.css('width','67px');
		
	// INICIA CONTROLE DA TELA
		var camposGrupo2  = $('#nmprimtl,#nmfatasi,#vledvmto,#inpessoa,#dtiniatv,#qtfuncio,#qtfilial,#dsendweb,#cdnatjur,#cdseteco,#cdrmativ','#frmParticipacaoEmpresas');
		var camposGrupo3  = $('#persocio,#dtadmsoc','#frmParticipacaoEmpresas');		

		// Sempre inicia com tudo bloqueado
		cNrConta.desabilitaCampo();
		cCPF.desabilitaCampo();
		camposGrupo2.desabilitaCampo();
		camposGrupo3.desabilitaCampo();
		
		switch (operacao) {
			
			// Caso é inclusão, limpar dados do formulário					
			case 'I': 
				$('#frmParticipacaoEmpresas').limpaFormulario();
				cNrConta.habilitaCampo();
				break;
				
			//Caso é inclusão, apos a busca de dados pela conta ou pelo CPF 
			case 'IB':
				//Se o nº da conta for igual a 0 ou vazio então o formulario é desbloqueado para preenchimento 
				if ( cNrConta.val() == '0' || cNrConta.val() == '' ){
					camposGrupo2.habilitaCampo();
				}
				camposGrupo3.habilitaCampo();
				break;
				
			// Caso é alteração, se conta = 0, libera grupo 2 e 3, senão libera somente grupo 3 	
			case 'A': 
				if ( nrdctato == 0 ) {
					camposGrupo2.habilitaCampo();
					camposGrupo3.habilitaCampo();
					
				} else {
					camposGrupo3.habilitaCampo();
				}
				break;
				
			// Caso é exclusão, lista o formulário e bloqueia todos os campos
			case 'FX': 
				cNrConta.desabilitaCampo();
				cCPF.desabilitaCampo();
				camposGrupo2.desabilitaCampo();
				camposGrupo3.desabilitaCampo();
				break;	
			
			default: 
				break;
		}	

		// Controle do número da conta
		cNrConta.unbind('keydown').bind('keydown', function(e){ 	
		
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
				if ( !validaNroConta(nrdctato) ) { showError('error','Conta/dv inválida.','Alerta - Ayllos','focaCampoErro(\'nrdctato\',\'frmParticipacaoEmpresas\');'); return false; }
				
				// Se chegou até aqui, a conta é diferente do vazio e é válida, então realizar a operação desejada
				nrcpfcgc = '';				
				nrdrowid = '';				
				showMsgAguardo('Aguarde, buscando dados ...');
				controlaOperacao('TB');
			} 
		});

		// Controle no CPF
		cCPF.unbind('keydown').bind('keydown', function(e){ 	
		
			if ( divError.css('display') == 'block' ) { return false; }		
			
			// Se é a tecla ENTER, verificar numero conta e realizar as devidas operações
			if ( e.keyCode == 13 ) {		
			
				cpfaux = $(this).val();
				
				// Armazena o número da conta na variável global
				cpf = normalizaNumero( cpfaux );
			
				// Verifica se o número da conta é vazio
				if ( cpf == 0 ) { return false; }
					
				// Verifica se a conta é válida
				if ( !validaCpfCnpj(cpf ,2) ) { showError('error','CNPJ inv&aacute;lido.','Alerta - Ayllos','bloqueiaFundo(divRotina,\'nrcpfcgc\',\'frmParticipacaoEmpresas\');'); return false; }
				
				// Se chegou até aqui, a conta é diferente do vazio e é válida, então realizar a operação desejada
				nrcpfcgc 	= cpf;
				nrdctato 	= 0;
				nrdrowid 	= '';
				showMsgAguardo('Aguarde, buscando dados ...');
				controlaOperacao('TB');
			} 
		});	
		
		cDtAdmissao.unbind("keydown").bind("keydown",function(e) {
			if (e.keyCode == 13 && isHabilitado(cEndividamento) == false) {
				$("#btSalvar","#divBotoes").trigger("click");
				return false;
			}	
		});	

		cEndividamento.unbind("keydown").bind("keydown",function(e) {
			if (e.keyCode == 13) {
				$("#btSalvar","#divBotoes").trigger("click");
				return false;
			}	
		});	
		
		layoutPadrao();
		controlaPesquisas();
	}
	
	hideMsgAguardo();
	bloqueiaFundo(divRotina);
	removeOpacidade('divConteudoOpcao');
	highlightObjFocus($('#frmParticipacaoEmpresas'));
	controlaFocoEnter("frmParticipacaoEmpresas");
	controlaFoco(operacao);
	divRotina.centralizaRotinaH();

	return false;	
}

function estadoInicial() {
	var cNrConta		= $('#nrdctato','#frmParticipacaoEmpresas');
	var cCPF			= $('#nrcpfcgc','#frmParticipacaoEmpresas');
	var camposGrupo2    = $('#nmprimtl,#nmfatasi,#vledvmto,#inpessoa,#dtiniatv,#qtfuncio,#qtfilial,#dsendweb,#cdnatjur,#cdseteco,#cdrmativ','#frmParticipacaoEmpresas');
	var camposGrupo3    = $('#persocio,#dtadmsoc','#frmParticipacaoEmpresas');
	var sexo			= $('input[name="cdsexcto"]');	
	var cDescBem		= $('#dsrelbem','#frmParticipacaoEmpresas');
	
	$('#frmParticipacaoEmpresas').limpaFormulario();
	cNrConta.habilitaCampo();
	cCPF.desabilitaCampo();
	camposGrupo2.desabilitaCampo();
	camposGrupo3.desabilitaCampo();
	sexo.desabilitaCampo();	
	cDescBem.desabilitaCampo();
	removeOpacidade('divConteudoOpcao');	
	cNrConta.focus();
}


function controlaFoco(operacao) {
	if (in_array(operacao,['CT','',])) {
		$('#btAlterar','#divBotoes').focus();
	} else if ( operacao == 'CF' ) {
		$('#btVoltar','#divBotoes').focus();
	} else {
		$('.campo:first','#'+nomeForm).focus();
	}
	return false;
}

function controlaPesquisas() {
	// Variável local para guardar o elemento anterior
	var campoAnterior = '';
	var bo, procedure, titulo, qtReg, filtros, colunas, filtrosDesc;	
	
	bo = 'b1wgen0059.p';
	
	// Atribui a classe lupa para os links de desabilita todos
	var lupas = $('a:not(.link)','#frmParticipacaoEmpresas');
	lupas.addClass('lupa').css('cursor','auto');
	
	// Percorrendo todos os links
	lupas.each( function(i) {
	
		if ( !$(this).prev().hasClass('campoTelaSemBorda') ) $(this).css('cursor','pointer');
		
		$(this).click( function() {
			if ( $(this).prev().hasClass('campoTelaSemBorda') ) {
				return false;
			} else {						
				campoAnterior = $(this).prev().attr('name');
				
				// Natureza Jurídica
				if ( campoAnterior == 'cdnatjur' ) {					
					procedure	= 'busca_natureza_juridica';
					titulo      = 'Natureza Jur&iacute;dica';
					qtReg		= '30';
					filtros 	= 'Cód. Nat. Jurídica;cdnatjur;30px;S;0|Natureza Jurídica;dsnatjur;250px;S;';
					colunas 	= 'Código;cdnatjur;20%;right|Natureza Jurídica;dsnatjur;80%;left';
					mostraPesquisa(bo,procedure,titulo,qtReg,filtros,colunas,divRotina);
					return false;	

				// Setor Econômico
				} else if ( campoAnterior == 'cdseteco' ) {
					procedure	= 'busca_setor_economico';
					titulo      = 'Setor Econ&ocirc;mico';
					qtReg		= '30';
					filtros 	= 'Cód. Setor Econômico;cdseteco;30px;S;0|Setor Econômico;nmseteco;250px;S;';
					colunas 	= 'Código;cdseteco;20%;right|Setor Econômico;nmseteco;80%;left';
					mostraPesquisa(bo,procedure,titulo,qtReg,filtros,colunas,divRotina);
					return false;					
				
				// Ramo Atividade
				} else if ( campoAnterior == 'cdrmativ' ) {
					procedure	= 'busca_ramo_atividade';
					titulo      = 'Ramo Atividade';
					qtReg		= '30';
					filtros 	= 'Cód. Ramo Atividade;cdrmativ;30px;S;0|Ramo Atividade;dsrmativ;250px;S;|Cód. Setor Econômico;cdseteco;30px;N;|Setor Econômico;nmseteco;200px;N;';
					colunas 	= 'Código;cdrmativ;20%;right|Ramo Atividade;nmrmativ;80%;left';
					mostraPesquisa(bo,procedure,titulo,qtReg,filtros,colunas,divRotina);
					return false;
				}
			}
		});
	});
	
	// Hiperlink, pega o endereço no elemento anterior
	$('.link','#frmParticipacaoEmpresas').css('cursor','pointer');
	$('.link','#frmParticipacaoEmpresas').each( function() {
		
		var url = $(this).prev().attr('value');
		if( url.search('http://') == -1) url = 'http://'+$(this).prev().attr('value');
		$(this).attr('href',url);
		$(this).attr('target','_blank');
	});	

	/*-------------------------------------*/
	/*   CONTROLE DAS BUSCA DESCRIÇÕES     */
	/*-------------------------------------*/	

	// Natureza Jurídica
	$('#cdnatjur','#frmParticipacaoEmpresas').unbind('change').bind('change',function() {
		procedure	= 'busca_natureza_juridica';
		titulo      = 'Natureza Jur&iacute;dica';	
		filtrosDesc = '';
		buscaDescricao(bo,procedure,titulo,$(this).attr('name'),'dsnatjur',$(this).val(),'dsnatjur',filtrosDesc,'frmParticipacaoEmpresas');
		return false;
	});	
	
	// Setor Econômico
	$('#cdseteco','#frmParticipacaoEmpresas').unbind('change').bind('change',function() {
		procedure	= 'busca_setor_economico';
		titulo      = 'Setor Econ&ocirc;mico';
		filtrosDesc = '';
		buscaDescricao(bo,procedure,titulo,$(this).attr('name'),'nmseteco',$(this).val(),'nmseteco',filtrosDesc,'frmParticipacaoEmpresas');
		return false;
	});		

	// Ramo Atividade
	$('#cdrmativ','#frmParticipacaoEmpresas').unbind('change').bind('change',function() {
		procedure	= 'busca_ramo_atividade';
		titulo      = 'Ramo Atividade';
		filtrosDesc = 'cdseteco|'+$('#cdseteco','#frmParticipacaoEmpresas').val();
		buscaDescricao(bo,procedure,titulo,$(this).attr('name'),'dsrmativ',$(this).val(),'nmrmativ',filtrosDesc,'frmParticipacaoEmpresas');
		return false;
	});		
	
	return false;
}

function voltarRotina() {
	fechaRotina(divRotina);
	acessaRotina('ENDERECO','Endereço','endereco');
}

function proximaRotina () {
	hideMsgAguardo();
	encerraRotina(false);
	acessaRotina('PROCURADORES','Representante/Procurador','procuradores');				
}