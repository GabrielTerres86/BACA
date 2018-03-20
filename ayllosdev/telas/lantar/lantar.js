/*!
 * FONTE        : lantar.js
 * CRIAÇÃO      : Daniel Zimmermann / Tiago Machado Flor
 * DATA CRIAÇÃO : 13/03/2013
 * OBJETIVO     : Biblioteca de funções da tela LANTAR
 * --------------
 * ALTERAÇÕES   : 15/08/2013 - Alteração da sigla PAC para PA (Carlos).
 *
 *				  19/03/2018 - Buscar tipos de conta do oracle. Chamada no js. PRJ366 (Lombardi).
 * -----------------------------------------------------------------------
 */

//Formulários e Tabela
var frmCab   		= 'frmCab';
var frmDadosPF 		= 'frmLantarPF';
var frmDadosPJ		= 'frmLantarPJ';
var tabDados		= 'divTabela';

//Labels/Campos do cabeçalho
var rNrdconta, cNrdconta, cTodosCabecalho, btnOK, arrAssociado, pessoaTela, arrTarifaPf, arrTarifaPj, arrPesqAssociado, glbTabNrdconta;
	
$(document).ready(function() {
	estadoInicial();
});

function estadoInicial() {
	$('#divTela').fadeTo(0,0.1);

	arrAssociado = new Array();
	arrTarifaPf  = new Array();
	arrTarifaPj  = new Array();
	
	arrPesqAssociado = new Array();

	carregaTabPessoa();
	
	hideMsgAguardo();		
	atualizaSeletor();
	
	formataCabecalho();
	formataDadosPF();
	formataDadosPJ();
	
	
	trocaBotao('');
	$('#frmCab').css({'display':'block'});
	$('#divBotoes').css({'display':'block'});
	$('#divTabela').css({'display':'none'});
	$('#frmLantarPF').css({'display':'none'});
	$('#frmLantarPJ').css({'display':'none'});
	
	cTodosCabecalho.limpaFormulario().removeClass('campoErro');	
	
	//cCdorigem.focus();	
	removeOpacidade('divTela');
	
}

function realizaOperacao() {

	//Remove a classe de Erro do form
	$('input,select', '#frmCab').removeClass('campoErro');

	showMsgAguardo("Aguarde, realizando lançamentos...");
	
	var strNrdconta = '';
	var strCdhistor = '';
	var strQtlantar = '';
	var strVltarifa = '';
	var strQtdchcus = '';
	var strCdfvlcop = '';
	var flgRegistro = false;
	
	// Verifica se existe contas a serem processadas.
	if (arrAssociado.length <= 0) {
		hideMsgAguardo();
		showError("error","N&atilde;o possui contas a serem processados.","Alerta - Ayllos","unblockBackground");
		return false;
	}
	
	var aux_contachq = false;
	var aux_tarifchq = false;

	// Monta lista com contas a serem processadas.
	for(var i=0,len=arrAssociado.length; i<len; i++){
		strNrdconta = strNrdconta + arrAssociado[i].nrdconta + ';';
		strQtdchcus = strQtdchcus + normalizaNumero(arrAssociado[i].qtdchcus) + ';';
		
		if (normalizaNumero(arrAssociado[i].qtdchcus) > 0) {
			aux_contachq = true;
		}
		
	}
	
	$.trim(strNrdconta);
	strNrdconta = strNrdconta.substr(0,strNrdconta.length - 1);

	// Verifica se Pessoa Fisica ou Pessoa Juridica.
	if ( pessoaTela == 1 ) {
	
	
		$.each(arrTarifaPf, function(i, object){		
		
			if (object.bloqueia == '1') {
				aux_tarifchq = true;
			}
			
		  // Inclui apenas o registro se quantidade foi informada.		
		  if ( ( object.qtlantar > 0 ) || ( (object.bloqueia == '1') && (aux_contachq == true) ) ) 	{
			  strCdhistor = strCdhistor + object.cdhistor + ';';	  
			  strVltarifa = strVltarifa + object.vltarifa + ';';
			  strQtlantar = strQtlantar + object.qtlantar + ';';
			  strCdfvlcop = strCdfvlcop + object.cdfvlcop + ';';
			  flgRegistro = true;
		  }
		});
		
	} else {
		$.each(arrTarifaPj, function(i, object){
		
			if (object.bloqueia == '1') {
				aux_tarifchq = true;
			}
		
			// Inclui apenas o registro se quantidade foi informada.		
			if ( (object.qtlantar > 0 )  || ( (object.bloqueia == '1') && (aux_contachq == true) ) ) 	{
				strCdhistor = strCdhistor + object.cdhistor + ';';	  
				strVltarifa = strVltarifa + object.vltarifa + ';';
				strQtlantar = strQtlantar + object.qtlantar + ';';
				strCdfvlcop = strCdfvlcop + object.cdfvlcop + ';';
				flgRegistro = true;
			}
		});
	}
	
	if ( (aux_contachq == true ) &&  (aux_tarifchq == true) ) {
		// Possui contas com quantidade de cheque custodia e tarifa de custodia cheque esta disponivel para lancamento.
	} else {
	
		// Não executa operação caso não tenha registros com quantidade informada.
		if ( flgRegistro == false ) {
			hideMsgAguardo();
			showError("error","N&atilde;o possui registros com quantidade informada.","Alerta - Ayllos","unblockBackground");
			return false;
		}
	}
	
	$.trim(strCdhistor);
	strCdhistor = strCdhistor.substr(0,strCdhistor.length - 1);
	
	$.trim(strVltarifa);
	strVltarifa = strVltarifa.substr(0,strVltarifa.length - 1);
	
	$.trim(strQtlantar);
	strQtlantar = strQtlantar.substr(0,strQtlantar.length - 1);
	
	$.trim(strQtdchcus);
	strQtdchcus = strQtdchcus.substr(0,strQtdchcus.length - 1);
	
	$.trim(strCdfvlcop);
	strCdfvlcop = strCdfvlcop.substr(0,strCdfvlcop.length - 1);
	
	var inpessoa = pessoaTela;	
	inpessoa = normalizaNumero(inpessoa);	
	
	// Executa script através de ajax
	$.ajax({		
		type: "POST",
		url: UrlSite + "telas/lantar/manter_rotina.php", 
		data: {
			strNrdconta: strNrdconta,
			strCdhistor: strCdhistor,
			strQtlantar: strQtlantar,
			strVltarifa: strVltarifa,
			strQtdchcus: strQtdchcus,
			strCdfvlcop: strCdfvlcop,
			inpessoa   : inpessoa,
			redirect: "script_ajax"
		}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
		success: function(response) {
			try {
				hideMsgAguardo();				
				eval(response);
			} catch(error) {
				hideMsgAguardo();
				showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message,"Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
			}
		}				
	});	

}

