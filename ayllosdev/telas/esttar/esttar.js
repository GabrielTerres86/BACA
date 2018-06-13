/*!
 * FONTE        : esttar.js
 * CRIAÇÃO      : Daniel Zimmermann 
 * DATA CRIAÇÃO : 13/03/2013
 * OBJETIVO     : Biblioteca de funções da tela ESTTAR
 * --------------
 * ALTERAÇÕES   : 
 * -----------------------------------------------------------------------
 */

// Formulários e Tabela
var frmCab   		= 'frmCab';

//Labels/Campos do cabeçalho
var rNrdconta, cNrdconta, rNmprimtl, cNmprimtl, rDtinicio, cDtinicio, rDtafinal, cDtafinal,
rCddopcap, cCddopcap, rCdhistor, cCdhistor, rDshistor, cDshistor, cTodosCabecalho, arrTarifa;

$(document).ready(function() {
	estadoInicial();
});

function estadoInicial() {

	$('#divTela').fadeTo(0,0.1);
	
	$('#divEstorno').html('');
	
	$( "#dtinicio" ).datepicker("option", "disabled", false);
	$( "#dtafinal" ).datepicker("option", "disabled", false);
	
	arrTarifa = new Array();

	hideMsgAguardo();		
	formataCabecalho();
	controlaNavegacao();
	
	//trocaBotao('Prosseguir');
	
	cTodosCabecalho.limpaFormulario().removeClass('campoErro');	

	highlightObjFocus( $('#frmCab') );
	
	$('#frmCab').css({'display':'block'});
	$('#divBotoes').css({'display':'block'});
	$('#formTabEsttar').css({'display':'none'});
	$('#formRodape').css({'display':'none'});
	
	$("#btSalvar","#divBotoes").show();
	$("#btConcluir","#divBotoes").hide();
	
	cNrdconta.focus();	
	removeOpacidade('divTela');
	
}

function formataCabecalho() {

	// Cabecalho
	rNrdconta			= $('label[for="nrdconta"]','#'+frmCab); 
	rDtinicio			= $('label[for="dtinicio"]','#'+frmCab); 
	rDtafinal			= $('label[for="dtafinal"]','#'+frmCab); 
	rCddopcap			= $('label[for="cddopcap"]','#'+frmCab); 
	rCdhistor			= $('label[for="cdhistor"]','#'+frmCab); 
	rCdagenci			= $('label[for="cdagenci"]','#'+frmCab); 
	
	cNrdconta			= $('#nrdconta','#'+frmCab); 
	cNmprimtl			= $('#nmprimtl','#'+frmCab);
	cCdagenci			= $('#cdagenci','#'+frmCab);
	cDtinicio			= $('#dtinicio','#'+frmCab); 
	cDtafinal			= $('#dtafinal','#'+frmCab); 
	cCddopcap			= $('#cddopcap','#'+frmCab); 
	cCdhistor			= $('#cdhistor','#'+frmCab);
	cDshistor			= $('#dshistor','#'+frmCab);
	
	cTodosCabecalho		= $('input[type="text"],select','#'+frmCab);
	
	rNrdconta.addClass('rotulo').css({'width':'60px'});
	rCdagenci.addClass('rotulo-linha').css({'width':'38px'});
	rDtinicio.addClass('rotulo').css({'width':'60px'});
	rDtafinal.addClass('rotulo-linha').css({'width':'38px'}).css({'text-align':'center'});
	rCddopcap.addClass('rotulo-linha').css({'width':'220px'});
	rCdhistor.addClass('rotulo').css({'width':'60px'});
	
	if ( $.browser.msie ) {
		rCddopcap.addClass('rotulo-linha').css({'width':'225px'});
	}
	
	cNrdconta.addClass('conta pesquisa').css({'width':'80px'});
	cNmprimtl.css({'width':'395px'});
	cCdagenci.css({'width':'130px'});
	cDtinicio.addClass('data').css({'width':'80px'});
	cDtafinal.addClass('data').css({'width':'80px'});
	cCdhistor.addClass('inteiro').css({'width':'80px'}).attr('maxlength','6');;
	cDshistor.css({'width':'570px'});
	
	cTodosCabecalho.desabilitaCampo();

	cNrdconta.habilitaCampo();
	
	layoutPadrao();

	return false;
}


