/*!
 * FONTE        : endava.js
 * CRIAÇÃo      : Jéssica (DB1) 
 * DATA CRIAÇÃO : 30/10/2013
 * OBJETIVO     : Biblioteca de funções da tela ENDAVA
 * --------------
 * ALTERAÇÔES   :
 * 000: [02/03/2015] Vanessa.  Ajustes para ficar igual a tela do caracter.
 *
 * --------------
 */
 
 var nometela;

//Formulários e Tabela
var frmCab   	= 'frmCab';
var frmConsulta = 'frmConsulta';
var divTabela;


var cddopcao, pro_cpfcgc, nrctremp, nrdconta, tpctrato, nmdaval, tpdocav, dscpfav, 
    nmcjgav, cpfccg, tpdoccj, dscfcav, nrfonres, nrcepend, dsendav1, nrendere, 
	complend, nrcxapst, dsendav2, dsdemail, nmcidade, cdufresd,
    cTodosCabecalho, btnOK, cTodosConsulta;

var rCddopcao, rPro_cpfcgc, rNrctremp, rNrdconta, rTpctrato, rNmdaval, rTpdocav, rDscpfav,
    rNmcjgav, rCpfccg, rTpdoccj, rDscfcav, rNrfonres, rNrcepend, rDsendav1, rNrendere,
	rComplend, rNrcxapst, rDsendav2, rDsdemail, rNmcidade, rCdufresd,
    cCddopcao, cPro_cpfcgc, cNrctremp, cNrdconta, cTpctrato, cNmdaval, cTpdocav, cDscpfav,
	cNmcjgav, cCpfccg, cTpdoccj, cDscfcav, cNrfonres, cNrcepend, cDsendav1, cNrendere,
	cComplend, cNrcxapst, cDsendav2, cDsdemail, cNmcidade, cCdufresd;
	
$(document).ready(function() {
	divTabela		= $('#divTabela');
	nrregist = 15;
	estadoInicial();
			
	return false;
		
});

//$('#btnError').unbind('click').bind('click', function() { alert()});
function carregaDados(){

	cddopcao   = $('#cddopcao','#'+frmCab).val();
	pro_cpfcgc = $('#pro_cpfcgc','#'+frmConsulta).val();  
	nrctremp   = $('#nrctremp','#'+frmConsulta).val();                                             
	
	nrdconta   = $('#nrdconta','#'+frmConsulta).val();                                            
	nrdconta   = nrdconta.replace(/[-. ]*/g,'');
	
	tpctrato   = $('#tpctrato','#'+frmConsulta).val();                                             
	nrfonres   = $('#nrfonres','#'+frmConsulta).val();                                           
	nrcepend   = $('#nrcepend','#'+frmConsulta).val();                                          
	dsendav1   = $('#dsendav1','#'+frmConsulta).val();                                         
	nrendere   = $('#nrendere','#'+frmConsulta).val();                               
	complend   = $('#complend','#'+frmConsulta).val();                                      
	nrcxapst   = $('#nrcxapst','#'+frmConsulta).val();                              
	dsendav2   = $('#dsendav2','#'+frmConsulta).val();                              
	dsdemail   = $('#dsdemail','#'+frmConsulta).val();                                     
	nmcidade   = $('#nmcidade','#'+frmConsulta).val();                                           
	cdufresd   = $('#cdufresd','#'+frmConsulta).val();                              
				                                                 
	return false;
} //carregaDados

// inicio
function estadoInicial() {

	$('#frmCab').fadeTo(0,0.1);
	$('#divTabela').html('');
	formataCabecalho();
	formataConsulta();
	controlaPesquisas();
	
	$('#frmConsulta').limpaFormulario();
	
	removeOpacidade('frmCab');
    	return false;
	
}

