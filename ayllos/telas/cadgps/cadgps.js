/*!
 * FONTE        : cadgps.js
 * CRIAÇÃO      : Rogérius Militão (DB1)
 * DATA CRIAÇÃO : 07/06/2011
 * OBJETIVO     : Biblioteca de funções da tela CADGPS
 * --------------
 * ALTERAÇÕES   :
 * 001: 21/01/2013 - Daniel (CECRED) : Implantacao novo layout.
 * --------------
 */

// Definição de algumas variáveis globais 
var operacao 		= ''; // Armazena a operação corrente da tela CADGPS
var operacaoOld		= ''; // Variável auxiliar para guardar a operação passada

var frmCabCadgps	= 'frmCabCadgps';
var frmCadgps		= 'frmCadgps';
var frmCadgpsDebito = 'frmCadgpsDebito';

var cdidenti 		= 0; 
var cddpagto		= 0; 
var msgretor		= '';

// Fieldset do formulario
var fCabecalho		= ''; // formulario cabecalho
var fConta			= ''; // fieldset conta
var fContribuinte	= ''; // fieldset contribuinte
var fEndereco		= ''; // fieldset endereco
var fOutro			= ''; // fieldset outro			


$(document).ready(function() {

	$('#frmCabCadgps').css({'display':'block'});
	$('#frmCadgps').css({'display':'block'});

	if ( ! $.browser.msie ) {	
		$(this).keypress( function(e) {
			if ( e.keyCode == 13 ) { 
				if ( ($('#divIdentificadores').css('visibility') == 'visible') && (divError.css('display') != 'block') ) { 
					selecionaIdentificador(); 
					return false; 
				}		
			}
		});
	}
	
	fCabecalho		= $('input[type="text"],select','#'+frmCabCadgps);
	fConta			= $('input[type="text"],select','#'+frmCadgps + ' fieldset:eq(0)'); // fieldset conta
	fContribuinte	= $('input[type="text"],select','#'+frmCadgps + ' fieldset:eq(1)'); // fieldset contribuinte
	fEndereco		= $('input[type="text"],select','#'+frmCadgps + ' fieldset:eq(2)'); // fieldset endereco
	fOutro			= $('input[type="text"],select','#'+frmCadgps + ' fieldset:eq(3)'); // fieldset outro			
	
	estadoInicial();
	
	highlightObjFocus( $('#frmCabCadgps') );
	highlightObjFocus( $('#frmCadgps') );
	highlightObjFocus( $('frmCadgpsDebito') );

});


// Controles
function estadoInicial() {
	
	trocaBotao('prosseguir');
	
	if ( operacao == 'A5' || operacao == 'I5') {
		operacao = operacao == 'A5' ? 'A4' : 'I4';
		formataConta();
		formataOutro();
	} else {
		
		var op = operacao == '' ? 'C1' : operacao.charAt(0) + '1';
	
		// variaveis globais
		operacao = '';
		cdidenti = 0; 
		cddpagto = 0; 
		msgretor = '';		

		// 
		fechaRotina($('#divRotina'));
		$('#divRotina').html('');	
	
		// limpa formularios
		fCabecalho.limpaFormulario();
		fConta.limpaFormulario();
		fContribuinte.limpaFormulario();
		fEndereco.limpaFormulario();
		fCabecalho.limpaFormulario();
		fOutro.limpaFormulario();

		$('input, select','#'+ frmCadgps ).removeClass('campoErro');

		// formata
		$('#opcao','#'+frmCabCadgps).val(op);
		controlaLayout();

	}
	 
}

function controlaOperacao() {

	switch (operacao) {
		// Consulta
		case 'C1': formataCabecalho(); 	operacao='C2'; 	return false; break;
		case 'C2': operacao ='C3'; 		manterRotina(); return false; break;
		case 'C3': formataCabecalho(); 	operacao = ''; 	return false; break;
		// Alteracao	
		case 'A1': formataCabecalho(); 	operacao='A2'; 	return false; break;
		case 'A2': operacao ='A3'; 		manterRotina(); return false; break;
		case 'A3': formataCabecalho(); 	formataConta(); operacao = 'A4'; return false; break;
		case 'A4': operacao ='A5'; 		formataConta(); return false; break;
		case 'A5': 
			if ($('#nrdconta','#'+frmCadgps).val() == 0) { 
				operacao='A6';
			} else  {				
				operacao='A7';
			} 	
			manterRotina(); 
			return false; 
		break;
		case 'A6': operacao='A7'; 		manterRotina(); break;
		case 'A7': 
			showConfirmacao('Confirmar opera&ccedil;&atilde;o?','Confirma&ccedil;&atilde;o - Ayllos','operacao=\'A8\'; manterRotina();','operacao=\'A5\';','sim.gif','nao.gif');
			return false; 
		break;
		// Inclusão
		case 'I1': formataCabecalho(); 	operacao='I2'; 	return false; break; 
		case 'I2': formataCabecalho(); 	operacao='I8'; 	return false; break; 
		case 'I8': operacao ='I3'; 		manterRotina(); return false; break; 
		case 'I3': formataConta(); 		operacao='I4'; 	return false; break; 
		case 'I4': operacao ='I5'; 		formataConta(); return false; break;
		case 'I5': operacao ='I6'; 		manterRotina(); return false; break;
		case 'I6': 
			showConfirmacao('Confirmar opera&ccedil;&atilde;o?','Confirma&ccedil;&atilde;o - Ayllos','operacao=\'I7\'; manterRotina();','estadoInicial();','sim.gif','nao.gif');
			return false; 
		break;
		//Debito
		case 'D1': formataCabecalho(); 	operacao='D2'; 	return false; break;
		case 'D2': operacao ='D3'; 		manterRotina(); return false; break;
		case 'D3': formataCabecalho(); 	operacao = ''; 	return false; break;
		case 'D4': operacao = 'D5'; 	manterRotina(); return false; break;
		case 'D6': 
			showConfirmacao('Confirmar opera&ccedil;&atilde;o?','Confirma&ccedil;&atilde;o - Ayllos','operacao=\'D7\'; manterRotina();','estadoInicial();','sim.gif','nao.gif');
			return false; 
		break;
		default: return false; break;		
	}

}

