/*!
 * FONTE  0     : cadins.js
 * CRIAÇÃO      : Gabriel Capoia (DB1)
 * DATA CRIAÇÃO : 25/05/2011
 * OBJETIVO     : Biblioteca de funções da tela CADINS
 * --------------
 * ALTERAÇÕES   : 
 * --------------
 * 28/06/2012 - Jorge        (CECRED) : Alterado funcao trataImpressao(), geraDeclaracao() e ajusttes no esquema de impressao
 * 17/12/2012 - Daniel 		 (CECRED) : Ajuste para layout padrao (Daniel).
 * 28/12/2012 - Gabriel		 (CECRED) : Ajuste para layout padrao (Gabriel).  				
 * 13/08/2013 - Carlos       (CECRED) : Alteração da sigla PAC para PA.
 */

// Definição de variáveis globais 
var nrJanelas = 0; // Armazena o número de janelas para as impressões

var msgRetor  = '';
var nmprimtl  = '';

var nomeForm  = 'frmCab';
	
var rPac, rNome, cTodos, cPac, cDesPac, cNome;

var cTodos_0, rRotulo, rNB, rNIT, rAgenc, rCPF, 
	cNB, cNIT, cAgenc, cCPF;

var cTodos_1, rRotulo_1, rOpcao, rConta, rNConta,
	rNome1, rMeio, rNMeio, rData, rNData, cOpcao, 
	cConta, cNConta, rNome1, cMeio, cNMeio, cData, 
	cNData, cdaltcad, btCdaltera, btPac, btVoltar;
	
var impresWin = "";

$(document).ready(function() {

	$("#frmCab").css('display','block');
	$("#frmCadins").css('display','block');
	$("#divBotoes").css('display','block');
	
	$('#frmCab').fadeTo(0,0.1);
	$('#divBotoes').fadeTo(0,0.1);
	
	highlightObjFocus( $('#frmCadins') );
	highlightObjFocus( $('#frmCab') );
	
	rPac      = $('label[for="cdagcpac"]','#frmCab');	
    rNome     = $('label[for="nmrecben"]','#frmCab');	
	          
    cTodos    = $('input[type="text"],select','#frmCab');	
    cPac      = $('#cdagcpac','#frmCab');	
    cDesPac   = $('#nmresage','#frmCab');	
    cNome     = $('#nmrecben','#frmCab');
	
	cTodos_0  = $('input,select ','#frmCadins fieldset:eq(0)');
	
	rRotulo   = $('label[for="nrbenefi"],label[for="cdaginss"]','#frmCadins');
	
	rNB       = $('label[for="nrbenefi"]','#frmCadins');
	rNIT      = $('label[for="nrrecben"]','#frmCadins');
	rAgenc    = $('label[for="cdaginss"]','#frmCadins');
	rCPF      = $('label[for="nrcpfcgc"]','#frmCadins');
	          
	cNB       = $('#nrbenefi','#frmCadins');
	cNIT      = $('#nrrecben','#frmCadins');
	cAgenc    = $('#cdaginss','#frmCadins');
	cCPF      = $('#nrcpfcgc','#frmCadins');
	
	cTodos_1  = $('input,select ','#frmCadins fieldset:eq(1)');
	
	rRotulo_1 = $('label[for="cdaltera"],label[for="dtatucad"],label[for="tpmepgto"],label[for="nrdconta"]','#frmCadins');
	
	rOpcao    = $('label[for="cdaltera"]','#frmCadins');
	rConta    = $('label[for="nrdconta"]','#frmCadins');
	rNConta   = $('label[for="nrnovcta"]','#frmCadins');
	rNome1    = $('label[for="nmprimtl"]','#frmCadins');
	rMeio     = $('label[for="tpmepgto"]','#frmCadins');
	rNMeio    = $('label[for="tpnovmpg"]','#frmCadins');
	rData     = $('label[for="dtatucad"]','#frmCadins');
	rNData    = $('label[for="dtdenvio"]','#frmCadins');
	          
	cOpcao    = $('#cdaltera','#frmCadins');
	cConta    = $('#nrdconta','#frmCadins');
	cNConta   = $('#nrnovcta','#frmCadins');
	cNome1    = $('#nmprimtl','#frmCadins');
	cMeio     = $('#tpmepgto','#frmCadins');
	cNMeio    = $('#tpnovmpg','#frmCadins');
	cData     = $('#dtatucad','#frmCadins');
	cNData    = $('#dtdenvio','#frmCadins');
	cCdaltcad = $('#cdaltcad','#frmCadins');
	
	btPac      = $('#btPac','#frmCab'); 
	btCdaltera = $('#btCdaltera','#frmCadins');
	btVoltar   = $('#btVoltar','#divBotoes');
		
	formataCabecalho();
	controlaLayout();
	
	removeOpacidade('frmCab');
	removeOpacidade('divBotoes');
	
	return false;
});

