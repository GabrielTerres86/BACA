/*!
 * FONTE        : altava.js
 * CRIA��O      : Rogerius Milit�o (DB1) 
 * DATA CRIA��O : 21/12/2011
 * OBJETIVO     : Biblioteca de fun��es da tela ALTAVA
 * --------------
 * ALTERA��ES   :
 * --------------
 * 28/06/2012 - Jorge                (CECRED) : Alterado funcao Gera_Impressao(), novo esquema para impressao
 * 21/11/2012 - Daniel		         (CECRED) : Incluso funcao ControlaFocusAvalista, alterado funcao formataMsgAjuda
 *										        para nao mostrar mais informacoes via tag <span>, alterado bot�es
 *										        do tipo tag <input> por tag <a> (Daniel).
 * 15/07/2014 - Daniel        		 (CECRED) : Novo tratamento para campo tipo de pessoa e data nascimento.
 *
 * 30/12/2014 - Kelvin (SD - 233714) (CECRED) : Padronizando a mascara do campo nrctremp.
 *							            	    10 Digitos - Campos usados apenas para visualiza��o
 *										       	8 Digitos - Campos usados para alterar ou incluir novos contratos	
 *							   
 *
 */

//Formul�rios e Tabela
var frmCab   		= 'frmCab';
var frmDados		= 'frmAltava';

var nrctremp		= 0;
var nrctatos		= 0;

var avalista		= '';
var qtdavali		= 0;
var nrindice		= 0;
var flgalter		= 'N';

var nomeForm 		= 'frmAvalista'; // Endereco

var nrJanelas		= 0;
var fiadores		= new Array();

var rNrdconta, rNmprimtl,
	cNrdconta, cNmprimtl, cTodosCabecalho, btnOK1;

var rNrctremp, rDslcremp, rDsfinemp, rVlemprst, rVlpreemp, rQtpreemp,
	cNrctremp, cDslcremp, cDsfinemp, cVlemprst, cVlpreemp, cQtpreemp, cTodosDados, btnOK2;

var cNrctaava, cNmdavali, cNrcpfcgc, cTpdocava, cNrdocava, cNmconjug, cNrcpfcjg, cTpdoccjg, cNrdoccjg, cNrcepend, 
	cDsendre1, cNrendere, cComplend, cNrcxapst, cDsendre2, cCdufresd, cNmcidade, cDsdemail, cNrfonres, btnOK3,
	cInpessoa, cDtnascto;


$(document).ready(function() {
	estadoInicial();
});

// inicio
function estadoInicial() {
	$('#divTela').fadeTo(0,0.1);
	
	$('#frmCab').css({'display':'block'});
	$('#divBotoes', '#divTela').css({'display':'block'});
	
	fiadores		= new Array();

	// retira as mensagens	
	hideMsgAguardo();

	// formailzia	
	formataCabecalho();
	formataDados();
	formataMsgAjuda('divTela');
	
	// remove o campo prosseguir
	trocaBotao('');	
	
	// inicializa com a frase de ajuda para o campo cddopcao
	$('span:eq(0)', '#divMsgAjuda').html( cNrdconta.attr('alt') );

	// limpa a tela de rotina
	fechaRotina( $('#divRotina') );
	
	//
	cTodosCabecalho.limpaFormulario().removeClass('campoErro');	
	cTodosDados.limpaFormulario().removeClass('campoErro');	

	$('#'+frmDados).css({'display':'none'});
	
	
	cNrdconta.focus();
	removeOpacidade('divTela');
	
	highlightObjFocus( $('#frmCab') );			

	cNrdconta.focus();
	
}