// Controle
function buscaAssociado() {

	hideMsgAguardo();

	var nrdconta = normalizaNumero( cNrdconta.val() );
	
	var mensagem = 'Aguarde, buscando associado ...';
	showMsgAguardo( mensagem );	
	
	//Carrega dados da conta através de ajax
	$.ajax({		
		type	: 'POST',
		url		: UrlSite + 'telas/esttar/busca_associado.php', 
		data    : 
				{ 
					nrdconta	: nrdconta,
					redirect	: 'script_ajax' 
				}, 
				error: function(objAjax,responseError,objExcept) {
					hideMsgAguardo();
					showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
				},
				success: function(response) {
				
					if ( response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1 ) {
						try {
							hideMsgAguardo();
							eval(response);
							controlaLayout();
							$('#dtinicio','#frmCab').focus();
						} catch(error) {
							hideMsgAguardo();
							showError('error','1N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','unblockBackground()');
						}
					} else {
						try {
							eval( response );
						} catch(error) {
							hideMsgAguardo();
							showError('error','2N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','unblockBackground()');
						}
					}
					
				}						
	});				
}


function controlaPesquisas(valor) {

	switch( valor )
	{
		case 1:
			controlaPesquisaAssociado();
			break;
		case 2:
			controlaPesquisaHistorico();
			break;
	}
	
}


function controlaPesquisaAssociado() {

	// Se esta desabilitado o campo 
	if ($("#nrdconta","#frmCab").prop("disabled") == true)  {
		return;
	}

	mostraPesquisaAssociado('nrdconta', frmCab );
	return false;


}


// Formata
function controlaNavegacao() {

	cNrdconta.unbind('keypress').bind('keypress', function(e) {
		if ( divError.css('display') == 'block' ) { return false; }		
		// Se é a tecla ENTER, 
		if ( e.keyCode == 13 ) {
			if ( cNrdconta.val() != '') {
				buscaAssociado();
				return false;
			} else {
				mostraPesquisaAssociado('nrdconta', frmCab );
				return false;
			}
		} else if ( e.keyCode == 118 ) {
			mostraPesquisaAssociado('nrdconta', frmCab );
			return false;
		}
	});	
	
	cDtinicio.unbind('keypress').bind('keypress', function(e) {
		if ( divError.css('display') == 'block' ) { return false; }		
		// Se é a tecla ENTER, 
		if ( e.keyCode == 13 ) {
			cDtafinal.focus();
			return false;
		}
	});	
	
	cDtafinal.unbind('keypress').bind('keypress', function(e) {
		if ( divError.css('display') == 'block' ) { return false; }		
		// Se é a tecla ENTER, 
		if ( e.keyCode == 13 ) {
			cCddopcap.focus();
			return false;
		}
	});
	
	cCddopcap.unbind('keypress').bind('keypress', function(e) {
		if ( divError.css('display') == 'block' ) { return false; }		
		// Se é a tecla ENTER, 
		if ( e.keyCode == 13 ) {
			cCdhistor.focus();
			return false;
		}
	});
	
	cCdhistor.unbind('keypress').bind('keypress', function(e) {
		if ( divError.css('display') == 'block' ) { return false; }		
		// Se é a tecla ENTER, 
		if ( e.keyCode == 13 ) {
			if (cCdhistor.val() == '') {
				cDshistor.val('TODOS');
				btnContinuar(); 
			} else {
				buscaHistorico();
			}
			return false;
		}
	});

	
	return false;	
}

function controlaLayout() {

	formataCabecalho();
	
	cNrdconta.desabilitaCampo();
	cDtinicio.habilitaCampo();
	cDtafinal.habilitaCampo();
	cCddopcap.habilitaCampo();
	cCdhistor.habilitaCampo();
	
	cDtinicio.focus();
	layoutPadrao();
	return false;
}