function carregaTabPessoa() {

	hideMsgAguardo();	
	
	var mensagem = 'Aguarde, buscando informações da conta...';
	showMsgAguardo( mensagem );	
	
	// Carrega dados da conta através de ajax
	$.ajax({		
		type	: 'POST',
		url		: UrlSite + 'telas/lantar/carrega_tab_pessoa_fisica.php', 
		data    : 
				{ 
					redirect	: 'script_ajax' 
				},
		error   : function(objAjax,responseError,objExcept) {
					hideMsgAguardo();
					showError('error','N&atilde;o foi possível concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','estadoInicial();');
				},
		success : function(response) {
					hideMsgAguardo();
					if ( response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1 ) {
						try {
							eval(response);
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
							showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','estadoInicial();');
						}
					}

				}
	});

	
	// Carrega dados da conta através de ajax
	$.ajax({		
		type	: 'POST',
		url		: UrlSite + 'telas/lantar/carrega_tab_pessoa_juridica.php', 
		data    : 
				{ 
					redirect	: 'script_ajax' 
				},
		error   : function(objAjax,responseError,objExcept) {
					hideMsgAguardo();
					showError('error','N&atilde;o foi possível concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','estadoInicial();');
				},
		success : function(response) {
					hideMsgAguardo();
					if ( response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1 ) {
						try {
							eval(response);
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
							showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','estadoInicial();');
						}
					}

				}
	});
	
	return false;	
}


function atualizaSeletor() {

	// Cabecalho
	rNrdconta			= $('label[for="nrdconta"]','#'+frmCab); 
	
	cNrdconta			= $('#nrdconta','#'+frmCab); 
	cTodosCabecalho		= $('input[type="text"],select','#'+frmCab);
	btnOK				= $('#btnOK','#'+frmCab);

	cTodosDadosPF			= $('input[type="text"],select','#'+frmDadosPF);
	cTodosDadosPJ			= $('input[type="text"],select','#'+frmDadosPJ);
	
	return false;
}


// Controle
function controlaOperacao( operacao ) {

	hideMsgAguardo();

	var nrdconta = normalizaNumero( cNrdconta.val() );
	var telinpes = normalizaNumero( pessoaTela );
	
	var mensagem = 'Aguarde, buscando dados da conta ...';
	showMsgAguardo( mensagem );	
	
	// Carrega dados da conta através de ajax
	$.ajax({		
		type	: 'POST',
		url		: UrlSite + 'telas/lantar/principal.php', 
		data    : 
				{ 
					operacao	: operacao,
					nrdconta	: nrdconta,
					telinpes	: telinpes,
					redirect	: 'script_ajax' 
				},
		error   : function(objAjax,responseError,objExcept) {
					hideMsgAguardo();
					showError('error','N&atilde;o foi possível concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','estadoInicial();');
				},
		success : function(response) {
					if ( response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1 ) {
						try {
							$('#divTabela').html(response);
							hideMsgAguardo();
							return false;
						} catch(error) {
							hideMsgAguardo();
							showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','estadoInicial();');
						}
					} else {
						try {
							eval( response );
						} catch(error) {
							hideMsgAguardo();
							showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','estadoInicial();');
						}
					}

				}
	});

	
	return false;	
}

function criaObjetoAssociado(cdagenci, nrdconta, nrmatric, cdtipcta, dstipcta, nmprimtl, inpessoa, qtdchcus ){

	var flgCria = true;

	if ( (arrAssociado.length > 0) && (pessoaTela != inpessoa) ){ 
		hideMsgAguardo()
		bloqueiaFundo($('#divRotina'));
		showError('error','Todas as contas selecionadas devem ter o mesmo tipo de pessoa','Alerta - Ayllos','cNrdconta.focus();');
		return false; 
		}
		
	for(var i=0,len=arrAssociado.length; i<len; i++){
		// Verifica se conta já foi incluida, evitando assim duplicidade de registros.
		if 	( arrAssociado[i].nrdconta == nrdconta ) {
			flgCria = false;
		 }
	}
	
	if ( flgCria == true ) { 

		var objAssociado = new associado(cdagenci, nrdconta, nrmatric, cdtipcta, dstipcta, nmprimtl, qtdchcus);
		arrAssociado.push( objAssociado );
		pessoaTela = inpessoa;
		
		if ( inpessoa == 1 ) {
			$('#frmLantarPF').css({'display':'block'});
		} else {
			$('#frmLantarPJ').css({'display':'block'});
		}
			
	}
	
}

function carregaTabela(){

	$("table.divRegistros", "#divTabela" ).remove();

	$('#divTabela').css({'display':'block'});

	$('#regAssociado').html('');
	
	for(var i=0,len=arrAssociado.length; i<len; i++){
		$('#regAssociado').append( 
					'<tr>' +
						'<td><span>'+arrAssociado[i].cdagenci+'</span>'
							      +arrAssociado[i].cdagenci+
						'</td>'+
						'<td id="nrdconta"><span>'+arrAssociado[i].nrdconta+'</span>'
							      +mascara(arrAssociado[i].nrdconta,'####.###.#')+
						'</td>'+
						'<td><span>'+arrAssociado[i].nrmatric+'</span>'
							      +mascara(arrAssociado[i].nrmatric,'####.###')+
						'</td>'+
						'<td><span>'+arrAssociado[i].cdtipcta+'</span>'
							      +arrAssociado[i].cdtipcta+
						'</td>'+
						'<td><span>'+arrAssociado[i].nmprimtl+'</span>'
							      +arrAssociado[i].nmprimtl+
						'</td>'+
						'<td><span>'+arrAssociado[i].qtdchcus+'</span>'
							      +arrAssociado[i].qtdchcus+
						'</td>'+
					'</tr>'
		);
	}
	
	$('#divBotoesTabLantar').css({'display':'block'});
	
}

function controlaPesquisas() {
	
	mostraPesquisaAssociado('nrdconta', frmCab );
	return false;
}