function controlaOperacao() {
		
	var cdaltera = cOpcao.val();
		
	if( cdaltera == 2 ){
	
		rNMeio.css('display','none');
		cNMeio.css('display','none');
		rData.html('');
		rData.html('Data da altera&ccedil;&atilde;o:');
		cNConta.val('');
		rNome1.css('display','none');
		cNome1.css('display','none');
		
		cOpcao.desabilitaCampo();
		
		cNConta.habilitaCampo();
		cNConta.focus();
				
	}else if( cdaltera == 9 ){
	
		cNConta.val('');
		rNome1.css('display','none');
		cNome1.css('display','none');
		
		cOpcao.desabilitaCampo();
		
		cNConta.habilitaCampo();
		cNConta.focus();
		
	}else if( cdaltera == 93 ){
		showConfirmacao("Deseja visualizar a impress&atilde;o?","Confirma&ccedil;&atilde;o - Ayllos","geraDeclaracao();","","sim.gif","nao.gif");
	}else{
		 manterRotina('T');
	}
	return false;
}

function trataImpressao( nmarqpdf ){
	
	$('#nmarqpdf','#'+nomeForm).remove();		
	$('#sidlogin','#'+nomeForm).remove();			
	
	// Insiro input do tipo hidden do formulário para enviá-los posteriormente
	$('#'+nomeForm).append('<input type="hidden" id="nmarqpdf" name="nmarqpdf" value="' + nmarqpdf + '" />');
	$('#'+nomeForm).append('<input type="hidden" id="sidlogin" name="sidlogin" value="' + $('#sidlogin','#frmMenu').val() + '" />');	
			
	var action = UrlSite + 'telas/cadins/imprimir_dados.php';	
	
	carregaImpressaoAyllos(nomeForm,action);
	
	return false;
	
}

function geraDeclaracao(){

	$('input, select', '#frmCadins').habilitaCampo();

	// Agora insiro os devidos valores nos inputs criados
	$('#auxconta','#frmCadins').val( normalizaNumero(cNConta.val()) );
	$('#cdagcpac','#frmCadins').val( cPac.val() );
	$('#nmrecben','#frmCadins').val( cNome.val() );
	
	$('#sidlogin','#frmCadins').remove();
			
	$('#frmCadins').append('<input type="hidden" id="sidlogin" name="sidlogin" value="' + $('#sidlogin','#frmMenu').val() + '" />');
			
	var action    = UrlSite + 'telas/cadins/gera_declaracao.php';	
	var callafter = "$('input, select', '#frmCadins').desabilitaCampo();cOpcao.habilitaCampo().focus();";
	
	carregaImpressaoAyllos("frmCadins",action,callafter);

	return false;
}