// Botoes
function btnVoltar() {
	estadoInicial();
	return false;
}

function btnContinuar() {

	//Remove a classe de Erro do form
	$('input,select', '#frmCab').removeClass('campoErro');

	if ( ! cNrdconta.hasClass('campoTelaSemBorda') ){ 
		if ( cNrdconta.val() != ''  ){
			buscaAssociado();
			return false;
		}
	
		return false;
	}

	
	var dtinicio = cDtinicio.val();
	var dtafinal = cDtafinal.val();
	var cddopcap = cCddopcap.val();

	if ( dtinicio == '' ){
		hideMsgAguardo();
		showError("error","Periodo Inicial deve ser informado.","Alerta - Ayllos","focaCampoErro(\'dtinicio\', \'frmCab\');",false);
		return false;
	
	}
	
	if ( dtafinal == '' ){
		hideMsgAguardo();
		showError("error","Periodo Final deve ser informado.","Alerta - Ayllos","focaCampoErro(\'dtafinal\', \'frmCab\');",false);
		return false;
	
	}
	
		
	var aux_inicio = parseInt(dtinicio.split("/")[2].toString() + dtinicio.split("/")[1].toString() + dtinicio.split("/")[0].toString()); 
	var aux_final  = parseInt(dtafinal.split("/")[2].toString() + dtafinal.split("/")[1].toString() + dtafinal.split("/")[0].toString()); 
	
	if ( aux_inicio > aux_final ) {
		hideMsgAguardo();
		showError("error","Periodo Inicial deve ser menor que Periodo Final.","Alerta - Ayllos","focaCampoErro(\'dtinicio\', \'frmCab\');",false);
		return false;
	}
	
	var dtlimest = $('#dtlimest','#frmCab').val();
	var aux_dtlimest  = parseInt(dtlimest.split("/")[2].toString() + dtlimest.split("/")[1].toString() + dtlimest.split("/")[0].toString()) ; 
	
	if (( aux_inicio < aux_dtlimest ) && (cddopcap == 1 || cddopcap == 3)){
		hideMsgAguardo();
		showError("error","Periodo Inicial maior que o prazo permitido para estorno/suspens&atilde;o (" + dtlimest + ").","Alerta - Ayllos","focaCampoErro(\'dtinicio\', \'frmCab\');",false);
		return false;
	}

	
	
	$('input[type="text"],select','#'+frmCab).desabilitaCampo();
	buscaTarifasConta();

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

function formataTabela() {
	
	// Tabela
	var divRegistro = $('div.divRegistros', '#divEstorno');		
	var tabela      = $('table', divRegistro );
	
	$('#divEstorno').css({'margin-top':'5px'});
	divRegistro.css({'height':'145px','padding-bottom':'2px'});

	var ordemInicial = new Array();

	var arrayLargura = new Array();
	arrayLargura[0] = '20px';
	arrayLargura[1] = '65px';
	arrayLargura[2] = '40px';
	arrayLargura[3] = '200px';
	arrayLargura[4] = '80px';
	arrayLargura[5] = '70px';

	var arrayAlinha = new Array();
	arrayAlinha[0] = 'left';
	arrayAlinha[1] = 'right';
	arrayAlinha[2] = 'right';
	arrayAlinha[3] = 'left';
	arrayAlinha[4] = 'right';
	arrayAlinha[5] = 'right';
	arrayAlinha[6] = 'left';
	
	tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha, '' );
	
	$("th:eq(0)", tabela).removeClass();
	$("th:eq(0)", tabela).unbind('click');
	
	$('input[type="text"],select','#divEstorno').desabilitaCampo();
	
	$('.motivo','#divEstorno').css("visibility","hidden");
	$('.lupa','#divEstorno').css("visibility","hidden");
	
	return false;
}


