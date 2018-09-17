/*!
 * FONTE        : agenet.js                             Última altração: 31/11/2017
 * CRIAÇÃO      : Jonathan - RKAM
 * DATA CRIAÇÃO : 17/11/2015
 * OBJETIVO     : Biblioteca de funções da tela AGENET
 * --------------
 * ALTERAÇÕES   : 25/04/2016 - Ajuste para atender as solicitações do projeto M 117
                               (Adriano - M117).
                    
 * --------------
 
 29/06/2016 - m117 Inclusao do campo tipo de transacao no filtro (Carlos)

 19/07/2016 - Ajuste para controlar corretamente as div ao escolher uma opção (Adriano).
 
 31/11/2017 - Exibir TEDs Canceladas devido a fraude PRJ335 - Analise de fraude(Odirlei-AMcom)
 
 */

	
$(document).ready(function() {
	
	estadoInicial();	
	
});

// seletores
function estadoInicial() {
	
	$('#divTela').css({'display':'inline'}).fadeTo(0,0.1);
	removeOpacidade('divTela');	

	formataCabecalho();

	removeOpacidade('divTela');
	highlightObjFocus( $('#frmCab') ); 
	
	$('#divBotoes').css({'display':'none'});
	$('#frmCab').css({'display':'block'});
	$('#divTela').css({'width':'700px','padding-bottom':'2px'});
	
	$("#cddopcao","#frmCab").focus();
	
}

function formataCabecalho(){
	
	// rotulo
	$('label[for="cddopcao"]',"#frmCab").addClass("rotulo").css({"width":"45px"}); 
	
	// campo
	$("#cddopcao","#frmCab").css("width","565px").habilitaCampo();
	
	$('input[type="text"],select','#frmCab').limpaFormulario().removeClass('campoErro');
		
	//Define ação para ENTER e TAB no campo Opção
	$("#cddopcao","#frmCab").unbind('keypress').bind('keypress', function(e) {
		if (e.keyCode == 9 || e.keyCode == 13) {
			
			formataFormularioFiltro();
			
			return false;
			
		}
    });	
	
	//Define ação para CLICK no botão de OK
	$("#btnOK","#frmCab").unbind('click').bind('click', function() {
			
		// Se esta desabilitado o campo 
		if ($("#cddopcao","#frmCab").prop("disabled") == true)  {
			return false;
		}
		
		formataFormularioFiltro();
		
		$(this).unbind('click');			
		
		return false;
    });	
	
	layoutPadrao();
	
	return false;	
}

