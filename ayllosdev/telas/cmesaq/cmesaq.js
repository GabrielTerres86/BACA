/*!
 * FONTE        : cmesaq.js
 * CRIAÇÃO      : Gabriel
 * DATA CRIAÇÃO : 16/11/2011
 * OBJETIVO     : Biblioteca de funções da tela CMESAQ
 * --------------
 * ALTERAÇÕES   : 22/02/2012 - Alterações para mostrar campo para 
 *			  				   informar conta (quando tipo 0). (Lucas)
 *
 * 				  28/06/2012 - Ajustado esquema de impressao em funcao imprimirDados() (Jorge). 
 *
 *                15/04/2013 - Padronização de novo layout (David Kruger).
 *
 *                05/09/2013 - Alteração da sigla PAC para PA (Carlos)
 *
 *				  27/06/2016 - Removido a classe inteiro do campo do operador para que
 *							   seja permitido letras no campo para ajustar o problema do		
 *							   do chamado 467402. (Kelvin)						
 *				  
 *				  18/04/2017 - Ajuste para que não seja possível informar caracteres especiais
 *							   SD 574441. (Kelvin)											  
 * --------------
 */

// Definição de algumas variáveis globais 
var operacao 		= ''; // Armazena a operação corrente da tela

//Formulários
var formCab   		= 'frmCab';
var formCab2		= 'frmCab2'
var formDados 		= 'frmCmesaq';
var flgimpri		= false;

//Labels/Campos do cabeçalho
var rOpcao, rData, rPac, rBcoCxa, rLote, rDocmto, rNrdconta, rTpdocmto, cCabecalho, cCabecalho2,  cOpcao, cData, cPac, cBcoCxa, cLote, cDocmto, cNrdconta, cTpdocmto;

//Labels/Campos do formulário de dados
var rSeq, rLanmto, rDConta,
    cSeq, cLanmto, cDConta,
	
	rConta, rNome, rCnpj, rNrIde, rNasc, rEndereco, rCidade, rCep, rUf, rInfo, rDestino , rDsdopera , rVlretesp , 
	cConta, cNome, cCnpj, cNrIde, cNasc, cEndereco, cCidade, cCep, cUf, cInfo, cDestino , cDsdopera , cVlretesp , cVlmincen ;
	

$(document).ready(function() {    
    
	highlightObjFocus( $('#'+formCab) );
	highlightObjFocus( $('#'+formCab2) );
	highlightObjFocus( $('#'+formDados) );
	estadoInicial();			
});


function estadoInicial() {

	$('#divTela').fadeTo(0,0.1);

	fechaRotina($('#divRotina'));
	setGlobais();
 
 	$('input', '#'+ formCab ).limpaFormulario();
	$('input', '#'+ formCab2 ).limpaFormulario();
	$('input', '#'+ formDados ).limpaFormulario();	
	
	$('#'+formCab2).css('display','none');	
    	
	atualizaSeletor();	
	formataCabecalho();
	controlaLayout();

	$('input, select','#'+ formCab ).removeClass('campoErro');
	$('input, select','#'+ formCab2 ).removeClass('campoErro');
	$('input, select','#'+ formDados ).removeClass('campoErro');

	cOpcao.val('I1');	
	cData.focus();
		
	removeOpacidade('divTela');
	return false;
}

function estadoCabecalho() {

	hideMsgAguardo();
	$('#divTela').fadeTo(0,0.1);

	fechaRotina($('#divRotina'));
	setGlobais();
	
	$('input, select', '#'+formCab).habilitaCampo();
	$('input', '#'+formDados).desabilitaCampo().limpaFormulario();

	cOpcao.focus();

	removeOpacidade('divTela');
	return false;
}