// Formata
function formataCabecalho() {
	
	rNrdconta.addClass('rotulo').css({'width':'38px'});
	cNrdconta.addClass('conta pesquisa').css({'width':'80px'})

	cTodosCabecalho.habilitaCampo();	
	
	var nomeForm    = 'frmCab';
	highlightObjFocus( $('#'+nomeForm) );
	
	var nomeForm    = 'frmLantarPF';
	highlightObjFocus( $('#'+nomeForm) );
	
	var nomeForm    = 'frmLantarPJ';
	highlightObjFocus( $('#'+nomeForm) );
	
	// Se clicar no botao OK
	btnOK.unbind('click').bind('click', function() { 	
		
		if ( divError.css('display') == 'block' ) { return false; }		
		if ( cNrdconta.hasClass('campoTelaSemBorda')  ) { return false; }		
		
		// Armazena o número da conta na variável global
		var nrdconta = normalizaNumero( cNrdconta.val() );
		
		// Verifica se o número da conta é vazio
		if ( nrdconta == '' ) { return false; }
	
		// Verifica se a conta é válida
		if ( !validaNroConta(nrdconta) ) { 
			showError('error','Conta/dv Inv&aacute;lida.','Alerta - Ayllos','focaCampoErro(\'nrdconta\',\''+ frmCab +'\');'); 
			return false; 
		}
		// Se chegou até aqui, a conta é diferente do vazio e é válida, então realizar a operação desejada
		controlaOperacao('associado');
		return false;
			
	});	

	cNrdconta.unbind('keypress').bind('keypress', function(e) {
		if ( divError.css('display') == 'block' ) { return false; }		
		// Se é a tecla ENTER, 
		if ( e.keyCode == 9 || e.keyCode == 13 ) {	
			btnOK.click();
			return false;
		} else if ( e.keyCode == 118 ) {
			mostraPesquisaAssociado('nrdconta', frmCab );
			return false;
		}
	});	

	layoutPadrao();
	cNrdconta.trigger('blur');
	return false;	
}

function formataDadosPF() {

	rCdhistor = $('#cdhistor','#frmLantarPF'); 
	rDshistor = $('#dshistor','#frmLantarPF'); 
	cVltarifa = $('#vltarifa','#frmLantarPF'); 
	cVlrtotal = $('#vlrtotal','#frmLantarPF'); 

	rCdhistor.css({'width':'30px'});
	rDshistor.css({'width':'410px'});
	cVltarifa.css({'width':'90px'});
	cVlrtotal.css({'width':'90px'});
	
	cVltarifa.desabilitaCampo();
	cVlrtotal.desabilitaCampo();
	
	
	cQtdetari = $('.qtde','#frmLantarPF');
	cQtdetari.addClass('campo inteiro').css({'width':'40px'}).attr('maxlength','4');
	
	layoutPadrao();
	return false;
}

function formataDadosPJ() {

	rCdhistor = $('#cdhistor','#frmLantarPJ'); 
	rDshistor = $('#dshistor','#frmLantarPJ'); 
	cVltarifa = $('#vltarifa','#frmLantarPJ'); 
	cVlrtotal = $('#vlrtotal','#frmLantarPJ'); 

	rCdhistor.css({'width':'30px'});
	rDshistor.css({'width':'410px'});
	cVltarifa.css({'width':'100px'});
	cVlrtotal.css({'width':'100px'});
	
	cVltarifa.desabilitaCampo();
	cVlrtotal.desabilitaCampo();
	
	cQtdetari = $('.qtde','#frmLantarPJ');
	cQtdetari.addClass('campo inteiro').css({'width':'40px'}).attr('maxlength','4');
	
	layoutPadrao();
	return false;
}

function formataTabela() {
	
	$("table.tituloRegistros", "#" + tabDados ).remove();
	
	// Tabela
    var divRegistro = $('div.divRegistros', '#'+tabDados);
	var tabela      = $('table', divRegistro );
	var linha       = $('table > tbody > tr', divRegistro );
	
	$('#'+tabDados).css({'margin-top':'5px'});
	divRegistro.css({'height':'145px','padding-bottom':'2px'});

	var ordemInicial = new Array();

	var arrayLargura = new Array();
	arrayLargura[0] = '35px';
	arrayLargura[1] = '60px';
	arrayLargura[2] = '80px';
	arrayLargura[3] = '180px';
	arrayLargura[4] = '330px';

	var arrayAlinha = new Array();
	arrayAlinha[0] = 'right';
	arrayAlinha[1] = 'right';
	arrayAlinha[2] = 'right';
	arrayAlinha[3] = 'left';
	arrayAlinha[4] = 'left';
	arrayAlinha[5] = 'center';
	
	tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha, '' );
	
	glbTabNrdconta = '';
	
	// seleciona o registro que é clicado
	$('table > tbody > tr', divRegistro).click( function() {
		glbTabNrdconta = $(this).find('#nrdconta > span').text() ;
	});
	
	$('table > tbody > tr:eq(0)', divRegistro).click();
	
	return false;
}

function controlaLayout() {

	atualizaSeletor();
	formataCabecalho();
	formataDadosPF();
	formataDadosPJ();
	
	trocaBotao('Concluir');
	
	cNrdconta.val('');
	cNrdconta.focus();
	layoutPadrao();
	return false;
}

// Botoes
function btnVoltar() {
	estadoInicial();
	return false;
}

function btnContinuar() {

	if ( divError.css('display') == 'block' ) { return false; }		

	realizaOperacao();
	
	return false;
}

function trocaBotao( botao ) {
	
	$('#divBotoes','#divTela').html('');
	$('#divBotoes','#divTela').append('<a href="#" class="botao" id="btVoltar" onclick="btnVoltar(); return false;" >Voltar</a>&nbsp;');
	
	if (botao != '') {
		$('#divBotoes','#divTela').append('<a href="#" class="botao" id="btSalvar" onclick="btnContinuar(); return false;" >' + botao + '</a>');
	}

	return false;
}

function associado(cdagenci, nrdconta, nrmatric, cdtipcta, dstipcta, nmprimtl, qtdchcus ) {

	this.cdagenci=cdagenci;
	this.nrdconta=nrdconta;
	this.nrmatric=nrmatric;
	this.cdtipcta=cdtipcta + ' - ' + dstipcta;
	this.nmprimtl=nmprimtl;
	this.qtdchcus=qtdchcus;
}

function tarifa(cdtarifa, dstarifa, cdhistor, dshistor, vltarifa, cdfvlcop, bloqueia, qtlantar, vltotlan){
	this.cdtarifa=cdtarifa;
	this.dstarifa=dstarifa;
	this.cdhistor=cdhistor;
	this.dshistor=dshistor;
	this.vltarifa=vltarifa;	
	this.cdfvlcop=cdfvlcop;
	this.qtlantar=qtlantar;
	this.vltotlan=vltotlan;
	this.bloqueia=bloqueia;
}

