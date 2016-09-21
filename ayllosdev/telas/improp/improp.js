/********************************************************************
 Fonte: improp.js                                                 
 Autor: Gabriel                                                   
 Data : Outubro/2010                Última Alteração: 23/07/2013  
                                                                  
 Objetivo  : Biblioteca de funções da tela IMPROP                 
                                                                  	 
 Alterações: 02/07/2012 - Alterado funcao imprimirContratos(),    
						  novo esquema de impressao (Jorge).  

			 27/02/2013 - Modificar para o layout padrao (Gabriel).	

			 23/07/2013 - Paginar a tela de 10 em 10 registros (Gabriel)		
********************************************************************/

var contWin  = 0;    // Variável para contagem do número de janelas abertas para impressos
var rCddopcao, rNrdconta, rTprelato0;  
var cCddopcao, cNrdconta, cCdagenci, cDtiniper , cDtfimper;
var cTprelato, cTprelato01, cTprelato02, cTprelato03, cTprelato04, cTprelato05;
var botoesMensagem;


$(document).ready(function() {	
	estadoInicial();
});

function estadoInicial() {

	rCddopcao   = $("label[for='cddopcao']","#frmImprop");
	rNrdconta   = $("label[for='nrdconta']","#frmImprop");
	rTprelato0  = $("label[for='tprelato0']","#frmImprop");

	cCddopcao = $("#cddopcao","#frmImprop");
	cNrdconta = $("#nrdconta","#frmImprop");
	cCdagenci = $("#cdagenci","#frmImprop");
	cDtiniper = $("#dtiniper","#frmImprop");
	cDtfimper = $("#dtfimper","#frmImprop");
	
	cTprelato   = $("#tprelato01 , #tprelato02 , #tprelato03 , #tprelato04","#frmImprop");
	cTprelato01 = $("#tprelato01","#frmImprop");
	cTprelato02 = $("#tprelato02","#frmImprop");
	cTprelato03 = $("#tprelato03","#frmImprop");
	cTprelato04 = $("#tprelato04","#frmImprop");
	cTprelato05 = $("#tprelato05","#frmImprop");
		
	botoesMensagem = $('a','#divBotoes');
	
	rCddopcao.css('width','46px');
	rNrdconta.css('width','46px');
	rTprelato0.css('width','46px');
	cCddopcao.css('width','490px');
	
	// Setar as Mascaras dos campos
	cNrdconta.addClass('conta').css( { 'width' : '80px' } );
	cCdagenci.css( { 'width' : '40px' } ).setMask("INTEGER","zz9","");
	cDtiniper.addClass('data').css( { 'width' : '80px' } );
	cDtfimper.addClass('data').css( { 'width' : '80px' } );
	
	
	// Esconder botoes
	botoesMensagem.css({'display':'none','padding-left':'2px','margin-top':'0px'});	
	
	$('#btProsseguir','#divBotoes').css('display','inline');

	cNrdconta.unbind("keypress").bind("keypress",function(e) {
		if (e.keyCode == 9 || e.keyCode == 13 ) {	
			cCdagenci.focus();
		}
	});
	
	cCdagenci.unbind("keypress").bind("keypress",function(e) {
		if (e.keyCode == 9 || e.keyCode == 13 ) {	
			cDtiniper.focus();
		}
	});
	
	cDtiniper.unbind("keypress").bind("keypress",function(e) {
		if (e.keyCode == 9 || e.keyCode == 13 ) {	
			cDtfimper.focus();
		}
	});
	
	cDtfimper.unbind("keypress").bind("keypress",function(e) {
		if (e.keyCode == 9 || e.keyCode == 13 ) {	
			ValidaDadosContratos();
			return false;
		}
	});
		
	// Se Mudou o CheckBox de 'Todas' (tipo de contrato)
	cTprelato05.unbind("change").bind("change",function(e) { 
		// Se 'Todas' entao desabilita as outras operacoes 
		if (cTprelato05.prop('checked')) {
		   cTprelato.prop('checked',false);	   
		   cTprelato.prop("disabled",true);	
		}
		else { // Senao Habilita
		   cTprelato.prop("disabled",false);
		}			
	});
		
	highlightObjFocus($("#frmImprop"));
		
    cNrdconta.focus();
		
	layoutPadrao();	
		
}

