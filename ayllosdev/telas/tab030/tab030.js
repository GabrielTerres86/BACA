/***********************************************************************
 Fonte: tab036.js                                                  
 Autor: Lucas/Gabriel                                                     
 Data : Nov/2011                Última Alteração:  22/04/2013
                                                                   
 Objetivo  : Biblioteca de funções da tela TAB036.                 
                                                                   	 
 Alterações: 25/05/2012 - Incluido campo 'diasatrs(Dias atraso para relatorio)'
                          (Tiago). 
						  
			 25/10/2012 - Incluso função voltaroltar, inclusão do efeito
						  fade e highlightObjFocus, tratamento processo
						  de desabilitação de campo opção e regra para
						  execução no botão OK. Retirado processo de
						  geração mensagem ajuda no rodape. (Daniel)
						  
		     22/04/2013 - Ajuste para a inclusao do parametro "Dias atraso para inadimplencia"
						  (Adriano).
						  
						  
************************************************************************/

var first = true;
var cddopcao;
var vllimite;
var vlsalmin;
var diasatrs;
var atrsinad;

$(document).ready(function() {	

	$("#btAlterar","#divMsgAjuda").hide();
	
	$("#btVoltar","#divMsgAjuda").hide();
	
	$("#divMsgAjuda").css('display','block');
	
	$('#frmCabTab030').fadeTo(0,0.1);
	$('#frmTab030').fadeTo(0,0.1);
	
	removeOpacidade('frmCabTab030');
	removeOpacidade('frmTab030');
	
	$('fieldset > legend').css({'font-size':'11px','color':'#777','margin-left':'5px','padding':'0px 2px'});
	$('fieldset').css({'clear':'both','border':'1px solid #777','margin':'3px 0px','padding':'10px 3px 5px 3px'});
	
	vllimite = $('#vllimite','#frmTab030');
	vlsalmin = $('#vlsalmin','#frmTab030');
	diasatrs = $('#diasatrs','#frmTab030');
	atrsinad = $('#atrsinad','#frmTab030');
	
	vllimite.desabilitaCampo();
	vlsalmin.desabilitaCampo();
	diasatrs.desabilitaCampo();
	atrsinad.desabilitaCampo();

	$("#vllimite","#frmTab030").setMask("DECIMAL","zzzzz9,99",",");
	$("#vlsalmin","#frmTab030").setMask("DECIMAL","zzzzzz9,99",",");	
	$("#diasatrs","#frmTab030").setMask("INTEGER","zz9","");
	$("#atrsinad","#frmTab030").setMask("INTEGER","zzz9","");
	
	var rvllimite	= $('label[for="vllimite"]','#frmTab030');
	var rvlsalmin	= $('label[for="vlsalmin"]','#frmTab030');	
	var rdiasatrs   = $('label[for="diasatrs"]','#frmTab030');
	var ratrsinad   = $('label[for="atrsinad"]','#frmTab030');
	
	formataMsgAjuda('');
	$("#divMsgAjuda").css('display','block'); 
	
	// rotulo
	/*rvllimite			= $('label[for="vllimite"]','#frmTab030'); */
	rvllimite.css('width','230px');
	
	/*rvlsalmin			= $('label[for="vlsalmin"]','#frmTab030'); */
	rvlsalmin.css('width','230px');
	
	/*rdiasatrs			= $('label[for="diasatrs"]','#frmTab030'); */
	rdiasatrs.css('width','230px');
	
	/*ratrsinad			= $('label[for="atrsinad"]','#frmTab030'); */
	ratrsinad.css('width','230px');
	
	$('#cddopcao','#frmCabTab030').focus();
	
	$('#cddopcao','#frmCabTab030').unbind('keypress').bind('keypress', function(e) {
			if ( e.keyCode == 9 || e.keyCode == 13 ) {	
				$('#btnOK','#frmCabTab030').focus();
				return false;
			}	
	});
	
	
});


function confirma () {

	var msgConfirma = "Deseja efetuar a altera&ccedil;&atilde;o do valor ?";
	showConfirmacao(msgConfirma,'Confirma&ccedil;&atilde;o - Ayllos','manter_rotina()','','sim.gif','nao.gif');

}

function define_operacao () {

	// Verifica se campo Opção está desativado.
	if( $('#cddopcao','#frmCabTab030').hasClass('campoTelaSemBorda') ){ return false; }
	manter_rotina ()
}