function manterRotina() {

	var mensagem = '';
		
	hideMsgAguardo();		
	
	switch (operacao) {	
		case 'C1': mensagem = 'Aguarde, validando...'; break;
		case 'C2': mensagem = 'Aguarde, validando...'; break;
		case 'C3': mensagem = 'Aguarde, buscando guia...'; break;

		case 'A1': mensagem = 'Aguarde, validando...'; break;
		case 'A2': mensagem = 'Aguarde, validando...'; break;
		case 'A3': mensagem = 'Aguarde, buscando guia...'; break;
		case 'A4': mensagem = 'Aguarde, validando...'; break;
		case 'A5': mensagem = 'Aguarde, buscando associado...'; break;
		case 'A6': mensagem = 'Aguarde, validando dados...'; break;
		case 'A7': mensagem = 'Aguarde, validando...'; break;
		case 'A8': mensagem = 'Aguarde, gravando dados...'; break;

		case 'I1': mensagem = 'Aguarde, validando...'; break;
		case 'I2': mensagem = 'Aguarde, validando...'; break;
		case 'I3': mensagem = 'Aguarde, validando...'; break;
		case 'I4': mensagem = 'Aguarde, validando...'; break;
		case 'I5': mensagem = 'Aguarde, buscando associado...'; break;
		case 'I6': mensagem = 'Aguarde, validando...'; break;
		case 'I7': mensagem = 'Aguarde, gravando dados...'; break;
		case 'I8': mensagem = 'Aguarde, validando...'; break;

		case 'D1': mensagem = 'Aguarde, validando...'; break;
		case 'D2': mensagem = 'Aguarde, validando...'; break;
		case 'D3': mensagem = 'Aguarde, buscando guia...'; break;
		case 'D4': mensagem = 'Aguarde, buscando dados...'; break;
		case 'D5': mensagem = 'Aguarde, validando...'; break;
		case 'D6': mensagem = 'Aguarde, validando...'; break;
		case 'D7': mensagem = 'Aguarde, gravando dados...'; break;

		default: return false; break;
	}
	
	showMsgAguardo( mensagem );	

	// conta
	var tpcontri = $('#tpcontri', '#'+frmCadgps).val();	
	var nrdconta = normalizaNumero($('#nrdconta', '#'+frmCadgps).val());	
	var idseqttl = normalizaNumero($('#idseqttl', '#'+frmCadgps).val());
	
	// contribuinte
	var nmextttl = $('#nmprimtl', '#'+frmCadgps).val();
	var nrcpfcgc = normalizaNumero($('#nrcpfcgc', '#'+frmCadgps).val());

	var dsendres = $('#dsendere', '#'+frmCadgps).val();	
	var nmbairro = $('#nmbairro', '#'+frmCadgps).val();	
	var nmcidade = $('#nmcidade', '#'+frmCadgps).val();	
	var nrcepend = normalizaNumero($('#nrcepend', '#'+frmCadgps).val());	
	var cdufresd = $('#cdufresd', '#'+frmCadgps).val();	
	var nrendres = normalizaNumero($('#nrendere', '#'+frmCadgps).val());
	var complend = $('#complend', '#'+frmCadgps).val();
	var nrcxapst = normalizaNumero($('#nrcxapst', '#'+frmCadgps).val());

	// outro
	var nrfonres = $('#nrfonres', '#'+frmCadgps).val();
	var flgrgatv = $('#flgrgatv', '#'+frmCadgps).val();	

	// debito
	var flgdbaut = $('#flgdbaut', '#'+frmCadgpsDebito).val();
	var inpessoa = normalizaNumero($('#inpessoa', '#'+frmCadgpsDebito).val());
	var nrctadeb = normalizaNumero($('#nrctadeb', '#'+frmCadgpsDebito).val());
	var nmctadeb = $('#nmctadeb', '#'+frmCadgpsDebito).val();
	var vlrdinss = $('#vlrdinss', '#'+frmCadgpsDebito).val();
	var vloutent = $('#vloutent', '#'+frmCadgpsDebito).val();
	var vlrjuros = $('#vlrjuros', '#'+frmCadgpsDebito).val();
	var vlrtotal = $('#vlrtotal', '#'+frmCadgpsDebito).val();

	$.ajax({		
			type  : 'POST',
			async : true ,
			url   : UrlSite + 'telas/cadgps/manter_rotina.php', 		
			data: {
				operacao: operacao,	cdidenti: cdidenti, 
				cddpagto: cddpagto, nrdconta: nrdconta,
				tpcontri: tpcontri, flgrgatv: flgrgatv,
				dsendres: dsendres, nmbairro: nmbairro,
				nmcidade: nmcidade, nrcepend: nrcepend,
				cdufresd: cdufresd, nrendres: nrendres,
				complend: complend, nrcxapst: nrcxapst,
				nrfonres: nrfonres, nmextttl: nmextttl,
				nrcpfcgc: nrcpfcgc, vlrdinss: vlrdinss,
				flgdbaut: flgdbaut, vloutent: vloutent,
				vlrjuros: vlrjuros, vlrtotal: vlrtotal,
				idseqttl: idseqttl, nrctadeb: nrctadeb,
				inpessoa: inpessoa, nmctadeb: nmctadeb,
				redirect: 'script_ajax'
			}, 
			error: function(objAjax,responseError,objExcept) {
				hideMsgAguardo();
				showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','estadoInicial();');
			},
			success: function(response) {
				try {
					eval(response);
					return false;
				} catch(error) {
					hideMsgAguardo();
					showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','estadoInicial();');
				}
			}
		});

	return false;	
	                     
}       	

function controlaLayout() {

	$('#divTela').fadeTo(0,0.1);
	$('fieldset').css({'clear':'both','border':'1px solid #777','margin':'3px 0px','padding':'10px 3px 5px 3px'});
	$('fieldset > legend').css({'font-size':'11px','color':'#777','margin-left':'5px','padding':'0px 2px'});
	$('#divBotoes').css({'text-align':'center','padding-top':'5px'});

	formataCabecalho();	
	formataConta();
	formataContribuinte();
	formataEndereco();
	formataOutro();

	// Conclui a operação	
	/*
	$('#btSalvar','#divTela').unbind('click').bind('click', function(e) {	
		if ( divError.css('display') == 'block' ) { return false; }	
		if ( operacao == 'A5' || operacao == 'I5') {
		controlaOperacao();
		}
		return false;
	});
	*/
	
	layoutPadrao();
	controlaPesquisas();
	controlaFoco();
	removeOpacidade('divTela');
	return false;
	
}