// formata
function formataCabecalho() {
		
	cTodosCabecalho		= $('input[type="text"],select','#'+frmCab);
		
	btnOK				= $('#btnOK','#'+frmCab);
	
	
	//Cabecalho
		
	rCddopcao			= $('label[for="cddopcao"]','#'+frmCab);	
	cCddopcao			= $('#cddopcao','#'+frmCab);
		
	cTodosCabecalho.habilitaCampo();
			
	rCddopcao.addClass('rotulo').css({'width':'80px'});
	cCddopcao.css({'width':'467px'});
			
	cCddopcao.focus();
	
	
	btnOK.unbind('click').bind('click', function() { 
		
		btnOK.unbind('click');
		if ( divError.css('display') == 'block' ) { return false; }		
		
		cTodosCabecalho.removeClass('campoErro');	
		cCddopcao.desabilitaCampo();	
		
		controlaLayout();
			
	});
	
	cCddopcao.unbind('keypress').bind('keypress', function(e) {

		if ( divError.css('display') == 'block' ) { return false; }

		// Se é a tecla ENTER
		if ( e.keyCode == 13) {

			btnContinuar();
			return false;
		}

	});
	
	
	$('#frmConsulta').css('display','none');
			
	highlightObjFocus( $('#frmCab') );
	highlightObjFocus( $('#frmConsulta') );
		
	layoutPadrao();
	
	cCddopcao.focus();	
		
	return false;	
}

function controlaLayout() {

	$('#frmConsulta').css('display','block');
		
	cPro_cpfcgc.habilitaCampo();
	cPro_cpfcgc.focus();

	
						
	return false;
}


//botoes
function btnVoltar() {
	
	estadoInicial();
		
	return false;
}

function btnContinuar() { 

	if ( divError.css('display') == 'block' ) { return false; }		
			
	if ( cCddopcao.hasClass('campo') ) {
		btnOK.click();
		
	}else {
	
		if(cCddopcao.val() == "A"){  
		
			if ( cPro_cpfcgc.hasClass('campoTelaSemBorda')  ) {
								
					showConfirmacao('Confirmar opera&ccedil;&atilde;o?','Confirma&ccedil;&atilde;o - Ayllos','manterRotina();','','sim.gif','nao.gif');
					
				}else {
					mostraContrato();
				}
				return false;
		
		}else{
		
			mostraContrato();
		}
					
	}
				
	return false;

}

function buscaEndava(nriniseq) {
	
	showMsgAguardo('Aguarde, buscando Contratos...');

	carregaDados();
			
	$.ajax({		
		type	: 'POST',
		dataType: 'html',
		url		: UrlSite + 'telas/'+nometela+'/busca_contrato.php', 
		data    :
				{ 
				  cddopcao   : cddopcao,	
				  pro_cpfcgc : pro_cpfcgc,
				  nrctremp   : nrctremp,
				  nrdconta   : nrdconta,
				  tpctrato   : tpctrato,
				  nmdaval    : nmdaval,
				  tpdocav    : tpdocav,
				  dscpfav    : dscpfav,
				  nmcjgav    : nmcjgav,
				  cpfccg     : cpfccg,
				  tpdoccj    : tpdoccj,
				  dscfcav    : dscfcav,
				  nrfonres   : nrfonres,
				  nrcepend   : nrcepend,
				  dsendav1   : dsendav1,
				  nrendere   : nrendere,
				  complend   : complend,
				  nrcxapst   : nrcxapst,
				  dsendav2   : dsendav2,
				  dsdemail   : dsdemail,
				  nmcidade   : nmcidade,
				  cdufresd   : cdufresd,
				  nrregist   : nrregist,
				  nriniseq   : nriniseq,
				  redirect   : 'script_ajax'
				  
				  
				},
		error   : function(objAjax,responseError,objExcept) {
					hideMsgAguardo();
					showError('error','Não foi possível concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','');
				},
		success : function(response) { 
					hideMsgAguardo();
														
					if ( response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1 ) {
						try {
							exibeRotina($('#divRotina'));
							$('#divConteudo').html(response); 
							
						    formataTabela(); 
							return false;
						} catch(error) {
							hideMsgAguardo();
							showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','');
						}
					} else {
						try {  
							eval( response ); 
						} catch(error) {
							hideMsgAguardo();
							showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','');
						}
					}
					
				}
	}); 
}