function formataRodape() {

	rQtdselec			= $('label[for="qtdselec"]','#formRodape'); 
	rTotselec			= $('label[for="totselec"]','#formRodape'); 
	rQtdtotal			= $('label[for="qtdtotal"]','#formRodape'); 
	rVlrtotal			= $('label[for="vlrtotal"]','#formRodape'); 
	
	cQtdselec			= $('#qtdselec','#formRodape'); 
	cTotselec			= $('#totselec','#formRodape');
	cQtdtotal			= $('#qtdtotal','#formRodape');
	cVlrtotal			= $('#vlrtotal','#formRodape'); 
	
	rQtdselec.addClass('rotulo').css({'width':'85px'}).css({'padding-left':'5px'});
	rTotselec.addClass('rotulo-linha').css({'width':'60px'}).css({'padding-left':'20px'});
	rQtdtotal.addClass('rotulo-linha').css({'width':'200px'});
	rVlrtotal.addClass('rotulo-linha').css({'width':'60px'}).css({'padding-left':'20px'});
	
	cQtdselec.addClass('campo').css({'width':'40px'});
	cTotselec.addClass('campo moeda').css({'width':'80px'}).setMask("DECIMAL","zzz.zzz.zz9,99","","");
	cQtdtotal.addClass('campo').css({'width':'40px'});
	cVlrtotal.addClass('campo moeda').css({'width':'80px'}).setMask("DECIMAL","zzz.zzz.zz9,99","","");
	
	cQtdselec.desabilitaCampo();
	cTotselec.desabilitaCampo();
	cQtdtotal.desabilitaCampo();
	cVlrtotal.desabilitaCampo();

}

function liberaCampo() {

	$('#formTabEsttar').css({'display':'block'});
	$('#formRodape').css({'display':'block'});
	
	cNrdconta.desabilitaCampo();
	cDtinicio.habilitaCampo();
	cDtafinal.habilitaCampo();
	cCdhistor.habilitaCampo();
	
	cDtafinal.val('<?php echo $glbvars["dtmvtolt"]; ?>');
}