// controle de seletores
function atualizaSeletor(){

	rOpcao    = $('label[for="cddopcao"]','#'+formCab);
	rData     = $('label[for="dtdepesq"]','#'+formCab);
	rTpdocmto = $('label[for="tpdocmto"]','#'+formCab);
	
	rPac      = $('label[for="cdagenci"]','#'+formCab2);	
	rBcoCxa   = $('label[for="cdbccxlt"]','#'+formCab2);
	rLote     = $('label[for="nrdolote"]','#'+formCab2);
	rDocmto   = $('label[for="nrdocmto"]','#'+formCab2);
	rNrdconta = $('label[for="nrdconta"]','#'+formCab2);
	rNrdCaixa = $('label[for="nrdcaixa"]','#'+formCab2);
	rCdOpeCxa = $('label[for="cdopecxa"]','#'+formCab2);
	

	cCabecalho  = $('input[type="text"],select','#'+formCab);
	cCabecalho2 = $('input[type="text"],select','#'+formCab2);

	cOpcao    = $('#cddopcao','#'+formCab);
	cData     = $('#dtdepesq','#'+formCab);
	cTpdocmto = $('#tpdocmto','#'+formCab);
	
	cPac      = $('#cdagenci','#'+formCab2);
	cBcoCxa   = $('#cdbccxlt','#'+formCab2);
	cLote     = $('#nrdolote','#'+formCab2);
	cDocmto   = $('#nrdocmto','#'+formCab2);
	cNrdconta = $('#nrdconta','#'+formCab2);
	cNrdCaixa = $('#nrdcaixa','#'+formCab2);
	cCdOpeCxa = $('#cdopecxa','#'+formCab2);
	
	
	rSeq          = $('label[for="nrseqaut"]','#'+formDados);
	rLanmto       = $('label[for="vllanmto"]','#'+formDados);
	rDConta       = $('label[for="dsdconta"]','#'+formDados);
	
	rConta    = $('label[for="nrccdrcb"]','#'+formDados);
	rNome     = $('label[for="nmpesrcb"]','#'+formDados);
	rCnpj     = $('label[for="cpfcgrcb"]','#'+formDados);
	rNrIde    = $('label[for="nridercb"]','#'+formDados);
	rNasc     = $('label[for="dtnasrcb"]','#'+formDados);
	rEndereco = $('label[for="desenrcb"]','#'+formDados);
	rCidade   = $('label[for="nmcidrcb"]','#'+formDados);
	rCep      = $('label[for="nrceprcb"]','#'+formDados);
	rUf       = $('label[for="cdufdrcb"]','#'+formDados);
	rInfo     = $('label[for="flinfdst"]','#'+formDados);
	rDestino  = $('label[for="dstrecur"]','#'+formDados);
	rDsdopera = $('label[for="dsdopera"]','#'+formDados);
	rVlretesp = $('label[for="vlretesp"]','#'+formDados);

	cTodos_1      = $('input[type="text"],select','#'+formDados);

	cSeq          = $('#nrseqaut','#'+formDados);
	cLanmto       = $('#vllanmto','#'+formDados);
	cDConta       = $('#dsdconta','#'+formDados);
	
	cConta    = $('#nrccdrcb','#'+formDados);
	cNome     = $('#nmpesrcb','#'+formDados);
	cCnpj     = $('#cpfcgrcb','#'+formDados);
	cNrIde    = $('#nridercb','#'+formDados);
	cNasc     = $('#dtnasrcb','#'+formDados);
	cEndereco = $('#desenrcb','#'+formDados);
	cCidade   = $('#nmcidrcb','#'+formDados);
	cCep      = $('#nrceprcb','#'+formDados);
	cUf       = $('#cdufdrcb','#'+formDados);
	cInfo     = $('#flinfdst','#'+formDados);
	cDestino  = $('#dstrecur','#'+formDados);
	cDsdopera = $('#dsdopera','#'+formDados);
	cVlretesp = $('#vlretesp','#'+formDados);
	cVlmincen = $('#vlmincen','#'+formDados);

	return false;
}

