/*!
 * FONTE        : concmn.js
 * CRIAÇÃO      : Jackson Barcellos AMcom
 * DATA CRIAÇÃO : 04/2019
 * OBJETIVO     : P530
 * --------------
 * ALTERAÇÕES   : 
 * --------------
 */

//Formulários e Tabela
var frmCab   		= 'frmCab';
var tabDados		= 'divTabela';

//Labels/Campos do cabeçalho
var rNrdconta, cNrdconta, cTodosCabecalho, btnOK, cNrcpfcnpj, cVcooper, rVcooper;
var nrdconta , cpfcnpj, vcooper;
	
$(document).ready(function() {
	estadoInicial();
});

function estadoInicial(){
	$('#divTela').fadeTo(0,0.1);
	$('#divBotoes').css({'display':'none'});
	$('#divTabela').css({'display':'none'});
	$('#frmCab').css({'display':'block'});
	
	hideMsgAguardo();	
	
	rNrdconta			= $('label[for="nrdconta"]','#'+frmCab); 	
	cNrdconta			= $('#nrdconta','#'+frmCab); 
	cNrcpfcnpj			= $('#nrcpfcnpj','#'+frmCab); 	
	rVcooper			= $('label[for="vcooper"]','#'+frmCab); 	
	cVcooper			= $('#vcooper','#'+frmCab); 	
	cTodosCabecalho		= $('input[type="text"],select','#'+frmCab);
	btnOK				= $('#btnOK','#'+frmCab);
	
	formataCabecalho();
	removeOpacidade('divTela');

	
}

function formataCabecalho() {
	
	rVcooper.addClass('rotulo').css({'width':'75px'});
	cVcooper.addClass('vcooper pesquisa').css({'width':'80px'})
	rNrdconta.addClass('rotulo').css({'width':'75px'});	
	cNrdconta.addClass('nrdconta pesquisa').css({'width':'80px'})
	cNrcpfcnpj.addClass('nrcpfcnpj pesquisa').css({'width':'150px'})

	cTodosCabecalho.habilitaCampo();	
	
	var nomeForm    = 'frmCab';
	highlightObjFocus( $('#'+nomeForm) );	
	

	cNrdconta.unbind('keypress').bind('keypress', function(e) {
		if ( divError.css('display') == 'block' ) { return false; }		
		// Se é a tecla ENTER, 
		if ( e.keyCode == 13 ) {	
			btnOk();
			return false;
		} else if ( e.keyCode == 118 ) {
			mostraPesquisaAssociado('nrdconta', frmCab );
			return false;
		}
	});	
	
	cNrcpfcnpj.unbind('keypress').bind('keypress', function(e) {
		if ( divError.css('display') == 'block' ) { return false; }		
		// Se é a tecla ENTER, 
		if ( e.keyCode == 13 ) {	
			btnOk();
			return false;
		} 
	});	


	layoutPadrao();
	cNrdconta.trigger('blur');
	cNrdconta.focus();
	return false;	
}

function montaPesquisaAssociados() {
	mostraPesquisaAssociado('nrdconta','frmCab');
}

function controlaOperacao(operacao,nriniseq,nrregist){
	if (operacao == 'C'){
		showMsgAguardo( 'Aguarde ...' );	
				
		// Carrega dados da conta através de ajax
		$.ajax({		
			type	: 'POST',
			url		: UrlSite + 'telas/concmn/principal.php', 
			data    : 
					{ 
						nmdatela: 'CONCMN',
						nmrotina: ' ',
						nrdconta: nrdconta,	
					   nrcpfcnpj: cpfcnpj,
						operacao: operacao,
						nriniseq: nriniseq,
                        nrregist: nrregist,
						 vcooper: vcooper,
						redirect: 'html_ajax' 
					},
			error   : function(objAjax,responseError,objExcept) {
						hideMsgAguardo();
						showError('error','1Não foi possível concluir a requisi&ccedil;&atilde;o.','Alerta - Anota','$(\'#nrdconta\',\'#frmCabAnota\').focus()');
					},
			success : function(response) { 
						hideMsgAguardo();
						if ( response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1 ) {
							try {
								
								$('#divTabela').html(response);
								formataTabela();								
																
								return false;
							} catch(error) {
								hideMsgAguardo();
								showError('error','2N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','unblockBackground()');
							}
						} else {
							try {
								eval( response );
							} catch(error) {
								hideMsgAguardo();
								showError('error','3N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','unblockBackground()');
							}
						}
					}
		}); 
	}
	else{
		return false;
	}
}

function formataTabela(){
	
	$('#divTabela').css({'display':'block'});
	$('#divBotoes').css({'display':'block'});
	$('#divRegistros').css({'display':'block'});
	
	var divRegistro = $('div.divRegistros', '#divTabela');
	divRegistro.css({'height':175});
	var tabela = $('table', divRegistro);
	var ordemInicial = new Array();
	if (vcooper == 0){
		ordemInicial = [[0, 0]];
	}else{
		ordemInicial = [[1, 0]];
	}

    var arrayLargura = new Array();
    arrayLargura[0] = '14%';
    arrayLargura[1] = '11%';
    arrayLargura[2] = '17%';
    arrayLargura[3] = '20%';
    arrayLargura[4] = '36%'; //tipo cobranca

    var arrayAlinha = new Array();
    arrayAlinha[0] = 'center';
    arrayAlinha[1] = 'center';
    arrayAlinha[2] = 'right';
    arrayAlinha[3] = 'center';
	arrayAlinha[4] = 'left';


    var metodoTabela = '';

    tabela.formataTabela(ordemInicial, arrayLargura, arrayAlinha, metodoTabela);
	
	$('#divPesquisaRodape', '#divTabela').formataRodapePesquisa();
	
}

function btnOk(){
	if ( divError.css('display') == 'block' ) { return false; }		
	if ( cNrdconta.hasClass('campoTelaSemBorda')  ) { return false; }		
		
	// Armazena o número da conta na variável global
	nrdconta = normalizaNumero( cNrdconta.val() );		
	if (typeof cNrcpfcnpj.val() != 'undefined'){
		cpfcnpj = cNrcpfcnpj.val();
		if (cpfcnpj == '') {
			cpfcnpj = 0;
		}
	}else{
		cpfcnpj = 0;	
	}
	
	if (typeof cVcooper.val() != 'undefined'){
		vcooper = cVcooper.val();
	}else{
		vcooper = -1;
	}
	
	
	// Verifica se a conta é válida
	if ( nrdconta > 0){
		if ( !validaNroConta(nrdconta) ) { 
			showError('error','Conta/dv Inv&aacute;lida.','Alerta - Ayllos','focaCampoErro(\'nrdconta\',\''+ frmCab +'\');'); 
			return false; 
		}
	}
	controlaOperacao('C',1,30);
	return false;
}

function btnVoltar() {
	estadoInicial();
	return false;
}




