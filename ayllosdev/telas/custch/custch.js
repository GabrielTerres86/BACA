/*!
 * FONTE        : custch.js
 * CRIAÇÃO      : Douglas Quisinski
 * DATA CRIAÇÃO : 08/05/2015
 * OBJETIVO     : Biblioteca de funções da tela CUSTCH
 * --------------
 * ALTERAÇÕES   : 11/04/2017 - Permitir acessar o Ayllos mesmo vindo do CRM. (Jaison/Andrino)
 * --------------
 */

//Formulários e Tabela
var frmCab   = 'frmCab';
var frmDados = 'frmCustch';
var tabDados = 'tabCustch';
var aux_dtmvtolt = '';

//Labels/Campos do cabeçalho
var rNrdconta, cNrdconta, 
	rNmprimtl, cNmprimtl, 
	rDtchebom, cDtchqbom,
	rVlcheque, cVlcheque,
	rDsdocmc7, cDsdocmc7,
	cTodosCabecalho, cTodosCheque,
	btnOK, btnAdd,
	cTodosDados;	
	
$(document).ready(function() {
	estadoInicial();
});

// seletores
function estadoInicial() {
	$('#divTela').fadeTo(0,0.1);

	hideMsgAguardo();
	formataCabecalho();
		
	cTodosCabecalho.limpaFormulario().removeClass('campoErro');	

	removeOpacidade('divTela');

	highlightObjFocus( $('#frmCab') ); 
	
	$('#frmCab').css({'display':'block'});
	$('#divTela').css({'width':'1000px','padding-bottom':'2px'});

	cNrdconta.focus();

    // Seta os valores caso tenha vindo do CRM
    if ($("#crm_inacesso","#frmCab").val() == 1) {
        $("#nrdconta","#frmCab").val($("#crm_nrdconta","#frmCab").val());
    }
}