function buscaHistorico(){

	showMsgAguardo("Aguarde, consultando Historico...");

	var cdhistor = $('#cdhistor','#frmCab').val();
	cdhistor = normalizaNumero(cdhistor);	
	
	// Executa script através de ajax
	$.ajax({		
		type: "POST",
		url: UrlSite + "telas/esttar/busca_historico.php", 
		data: {
			cdhistor: cdhistor,
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


function buscaTarifasConta() {

	if (cCdhistor.val() == '') {
		cDshistor.val('TODOS');
	}

	hideMsgAguardo();
	showMsgAguardo( 'Aguarde, buscando tarifas ...' );	

	var nrdconta = normalizaNumero( cNrdconta.val() );
	var cddopcap = cCddopcap.val();
	var dtinicio = cDtinicio.val();
	var dtafinal = cDtafinal.val();
	var cdhistor = cCdhistor.val();
	
	
	
	
	// Carrega dados da conta através de ajax
	$.ajax({		
		type	: 'POST',
		dataType: 'html',
		url		: UrlSite + 'telas/esttar/busca_tarifas_estorno.php', 
		data    : 
				{ 
					nrdconta	: nrdconta,
					cddopcap	: cddopcap,
					dtinicio	: dtinicio,
					dtafinal	: dtafinal,
					cdhistor	: cdhistor,
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
							$('input[type="text"],select','#frmCab').desabilitaCampo();
							$('#divEstorno').html(response);
							formataTabela();
							formataRodape();
							controlaCheck();
							$("#btSalvar","#divBotoes").hide();
							$("#btConcluir","#divBotoes").show();
							$('#formTabEsttar').css({'display':'block'});
							$('#formRodape').css({'display':'block'});
							$( ".ui-datepicker-trigger" ).css({'display':'none'});
							rCddopcap.addClass('rotulo-linha').css({'width':'209px'});
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

function verificaSelecionados(){
	var conta = 0;
	var valor = 0;

	$('input[type="checkbox"],select','#formTabEsttar').each(function(e){				
			
		if( $(this).prop("id") != "checkTodos"  ){
			if( $(this).prop("checked") == true ){
				conta = conta + 1;
				valor = valor + parseFloat( $('#vltarifa' + normalizaNumero($(this).prop("id")).toString() ).val() );
			}
		}	
	});
	
	valor = number_format(valor,2,',','');
	
	$('#qtdselec','#formRodape').val(conta) ;
	$('#totselec','#formRodape').val(valor) ;
	return false;
}

function controlaCheck() {

	$('#checkTodos','#formTabEsttar').unbind('click').bind('click', function(e) {
		
		if( $(this).prop("checked") == true ){
			$(this).val("yes");	
			$('input[type="checkbox"],select','#formTabEsttar').each(function(e){				
				if( $(this).prop("id") != "checkTodos"  ){
				    $(this).prop("checked",true);
					$(this).trigger("click");
					$(this).prop("checked",true);
				}	
			});
		} else {
		
			$(this).val("no");	
				$('input[type="checkbox"],select','#formTabEsttar').each(function(e){				
					if( $(this).prop("id") != "checkTodos"  ){
						$(this).prop("checked",false);
						$(this).trigger("click");
						$(this).prop("checked",false);
					}	
				});
		}
		
		verificaSelecionados();
			
	});
	
}


function pesquisaMotivo(valor) {

	if ( $('#dsmotest'+valor,'#formTabEsttar').css('visibility') == 'hidden' ) { return false; }	


	// Variável local para guardar o elemento anterior
	var campoAnterior = '';
	var bo, procedure, titulo, qtReg, filtros, colunas, cdmotest, titulo_coluna, cdmotests, dsmotest, tpaplica;	
	
	// Nome do Formulário que estamos trabalhando
	var nomeFormulario = 'formTabEsttar';
	
	var divRotina = 'divTela';
	
	//Remove a classe de Erro do form
	$('input,select', '#'+nomeFormulario).removeClass('campoErro');
	
	var cdmotest = $('#cdmotest'+valor,'#'+nomeFormulario).val();
	
	var teste = '#dsmotest'+valor;
	cdmotests = cdmotest;	
	dsmotest = ' ';
	tpaplica = 1;
	
	titulo_coluna = "Descricao";
	
	bo			= 'b1wgen0153.p'; 
	procedure	= 'lista-met';
	titulo      = 'Motivos de Estorno Baixa Suspensao de Tarifas';
	qtReg		= '10';
	filtros 	= 'Codigo;cdmotest;130px;S;' + cdmotest + ';S|Descricao;dsmotest;100px;S;' + dsmotest + ';N|Aplicacao;tpaplica;100px;N;' + tpaplica + ';N';
	colunas 	= 'Codigo;cdmotest;20%;right|' + titulo_coluna + ';dsmotest;50%;left';
	mostraPesquisa(bo,procedure,titulo,qtReg,filtros,colunas,'','buscaValorPesquisa(' + valor + ')'); 
	
	return false; 

}


function buscaValorPesquisa(posicao) {

	var valor  = $('#dsmotest','#formTabEsttar').val();
	var codigo = $('#cdmotest','#formTabEsttar').val();

	$('#dsmotest'+posicao,'#formTabEsttar').val(valor);
	$('#cdmotest'+posicao,'#formTabEsttar').val(codigo);
	
}


function criticaOperacao(){

	var flagOK = true;
	var flagreg = false;

	$('input[type="checkbox"],select','#formTabEsttar').each(function(e){				
			
		if( $(this).prop("id") != "checkTodos"  ){
			if( $(this).prop("checked") == true ){
			
				flagreg = true;
			
				if ( $('#dsmotest' + normalizaNumero($(this).prop("id")).toString() ).val() == '' ){
					showError("error","Existem registros selecionados sem motivo informado.","Alerta - Ayllos","unblockBackground()");
					flagOK = false;
					return false;
				}
			}
		}	
	});
	
	if ( flagOK == true ) {
	
		if ( flagreg == false ){
			showError("error","Nenhum registro selecionado.","Alerta - Ayllos","unblockBackground()");
			return false;
		} else {
			showConfirmacao('Deseja realmente efetuar operacao para os registros selecionados?','Confirma&ccedil;&atilde;o - Ayllos','efetuaOperacao();','return false;','sim.gif','nao.gif');
		}
	}
	
}

function efetuaOperacao() {

	hideMsgAguardo();
	showMsgAguardo( 'Aguarde, efetuando Estorno/Baixa/Suspensão de Lançamentos ...' );
	
	var strCdlantar = '';
	var strCdmotest = '';
	
	// Monta lista de baixa/estorno/suspensao a serem efetuados.
	$('input[type="checkbox"],select','#formTabEsttar').each(function(e){				
			
		if( $(this).prop("id") != "checkTodos"  ){
			if( $(this).prop("checked") == true ){
				strCdlantar = strCdlantar + $('#cdlantar' + normalizaNumero($(this).prop("id")).toString() ).val() + ';';
				strCdmotest = strCdmotest + $('#cdmotest' + normalizaNumero($(this).prop("id")).toString() ).val() + ';';
			}
		}	
	});
	
	$.trim(strCdlantar);
	strCdlantar = strCdlantar.substr(0,strCdlantar.length - 1);
	
	$.trim(strCdmotest);
	strCdmotest = strCdmotest.substr(0,strCdmotest.length - 1);
	
	var nrdconta = normalizaNumero( cNrdconta.val() );
	var cddopcap = cCddopcap.val();
	
	// Carrega dados da conta através de ajax
	$.ajax({		
		type	: 'POST',
		dataType: 'html',
		url		: UrlSite + 'telas/esttar/manter_rotina.php', 
		data    : 
				{ 
					nrdconta	: nrdconta,
					cddopcap	: cddopcap,
					strCdlantar	: strCdlantar,
					strCdmotest	: strCdmotest,
					redirect	: 'script_ajax' 
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

	return false;	
		
}

function buscaQtdDiasEstorno() {

	// Carrega dados da conta através de ajax
	$.ajax({		
		type	: 'POST',
		dataType: 'html',
		url		: UrlSite + 'telas/esttar/busca_dias_estorno.php', 
		data    : 
				{ 
					redirect	: 'script_ajax' 
				},
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
		success: function(response) {
			try {
				eval(response);
			} catch(error) {
				hideMsgAguardo();
				showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message,"Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
			}
		}
	});

	return false;	
		
}

function controlaPesquisaHistorico() {

	// Se esta desabilitado o campo 
	if ($("#cdhistor","#frmCab").prop("disabled") == true)  {
		return;
	}
	
	// Variável local para guardar o elemento anterior
	var campoAnterior = '';
	var bo, procedure, titulo, qtReg, filtros, colunas, cdhistor, titulo_coluna, cdgrupos, dshistor;	
	
	// Nome do Formulário que estamos trabalhando
	var nomeFormulario = 'frmCab';
	
	var divRotina = 'divTela';
	
	//Remove a classe de Erro do form
	$('input,select', '#'+nomeFormulario).removeClass('campoErro');
	
	var cdhistor = $('#cdhistor','#'+nomeFormulario).val();
	cdhistor = cdhistor;	
	dshistor = '';
	
	titulo_coluna = "Historicos";
	
	bo			= 'b1wgen0153.p'; 
	procedure	= 'lista-historicos';
	titulo      = 'Historicos';
	qtReg		= '20';
	filtros 	= 'Codigo;cdhistor;80px;S;' + cdhistor + ';S|Descricao;dshistor;280px;S;' + dshistor + ';S';
	colunas 	= 'Codigo;cdhistor;20%;right|' + titulo_coluna + ';dshistor;50%;left';
	mostraPesquisa(bo,procedure,titulo,qtReg,filtros,colunas,'','$(\'#cdhistor\',\'#frmCab\').val()');
	
	return false;
}
