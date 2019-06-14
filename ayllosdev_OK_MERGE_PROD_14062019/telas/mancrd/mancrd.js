/*
  FONTE        : mancrd.js
  CRIAÇÃO      : Kelvin Souza Ott 
  DATA CRIAÇÃO : 28/06/2017
  OBJETIVO     : Biblioteca de funções da tela MANCRD
  --------------
  ALTERAÇÕES   : 27/10/2017 - Efetuar ajustes e melhorias na tela (Lucas Ranghetti #742880)
 
                 23/07/2018 - Deixar o campo nmempres sempre habilitado. Projeto 345(Lombardi).
 
				 25/07/2018 - Adicionado campo insitdec na tela. Projeto 345(Lombardi).
 
				 31/07/2018 - Ajustado tamanho das colunas na tabela de listagem dos cartões. (Reinert)
 
  --------------
 */
var frmCab   		= 'frmCab';

var rNrdconta, rNmprimtl, cNrdconta, cNmprimtl, cTodosCabecalho, btnOK;		

$(document).ready(function() {	
	divTabela		= $('#divTabela');
	estadoInicial();			
	return false;
	
});

// Inicio
function estadoInicial() {

	$('#frmCab').fadeTo(0,0.1);
					
	$('#divTabela').html('');
	
	formataCabecalho();
	
	removeOpacidade('frmCab');	
	
	cTodosCabecalho.limpaFormulario().removeClass('campoErro');	
	
	return false;
	
}

function formataCabecalho() {

	// cabecalho
	rNrdconta = $('label[for="nrdconta"]','#'+frmCab); 
	rNmprimtl = $('label[for="nmprimtl"]','#'+frmCab); 	
		
	cNrdconta = $('#nrdconta','#'+frmCab); 
	cNmprimtl = $('#nmprimtl','#'+frmCab); 
	
	cTodosCabecalho		= $('input[type="text"],select','#'+frmCab);
	btnOK				= $('#btnOK','#'+frmCab);
	
	//Label
	rNrdconta.addClass('rotulo').css({'width':'110px'});	
	rNmprimtl.addClass('rotulo-linha').css({'width':'85px'});
		
	//Campos
	cNrdconta.css({'width':'90px'}).addClass('conta pesquisa');	
	cNmprimtl.css({'width':'360px'});
		
	cTodosCabecalho.habilitaCampo();
	cNmprimtl.desabilitaCampo();
	highlightObjFocus( $('#frmCab') );
	
	cNrdconta.unbind('keypress').bind('keypress', function(e) {
		if ( divError.css('display') == 'block' ) { return false; }		
		// Se é a tecla ENTER, 
		if ( e.keyCode == 13 ) {
			btnOK.click();
			return false;
		} 
	});	
	
	cNrdconta.focus();	
	
	// Se clicar no botao OK
	btnOK.unbind('click').bind('click', function() {				
		if ( divError.css('display') == 'block' ) { return false; }				
		buscaCartoes();
		return false;
			
	});	
	
	layoutPadrao();
	
	return false;	
}


function controlaPesquisas() {

	if ( $('#nrdconta','#frmCab').hasClass('campoTelaSemBorda')  ) { return false; }	
	
	mostraPesquisaAssociado('nrdconta', frmCab );
	return false;
}

function buscaCartoes() {

	showMsgAguardo('Aguarde, consultando cartoes...');
    
	carregaDados();
	
}

function carregaDados(){
  $.ajax({		
		type	: 'POST',
		dataType: 'html',
		url		: UrlSite + 'telas/'+nometela+'/busca_cartoes.php', 
		data    :
				{ 	nrdconta: normalizaNumero(cNrdconta.val())
				   ,redirect: 'script_ajax'				 
				},
		error   : function(objAjax,responseError,objExcept) {
					hideMsgAguardo();
					showError('error','Não foi possível concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','$(\'#nrdconta\',\'#frmCab\').focus();');
				},
		success : function(response) { 
					try{
						hideMsgAguardo();
						$('#divTabela').html(response);						
						formataGridContrato();
						return false;
					}
					catch(error){
						hideMsgAguardo();
						showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'unblockBackground()');
						
					}
					
				}
	}); 


}