function controlaFoco() {
		
	$('#opcao','#'+frmCabCadgps).focus()

	return false;
}

function controlaPesquisas(opcao) {
	
	// /*---------------------*/
	// /*  CONTROLE CONTA/DV  */
	// /*---------------------*/
	// var linkConta = $('a:eq(2)','#frmCadgps' + ' fieldset:eq(0)');

	// if ( linkConta.prev().hasClass('campoTelaSemBorda') ) {		
		// linkConta.addClass('lupa').css('cursor','auto').unbind('click').bind('click', function() { return false; });
	// } else {
		// linkConta.css('cursor','pointer').unbind('click').bind('click', function() {			
			// mostraPesquisaAssociado('nrdconta','frmCadgps');
		// });
	// }
	
	if (opcao == 1) {	
		if ( $('#nrdconta','#frmCadgps').hasClass('campoTelaSemBorda') ) {
			return false;
		}
		mostraPesquisaAssociado('nrdconta','frmCadgps');
		return false;
	}
	
	
	// /*--------------------*/
	// /*  CONTROLE TITULAR  */
	// /*--------------------*/
	// var linkTitular = $('a:eq(3)','#frmCadgps' + ' fieldset:eq(0)');
	
	// if ( linkTitular.prev().hasClass('campoTelaSemBorda') ) {		
		// linkTitular.addClass('lupa').css('cursor','auto').unbind('click').bind('click', function() { return false; });
	// } else {
		// linkTitular.css('cursor','pointer').unbind('click').bind('click', function() {			
			// mostraTitulares();
			// return false;			
		// });
	// }
	
	if (opcao == 2) {	
		if ( $('#idseqttl','#frmCadgps').hasClass('campoTelaSemBorda') ) {
			return false;
		}
		mostraTitulares();
		return false;
	}
	
	// /*--------------------------*/
	// /*  CONTROLE IDENTIFICADOR  */
	// /*--------------------------*/
 	// var linkIdentificador = $('a:eq(0)','#frmCabCadgps');

	// if ( linkIdentificador.prev().hasClass('campoTelaSemBorda') || operacao.charAt(0) == 'I' ) {		
		// linkIdentificador.addClass('lupa').css('cursor','auto').unbind('click').bind('click', function() { return false; });
	// } else {
		// linkIdentificador.css('cursor','pointer').unbind('click').bind('click', function() {			
			// mostraIdentificadores( 1 , 30 );
		// });
	// } 
	if (opcao == 3) {	
		if ( $('#cdidenti','#frmCabCadgps').hasClass('campoTelaSemBorda') ) {
			return false;
		}
		
		if ( $('#opcao','#frmCabCadgps').val() == "I1" ) {
			return false;
		}
		
		mostraIdentificadores( 1 , 30 );
		return false;
	}
	
	// /*---------------------*/
	// /*  CONTROLE ENDERECO  */
	// /*---------------------*/
	// var linkEndereco = $('a:eq(4)','#frmCadgps');
	
	// if ( linkEndereco.prev().hasClass('campoTelaSemBorda') ) {		
		// linkEndereco.addClass('lupa').css('cursor','auto').unbind('click').bind('click', function() { return false; });
	// } else {
		// linkEndereco.css('cursor','pointer');
	// }	
	
	// var camposOrigem = 'nrcepend;dsendere;nrendere;complend;nrcxapst;nmbairro;cdufresd;nmcidade';	
	// $('#nrcepend','#'+frmCadgps).buscaCEP(frmCadgps, camposOrigem, $('#divTela'));
	
	if (opcao == 4) {	
		if ( $('#nrcepend','#frmCabCadgps').hasClass('campoTelaSemBorda') ) {
			return false;
		}
		var camposOrigem = 'nrcepend;dsendere;nrendere;complend;nrcxapst;nmbairro;cdufresd;nmcidade';	
		$('#nrcepend','#'+frmCadgps).buscaCEP(frmCadgps, camposOrigem, $('#divTela'));
	}


	// /*--------------------------------------*/
	// /*  CONTROLE CONTA/DV NA TELA DE DEBITO */
	// /*--------------------------------------*/
	// var linkContaDeb = $('a:eq(2)','#frmCadgpsDebito');

	// if ( linkContaDeb.prev().hasClass('campoTelaSemBorda') ) {		
		// linkContaDeb.addClass('lupa').css('cursor','auto').unbind('click').bind('click', function() { return false; });
	// } else {
		// linkContaDeb.css('cursor','pointer').unbind('click').bind('click', function() {			
			// mostraPesquisaAssociado('nrctadeb','frmCadgpsDebito',$('#divRotina'));
		// });
	// }	
		if (opcao == 5) {	
		if ( $('#nrctadeb','#frmCadgpsDebito').hasClass('campoTelaSemBorda') ) {
			return false;
		}
		mostraPesquisaAssociado('nrctadeb','frmCadgpsDebito',$('#divRotina'));
	}

	
}