function controlaOperacao(op) {

	operacao = op;
	
	if (operacao == 'C1' || operacao == 'A1' || operacao == 'A2' || operacao == 'I1' || operacao == 'I2')   {
		manterRotina(); 
	}
	else
	if (operacao == 'A21' || operacao == 'I21') {
		controlaLayout(); 
	}	
	else
	if (operacao == 'A3' || operacao == 'I3' ) {
		
		var nmpesrcb = cNome.val();
		var cpfcgrcb = normalizaNumero(cCnpj.val());
		var nridercb = cNrIde.val();
		var dtnasrcb = cNasc.val();
		var desenrcb = cEndereco.val();
		var nmcidrcb = cCidade.val();
		var nrceprcb = normalizaNumero(cCep.val());
		var cdufdrcb = cUf.val();
		
		setGlobais();
		
		// Verifica se foi informado
		if ( nmpesrcb == "" ) { 
			showError('error','Informe o nome.','Alerta - Ayllos','focaCampoErro(\'nmpesrcb\',\''+ formDados +'\');'); 
			return false; 
		}

		// Verifica se foi informado
		if ( cpfcgrcb == "" ) { 
			showError('error','Informe o CPF/CNPJ.','Alerta - Ayllos','focaCampoErro(\'cpfcgrcb\',\''+ formDados +'\');'); 
			return false; 
		}
								
		if ( nridercb == "") { 
			showError('error','Campo deve ser informado.','Alerta - Ayllos','focaCampoErro(\'nridercb\',\''+ formDados +'\');'); 
			return false; 
		}
		
		if ( dtnasrcb == "" ) {
			showError('error','Data de nascimento deve ser informada.','Alerta - Ayllos','focaCampoErro(\'dtnasrcb\',\''+ formDados +'\');'); 
			return false; 
		}
			
		// Verifica se foi informado
		if ( desenrcb == "" ) { 
			showError('error','Informe o endereço.','Alerta - Ayllos','focaCampoErro(\'desenrcb\',\''+ formDados +'\');'); 
			return false; 
		}
		
		// Verifica se foi informado
		if ( nmcidrcb == "" ) { 
			showError('error','Informe a cidade.','Alerta - Ayllos','focaCampoErro(\'nmcidrcb\',\''+ formDados +'\');'); 
			return false; 
		}
					
		// Verifica se foi informado
		if ( nrceprcb == "" ) { 
			showError('error','Informe o CEP.','Alerta - Ayllos','focaCampoErro(\'nrceprcb\',\''+ formDados +'\');'); 
			return false; 
		}

		// Verifica se foi informado
		if ( cdufdrcb == "" ) { 
			showError('error','Informe a UF.','Alerta - Ayllos','focaCampoErro(\'cdufdrcb\',\''+ formDados +'\');'); 
			return false; 
		}
		
		//na opcao dstrecur
		if (cInfo.val() == "no" ) {
		    cDestino.val('');
		} 
					
		if (cDestino.hasClass('campo') && (cDestino.val() == "")) { 
			showError('error','Campo deve ser preenchido.','Alerta - Ayllos','focaCampoErro(\'dstrecur\',\''+ formDados +'\');'); 
			return false;
		}
		
		if (cDsdopera.hasClass('campo') && cDsdopera.val() == "") {
			showError('error','Selecione uma op&ccedil;&atilde;o.','Alerta - Ayllos','focaCampoErro(\'dsdopera\',\''+ formDados +'\');'); 
			return false;
		}
		
		if ( parseFloat(cVlretesp.val().replace(/\./g,"") ) > parseFloat(cLanmto.val().replace(/\./g,"") ) ) {
			showError('error','Valor digitado n&atilde;o pode ser maior que o lan&ccedil;amento','Alerta - Ayllos','focaCampoErro(\'vlretesp\',\''+ formDados +'\');'); 
			return false;
		}
	
		manterRotina();
	} 
	else
	if (operacao == 'A4' || operacao == 'I4' ) {
		
		if (cDestino.hasClass('campo') && (cDestino.val() == "")) { 
			showError('error','Campo deve ser preenchido.','Alerta - Ayllos','focaCampoErro(\'dstrecur\',\''+ formDados +'\');'); 
			return false;
		}
		
		if (cDsdopera.hasClass('campo') && cDsdopera.val() == "") {
			showError('error','Selecione uma op&ccedil;&atilde;o.','Alerta - Ayllos','focaCampoErro(\'dsdopera\',\''+ formDados +'\');'); 
			return false;
		}			
		
		if ( parseFloat(cVlretesp.val().replace(/\./g,"") ) > parseFloat(cLanmto.val().replace(/\./g,"") ) ) {
			showError('error','Valor digitado n&atilde;o pode ser maior que o lan&ccedil;amento','Alerta - Ayllos','focaCampoErro(\'vlretesp\',\''+ formDados +'\');'); 
			return false;
		}
		
		setGlobais();
		
		showConfirmacao('Confirmar Opera&ccedil;&atilde;o?','Confirma&ccedil;&atilde;o - Ayllos','confirmaImpressao();','cInfo.focus()','sim.gif','nao.gif');	
		
	}
	return false;
}

function confirmaImpressao () {

  	showConfirmacao('Deseja imprimir o DOCUMENTO?','Confirma&ccedil;&atilde;o - Ayllos','flgimpri=true; manterRotina();','flgimpri=false; manterRotina();','sim.gif','nao.gif');
	
}