function marcaTodas () {

	var cFlgtodas   = $("#flgtodas","#divResultado");
		
	cFlgtodas.unbind("change").bind("change",function() {						
		$('#dsdimpri','#divContratos').each(function() {		 
			$(this).prop('checked',cFlgtodas.prop('checked'));	
		});			       	   
	});

}
 
// Validar informacoes da tela (Permissoes, conta, pac e datas )
function ValidaDadosContratos() {

	var cddopcao = cCddopcao.val();
	var nrdconta = retiraCaracteres( cNrdconta.val(),"0123456789",true);
	var cdagenci = cCdagenci.val();
	var dtiniper = cDtiniper.val();
	var dtfimper = cDtfimper.val();		
	
	// Pelo menos um CheckBox (Operacao) marcada 
	if (!cTprelato01.prop('checked') && !cTprelato02.prop('checked') && !cTprelato03.prop('checked') && !cTprelato04.prop('checked') && !cTprelato05.prop('checked')) {
		showError("error","Selecione pelo menos um tipo de opera&ccedil;&atilde;o de cr&eacute;dito.","Alerta - Ayllos");		
		return;					
	}	
	// Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, validando informa&ccedil;&otilde;es ...");
	
	// Carrega conteúdo da opção através de ajax
	$.ajax({		
		type: "POST", 
		url: UrlSite + "telas/improp/valida_dados.php",
		data: {
		    cddopcao: cddopcao,
			nrdconta: nrdconta,
			cdagenci: cdagenci,
			dtiniper: dtiniper,
			dtfimper: dtfimper,		
			redirect: "html_ajax" // Tipo de retorno do ajax
		},		
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message + ".","Alerta - Ayllos","$('#nrdconta','#frmImprop').focus()");							
		},
		success: function(response) {		
			try {
				eval(response);
			} catch(error) {
				hideMsgAguardo();					
			    showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message + ".","Alerta - Ayllos","$('#nrdconta','#frmImprop').focus()");							
			}				
		}		
				
	}); 	
}

// Listar os contratos 
function listaContratos(nriniseq) {

	var cddopcao = cCddopcao.val();
	var nrdconta = retiraCaracteres( cNrdconta.val(),"0123456789",true);
	var cdagenci = cCdagenci.val();
	var dtiniper = cDtiniper.val();
	var dtfimper = cDtfimper.val();	
	var nmrelato = "";	
		
	// Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, carregando dados dos contratos ...");	
	
	// Colocar na variavel 'nmrelato' a(as) operacoes marcadas
	
	// Se todas as operacoes 
	if (cTprelato05.prop('checked')) { 
		nmrelato = cTprelato05.val();
	}
	else { // Senao concatena as 4 operacoes 
	
		if (cTprelato01.prop('checked')) {
		   nmrelato = cTprelato01.val();
		}	
		if (cTprelato02.prop('checked')) {
		   if (nmrelato != "") {
		      nmrelato += ",";
		   }
		   nmrelato += cTprelato02.val(); 	
		}
		if (cTprelato03.prop('checked')) {
		   if (nmrelato != "") {
		      nmrelato += ",";
		   }
		   nmrelato += cTprelato03.val();			
		}
		if (cTprelato04.prop('checked')) {
		   if (nmrelato != "") {
		      nmrelato += ",";
		   }
		   nmrelato += cTprelato04.val();	
		}	
	}

	//layoutTabela();
	controlaBotoes();
		
	// Carrega os dados da tela atraves de ajax
	$.ajax ({
		type: "POST",
		url: UrlSite + "telas/improp/carrega_contratos.php",
		data: {
		    cddopcao: cddopcao,
			nrdconta: nrdconta,
			cdagenci: cdagenci,
			dtiniper: dtiniper,
			dtfimper: dtfimper,
			nmrelato: nmrelato,
			nriniseq: nriniseq,
			redirect: "html_ajax" // Tipo de retorno do ajax		
		},
		error: function(ObjAjax,responseError,objExcept) {
			hideMsgAguardo();
            showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message + ".","Alerta - Ayllos","$('#nrdconta','#frmImprop').focus()");							
		},
		success: function(response) {
			try {
				eval(response);	
				layoutTabela();	
				marcaTodas();		
			} catch(error) {
				hideMsgAguardo();
			    showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message + ".","Alerta - Ayllos","$('#nrdconta','#frmImprop').focus()");							
			}	
		}
	});	
}