// controle
function controlaOperacao( ) {

	var nrdconta = normalizaNumero( cNrdconta.val() );
	var nmprimtl = cNmprimtl.val();
	
	showMsgAguardo( 'Aguarde, buscando dados ...' );		
	
	// Carrega dados da conta através de ajax
	$.ajax({		
		type	: 'POST',
		dataType: 'html',
		url		: UrlSite + 'telas/custch/principal.php', 
		data    : 
				{ 	
					nrdconta: nrdconta,
					nmprimtl: nmprimtl,
					redirect: 'script_ajax' 
				},
		error   : function(objAjax,responseError,objExcept) {
					hideMsgAguardo();
					showError('error','N&atilde;o foi possível concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','estadoInicial();');
				},
		success : function(response) {
					hideMsgAguardo();
					if ( response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1 ) {
						try {
							$('#divTela').html(response);
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

function controlaPesquisas() {

	/*---------------------*/
	/*  CONTROLE CONTA/DV  */
	/*---------------------*/
	var linkConta = $('a:eq(0)','#'+ frmCab );

	if ( linkConta.prev().hasClass('campoTelaSemBorda') ) {		
		linkConta.addClass('lupa').css('cursor','auto').unbind('click').bind('click', function() { return false; });
	} else {

		linkConta.prev().unbind('blur').bind('blur', function() { 
			controlaPesquisas();
			return false;
		});	
	
		linkConta.css('cursor','pointer').unbind('click').bind('click', function() {			
			mostraPesquisaAssociado('nrdconta', frmCab );
		});
	}

	return false;
}

function controlaLayout( operacao ) {

	formataCabecalho();
	
	if ( operacao == 'BD' ) {
		cTodosCabecalho.habilitaCampo();
		cNrdconta.desabilitaCampo();
		cNmprimtl.desabilitaCampo();
	} else  {
		cTodosCabecalho.desabilitaCampo();
	}

	$('#frmCab').css({'display':'block'});
	controlaPesquisas();	
	
	hideMsgAguardo();
	return false;
}


// formata
function formataCabecalho() {

	// rotulo
	rNrdconta = $('label[for="nrdconta"]','#'+frmCab); 
	rNrdconta.addClass('rotulo').css({'width':'39px'});
	
	// campo
	cNrdconta = $('#nrdconta','#'+frmCab); 
	cNmprimtl = $('#nmprimtl','#'+frmCab); 

	cNrdconta.addClass('conta pesquisa').css({'width':'75px'})
	cNmprimtl.css({'width':'530px'});	

	// outros
	btnOK			= $('#btnOK','#'+frmCab);
	cTodosCabecalho	= $('input[type="text"],select','#'+frmCab);
	cTodosCabecalho.desabilitaCampo();
	cNrdconta.habilitaCampo();
	cNrdconta.focus();
	
	btnOK.unbind('click').bind('click', function() {
	
		if ( divError.css('display') == 'block' ) { return false; }		

		if ( cNrdconta.hasClass('campoTelaSemBorda')  ) { return false; }		
		
		// Armazena o número da conta na variável global
		var nrdconta = normalizaNumero( cNrdconta.val() );
		
		// Verifica se o número da conta é vazio
		if ( nrdconta == '' ) { return false; }
	
		// Verifica se a conta é válida
		if ( !validaNroConta(nrdconta) ) { 
			showError('error','Conta/dv inv&aacute;lida.','Alerta - Ayllos','focaCampoErro(\'nrdconta\',\''+ frmCab +'\');'); 
			return false; 
		}

		cTodosCabecalho.removeClass('campoErro');	
		
		// Se chegou até aqui, a conta é diferente do vazio e é válida, então realizar a operação desejada
		controlaOperacao();
		return false;
	
	});	
	
	
	cNrdconta.unbind('keypress').bind('keypress', function(e) {
		if ( divError.css('display') == 'block' ) { return false; }		

		// Se é a tecla ENTER, 
		if ( e.keyCode == 13 ) {
			btnOK.click();
			return false;

		} else if ( e.keyCode == 118 ) {
			mostraPesquisaAssociado('nrdconta', frmCab );
			return false;
		}
	});	

	layoutPadrao();
	cNrdconta.trigger('blur');
	controlaPesquisas();
	return false;	
}

function formataCampoCheque(){
	// rotulo
	rDtchebom = $('label[for="dtchebom"]','#'+frmDados); 
	rVlcheque = $('label[for="vlcheque"]','#'+frmDados);        
	rDsdocmc7 = $('label[for="dsdocmc7"]','#'+frmDados);        

	rDtchebom.addClass('rotulo').css({'width':'60px'});
	rVlcheque.addClass('rotulo-linha').css({'width':'60px'});
	rDsdocmc7.addClass('rotulo-linha').css({'width':'65px'});
	
	// campo
	cDtchqbom = $('#dtchqbom','#'+frmDados); 
	cVlcheque = $('#vlcheque','#'+frmDados); 
	cDsdocmc7 = $('#dsdocmc7','#'+frmDados); 

	cDtchqbom.css({'width':'75px'}).addClass('data');	
	cVlcheque.css({'width':'110px','text-align':'right'}).setMask('DECIMAL','zzz.zzz.zz9,99','.','');
	cDsdocmc7.css({'width':'290px'}).attr('maxlength','34');

	cDsdocmc7.unbind('keyup').bind('keyup', function(e) {
		formataCampoCmc7(false);
		return false;
	});
	cDsdocmc7.unbind('blur').bind('blur', function(e) {
		formataCampoCmc7(true);
		adicionaChequeCustodiar();
		return false;
	});
	cDsdocmc7.unbind('keypress').bind('keypress', function(e) {
		if ( divError.css('display') == 'block' ) { return false; }		

		// Se é a tecla ENTER, 
		if ( e.keyCode == 13 ) {
			btnAdd.click();
			return false;

		}
	});	

	// outros
	btnAdd		 = $('#btnAdd','#'+frmDados);
	btnAdd.unbind('click').bind('click', function() {
		if ( divError.css('display') == 'block' ) { return false; }		

		adicionaChequeCustodiar();
		return false;
	});		
	
	$('#'+frmDados).css({'display':'block'});
	highlightObjFocus( $('#'+frmDados) ); 

	cTodosCheque = $('input[type="text"],select','#'+frmDados);
	cTodosCheque.habilitaCampo();
	cDtchqbom.focus();
		
	layoutPadrao(); 
	return false;	
}

function formataTabelaCustodia(){
	// Tabela
	$('#tabCustch').css({'display':'block'});
    $('#divConteudo').css({'display':'block'});

    var divRegistro = $('div.divRegistros', '#tabCustch');
	var tabela      = $('table', divRegistro );
	var linha       = $('table > tbody > tr', divRegistro );

    $('#tabCustch').css({'margin-top':'5px'});
	divRegistro.css({'height':'305px','width':'1000px','padding-bottom':'2px'});

	var ordemInicial = new Array();

	var arrayLargura = new Array();
    arrayLargura[0] = '67px';
	arrayLargura[1] = '90px';
	arrayLargura[2] = '50px';
	arrayLargura[3] = '50px';
	arrayLargura[4] = '90px';
	arrayLargura[5] = '90px';
	arrayLargura[6] = '234px';
	arrayLargura[7] = '15px';
	arrayLargura[8] = '';

    var arrayAlinha = new Array();
	arrayAlinha[0] = 'left';
    arrayAlinha[1] = 'left';
	arrayAlinha[2] = 'left';
	arrayAlinha[3] = 'left';
	arrayAlinha[4] = 'left';
	arrayAlinha[5] = 'left';
	arrayAlinha[6] = 'left';
	arrayAlinha[7] = 'left';
	arrayAlinha[8] = 'left';
	
	tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha);
	hideMsgAguardo();
	return false;
}

function controlaBotao( opcao ) {
	switch ( opcao ){
		case 'N': // Novo Cheque
			novoCheque();
		break;
		
		case 'C': // Cancelar
			cancelarInclusao();
		break;
		
		case 'F': // Finalizar
			finalizarCustodia();
		break;
	}
}

function formataCampoCmc7(exitCampo){
	var mask   = '<zzzzzzzz<zzzzzzzzzz>zzzzzzzzzzzz:';
	var indice = 0;
	var valorAtual = cDsdocmc7.val();
	var valorNovo  = '';
	
	if ( valorAtual == '' ){
		return false;
	}
	
	if ( exitCampo && valorAtual.length < 34) {
		showError('error','Valor do CMC-7 inv&aacute;lido.','Alerta - Ayllos','cDsdocmc7.focus();');
	}
	
	//remover os caracteres de formatação
	valorAtual = valorAtual.replace(/[^0-9]/g, "").substr(0,30);
	for ( var x = 0;  x < valorAtual.length; x++ ) {
		//verifica se é um separador da máscara
		if (mask.charAt(indice) != 'z'){
			valorNovo = valorNovo.concat(mask.charAt(indice));
			indice++;
		}
		valorNovo = valorNovo.concat(valorAtual.charAt(x));
		indice++;
	}
	
	// verifica se o valor digitado possui 30 caracteres sem formatação
	if ( valorAtual.length == 30 ){
		// Adiciona o ultimo caracter da máscara
		valorNovo = valorNovo.concat(':');
	}
	
	cDsdocmc7.val(valorNovo);
}

function adicionaChequeCustodiar(){

	var data  = cDtchqbom.val();
	var valor = cVlcheque.val();
	var cmc7  = cDsdocmc7.val();
	var cmc7_sem_format  = cmc7.replace(/[^0-9]/g, "").substr(0,30);
	
	if ( cmc7 == '' ) {
		return false;
	}
	
	// Validar se os campos estão preenchidos
	if ( data == '' ) {
		showError('error','Data boa inv&aacute;lida.','Alerta - Ayllos','cDtchqbom.focus();');
		return false;
	}
	
	if ( valor == '' ) {
		showError('error','Valor inv&aacute;lido.','Alerta - Ayllos','cVlcheque.focus();');
		return false;
	}
	
	if ( cmc7_sem_format.length < 30 ) {
		showError('error','CMC-7 inv&aacute;lido.','Alerta - Ayllos','cDsdocmc7.focus();');
		return false;
	}
	
	var aDataBoa = data.split("/"); 
	var aDtmvtolt = aux_dtmvtolt.split("/"); 
	var dtcompara1 = parseInt(aDataBoa[2].toString() + aDataBoa[1].toString() + aDataBoa[0].toString()); 
	var dtcompara2 = parseInt(aDtmvtolt[2].toString() + aDtmvtolt[1].toString() + aDtmvtolt[0].toString()); 
	
	if ( dtcompara1 <= dtcompara2 ) {
		showError('error','A data boa deve ser maior que a data atual.','Alerta - Ayllos','cDtchqbom.focus();');
		return false;
	}
	
	var idCriar = "id_".concat(cmc7_sem_format);

	//Desmontar o CMC-7 para exibir os campos
	var banco     = cmc7_sem_format.substr(0,3);
	var agencia   = cmc7_sem_format.substr(3,4);
	var cheque    = cmc7_sem_format.substr(11,6);
	var conta     = 0;
	var qtdLinhas = $('#tbCheques tbody tr').length;
	var corLinha  = (qtdLinhas%2 === 0) ? 'corImpar' : 'corPar';
	
	if( banco == 1 ){
	    conta = mascara(normalizaNumero(cmc7_sem_format.substr(21,8)),'####.###-#');
	} else {
		conta = mascara(normalizaNumero(cmc7_sem_format.substr(19,10)),'######.###-#');
	}
	
	if(!document.getElementById(idCriar)) {
		
		// Criar a linha na tabela
		$("#tbCheques > tbody")
			.append($('<tr>') // Linha
			    .attr('id',idCriar)
				.attr('class',corLinha)
				.append($('<td>') // Coluna: Data Boa
				    .attr('style','width: 67px; text-align:left')
					.text(data)
					.append($('<input>')
						.attr('type','hidden')
						.attr('name','aux_dtchqbom')
						.attr('id','aux_dtchqbom')
						.attr('value',data)
					)
				)
				.append($('<td>') // Coluna: Valor
					.attr('style','width: 90px; text-align:right')
					.text(valor)
					.append($('<input>')
						.attr('type','hidden')
						.attr('name','aux_vlcheque')
						.attr('id','aux_vlcheque')
						.attr('value',valor)
					)
				)
				.append($('<td>') // Coluna: Banco
					.attr('style','width: 50px; text-align:right')
					.text(banco)
					.append($('<input>')
						.attr('type','hidden')
						.attr('name','aux_banco')
						.attr('id','aux_banco')
						.attr('value',banco)
					)
				)
				.append($('<td>')  // Coluna: Agência
					.attr('style','width: 50px; text-align:right')
					.text(agencia)
					.append($('<input>')
						.attr('type','hidden')
						.attr('name','aux_agencia')
						.attr('id','aux_agencia')
						.attr('value',agencia)
					)
				)
				.append($('<td>') // Coluna: Número do Cheque
					.attr('style','width: 90px; text-align:right')
					.text(cheque)
					.append($('<input>')
						.attr('type','hidden')
						.attr('name','aux_cheque')
						.attr('id','aux_cheque')
						.attr('value',cheque)
					)
				)
				.append($('<td>') // Coluna: Número da Conta
					.attr('style','width: 90px; text-align:right')
					.text(conta)
					.append($('<input>')
						.attr('type','hidden')
						.attr('name','aux_conta')
						.attr('id','aux_conta')
						.attr('value',conta)
					)
				)
				.append($('<td>') // Coluna: CMC-7
					.attr('style','width: 230px; text-align:right')
					.text(cmc7)
					.append($('<input>')
						.attr('type','hidden')
						.attr('name','aux_dsdocmc7')
						.attr('id','aux_dsdocmc7')
						.attr('value',cmc7_sem_format)
					)
					.append($('<input>')
						.attr('type','hidden')
						.attr('name','aux_cmc7')
						.attr('id','aux_cmc7')
						.attr('value',cmc7)
					)
				)
				.append($('<td>') // Coluna: Botão para REMOVER
					.attr('style','width: 15px; text-align:center')
					.append($('<img>')
						.attr('src', UrlImagens + 'geral/panel-delete_16x16.gif')
						.click(function(event) {
							
							var chequeRemove = document.getElementById($(this).parent().parent().attr('id'));
							chequeRemove.parentNode.removeChild(chequeRemove);

							atualizaMensagemQtdRegistros();
							return false;
						})
					)
				)
				.append($('<td>') // Coluna: Crítica
				    .attr('style','text-align:left')
					.attr('name','aux_dscritic')
					.attr('id','aux_dscritic')
					.text('')
				)
			);
		
		atualizaMensagemQtdRegistros();
		//Utiliza o Botão Novo após incluir um cheque na custódia
		controlaBotao('N');
	}
}

function atualizaMensagemQtdRegistros(){
	var vlTotal = 0;
	var qtTotal = 0;
	
	// Totalizar o valor dos cheques
	$('#tbCheques tbody tr').each(function(){
		// Quantidade de Cheques
		qtTotal++;
		// Somar Todos
		vlTotal += converteMoedaFloat(normalizaNumero($("#aux_vlcheque",this).val()));
	});
	$('#qtdChequeCustodiar').html('Exibindo ' + qtTotal + ' cheques para custodiar. Valor Total R$ ' + number_format(vlTotal,2,',','.'));
}

function novoCheque(){
	//Limpa o valor dos campos e seta foco na data
	cVlcheque.val('');
	cDsdocmc7.val('');
	cDtchqbom.focus();
}

function cancelarInclusao(){
	var tab = document.getElementById('tabConteudo');
	tab.parentNode.removeChild(tab);
	estadoInicial();
}

function finalizarCustodia(){
	if( $('#tbCheques tbody tr').length > 0 ){
		showConfirmacao('Deseja finalizar a custódia de cheques?','Confirma&ccedil;&atilde;o - Ayllos','submitCustodiaCheque();','controlaBotao("N")','sim.gif','nao.gif');
	} else {
		showError('error','Nenhum cheque foi informado para custodiar.','Alerta - Ayllos','controlaBotao("N")');
	}
}

function submitCustodiaCheque(){
	
	showMsgAguardo('Aguarde, finalizando custódia ...');
	
	var nrdconta = normalizaNumero( cNrdconta.val() );
	var dscheque = "";
	var corLinha  = 'corImpar';

	$('#tbCheques tbody tr').each(function(){
		if( dscheque != "" ){
			dscheque += "|";
		}
		
		dscheque += $("#aux_dtchqbom",this).val() + ";" ; // Data Boa
		dscheque += $("#aux_vlcheque",this).val().replace(/\./g,'').replace(',','.') + ";" ; // Valor
		dscheque += $("#aux_dsdocmc7",this).val(); // CMC-7
		
		// Limpar a crítica
		$("#aux_dscritic",this).text('');
		$(this).css('background', '');
		// Adiciona a cor Zebrado na Tabela de Cheques
		$(this).attr('class', corLinha);
		if( corLinha == 'corImpar' ){
			corLinha = 'corPar';
		} else {
			corLinha = 'corImpar';
		}
	});

	if( dscheque == "" ){
		unblockBackground();
		showError('error','Nenhum cheque foi informado para custodiar.','Alerta - Ayllos','controlaBotao("N")');
		return false;
	}
	
	$.ajax({        
        type: 'POST',
        dataType: 'html',
        url: UrlSite + 'telas/custch/manter_rotina.php', 
        data: {
            nrdconta: nrdconta,
			dscheque: dscheque,
            redirect: 'html_ajax'           
            }, 
        error: function(objAjax,responseError,objExcept) {
            hideMsgAguardo();           
            showError('error','Não foi possível concluir a requisição.','Alerta - Ayllos',"unblockBackground()");
        },
        success: function(response) {
			hideMsgAguardo();
			try {
				eval( response );
			} catch(error) {						
				showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','unblockBackground();');
			}
        }
    });
}

function solicitaImpressaoCustodiaEmitida(){
	showConfirmacao('Deseja imprimir a custódia de cheques?','Confirma&ccedil;&atilde;o - Ayllos','geraImpressaoCustodia();','controlaBotao("C")','sim.gif','nao.gif');
}

function geraImpressaoCustodia(){

	var nrdconta = cNrdconta.val();
	var nmprimtl = cNmprimtl.val();
	var dscheque = "";
	
	$('#tbCheques tbody tr').each(function(){
		if( dscheque != "" ){
			dscheque += "|";
		}
		
		dscheque += $("#aux_dtchqbom",this).val() + ";" ; // Data Boa
		dscheque += $("#aux_vlcheque",this).val().replace(/\./g,'').replace(',','.') + ";" ; // Valor Cheque
		dscheque += $("#aux_banco",   this).val() + ";" ; // Banco
		dscheque += $("#aux_agencia", this).val() + ";" ; // Agência
		dscheque += $("#aux_cheque",  this).val() + ";" ; // Número Cheque
		dscheque += $("#aux_conta",   this).val() + ";" ; // Número Conta
		dscheque += $("#aux_cmc7",    this).val();        // CMC-7
	});

	$('#nrdconta','#frmImpressao').remove();
	$('#dscheque','#frmImpressao').remove();

	$('#frmImpressao').append('<input type="hidden" id="nrdconta" name="nrdconta" value="'+nrdconta+'"/>');
	$('#frmImpressao').append('<input type="hidden" id="nmprimtl" name="nmprimtl" value="'+nmprimtl+'"/>');
	$('#frmImpressao').append('<input type="hidden" id="dscheque" name="dscheque" value="'+dscheque+'"/>');
	
	var action = UrlSite + "telas/custch/custodia_pdf.php";
	carregaImpressaoAyllos("frmImpressao",action,'controlaBotao("C");');
}