function formataGridContrato() {

    var divRegistro = $('div.divRegistros', '#divCartoes');
    var tabela = $('table', divRegistro);
   // var linha = $('table > tbody > tr', divRegistro);

    divRegistro.css({'height': '300px','width':'900px'});
	
    var ordemInicial = new Array();
    ordemInicial = [[0]];

    var arrayLargura = new Array();
    arrayLargura[0] = '90px'; // cpf
    arrayLargura[1] = '215px'; // Nome
	arrayLargura[2] = '125px'; // cartao
	arrayLargura[3] = '150px'; // Administradora    
    arrayLargura[4] = '75px'; // validade
    //arrayLargura[5] = '120px'; // situacao
    arrayLargura[6] = '45px'; 
    
    var arrayAlinha = new Array();
    arrayAlinha[0] = 'left';
    arrayAlinha[1] = 'left';
    arrayAlinha[2] = 'left';
    arrayAlinha[3] = 'left';
    arrayAlinha[4] = 'left';
    arrayAlinha[5] = 'left';
    arrayAlinha[6] = 'center';
    
    var metodoTabela = '';

    tabela.formataTabela(ordemInicial, arrayLargura, arrayAlinha, metodoTabela);

    hideMsgAguardo();   

    return false;
}

function mostraDetalhamento(nrdconta, nmprimtl, nrcrcard, nrcctitg, cdadmcrd, nrcpftit, nmtitcrd, listadm, insitcrd, dtsol2vi, flgprcrd, nrctrcrd, inpessoa, nmempres, flgdebit, insitdec) {
	
	showMsgAguardo('Aguarde, buscando detalhamento do cartao...');

	// Executa script através de ajax
	$.ajax({		
		type: 'POST',
		dataType: 'html',
		url: UrlSite + 'telas/mancrd/detalhamento_cartoes.php', 
		data: {			
			redirect: 'html_ajax'			
			}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos',"unblockBackground()");
		},
		success: function(response) {			
			$('#divRotina').css({'height': '400px'});						
			$('#divRotina').html(response);				
            exibeRotina($('#divRotina'));			
			buscaDetalheCartao(nrdconta, nmprimtl, nrcrcard, nrcctitg, cdadmcrd, nrcpftit, nmtitcrd, listadm, insitcrd, dtsol2vi, flgprcrd, nrctrcrd, inpessoa, nmempres, flgdebit, insitdec);
		}				
	});
	
	return false;
	
}


function buscaDetalheCartao(nrdconta, nmprimtl, nrcrcard, nrcctitg, cdadmcrd, nrcpftit, nmtitcrd, listadm, insitcrd, dtsol2vi, flgprcrd, nrctrcrd, inpessoa, nmempres, flgdebit, insitdec){
	
	// Executa script através de ajax
	$.ajax({		
		type: 'POST',
		dataType: 'html',
		url: UrlSite + 'telas/mancrd/form_mancrd.php', 
		data: {
			   nrdconta : nrdconta
			  ,nmprimtl : nmprimtl
			  ,nrcrcard : nrcrcard
			  ,nrcctitg : nrcctitg
			  ,cdadmcrd : cdadmcrd
			  ,nrcpftit : nrcpftit
			  ,nmtitcrd : nmtitcrd
			  ,listadm  : listadm
			  ,insitcrd : insitcrd
			  ,dtsol2vi : dtsol2vi			  
			  ,flgprcrd : flgprcrd
			  ,insitdec : insitdec
			  ,flgdebit : flgdebit
			  ,nrctrcrd : nrctrcrd
			  ,inpessoa : inpessoa
			  ,nmempres : nmempres
			  ,redirect: 'html_ajax'			
			}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos',"unblockBackground()");
		},
		success: function(response) {	
			$('#divDetalhamento').html(response);			
			formataDetalheCartao();
		}				
	});
	
	return false;
	
}