// controle
function controlaOperacao() {
	
	var nrdconta = normalizaNumero( cNrdconta.val() );
	
	var mensagem = 'Aguarde, buscando dados ...';
	showMsgAguardo( mensagem );	
	
	// Carrega dados da conta atrav�s de ajax
	$.ajax({		
		type	: 'POST',
		dataType: 'html',
		url		: UrlSite + 'telas/altava/principal.php', 
		data    : 
				{ 
					nrdconta	: nrdconta, 
					redirect	: 'script_ajax' 
				},
		error   : function(objAjax,responseError,objExcept) {
					hideMsgAguardo();					
					showError('error','N&atilde;o foi poss�vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','estadoInicial();');
				},
		success : function(response) {
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

function manterRotina( operacao ) {
		
	hideMsgAguardo();		
	
	var mensagem = '';
	var nrdconta = normalizaNumero( $('#nrdconta','#'+frmCab).val() );
	
	var nrctaava = normalizaNumero( $('#nrctaava', '#frmAvalista').val() );	
	var nmdavali = $('#nmdavali', '#frmAvalista').val();	
	var dscpfcgc = $('#nrdocava', '#frmAvalista').val();	
	var nrcpfcgc = normalizaNumero( $('#nrcpfcgc', '#frmAvalista').val() );	
	var tpdocava = $('#tpdocava', '#frmAvalista').val();	
	var nmconjug = $('#nmconjug', '#frmAvalista').val();	
	var tpdoccjg = $('#tpdoccjg', '#frmAvalista').val();	
	var dscpfcjg = $('#nrdoccjg', '#frmAvalista').val();	
	var nrcpfcjg = normalizaNumero( $('#nrcpfcjg', '#frmAvalista').val() );	
	var nrcepend = normalizaNumero( $('#nrcepend', '#frmAvalista').val() );	
	var dsendre1 = $('#dsendre1', '#frmAvalista').val();	
	var nrendere = $('#nrendere', '#frmAvalista').val();	
	var complend = $('#complend', '#frmAvalista').val();	
	var nrcxapst = normalizaNumero( $('#nrcxapst', '#frmAvalista').val() );	
	var dsendre2 = $('#dsendre2', '#frmAvalista').val();	
	var cdufresd = $('#cdufresd', '#frmAvalista').val();	
	var nmcidade = $('#nmcidade', '#frmAvalista').val();	
	var dsdemail = $('#dsdemail', '#frmAvalista').val();	
	var nrfonres = $('#nrfonres', '#frmAvalista').val();	
	
	var inpessoa = $('#inpessoa', '#frmAvalista').val();
	var dtnascto = $('#dtnascto', '#frmAvalista').val();
	
	switch ( operacao ) {
		case 'BC'	: mensagem = 'Aguarde, buscando dados ...'; 	break;
		case 'VA'	: mensagem = 'Aguarde, validando dados ...';	break;
		case 'VC'	: mensagem = 'Aguarde, validando dados ...';	break;
		case 'BA'	: mensagem = 'Aguarde, buscando dados ...';		break;
		case 'GD'	: mensagem = 'Aguarde, gravando dados ...';		break;
		default		: return false; 								break;
	}
		
	showMsgAguardo( mensagem );	
	
	$.ajax({		
			type  : 'POST',
			url   : UrlSite + 'telas/altava/manter_rotina.php', 		
			data: {
				operacao	: operacao,
				nrdconta	: nrdconta,
				nrctremp	: nrctremp,
				nrindice	: nrindice,
				nrctaava	: nrctaava,	
				nmdavali    : nmdavali,
				dscpfcgc    : dscpfcgc,
				nrcpfcgc    : nrcpfcgc,
				tpdocava    : tpdocava,
				nmconjug    : nmconjug,
				tpdoccjg    : tpdoccjg,
				dscpfcjg    : dscpfcjg,
				nrcpfcjg    : nrcpfcjg,
				nrcepend    : nrcepend,
				dsendre1    : dsendre1,
				nrendere    : nrendere,
				complend    : complend,
				nrcxapst    : nrcxapst,
				dsendre2    : dsendre2,
				cdufresd    : cdufresd,
				nmcidade    : nmcidade,
				dsdemail    : dsdemail,
				nrfonres    : nrfonres,
				avalista	: avalista,
				inpessoa    : inpessoa,
				dtnascto    : dtnascto,
				redirect	: 'script_ajax'
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

function controlaPesquisas() {

	// a variavel camposOrigem deve ser composta:
	// 1) os cincos primeiros campos s�o os retornados para o formulario de origem
	// 2) o sexto campo � o campo q ser� focado ap�s o retorno ao formulario de origem, que
	// pelo requisito na maioria dos casos ser� o NUMERO do endere�o	
	var camposOrigem = 'nrcepend;dsendre1;nrendere;complend;nrcxapst;dsendre2;cdufresd;nmcidade';	

	// Atribui a classe lupa para os links e desabilita todos
	$('a','#'+nomeForm).addClass('lupa').css('cursor','auto');	
	
	// Percorrendo todos os links
	$('a','#'+nomeForm).each( function() {
		if ( !$(this).prev().hasClass('campoTelaSemBorda') ) { $(this).css('cursor','pointer'); }
	});
	
	/*---------------------*/
	/*  CONTROLE CONTA/DV  */
	/*---------------------*/
	var linkConta = $('a:eq(0)','#'+ frmCab );

	if ( linkConta.prev().hasClass('campoTelaSemBorda') ) {		
		linkConta.addClass('lupa').css('cursor','auto').unbind('click').bind('click', function() { return false; });
	} else {
		linkConta.css('cursor','pointer').unbind('click').bind('click', function() {			
			mostraPesquisaAssociado('nrdconta', frmCab );
		});
	}

	/*--------------------*/
	/*  CONTROLE CONTRATO */
	/*--------------------*/
	var linkContrato = $('a:eq(2)','#'+ frmCab);
	
	if ( linkContrato.prev().hasClass('campoTelaSemBorda') ) {		
		linkContrato.addClass('lupa').css('cursor','auto').unbind('click').bind('click', function() { return false; });
	} else {
		linkContrato.css('cursor','pointer').unbind('click').bind('click', function() {			
			mostraContrato();
		});
	}	


	/*---------------------*/
	/*  CONTROLE CONTA/DV  */
	/*---------------------*/
	var linkConta = $('a:eq(0)','#frmAvalista' );

	if ( linkConta.prev().hasClass('campoTelaSemBorda') ) {		
		linkConta.addClass('lupa').css('cursor','auto').unbind('click').bind('click', function() { return false; });
	} else {
		linkConta.css('cursor','pointer').unbind('click').bind('click', function() {			
			mostraPesquisaAssociado('nrctaava', 'frmAvalista', $('#divRotina') );
		});
	}
	
	
	/*----------------------*/
	/*  CONTROLE ENDERECO   */
	/*----------------------*/
	$('#nrcepend','#'+nomeForm).buscaCEP(nomeForm, camposOrigem, divRotina);
	
	ControlaFocusAvalista();
	
	return false;
}


// formata
function formataCabecalho() {

	// cabecalho
	rNrdconta			= $('label[for="nrdconta"]','#'+frmCab); 
	rNmprimtl	        = $('label[for="nmprimtl"]','#'+frmCab);        
	rNrctremp			= $('label[for="nrctremp"]','#'+frmCab);

	cNrctremp			= $('#nrctremp','#'+frmCab);			
	cNrdconta			= $('#nrdconta','#'+frmCab); 
	cNmprimtl			= $('#nmprimtl','#'+frmCab); 
	cTodosCabecalho		= $('input[type="text"],select','#'+frmCab);
	btnOK1				= $('#btnOK1','#'+frmCab);
	btnOK2				= $('#btnOK2','#'+frmCab);

	rNrdconta.addClass('rotulo').css({'width':'40px'});
	rNmprimtl.addClass('rotulo').css({'width':'40px'});
	rNrctremp.addClass('rotulo-linha').css({'width':'338px'});
	
	cNrdconta.addClass('conta pesquisa').css({'width':'80px'})
	cNmprimtl.addClass('alphanum').css({'width':'613px'}).attr('maxlength','48');
	cNrctremp.addClass('pesquisa').css({'width':'80px','text-align':'right'}).setMask('INTEGER','z.zzz.zzz.zzz','.','');	
	
	cNrdconta.habilitaCampo();
	cNmprimtl.desabilitaCampo();
	cNrctremp.desabilitaCampo();

	if ( $.browser.msie ) {
		rNrctremp.css({'width':'342px'});
	}
	
	// Se clicar no botao OK
	btnOK1.unbind('click').bind('click', function() { 	
		
		if ( divError.css('display') == 'block' ) { return false; }		
		if ( cNrdconta.hasClass('campoTelaSemBorda')  ) { return false; }		
		
		// Armazena o n�mero da conta na vari�vel global
		var nrdconta = normalizaNumero( cNrdconta.val() );
		
		// Verifica se o n�mero da conta � vazio
		if ( nrdconta == '' ) { return false; }
	
		// Verifica se a conta � v�lida
		if ( !validaNroConta(nrdconta) ) { 
			showError('error','Conta/dv inv&aacute;lida.','Alerta - Ayllos','focaCampoErro(\'nrdconta\',\''+ frmCab +'\');'); 
			return false; 
		}

		cTodosCabecalho.removeClass('campoErro');	
		
		// Se chegou at� aqui, a conta � diferente do vazio e � v�lida, ent�o realizar a opera��o desejada
		controlaOperacao();
		return false;
			
	});	

	cNrdconta.unbind('keypress').bind('keypress', function(e) {
		if ( divError.css('display') == 'block' ) { return false; }		
		// Se � a tecla ENTER, 
		if ( e.keyCode == 13 ) {
			if (cNrdconta.val() == '' ) {
				mostraPesquisaAssociado('nrdconta', frmCab );
				return false;
			}
			btnOK1.click();
			return false;
		} else if ( e.keyCode == 118 ) {
			mostraPesquisaAssociado('nrdconta', frmCab );
			return false;
		}
	});	

	// Se clicar no botao OK
	btnOK2.unbind('click').bind('click', function() { 	
		
		if ( divError.css('display') == 'block' ) { return false; }		
		if ( cNrctremp.hasClass('campoTelaSemBorda')  ) { return false; }		

		// Armazena o n�mero da conta na vari�vel global
		nrctremp = normalizaNumero( cNrctremp.val() );
		
		// Verifica se o n�mero da conta � vazio
		if ( nrctremp == '' ) { return false; }
	
		cTodosCabecalho.removeClass('campoErro');	
		
		// Se chegou at� aqui, a conta � diferente do vazio e � v�lida, ent�o realizar a opera��o desejada
		manterRotina('BC');
		return false;
			
	});	

	cNrctremp.unbind('keypress').bind('keypress', function(e) {
		if ( divError.css('display') == 'block' ) { return false; }		
		if ( $('#divRotina').css('visibility') == 'visible' ) { 
			if ( e.keyCode == 13 ) { selecionaContrato(); return false; }
		}		

		// Se � a tecla ENTER, 
		if ( e.keyCode == 13 ) {
			nrctremp = normalizaNumero( $(this).val() );

			if ( nrctremp == 0 ) {
				mostraContrato();
			} else {
				btnOK2.click();
			}
			
			return false;

		} 
	});	
	
	layoutPadrao();
	controlaPesquisas();
	return false;	
}

function formataDados() {

	// label
	rDslcremp			= $('label[for="dslcremp"]','#'+frmDados);
	rDsfinemp			= $('label[for="dsfinemp"]','#'+frmDados);
	rVlemprst			= $('label[for="vlemprst"]','#'+frmDados);
	rVlpreemp			= $('label[for="vlpreemp"]','#'+frmDados);
	rQtpreemp			= $('label[for="qtpreemp"]','#'+frmDados);
	
	rDslcremp.addClass('rotulo').css({'width':'75px'});
	rDsfinemp.addClass('rotulo-linha').css({'width':'65px'});
	rVlemprst.addClass('rotulo').css({'width':'75px'});
	rVlpreemp.addClass('rotulo-linha').css({'width':'135px'});
	rQtpreemp.addClass('rotulo-linha').css({'width':'140px'});
	
	// input
	cDslcremp			= $('#dslcremp', '#'+frmDados);
	cDsfinemp			= $('#dsfinemp', '#'+frmDados);
	cVlemprst			= $('#vlemprst', '#'+frmDados);
	cVlpreemp			= $('#vlpreemp', '#'+frmDados);
	cQtpreemp			= $('#qtpreemp', '#'+frmDados);	
	cTodosDados		= $('input[type="text"],select','#'+frmDados);

	cDslcremp.css({'width':'250px'});
	cDsfinemp.css({'width':'250px'});
	cVlemprst.css({'width':'95px'});	
	cVlpreemp.css({'width':'95px'});	
	cQtpreemp.css({'width':'95px'});	

	if ( $.browser.msie ) {
		rDslcremp.css({'width':'77px'});
		rDsfinemp.css({'width':'65px'});
		rVlemprst.css({'width':'77px'});
		rQtpreemp.css({'width':'142px'});
	}

	cTodosDados.desabilitaCampo();
	layoutPadrao();
	controlaPesquisas();
	return false;	
	
}

function formataAvalista() {
	
	/* AVALISTA */
	// label
	rNrctaava = $('label[for="nrctaava"]', '#frmAvalista');
	rNmdavali = $('label[for="nmdavali"]', '#frmAvalista');
	rNrcpfcgc = $('label[for="nrcpfcgc"]', '#frmAvalista');
	rTpdocava = $('label[for="tpdocava"]', '#frmAvalista');
	rInpessoa = $('label[for="inpessoa"]', '#frmAvalista');
	rDtnascto = $('label[for="dtnascto"]', '#frmAvalista'); 

	rNrctaava.addClass('rotulo').css({'width':'50px'});
	rNmdavali.addClass('rotulo').css({'width':'50px'});
	rNrcpfcgc.addClass('rotulo').css({'width':'50px'});
	rTpdocava.addClass('rotulo-linha').css({'width':'35px'});
	
	rInpessoa.addClass('rotulo').css({'width':'50px'});
	rDtnascto.addClass('rotulo-linha').css({'width':'90px'});
	
	// input
	cNrctaava = $('#nrctaava', '#frmAvalista');
	cNmdavali = $('#nmdavali', '#frmAvalista');
	cNrcpfcgc = $('#nrcpfcgc', '#frmAvalista');
	cTpdocava = $('#tpdocava', '#frmAvalista');
	cNrdocava = $('#nrdocava', '#frmAvalista');
	
	cInpessoa = $('#inpessoa', '#frmAvalista');
	cDtnascto = $('#dtnascto', '#frmAvalista');

	cNrctaava.addClass('conta pesquisa').css({'width':'120px'});
	cNmdavali.addClass('alphanum').css({'width':'427px'}).attr('maxlength','40');
	cNrcpfcgc.addClass('inteiro').css({'width':'120px'}).attr('maxlength','14');
	cTpdocava.css({'width':'42px'});
	cNrdocava.addClass('alphanum').css({'width':'221px'}).attr('maxlength','40');
	
	cInpessoa.css({'width':'100px'});
	cDtnascto.addClass('data').css({'width':'80px'});
	
	/* CONJUGE */
	// label
	rNmconjug = $('label[for="nmconjug"]', '#frmAvalista');	
	rNrcpfcjg = $('label[for="nrcpfcjg"]', '#frmAvalista');
	rTpdoccjg = $('label[for="tpdoccjg"]', '#frmAvalista');

	rNmconjug.addClass('rotulo').css({'width':'50px'});
	rNrcpfcjg.addClass('rotulo').css({'width':'50px'});
	rTpdoccjg.addClass('rotulo-linha').css({'width':'35px'});
	
	// input
	cNmconjug = $('#nmconjug', '#frmAvalista');	
	cNrcpfcjg = $('#nrcpfcjg', '#frmAvalista');
	cTpdoccjg = $('#tpdoccjg', '#frmAvalista');
	cNrdoccjg = $('#nrdoccjg', '#frmAvalista');

	cNmconjug.addClass('alphanum').css({'width':'427px'}).attr('maxlength','40');
	cNrcpfcjg.addClass('inteiro').css({'width':'120px'}).attr('maxlength','14');
	cTpdoccjg.css({'width':'42px'});
	cNrdoccjg.addClass('alphanum').css({'width':'221px'}).attr('maxlength','40');
	
	
	/* ENDERECO */ 
	// label
	rNrcepend = $('label[for="nrcepend"]', '#frmAvalista');
	rDsendre1 = $('label[for="dsendre1"]', '#frmAvalista');
	rNrendere = $('label[for="nrendere"]', '#frmAvalista');
	rComplend = $('label[for="complend"]', '#frmAvalista');
	rNrcxapst = $('label[for="nrcxapst"]', '#frmAvalista');
	rDsendre2 = $('label[for="dsendre2"]', '#frmAvalista');
	rCdufresd = $('label[for="cdufresd"]', '#frmAvalista');
	rNmcidade = $('label[for="nmcidade"]', '#frmAvalista');

	rNrcepend.addClass('rotulo').css({'width':'50px'});
	rDsendre1.addClass('rotulo-linha').css({'width':'38px'});
	rNrendere.addClass('rotulo').css({'width':'50px'});
	rComplend.addClass('rotulo-linha').css({'width':'55px'});
	rNrcxapst.addClass('rotulo').css({'width':'50px'});
	rDsendre2.addClass('rotulo-linha').css({'width':'55px'});
	rCdufresd.addClass('rotulo').css({'width':'50px'});
	rNmcidade.addClass('rotulo-linha').css({'width':'55px'});
	
	// input
	cNrcepend = $('#nrcepend', '#frmAvalista');
	cDsendre1 = $('#dsendre1', '#frmAvalista');
	cNrendere = $('#nrendere', '#frmAvalista');
	cComplend = $('#complend', '#frmAvalista');
	cNrcxapst = $('#nrcxapst', '#frmAvalista');
	cDsendre2 = $('#dsendre2', '#frmAvalista');
	cCdufresd = $('#cdufresd', '#frmAvalista');
	cNmcidade = $('#nmcidade', '#frmAvalista');

	cNrcepend.addClass('cep pesquisa').css({'width':'75px'}).attr('maxlength','9');
	cDsendre1.addClass('alphanum').css({'width':'291px'}).attr('maxlength','40');
	cNrendere.addClass('numerocasa').css({'width':'75px'}).attr('maxlength','7');
	cComplend.addClass('alphanum').css({'width':'291px'}).attr('maxlength','40');
	cNrcxapst.addClass('caixapostal').css({'width':'75px'}).attr('maxlength','6');
	cDsendre2.addClass('alphanum').css({'width':'291px'}).attr('maxlength','40');	
	cCdufresd.css({'width':'75px'});
	cNmcidade.addClass('alphanum').css({'width':'291px'}).attr('maxlength','25');
	
	
	/* CONTATO */
	// label
	rDsdemail = $('label[for="dsdemail"]', '#frmAvalista');
	rNrfonres = $('label[for="nrfonres"]', '#frmAvalista');

	rDsdemail.addClass('rotulo').css({'width':'50px'});
	rNrfonres.addClass('rotulo-linha').css({'width':'39px'});

	
	// input
	cDsdemail = $('#dsdemail', '#frmAvalista');
	cNrfonres = $('#nrfonres', '#frmAvalista');
	
	cDsdemail.addClass('alphanum').css({'width':'240px'}).attr('maxlength','32');
	cNrfonres.addClass('alphanum').css({'width':'143px'}).attr('maxlength','20');

	
	/* OUTROS */	
	cTodosAvalista 	= $('input, select', '#frmAvalista');
	btnOK3 			= $('#btnOK3', '#frmAvalista');


	/* IE */
	if ( $.browser.msie ) {
		cNmdavali.css({'width':'424px'});
		cNmconjug.css({'width':'424px'});
	}

	// 
	cTodosAvalista.desabilitaCampo();
	
	//
	if ( flgalter == 'S' ) {
		cNrctaava.habilitaCampo();
	} else {
		$('span:eq(0)', '#divRotina #divMsgAjuda').html( 'Pressione F1 para continuar.' );
	
	}

	// Se clicar no botao OK
	btnOK3.unbind('click').bind('click', function() { 	
		if ( divError.css('display') == 'block' ) { return false; }		
		if ( cNrctaava.hasClass('campoTelaSemBorda')  ) { return false; }		
		
		var nrctaava = normalizaNumero( cNrctaava.val() );
		
		if ( nrctaava > 0 ) {
			
			// Verifica se a conta � v�lida
			if ( !validaNroConta(nrctaava) ) { 
				showError('error','Conta/dv inv&aacute;lida.','Alerta - Ayllos','focaCampoErro(\'nrctaava\',\'frmAvalista\'); bloqueiaFundo( $(\'#divRotina\') );'); 
				return false; 
			}
			
			//
			manterRotina('VC');
		
		} else {
			cTodosAvalista.habilitaCampo();
			cNrctaava.desabilitaCampo();
			cDsendre1.desabilitaCampo();
            cDsendre2.desabilitaCampo();
            cCdufresd.desabilitaCampo();
	        cNmcidade.desabilitaCampo();
			cNmdavali.focus();
		}

		controlaPesquisas();		
		return false;
	
	});
	
	/* Busca o avalista que tem conta */
	cNrctaava.unbind('keypress').bind('keypress', function(e) {
		if ( divError.css('display') == 'block' ) { return false; }		
		// Se � a tecla ENTER, 
		if ( e.keyCode == 13 ) {
			btnOK3.click();
			return false;
		} 
		
	});	
	
	/* Busca o avalista com o cpf */
	cNrcpfcgc.unbind('keypress').bind('keypress', function(e) {
		if ( divError.css('display') == 'block' ) { return false; }		
		// Se � a tecla ENTER, 
		if ( e.keyCode == 13 ) {
			
			var nrcpfant = normalizaNumero( $('#nrcpfant', '#frmAvalista').val() );
			var nrcpfcgc = normalizaNumero( $(this).val() );
			
			if ( verificaTipoPessoa(nrcpfcgc) > 0 && nrcpfcgc != nrcpfant ) {
				manterRotina('BA');                  
			}
			
			return false;
		} 
		
	});	

	// centraliza a divRotina
	$('#divRotina').css({'width':'525px'});
	$('#divConteudo').css({'width':'500px'});
	$('#divRotina').centralizaRotinaH();
	
	formataMsgAjuda('divRotina');
	layoutPadrao();
	cNrcepend.trigger('blur');
	cNrctaava.focus();
	controlaPesquisas();
	return false;
}


function controlaLayout() {

	if ( ! cNrdconta.hasClass('campoTelaSemBorda') ) { 
	
		nrctatos = parseInt( nrctatos );
		cNrdconta.desabilitaCampo();
		
		// Verifica se tem um contrato
		if ( nrctatos == 1 ) {
			cNrctremp.val( nrctremp );
			cNrctremp.trigger('blur');
			manterRotina('BC');
		} else {
			hideMsgAguardo();
		}

		formataMsgAjuda('divTela');
		cNrctremp.habilitaCampo();
		cNrctremp.focus();
		
	} else if ( ! cNrctremp.hasClass('campoTelaSemBorda')) {
		cNrctremp.desabilitaCampo();
		trocaBotao('prosseguir');
		$('#'+frmDados).css({'display':'block'});
		$('span:eq(0)', '#divMsgAjuda').html('Pressione F1 para prosseguir.');
		
		// seta as variaveis
		nrindice 		= 0;		
		flgalter 		= 'N';
		hideMsgAguardo();

		$('#btSalvar','#divBotoes').focus();
		
	} else {

		hideMsgAguardo();
	
		if ( nrindice == 2 || ( normalizaNumero( cNrctaava.val() ) == 0 && trim( cNmdavali.val() ) == '') ) {
			showConfirmacao('Confirmar opera��o?','Confirma&ccedil;&atilde;o - Ayllos','manterRotina(\'GD\');','fechaAvalista();','sim.gif','nao.gif');
		} else {
			mostraAvalista();
		}		
		
	}
	
	controlaPesquisas();
	return false;
}


// avalista
function mostraAvalista() {

	var mensagem = 'Aguarde, buscando dados ...';
 	showMsgAguardo(mensagem);

	nrindice = nrindice + 1;
	
	if ( (nrindice > qtdavali || qtdavali == 1) && flgalter== 'N' ) {
		nrindice = 1;
		flgalter = 'S';
	} 
	
	// Executa script de confirma��o atrav�s de ajax
	$.ajax({		
		type: 'POST',
		dataType: 'html',
		url: UrlSite + 'telas/altava/form_avalista.php', 
		data: {
			nrindice: nrindice,
			avalista: avalista,
			flgalter: flgalter,
			redirect: 'html_ajax'			
			}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();			
			showError('error','N�o foi poss�vel concluir a requisi��o.','Alerta - Ayllos',"unblockBackground()");
		},
		success: function(response) {
			hideMsgAguardo();

			$('#divRotina').html(response);
			exibeRotina( $('#divRotina') );

			formataAvalista();
			return false;
		}				
	});
	return false;
	
}

function fechaAvalista() {

	//
	hideMsgAguardo();
	
	fechaRotina( $('#divRotina') );
	$('#divRotina').html('');

	if ( nrctatos == 1 ) {
		estadoInicial();
	
	} else {
		trocaBotao('');
		$('#'+frmDados).css({'display':'none'});

		cNrctremp.habilitaCampo();
		cNrctremp.focus();
	}

	controlaPesquisas();	
	return false;
	
}


// imprimir
function Gera_Impressao( i ) {	
    
	$('#nrcpfava', '#'+frmCab).val( fiadores[i]['nrcpfava'] );
	$('#nmdavali', '#'+frmCab).val( fiadores[i]['nmdavali'] );
	$('#uladitiv', '#'+frmCab).val( fiadores[i]['uladitiv'] );
	
	cTodosCabecalho.habilitaCampo();
	
	if ( fiadores.length == 2 ) {
		var callafter = "cTodosCabecalho.desabilitaCampo();fechaAvalista();";
	} else {
		var callafter = "cTodosCabecalho.desabilitaCampo();bloqueiaFundo($('#divRotina'));"
	}

	var action = UrlSite + 'telas/altava/imprimir_dados.php';	
	
	carregaImpressaoAyllos(frmCab,action,callafter);
	
}

function mostraImprimir() {

	var mensagem = 'Aguarde, buscando dados ...';
 	showMsgAguardo(mensagem);

	// Executa script de confirma��o atrav�s de ajax
	$.ajax({		
		type: 'POST',
		dataType: 'html',
		url: UrlSite + 'telas/altava/form_imprimir.php', 
		data: {
			redirect: 'html_ajax'			
			}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();			
			showError('error','N�o foi poss�vel concluir a requisi��o.','Alerta - Ayllos',"unblockBackground()");
		},
		success: function(response) {
			hideMsgAguardo();

			$('#divRotina').html(response);
			exibeRotina( $('#divRotina') );

			formataImprimir();
			return false;
		}				
	});
	return false;
	
}

function formataImprimir() {

	$('#avalista1', '#frmImprimir').css({'width':'140px','height':'25px','cursor':'pointer','margin':'9px'});
    $('#avalista2', '#frmImprimir').css({'width':'140px','height':'25px','cursor':'pointer','margin':'9px'});

	if ( $.browser.msie ) {
		$('#avalista1', '#frmImprimir').css({'margin-top':'11px'});
		$('#avalista2', '#frmImprimir').css({'margin-top':'11px'});
	}	
	
	// centraliza a divRotina
	$('#divRotina').css({'width':'355px'});
	$('#divConteudo').css({'width':'330px'});	
	$('#divRotina').centralizaRotinaH();
	
	layoutPadrao();
	hideMsgAguardo();		
	bloqueiaFundo( $('#divRotina') );
	return false;
}



// contrato
function mostraContrato() {
	
	showMsgAguardo('Aguarde, buscando ...');

	// Executa script de confirma��o atrav�s de ajax
	$.ajax({		
		type: 'POST',
		dataType: 'html',
		url: UrlSite + 'telas/altava/contrato.php', 
		data: {
			redirect: 'html_ajax'			
			}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();			
			showError('error','N�o foi poss�vel concluir a requisi��o.','Alerta - Ayllos',"unblockBackground()");
		},
		success: function(response) {
			$('#divRotina').html(response);
			buscaContrato();
			return false;
		}				
	});
	return false;
	
}

function buscaContrato() {
		
	showMsgAguardo('Aguarde, buscando ...');

	var nrdconta = normalizaNumero( cNrdconta.val() );	
	
	$.ajax({		
		type: 'POST',
		dataType: 'html',
		url: UrlSite + 'telas/altava/busca_contrato.php', 
		data: {
			nrdconta: nrdconta, 
			redirect: 'script_ajax'			
			}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();			
			showError('error','N�o foi poss�vel concluir a requisi��o.','Alerta - Ayllos',"unblockBackground();");
		},
		success: function(response) {
		
			if ( response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1 ) {
				try {
					$('#divConteudo').html(response);
					exibeRotina($('#divRotina'));
					formataContrato();
					return false;
				} catch(error) {
					hideMsgAguardo();					
					showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','unblockBackground()');
				}
			} else {
				try {
					eval( response );
				} catch(error) {
					hideMsgAguardo();					
					showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','unblockBackground()');
				}
			}
		}				
	});
	return false;
}

function formataContrato() {

	var divRegistro = $('div.divRegistros','#divContrato');		
	var tabela      = $('table', divRegistro );
	var linha       = $('table > tbody > tr', divRegistro );
			
	divRegistro.css({'height':'130px'});
	
	var ordemInicial = new Array();
	ordemInicial = [[0,0]];	
	
	var arrayLargura = new Array();
	arrayLargura[0] = '60px';
	arrayLargura[1] = '62px';
	arrayLargura[2] = '80px';
	arrayLargura[3] = '60px';
	arrayLargura[4] = '80px';
	arrayLargura[5] = '38px';
	
		
	var arrayAlinha = new Array();
	arrayAlinha[0] = 'right';
	arrayAlinha[1] = 'left';
	arrayAlinha[2] = 'right';
	arrayAlinha[3] = 'right';
	arrayAlinha[4] = 'right';
	arrayAlinha[5] = 'right';
	arrayAlinha[6] = 'right';
	
	var metodoTabela = 'selecionaContrato();';
			
	tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha, metodoTabela );

	// centraliza a divRotina
	$('#divRotina').css({'width':'525px'});
	$('#divConteudo').css({'width':'500px'});
	$('#divRotina').centralizaRotinaH();

	
	hideMsgAguardo();
	bloqueiaFundo( $('#divRotina') );
	
	return false;
}

function selecionaContrato() {
	
	if ( $('table > tbody > tr', 'div.divRegistros').hasClass('corSelecao') ) {
					
		$('table > tbody > tr', 'div.divRegistros').each( function() {
			if ( $(this).hasClass('corSelecao') ) {
				nrctremp = $('#nrctremp', $(this) ).val(); 
			}	
		});
	}

	cNrctremp.val( nrctremp ).focus();
	fechaRotina( $('#divRotina') );
	return false;
}


// ajuda
function formataMsgAjuda( tela ) {	

	var divMensagem = $('#divMsgAjuda', '#'+tela );
	var spanMensagem = $('span',divMensagem);

	var botoesMensagem = $('#divBotoes',divMensagem);
	botoesMensagem.css({'float':'center','padding':'0 0 0 2px', 'margin-top':'10px', 'margin-bottom':'10px'});		
	
	if ( $.browser.msie ) {
		botoesMensagem.css({'margin-top':'10px', 'margin-bottom':'10px'});		
	}	
	
}

function avalistaLimpa( auxconta ) {

	$('input', '#frmAvalista').limpaFormulario();

	cNrctaava.val( auxconta );
	cNmdavali.val('** Nao cadastrado **');
	
	return false;
}



// botoes
function btnVoltar() {
	estadoInicial();
	controlaPesquisas();
	return false;
}

function btnContinuar() {

	if ( divError.css('display') == 'block' ) { return false; }		
	
	if ( flgalter == 'S' ) {
		manterRotina('VA');
	} else {
		mostraAvalista();                                                  
	}
	
	controlaPesquisas();
	return false;

}

function trocaBotao( botao ) {
	
	$('#divBotoes','#divTela').html('');
	$('#divBotoes','#divTela').append('<a href="#" class="botao" id="btVoltar" onClick="btnVoltar(); return false;">Voltar</a>');
	
	if ( botao != '') {
		$('#divBotoes','#divTela').append('&nbsp;<a href="#" class="botao" id="btSalvar" onClick="btnContinuar(); return false;">Continuar</a>');
	}
	return false;
}

function ControlaFocusAvalista() {

	highlightObjFocus( $('#frmAvalista') );

	$('#nmdavali', '#frmAvalista').unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {	
			$('#nrcpfcgc', '#frmAvalista').focus();
			return false;
		}	
	});
	
	$('#nrcpfcgc', '#frmAvalista').unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {	
			$('#tpdocava', '#frmAvalista').focus();
			return false;
		}	
	});
	
	$('#tpdocava', '#frmAvalista').unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {	
			$('#nrdocava', '#frmAvalista').focus();
			return false;
		}	
	});
	
	$('#nrdocava', '#frmAvalista').unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {	
			$('#inpessoa', '#frmAvalista').focus();
			return false;
		}	
	});
	
	$('#inpessoa', '#frmAvalista').unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {	
			$('#dtnascto', '#frmAvalista').focus();
			return false;
		}	
	});
	
	$('#dtnascto', '#frmAvalista').unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {	
			$('#nmconjug', '#frmAvalista').focus();
			return false;
		}	
	});
	
	$('#nmconjug', '#frmAvalista').unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {	
			$('#nrcpfcjg', '#frmAvalista').focus();
			return false;
		}	
	});
	
	$('#nrcpfcjg', '#frmAvalista').unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {	
			$('#tpdoccjg', '#frmAvalista').focus();
			return false;
		}	
	});
	
	$('#tpdoccjg', '#frmAvalista').unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {	
			$('#nrdoccjg', '#frmAvalista').focus();
			return false;
		}	
	});
	
	$('#nrdoccjg', '#frmAvalista').unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {	
			$('#nrcepend', '#frmAvalista').focus();
			return false;
		}	
	});
	
	$('#nrendere', '#frmAvalista').unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {	
			$('#complend', '#frmAvalista').focus();
			return false;
		}	
	});
	
	$('#complend', '#frmAvalista').unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {	
			$('#nrcxapst', '#frmAvalista').focus();
			return false;
		}	
	});
	
	$('#nrcxapst', '#frmAvalista').unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {	
			$('#dsdemail', '#frmAvalista').focus();
			return false;
		}	
	});
	
	$('#dsdemail', '#frmAvalista').unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {	
			$('#nrfonres', '#frmAvalista').focus();
			return false;
		}	
	});
	
	$('#nrfonres', '#frmAvalista').unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {	
			btnContinuar();
			return false;
		}	
	});
	
	return false;

}