function layoutTabela () {

	$("#divContratos").css("height","220px");

	var divRegistro = $('div.divRegistros');		
	var tabela      = $('table', divRegistro );
	var linha       = $('table > tbody > tr', divRegistro );
	
	divRegistro.css({'height':'190px','padding-bottom':'2px'});
	
	var ordemInicial = new Array();
			
	var arrayLargura = new Array();
	arrayLargura[0] = '28px';
	arrayLargura[1] = '80px';
	arrayLargura[2] = '79px';
	arrayLargura[3] = '89px';
	arrayLargura[4] = '75px';
	arrayLargura[5] = '130px';
	arrayLargura[6] = '20px';

	var arrayAlinha = new Array();
	arrayAlinha[0] = 'right';
	arrayAlinha[1] = 'right';
	arrayAlinha[2] = 'left';
	arrayAlinha[3] = 'right';
	arrayAlinha[4] = 'right';
	arrayAlinha[5] = 'center';
	arrayAlinha[6] = 'center';
	
	var metodoTabela = '';
	
	tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha, metodoTabela );

	$("th:eq(6)", tabela).removeClass();
	$("th:eq(6)", tabela).unbind('click');	

}

// Confirmacao da Opcao 'I' da tela
function confirmaImprimirContratos () {

	var nomedarq = montaPropostas();
	var msgConfirma;
	
	if (nomedarq == "") {
		return;
	}
	
	(nomedarq.indexOf(",") == -1) ? msgConfirma = "Deseja imprimir esta opera&ccedil;&atilde;o?" : msgConfirma = "Deseja imprimir todas estas opera&ccedil;&otilde;es?";  
	
	showConfirmacao(msgConfirma,'Confirma&ccedil;&atilde;o - Ayllos','imprimirContratos("' + nomedarq + '")','','sim.gif','nao.gif');
	
}

// Opcao 'I' da tela
function imprimirContratos (nomedarq) {

	$('#sidlogin','#frmImprop').remove();			
	
	$('#frmImprop').append('<input type="hidden" id="sidlogin" name="sidlogin" value="' + $('#sidlogin','#frmMenu').val() + '" />');	
	
	$("#nomedarq","#frmImprop").val(nomedarq);

	var action = UrlSite + 'telas/improp/impressao_contratos.php';	
	
	carregaImpressaoAyllos("frmImprop",action,"");
	
}
  
// Confirmacao da opcao 'E' da tela 
function confirmaExcluirContratos () {

	var nomedarq = montaPropostas();
	var msgConfirma;
	
	if (nomedarq == "") {
		return;
	}
	
	(nomedarq.indexOf(",") == -1) ? msgConfirma = "Deseja excluir esta opera&ccedil;&atilde;o?" : msgConfirma = "Deseja excluir todas estas opera&ccedil;&otilde;es?" ;  
	
	showConfirmacao(msgConfirma,'Confirma&ccedil;&atilde;o - Ayllos','excluirContratos("' + nomedarq + '")','','sim.gif','nao.gif');
	
}
	
// Opcao 'E' da tela 	
function excluirContratos (nomedarq) {
 	
	// Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, excluindo a(as) proposta(as) selecionada(as) ...");	
	
	$.ajax ({
	     type:"POST",
		 url: UrlSite + "telas/improp/exclui_contratos.php",
		 data: {
			  nomedarq: nomedarq,
			  redirect: "script_ajax"			
		 },	 
		error: function(ObjAjax,responseError,objExcept) {
			hideMsgAguardo();
		    showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","$('#nrdconta','#frmImprop').focus()");
	    },
		success: function(response) {
			try {
				eval(response);
			} catch(error) {
				hideMsgAguardo();
			    showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message + ".","Alerta - Ayllos","$('#nrdconta','#frmImprop').focus()");							
			}	
		}		 	
	});		
}