// Formatações
function formataCabecalho() {
	
	// formata os rotulos
	var rOpcao    	= $('label[for="opcao"]','#'+frmCabCadgps);	
	var rCdidenti 	= $('label[for="cdidenti"]','#'+frmCabCadgps);	
	var rCddpagto	= $('label[for="cddpagto"]','#'+frmCabCadgps);	

	rOpcao.addClass('rotulo').css('width','46px');
	rCdidenti.addClass('rotulo-linha').css('width','75px');;
	rCddpagto.addClass('rotulo-linha').css('width','80px');;
	
	// formatas os campos
	var cOpcao    	= $('#opcao','#'+frmCabCadgps);
	var cCdidenti  	= $('#cdidenti','#'+frmCabCadgps);
	var cCddpagto  	= $('#cddpagto','#'+frmCabCadgps);
			
	cOpcao.css('width','455px');
	cCdidenti.addClass('pesquisa').css({'width':'129px','text-align':'right'}).setMask('INTEGER','zzzzzzzzzzzzzzz9','','');
	cCddpagto.addClass('inteiro').css('width','119px').attr('maxlength','4');
	
	// ie
	if ( $.browser.msie ) {	
		cCdidenti.css('width','134px');
	}

	// operacao
	if ( operacao == 'C1' || operacao == 'A1' || operacao == 'I1' || operacao == 'D1' ) {
		cCdidenti.habilitaCampo().focus();
	} else if ( operacao == 'C3' || operacao == 'D3' ) {
		cCdidenti.desabilitaCampo();			
		cOpcao.habilitaCampo().focus(); 
	} else if (operacao == 'A3') {
		cCdidenti.desabilitaCampo();			
	} else if (operacao == 'I2') {
		cCdidenti.desabilitaCampo();
		cCddpagto.habilitaCampo().focus();			
	} else {
		fCabecalho.desabilitaCampo();
		cOpcao.habilitaCampo();
	}

	// Se pressionar ENTER em opçao
	cOpcao.unbind('keypress').bind('keypress', function(e) {	
		if ( divError.css('display') == 'block' ) { return false; }		
		
		if ( e.keyCode == 13 ) { 
			operacao = cOpcao.val();
			cOpcao.desabilitaCampo();

			// limpa formulario
			cCdidenti.val('');
			cCddpagto.val('');
			$('#frmCadgps').limpaFormulario();
	
			$('#tpcontri','#'+frmCadgps).val('1');
			$('#flgrgatv','#'+frmCadgps).val('yes');
	
			//
			manterRotina();
			return false;
		}
		
	});		
	
	// Se pressionar o botao OK
	cOpcao.next().unbind('click').bind('click', function() { 	
		if ( divError.css('display') == 'block' ) { return false; }		
		if ( cOpcao.hasClass('campoTelaSemBorda') ) { return false; }
		operacao = cOpcao.val();
		cOpcao.desabilitaCampo();

		// limpa formulario
		cCdidenti.val('');
		cCddpagto.val('');
		$('#frmCadgps').limpaFormulario();
	
		$('#tpcontri','#'+frmCadgps).val('1');
		$('#flgrgatv','#'+frmCadgps).val('yes');
	
		//
		manterRotina();
		return false;
		
	});		

	// Se pressionar tecla ENTER no campo Identificador
	cCdidenti.unbind('keypress').bind('keypress', function(e) {	
		if ( divError.css('display') == 'block' ) { return false; }	
		if ( $('#divRotina').css('visibility') == 'visible' ) { 
			if ( e.keyCode == 13 ) { selecionaIdentificador(); return false; }
		}		
		if ( e.keyCode == 13 && operacao.charAt(0) != 'I' ) { 
			mostraIdentificadores( 1 , 30 );
			return false;
		} else if (e.keyCode == 13 && operacao.charAt(0) == 'I') {
			cdidenti = normalizaNumero($(this).val());
			manterRotina();
			return false;
		}

	});		

	// Se pressionar tecla ENTER no campo Código Pgto
	cCddpagto.unbind('keypress').bind('keypress', function(e) {	
		if ( divError.css('display') == 'block' ) { return false; }	
		if (e.keyCode == 13 && operacao.charAt(0) == 'I') {
			cddpagto = normalizaNumero($(this).val());
			$(this).desabilitaCampo();
			manterRotina();
			return false;
		}

	});		

	layoutPadrao();
	controlaPesquisas();
	return false;	
}

function formataConta() {

	// rotulo
	var rTpcontri  	= $('label[for="tpcontri"]','#'+frmCadgps);	
	var rNrdconta	= $('label[for="nrdconta"]','#'+frmCadgps);			
	var rIdseqttl	= $('label[for="idseqttl"]','#'+frmCadgps);	
	
	rTpcontri.addClass('rotulo').css({'width':'55px'});
	rNrdconta.addClass('rotulo-linha').css({'width':'126px'});
	rIdseqttl.addClass('rotulo-linha').css({'width':'49px'});;
	
	// campo
	var cTpcontri   = $('#tpcontri','#'+frmCadgps);
	var cNrdconta   = $('#nrdconta','#'+frmCadgps);
	var cIdseqttl   = $('#idseqttl','#'+frmCadgps);

	cTpcontri.css('width','151px').attr('maxlength','2');
	cNrdconta.addClass('pesquisa conta').css('width','75px');
	cIdseqttl.addClass('inteiro').css('width','25px').attr('maxlength','1');

    // ie
	if ( $.browser.msie ) {	
		cIdseqttl.css('width','29px');
	}	
	
	// operacao
	if ( operacao == 'A3' || operacao == 'A4' || operacao == 'I3' || operacao == 'I4' ) {
		cTpcontri.habilitaCampo().focus(); 
		cNrdconta.habilitaCampo();
		cIdseqttl.desabilitaCampo();
		fContribuinte.desabilitaCampo();
		fEndereco.desabilitaCampo();
	} else if ( operacao == 'A5' || operacao == 'I5') {
		if ( cIdseqttl.hasClass('campoTelaSemBorda') ) {
			cTpcontri.desabilitaCampo();
			cNrdconta.desabilitaCampo();
			manterRotina(); 
			return false;
		}
	} else {
		cTpcontri.val('1');
		fConta.desabilitaCampo();
	}
	
	// Se pressionar tecla ENTER no campo Conta
	cNrdconta.unbind('keypress').bind('keypress', function(e) {	
		if ( divError.css('display') == 'block' ) { return false; }		
		if ( e.keyCode == 13 ) { 
	
			nrdconta = normalizaNumero( $(this).val() );
		
			// Verifica se a conta é válida
			if ( !validaNroConta(nrdconta) && nrdconta != 0) { 
				showError('error','Conta/dv inválida.','Alerta - Ayllos','focaCampoErro(\'nrdconta\',\'frmCadgps\');'); 
				return false; 
			}

			manterRotina();
			return false;
		}

	});		

	// Se pressionar tecla ENTER no campo Titular
	cIdseqttl.unbind('keypress').bind('keypress', function(e) {	
		if ( divError.css('display') == 'block' ) { return false; }		
		if ( $('#divRotina').css('visibility') == 'visible' ) { return false; }		
		if ( e.keyCode == 13 ) { 

			idseqttl = normalizaNumero( $(this).val() );
			
			if ( idseqttl == 0 ) {
				mostraTitulares();
			} else {
				$(this).desabilitaCampo();
				manterRotina();
			}
			controlaPesquisas();
			return false;			

		} else if ( e.keyCode == 118 ) {
			mostraTitulares();
			return false;
		}
		
	});		

	controlaPesquisas();
	return false;	
}