function pesquisa(cdagenci, nrdconta, nrmatric, cdtipcta, dstipcta, nmprimtl, qtdchcus ) {

	this.cdagenci=cdagenci;
	this.nrdconta=nrdconta;
	this.nrmatric=nrmatric;
	this.cdtipcta=cdtipcta;
    this.dstipcta=dstipcta;
	this.nmprimtl=nmprimtl;
	this.qtdchcus=qtdchcus;
}

function criaObjetoTarifaPf(cdtarifa, dstarifa, cdhistor, dshistor, vltarifa, cdfvlcop, bloqueia){
	
	var objTarifaPf = new tarifa(cdtarifa, dstarifa, cdhistor, dshistor, vltarifa, cdfvlcop, bloqueia, 0, 0);	
	arrTarifaPf.push( objTarifaPf );			
	return false;
}

function criaObjetoTarifaPj(cdtarifa, dstarifa, cdhistor, dshistor, vltarifa, cdfvlcop, bloqueia){

	var objTarifaPj = new tarifa(cdtarifa, dstarifa, cdhistor, dshistor, vltarifa, cdfvlcop, bloqueia, 0, 0);
	arrTarifaPj.push( objTarifaPj );		
	return false;
}

function carregaTabelaTarifaPf(){

	$('#tbLantarPF').html(
			'<tr>' +
				'<td style="border-right:none;padding:0;" width="30px">' +
				'</td>' +
				'<td style="border-right:none;padding:0;" width="420px">' +
				'</td>' +
				'<td style="border-right:none;padding:0;text-align:right;font-weight:bold" width="100px">' +
					'Valor tarifa' +
				'</td>' +
				'<td style="border-right:none;padding:0;text-align:right;font-weight:bold" width="60px" >' +
					'Qtde' +
				'</td>' +
				'<td style="border-right:none;padding:0;text-align:right;padding-right:5px;font-weight:bold" align="right" width="100px">' +
					'Valor total' +
				'</td>' +
			'</tr>'
	);
	
	for(var i=0,len=arrTarifaPf.length; i<len; i++){
		$('#tbLantarPF').append( 				
			'<tr>' +
				'<td style="border-right:none;padding:0;" width="30px">' +
					'<label id="cdhistor'+i+'" name="cdhistor'+i+'" style="width: 25px">' + arrTarifaPf[i].cdhistor + '</label>' +
				'</td>' +
				'<td style="border-right:none;padding:0;" width="420px">' +
					'<label id="dshistor'+i+'" name="dshistor'+i+'" style="text-align:left; padding-left:5px;">' + arrTarifaPf[i].dshistor + '</label>' +
				'</td>' +
				'<td style="border-right:none;padding:0;" width="100px">' +
					'<input type="text" name="vltarifa'+i+'" id="vltarifa'+i+'" align="center" style="float:right" class="monetario" style="text-align:right" value="' + arrTarifaPf[i].vltarifa + '"/>' +
				'</td>' +
				'<td style="border-right:none;padding:0;" width="60px" >' +
					'<input class="qtde" type="text" id="qtdetari'+i+'" name="qtdetari'+i+'" align="center" style="float:right" class="monetario" value="' + arrTarifaPf[i].qtlantar + '" />' +
				'</td>' + 
				'<td style="border-right:none;padding:0;text-align:right;padding-right:5px;" align="right" width="100px">' +
					'<input class="monetario" type="text" id="vlrtotal'+i+'" name="vlrtotal'+i+'" align="center" style="float:right; text-align:right" value="' + arrTarifaPf[i].vltotlan + '"/>' +
					'<input type="hidden" id="cdfvlcop'+i+'" name="cdfvlcop'+i+'" value="' + arrTarifaPf[i].cdfvlcop + '"/>' +
					'<input type="hidden" id="bloqueia'+i+'" name="bloqueia'+i+'" value="' + arrTarifaPf[i].bloqueia + '"/>' +
				'</td>' +
			'</tr>'								
			
		);		

		// Desabilitar os campos
		$('#vltarifa'+i).desabilitaCampo();		
		$('#vlrtotal'+i).desabilitaCampo();
		
		if ( $('#bloqueia'+i).val() == '1' ){
			$('#qtdetari'+i).desabilitaCampo();
		}
				
		// Atribui evento de calculo para o campo qtde		
		$('#qtdetari'+i).unbind('keypress').bind('keypress', function(e) {
			if ( divError.css('display') == 'block' ) { return false; }					
			if ( e.keyCode == 13 ){				
				calculaTabPf( normalizaNumero( $(this).prop('id') ) );
				var aux = $(this).prop("id");
				aux = normalizaNumero(aux) + 1;
				$('#qtdetari'+aux.toString()).focus();
				return false;
			} else if ( e.keyCode == 118 ) {				
				return false;
			}
		});					
		
		// Atribui evento de calculo para o campo qtde		
		$('#qtdetari'+i).unbind('change').bind('change', function(e) {
			if ( divError.css('display') == 'block' ) { return false; }								
						
			calculaTabPf( normalizaNumero( $(this).prop('id') ) );
			var aux = $(this).prop("id");
				aux = normalizaNumero(aux) + 1;
				$('#qtdetari'+aux.toString()).focus();
			
			return false;			
		});					
		
	}
		
}


