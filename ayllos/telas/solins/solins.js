/*************************************************************************
      Fonte: solins.js                                                 
      Autor: Fabrício                                                  
      Data : Setembro/2011                Última Alteração: 06/07/2012 
                                                                  
	  Objetivo  : Biblioteca de funções da tela SOLINS                
                                                                  	 
	  Alterações: 31/01/2012 - Alteracoes tarefa 42237 (Tiago)  
	  
				  23/04/2012 - Alterado o modo de pesquisa com lupas   
							   pois entrava em loop (Tiago)      
      
				  06/07/2012 - Alterado funcao gravaSolicitacao() e    
							   imprimeSolicitacao(), retirado ajax e   
							   novo esquema para impressao (Jorge).    
							   
				  09/01/2013 - Layout padrao (Gabriel).
				  
				  15/08/2013 - Alteração da sigla PAC para PA (Carlos)
*************************************************************************/

var aux_cdagenci = "";
var cPac, cNmrecben, cNridtrab , cNrbenefi, cCddopcao, cMotivsol;
var nomeForm; 

$(document).ready(function() {
	estadoInicial();
	formataCabecalho();
	alteraAltMotivo();
});

function formataCabecalho()  {
		
	cNmrecben = $('#nmbenefi',nomeForm);
	cNridtrab = $("#nridtrab",nomeForm);
	cNrbenefi = $("#nrbenefi",nomeForm);
	cCddopcao = $("#cddopcao",nomeForm);
	cMotivsol = $("#motivsol",nomeForm);
		
	cNridtrab.desabilitaCampo();
	cNrbenefi.desabilitaCampo();
	
	cPac.setMask('INTEGER','zz9','.','');

	cPac.unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 13 ) {
			cNmrecben.focus();
		}
	});
	
	cNmrecben.unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 13 ) {
			cCddopcao.focus();
		}	
	});
	
	cCddopcao.unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 13 ) {
			cMotivsol.focus();
		}
	});
	
	cMotivsol.unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 13 ) {
			imprimeSolicitacao();
			return false;
			
		}
	});
}

function controlaLayout(){
	layoutPadrao();
	controlaPesquisas();
}

function alteraAltMotivo() {

	var texto = "<option value='1'>1 - Perda/extravio</option>";
	
	texto += "<option value='2'>2 - Roubo</option>";
	
	if (cCddopcao.val() == "1") {
		cMotivsol.html(texto);
	} else {
		texto += "<option value='3'>3 - Esquecimento da senha</option>";	
		cMotivsol.html(texto);
    }
}

function controlaPesquisas() {
	
	// Atribui a classe lupa para os links de desabilita todos
	var lupas = $('a:not(.lupaFat)', nomeForm);
	
	lupas.addClass('lupa').css('cursor','auto');	
	
	// Percorrendo todos os links
	lupas.each( function() {
		
		if ( !$(this).prev().hasClass('campoTelaSemBorda') ) $(this).css('cursor','pointer');
		
		$(this).unbind('click').bind('click', function() {
				
				if ( $(this).prev().hasClass('campoTelaSemBorda') ) {
					return false;
				} else {			
					// Obtenho o nome do campo anterior
					campoAnterior = $(this).prev().attr('name');		
					
					// Nacionalidade
					if ( campoAnterior == 'cdagenci' ) {
						bo			= 'b1wgen0059.p';
						procedure	= 'busca_pac';
						titulo      = 'Agência PA';
						qtReg		= '20';					
						filtrosPesq	= 'Cód. PA;cdagenci;30px;S;0;;codigo;|Agência PA;dsagenci;200px;S;;;descricao;';
						colunas 	= 'Código;cdagepac;20%;right|Descrição;dsagepac;80%;left';
						mostraPesquisa(bo,procedure,titulo,qtReg,filtrosPesq,colunas);		
						return false;				
					} else if ( campoAnterior == 'nmbenefi' ) {
						mostraBeneficiarios(1, 30);
						return false;
					}				
				}
			});
	});
	
	return false;
}

function mostraBeneficiarios(  nriniseq , nrregist ){

	aux_cdagenci = $("#cdagenci", nomeForm).val();
	
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
	var nmrecben = cNmrecben.val();
					
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
				cNmrecben.val( $('#nmrecben', $(this) ).val() );
				cNrbenefi.val( $('#nrbenefi', $(this) ).val() );
				cNridtrab.val( $('#nrrecben', $(this) ).val() );
				
				$("#btOK", "#divBotoes").show();
			}
		});
	}
	
	controlaPesquisas();
	fechaRotina($('#divUsoGenerico'));
	return false;
}

function estadoInicial(){

	nomeForm    = '#frmSolins';	
	
	$(nomeForm).limpaFormulario();
	
	highlightObjFocus( $(nomeForm) );
	
	cPac = $('#cdagenci',nomeForm);
	
	cPac.focus();
	
	controlaLayout();
}

function imprimeSolicitacao(){
	
	var cdagenci = $("#cdagenci","#frmSolins").val();
	var nridtrab = $("#nridtrab","#frmSolins").val();
	var nrbenefi = $("#nrbenefi","#frmSolins").val();
	var cddopcao = $("#cddopcao","#frmSolins").val();
	var motivsol = $("#motivsol","#frmSolins").val();
	var nmbenefi = $("#nmbenefi","#frmSolins").val();
	var sidlogin = $('#sidlogin','#frmMenu').val();
	
	$('#cdagenci','#frmImpressao').remove();
	$('#nridtrab','#frmImpressao').remove();
	$('#nrbenefi','#frmImpressao').remove();
	$('#cddopcao','#frmImpressao').remove();
	$('#motivsol','#frmImpressao').remove();
	$('#nmbenefi','#frmImpressao').remove();	
	$('#sidlogin','#frmImpressao').remove();
	
	$('#frmImpressao').append('<input type="hidden" id="cdagenci" name="cdagenci" value="'+cdagenci+'"/>');
	$('#frmImpressao').append('<input type="hidden" id="nridtrab" name="nridtrab" value="'+nridtrab+'"/>');
	$('#frmImpressao').append('<input type="hidden" id="nrbenefi" name="nrbenefi" value="'+nrbenefi+'"/>');
	$('#frmImpressao').append('<input type="hidden" id="cddopcao" name="cddopcao" value="'+cddopcao+'"/>');
	$('#frmImpressao').append('<input type="hidden" id="motivsol" name="motivsol" value="'+motivsol+'"/>');
	$('#frmImpressao').append('<input type="hidden" id="nmbenefi" name="nmbenefi" value="'+nmbenefi+'"/>');	
	$('#frmImpressao').append('<input type="hidden" id="sidlogin" name="sidlogin" value="'+sidlogin+'"/>');	
	
	var action = UrlSite + "telas/solins/cadastra_solicitacao.php";
		
	carregaImpressaoAyllos("frmImpressao",action);
	
}

function limpaBeneficiario(){
	if (aux_cdagenci != ""){
		cNmrecben.val("");
		cNmrecben.focus();
	}
}