function formataFormularioFiltro(){
	
	// Desabilitar a opção
	$("#cddopcao","#frmCab").desabilitaCampo();
	
	//Limpa formulario
	$('input[type="text"]','#frmFiltro').limpaFormulario().removeClass('campoErro');
	
	// rotulo
	$('label[for="nrdconta"]',"#frmFiltro").addClass("rotulo").css({"width":"120px"}); 
	$('label[for="cdagenci"]',"#frmFiltro").addClass("rotulo-linha").css({"width":"80px"}); 
	$('label[for="insitlau"]',"#frmFiltro").addClass("rotulo-linha").css({"width":"65px"}); 
	$('label[for="cdtiptra"]',"#frmFiltro").addClass("rotulo").css({"width":"120px"}); 
	$('label[for="dtiniper"]',"#frmFiltro").addClass("rotulo-linha").css({"width":"100px"}); 
	$('label[for="dtfimper"]',"#frmFiltro").addClass("rotulo-linha").css({"width":"109px"}); 
	$('label[for="tipsaida"]',"#frmFiltro").addClass("rotulo").css({"width":"120px"}); 
	$('label[for="nmarquiv"]',"#frmFiltro").addClass("rotulo-linha").css({"width":"160px"}); 
	
	// campo
	$("#nrdconta","#frmFiltro").css({'width':'100px','text-align':'right'}).addClass('inteiro').attr('maxlength','10').habilitaCampo();
	$('#cdagenci','#frmFiltro').addClass('pesquisa codigo').css({'width':'100px','text-align':'right'}).attr('maxlength','4').habilitaCampo();
	$('#insitlau','#frmFiltro').css("width","120px").habilitaCampo();
	$("#cdtiptra","#frmFiltro").css({'width':'100px'}).habilitaCampo();
	$('#dtiniper','#frmFiltro').css({'width':'75px','text-align':'right'}).habilitaCampo().addClass('inteiro').attr('maxlength','14').setMask("DATE","","","");
	$('#dtfimper','#frmFiltro').css({'width':'75px','text-align':'right'}).habilitaCampo().addClass('inteiro').attr('maxlength','14').setMask("DATE","","","");
	$('#tipsaida','#frmFiltro').css({'width':'100px'}).habilitaCampo();
	$('#nmarquiv','#frmFiltro').css({'width':'245px','text-align':'left'}).habilitaCampo().addClass('alphanum').attr('maxlength','32');
	
	if ($('#cddopcao', '#frmCab').val() != 'C') {
		$("#cdtiptra","#frmFiltro").val('0');
	}
	if ($("#cddopcao","#frmCab").val() != "T"){
		$('#opt_recarga').attr('disabled','disabled').css('display','none');
	} else {
		$('#opt_recarga').removeAttr('disabled').css('display','block');
	}
	
	$('#dtiniper','#frmFiltro').val(dtiniper);
	$('#dtfimper','#frmFiltro').val(dtfimper);
	
	$("#insitlau option[value='0']", '#frmFiltro').prop('selected', true);

	// Evento onKeyUp no campo "nrdconta"
	$("#nrdconta","#frmFiltro").bind('keyup',function(e) { 		
		// Seta máscara ao campo
		if (!$(this).setMaskOnKeyUp("INTEGER","zzzz.zzz-z","",e)) {
			return false;
		}		
	});
	
	// Evento para o campo nrdconta
	$("#nrdconta","#frmFiltro").unbind('keypress').bind('keypress', function(e) {
		
		$(this).removeClass('campoErro');
		
		if (e.keyCode == 9 || e.keyCode == 13) {
			
			$("#cdagenci","#frmFiltro").focus();
			return false;
		}
    });	
	
	//Evento para o campo cdagenci
	$("#cdagenci","#frmFiltro").unbind('keypress').bind('keypress', function(e) {
		
		$(this).removeClass('campoErro');
		
		if (e.keyCode == 9 || e.keyCode == 13) {
			
		    ($("#cddopcao", "#frmCab").val() != 'C') ? $("#insitlau", "#frmFiltro").focus() : $("#dtiniper", "#frmFiltro").focus();
			return false;
		}
    });
	
	//Evento para o campo dssitlau
	$("#insitlau","#frmFiltro").unbind('keypress').bind('keypress', function(e) {
		
		$(this).removeClass('campoErro');
		
		if (e.keyCode == 9 || e.keyCode == 13) {
			
			$("#cdtiptra","#frmFiltro").focus();
			return false;
		}
    });

	//Evento para o campo cdtiptra
	$("#cdtiptra","#frmFiltro").unbind('keypress').bind('keypress', function(e) {
		
		$(this).removeClass('campoErro');
		
		if (e.keyCode == 9 || e.keyCode == 13) {
			
			$("#dtiniper","#frmFiltro").focus();
			return false;
		}
    });
	
	//Evento para o campo dtiniper
	$("#dtiniper","#frmFiltro").unbind('keypress').bind('keypress', function(e) {
		
		$(this).removeClass('campoErro');
		
		if (e.keyCode == 9 || e.keyCode == 13) {
			
			$("#dtfimper","#frmFiltro").focus();
			return false;
		}
    });
	
	//Evento para o campo dtiniper
	$("#dtfimper","#frmFiltro").unbind('keypress').bind('keypress', function(e) {
		
		$(this).removeClass('campoErro');
		
		if (e.keyCode == 9 || e.keyCode == 13) {
			
		    if ($('#cddopcao', '#frmCab').val() == 'T' || $('#cddopcao', '#frmCab').val() == 'C') {
				$('#btConcluir','#divBotoes').click();
			}else{
				$("#tipsaida","#frmFiltro").focus();
			}
			
			return false;
		}
    });	
	
	//Evento para o campo tipsaida
	$("#tipsaida","#frmFiltro").unbind('keypress').bind('keypress', function(e) {
		
		$(this).removeClass('campoErro');
		
		if (e.keyCode == 9 || e.keyCode == 13) {
			
			$("#nmarquiv","#frmFiltro").focus();
			
			return false;
		}
    });	
	
	//Evento para o campo nmarquiv
	$("#nmarquiv","#frmFiltro").unbind('keypress').bind('keypress', function(e) {
		
		$(this).removeClass('campoErro');
		
		if (e.keyCode == 9 || e.keyCode == 13) {
			
			$('#btConcluir','#divBotoes').click();
			
			return false;
		}
    });	
	
	if($("#cddopcao","#frmCab").val() == 'I'){
		
		$("#divArquivo","#frmFiltro").css('display','block');
		
	} else if ($("#cddopcao", "#frmCab").val() == 'T') {

	    $("#divArquivo", "#frmFiltro").css('display', 'none');

	} else {

	    $("#divArquivo", "#frmFiltro").css('display', 'none');

	    $("#insitlau", "#frmFiltro").desabilitaCampo();
	    $("#insitlau option[value='1']", '#frmFiltro').prop('selected', true);
		
		// opcao C - cancelamento
		$("#cdtiptra option[value='4']", '#frmFiltro').prop('selected', true);
		$("#cdtiptra","#frmFiltro").desabilitaCampo();		
	}
	
	$('#frmFiltro').css({'display':'block'});
	$('#divBotoes').css({'display':'block'});
	$('#btConcluir', '#divBotoes').css({ 'display': 'inline' });
	$('#btCancelar', '#divBotoes').css({ 'display': 'none' });
	$('#btVoltar','#divBotoes').css({'display':'inline'});
	highlightObjFocus( $('#frmFiltro') ); 
	$("#nrdconta","#frmFiltro").focus();
	
	layoutPadrao();
	
	return false;
	
}