function manterRotina() {

	hideMsgAguardo();		
	
	var mensagem = '';
	
	// Cabecalho
	var dtdepesq = cData.val();
	var cdagenci = normalizaNumero( cPac.val() 		);
	var cdbccxlt = normalizaNumero( cBcoCxa.val()	);
	var nrdolote = normalizaNumero( cLote.val()		);
	var nrdocmto = normalizaNumero( cDocmto.val()	);
	var nrdconta = cNrdconta.val();
	var tpdocmto = normalizaNumero( cTpdocmto.val() ); 
	var nrdcaixa = normalizaNumero( cNrdCaixa.val() );
	var cdopecxa = cCdOpeCxa.val();

	var nrccdrcb = normalizaNumero(cConta.val());
	var nmpesrcb = cNome.val();
	var nridercb = cNrIde.val();
	var dtnasrcb = cNasc.val();
	var desenrcb = cEndereco.val();
	var nmcidrcb = cCidade.val();
	var nrceprcb = normalizaNumero(cCep.val());
	var cdufdrcb = cUf.val();
	var flinfdst = (cInfo.val() != null) ? cInfo.val() : '';
	var dstrecur = cDestino.val();
	var cpfcgrcb = normalizaNumero(cCnpj.val());	
	var tpoperac = operacao.substring(1);
	var vlretesp = normalizaNumero ( cVlretesp.val() );
		
	switch (tpoperac) {
		case '1': mensagem = 'Aguarde, consultando os dados do lan&ccedil;amento ...'; break;
		case '2': mensagem = 'Aguarde, consultando os dados do cooperado ...'; break;
		case '3': mensagem = 'Aguarde, validando os dados ...'; break;
		case '4': mensagem = 'Aguarde, alterando os dados ...'; break;		
		default	  : return false; break;
	}
				
			
	
	showMsgAguardo( mensagem );	
	
	$.ajax({		
			type  : 'POST',
			async : true ,
			url   : UrlSite + 'telas/cmesaq/manter_rotina.php', 		
			data: {
				operacao	: operacao,		
				
				// Cabecalho
				dtdepesq : dtdepesq,
				cdagenci : cdagenci,
				cdbccxlt : cdbccxlt,
				nrdolote : nrdolote,
				nrdocmto : nrdocmto,	
				tpdocmto : tpdocmto,
				nrdconta : nrdconta,
				nrccdrcb : nrccdrcb, 
				nmpesrcb : removeCaracteresInvalidos(nmpesrcb), 
				nridercb : nridercb, 
				dtnasrcb : dtnasrcb, 
				desenrcb : removeCaracteresInvalidos(desenrcb), 
				nmcidrcb : removeCaracteresInvalidos(nmcidrcb), 
				nrceprcb : nrceprcb, 
				cdufdrcb : cdufdrcb, 
				flinfdst : flinfdst, 
				dstrecur : removeCaracteresInvalidos(dstrecur), 
				cpfcgrcb : cpfcgrcb, 
				flgimpri : flgimpri,
				vlretesp : vlretesp,
				nrdcaixa : nrdcaixa,
				cdopecxa : cdopecxa,
				nrdconta : nrdconta,
				
				redirect : 'script_ajax'
			}, 
			error: function(objAjax,responseError,objExcept) {
				hideMsgAguardo();
				showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','unblockBackground()');
			},
			success: function(response) {
				try {
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

function imprimirDados (nmarqpdf, flgimpre) {
	
	$('#sidlogin','#frmCmesaq').remove();			
	$('#flgimpre','#frmCmesaq').remove();
	
	$('#frmCmesaq').append('<input type="hidden" id="sidlogin" name="sidlogin" value="' + $('#sidlogin','#frmMenu').val() + '" />');	
	$('#frmCmesaq').append('<input type="hidden" id="flgimpre" name="flgimpre" value="' + flgimpre + '" />');	

	$("#nmarqpdf","#frmCmesaq").val(nmarqpdf);
	
	var action = UrlSite + 'telas/cmesaq/imprimir_dados.php';		
	
	if (flgimpre == "yes") {
		carregaImpressaoAyllos("frmCmesaq",action);
	} else {						
		// Configuro o formulário para posteriormente submete-lo
		$('#frmCmesaq').attr('method','post');
		$('#frmCmesaq').attr('action',action);
		$('#frmCmesaq').attr("target","frameBlank");
		$('#frmCmesaq').submit();				
	}
	
	return false;
	
}    	

function controlaLayout() { 

	$('fieldset').css({'clear':'both','border':'1px solid #777','margin':'3px 0px','padding':'10px 3px 5px 3px'});
	$('fieldset > legend').css({'font-size':'11px','color':'#777','margin-left':'5px','padding':'0px 2px'});
	$('#divBotoes').css({'text-align':'center','padding-top':'5px'});
	
	$('#frmCab2 > fieldset').css('padding-left','80px');
	
	rSeq.addClass('rotulo').css('width','30px');
	rLanmto.css('width','40px');
	rDConta.css('width','60px');
	rDsdopera.addClass('rotulo').css('width','145px');

	rConta.addClass('rotulo').css('width','57px');
	rNome.addClass('rotulo-linha').css('width','40px');
	rCnpj.addClass('rotulo-linha').css('width','57px');
	rNrIde.addClass('rotulo-linha').css('width','45px');
	rNasc.addClass('rotulo-linha').css('width','30px'); 
	rEndereco.addClass('rotulo').css('width','57px');
	rCidade.addClass('rotulo').css('width','57px');
	rCep.addClass('rotulo-linha').css('width','35px');
	rUf.addClass('rotulo-linha').css('width','30px');
	rInfo.addClass('rotulo').css('width','225px');
	rDestino.addClass('rotulo').css('width','57px');
	rVlretesp.css('width','55px');
	
	rDocmto.css('width','50px');
	rNrdconta.css('width','50px');
	rNrdCaixa.css('width','40px');
	rCdOpeCxa.css('width','60px');
	
	
	cSeq.addClass('inteiro').css('width','45px');
	cLanmto.addClass('decimal').css('width','80px');
	cDConta.css('width','270px');
	
	cConta.addClass('conta pesquisa').css('width','70px');
	cNome.css('width','338px');
	cCnpj.css('width','110px');
	cNrIde.css('width','100px');
	cNasc.addClass('data').css('width','64px');
	cEndereco.css('width','472px');
	cCidade.css('width','247px');
	cCep.addClass('cep').css('width','100px');
	cUf.css('width','50px');
	cInfo.css('width','60px');
	cDestino.css({'width':'468px','maxlength':'60'});	
	cDsdopera.css('width','85px');	
	cVlretesp.addClass('decimal').css('width','80px');
	cVlretesp.setMask("DECIMAL","zzz.zzz.zz9,99");
	
	if ( $('#dvtipdoc0').css('display') == 'block' ){
		$('#frmCab2 > fieldset').css('padding-left','25px');			   
	} else {
		$('#frmCab2 > fieldset').css('padding-left','80px');
	}


	cTodos_1.desabilitaCampo();    

	switch (operacao) {

		case 'A1':  cConta.habilitaCampo().focus(); 
					cCabecalho.desabilitaCampo(); 
					operacao = 'A2';
					break;
		case 'A2':  
					cConta.desabilitaCampo(); 
					if  ( parseFloat(cLanmto.val().replace(/\./g,"")) >= parseFloat(cVlmincen.val().replace(/\./g,"")) )  {
						cDsdopera.habilitaCampo().change().focus().val("");
					}
					cInfo.habilitaCampo().change();						
					operacao = 'A4';
					break;			
		case 'A21': cConta.desabilitaCampo(); 
					cCnpj.habilitaCampo();
					cNrIde.habilitaCampo();
					cNasc.habilitaCampo();
					cEndereco.habilitaCampo();
					cCidade.habilitaCampo();
					cCep.habilitaCampo();
					cUf.habilitaCampo();
		            cInfo.habilitaCampo().change();
					if  ( parseFloat(cLanmto.val().replace(/\./g,"")) >= parseFloat(cVlmincen.val().replace(/\./g,"")) )  {
						cDsdopera.habilitaCampo().change().val("");
					}		
					cNome.habilitaCampo().focus();
					operacao = 'A3';
					break;						
		case 'A3':  if (cInfo.val() == "no") {
						cInfo.habilitaCampo();
						controlaOperacao("A4");
						return false;
					}else {
						cInfo.desabilitaCampo();
						cDestino.habilitaCampo().focus();
						operacao = 'A4';
					}
					break;				
		case 'A4':	controlaOperacao("A4"); break;
		
		case 'I1':  cConta.habilitaCampo().focus(); 
					cCabecalho.desabilitaCampo(); 
					operacao = 'I2';
					break;
					
		case 'I2':  cConta.desabilitaCampo(); 
					if  ( parseFloat(cLanmto.val().replace(/\./g,"")) >= parseFloat(cVlmincen.val().replace(/\./g,"")) )  {
						cDsdopera.habilitaCampo().change().focus().val("");
					}
					cInfo.habilitaCampo().change();					
					operacao = 'I3';
					break;	
		case 'I21': cConta.desabilitaCampo(); 
					cCnpj.habilitaCampo();
					cNrIde.habilitaCampo();
					cNasc.habilitaCampo();
					cEndereco.habilitaCampo();
					cCidade.habilitaCampo();
					cCep.habilitaCampo();
					cUf.habilitaCampo();			
		            cInfo.habilitaCampo().change();
					if  ( parseFloat(cLanmto.val().replace(/\./g,"")) >= parseFloat(cVlmincen.val().replace(/\./g,"")) )  {
						cDsdopera.habilitaCampo().change().val("");
					}
					cNome.habilitaCampo().focus();
					operacao = 'I3';
					break;						
		case 'I3':  if (cInfo.val() == "no") {
						cInfo.habilitaCampo();
						controlaOperacao("I4");
						return false;
					}else{
						cInfo.desabilitaCampo();
						cDestino.habilitaCampo().focus();
						operacao = 'I4';
					}
					break;		
		case 'I4':	controlaOperacao("I4"); break;
												
		case 'voltar':	
						$('#'+formDados).limpaFormulario();
						$('#'+formCab2).limpaFormulario();
						$('#'+formCab2).css('display','none');
						
						$('input','#'+formCab).habilitaCampo();
			            $('select','#'+formCab).habilitaCampo();
												
						cCabecalho.habilitaCampo();
						
						$("input,select","#" + formDados).removeClass("campoErro");
						
						cTpdocmto.val("5");
						
						cData.focus();
						
						operacao = '';
						break;
		default: break;		
		}	
	
	layoutPadrao();
	controlaPesquisas();

	return false;
	
}

function formataCabecalho() {
	
	rOpcao.addClass('rotulo').css('width','50px');
	rData.addClass('rotulo').css('width','50px');
	rTpdocmto.addClass('rotulo-linha').css('width','100px');
	
	rPac.addClass('rotulo-linha');
	rBcoCxa.addClass('rotulo-linha');
	rLote.addClass('rotulo-linha');
	rDocmto.addClass('rotulo-linha');
	rNrdconta.addClass('rotulo-linha');	
	
	cOpcao.css('width','477px');
	cData.addClass('campo data').css('width','100px');
	cTpdocmto.addClass('campo').css('width','150px');
	
	cPac.addClass('campo inteiro').css('width','35px');
	cBcoCxa.addClass('campo inteiro').css('width','35px');
	cLote.addClass('campo inteiro').css('width','60px');
	cDocmto.addClass('campo inteiro').css('width','70px');
	cNrdconta.addClass('campo inteiro').css('width','70px');
	
	cNrdCaixa.addClass('campo inteiro').css('width','50px');
	cCdOpeCxa.addClass('campo').css('width','65px');
	
	
	cPac.setMask("INTEGER","zz9","");
	cLote.setMask("INTEGER","zzz.zz9",".");
	cBcoCxa.setMask("INTEGER","zz9","");
	cDocmto.setMask("INTEGER","zz.zzz.zz9",".");
	cNrdconta.setMask("INTEGER","zzzz.zz9.9",".");
	
	cOpcao.habilitaCampo().focus();	
	
	$('input, select','#'+ formCab2 ).unbind('keypress').bind('keypress', function(e) { 	
		
		if ( divError.css('display') == 'block' ) { return false; }		
			
		// Se é a tecla ENTER, valida os dados e realiza a busca
		if ( e.keyCode == 13 || e.keyCode == 112 ) {		
			// trata as variaveis
			setGlobais();			

			var cdagenci 	= cPac.val();
			var nrdolote 	= cLote.val();
			var cdbccxlt 	= normalizaNumero(cBcoCxa.val());
			var nrdocmto 	= normalizaNumero(cDocmto.val());
			var nrdconta 	= cNrdconta.val();
			var nrdcaixa	= normalizaNumero(cNrdCaixa.val());
			var cdopecxa	= cCdOpeCxa.val();
			
			
			// Verifica se foi informado
			if ( cdagenci == 0 ) { 
				showError('error','Informe o PA.','Alerta - Ayllos','focaCampoErro(\'cdagenci\',\''+ formCab2 +'\');'); 
				return false; 
			}		

			if ( $('#dvtipdoc1').css('display') == 'block' ) {		
			
				// Verifica se foi informado
				if ( cdbccxlt == 0 ) { 
					showError('error','Informe o banco/caixa.','Alerta - Ayllos','focaCampoErro(\'cdbccxlt\',\''+ formCab2 +'\');'); 
					return false; 
				}

				// Verifica se foi informado
				if ( nrdolote == 0 ) { 
					showError('error','Informe o lote.','Alerta - Ayllos','focaCampoErro(\'nrdolote\',\''+ formCab2 +'\');'); 
					return false; 
				}

			} else {
				// Verifica se foi informado
				if ( nrdcaixa == 0 ) {
					showError('error','Informe o caixa.','Alerta - Ayllos','focaCampoErro(\'nrdcaixa\',\''+ formCab2 +'\');'); 
					return false; 				
				}
				
				// Verifica se foi informado
				if ( cdopecxa == 0 ) {
					showError('error','Informe o operador.','Alerta - Ayllos','focaCampoErro(\'cdopecxa\',\''+ formCab2 +'\');'); 
					return false; 				
				}
				
			}
			
			// Verifica se foi informado
			if ( nrdocmto == 0 ) { 
				showError('error','Informe o número do documento.','Alerta - Ayllos','focaCampoErro(\'nrdocmto\',\''+ formCab2 +'\');'); 
				return false; 
			}	

			if ( nrdconta == 0  &&  ($('#dvtipdoc0').css('display') == 'block')) {  
				showError('error','Informe o número da Conta.','Alerta - Ayllos','focaCampoErro(\'nrdconta\',\''+ formCab2 +'\');'); 
				return false; 
			}				
		
            // Se chegou até aqui, está tudo ok e então realiza a operação desejada
			controlaOperacao(cOpcao.val());
			return false;		
		}
		
	});

	// Se pressionar alguma tecla nos campos do cabecalho, verificar a tecla pressionada e toda a devida ação
	$('#tpdocmto','#'+ formCab ).unbind('change').bind('change', function(e) { 	
		
		if ( divError.css('display') == 'block' ) { return false; }					

			// trata as variaveis
			setGlobais();			
			
			var dtdepesq 	= cData.val();
			var tpdocmto    = normalizaNumero(cTpdocmto.val());									
				
			//$('#cdagenci').focus();	
			
			// Verifica se foi informado
			if ( dtdepesq == "" ) { 
				showError('error','Informe a data.','Alerta - Ayllos','focaCampoErro(\'dtdepesq\',\''+ formCab +'\');'); 				
				return false; 
			}			
			
			if ( tpdocmto == 5 ) {
				showError('error','Selecione um tipo de documento.','Alerta - Ayllos','focaCampoErro(\'tpdocmto\',\''+ formCab +'\');'); 				
				return false; 			
			} 
			  
			$("input, select","#" + formCab).removeClass("campoErro");	
			
			$('#'+formCab2).css('display','block');					
			
			if ( tpdocmto == 4 ) {			    
			   $('#dvtipdoc1').css('display','none'); 
			   $('#dvtipdoc2').css('display','block');
			   $('#dvtipdoc0').css('display','none'); 				   
			}
			
			else if ( tpdocmto == 0 )  {			   			   
			   $('#dvtipdoc1').css('display','block'); 
			   $('#dvtipdoc2').css('display','none'); 
			   $('#dvtipdoc0').css('display','block'); 	
			}
			else {
			   $('#dvtipdoc1').css('display','block'); 
			   $('#dvtipdoc2').css('display','none'); 	
			   $('#dvtipdoc0').css('display','none'); 	
			}
			
			if ( $('#dvtipdoc0').css('display') == 'block' ){
				 $('#frmCab2 > fieldset').css('padding-left','25px');			   
			} else {
				 $('#frmCab2 > fieldset').css('padding-left','80px');
			}

			$('#cdagenci').focus();
			
			
			$('input','#'+formCab).desabilitaCampo();
			$('select','#'+formCab).desabilitaCampo();

			return false;	
		
	});	
	
	// Se pressionar alguma tecla no campo da conta, verificar a tecla pressionada e toda a devida ação
	$('#nrccdrcb','#'+ formDados ).unbind('keypress').bind('keypress', function(e) { 	
		
		if ( divError.css('display') == 'block' ) { return false; }		
			
		// Se é a tecla ENTER, valida os dados e realiza a busca
		if ( e.keyCode == 13 || e.keyCode == 112 ) {		

		    // Transformar em numerico
			var conta = number_format(retiraCaracteres($(this).val(),"0123456789",true),0, ",",".");
			
			// trata as variaveis
			setGlobais();
			
			// Verifica se foi informado
			if (conta == 0) {
				operacao = (operacao == "A2") ? "A21" : "I21";				
			}
			
			// Se chegou até aqui, está tudo ok e então realiza a operação desejada
			controlaOperacao(operacao);
			return false;
		} 

	});	
	
	// Se pressionar alguma tecla no campo UF, verificar a tecla pressionada e toda a devida ação
	$('#cdufdrcb','#'+ formDados ).unbind('keypress').bind('keypress', function(e) { 	

		if ( divError.css('display') == 'block' ) { return false; }		

		// Se é a tecla ENTER, valida os dados e realiza a busca
		if ( e.keyCode == 13 || e.keyCode == 112 ) {		
				
			// trata as variaveis
			setGlobais();
				
			// Se chegou até aqui, está tudo ok e então realiza a operação desejada
			controlaOperacao(operacao);
			return false;
		} 

	});	
	
	// Se pressionar alguma tecla nos campos do cabecalho, verificar a tecla pressionada e toda a devida ação
	$('#dstrecur','#'+ formDados ).unbind('keypress').bind('keypress', function(e) { 	
		
		if ( divError.css('display') == 'block' ) { return false; }		
			
		// Se é a tecla ENTER, valida os dados e realiza a operacao
		if ( e.keyCode == 13 || e.keyCode == 112 ) {		

			// trata as variaveis
			setGlobais();
			
			// Verifica se foi informado
			if ( $(this).val() == "" ) { 
				showError('errorcontrolaLayout','Campo deve ser preenchido.','Alerta - Ayllos','focaCampoErro(\'dstrecur\',\''+ formDados +'\');'); 
				return false; 
			}

			// Se chegou até aqui, está tudo ok e então realiza a operação desejada
			controlaOperacao(operacao);
			return false;
		} 

	});

	// Quando alterar o item selecionado no campo Informações
	$('#flinfdst','#'+ formDados ).unbind('change').bind('change', function(e) { 	
		if ( $(this).val() == "yes" ) {
			$('#dstrecur','#'+ formDados ).habilitaCampo();
			$('#dstrecur','#'+ formDados ).focus();
		}else{
			$('#dstrecur','#'+ formDados ).val("");	
			$('#dstrecur','#'+ formDados ).desabilitaCampo();				
		}
		return false;
	});		
	
	// Quando alterar o item selecionado no campo Valor sendo levado
	$('#dsdopera','#'+ formDados ).unbind('change').bind('change', function(e) { 	
		if ( $(this).val() == "T" ) { // Total	
			$('#vlretesp','#'+ formDados ).val( cLanmto.val() );	
			$('#vlretesp','#'+ formDados ).desabilitaCampo();
		}else{						  // Parcial
			$('#vlretesp','#'+ formDados ).habilitaCampo();
			$('#vlretesp','#'+ formDados ).focus();
		}
		return false;
	});

	layoutPadrao();
	controlaPesquisas();

	return false;
}

function controlaPesquisas() {

	/*---------------------*/
	/*  CONTROLE CONTA/DV  */
	/*---------------------*/
	var linkConta = $('a:eq(0)','#'+ formDados );

	if ( linkConta.prev().hasClass('campoTelaSemBorda') ) {		
		linkConta.addClass('lupa').css('cursor','auto').unbind('click').bind('click', function() { return false; });
	} else {

		linkConta.prev().unbind('blur').bind('blur', function() { 
			controlaPesquisas();
			return false;
		});	
	
		linkConta.css('cursor','pointer').unbind('click').bind('click', function() {			
			mostraPesquisaAssociado('nrccdrcb', formDados );
		});
	}

	return false;
}

// botao
function btnVoltar(op) {	
	operacao = op;	
	
	controlaLayout();	
	controlaPesquisas();
	return false;
}

function btnConcluir() {
	
	controlaOperacao(operacao);
	return false;
	
}

// variaveis globais
function setGlobais() {
	
	// tira borda do erro
	$("input","#" + formCab).removeClass("campoErro");
	// tira borda do erro
	$("input , select","#" + formDados).removeClass("campoErro");
	// tira borda do erro
	$("input , select","#" + formCab2).removeClass("campoErro");
	// tira borda do erro
	$("#cdufdrcb","#" + formDados).removeClass("campoErro");

	return false;
}
