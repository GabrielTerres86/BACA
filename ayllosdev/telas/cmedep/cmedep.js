/*!
 * FONTE        : cmedep.js
 * CRIAÇÃO      : Guilherme
 * DATA CRIAÇÃO : 19/07/2011
 * OBJETIVO     : Biblioteca de funções da tela CMEDEP
 * --------------
 * ALTERAÇÕES   :
 * 28/06/2012 - Jorge        (CECRED) : Ajuste de esquema de impressao em  funcao imprimirDados()
 * 19/07/2012 - Jorge        (CECRED) : Ajustes para informar nrdconta no cabeçalho.
 * --------------
 */

// Definição de algumas variáveis globais 
var operacao 		= ''; // Armazena a operação corrente da tela

//Formulários
var formCab   		= 'frmCab';
var formDados 		= 'frmCmedep';
var flgimpri		= false;

//Labels/Campos do cabeçalho
var rOpcao, rData, rPac, rBcoCxa, rLote, rDocmto, rCabCnt; 
var cCabecalho, cOpcao, cData, cPac, cBcoCxa, cLote, cDocmto, cCabCnt;

//Labels/Campos do formulário de dados
var rSeq, rLanmto, rDConta,
    cSeq, cLanmto, cDConta,
	
	rConta, rNome, rCnpj, rNrIde, rNasc, rEndereco, rCidade, rCep, rUf, rInfo, rRecursos,
	cConta, cNome, cCnpj, cNrIde, cNasc, cEndereco, cCidade, cCep, cUf, cInfo, cRecursos;
	

$(document).ready(function() {
	estadoInicial()	
});