function manterRotina( operacao ) {
		
	hideMsgAguardo();
	
	var mensagem = '';
	
	switch (operacao) {	
		case 'V' : mensagem = 'Aguarde, validando ...';   break;
		case 'VP': mensagem = 'Aguarde, validando ...';   break;
		case 'V2': mensagem = 'Aguarde, validando ...';   break;
		case 'V9': mensagem = 'Aguarde, validando ...';   break;
		case 'T' : mensagem = 'Aguarde, processando ...'; break;
		case 'T2': mensagem = 'Aguarde, processando ...'; break;
		case 'T9': mensagem = 'Aguarde, processando ...'; break;
		default  : mensagem = 'Aguarde, processando ...'; break;
	}
	
	showMsgAguardo( mensagem );
						 
	var nrbenefi = ( typeof cNB.val()       == 'undefined' ) ? '' : cNB.val();
	var cdagcpac = ( typeof cPac.val()      == 'undefined' ) ? '' : cPac.val();
	var nrrecben = ( typeof cNIT.val()      == 'undefined' ) ? '' : cNIT.val();
	var nmrecben = ( typeof cNome.val()     == 'undefined' ) ? '' : cNome.val();
	var cdaltera = ( typeof cOpcao.val()    == 'object'    ) ? '' : cOpcao.val();
	var nrdconta = ( typeof cConta.val()    == 'undefined' ) ? '' : cConta.val();
	var nrnovcta = ( typeof cNConta.val()   == 'undefined' ) ? '' : cNConta.val();
	var cdaltcad = ( typeof cCdaltcad.val() == 'undefined' ) ? '' : cCdaltcad.val();
		
	cdaltera = normalizaNumero( cdaltera );
	cdagcpac = normalizaNumero( cdagcpac );
	nrdconta = normalizaNumero( nrdconta );
	nrnovcta = normalizaNumero( nrnovcta );
	
	$.ajax({		
			type  : 'POST',
			async : true ,
			url   : UrlSite + 'telas/cadins/manter_rotina.php', 		
			data: {
				cdaltera: cdaltera,	nrbenefi: nrbenefi,	
				nrrecben: nrrecben,	nmrecben: nmrecben,	
				nrdconta: nrdconta,	nrnovcta: nrnovcta,
				cdaltcad: cdaltcad, cdagcpac: cdagcpac,
				operacao: operacao,	redirect: 'script_ajax'
			}, 
			error: function(objAjax,responseError,objExcept) {
				hideMsgAguardo();
				showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','unblockBackground()');
			},
			success: function(response) {
				try {
					hideMsgAguardo();
					eval(response);
					return false;
				} catch(error) {
					hideMsgAguardo();
					showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','unblockBackground()');
				}
			}
		});

	return false;	
	                     
}       	

function controlaLayout() {
		
	$('#divTela').fadeTo(0,0.1);
				
	rRotulo.addClass('rotulo').css('width','170px');
	rNIT.css('width','150px');
	rCPF.css('width','150px');
		
	cNB.addClass('').css('width','110px');
	cNIT.addClass('').css('width','110px');
	cAgenc.addClass('').css('width','110px');
	cCPF.addClass('cpf').css('width','110px');
	
	cTodos_0.desabilitaCampo();
			
	rRotulo_1.addClass('rotulo').css('width','150px');
	rNConta.css('width','200px');
	rNome1.css('width','150px');
	rNMeio.css('width' ,'200px');
	rNData.css('width' ,'200px');
	
	cOpcao.addClass('').css('width' ,'400px');
	cConta.addClass('conta').css('width' ,'110px');
	cNConta.addClass('conta').css('width','120px');
	cNome1.addClass('').css('width','250px');
	cMeio.addClass('').css('width'  ,'110px');
	cNMeio.addClass('').css('width' ,'120px');
	cData.addClass('data').css('width'  ,'110px');
	cNData.addClass('data').css('width' ,'120px');
	
	cTodos_1.desabilitaCampo();
			
	rNome1.css('display','none');
	cNome1.css('display','none');
	
	cNConta.unbind('keypress').bind('keypress', function(e) {
		// Se é a tecla ENTER, valida Nova Conta
		if ( e.keyCode == 13 ) { manterRotina( 'V'+cOpcao.val() );return false;	}
	});
	
	cOpcao.unbind('keypress').bind('keypress', function(e) {
		// Se é a tecla ENTER, valida Nova Conta
		if ( e.keyCode == 13 ) { manterRotina('V');return false;}
	});
	
	btCdaltera.unbind('click').bind('click', function(e) {
		if ( !$(this).prev().hasClass('campoTelaSemBorda') ){ manterRotina('V');}
		return false;
	});
	
	btVoltar.unbind('click').bind('click', function(e) {
		if ( !cNConta.hasClass('campoTelaSemBorda') ){ 
			cNConta.desabilitaCampo();
			cNConta.val();
			cOpcao.habilitaCampo();
			cOpcao.focus();
		}else{
			estadoInicial();
		}
		return false;
	});
			
	var filtros = 'nmsistem;CRED|tptabela;GENERI|cdempres;0|cdacesso;DSCMANINSS|cdcoopea;0';
	
	montaSelect('b1wgen0059.p','busca-opcoes-manut-inss','cdaltera','tpregist','tpregist;dstextab','0',filtros);
	
	layoutPadrao();
		
	$('.conta').trigger('blur');
	
	controlaPesquisas();
	
	hideMsgAguardo();
	removeOpacidade('divTela');

	return false;	
}