function formataTabelaAgendamentos() {
	
	var divRegistro = $('div.divRegistros', '#divTabela');
	var tabela      = $('table', divRegistro );
	var linha       = $('table > tbody > tr', divRegistro );

    divRegistro.css({'height':'250px'});
	$('#divRegistrosRodape','#divTabela').formataRodapePesquisa();	
	
	var ordemInicial = new Array();

	var arrayLargura = new Array();
    arrayLargura[0] = '50px';
	arrayLargura[1] = '90px';
	arrayLargura[2] = '75px';
	arrayLargura[3] = '130px';
	arrayLargura[4] = '90px';
		
    var arrayAlinha = new Array();
	arrayAlinha[0] = 'center';
    arrayAlinha[1] = 'right';
	arrayAlinha[2] = 'right';
	arrayAlinha[3] = 'left';
	arrayAlinha[4] = 'right';
	arrayAlinha[5] = 'left';
	
	tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha);
	
	$('table > tbody > tr', divRegistro).each( function(i) {
		
		if ( $(this).hasClass( 'corSelecao' ) ) {
		
			selecionaAgendamentos($(this));
			
		}	
		
	});	
	
	//seleciona o lancamento que é clicado
	$('table > tbody > tr', divRegistro).click( function() {
		
		selecionaAgendamentos($(this));
	});
	
	return false;
	
}

function controlaVoltar(){
	
	switch($("#cddopcao","#frmCab").val()) {
		
		case "T": // Mostra agendamentos na tela
		
			if($('#divTabela').css('display') == 'block'){
				$('#divTabela').css('display','none');
				formataFormularioFiltro();							
			}else{
				$('#frmFiltro').css('display','none');
				estadoInicial();
			}
		break;
		
		case "I": // Gera arquivo/impressao dos agendamentos
			
			$('#frmFiltro').css('display','none');
			estadoInicial();
			
		break;

	    case "C": // Cancela agendamentos 

	        if ($('#divTabela').css('display') == 'block') {
	            $('#divTabela').css('display', 'none');
	            formataFormularioFiltro();
	        } else {
	            $('#frmFiltro').css('display', 'none');
	            estadoInicial();
	        }
		break;
		
	}
	
}