function formataContribuinte() {

	// rotulos 
	var rNrcpfcgc	= $('label[for="nrcpfcgc"]','#'+frmCadgps);
	var rNmprimtl	= $('label[for="nmprimtl"]','#'+frmCadgps);
	
	rNrcpfcgc.addClass('rotulo').css('width','55px');
	rNmprimtl.addClass('rotulo-linha').css('width','76px');

	// campos
	var cNrcpfcgc	= $('#nrcpfcgc','#'+frmCadgps);
	var cNmprimtl	= $('#nmprimtl','#'+frmCadgps);
	
	cNrcpfcgc.css('width','120px').setMask('INTEGER','zzzzzzzzzzzzz9','','');
	cNmprimtl.addClass('alphanum').css('width','65px').css('width','271px').attr('maxlength','40');

	if ( operacao == 'A5' || operacao == 'I5' ) {
		fContribuinte.habilitaCampo();
		cNrcpfcgc.focus();
	} else {
		fContribuinte.desabilitaCampo();
	}
	
	layoutPadrao();
	return false;	
}

function formataEndereco() {

	// rotulos 
	var rCep	= $('label[for="nrcepend"]','#'+frmCadgps);
	var rEnd	= $('label[for="dsendere"]','#'+frmCadgps);
	var rNum	= $('label[for="nrendere"]','#'+frmCadgps);
	var rCom	= $('label[for="complend"]','#'+frmCadgps);
	var rCax	= $('label[for="nrcxapst"]','#'+frmCadgps);	
	var rBai	= $('label[for="nmbairro"]','#'+frmCadgps);
	var rEst	= $('label[for="cdufresd"]','#'+frmCadgps);	
	var rCid	= $('label[for="nmcidade"]','#'+frmCadgps);
	
	rCep.addClass('rotulo').css('width','55px');
	rEnd.addClass('rotulo-linha').css('width','35px');
	rNum.addClass('rotulo').css('width','55px');
	rCom.addClass('rotulo-linha').css('width','52px');
	rCax.addClass('rotulo').css('width','55px');
	rBai.addClass('rotulo-linha').css('width','52px');
	rEst.addClass('rotulo').css('width','55px');
	rCid.addClass('rotulo-linha').css('width','52px');
	
	// campos
	var cCep	= $('#nrcepend','#'+frmCadgps);
	var cEnd	= $('#dsendere','#'+frmCadgps);
	var cNum	= $('#nrendere','#'+frmCadgps);
	var cCom	= $('#complend','#'+frmCadgps);
	var cCax	= $('#nrcxapst','#'+frmCadgps);		
	var cBai	= $('#nmbairro','#'+frmCadgps);
	var cEst	= $('#cdufresd','#'+frmCadgps);	
	var cCid	= $('#nmcidade','#'+frmCadgps);

	cCep.addClass('cep pesquisa').css('width','65px').attr('maxlength','9');
	cEnd.addClass('alphanum').css('width','350px').attr('maxlength','40');
	cNum.addClass('numerocasa').css('width','65px').attr('maxlength','7');
	cCom.addClass('alphanum').css('width','350px').attr('maxlength','40');	
	cCax.addClass('caixapostal').css('width','65px').attr('maxlength','6');	
	cBai.addClass('alphanum').css('width','350px').attr('maxlength','40');	
	cEst.css('width','65px');	
	cCid.addClass('alphanum').css('width','350px').attr('maxlength','25');

	if ( operacao == 'A5' || operacao == 'I5' ) {
		fEndereco.habilitaCampo();
		trocaBotao('concluir');
	} else {	
		fEndereco.desabilitaCampo();
	}
	
	// sempre desabilitados
	$('#dsendere','#'+frmCadgps).desabilitaCampo();
	$('#nmbairro','#'+frmCadgps).desabilitaCampo();
	$('#cdufresd','#'+frmCadgps).desabilitaCampo();	
	$('#nmcidade','#'+frmCadgps).desabilitaCampo();

	controlaPesquisas();
	return false;	
}

function formataOutro() {

 	// rotulos 
	var rNrfonres	= $('label[for="nrfonres"]','#'+frmCadgps);
	var rFlgrgatv	= $('label[for="flgrgatv"]','#'+frmCadgps);
	var rFlgdbaut	= $('label[for="debito11"]','#'+frmCadgps);

	rNrfonres.addClass('rotulo').css('width','55px');
	rFlgrgatv.addClass('rotulo-linha').css('width','35px');
	rFlgdbaut.addClass('rotulo-linha').css('width','106px');

	// campos
	var cNrfonres	= $('#nrfonres','#'+frmCadgps);	
	var cFlgrgatv	= $('#flgrgatv','#'+frmCadgps);	
	var cFlgdbaut	= $('#debito11','#'+frmCadgps);	

	cNrfonres.css('width','120px').attr('maxlength','20');
	cFlgrgatv.css('width','100px');
	cFlgdbaut.css('width','100px');

    // ie
	if ( $.browser.msie ) {	
		cFlgdbaut.css('width','105px');
	}

	if ( operacao == 'A5') {
		fOutro.habilitaCampo();
		cFlgdbaut.desabilitaCampo();
	} else if ( operacao == 'I5') {
		cNrfonres.habilitaCampo();
	} else {
		cFlgrgatv.val('yes');
		fOutro.desabilitaCampo();
	}
	
	return false;
}


// Identificadores
function mostraIdentificadores() {
	
	showMsgAguardo('Aguarde, buscando identificadores...');

	$('#telaIdentificadores').remove();
	
	// Executa script de confirmação através de ajax
	$.ajax({		
		type: 'POST',
		dataType: 'html',
		url: UrlSite + 'telas/cadgps/identificadores.php', 
		data: {
			redirect: 'html_ajax'			
		}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError('error','Não foi possível concluir a requisição.','Alerta - Ayllos',"unblockBackground()");
		},
		success: function(response) {
			$('#divRotina').html(response);
			buscaIdentificadores( 1 , 30 );
		}				
	});
	return false;
	
}