function manterRotina() {
	
	showMsgAguardo('Aguarde efetuando operacao...');

	carregaDados();
				
	$.ajax({		
		type	: 'POST',
		dataType: 'html',
		url		: UrlSite + 'telas/'+nometela+'/manter_rotina.php', 
		data    :
				{ 
				  cddopcao   : cddopcao,	
				  pro_cpfcgc : pro_cpfcgc,	
				  nrctremp   : nrctremp,
				  nrdconta   : nrdconta,
				  tpctrato   : tpctrato,
				  dsendav1   : dsendav1,
				  dsendav2   : dsendav2,
				  nrendere   : nrendere,
				  nrfonres   : nrfonres,
				  complend   : complend,
				  nrcxapst   : nrcxapst,
				  dsdemail   : dsdemail,
				  nmcidade   : nmcidade,
				  cdufresd   : cdufresd,
				  nrcepend   : nrcepend,
				  redirect   : 'script_ajax'					  
				  
				},
		error   : function(objAjax,responseError,objExcept) {
					hideMsgAguardo();
					showError('error','Não foi possível concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','');
				},
		success : function(response) { 
					hideMsgAguardo();
					
					if ( response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1 ) {
						try {
							$('#divTabela').html(response);	
							return false;
						} catch(error) {
							hideMsgAguardo(); 
							showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','');
						}
					} else {
						try { 
							eval( response ); 
						} catch(error) {
							hideMsgAguardo();
							showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','');
						}
					}
					
				}
	});

}

	
function formataConsulta(){

	cTodosConsulta = $('input[type="text"],select','#divConsulta');
	
	rPro_cpfcgc   = $('label[for="pro_cpfcgc"]','#divConsulta');
	rNrctremp = $('label[for="nrctremp"]','#divConsulta');
	rNrdconta = $('label[for="nrdconta"]','#divConsulta');
	rTpctrato = $('label[for="tpctrato"]','#divConsulta');
	rNmdaval  = $('label[for="nmdaval"]','#divConsulta');
	rTpdocav  = $('label[for="tpdocav"]','#divConsulta');
	rDscpfav  = $('label[for="dscpfav"]','#divConsulta');
	rNmcjgav  = $('label[for="nmcjgav"]','#divConsulta');
	rCpfccg   = $('label[for="cpfccg"]','#divConsulta');
	rTpdoccj  = $('label[for="tpdoccj"]','#divConsulta');
	rDscfcav  = $('label[for="dscfcav"]','#divConsulta');
	rNrfonres = $('label[for="nrfonres"]','#divConsulta');
	rNrcepend = $('label[for="nrcepend"]','#divConsulta');
	rDsendav1 = $('label[for="dsendav1"]','#divConsulta');
	rNrendere = $('label[for="nrendere"]','#divConsulta');
	rComplend = $('label[for="complend"]','#divConsulta');
	rNrcxapst = $('label[for="nrcxapst"]','#divConsulta');
	rDsendav2 = $('label[for="dsendav2"]','#divConsulta');
	rDsdemail = $('label[for="dsdemail"]','#divConsulta');
	rNmcidade = $('label[for="nmcidade"]','#divConsulta');
	rCdufresd = $('label[for="cdufresd"]','#divConsulta');
	
		
	cPro_cpfcgc   = $('#pro_cpfcgc','#divConsulta');	
	cNrctremp = $('#nrctremp','#divConsulta');	
	cNrdconta = $('#nrdconta','#divConsulta');	
	cTpctrato = $('#tpctrato','#divConsulta');
	cNmdaval  = $('#nmdaval','#divConsulta');
	cTpdocav  = $('#tpdocav','#divConsulta');
	cDscpfav  = $('#dscpfav ','#divConsulta');
	cNmcjgav  = $('#nmcjgav','#divConsulta');
	cCpfccg   = $('#cpfccg','#divConsulta');
	cTpdoccj  = $('#tpdoccj','#divConsulta');
	cDscfcav  = $('#dscfcav ','#divConsulta');
	cNrfonres = $('#nrfonres','#divConsulta');
	cNrcepend = $('#nrcepend','#divConsulta');
	cDsendav1 = $('#dsendav1','#divConsulta');
	cNrendere = $('#nrendere','#divConsulta');
	cComplend = $('#complend','#divConsulta');
	cNrcxapst = $('#nrcxapst','#divConsulta');
	cDsendav2 = $('#dsendav2','#divConsulta');
	cDsdemail = $('#dsdemail','#divConsulta');
	cNmcidade = $('#nmcidade','#divConsulta');
	cCdufresd = $('#cdufresd','#divConsulta');
	cdImgLupa = $('#ImgLupa','#divConsulta');
	
	
	rPro_cpfcgc.css({'width':'80px'}).attr('maxlength','11');
	rNrctremp.css({'width':'265px'});
	rNrdconta.css({'width':'80px'});
	rTpctrato.css({'width':'250px'});
	rNmdaval.css({'width':'80px'});
	rTpdocav.css({'width':'80px'});
	rNmcjgav.css({'width':'80px'});
	rCpfccg.css({'width':'80px'});
	rTpdoccj.css({'width':'80px'});
	rNrfonres.css({'width':'80px'}).attr('maxlength','20');
	rNrcepend.css({'width':'155px'});
	rDsendav1.css({'width':'80px'}).attr('maxlength','40');
	rNrendere.css({'width':'80px'});
	rComplend.css({'width':'140px'}).attr('maxlength','40');
	rNrcxapst.css({'width':'80px'});
	rDsendav2.css({'width':'140px'});
	rDsdemail.css({'width':'80px'}).attr('maxlength','30');
	rNmcidade.css({'width':'80px'});
	rCdufresd.css({'width':'141px'});
	
	cPro_cpfcgc.css({'width':'115px'}).attr('maxlength','11');
	cNrctremp.css({'width':'100px'});
	cNrdconta.css({'width':'100px'}).addClass('conta');
	cTpctrato.css({'width':'150px'});
	cNmdaval.css({'width':'504px'});
	cTpdocav.css({'width':'40px'});
	cDscpfav .css({'width':'461px'});
	cNmcjgav.css({'width':'504px'});
	cCpfccg.css({'width':'115px'});
	cTpdoccj.css({'width':'40px'});
	cDscfcav .css({'width':'263px'});
	cNrfonres.css({'width':'223px'}).attr('maxlength','20');
	cNrcepend.css({'width':'100px'}).attr('maxlength','10');;
	cDsendav1.css({'width':'504px'}).attr('maxlength','40');
	cNrendere.css({'width':'90px'}).attr('maxlength','9');
	cComplend.css({'width':'271px'}).attr('maxlength','40');
	cNrcxapst.css({'width':'90px'}).attr('maxlength','5');
	cDsendav2.css({'width':'271px'});
	cDsdemail.css({'width':'504px'}).attr('maxlength','30');
	cNmcidade.css({'width':'320px'}).attr('maxlength','15');
	cCdufresd.css({'width':'40px'});
	cdImgLupa.css({'display':'none'});	
	
	cTodosConsulta.desabilitaCampo();
		
	layoutPadrao();
			
	cPro_cpfcgc.unbind('keypress').bind('keypress', function(e) {

		if ( divError.css('display') == 'block' ) { return false; }
				 
		// Se é a tecla ENTER
		if ( e.keyCode == 13) {

			btnContinuar();
			return false;
		}
		// Seta máscara ao campo
		return $(this).setMaskOnKeyUp("INTEGER","zzzzzzzzzzz","",e);
	});
	
	
	return false;
}