function buscaAgendamentos(nriniseq,nrregist){
	
	//Desabilita todos os campos do form
	$('input,select','#frmFiltro').desabilitaCampo();
	
	var nrdconta = normalizaNumero($('#nrdconta','#frmFiltro').val()); 
	var cdagenci = $("#cdagenci","#frmFiltro").val();
	var insitlau = $("#insitlau","#frmFiltro").val();
	var cdtiptra = $("#cdtiptra","#frmFiltro").val();
	var dtiniper = $("#dtiniper","#frmFiltro").val();
	var dtfimper = $("#dtfimper","#frmFiltro").val();
	var tipsaida = $("#tipsaida","#frmFiltro").val();
	var nmarquiv = $("#nmarquiv","#frmFiltro").val();
	var cddopcao = $("#cddopcao","#frmCab").val();
		
	$('input,select','#frmFiltro').removeClass('campoErro');
	
	showMsgAguardo( "Aguarde, buscando agendamentos..." );
	
    //Requisição para processar a opção que foi selecionada
	$.ajax({
        type: "POST",
        url: UrlSite + "telas/agenet/busca_agendamentos.php",
        data: {
			nrdconta: nrdconta,
			cdagenci: cdagenci,
			insitlau: insitlau,
			cdtiptra: cdtiptra,
			dtiniper: dtiniper,
			dtfimper: dtfimper,		
			cddopcao: cddopcao,
			nriniseq: nriniseq,
			tipsaida: tipsaida,
			nrregist: nrregist,
			nmarquiv: nmarquiv,
            redirect: "script_ajax"
        },
        error: function(objAjax,responseError,objExcept) {
            hideMsgAguardo();
            showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","$('#nrdconta','#frmFiltro').focus();");
        },
        success: function(response) {
			
			hideMsgAguardo();
			if ( response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1 ) {
				try {
			
					$('#divTabela').html(response);
					return false;
				} catch(error) {						
			
					showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message, "Alerta - Ayllos", "$('#nrdconta','#frmFiltro').focus();");
				}
			} else {
				try {
			
					eval( response );						
				} catch(error) {
			
					showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message, "Alerta - Ayllos", "$('#nrdconta','#frmFiltro').focus();");
				}
			}
		}
			
    });
    return false;
}

function cancelarAgendamento(dtmvtolt, nrdocmto, nrdconta) {

    //Desabilita todos os campos do form
    $('input,select', '#frmFiltro').desabilitaCampo();
        
    $('input,select', '#frmFiltro').removeClass('campoErro');

    showMsgAguardo("Aguarde, cancelando agendamento...");

    var cddopcao = $("#cddopcao", "#frmCab").val();

    //Requisição para processar a opção que foi selecionada
    $.ajax({
        type: "POST",
        url: UrlSite + "telas/agenet/cancelar_agendamento.php",
        data: {
            nrdconta: normalizaNumero(nrdconta),
            dtmvtolt: dtmvtolt,
            nrdocmto: nrdocmto,
            cddopcao: cddopcao,
            redirect: "script_ajax"
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Ayllos", "$('#btVoltar','#divBotoes').focus();");
        },
        success: function (response) {

            hideMsgAguardo();
            try {
                eval(response);
            } catch (error) {
                showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', "$('#btVoltar','#divBotoes').focus();");
			}
		}
			
    });

    return false;

}

function controlaPesquisa(valor){

	switch(valor){
	
		case 1:
			controlaPesquisaAssociado();
		break;
		
		case 2:
		    controlaPesquisaAgencia();
		break;

	}
	
}

function controlaPesquisaAssociado(){

	// Se esta desabilitado o campo 
	if ($("#nrdconta","#frmFiltro").prop("disabled") == true)  {
		return;
	}
	
	mostraPesquisaAssociado('nrdconta', 'frmFiltro');
	
	return false;
	
}


function controlaPesquisaAgencia(){

	// Se esta desabilitado o campo 
	if ($("#cdagenci","#frmFiltro").prop("disabled") == true)  {
		return;
	}
	
	/* Remove foco de erro */
	$('input','#frmFiltro').removeClass('campoErro'); 
	
	// Variável local para guardar o elemento anterior
	var campoAnterior = '';
	var bo, procedure, titulo, qtReg, filtros, colunas, cdhistor, titulo_coluna, cdgrupos, dshistor;	
	
	// Nome do Formulário que estamos trabalhando
	var nomeFormulario = 'frmFiltro';
	
	//Remove a classe de Erro do form
	$('input','#'+nomeFormulario).removeClass('campoErro');
			
	bo			= 'b1wgen0059.p';
	procedure	= 'busca_pac';
	titulo      = 'Agência PA';
	qtReg		= '20';
	filtrosPesq	= 'Cód. PA;cdagenci;30px;S;0;;codigo;|Agência PA;nmresage;200px;S;;;descricao;';
	colunas 	= 'Código;cdagepac;20%;right|Descrição;dsagepac;80%;left';
	mostraPesquisa(bo,procedure,titulo,qtReg,filtrosPesq,colunas);
		
	return false;	

}