function buscaIdentificadores( nriniseq , nrregist ) {
		
	showMsgAguardo('Aguarde, buscando identificadores...');
	
	cdidenti = normalizaNumero($('#cdidenti','#'+frmCabCadgps).val());
	
	$.ajax({		
		type: 'POST',
		dataType: 'html',
		url: UrlSite + 'telas/cadgps/busca_identificadores.php', 
		data: {
			cdidenti: cdidenti, nriniseq: nriniseq, nrregist: nrregist, 
			redirect: 'script_ajax'			
			}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError('error','Não foi possível concluir a requisição.','Alerta - Ayllos',"unblockBackground();");
		},
		success: function(response) {
		
			if ( response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1 ) {
				try {
					$('#divConteudoOpcao').html(response);
					return false;
				} catch(error) {
					hideMsgAguardo();
					showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','unblockBackground()');
				}
			} else {
				try {
					eval( response );
					controlaFoco();
				} catch(error) {
					hideMsgAguardo();
					showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','unblockBackground()');
				}
			}
		}				
	});

	return false;
}

function formataIdentificadores() {
			
	var divRegistro = $('div.divRegistros','#divIdentificadores');		
	var tabela      = $('table', divRegistro );
	var linha       = $('table > tbody > tr', divRegistro );
			
	divRegistro.css({'height':'150px','width':'550px'});
	
	var ordemInicial = new Array();
	ordemInicial = [[0,0]];
			
	var arrayLargura = new Array();
	arrayLargura[0] = '80px';
	arrayLargura[1] = '80px';
	arrayLargura[2] = '80px';
	
		
	var arrayAlinha = new Array();
	arrayAlinha[0] = 'center';
	arrayAlinha[1] = 'center';
	arrayAlinha[2] = 'center';
	arrayAlinha[3] = 'left';
	
	var metodoTabela = 'selecionaIdentificador();';
			
	tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha, metodoTabela );
	
	hideMsgAguardo();
	bloqueiaFundo( $('#divRotina') );

	if ( $.browser.msie ) {	
		$('table > tbody > tr', divRegistro).keypress( function(e) {
			if ( e.keyCode == 13 ) { 
				selecionaIdentificador(); 
				return false; 
			}		
		});
	}
	
	return false;
}

function selecionaIdentificador() {
	
	if ( $('table > tbody > tr', 'div.divRegistros').hasClass('corSelecao') ) {
					
		$('table > tbody > tr', 'div.divRegistros').each( function() {
			if ( $(this).hasClass('corSelecao') ) {
				cdidenti = $('#cdidenti', $(this) ).val();
				cddpagto = $('#cddpagto', $(this) ).val();
				manterRotina();
				return false;
			}	
		});
	}

	return false;
}


// Debitos
function mostraDebitos() {
	
	showMsgAguardo('Aguarde, buscando debitos...');

	// Executa script de confirmação através de ajax
	$.ajax({		
		type: 'POST',
		dataType: 'html',
		url: UrlSite + 'telas/cadgps/debitos.php', 
		data: {
			redirect: 'html_ajax'			
			}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError('error','Não foi possível concluir a requisição.','Alerta - Ayllos',"unblockBackground()");
		},
		success: function(response) {
			$('#divRotina').html(response);
			buscaDebitos();
		}				
	});
	return false;
	
}

function buscaDebitos() {
		
	showMsgAguardo('Aguarde, buscando debitos...');

	var nrdconta = normalizaNumero($('#nrdconta', '#'+frmCadgps).val());	
	var idseqttl = normalizaNumero($('#idseqttl', '#'+frmCadgps).val());
	
	$.ajax({		
		type: 'POST',
		dataType: 'html',
		url: UrlSite + 'telas/cadgps/busca_debitos.php', 
		data: {
			cdidenti: cdidenti, cddpagto: cddpagto, 
			nrdconta: nrdconta, idseqttl: idseqttl,
			redirect: 'script_ajax'			
			}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError('error','Não foi possível concluir a requisição.','Alerta - Ayllos',"unblockBackground();");
		},
		success: function(response) {
		
			if ( response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1 ) {
				try {
					$('#divConteudoOpcao').html(response);
					exibeRotina($('#divRotina'));
					formataDebitos();
					$('#cdidenti','#'+frmCabCadgps).desabilitaCampo();
					$('#opcao','#'+frmCabCadgps).habilitaCampo();
					return false;
				} catch(error) {
					hideMsgAguardo();
					showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','unblockBackground()');
				}
			} else {
				try {
					eval( response );
					controlaFoco();
				} catch(error) {
					hideMsgAguardo();
					showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','unblockBackground()');
				}
			}
		}				
	});
	return false;
}

