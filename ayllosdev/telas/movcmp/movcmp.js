/*!
 * FONTE        : movcmp.js
 * CRIAÇÃO      : Jackson Barcellos AMcom
 * DATA CRIAÇÃO : 06/2019
 * OBJETIVO     : P565
 * --------------
 * ALTERAÇÕES   : 
 * --------------
 */

//Formulários e Tabela
var frmCab   		= 'frmCab';
var tabDados		= 'divTabela';
var frmMovnr 		= 'frmMovnr';
var frmMovsr		= 'frmMovsr';

//Labels/Campos do cabeçalho
var btnOK,  rVcooper, rTpremessa, rTparquivo, rCdagenci, rDtinicial, rDtfinal;
var cTodosCabecalho, cVcooper, cTpremessa, cTparquivo, cCdagenci, cDtinicial, cDtfinal;
var vcooper, tpremessa, tparquivo, cdagenci, dtinicial, dtfinal;
var cbTpArquivoNR={option1:{value:1,text:"DEVOLUCAO DIURNA"}
				   ,option2:{value:2,text:"DEVOLUCAO FRAUDES E IMPEDIMENTOS"}
				   ,option3:{value:3,text:"COMPEL"}
				   ,option4:{value:4,text:"TITULOS"}
				  };
var cbTpArquivoSR={option1:{value:1,text:"DEVOLU"}
				   ,option2:{value:2,text:"DOCTOS"}
				   ,option3:{value:3,text:"COMPEL"}
				   ,option4:{value:4,text:"TITULOS"}
				  };
	
$(document).ready(function() {
	estadoInicial();
});

function estadoInicial(){
	$('#divTela').fadeTo(0,0.1);
	$('#divBotoes').css({'display':'none'});
	$('#divTabela').css({'display':'none'});
	$('#frmCab').css({'display':'block'});
	
	hideMsgAguardo();	
	
	btnOK				= $('#btnOK','#'+frmCab);
	rTpremessa		    = $('label[for="tpremessa"]','#'+frmCab); 	
	rVcooper			= $('label[for="vcooper"]','#'+frmCab); 	
	rTparquivo		    = $('label[for="tparquivo"]','#'+frmCab); 	
	rCdagenci			= $('label[for="cdagenci"]','#'+frmCab); 	
	rDtinicial			= $('label[for="dtinicial"]','#'+frmCab); 	
	rDtfinal			= $('label[for="dtfinal"]','#'+frmCab); 	

	cTodosCabecalho		= $('input[type="text"],select','#'+frmCab);
	cTpremessa			= $('#tpremessa','#'+frmCab); 	
	cVcooper			= $('#vcooper','#'+frmCab); 	
	cTparquivo			= $('#tparquivo','#'+frmCab); 
	cCdagenci			= $('#cdagenci','#'+frmCab); 
	cDtinicial			= $('#dtinicial','#'+frmCab); 
	cDtfinal			= $('#dtfinal','#'+frmCab); 		
		
	tpremessa = cTpremessa.val();
	cDtinicial.val($('#glbdtmvtolt','#'+frmCab).val());
	cDtfinal.val($('#glbdtmvtolt','#'+frmCab).val());

	formataCabecalho();
	removeOpacidade('divTela');

	
}

function formataCabecalho() {

	rVcooper.addClass('rotulo').css({'width':'75px'});
	cVcooper.addClass('vcooper pesquisa').css({'width':'80px'})
	
	cTodosCabecalho.habilitaCampo();	
	btnOK.trocaClass("botaoDesativado","botao");
	
	var nomeForm    = 'frmCab';
	highlightObjFocus( $('#'+nomeForm) );	

	rTpremessa.addClass('rotulo').css('width', '90px');
	rVcooper.addClass('rotulo').css('width', '90px');
	rTparquivo.addClass('rotulo').css('width', '90px');
	rCdagenci.addClass('rotulo-linha').css('width', '75px');
	rDtinicial.addClass('rotulo-linha').css('width', '75px');
	rDtfinal.addClass('rotulo-linha').css('width', '75px');
	
	cTpremessa.css('width', '495');
	cVcooper.css('width', '150');
	cTparquivo.css('width', '150');
	cCdagenci.css('width', '50');
	cDtinicial.css('width', '75px').setMask("DATE");	
	cDtfinal.css('width', '75px').setMask("DATE");	

	formataTpRemessa();

	cTpremessa.unbind('change').bind('change', function () {
        tpremessa = cTpremessa.val();
		formataTpRemessa();
    });

    cDtinicial.focus();

	return false;	
}