function mostraContrato() {
	
	showMsgAguardo('Aguarde, buscando ...');

	// Executa script de confirmação através de ajax
	$.ajax({		
		type: 'POST',
		dataType: 'html',
		url: UrlSite + 'telas/endava/contrato.php', 
		data: {
			redirect: 'html_ajax'			
			}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();			
			showError('error','Não foi possível concluir a requisição.','Alerta - Ayllos',"unblockBackground()");
		},
		success: function(response) {
				
			$('#divRotina').html(response);
			
			buscaEndava(1);
			return false;
		}				
	});
	
	return false;
	
}

function formataTabela() {

	var divRegistro = $('div.divRegistros','#divContrato');		
	var tabela      = $('table', divRegistro );
	var linha       = $('table > tbody > tr', divRegistro );
			
	divRegistro.css({'height':'250px','width':'365px'});
	
	var ordemInicial = new Array();
	// ordemInicial = [[1,0]];	
	
	var arrayLargura = new Array();
	arrayLargura[0] = '80px';
	arrayLargura[1] = '80px';
				
	var arrayAlinha = new Array();
	arrayAlinha[0] = 'right';
	arrayAlinha[1] = 'left';
	arrayAlinha[2] = 'left';
		
	var metodoTabela = 'selecionaContrato();';
			
	tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha, metodoTabela );
	
	hideMsgAguardo();
	bloqueiaFundo( $('#divRotina') );
	
	return false;
}