function formataDebitos() {

	$('#divConteudoOpcao', '#telaDebitos').css({'width':'580px'});

 	// rotulos 
	var rFlgdbaut	= $('label[for="flgdbaut"]','#'+frmCadgpsDebito);
	var rInpessoa	= $('label[for="inpessoa"]','#'+frmCadgpsDebito);
	var rNrctadeb	= $('label[for="nrctadeb"]','#'+frmCadgpsDebito);
	var rNmctadeb	= $('label[for="nmctadeb"]','#'+frmCadgpsDebito);
	var rVlrdinss	= $('label[for="vlrdinss"]','#'+frmCadgpsDebito);
	var rVloutent	= $('label[for="vloutent"]','#'+frmCadgpsDebito);
	var rVlrjuros	= $('label[for="vlrjuros"]','#'+frmCadgpsDebito);
	var rVlrtotal	= $('label[for="vlrtotal"]','#'+frmCadgpsDebito);
	
	rFlgdbaut.addClass('rotulo').css('width','150px');
	rInpessoa.addClass('rotulo-linha').css('width','200px');
	rNrctadeb.addClass('rotulo').css('width','150px');
	rNmctadeb.addClass('rotulo-linha').css('width','40px');
	rVlrdinss.addClass('rotulo').css('width','150px');
	rVloutent.addClass('rotulo').css('width','150px');
	rVlrjuros.addClass('rotulo').css('width','150px');
	rVlrtotal.addClass('rotulo').css('width','150px');
	
	// campos
	var cTodos	  	= $('input[type="text"],select','#'+frmCadgpsDebito);
	var cFlgdbaut	= $('#flgdbaut','#'+frmCadgpsDebito);	
	var cInpessoa	= $('#inpessoa','#'+frmCadgpsDebito);	
	var cNrctadeb	= $('#nrctadeb','#'+frmCadgpsDebito);	
	var cNmctadeb	= $('#nmctadeb','#'+frmCadgpsDebito);	
	var cVlrdinss	= $('#vlrdinss','#'+frmCadgpsDebito);	
	var cVloutent	= $('#vloutent','#'+frmCadgpsDebito);	
	var cVlrjuros	= $('#vlrjuros','#'+frmCadgpsDebito);	
	var cVlrtotal	= $('#vlrtotal','#'+frmCadgpsDebito);	

	cTodos.desabilitaCampo();
	cFlgdbaut.css('width','60px');
	cInpessoa.css('width','90px');
	cNrctadeb.addClass('pesquisa conta').css('width','90px');
	cNmctadeb.css('width','231px').attr('maxlength','40');
	cVlrdinss.addClass('moeda').css('width','90px');
	cVloutent.addClass('moeda').css('width','90px');
	cVlrjuros.addClass('moeda').css('width','90px');
	cVlrtotal.addClass('moeda').css('width','90px');

	// ie
	if ( $.browser.msie ) {	
		cNmctadeb.css('width','229px');
	}
	
	if ( operacao != '' ) {
	
		cFlgdbaut.habilitaCampo().focus();

		// Se pressionar o botao OK
		cFlgdbaut.next().unbind('click').bind('click', function() { 	
			if ( divError.css('display') == 'block' ) { return false; }		
			if ( cFlgdbaut.hasClass('campoTelaSemBorda') ) { return false; }
			if ( msgretor != '') { 	showError('error',msgretor,'Alerta - Ayllos','fechaRotina($(\'#divRotina\'));'); return false; }
			
			if (cFlgdbaut.val() == 'no') {
				//operacao = 'D6';
				//controlaOperacao();
				$('#'+frmCadgpsDebito).limpaFormulario();
				cFlgdbaut.val('no');
				$('#btSalvar','#divConteudoOpcao').focus();
			} else if (cFlgdbaut.val() == 'yes') {
				cInpessoa.habilitaCampo().focus();
				cNrctadeb.habilitaCampo();
				cFlgdbaut.desabilitaCampo();
				controlaPesquisas();
			}
			
			return false;
			
		});	
	
		// Busca o nome do titular ao pressionar ENTER
		cNrctadeb.unbind('keypress').bind('keypress', function(e) {	
			if ( divError.css('display') == 'block' ) { return false; }	
			if ( e.keyCode == 13 ) {

				// Armazena o número da conta na variável global
				var inpessoa = normalizaNumero( $('#inpessoa','#'+frmCadgpsDebito).val() );
				
				// Verifica se a conta é válida
				if ( inpessoa == '' ) { 
					showError('error','Tipo de pessoa invalido.','Alerta - Ayllos','bloqueiaFundo( $(\'#divRotina\') ); $(\'#inpessoa\',\'#\'+frmCadgpsDebito).focus();'); 
					return false; 
				}
				
				operacao = 'D4';		
				manterRotina();
				return false;
			}
		});
		
		// Recalcula o valor total do debito ao digitar um novo valor
		cVlrdinss.unbind('change').bind('change', function(e) {
			var vlrtotal = 0;
			valor		 = $(this).val() == '' ? 0 : $(this).val();
			vlrtotal 	 = calculaDebitos( valor, cVloutent.val(), cVlrjuros.val() );
			cVlrtotal.val( vlrtotal ); 	
		});
		
		// Recalcula o valor total do debito ao digitar um novo valor
		cVloutent.unbind('change').bind('change', function(e) {
			var vlrtotal = 0;
			valor		 = $(this).val() == '' ? 0 : $(this).val();
			vlrtotal 	 = calculaDebitos( cVlrdinss.val(), valor, cVlrjuros.val() );
			cVlrtotal.val(vlrtotal); 	
		});
		
		// Recalcula o valor total do debito ao digitar um novo valor
		cVlrjuros.unbind('change').bind('change', function(e) {
			var vlrtotal = 0;
			valor		 = $(this).val() == '' ? 0 : $(this).val();
			vlrtotal 	 = calculaDebitos( cVlrdinss.val(), cVloutent.val(), valor );
			cVlrtotal.val( vlrtotal );
		});
		
		// Conclui a operação	
		$('#btSalvar','#divConteudoOpcao').unbind('click').bind('click', function(e) {	
			if ( divError.css('display') == 'block' ) { return false; }	
			if ( cFlgdbaut.val() == 'yes' && cVlrdinss.hasClass('campoTelaSemBorda') ) { return false; }
			
			operacao = 'D6';
			
			if ( cFlgdbaut.val() == 'no' ) {
				controlaOperacao();
			} else  if ( cFlgdbaut.val() == 'yes' ) {
				manterRotina();
			}
			
			return false;
		});

		$('#btSalvar', '#'+frmCadgpsDebito).css({'display':''});
	
	} else {
		$('#btSalvar', '#'+frmCadgpsDebito).css({'display':'none'});
	}
	
	layoutPadrao();
	cNrctadeb.trigger('blur');
	hideMsgAguardo();
	bloqueiaFundo( $('#divRotina') );
	
	return false;
}

function calculaDebitos(vlrdinss,vloutent,vlrjuros){

	var vlrtotal = 0;
	
	// Converte para float
	vlrdinss  = converteMoedaFloat(vlrdinss);
	vloutent  = converteMoedaFloat(vloutent);
	vlrjuros  = converteMoedaFloat(vlrjuros);

	// Soma os valores
	vlrtotal  = vlrdinss + 	vloutent + vlrjuros;
	vlrtotal  = number_format(vlrtotal,2,',','');

	return vlrtotal;

}


// Titular
function mostraTitulares() {
	
	showMsgAguardo('Aguarde, buscando titular...');

	// Executa script de confirmação através de ajax
	$.ajax({		
		type: 'POST',
		dataType: 'html',
		url: UrlSite + 'telas/cadgps/titulares.php', 
		data: {
			redirect: 'html_ajax'			
			}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError('error','Não foi possível concluir a requisição.','Alerta - Ayllos',"unblockBackground()");
		},
		success: function(response) {
			$('#divRotina').html(response);
			buscaTitulares();
			return false;
		}				
	});
	return false;
	
}