function formataTpRemessa(){
	var cbValores;
	cTparquivo.children('option:not(:first)').remove();
	if (tpremessa == 'nr'){
		cCdagenci.show();
		rCdagenci.show();	
		cbValores = cbTpArquivoNR;
	}else{
		cCdagenci.hide();
		rCdagenci.hide();
		cbValores = cbTpArquivoSR;
	}
	$.each(cbValores, function(i, item) {
    	cTparquivo.append($('<option>', {
      			  value: item.value,
      		      text : item.text
		}));
	});	
}

function controlaOperacao(operacao,nriniseq,nrregist){	
	if (operacao == 'C' && btnOK.hasClass('botao')){
		showMsgAguardo( 'Aguarde ...' );	
				
		// Carrega dados da conta através de ajax
		$.ajax({		
			type	: 'POST',
			url		: UrlSite + 'telas/movcmp/principal.php', 
			data    : 
					{ 
						nmdatela: 'MOVCMP',
						nmrotina: ' ',
						operacao: operacao,
						nriniseq: nriniseq,
                        nrregist: nrregist,
						 vcooper: vcooper,
					   tpremessa: tpremessa,
					   tparquivo: tparquivo,
					    cdagenci: cdagenci,
					   dtinicial: dtinicial,
					     dtfinal: dtfinal,
						redirect: 'html_ajax' 
					},
			error   : function(objAjax,responseError,objExcept) {
						hideMsgAguardo();
						showError('error','1Não foi possível concluir a requisi&ccedil;&atilde;o.','Alerta','cDtinicial.focus()');
					},
			success : function(response) { 
						hideMsgAguardo();						
						if ( response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1 ) {
							try {								
								$('#divTabela').html(response);
								btnOK.trocaClass("botao","botaoDesativado");
								cTodosCabecalho.desabilitaCampo();
								if (tpremessa == 'nr'){
									formataTabelanr();								
								}
								else if (tpremessa == 'sr'){
									formataTabelasr();								
								}	
								else{
									showError('error','Tipo de remessa invalida.','Alerta - Ayllos','unblockBackground()');
								}															
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

function formataTabelanr(){
	
	$('#divTabela').css({'display':'block'});
	$('#divBotoes').css({'display':'block'});
	$('#divRegistros').css({'display':'block'});
	$('#divMovnr').css({'display':'block'});
	
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
    arrayLargura[0] = '12%';
    arrayLargura[1] = '5%';
    arrayLargura[2] = '11%';
    arrayLargura[3] = '13%';
    arrayLargura[4] = '10%'; 
    arrayLargura[5] = '16%';
    arrayLargura[6] = '10%';
    arrayLargura[7] = '16%';
    arrayLargura[8] = '5%';

    var arrayAlinha = new Array();
    arrayAlinha[0] = 'center';
    arrayAlinha[1] = 'center';
    arrayAlinha[2] = 'right';
    arrayAlinha[3] = 'center';
	arrayAlinha[4] = 'left';
	arrayAlinha[5] = 'center';
    arrayAlinha[6] = 'right';
    arrayAlinha[7] = 'center';
	arrayAlinha[8] = 'left';

    var metodoTabela = 'selecionaLinhanr($(this))';

    tabela.formataTabela(ordemInicial, arrayLargura, arrayAlinha, metodoTabela, metodoTabela);

    selecionaLinhanr($('table > tbody > tr:eq(0)', divRegistro));

    $('table > tbody > tr', divRegistro).focus( function() {
		selecionaLinhanr($(this));

	});

	// seleciona o registro que é clicado
	$('table > tbody > tr', divRegistro).click( function() {
		selecionaLinhanr($(this));

	});
	
	$('#divPesquisaRodape', '#divTabela').formataRodapePesquisa();

	$('label[for="nmarquiv"]','#'+frmMovnr).addClass('rotulo').css('width', '50px');
	$('label[for="insituac"]','#'+frmMovnr).addClass('rotulo-linha').css('width', '100px');
	$('label[for="totais"]','#'+frmMovnr).addClass('rotulo').css('width', '55%');
	$('label[for="qtenviad"]','#'+frmMovnr).addClass('rotulo').css('width', '100px');
	$('label[for="vlenviad"]','#'+frmMovnr).addClass('rotulo-linha').css('width', '200px');
	$('label[for="qtproces"]','#'+frmMovnr).addClass('rotulo').css('width', '100px');
	$('label[for="vlproces"]','#'+frmMovnr).addClass('rotulo-linha').css('width', '200px');	

	$('#nmarquiv','#'+frmMovnr).css('width', '300').desabilitaCampo();
	$('#insituac','#'+frmMovnr).css('width', '200').desabilitaCampo();
	$('#qtenviad','#'+frmMovnr).css({'width':'150','text-align':'right'}).desabilitaCampo();
	$('#vlenviad','#'+frmMovnr).css({'width':'160','text-align':'right'}).desabilitaCampo();
	$('#qtproces','#'+frmMovnr).css({'width':'150','text-align':'right'}).desabilitaCampo();
	$('#vlproces','#'+frmMovnr).css({'width':'160','text-align':'right'}).desabilitaCampo();	
}

function selecionaLinhanr(tr){
	
	var avlenviad = $('#vlenviad', tr ).val();
	avlenviad = ( typeof avlenviad == 'undefined' ) ? 0 : avlenviad; 
	$('#vlenviad','#divMovnr' ).val(number_format(parseFloat(avlenviad.replace(',','.')),2,',','.'));
	var avlproces = $('#vlproces', tr ).val();
	avlproces = ( typeof avlproces == 'undefined' ) ? 0 : avlproces; 
	$('#vlproces','#divMovnr' ).val(number_format(parseFloat(avlproces.replace(',','.')),2,',','.'));
	
	$('#nmarquiv','#divMovnr' ).val( $('#nmarquiv', tr ).val() );
	$('#insituac','#divMovnr' ).val( $('#dssituac', tr ).val() );
	$('#qtenviad','#divMovnr' ).val( $('#qtenviad', tr ).val() );
	$('#qtproces','#divMovnr' ).val( $('#qtproces', tr ).val() );
	
	return false;
}

function formataTabelasr(){
	
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
    arrayLargura[0] = '12%';
    arrayLargura[1] = '10%';
    arrayLargura[2] = '11%';
    arrayLargura[3] = '10%';
    arrayLargura[4] = '11%'; 
    arrayLargura[5] = '11%';
    arrayLargura[6] = '11%';
    arrayLargura[7] = '11%';
    arrayLargura[8] = '11%';

    var arrayAlinha = new Array();
    arrayAlinha[0] = 'center';
    arrayAlinha[1] = 'center';
    arrayAlinha[2] = 'right';
    arrayAlinha[3] = 'center';
	arrayAlinha[4] = 'left';
	arrayAlinha[5] = 'center';
    arrayAlinha[6] = 'right';
    arrayAlinha[7] = 'center';
	arrayAlinha[8] = 'left';

    var metodoTabela = 'selecionaLinhasr($(this))';

    tabela.formataTabela(ordemInicial, arrayLargura, arrayAlinha, metodoTabela, metodoTabela);

    selecionaLinhasr($('table > tbody > tr:eq(0)', divRegistro));

    $('table > tbody > tr', divRegistro).focus( function() {
		selecionaLinhasr($(this));

	});

	// seleciona o registro que é clicado
	$('table > tbody > tr ', divRegistro).click( function() {
		selecionaLinhasr($(this));

	});
	
	$('#divPesquisaRodape', '#divTabela').formataRodapePesquisa();

	$('label[for="nmarqrec"]','#'+frmMovsr).addClass('rotulo').css('width', '50px');	
	$('label[for="totais"]','#'+frmMovsr).addClass('rotulo').css('width', '55%');
	$('label[for="qtrecebd"]','#'+frmMovsr).addClass('rotulo').css('width', '100px');
	$('label[for="vlrecebd"]','#'+frmMovsr).addClass('rotulo-linha').css('width', '200px');
	$('label[for="qtintegr"]','#'+frmMovsr).addClass('rotulo').css('width', '100px');
	$('label[for="vlintegr"]','#'+frmMovsr).addClass('rotulo-linha').css('width', '200px');	
	$('label[for="qtrejeit"]','#'+frmMovsr).addClass('rotulo').css('width', '100px');
	$('label[for="vlrejeit"]','#'+frmMovsr).addClass('rotulo-linha').css('width', '200px');	

	$('#nmarqrec','#'+frmMovsr).css('width', '300').desabilitaCampo();
	$('#qtrecebd','#'+frmMovsr).css({'width':'150','text-align':'right'}).desabilitaCampo();
	$('#vlrecebd','#'+frmMovsr).css({'width':'160','text-align':'right'}).desabilitaCampo();
	$('#qtintegr','#'+frmMovsr).css({'width':'150','text-align':'right'}).desabilitaCampo();
	$('#vlintegr','#'+frmMovsr).css({'width':'160','text-align':'right'}).desabilitaCampo();
	$('#qtrejeit','#'+frmMovsr).css({'width':'150','text-align':'right'}).desabilitaCampo();
	$('#vlrejeit','#'+frmMovsr).css({'width':'160','text-align':'right'}).desabilitaCampo();
}

function selecionaLinhasr(tr){

	var avlrecebd = $('#vlrecebd', tr ).val();
	avlrecebd = ( typeof avlrecebd == 'undefined' ) ? 0 : avlrecebd; 
	$('#vlrecebd','#divMovsr' ).val(number_format(parseFloat(avlrecebd.replace(',','.')),2,',','.'));
	var avlintegr = $('#vlintegr', tr ).val();
	avlintegr = ( typeof avlintegr == 'undefined' ) ? 0 : avlintegr; 
	$('#vlintegr','#divMovsr' ).val(number_format(parseFloat(avlintegr.replace(',','.')),2,',','.'));
	var avlrejeit = $('#vlrejeit', tr ).val();
	avlrejeit = ( typeof avlrejeit == 'undefined' ) ? 0 : avlrejeit; 
	$('#vlrejeit','#divMovsr' ).val(number_format(parseFloat(avlrejeit.replace(',','.')),2,',','.'));
	
	$('#nmarqrec','#divMovsr' ).val( $('#nmarqrec', tr ).val() );
	$('#qtrecebd','#divMovsr' ).val( $('#qtrecebd', tr ).val() );
	$('#qtintegr','#divMovsr' ).val( $('#qtintegr', tr ).val() );
	$('#qtrejeit','#divMovsr' ).val( $('#qtrejeit', tr ).val() );
	
	return false;
}

function btnOk(){
	if ( divError.css('display') == 'block' ) { return false; }		
	
	if (typeof cVcooper.val() != 'undefined'){
		vcooper = cVcooper.val();
	}else{
		vcooper = -1;
	}

	if (typeof cDtinicial.val() == 'undefined' || cDtinicial.val() == ''){
		showError('error','Informe a data inicial v&aacute;lida.','Alerta - Ayllos','');
		cDtinicial.focus();
	}

	tpremessa = cTpremessa.val();
	tparquivo = cTparquivo.val();
	cdagenci  = cCdagenci.val();
	dtinicial = cDtinicial.val();
	dtfinal	  =	cDtfinal.val();	
	
	controlaOperacao('C',1,30);
	return false;
}

function btnVoltar() {
	estadoInicial();
	return false;
}