function selecionaContrato() {
	
	if ( $('table > tbody > tr', 'div.divRegistros').hasClass('corSelecao') ) {
					
		$('table > tbody > tr', 'div.divRegistros').each( function() {
			if ( $(this).hasClass('corSelecao') ) {
				cNrctremp.val( $('#nrctremp', $(this) ).val() );
				cNrdconta.val( $('#nrdconta', $(this) ).val() );
				cTpctrato.val( $('#tpctrato', $(this) ).val() );
				cNmdaval.val ( $('#nmdaval',  $(this) ).val() );
				cTpdocav.val ( $('#tpdocav',  $(this) ).val() );
				cDscpfav.val ( $('#dscpfav',  $(this) ).val() );
				cNmcjgav.val ( $('#nmcjgav',  $(this) ).val() );
				cCpfccg.val  ( $('#cpfccg',   $(this) ).val() );
				cTpdoccj.val ( $('#tpdoccj',  $(this) ).val() );
				cDscfcav.val ( $('#dscfcav',  $(this) ).val() );
				cNrfonres.val( $('#nrfonres', $(this) ).val() );
				cNrcepend.val( $('#nrcepend', $(this) ).val() );
				cDsendav1.val( $('#dsendav1', $(this) ).val() );
				cNrendere.val( $('#nrendere', $(this) ).val() );
				cComplend.val( $('#complend', $(this) ).val() );
				cNrcxapst.val( $('#nrcxapst', $(this) ).val() );
				cDsendav2.val( $('#dsendav2', $(this) ).val() );
				cDsdemail.val( $('#dsdemail', $(this) ).val() );
				cNmcidade.val( $('#nmcidade', $(this) ).val() );
				cCdufresd.val( $('#cdufresd', $(this) ).val() );
				
				
			}	
		});
	}
	
	
	if(cCddopcao.val() == "A"){
		
		cTodosConsulta.desabilitaCampo();
		
		cPro_cpfcgc.desabilitaCampo();
		
		cNrfonres.habilitaCampo();
		cNrcepend.habilitaCampo();
		cDsendav1.habilitaCampo();
		cNrendere.habilitaCampo();
		cComplend.habilitaCampo();
		cNrcxapst.habilitaCampo();
		cDsendav2.habilitaCampo();
		cDsdemail.habilitaCampo();
		cNmcidade.habilitaCampo();
		cCdufresd.habilitaCampo();
		cdImgLupa.css({'display':'block'});
		cNrfonres.focus();		
	}

	fechaRotina($('#divRotina'));
	return false;
	
}

function GerenciaPesquisa(opcao) {
	
	if( $('#cddopcao','#frmCab').hasClass('campoTelaSemBorda') ){
	
		if(opcao == 1) {
			mostraContrato();
		}
		return false;
	}
}