function carregaTabelaTarifaPj(){

	$('#tbLantarPJ').html(
			'<tr>' +
				'<td style="border-right:none;padding:0;" width="30px">' +
				'</td>' +
				'<td style="border-right:none;padding:0;" width="420px">' +
				'</td>' +
				'<td style="border-right:none;padding:0;text-align:right;font-weight:bold" width="100px">' +
					'Valor tarifa' +
				'</td>' +
				'<td style="border-right:none;padding:0;text-align:right;font-weight:bold" width="60px" >' +
					'Qtde' +
				'</td>' +
				'<td style="border-right:none;padding:0;text-align:right;padding-right:5px;font-weight:bold" align="right" width="100px">' +
					'Valor total' +
				'</td>' +
			'</tr>'
	);
	
	for(var i=0,len=arrTarifaPj.length; i<len; i++){
		$('#tbLantarPJ').append( 				
			'<tr>' +
				'<td style="border-right:none;padding:0;" width="30px">' +
					'<label id="pjcdhistor'+i+'" name="pjcdhistor'+i+'" >' + arrTarifaPj[i].cdhistor + '</label>' +
				'</td>' +
				'<td style="border-right:none;padding:0;" width="420px">' +
					'<label id="pjdshistor'+i+'" name="pjdshistor'+i+'" style="text-align:left; padding-left:5px;">' + arrTarifaPj[i].dshistor + '</label>' +
				'</td>' +
				'<td style="border-right:none;padding:0;" width="100px">' +
					'<input type="text" name="pjvltarifa'+i+'" id="pjvltarifa'+i+'" align="center" style="float:right" class="monetario" style="text-align:right" value="' + arrTarifaPj[i].vltarifa + '"/>' +
				'</td>' +
				'<td style="border-right:none;padding:0;" width="60px" >' +
					'<input class="qtde" type="text" id="pjqtdetari'+i+'" name="pjqtdetari'+i+'" align="center" style="float:right" value="' + arrTarifaPj[i].qtlantar + '" />' +
				'</td>' + 
				'<td style="border-right:none;padding:0;text-align:right;padding-right:5px;" align="right" width="100px">' +
					'<input class="monetario" type="text" id="pjvlrtotal'+i+'" name="pjvlrtotal'+i+'" align="center" style="float:right; text-align:right" value="' + arrTarifaPj[i].vltotlan + '"/>' +
					'<input type="hidden" id="cdfvlcop'+i+'" name="pjcdfvlcop'+i+'" value="' + arrTarifaPj[i].cdfvlcop + '"/>' +
					'<input type="hidden" id="bloqueia'+i+'" name="pjbloqueia'+i+'" value="' + arrTarifaPj[i].bloqueia + '"/>' +
				'</td>' +
			'</tr>'
		);						
				
		// Desabilitar os campos
		$('#pjvltarifa'+i).desabilitaCampo();		
		$('#pjvlrtotal'+i).desabilitaCampo();
		
		if ( $('#pjbloqueia'+i).val() == '1' ){
			$('#pjqtdetari'+i).desabilitaCampo();
		}
				
		// Atribui evento de calculo para o campo qtde		
		$('#pjqtdetari'+i).unbind('keypress').bind('keypress', function(e) {
			if ( divError.css('display') == 'block' ) { return false; }					
			if ( e.keyCode == 13 ){				
				calculaTabPj( normalizaNumero( $(this).prop('id') ) );
				return false;
			} else if ( e.keyCode == 118 ) {				
				return false;
			}
		});					
		
		// Atribui evento de calculo para o campo qtde		
		$('#pjqtdetari'+i).unbind('change').bind('change', function(e) {
			if ( divError.css('display') == 'block' ) { return false; }								
						
			calculaTabPj( normalizaNumero( $(this).prop('id') ) );
			
			return false;			
		});	

	}
}

function calculaTabPj(indice){	
	atualizaArrPj();	

	var valor_aux = arrTarifaPj[indice].vltarifa;
	valor_aux  = number_format(parseFloat(valor_aux.replace(',','.')),2,',','');
	
	var valor = arrTarifaPj[indice].qtlantar;
	
	valor = number_format(parseFloat(valor.replace(',','.')),2,',','');
	
	valor =  converteMoedaFloat(valor) * converteMoedaFloat(valor_aux);
	
	subtotal = number_format(valor,2,',','');
	
	
	// Calculo	
	arrTarifaPj[indice].vltotlan = subtotal;
	atualizaTabPj();	
	return false;
	
	
	
}

function calculaTabPf(indice){	
	atualizaArrPf();	

	var valor_aux = arrTarifaPf[indice].vltarifa;
	valor_aux  = number_format(parseFloat(valor_aux.replace(',','.')),2,',','');
	
	var valor = arrTarifaPf[indice].qtlantar;
	
	valor = number_format(parseFloat(valor.replace(',','.')),2,',','');
	
	valor =  converteMoedaFloat(valor) * converteMoedaFloat(valor_aux);
	
	subtotal = number_format(valor,2,',','');
	
	// Calculo	
//	var subtotal = converteMoedaFloat(arrTarifaPf[indice].vltarifa) * parseInt(arrTarifaPf[indice].qtlantar);
	 
	arrTarifaPf[indice].vltotlan = subtotal;
	atualizaTabPf();	
	return false;
}

function atualizaArrPf(){

	for(var i=0,len=arrTarifaPf.length; i<len; i++){
	
		arrTarifaPf[i].vltarifa = $('#vltarifa'+i).val();
		arrTarifaPf[i].qtlantar = $('#qtdetari'+i).val();
		arrTarifaPf[i].vltotlan = $('#vlrtotal'+i).val();
		
	}

	return false;
}

function atualizaArrPj(){

	for(var i=0,len=arrTarifaPj.length; i<len; i++){
	
		arrTarifaPj[i].vltarifa = $('#pjvltarifa'+i).val();
		arrTarifaPj[i].qtlantar = $('#pjqtdetari'+i).val();
		arrTarifaPj[i].vltotlan = $('#pjvlrtotal'+i).val();
		
	}

	return false;
}

function atualizaTabPf(){

	for(var i=0,len=arrTarifaPf.length; i<len; i++){
	
		$('#vltarifa'+i).val(arrTarifaPf[i].vltarifa);
		$('#qtdetari'+i).val(arrTarifaPf[i].qtlantar);
		$('#vlrtotal'+i).val(arrTarifaPf[i].vltotlan);
		
		$('#vlrtotal'+i).attr('alt','n9p3c2D').css('text-align','right').autoNumeric().trigger('blur');
		
	}
		
	return false;
}

function atualizaTabPj(){

	for(var i=0,len=arrTarifaPj.length; i<len; i++){
	
		$('#pjvltarifa'+i).val(arrTarifaPj[i].vltarifa);
		$('#pjqtdetari'+i).val(arrTarifaPj[i].qtlantar);
		$('#pjvlrtotal'+i).val(arrTarifaPj[i].vltotlan);
		
		$('#pjvlrtotal'+i).attr('alt','n9p3c2D').css('text-align','right').autoNumeric().trigger('blur');
		
	}
		
	return false;
}


function formataTabelaTarifa() {
	
	// Tabela
	var divRegistro = $('div.divRegistros', '#frmLantarPF');		
	var tabela      = $('table', divRegistro );
	
	$('#'+tabDados).css({'margin-top':'5px'});
	divRegistro.css({'height':'145px','padding-bottom':'2px'});

	var ordemInicial = new Array();

	var arrayLargura = new Array();
	arrayLargura[0] = '30px';
	arrayLargura[1] = '100px';
	arrayLargura[2] = '60px';
	arrayLargura[3] = '60px';

	var arrayAlinha = new Array();
	arrayAlinha[0] = 'left';
	arrayAlinha[1] = 'right';
	arrayAlinha[2] = 'right';
	arrayAlinha[3] = 'left';
	arrayAlinha[4] = 'left';
	
	tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha, '' );
	
	return false;
}