function formataCabecalho() {
		
	rPac.addClass('rotulo-linha');
	rNome.addClass('rotulo-linha');
	
	cTodos.habilitaCampo();
	cPac.css('width','35px').addClass('pesquisa codigo').attr('maxlength','3');
	cDesPac.addClass('descricao').css('width','140px').desabilitaCampo();
	cNome.addClass('alphanum').css('width','260px').attr('maxlength','30');
			
	if ( $.browser.msie ) {	cNome.css('width','260px');	}

	cPac.focus();
	
	// Se pressionar tecla ENTER no campo Beneficiarios, chama validação
	/*cPac.unbind('keypress').bind('keypress', function(e) {	
		if ( e.keyCode == 13 || e.keyCode == 9 ) { 
			descricaoPac();
			return false;
		}	
	});		*/

	
	// Se pressionar tecla ENTER no campo Beneficiarios, chama validação
	cNome.unbind('keypress').bind('keypress', function(e) {	
		if ( e.keyCode == 13 || e.keyCode == 118 ) { 
			mostraBeficiarios( 1 , 30 );
			return false;
		}	
	});		

	// Se pressionar tecla ENTER no campo Beneficiarios, chama validação
	btPac.unbind('click').bind('click', function() {	
		mostraBeficiarios( 1 , 30 );
		return false;
	});		
	
	controlaPesquisas();
	return false;	
}

function mostraBeficiarios(  nriniseq , nrregist ){
	
	showMsgAguardo('Aguarde, buscando beneficiários...');
			
	$('#telaFilha').remove();
					
	// Executa script de confirmação através de ajax
	$.ajax({		
		type: 'POST',
		dataType: 'html',
		url: UrlSite + 'telas/cadins/beneficiarios.php', 
		data: {
			redirect: 'html_ajax'			
			}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError('error','0 Não foi possível concluir a requisição.','Alerta - Ayllos',"unblockBackground()");
		},
		success: function(response) {
			$('#divUsoGenerico').html(response);
			buscaBeneficiarios( nriniseq , nrregist );
		}				
	});
	return false;
	
}

function buscaBeneficiarios( nriniseq , nrregist ){
		
	showMsgAguardo('Aguarde, buscando beneficiários...');
	
	var cdagcpac = cPac.val();
	var nmrecben = cNome.val();
					
	$.ajax({		
		type: 'POST',
		dataType: 'html',
		url: UrlSite + 'telas/cadins/busca_beneficiarios.php', 
		data: {
			cdagcpac: cdagcpac, nmrecben: nmrecben,
			nriniseq: nriniseq, nrregist: nrregist, 
			redirect: 'script_ajax'			
			}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError('error','Não foi possível concluir a requisição.','Alerta - Ayllos',"fechaRotina($(\'#divUsoGenerico\'));estadoInicial();");
		},
		success: function(response) {
		
			if ( response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1 ) {
				try {
					$('#divConteudoOpcao').html(response);
					exibeRotina($('#divUsoGenerico'));
					formataBeneficiarios( nriniseq , nrregist );
					return false;
				} catch(error) {
					hideMsgAguardo();
					showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','fechaRotina($(\'#divUsoGenerico\'));estadoInicial();');
				}
			} else {
				try {
					eval( response );
				} catch(error) {
					hideMsgAguardo();
					showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','fechaRotina($(\'#divUsoGenerico\'));estadoInicial();');
				}
			}
		}				
	});
	return false;
}

function formataBeneficiarios(){
			
	var divRegistro = $('div.divRegistros','#divBeneficiarios');		
	var tabela      = $('table', divRegistro );
	var linha       = $('table > tbody > tr', divRegistro );
			
	divRegistro.css({'height':'150px','width':'550px'});
	
	var ordemInicial = new Array();
	ordemInicial = [[0,0]];
			
	var arrayLargura = new Array();
	arrayLargura[0] = '280px';
	arrayLargura[1] = '90px';
	arrayLargura[2] = '90px';
	
		
	var arrayAlinha = new Array();
	arrayAlinha[0] = 'left';
	arrayAlinha[1] = 'center';
	arrayAlinha[2] = 'center';
	arrayAlinha[3] = 'center';
	
	var metodoTabela = 'selecionaBeneficiario();';
			
	tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha, metodoTabela );
	
	hideMsgAguardo();
	bloqueiaFundo( $('#divUsoGenerico') );
	
	$('#btSalvar','#divBotoes').focus();
	
	return false;
}