function buscaTitulares() {
		
	showMsgAguardo('Aguarde, buscando titular...');

	var nrdconta = normalizaNumero($('#nrdconta', '#'+frmCadgps).val());	
	
	$.ajax({		
		type: 'POST',
		dataType: 'html',
		url: UrlSite + 'telas/cadgps/busca_titulares.php', 
		data: {
			nrdconta: nrdconta, 
			redirect: 'script_ajax'			
			}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError('error','Não foi possível concluir a requisição.','Alerta - Ayllos',"unblockBackground();");
		},
		success: function(response) {
		
			if ( response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1 ) {
				try {
					$('#divConteudoTitular').html(response);
					exibeRotina($('#divRotina'));
					formataTitulares();
					return false;
				} catch(error) {
					hideMsgAguardo();
					showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','unblockBackground()');
				}
			} else {
				try {
					eval( response );
					controlaFoco();
				} catch(error) {
					hideMsgAguardo();
					showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','unblockBackground()');
				}
			}
		}				
	});
	return false;
}

function formataTitulares() {

	var divRegistro = $('div.divRegistros','#divTitulares');		
	var tabela      = $('table', divRegistro );
	var linha       = $('table > tbody > tr', divRegistro );
			
	divRegistro.css({'height':'120px','width':'400px'});
	
	var ordemInicial = new Array();
	ordemInicial = [[0,0]];
			
	var arrayLargura = new Array();
	arrayLargura[0] = '50px';
	
		
	var arrayAlinha = new Array();
	arrayAlinha[0] = 'center';
	arrayAlinha[1] = 'left';
	
	var metodoTabela = 'selecionaTitular();';
			
	tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha, metodoTabela );
	
	hideMsgAguardo();
	bloqueiaFundo( $('#divRotina') );
	
	return false;
}

function selecionaTitular() {
	
	if ( $('table > tbody > tr', 'div.divRegistros').hasClass('corSelecao') ) {
					
		$('table > tbody > tr', 'div.divRegistros').each( function() {
			if ( $(this).hasClass('corSelecao') ) {
				$('#idseqttl', '#'+frmCadgps ).val( $('#idseqttl', $(this) ).val() ).desabilitaCampo();
			}	
		});
	}
	
	fechaRotina($('#divRotina'));
	manterRotina();
	controlaPesquisas();
	return false;
}


// Botão
function btnContinuar() {

	if ( divError.css('display') == 'block' ) { return false; }	
	
	if ( operacao == '') {
		operacao = $('#opcao','#'+frmCabCadgps).val();
		$('#opcao','#'+frmCabCadgps).desabilitaCampo();

		// limpa formulario
		$('#cdidenti','#'+frmCabCadgps).val('');
		$('#cddpagto','#'+frmCabCadgps).val('');
		$('#frmCadgps').limpaFormulario();

		$('#tpcontri','#'+frmCadgps).val('1');
		$('#flgrgatv','#'+frmCadgps).val('yes');

		manterRotina();

	} else if ( operacao == 'C2' || operacao == 'A2' || operacao == 'D2' ) {
		mostraIdentificadores( 1 , 30 );
	
	} else if ( operacao == 'I2' ) {
		cdidenti = normalizaNumero( $('#cdidenti','#'+frmCabCadgps).val() );
		manterRotina();

	} else if ( operacao == 'A4' || operacao == 'I4' ) {
		nrdconta = normalizaNumero( $('#nrdconta','#'+frmCadgps).val() );
	
		// Verifica se a conta é válida
		if ( !validaNroConta(nrdconta) && nrdconta != 0) { 
			showError('error','Conta/dv inválida.','Alerta - Ayllos','focaCampoErro(\'nrdconta\',\'frmCadgps\');'); 
			return false; 
		}

		manterRotina();

	} else if ( ( operacao == 'A5' || operacao == 'I5' ) && $('#idseqttl','#'+frmCadgps).hasClass('campo') ) {		

		var idseqttl = normalizaNumero( $('#idseqttl','#'+frmCadgps).val() );
		
		if ( idseqttl == 0 ) {
			mostraTitulares();
		} else {
			$('#idseqttl','#'+frmCadgps).desabilitaCampo();
			manterRotina();
		}
		controlaPesquisas();	
	
	} else if ( operacao == 'A5' || operacao == 'I5') {
		controlaOperacao();
		
	} else if ( operacao == 'I8' ) {
		cddpagto = normalizaNumero( $('#cddpagto','#'+frmCabCadgps).val() );
		$('#cddpagto','#'+frmCabCadgps).desabilitaCampo();
		manterRotina();	
	}

}

function trocaBotao( botao ) {
	
	$('#divBotoes','#'+frmCadgps).html('');
	$('#divBotoes','#'+frmCadgps).append('<a href="#" class="botao" id="btVoltar" onClick="estadoInicial(); return false;" >Voltar</a>');
	
	if ( botao == 'prosseguir' ) {
		$('#divBotoes','#'+frmCadgps).append('<a href="#" class="botao" id="btSalvar" onClick="btnContinuar(); return false;">Prosseguir</a>');
	} else if ( botao == 'concluir' ) {
		$('#divBotoes','#'+frmCadgps).append('<a href="#" class="botao" id="btSalvar" onClick="btnContinuar(); return false;">Concluir</a>');
	}
	
	return false;
}


function controlafrmCadgpsDebito() {

	$('#inpessoa','#frmCadgpsDebito').unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {	
			$('#nrctadeb','#frmCadgpsDebito').focus();
			return false;
		}	
	});		
	
	$('#nrctadeb','#frmCadgpsDebito').unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {	
			$('#vlrdinss','#frmCadgpsDebito').focus();
			return false;
		}	
	});
	
	$('#vlrdinss','#frmCadgpsDebito').unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {	
			$('#vloutent','#frmCadgpsDebito').focus();
			return false;
		}	
	});		
	
	$('#vloutent','#frmCadgpsDebito').unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {	
			$('#vlrjuros','#frmCadgpsDebito').focus();
			return false;
		}	
	});
	
	$('#vlrjuros','#frmCadgpsDebito').unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {	
			$('#btSalvar','#frmCadgpsDebito').focus();
			return false;
		}	
	});
}