// Pesquisa Associados
function pesquisaAssociados() {

	showMsgAguardo('Aguarde, buscando pesquisa associados...');

	// Executa script através de ajax
	$.ajax({		
		type: 'POST',
		dataType: 'html',
		url: UrlSite + 'telas/lantar/pesquisa_associados.php', 
		data: {			
			redirect: 'html_ajax'			
			}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError('error','Não foi possível concluir a requisição.','Alerta - Ayllos',"unblockBackground()");
		},
		success: function(response) {
			$('#divRotina').html(response);
			montaPesquisaAssociados();
		}				
	});
	return false;
	
}


function montaPesquisaAssociados() {

	$.ajax({		
		type: 'POST',
		dataType: 'html',
		url: UrlSite + 'telas/lantar/monta_form_pesquisa.php', 
		data: {
			redirect: 'script_ajax'			
			}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError('error','Não foi possível concluir a requisição.','Alerta - Ayllos',"unblockBackground();");
		},
		success: function(response) {
		
			if ( response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1 ) {
				try {
					$('#divBuscaAssociados').html(response);
					exibeRotina($('#divRotina'));
					formataConsultaAssociado();
					$('#nmprimtl','#divBuscaAssociados').focus();
					
					$('#inpessoa','#divBuscaAssociados').habilitaCampo();
					
					if ( pessoaTela == 1 ){
						$('#inpessoa','#divBuscaAssociados').val(pessoaTela).desabilitaCampo();
					}
					
					if ( pessoaTela == 2 ){
						$('#inpessoa','#divBuscaAssociados').val(pessoaTela).desabilitaCampo();
					}
					
					hideMsgAguardo();
					bloqueiaFundo($('#divRotina'));
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


function formataConsultaAssociado() {

	$('#divRotina').css('width','680px');

	var divBuscaAssociados = "divBuscaAssociados";
	
	highlightObjFocus( $('#divBuscaAssociados') );

 	// Rotulos 
	var rNmprimtl	= $('label[for="nmprimtl"]','#'+divBuscaAssociados);
	var rCdagenci	= $('label[for="cdagenci"]','#'+divBuscaAssociados);
	var rInpessoa	= $('label[for="inpessoa"]','#'+divBuscaAssociados);
	var rCdtipcta	= $('label[for="cdtipcta"]','#'+divBuscaAssociados);
	var rFlgchcus	= $('label[for="flgchcus"]','#'+divBuscaAssociados);
	var rMespsqch	= $('label[for="mespsqch"]','#'+divBuscaAssociados);
	var rAnopsqch	= $('label[for="anopsqch"]','#'+divBuscaAssociados);
	
	rNmprimtl.addClass('rotulo').css('width','140px');
	rCdagenci.addClass('rotulo').css('width','140px').css('clear','none');
	rInpessoa.addClass('rotulo-linha').css('width','80px').css('clear','none');
	rCdtipcta.addClass('rotulo-linha').css('width','80px').css('clear','none');
	rFlgchcus.addClass('rotulo').css('width','200px').css('clear','none');
	rMespsqch.addClass('rotulo-linha').css('width','90px').css('clear','none');
	rAnopsqch.addClass('rotulo-linha').css('width','90px').css('clear','none');
	
	// Campos
	var cTodos	  	= $('input[type="text"],select','#'+divBuscaAssociados);
	var cNmprimtl	= $('#nmprimtl','#'+divBuscaAssociados);	
	var cCdagenci	= $('#cdagenci','#'+divBuscaAssociados);	
	var cInpessoa	= $('#inpessoa','#'+divBuscaAssociados);	
	var cCdtipcta	= $('#cdtipcta','#'+divBuscaAssociados);	
	var cFlgchcus	= $('#flgchcus','#'+divBuscaAssociados);	
	var cMespqsch	= $('#mespsqch','#'+divBuscaAssociados);	
	var cAnopsqch	= $('#anopsqch','#'+divBuscaAssociados);	

	// cTodos.habilitaCampo();
	cNmprimtl.addClass('campo').attr('maxlength','200').css('width','531px');
	cCdagenci.addClass('campo inteiro').css('width','40px');
	cCdagenci.attr('maxlength','3').setMask('INTEGER','zzz','','');
	cInpessoa.addClass('campo').css('width','140px');
	cCdtipcta.addClass('campo').css('width','167px');
	cFlgchcus.css('margin-left','117');
	cMespqsch.addClass('campo').css('width','90px');
	cAnopsqch.addClass('campo').css('width','60px').setMask('INTEGER','zzzz','','');
	
	$('#mespsqch','#divBuscaAssociados').desabilitaCampo();	
	$('#anopsqch','#divBuscaAssociados').desabilitaCampo();
	
	
	cInpessoa.unbind('change').bind('change', function(e) {
			buscar_tipos_de_conta(cInpessoa.val());
	});
	
	cFlgchcus.unbind('click').bind('click', function(e) {
			
		if( $(this).prop("checked") == true ){
			$(this).val("yes");		
			$('#mespsqch','#divBuscaAssociados').habilitaCampo().focus();	
			$('#anopsqch','#divBuscaAssociados').habilitaCampo();
			
			var dtmvtolt = $('#glbdtmvtolt','#frmCab').val();
			
			var ano_atual = parseInt(dtmvtolt.split("/")[2].toString()); 
			
			$('#anopsqch','#divBuscaAssociados').val(ano_atual); // Daniel
		}else{
			$(this).val("no");		
			$('#mespsqch','#divBuscaAssociados').val('').desabilitaCampo();	
			$('#anopsqch','#divBuscaAssociados').val('').desabilitaCampo();
		}		
			
	});
	
	controlaFocusPesquisa();
	
	buscar_tipos_de_conta(cInpessoa.val());
	
	layoutPadrao();
	
	return false;
}


function buscaDadosAssociado(nriniseq, nrregist) {

	showMsgAguardo('Aguarde, buscando associados...');
	
	var divBuscaAssociados = "divBuscaAssociados";
	
	var nmprimtl	= $('#nmprimtl','#'+divBuscaAssociados).val();	
	var cdagenci	= normalizaNumero($('#cdagenci','#'+divBuscaAssociados).val());	
	var inpessoa	= normalizaNumero($('#inpessoa','#'+divBuscaAssociados).val());	
	var cdtipcta	= normalizaNumero($('#cdtipcta','#'+divBuscaAssociados).val());	
	var flgchcus	= $('#flgchcus','#'+divBuscaAssociados).val();	
	var mespsqch	= $('#mespsqch','#'+divBuscaAssociados).val();	
	var anopsqch	= $('#anopsqch','#'+divBuscaAssociados).val();	
	var arrpesqu	= arrPesqAssociado;
	
	var cddopcao	= 'C';
	
	if ( flgchcus == 'yes' ) {
		if ( mespsqch == '' ) {
			 hideMsgAguardo();
			 showError('error','Mes do periodo deve ser informada.','Alerta - Ayllos',"focaCampoErro(\'mespsqch\', \'divBuscaAssociados\');bloqueiaFundo($('#divRotina'));",false);
			 return false;
		}
		
		if ( anopsqch == '' ) {
			 hideMsgAguardo();
			 showError('error','Ano do periodo deve ser informada.','Alerta - Ayllos','anopsqch.focus();');
			 return false;
		}
		
		var dtmvtolt = $('#glbdtmvtolt','#frmCab').val();
		
		if ( mespsqch.length == 1 ){
			mespsqch = '0' + mespsqch;
		}
		
		var data_sistema = parseInt(dtmvtolt.split("/")[2].toString() + dtmvtolt.split("/")[1].toString() ); 
		var data_tela = parseInt(anopsqch.toString() + mespsqch.toString() ); 
		

		if ( data_tela >= data_sistema ) {
			 hideMsgAguardo();
			 showError('error','Periodo informado deve ser menor que mes e ano atual.','Alerta - Ayllos',"focaCampoErro(\'mespsqch\', \'divBuscaAssociados\');bloqueiaFundo($('#divRotina'));",false);
			 return false;
		}
		
	}
	
	// Executa script através de ajax
	$.ajax({		
		type: 'POST',
		dataType: 'html',
		url: UrlSite + 'telas/lantar/busca_associados.php', 
		data: {			
			cddopcao: cddopcao,
			nmprimtl: nmprimtl,
			cdagenci: cdagenci,
			inpessoa: inpessoa,
			cdtipcta: cdtipcta,
			flgchcus: flgchcus,
			mespsqch: mespsqch,
			anopsqch: anopsqch,
			nriniseq: nriniseq,
			nrregist: nrregist,
			arrpesqu: arrpesqu,
			redirect: 'html_ajax'			
			}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError('error','Não foi possível concluir a requisição.','Alerta - Ayllos',"unblockBackground()");
		},
		success: function(response) {
			$('#divConsultaAssociado').html(response);		
			formataDivConsultaAssociado();
			$('#divPesquisaRodape','#divConsultaAssociado').formataRodapePesquisa();
			hideMsgAguardo();
			bloqueiaFundo($('#divRotina'));
			$('#nmprimtl','#'+divBuscaAssociados).desabilitaCampo();
			$('#cdagenci','#'+divBuscaAssociados).desabilitaCampo();
			$('#inpessoa','#'+divBuscaAssociados).desabilitaCampo();	
			$('#cdtipcta','#'+divBuscaAssociados).desabilitaCampo();	
			$('#flgchcus','#'+divBuscaAssociados).desabilitaCampo();	
			$('#mespsqch','#'+divBuscaAssociados).desabilitaCampo();	
			$('#anopsqch','#'+divBuscaAssociados).desabilitaCampo();	
		}				
	});
	
	return false;

}

function formataDivConsultaAssociado() {

	var divRegistro = $('#divAssociados');		
	var tabela      = $('table', divRegistro );
	var linha       = $('table > tbody > tr', divRegistro );
	
	divRegistro.css({'height':'100%','width':'100%'});
	
	var ordemInicial = new Array();
	ordemInicial = [[1,0]];	
	
	var arrayLargura = new Array();
	arrayLargura[0] = '30px';
	arrayLargura[1] = '70px';
	arrayLargura[2] = '280px';
	arrayLargura[3] = '30px';
	arrayLargura[4] = '80px';
	arrayLargura[5] = '130px';
	
		
	var arrayAlinha = new Array();
	arrayAlinha[0] = 'center';
	arrayAlinha[1] = 'right';
	arrayAlinha[2] = 'left';
	arrayAlinha[3] = 'left';
	arrayAlinha[4] = 'left';
	arrayAlinha[5] = 'left';
	arrayAlinha[6] = 'left';
	
	var metodoTabela = '';
			
	tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha, metodoTabela );
	
	$("th:eq(0)", tabela).removeClass();
	$("th:eq(0)", tabela).unbind('click');
	controlaCheck();
	
	return false;
	
}

function vinculaContas() {

	// Limpa Array
	arrAssociado = [];

	for(x=0;x<arrPesqAssociado.length;x++) {
		criaObjetoAssociado(arrPesqAssociado[x].cdagenci, arrPesqAssociado[x].nrdconta, arrPesqAssociado[x].nrmatric, arrPesqAssociado[x].cdtipcta, arrPesqAssociado[x].dstipcta, arrPesqAssociado[x].nmprimtl, $('#inpessoa','#divBuscaAssociados').val(), arrPesqAssociado[x].qtdchcus )
	}
	
}

// Função para chamar a manter_rotina.php
function buscar_tipos_de_conta (inpessoa) {
	
	$.ajax({
		type: 'POST',
		dataType: 'html',
		url: UrlSite + 'telas/cadsoa/buscar_tipos_de_conta.php',
		data: {
			inpessoa: inpessoa,
			redirect: 'script_ajax'
		},
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError('error','Nao foi possivel concluir a operacao.','Alerta - Ayllos','unblockBackground()');
		},
		success: function(response) {
			try {
				hideMsgAguardo();
				
				var cCdtipcta = $('#cdtipcta','#divBuscaAssociados');
				
				var xml = response;
				cCdtipcta.html('<option value=""> < Todos ></option>');
				glb_tipos_de_conta = [];
				
				$(xml).find('tipo_conta').each(function() {
					
					var cdtipo_conta = $(this).find('cdtipo_conta').text();
					var dstipo_conta = $(this).find('dstipo_conta').text();
					
					var tipo_de_conta = {
						cdtipo_conta: cdtipo_conta
					}
					
					glb_tipos_de_conta.push(tipo_de_conta);
					cCdtipcta
					cCdtipcta.append('<option value="' + cdtipo_conta + '"> ' + cdtipo_conta + ' - ' + dstipo_conta + "</option>");
					
				});
				cCdtipcta.val(0);
				
				return false;
			} catch(error) {
				hideMsgAguardo();
				showError('error','Nao foi possivel concluir a operacao.','Alerta - Ayllos','unblockBackground()');
			}
		}
	});
}

function controlaFocusPesquisa() {

	var divBuscaAssociados = "divBuscaAssociados";
	
	// Campos
	var cNmprimtl	= $('#nmprimtl','#'+divBuscaAssociados);	
	var cCdagenci	= $('#cdagenci','#'+divBuscaAssociados);	
	var cInpessoa	= $('#inpessoa','#'+divBuscaAssociados);	
	var cCdtipcta	= $('#cdtipcta','#'+divBuscaAssociados);	
	var cFlgchcus	= $('#flgchcus','#'+divBuscaAssociados);	
	var cMespsqch	= $('#mespsqch','#'+divBuscaAssociados);	
	var cAnopsqch	= $('#anopsqch','#'+divBuscaAssociados);	
	
	cNmprimtl.unbind('keypress').bind('keypress', function(e) {
		if ( divError.css('display') == 'block' ) { return false; }		
		// Se é a tecla ENTER, 
		if ( e.keyCode == 9 || e.keyCode == 13 ) {	
			cCdagenci.focus();
			return false;
		}
	});	
	
	
	cCdagenci.unbind('keypress').bind('keypress', function(e) {
		if ( divError.css('display') == 'block' ) { return false; }		
		// Se é a tecla ENTER, 
		if ( e.keyCode == 9 || e.keyCode == 13 ) {	
			cInpessoa.focus();
			return false;
		}
	});
	
	cInpessoa.unbind('keypress').bind('keypress', function(e) {
		if ( divError.css('display') == 'block' ) { return false; }		
		// Se é a tecla ENTER, 
		if ( e.keyCode == 9 || e.keyCode == 13 ) {	
			cCdtipcta.focus();
			return false;
		}
	});
	
	cCdtipcta.unbind('keypress').bind('keypress', function(e) {
		if ( divError.css('display') == 'block' ) { return false; }		
		// Se é a tecla ENTER, 
		if ( e.keyCode == 9 || e.keyCode == 13 ) {	
			cFlgchcus.focus();
			return false;
		}
	});
	
	cMespsqch.unbind('keypress').bind('keypress', function(e) {
		if ( divError.css('display') == 'block' ) { return false; }		
		// Se é a tecla ENTER, 
		if ( e.keyCode == 9 || e.keyCode == 13 ) {	
			cAnopsqch.focus();
			return false;
		}
	});
	
	cAnopsqch.unbind('keypress').bind('keypress', function(e) {
		if ( divError.css('display') == 'block' ) { return false; }		
		// Se é a tecla ENTER, 
		if ( e.keyCode == 9 || e.keyCode == 13 ) {	
			cAnopsqch.focus();
			return false;
		}
	});
}


function btConcluirPesquisa() {

	showMsgAguardo('Aguarde, montando tabela de associados...');
	
	setTimeout(function(){pesquisaCarga();},1000);
	

	// vinculaContas();
	// fechaRotina($('#divRotina'));
	// carregaTabela();
	// formataTabela();
	// controlaLayout();
	
	// hideMsgAguardo();
	
	return false;

}


function controlaPesquisaPac() {

 	// Variável local para guardar o elemento anterior
	var campoAnterior = '';
	var bo, procedure, titulo, qtReg, filtros, colunas, cdcooper, nmrescop, cdagenci, titulo_coluna, cdagencis, nmresage;	
	
	// Nome do Formulário que estamos trabalhando
	var nomeFormulario = 'divBuscaAssociados';
	
	var divRotina = 'divTela';
	
	//Remove a classe de Erro do form
	$('input,select', '#'+nomeFormulario).removeClass('campoErro');
	
	var cdagenci = $('#cdagenci','#'+nomeFormulario).val();
	
	cdagencis = cdagenci;	
	nmresage = ' ';
	nmrescop = ' ';
	
	titulo_coluna = "Descricao";
	
	bo			= 'b1wgen0153.p'; 
	procedure	= 'lista-pacs';
	titulo      = 'Agência PA';
	qtReg		= '20';
	
	filtros 	= 'Cód. PA;cdagenci;30px;S;' + cdagenci + ';S|Agência PA;nmresage;200px;S;' + nmresage + ';N';
	colunas 	= 'Codigo;cdagenci;20%;right|' + titulo_coluna + ';nmresage;50%;left';
	
	
	mostraPesquisa(bo,procedure,titulo,qtReg,filtros,colunas,'','$(\'#cdagenci\',\'#divBuscaAssociados\').val()');
	
	return false; 
}


function controlaCheck() {

	$('#checkTodos','#divConsultaAssociado').unbind('click').bind('click', function(e) {
		
		if( $(this).prop("checked") == true ){
			$(this).val("yes");	
			$('input[type="checkbox"],select','#divConsultaAssociado').each(function(e){				
				if( $(this).prop("id") != "checkTodos"  ){
				    $(this).prop("checked",true);
					$(this).trigger("click");
					$(this).prop("checked",true);
				}	
			});
		} else {
		
			$(this).val("no");	
				$('input[type="checkbox"],select','#divConsultaAssociado').each(function(e){				
					if( $(this).prop("id") != "checkTodos"  ){
						$(this).prop("checked",false);
						$(this).trigger("click");
						$(this).prop("checked",false);
					}	
				});
		}
			
	});
	
}

function btnExcluir() {

	// Verifico se o focu esta em um dos campo quantidade para evitar 
	// chamada da função quando pressionado tecla delete para limpar o campo.
	for (var i=0,len=arrTarifaPf.length; i<len; i++) {
			
			if ( $('#qtdetari'+i).hasClass('campoFocusIn') ) {
				return false;
			}			
	}

	if ( glbTabNrdconta == '' ) {
		showError('error','Não há registro selecionado','Alerta - Ayllos',"unblockBackground()");
		return false
	} else {
		showConfirmacao('Deseja realmente excluir o registro selecionado?','Confirma&ccedil;&atilde;o - Ayllos','excluirRegistro()','return false;','sim.gif','nao.gif');	
	}

}

function excluirRegistro() {


	for(x=0;x<arrAssociado.length;x++) {
		if ( arrAssociado[x].nrdconta == glbTabNrdconta ) {
			arrAssociado.splice(x,1);
		}
		
	}
	
	for(x=0;x<arrPesqAssociado.length;x++) {
		if ( arrPesqAssociado[x].nrdconta == glbTabNrdconta ) {
			arrPesqAssociado.splice(x,1);
		}
		
	}
	
	carregaTabela();
	formataTabela();
	controlaLayout();
	return false;
	
}

function pesquisaCarga() {

	vinculaContas();
	fechaRotina($('#divRotina'));
	carregaTabela();
	formataTabela();
	controlaLayout();
	
	hideMsgAguardo();
	
	return false;

}