function formataDetalheCartao(){
	
	var rNrdcontaDet, rNmprimtlDet, rNrcrcardDet, rNmtitcrdDet, rNrcctitgDet, rDsadmcrdDet, rNrcpftitDet, rFlgdebitDet, rInsitcrdDet, rFlgprcrdDet, rNmempresDet, rInsitdecDet;
	
	var rNrdcontaDet, cNmprimtlDet, cNrcrcardDet, cNmtitcrdDet, cNrcctitgDet, cDsadmcrdDet, cNrcpftitDet, cFlgdebitDet, cInsitcrdDet, cFlgprcrdDet, cNmempresDet, cInsitdecDet;
	
	highlightObjFocus($('#frmDetalheCartao'));
	
	cTodosDetalheCrt = $('input[type="text"]', '#frmDetalheCartao');
	
	// label
    rNrdcontaDet = $('label[for="nrdconta"]', '#frmDetalheCartao');
	rNrcrcardDet = $('label[for="nrcrcard"]', '#frmDetalheCartao');	
	rNrcctitgDet = $('label[for="nrcctitg"]', '#frmDetalheCartao');
	rDsadmcrdDet = $('label[for="dsadmcrd"]', '#frmDetalheCartao');
	rNrcpftitDet = $('label[for="nrcpftit"]', '#frmDetalheCartao');
	rNmtitcrdDet = $('label[for="nmtitcrd"]', '#frmDetalheCartao');
	rInsitcrdDet = $('label[for="insitcrd"]', '#frmDetalheCartao');
	rFlgdebitDet = $('label[for="flgdebit"]', '#frmDetalheCartao');
	rFlgprcrdDet = $('label[for="flgprcrd"]', '#frmDetalheCartao');
	rNmempresDet = $('label[for="nmempres"]', '#frmDetalheCartao');
	rInsitdecDet = $('label[for="insitdec"]', '#frmDetalheCartao');
	
	rNrdcontaDet.css({'width': '68px'}).addClass('rotulo');	
	rNrcrcardDet.css({'width': '69px'}).addClass('rotulo');	
	rNrcctitgDet.css({'width': '92px'}).addClass('rotulo-linha');
	rDsadmcrdDet.css({'width': '106px'}).addClass('rotulo');
	rNrcpftitDet.css({'width': '48px'}).addClass('rotulo-linha');
	rNmtitcrdDet.css({'width': '106px'}).addClass('rotulo');
	rInsitcrdDet.css({'width': '106px'}).addClass('rotulo');
	rFlgdebitDet.css({'width': '108px'}).addClass('rotulo-linha');
	rFlgprcrdDet.css({'width': '75px'}).addClass('rotulo-linha');
	rInsitdecDet.css({'width': '106px'}).addClass('rotulo');
	rNmempresDet.css({'width': '106px'}).addClass('rotulo');
	
	// input
	cNrdcontaDet = $('#nrdconta', '#frmDetalheCartao');
	cNmprimtlDet = $('#nmprimtl', '#frmDetalheCartao');
	cNrcrcardDet = $('#nrcrcard', '#frmDetalheCartao');	
	cNrcctitgDet = $('#nrcctitg', '#frmDetalheCartao');
	cDsadmcrdDet = $('#dsadmcrd', '#frmDetalheCartao');
	cNrcpftitDet = $('#nrcpftit', '#frmDetalheCartao');
	cNmtitcrdDet = $('#nmtitcrd', '#frmDetalheCartao');
	cInsitcrdDet = $('#insitcrd', '#frmDetalheCartao');
	cFlgdebitDet = $('#flgdebit', '#frmDetalheCartao');
	cFlgprcrdDet = $('#flgprcrd', '#frmDetalheCartao');
	cInsitdecDet = $('#insitdec', '#frmDetalheCartao');
	cNmempresDet = $('#nmempres', '#frmDetalheCartao');
	
	cNrdcontaDet.css({'width': '75px'}).addClass('conta pesquisa');
	cNmprimtlDet.css({'width': '360px'}).addClass('campo');
    cNrcrcardDet.css({'width': '170px'}).addClass('inteiro campo');    
    cNrcctitgDet.css({'width': '169px'}).addClass('inteiro campo');
	cDsadmcrdDet.css({'width': '177px'}).addClass('inteiro campo');
    cNrcpftitDet.css({'width': '169px'}).addClass('cpf campo');
	cNmtitcrdDet.css({'width': '400px'}).addClass('campo');
	cInsitcrdDet.css({'width': '177px'}).addClass('inteiro campo');	
	cInsitdecDet.css({'width': '177px'}).addClass('inteiro campo');	
	cNmempresDet.css({'width': '400px'}).addClass('campo');
	
	layoutPadrao();
	/*
	if ($("#frmDetalheCartao #inpessoa").val() == 1 ||
	    $("#frmDetalheCartao #nrcrcard").val() != '0000.0000.0000.0000') {
		cNmempresDet.desabilitaCampo();
	}else{
		cNmempresDet.habilitaCampo();
	}
	*/
	cNmempresDet.habilitaCampo();
	
	//Desabilita campos
	cNrdcontaDet.desabilitaCampo();
	cNmprimtlDet.desabilitaCampo();
	cNrcrcardDet.desabilitaCampo();
	
	hideMsgAguardo();
	
	bloqueiaFundo($('#divRotina'));
	return false;
}