// Montar todas as  propostas selecionadas numa variavel
function montaPropostas () {

	var nomedarq= "";
	
	// Para todas as propostas selecionadas montar os nomes do arquivo numa variavel soh
	$('#dsdimpri','#divContratos').each(function() {	
		if ($(this).prop('checked')) {			 
			 nomedarq = (nomedarq == "") ? $(this).val() : nomedarq + "," + $(this).val();
		}
	});
		
	// Selecionar pelo menos uma operacao
	if (nomedarq == "") {
	    showError("error","Selecione pelo menos uma opera&ccedil;&atilde;o de cr&eacute;dito para continuar.","Alerta - Ayllos");		
		return "";					
	}
	
	return nomedarq;

} 
 
// Voltar a tela a Principal
function voltar() {

  // Habilitar os campos
  trataPrincipal(false);
	
  // Voltar os campos aos valores originais
  cCddopcao.val("I"); 
  cNrdconta.val("");
  cCdagenci.val("");
  cDtiniper.val("");
  cDtfimper.val(""); 
  
  // Habilitar de novo os campos
  cTprelato.prop("disabled",false);	   
  // Deixar checkBox em branco	   
  cTprelato.prop('checked',false);

  cTprelato05.prop('checked',false);

  // Desabilitar check box de todas as operacoes
	   	   
  // Foco no campo na Conta/dv			
  cNrdconta.focus();
  
		
  // Esconder o botao de Voltar
  $('#btVoltar','#divBotoes').css('display','none');
  // Esconder botao de Excluir
  $('#btExcluir','#divBotoes').css('display','none');
  // Esconder botao de Imprimir
  $('#btImprimir','#divBotoes').css('display','none');
  // Mostrar o botao de Prosseguir
  $('#btProsseguir','#divBotoes').css('display','inline'); 
  
  // Limpar lista de contratos
  $("#divContratos").html("");
  $("#divContratos").css("height","0px");

}

function controlaBotoes() {

  var cddopcao = $('#cddopcao','#frmImprop').val();
   
  // Esconder botao de Prosseguir
  $('#btProsseguir','#divBotoes').css('display','none'); 
  // Esconder botao de Excluir
  $('#btExcluir','#divBotoes').css('display','none');
  // Esconder botao de Imprimir
  $('#btImprimir','#divBotoes').css('display','none');

  // Mostrar o botao para Voltar
  $('#btVoltar','#divBotoes').css('display','inline');

  // Desabilitar Principal
  trataPrincipal(true);	
	
  if (cddopcao == "I") { // Opcao de Imprimir
     // Mostrar o botao de Imprimir
     $('#btImprimir','#divBotoes').css('display','inline'); 
  }
  else
  if (cddopcao == "E") { // Opcao de Excluir
     // Mostrar o botao de Excluir
     $('#btExcluir','#divBotoes').css('display','inline');	 
  }
  
}

function trataPrincipal (habilita) {
	if (habilita) {
		$('#cddopcao','#frmImprop').desabilitaCampo();
		$('#nrdconta','#frmImprop').desabilitaCampo();		
		$('#cdagenci','#frmImprop').desabilitaCampo();
		$('#dtiniper','#frmImprop').desabilitaCampo();
		$('#dtfimper','#frmImprop').desabilitaCampo();		
	} else {
		$('#cddopcao','#frmImprop').habilitaCampo();
		$('#nrdconta','#frmImprop').habilitaCampo();		
		$('#cdagenci','#frmImprop').habilitaCampo();
		$('#dtiniper','#frmImprop').habilitaCampo();
		$('#dtfimper','#frmImprop').habilitaCampo();		
	}
	
	$('#pesquisaAssoc','#frmImprop').prop("disabled",habilita);
	cTprelato.prop("disabled",habilita);
	cTprelato05.prop("disabled",habilita);	
}