// Função para chamar a manter_rotina.php
function manter_rotina () { 	
	
	var nomeForm    = 'frmTab030';
	highlightObjFocus( $('#'+nomeForm) );
	
	var nomeForm    = 'frmCabTab030';
	highlightObjFocus( $('#'+nomeForm) );
	
	var mensagem = '';
	cddopcao = $('#cddopcao','#frmCabTab030').val();
	vllimite = $('#vllimite','#frmTab030').val();
	vlsalmin = $('#vlsalmin','#frmTab030').val();
	diasatrs = $('#diasatrs','#frmTab030').val();
	atrsinad = $('#atrsinad','#frmTab030').val();
	
	
	if (cddopcao == "A" && first == true) {
		cddopcao = "Primeiro";
		first = false;
	}
	
	switch (cddopcao) {
		
		case 'C': 

			$('#vllimite','#frmTab030').desabilitaCampo();
			$('#vlsalmin','#frmTab030').desabilitaCampo();
			$('#diasatrs','#frmTab030').desabilitaCampo();
			$('#atrsinad','#frmTab030').desabilitaCampo();
			first = false;
			$("#btAlterar","#divMsgAjuda").hide();
			$("#btVoltar","#divMsgAjuda").show();
			mensagem = 'Aguarde, buscando os dados ...';
				
   	    break;
		
		case 'A':
			
			mensagem = 'Aguarde, alterando os dados ...';
			$('#vllimite','#frmTab030').habilitaCampo();
			$('#vlsalmin','#frmTab030').habilitaCampo();
			$('#diasatrs','#frmTab030').habilitaCampo();
			$('#atrsinad','#frmTab030').habilitaCampo();
			$("#btAlterar","#divMsgAjuda").show();
			$("#btVoltar","#divMsgAjuda").show();
			
			$('#vllimite','#frmTab030').focus();
					
			//Foca no próximo campo caso pressine ENTER 
			$('#vllimite','#frmTab030').keypress( function(e) {
				if ( e.keyCode == 13 ) { 
					$('#vlsalmin','#frmTab030').focus();
					return false;
				}		
			});
			$('#vlsalmin','#frmTab030').keypress( function(e) {
				if ( e.keyCode == 13 ) { 
					$('#diasatrs','#frmTab030').focus();
					return false; 
				}		
			});
			$('#diasatrs','#frmTab030').keypress( function(e) {
				if ( e.keyCode == 13 ) { 
					$('#atrsinad','#frmTab030').focus();
					return false; 
				}		
			});
			$('#atrsinad','#frmTab030').keypress( function(e) {
				if ( e.keyCode == 13 ) { 
					confirma();
					return false; 
				}		
			});

			
		break;
		  
		case 'Primeiro':
			
			mensagem = 'Aguarde, alterando os dados ...';
			cddopcao = "C";
			$('#vllimite','#frmTab030').habilitaCampo();
			$('#vlsalmin','#frmTab030').habilitaCampo();
			$('#diasatrs','#frmTab030').habilitaCampo();
			$('#atrsinad','#frmTab030').habilitaCampo();
			$("#btAlterar","#divMsgAjuda").show();
			$("#btVoltar","#divMsgAjuda").show();
			
			$('#vllimite','#frmTab030').focus();
			
			//Foca no próximo campo caso pressine ENTER 
			$('#vllimite','#frmTab030').keypress( function(e) {
				if ( e.keyCode == 13 ) { 
					$('#vlsalmin','#frmTab030').focus();
					return false;
				}		
			});
			$('#vlsalmin','#frmTab030').keypress( function(e) {
				if ( e.keyCode == 13 ) { 
					$('#diasatrs','#frmTab030').focus();
					return false; 
				}		
			});
			
			$('#diasatrs','#frmTab030').keypress( function(e) {
				if ( e.keyCode == 13 ) { 
					$('#atrsinad','#frmTab030').focus();
					return false; 
				}		
			});
			
			$('#atrsinad','#frmTab030').keypress( function(e) {
				if ( e.keyCode == 13 ) { 
					confirma();
					return false; 
				}		
			});
			
		break;
		  
		case '':
			return false;
		break;
		
		
				  
	}
	
	// Desabilita campo opção
	cTodosCabecalho		= $('input[type="text"],select','#frmCabTab030'); 
	cTodosCabecalho.desabilitaCampo();
	
	// Mostra mensagem de aguardo
	showMsgAguardo(mensagem);
		
	// Carrega dados da conta através de ajax
	$.ajax({		
		type: "POST",
		url: UrlSite + "telas/tab030/manter_rotina.php", 
		data: {
			cddopcao: cddopcao,
			vllimite: vllimite,
			vlsalmin: vlsalmin,
			diasatrs: diasatrs,
			atrsinad: atrsinad,
			redirect: "html_ajax" // Tipo de retorno do ajax
		},
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","$('#cddopcao','#frmTab030').focus()");
		},
		success: function(response) {
			try {
				eval(response);
			} catch(error) {
				hideMsgAguardo();					
				showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message + ".","Alerta - Ayllos","$('#cddopcao','#frmTab030').focus()");				
			}
		}				
	}); 
	
}

// Mostrar a mensagem de Ajuda na tela
function formataMsgAjuda() {

	var botoesMensagem = $('input','#divMsgAjuda');
	botoesMensagem.css({'display':'none','float':'right','padding-left':'2px','margin-top':'0px'});	

}

function voltar() {

	cTodosCabecalho		= $('input[type="text"],select','#frmCabTab030'); 
	cTodosCabecalho.habilitaCampo();
	$("#btAlterar","#divMsgAjuda").hide();
	$("#btVoltar","#divMsgAjuda").hide();
	$('#cddopcao','#frmCabTab030').focus();
	$('#vllimite','#frmTab030').desabilitaCampo().val('');
	$('#vlsalmin','#frmTab030').desabilitaCampo().val('');
	$('#diasatrs','#frmTab030').desabilitaCampo().val('');
	$('#atrsinad','#frmTab030').desabilitaCampo().val('');
	first = true;

}