function confirmaAtualizaCartao(flgvalid){
	
	var aux_flgdebit, aux_flgprcrd;
	
	if ($("[name=flgdebit]").is(":checked")) 
		aux_flgdebit = 1;			
	else
		aux_flgdebit = 0;
	
	if ($("[name=flgprcrd]").is(":checked")) 
		aux_flgprcrd = 1;			
	else
		aux_flgprcrd = 0;


	if (flgvalid == 1) {
		showConfirmacao('Deseja atualizar o cart&atilde;o?', 'Confirma&ccedil;&atilde;o - Ayllos', 'atualizaCartao(' + normalizaNumero($("#frmDetalheCartao #nrdconta").val()) + ',\'' 
																													 + $("#nrcrcard").val() + '\',\'' 
																													 + $("#nrcctitg").val() + '\','
																													 + $("#dsadmcrd").val() + ',\''
																													 + $("#nrcpftit").val() + '\','
																													 + aux_flgdebit + ',\'' 
																												     + $("#nmtitcrd").val() + '\','
																													 + $("#nrctrcrd").val() + ',\''
																													 + $("#nmempres").val() + '\',\''
																													 + aux_flgprcrd + '\','
																													 + $("#insitcrd").val() + ','
																													 + $("#insitdec").val() + ', 1);', 'cNrdconta.focus();', 'sim.gif', 'nao.gif');	
   }else{
        atualizaCartao(normalizaNumero($("#frmDetalheCartao #nrdconta").val()),$("#nrcrcard").val(), $("#nrcctitg").val() ,
                                       $("#dsadmcrd").val(), $("#nrcpftit").val() , aux_flgdebit, $("#nmtitcrd").val() ,
									   $("#nrctrcrd").val(), $("#nmempres").val() , aux_flgprcrd ,$("#insitcrd").val() ,
									   $("#insitdec").val(), 0);   
   }
}

function atualizaCartao(nrdconta, nrcrcard, nrcctitg, cdadmcrd, nrcpftit, flgdebit, nmtitcrd, nrctrcrd, nmempres, flgprcrd, insitcrd, insitdec, flgvalid){
	
	showMsgAguardo('Aguarde, atualizando detalhes do cartao...');
	
	// Executa script através de ajax
	$.ajax({		
		type: 'POST',
		dataType: 'script',
		url: UrlSite + 'telas/mancrd/atualiza_cartao.php', 
		data: {
			 nrdconta : nrdconta
			,nrcrcard : normalizaNumero(nrcrcard)
			,nrcctitg : nrcctitg
			,cdadmcrd : cdadmcrd
			,nrcpftit : normalizaNumero(nrcpftit)
			,flgdebit : flgdebit
			,nmtitcrd : nmtitcrd
			,insitcrd : insitcrd
			,insitdec : insitdec
			,flgprcrd : flgprcrd
			,nrctrcrd : nrctrcrd
			,nmempres : nmempres
			,flgvalid : flgvalid
			,redirect: 'html_ajax'			
			}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos',"unblockBackground()");
		},
		success: function(response) {		
			
		}				
	});
	
	return false;
	
}+ '\',' 

function confirmaReenviarSolicitacao(nrdconta, nrcrcard, nrctrcrd){
	showConfirmacao('Deseja reenviar a solicitacao do cartao?', 'Confirma&ccedil;&atilde;o - Ayllos', 'reenviarSolicitacao(' + normalizaNumero(nrdconta) + ',\'' 																												
																												             + normalizaNumero(nrcrcard) + '\','
																															 + normalizaNumero(nrctrcrd) + ');', 'cNrdconta.focus();', 'sim.gif', 'nao.gif');
	
}
function reenviarSolicitacao(nrdconta, nrcrcard, nrctrcrd){
	
	showMsgAguardo('Aguarde, reenviando solicitacao do cartao...');
	
	// Executa script através de ajax
	$.ajax({		
		type: 'POST',
		dataType: 'script',
		url: UrlSite + 'telas/mancrd/reenvia_solicitacao.php', 
		data: {
			 nrdconta : nrdconta
			,nrcrcard : normalizaNumero(nrcrcard)			
			,nrctrcrd : nrctrcrd
			,redirect: 'html_ajax'			
			}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos',"unblockBackground()");
		},
		success: function(response) {					
		}				
	});
	
	return false;	
	
}

function btnVoltar(){	
	estadoInicial();	
	return false;
}