function selecionaBeneficiario(){
	
	if ( $('table > tbody > tr', 'div.divRegistros').hasClass('corSelecao') ) {
					
		$('table > tbody > tr', 'div.divRegistros').each( function() {
			if ( $(this).hasClass('corSelecao') ) {
				cNome.val(     $('#nmrecben', $(this) ).val() );
				cCPF.val(      $('#nrcpfcgc', $(this) ).val() );
				cNB.val(       $('#nrbenefi', $(this) ).val() );
				cNIT.val(      $('#nrrecben', $(this) ).val() );
				cAgenc.val(    $('#cdaginss', $(this) ).val() );
				cConta.val(    $('#nrdconta', $(this) ).val() );
				cMeio.val(     $('#tpmepgto', $(this) ).val() );
				cData.val(     $('#dtatucad', $(this) ).val() );
				cCdaltcad.val( $('#cdaltcad', $(this) ).val() );
				cNData.val(    $('#dtdenvio', $(this) ).val() );
			}
		});
	}
	
	cTodos_0.trigger('blur');
	cTodos_1.trigger('blur');
	cTodos.desabilitaCampo();
	cNome.desabilitaCampo();
	cOpcao.habilitaCampo();
	cOpcao.focus();
	controlaPesquisas();
	fechaRotina($('#divUsoGenerico'));
	return false;
}

//Adiciona os eventos aos campos/lupas de pesquisas
function controlaPesquisas() {
					
	var nomeForm = 'frmCab';
	var lupas = $('a','#'+nomeForm);
	
	lupas.addClass('lupa').css('cursor','auto');	
	
	// Percorrendo todos os links
	lupas.each( function() {
	
		if ( !$(this).prev().hasClass('campoTelaSemBorda') ) $(this).css('cursor','pointer');		
		
		$(this).prev().unbind('blur').bind('blur', function() { 
			if ( !$(this).hasClass('campoTelaSemBorda') ) {
				controlaPesquisas();
			}
			return false;
		});
		
		$(this).unbind('click').bind('click', function() {
			if ( $(this).prev().hasClass('campoTelaSemBorda') ) {
				return false;
			} else {			
				// Obtenho o nome do campo anterior
				campoAnterior = $(this).prev().attr('name');		
				
				// PA
				if ( campoAnterior == 'cdagcpac' ) {
										
					bo			= 'b1wgen0059.p';
					procedure	= 'busca_pac';
					titulo      = 'Agência PA';
					qtReg		= '20';					
					filtrosPesq	= 'Cód. PA;cdagcpac;30px;S;0;;codigo;|Agência PA;nmresage;200px;S;;;descricao;';
					colunas 	= 'Código;cdagepac;20%;right|Descrição;dsagepac;80%;left';
					mostraPesquisa(bo,procedure,titulo,qtReg,filtrosPesq,colunas);
					
				//Beneficiários			
				}else if ( campoAnterior == 'nmrecben' ) {
					mostraBeficiarios( 1 , 30 );
				}
				return false;
			}
		});
	});
	
	$('#cdagcpac','#' + nomeForm ).unbind('change').bind('change', function() { 
		var bo			= 'b1wgen0059.p';
		var procedure	= 'busca_pac';
		var titulo      = 'Agência PA';
		var filtrosDesc = 'cdagepac|'+$(this).val();
		buscaDescricao(bo,procedure,titulo,$(this).attr('name'),'nmresage',$(this).val(),'dsagepac',filtrosDesc,nomeForm);
		$('#nmrecben','#' + nomeForm ).focus();
		return false;
	});
	
	return false;
	
}

function estadoInicial() { 	
		
	$('#'+nomeForm).limpaFormulario();
	$('#frmCadins').limpaFormulario();
		
	formataCabecalho();
	controlaLayout();
	
	cPac.attr('aux',''); // atributo para o controle da pesquisa
	
	rNMeio.css('display','block');
	cNMeio.css('display','block');
	rNome1.css('display','none');
	cNome1.css('display','none');
	
	return false;	
}