function controlaPesquisas() {

	// Definindo as variáveis
	var camposOrigem 	= 'nrcepend;dsendav1;nrendere;complend;nrcxapst;dsendav2;cdufresd;nmcidade;';

	var linkEndereco = $('a:eq(1)','#frmConsulta');		
	cNrfonres = $('#nrfonres','#frmConsulta');
	cNrcepend = $('#nrcepend','#frmConsulta');
	cDsendav1 = $('#dsendav1','#frmConsulta');
	cNrendere = $('#nrendere','#frmConsulta');
	cComplend = $('#complend','#frmConsulta');
	cNrcxapst = $('#nrcxapst','#frmConsulta');
	cDsendav2 = $('#dsendav2','#frmConsulta');
	cDsdemail = $('#dsdemail','#frmConsulta');
	cNmcidade = $('#nmcidade','#frmConsulta');
	cCdufresd = $('#cdufresd','#frmConsulta');
	cdImgLupa = $('#ImgLupa','#frmConsulta');
	
	
	
	linkEndereco.css('cursor','pointer');
	linkEndereco.prev().buscaCEP('frmConsulta', camposOrigem, $('#divTela'));
	//$("#nrcepend","#frmConsulta").focus();
	
	//Navegação entre os campos usando enter e tab
	cNrfonres.unbind('keypress').bind('keypress', function(e) { 
		if ( e.keyCode == 9 || e.keyCode == 13 ) {	
			cNrcepend.focus();
			return false;
		}	
	});		
	
	cNrcepend.bind("keyup",function(e) { 

	// Seta máscara ao campo
		if (!$(this).setMaskOnKeyUp("INTEGER","zzzzz-zzz","",e)) {
			return false;
		}
		//Tecla F7		
		if(e.keyCode == 118){ 
		   mostraPesquisaEndereco("frmConsulta", camposOrigem,  $('#divTela'))
		   return false;
		   
		}
			
	});
	
	cDsendav1.unbind('keypress').bind('keypress', function(e) { 
		if ( e.keyCode == 9 || e.keyCode == 13 ) {	
			cNrendere.focus();
			return false;
		}	
	});			
	
	cNrendere.unbind('keypress').bind('keypress', function(e) { 
		// Seta máscara ao campo
		if (!$(this).setMaskOnKeyUp("INTEGER","zzz.zzz.zz","",e)) {
			return false;
		}
		
		if ( e.keyCode == 9 || e.keyCode == 13 ) {	
			cComplend.focus();
			return false;
		}
			
	});
	
	cComplend.unbind('keypress').bind('keypress', function(e) { 
		if ( e.keyCode == 9 || e.keyCode == 13 ) {	
			cNrcxapst.focus();
			return false;
		}	
	});	

    
	
	cNrcxapst.unbind('keypress').bind('keypress', function(e) { 
		// Seta máscara ao campo
		if (!$(this).setMaskOnKeyUp("INTEGER","zz.zzz","",e)) {
			return false;
		}
		if ( e.keyCode == 9 || e.keyCode == 13 ) {	
			cDsendav2.focus();
			return false;
		}
		
			
	});		

	cDsendav2.unbind('keypress').bind('keypress', function(e) { 
		if ( e.keyCode == 9 || e.keyCode == 13 ) {	
			cDsdemail.focus();
			return false;
		}	
	});						

	cDsdemail.unbind('keypress').bind('keypress', function(e) { 
		if ( e.keyCode == 9 || e.keyCode == 13 ) {	
			cNmcidade.focus();
			return false;
		}	
	});							

	cNmcidade.unbind('keypress').bind('keypress', function(e) { 
		if ( e.keyCode == 9 || e.keyCode == 13 ) {	
			cCdufresd.focus();
			return false;
		}	
	});
	
	cCdufresd.unbind('keypress').bind('keypress', function(e) {
		if ( divError.css('display') == 'block' ) { return false; }
		
		// Se é a tecla ENTER
		if ( e.keyCode == 13) {
			btnContinuar();
			return false;
		}		
	});	
	
	
}