function estadoInicial() {

	$('#divTela').fadeTo(0,0.1);

	fechaRotina($('#divRotina'));
	setGlobais();
 
 	$('input', '#'+ formCab ).limpaFormulario();
	$('input', '#'+ formDados ).limpaFormulario();
	 
	atualizaSeletor();	
	formataCabecalho();
	controlaLayout();

	$('input, select','#'+ formCab ).removeClass('campoErro');
	$('input, select','#'+ formDados ).removeClass('campoErro');

	cOpcao.val('I1');

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

	rOpcao   = $('label[for="cddopcao"]','#'+formCab);
	rData    = $('label[for="dtdepesq"]','#'+formCab);
	rPac     = $('label[for="cdagenci"]','#'+formCab);
	rBcoCxa  = $('label[for="cdbccxlt"]','#'+formCab);
	rLote    = $('label[for="nrdolote"]','#'+formCab);
	rDocmto  = $('label[for="nrdocmto"]','#'+formCab);
	rCabCnt  = $('label[for="nrdconta"]','#'+formCab);
	
	cCabecalho   = $('input[type="text"],select','#'+formCab);
	cOpcao   = $('#cddopcao','#'+formCab);
	cData    = $('#dtdepesq','#'+formCab);
	cPac     = $('#cdagenci','#'+formCab);
	cBcoCxa  = $('#cdbccxlt','#'+formCab);
	cLote    = $('#nrdolote','#'+formCab);
	cDocmto  = $('#nrdocmto','#'+formCab);
	cCabCnt  = $('#nrdconta','#'+formCab);
	
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
	rRecursos = $('label[for="recursos"]','#'+formDados);
	
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
	cRecursos = $('#recursos','#'+formDados);

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
		
		//na opcao recursos
		if (cInfo.val() == "no" ) {
		    cRecursos.val('');
		} 
					
		if (cRecursos.hasClass('campo') && (cRecursos.val() == "")) { 
			showError('error','Campo deve ser preenchido.','Alerta - Ayllos','focaCampoErro(\'recursos\',\''+ formDados +'\');'); 
			return false;
		}
	
		manterRotina();
	}
	else
	if (operacao == 'A4' || operacao == 'I4' ) {
		
		if (cRecursos.hasClass('campo') && (cRecursos.val() == "")) { 
			showError('error','Campo deve ser preenchido.','Alerta - Ayllos','focaCampoErro(\'recursos\',\''+ formDados +'\');'); 
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
	var nrdconta = normalizaNumero( cCabCnt.val()	);
	
	var nrccdrcb = normalizaNumero(cConta.val());
	var nmpesrcb = cNome.val();
	var nridercb = cNrIde.val();
	var dtnasrcb = cNasc.val();
	var desenrcb = cEndereco.val();
	var nmcidrcb = cCidade.val();
	var nrceprcb = normalizaNumero(cCep.val());
	var cdufdrcb = cUf.val();
	var flinfdst = (cInfo.val() != null) ? cInfo.val() : '';
	var recursos = cRecursos.val();
	var cpfcgrcb = normalizaNumero(cCnpj.val());
	var tpoperac = operacao.substring(1);
	
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
			url   : UrlSite + 'telas/cmedep/manter_rotina.php', 		
			data: {
				operacao	: operacao,		
				
				// Cabecalho
				dtdepesq : dtdepesq,
				cdagenci : cdagenci,
				cdbccxlt : cdbccxlt,
				nrdolote : nrdolote,
				nrdocmto : nrdocmto,				
				nrdconta : nrdconta,
				nrccdrcb : nrccdrcb, 
				nmpesrcb : nmpesrcb, 
				nridercb : nridercb, 
				dtnasrcb : dtnasrcb, 
				desenrcb : desenrcb, 
				nmcidrcb : nmcidrcb, 
				nrceprcb : nrceprcb, 
				cdufdrcb : cdufdrcb, 
				flinfdst : flinfdst, 
				recursos : recursos, 
				cpfcgrcb : cpfcgrcb, 
				flgimpri : flgimpri,
				
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
	
	$('#sidlogin','#frmCmedep').remove();	
	$('#flgimpre','#frmCmedep').remove();
	
	$('#frmCmedep').append('<input type="hidden" id="sidlogin" name="sidlogin" value="' + $('#sidlogin','#frmMenu').val() + '" />');	
	$('#frmCmedep').append('<input type="hidden" id="flgimpre" name="flgimpre" value="' + flgimpre + '" />');	

	$("#nmarqpdf","#frmCmedep").val(nmarqpdf);
	
	var action = UrlSite + 'telas/cmedep/imprimir_dados.php';	
	
	if (flgimpre == "yes") {
		carregaImpressaoAyllos("frmCmedep",action);
	} else {
		// Configuro o formulário para posteriormente submete-lo
		$('#frmCmedep').attr('method','post');
		$('#frmCmedep').attr('action',action);
		$('#frmCmedep').attr("target","frameBlank");
		$('#frmCmedep').submit();	
	}	
	
	return false;
	
}    	

function controlaLayout() {

	$('fieldset').css({'clear':'both','border':'1px solid #777','margin':'3px 0px','padding':'10px 3px 5px 3px'});
	$('fieldset > legend').css({'font-size':'11px','color':'#777','margin-left':'5px','padding':'0px 2px'});
	$('#divBotoes').css({'text-align':'center','padding-top':'5px'});

	rSeq.addClass('rotulo').css('width','30px');
	rLanmto.css('width','40px');
	rDConta.css('width','60px');

	rConta.addClass('rotulo').css('width','60px');
	rNome.addClass('rotulo-linha').css('width','40px');
	rCnpj.addClass('rotulo-linha').css('width','57px');
	rNrIde.addClass('rotulo-linha').css('width','45px');
	rNasc.addClass('rotulo-linha').css('width','30px'); 
	rEndereco.addClass('rotulo').css('width','60px');
	rCidade.addClass('rotulo').css('width','60px');
	rCep.addClass('rotulo-linha').css('width','35px');
	rUf.addClass('rotulo-linha').css('width','30px');
	rInfo.addClass('rotulo').css('width','230px');
	rRecursos.addClass('rotulo').css('width','60px');
	
	cSeq.addClass('inteiro').css('width','30px');
	cLanmto.addClass('decimal').css('width','80px');
	cDConta.css('width','280px');
	
	cConta.addClass('conta pesquisa').css('width','80px');
	cNome.css('width','328px');
	cCnpj.css('width','110px');
	cNrIde.css('width','100px');
	cNasc.addClass('data').css('width','64px');
	cEndereco.css('width','472px');
	cCidade.css('width','247px');
	cCep.addClass('cep').css('width','100px');
	cUf.css('width','50px');
	cInfo.css('width','50px');
	cRecursos.css({'width':'468px','maxlength':'60'});	
	
	cTodos_1.desabilitaCampo();
	
	switch (operacao) {

		case 'A1':  cConta.habilitaCampo().focus(); 
					cCabecalho.desabilitaCampo(); 
					operacao = 'A2';
					break;
		case 'A2':  cConta.desabilitaCampo(); 
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
					cNome.habilitaCampo().focus();
					operacao = 'A3';
					break;						
		case 'A3':  if (cInfo.val() == "no") {
						cInfo.habilitaCampo();
						controlaOperacao("A4");
						return false;
					}else {
						cInfo.desabilitaCampo();
						cRecursos.habilitaCampo().focus();
						operacao = 'A4';
					}
					break;				
		case 'A4':	controlaOperacao("A4"); break;
		
		case 'I1':  cConta.habilitaCampo().focus(); 
					cCabecalho.desabilitaCampo(); 
					operacao = 'I2';
					break;
					
		case 'I2':  cConta.desabilitaCampo(); 
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
					cNome.habilitaCampo().focus();
					operacao = 'I3';
					break;						
		case 'I3':  if (cInfo.val() == "no") {
						cInfo.habilitaCampo();
						controlaOperacao("I4");
						return false;
					}else{
						cInfo.desabilitaCampo();
						cRecursos.habilitaCampo().focus();
						operacao = 'I4';
					}
					break;		
		case 'I4':	controlaOperacao("I4"); break;
										
		case 'Aok':	$('#'+formDados).desabilitaCampo().limpaFormulario();
						cCabecalho.habilitaCampo();
						cDocmto.focus();
						break;
		case 'voltar':	$('#'+formDados).limpaFormulario();
						cCabecalho.habilitaCampo();
						$("input","#" + formDados).removeClass("campoErro");
						if (cDocmto.val() != "") {
							cDocmto.focus();
						}else{ 
							estadoInicial(); 
						}
						break;
		default: break;		
		}
	
	layoutPadrao();
	controlaPesquisas();

	return false;
	
}

function formataCabecalho() {
	
	rOpcao.css('width','42px');
	rData.addClass('rotulo-linha').css('width','50px');
	rPac.addClass('rotulo-linha').css('width','60px');;
	rBcoCxa.addClass('rotulo-linha').css('width','90px');;
	rLote.addClass('rotulo-linha').css('width','50px');;
	rDocmto.addClass('rotulo-linha').css('width','128px');
	rCabCnt.addClass('rotulo-linha').css('width','55px');;
	
	cOpcao.css('width','33px');
	cData.addClass('campo data').css('width','65px');
	cPac.addClass('campo inteiro').css('width','30px');
	cBcoCxa.addClass('campo inteiro').css('width','30px');
	cLote.addClass('campo inteiro').css('width','50px');
	cDocmto.addClass('campo inteiro').css('width','70px');
	cCabCnt.addClass('campo inteiro').css('width','70px');
	
	cPac.setMask("INTEGER","zz9","");
	cLote.setMask("INTEGER","zzz.zz9",".");
	cBcoCxa.setMask("INTEGER","zz9","");
	cDocmto.setMask("INTEGER","zz.zzz.zz9",".");
	cCabCnt.setMask("INTEGER","zzzz.zz9.9",".");
	
	cOpcao.habilitaCampo().focus();

	
	// Se pressionar alguma tecla nos campos do cabecalho, verificar a tecla pressionada e toda a devida ação
	$('input, select','#'+ formCab ).unbind('keypress').bind('keypress', function(e) { 	
		
		if ( divError.css('display') == 'block' ) { return false; }		
			
		// Se é a tecla ENTER, valida os dados e realiza a busca
		if ( e.keyCode == 13 || e.keyCode == 112 ) {		

			// trata as variaveis
			setGlobais();			
			
			//cddopcao 	= cOpcao.val();
			var cdagenci 	= cPac.val();
			var dtdepesq 	= cData.val();
			var nrdolote 	= cLote.val();
			var cdbccxlt 	= normalizaNumero(cBcoCxa.val());
			var nrdocmto 	= normalizaNumero(cDocmto.val());
			var nrdconta 	= normalizaNumero(cCabCnt.val());
												
			// Verifica se foi informado
			if ( dtdepesq == "" ) { 
				showError('error','Informe a data.','Alerta - Ayllos','focaCampoErro(\'dtdepesq\',\''+ formCab +'\');'); 
				return false; 
			}

			// Verifica se foi informado
			if ( cdagenci == 0 ) { 
				showError('error','Informe o PAC.','Alerta - Ayllos','focaCampoErro(\'cdagenci\',\''+ formCab +'\');'); 
				return false; 
			}
			
			// Verifica se foi informado
			if ( cdbccxlt == 0 ) { 
				showError('error','Informe o banco/caixa.','Alerta - Ayllos','focaCampoErro(\'cdbccxlt\',\''+ formCab +'\');'); 
				return false; 
			}

			// Verifica se foi informado
			if ( nrdolote == 0 ) { 
				showError('error','Informe o lote.','Alerta - Ayllos','focaCampoErro(\'nrdolote\',\''+ formCab +'\');'); 
				return false; 
			}

			// Verifica se foi informado
			if ( nrdocmto == 0 ) { 
				showError('error','Informe o número do documento.','Alerta - Ayllos','focaCampoErro(\'nrdocmto\',\''+ formCab +'\');'); 
				return false; 
			}
			
			// Verifica se foi informado
			if ( nrdconta == 0 ) { 
				showError('error','Informe o número da conta.','Alerta - Ayllos','focaCampoErro(\'nrdconta\',\''+ formCab +'\');'); 
				return false; 
			}
			
			// Se chegou até aqui, está tudo ok e então realiza a operação desejada
			controlaOperacao(cOpcao.val());
			return false;
			
		} 
		
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
	$('#recursos','#'+ formDados ).unbind('keypress').bind('keypress', function(e) { 	
		
		if ( divError.css('display') == 'block' ) { return false; }		
			
		// Se é a tecla ENTER, valida os dados e realiza a operacao
		if ( e.keyCode == 13 || e.keyCode == 112 ) {		

			// trata as variaveis
			setGlobais();
			
			// Verifica se foi informado
			if ( $(this).val() == "" ) { 
				showError('errorcontrolaLayout','Campo deve ser preenchido.','Alerta - Ayllos','focaCampoErro(\'recursos\',\''+ formDados +'\');'); 
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
			$('#recursos','#'+ formDados ).habilitaCampo();
			$('#recursos','#'+ formDados ).focus();
		}else{
			$('#recursos','#'+ formDados ).val("");	
			$('#recursos','#'+ formDados ).desabilitaCampo();				
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
function btnVoltar() {

	operacao = 'voltar';
	
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
	$("input","#" + formDados).removeClass("campoErro");
	// tira borda do erro
	$("#cdufdrcb","#" + formDados).removeClass("campoErro");
	
	return false;
}