function selecionaAgendamentos(tr){

    var dstiptra = $('#dstiptra', tr ).val();
    var insitlau = $('#insitlau', tr ).val();

    $('#btCancelar', '#divBotoes').css({ 'display': 'none' }).unbind('click');
	
	if(dstiptra.indexOf('PAGAMENTO-DARF') > -1 || dstiptra.indexOf('PAGAMENTO-DAS') > -1){

		var tpcaptura = $('#tpcaptura', tr ).val();
		$('#dstpcaptura','#fsetAgendamentoDarfDas').val( $('#dstpcaptura', tr ).val() );
	    $('#dsnome_fone','#fsetAgendamentoDarfDas').val( $('#dsnome_fone', tr ).val() );
		$('#nrcpfcgc','#fsetAgendamentoDarfDas').val( $('#nrcpfcgc', tr ).val() );
		$('#dslinha_digitavel','#fsetAgendamentoDarfDas').val( $('#dslinha_digitavel', tr ).val() );
		$('#dtapuracao','#fsetAgendamentoDarfDas').val( $('#dtapuracao', tr ).val() );
		$('#dtvencto','#fsetAgendamentoDarfDas').val( $('#dtvencto', tr ).val() );
		$('#cdtributo','#fsetAgendamentoDarfDas').val( $('#cdtributo', tr ).val() );
		$('#nrrefere','#fsetAgendamentoDarfDas').val( $('#nrrefere', tr ).val() );
		$('#vlreceita_bruta','#fsetAgendamentoDarfDas').val( $('#vlreceita_bruta', tr ).val() );
		$('#vlpercentual','#fsetAgendamentoDarfDas').val( $('#vlpercentual', tr ).val() );
		$('#vlprincipal','#fsetAgendamentoDarfDas').val( $('#vlprincipal', tr ).val() );
		$('#vlmulta','#fsetAgendamentoDarfDas').val( $('#vlmulta', tr ).val() );
		$('#vljuros','#fsetAgendamentoDarfDas').val( $('#vljuros', tr ).val() );
		$('#vllanaut','#fsetAgendamentoDarfDas').val( $('#vllanaut', tr ).val() );
		$('#dttransa','#fsetAgendamentoDarfDas').val( $('#dttransa', tr ).val() );
		$('#hrtransa','#fsetAgendamentoDarfDas').val( $('#hrtransa', tr ).val() );
		
		//label
		$('label[for="dstpcaptura"]',"#fsetAgendamentoDarfDas").addClass("rotulo").css({"width":"160px"});
		
		$('label[for="dsnome_fone"]',"#fsetAgendamentoDarfDas").addClass("rotulo").css({"width":"160px"});
		
		$('label[for="nrcpfcgc"]',"#fsetAgendamentoDarfDas").addClass("rotulo").css({"width":"160px"});
		
		$('label[for="dslinha_digitavel"]',"#fsetAgendamentoDarfDas").addClass("rotulo").css({"width":"160px"});
		
		$('label[for="dtapuracao"]',"#fsetAgendamentoDarfDas").addClass("rotulo").css({"width":"160px"});
		$('label[for="dtvencto"]',"#fsetAgendamentoDarfDas").addClass("rotulo-linha").css({"width":"160px"});
		
		$('label[for="cdtributo"]',"#fsetAgendamentoDarfDas").addClass("rotulo").css({"width":"160px"});
		$('label[for="nrrefere"]',"#fsetAgendamentoDarfDas").addClass("rotulo-linha").css({"width":"160px"});
		
		$('label[for="vlreceita_bruta"]',"#fsetAgendamentoDarfDas").addClass("rotulo").css({"width":"160px"});
		$('label[for="vlpercentual"]',"#fsetAgendamentoDarfDas").addClass("rotulo-linha").css({"width":"160px"});
		
		$('label[for="vlprincipal"]',"#fsetAgendamentoDarfDas").addClass("rotulo").css({"width":"160px"});
		
		$('label[for="vlmulta"]',"#fsetAgendamentoDarfDas").addClass("rotulo").css({"width":"160px"});
		$('label[for="vljuros"]',"#fsetAgendamentoDarfDas").addClass("rotulo-linha").css({"width":"160px"});
		
		$('label[for="vllanaut"]',"#fsetAgendamentoDarfDas").addClass("rotulo").css({"width":"160px"});
		
		$('label[for="dttransa"]',"#fsetAgendamentoDarfDas").addClass("rotulo").css({"width":"160px"});
		$('label[for="hrtransa"]',"#fsetAgendamentoDarfDas").addClass("rotulo-linha").css({"width":"160px"});
		
		// campo
		$("#dstpcaptura","#fsetAgendamentoDarfDas").css('width','470px').desabilitaCampo();
		$("#dsnome_fone","#fsetAgendamentoDarfDas").css('width','470px').desabilitaCampo();
		$("#nrcpfcgc","#fsetAgendamentoDarfDas").css('width','200px').desabilitaCampo();
		$("#dslinha_digitavel","#fsetAgendamentoDarfDas").css('width','470px').desabilitaCampo();
		$("#dtapuracao","#fsetAgendamentoDarfDas").css('width','100px').desabilitaCampo();
		$("#dtvencto","#fsetAgendamentoDarfDas").css('width','100px').desabilitaCampo();
		$("#cdtributo","#fsetAgendamentoDarfDas").css({"width":"100px","text-align":"right"}).desabilitaCampo();
		$("#nrrefere","#fsetAgendamentoDarfDas").css({"width":"100px","text-align":"right"}).desabilitaCampo();
		$("#vlreceita_bruta","#fsetAgendamentoDarfDas").css({"width":"100px","text-align":"right"}).desabilitaCampo();
		$("#vlpercentual","#fsetAgendamentoDarfDas").css({"width":"100px","text-align":"right"}).desabilitaCampo();
		$("#vlprincipal","#fsetAgendamentoDarfDas").css({"width":"100px","text-align":"right"}).desabilitaCampo();
		$("#vlmulta","#fsetAgendamentoDarfDas").css({"width":"100px","text-align":"right"}).desabilitaCampo();
		$("#vljuros","#fsetAgendamentoDarfDas").css({"width":"100px","text-align":"right"}).desabilitaCampo();
		$("#vllanaut","#fsetAgendamentoDarfDas").css({"width":"100px","text-align":"right"}).desabilitaCampo();
		$("#dttransa","#fsetAgendamentoDarfDas").css('width','100px').desabilitaCampo();
		$("#hrtransa","#fsetAgendamentoDarfDas").css('width','100px').desabilitaCampo();
		
		$('#divDarfDasLinDig').css('display','none');
		$('#divDarfDasManual').css('display','none');

		if (tpcaptura == 1) //Com código de barras
		{
			$('#divDarfDasLinDig').css('display','block');
		}
		else //Sem código de barras
		{
		    $('#divDarfDasManual').css('display','block');
		}
		
		$('#fsetAgendamentoConta').css('display','none'); 
		$('#fsetAgendamentoLinhaDig').css('display','none');
		$('#fsetAgendamentoContaDestino').css('display','none');
		$('#fsetAgendamentoDarfDas').css('display','block');
		$('#fsetAgendamentoRecarga').css('display','none');
		
	}else if(dstiptra.indexOf('PAGAMENTO') > -1){

		$('#dstransa','#fsetAgendamentoLinhaDig').val( $('#dstransa', tr ).val() );
		$('#dttransa','#fsetAgendamentoLinhaDig').val( $('#dttransa', tr ).val() );
		$('#hrtransa','#fsetAgendamentoLinhaDig').val( $('#hrtransa', tr ).val() );
		$('#dstitdda','#fsetAgendamentoLinhaDig').val( $('#dstitdda', tr ).val() );
		
		//label
		$('label[for="dstransa"]',"#fsetAgendamentoLinhaDig").addClass("rotulo").css({"width":"115px"}); 
		$('label[for="dttransa"]',"#fsetAgendamentoLinhaDig").addClass("rotulo").css({"width":"115px"}); 
		$('label[for="hrtransa"]',"#fsetAgendamentoLinhaDig").addClass("rotulo-linha").css({"width":"100px"}); 
			
		// campo
		$("#dstransa","#fsetAgendamentoLinhaDig").css('width','500px').desabilitaCampo();
		$("#dttransa","#fsetAgendamentoLinhaDig").css('width','100px').desabilitaCampo();
		$("#hrtransa","#fsetAgendamentoLinhaDig").css('width','100px').desabilitaCampo();
		$("#dstitdda","#fsetAgendamentoLinhaDig").css('width','190px').desabilitaCampo();
		
		$('#fsetAgendamentoConta').css('display','none'); 
		$('#fsetAgendamentoLinhaDig').css('display','block');
		$('#fsetAgendamentoContaDestino').css('display','none');
		$('#fsetAgendamentoDarfDas').css('display','none');
		$('#fsetAgendamentoRecarga').css('display','none');
		
	}else if((dstiptra.indexOf('TRANSFERENCIA') > -1) || dstiptra.indexOf('TED') > -1) {
	
		$('#dstransa','#fsetAgendamentoContaDestino').val( $('#dstransa', tr ).val() );
		$('#dttransa','#fsetAgendamentoContaDestino').val( $('#dttransa', tr ).val() );
		$('#hrtransa','#fsetAgendamentoContaDestino').val( $('#hrtransa', tr ).val() );
		$('#dstitdda','#fsetAgendamentoContaDestino').val( $('#dstitdda', tr ).val() );
        $('#dsobserv','#fsetAgendamentoContaDestino').val( $('#dsobserv', tr ).val() );
		
		//label
		$('label[for="dstransa"]',"#fsetAgendamentoContaDestino").addClass("rotulo").css({"width":"115px"}); 
		$('label[for="dttransa"]',"#fsetAgendamentoContaDestino").addClass("rotulo").css({"width":"115px"}); 
		$('label[for="hrtransa"]',"#fsetAgendamentoContaDestino").addClass("rotulo-linha").css({"width":"100px"}); 
			
		// campo
		$("#dstransa","#fsetAgendamentoContaDestino").css('width','500px').desabilitaCampo();
		$("#dttransa","#fsetAgendamentoContaDestino").css('width','100px').desabilitaCampo();
		$("#hrtransa","#fsetAgendamentoContaDestino").css('width','100px').desabilitaCampo();
		$("#dstitdda","#fsetAgendamentoContaDestino").css('width','190px').desabilitaCampo();
        
        if ($('#dsobserv','#fsetAgendamentoContaDestino').val() == "" ) {            
            $("#dsobserv","#fsetAgendamentoContaDestino").css('display','none');
            $('label[for="dsobserv"]',"#fsetAgendamentoContaDestino").css('display','none');
        }else{
            $("#dsobserv","#fsetAgendamentoContaDestino").css('display','block'); 
            $('label[for="dsobserv"]',"#fsetAgendamentoContaDestino").css('display','block');
            $('label[for="dsobserv"]',"#fsetAgendamentoContaDestino").addClass("rotulo").css({"width":"115px"}); 
            $("#dsobserv","#fsetAgendamentoContaDestino").css('width','500px').desabilitaCampo();            
        }                    
				
		$('#fsetAgendamentoConta').css('display','none'); 
		$('#fsetAgendamentoLinhaDig').css('display','none');
		$('#fsetAgendamentoContaDestino').css('display', 'block');
		$('#fsetAgendamentoDarfDas').css('display','none');
		$('#fsetAgendamentoRecarga').css('display','none');

		if ($('#cddopcao', '#frmCab').val() == 'C') {

		    //Somente é permitido o cancelamento de TED com a situação de Pendente
		    if (dstiptra.indexOf('TED') > -1 && insitlau == 1) {

		        //Define ação para CLICK no botão Cancelar Agend.
		        $("#btCancelar", "#divBotoes").unbind('click').bind('click', function () {

		            showConfirmacao('Deseja confirmar opera&ccedil;&atilde;o?', 
					'Confirma&ccedil;&atilde;o - Ayllos', 
					'cancelarAgendamento("' + $('#dtmvtolt', tr).val() + '", "' + $('#nrdocmto', tr).val() + '", "' + $('#nrdconta', tr).val() + '");', '$(\'#btVoltar\',\'#divBotoes\').focus();', 'sim.gif', 'nao.gif');
		            return false;

		        });

		        $('#btCancelar', '#divBotoes').css({ 'display': 'inline' });

		    }
		}
		
	}else if(dstiptra.indexOf('RECARGA') > -1){

		$('#dstransa','#fsetAgendamentoRecarga').val( $('#dstransa', tr ).val() );
		$('#dttransa','#fsetAgendamentoRecarga').val( $('#dttransa', tr ).val() );
		$('#hrtransa','#fsetAgendamentoRecarga').val( $('#hrtransa', tr ).val() );
		$('#dstitdda','#fsetAgendamentoRecarga').val( $('#dstitdda', tr ).val() );
		
		//label
		$('label[for="dstransa"]',"#fsetAgendamentoRecarga").addClass("rotulo").css({"width":"115px"}); 
		$('label[for="dttransa"]',"#fsetAgendamentoRecarga").addClass("rotulo").css({"width":"115px"}); 
		$('label[for="hrtransa"]',"#fsetAgendamentoRecarga").addClass("rotulo-linha").css({"width":"100px"}); 
			
		// campo
		$("#dstransa","#fsetAgendamentoRecarga").css('width','500px').desabilitaCampo();
		$("#dttransa","#fsetAgendamentoRecarga").css('width','100px').desabilitaCampo();
		$("#hrtransa","#fsetAgendamentoRecarga").css('width','100px').desabilitaCampo();
		$("#dstitdda","#fsetAgendamentoRecarga").css('width','190px').desabilitaCampo();
		
		$('#fsetAgendamentoConta').css('display','none'); 
		$('#fsetAgendamentoLinhaDig').css('display','none');
		$('#fsetAgendamentoContaDestino').css('display','none');
		$('#fsetAgendamentoDarfDas').css('display','none');
		$('#fsetAgendamentoRecarga').css('display','block');
		
	}else{
		
		$('#dttransa','#fsetAgendamentoConta').val( $('#dttransa', tr ).val() );
		$('#hrtransa','#fsetAgendamentoConta').val( $('#hrtransa', tr ).val() );
		
		//label
		$('label[for="dstransa"]',"#fsetAgendamentoConta").addClass("rotulo").css({"width":"115px"}); 
		$('label[for="dttransa"]',"#fsetAgendamentoConta").addClass("rotulo-linha").css({"width":"100px"}); 
		$('label[for="hrtransa"]',"#fsetAgendamentoConta").addClass("rotulo-linha").css({"width":"100px"}); 
	
		// campo
		$("#dstransa","#fsetAgendamentoConta").css('width','100px').desabilitaCampo();
		$("#dttransa","#fsetAgendamentoConta").css('width','100px').desabilitaCampo();
		$("#hrtransa","#fsetAgendamentoConta").css('width','100px').desabilitaCampo();
				
		$('#fsetAgendamentoConta').css('display','block'); 
		$('#fsetAgendamentoLinhaDig').css('display','none');
		$('#fsetAgendamentoContaDestino').css('display','none');
		$('#fsetAgendamentoDarfDas').css('display','none');
		$('#fsetAgendamentoRecarga').css('display','none');
		
	}
	
	layoutPadrao();
	
	return false;		
	
}

function Gera_Impressao(nmarqpdf,callback) {	
	
	hideMsgAguardo();	
	
	var action = UrlSite + 'telas/agenet/imprimir_pdf.php';
	
	$('#nmarqpdf','#frmCab').remove();	
	$('#sidlogin','#frmCab').remove();	
	
	$('#frmCab').append('<input type="hidden" id="nmarqpdf" name="nmarqpdf" value="' + nmarqpdf + '" />');	
	$('#frmCab').append('<input type="hidden" id="sidlogin" name="sidlogin" value="' + $('#sidlogin','#frmMenu').val() + '" />');	
	
	carregaImpressaoAyllos("frmCab",action,callback);
	
}
