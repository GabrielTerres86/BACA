/*!
 * FONTE        : parcdc.js                         
 * CRIAÇÃO      : Jean Michel
 * DATA CRIAÇÃO : 06/12/2017
 * OBJETIVO     : Biblioteca de funções da tela PARCDC
 * --------------
 * ALTERAÇÕES   :
 *
 * --------------
 */

var glbCdsegmento = 0;

$(document).ready(function() {

	estadoInicial();

	highlightObjFocus( $('#frmCab') );

	$('fieldset > legend').css({'font-size':'11px','color':'#777','margin-left':'5px','padding':'0px 2px'});
	$('fieldset').css({'clear':'both','border':'1px solid #777','margin':'3px 0px','padding':'10px 3px 5px 3px'});

	return false;

});

function estadoInicial() {

	$('#frmCab').css({'display':'block'});

	$('#divBotoes', '#divTela').html('').css({'display':'block'});

	formataCabecalho();

	return false;

}

function controlaFoco() {
		
	$('#cdcooper','#frmCab').unbind('keypress').bind('keypress', function(e) {
	
		if ( $('#cdcooper','#frmCab').hasClass('campoTelaSemBorda') ) { return false; }
		
		if ( e.keyCode == 9 || e.keyCode == 13 ) {	
			eventTipoOpcao();			
			return false;
		}	
	});
		
	$('#btnOK','#frmCab').unbind('keypress').bind('keypress', function(e) {
		
		if ( $('#cddopcao','#frmCab').hasClass('campoTelaSemBorda') ) { return false; }
		
		if ( e.keyCode == 9 || e.keyCode == 13 ) {	
			eventTipoOpcao();
			return false;
		}	
	});
	
	$('#btnOK','#frmCab').unbind('click').bind('click', function(){
	
		if ( $('#cddopcao','#frmCab').hasClass('campoTelaSemBorda') ) { return false; }		
		eventTipoOpcao();
		return false;			
	});
	
	$('#inintegra_cont','#frmParametros').unbind('keypress').bind('keypress', function(e) {
		
		if ( $('#inintegra_cont','#frmParametros').hasClass('campoTelaSemBorda') ) { return false; }
		
		if ( e.keyCode == 9 || e.keyCode == 13 ) {	
			$('#nrprop_env','#frmParametros').focus();
			return false;
		}	
	});
	
	$('#nrprop_env','#frmParametros').unbind('keypress').bind('keypress', function(e) {
		
		if ( $('#nrprop_env','#frmParametros').hasClass('campoTelaSemBorda') ) { return false; }
		
		if ( e.keyCode == 9 || e.keyCode == 13 ) {	
			$('#intempo_prop_env','#frmParametros').focus();
			return false;
		}	
	});
	
	$('#intempo_prop_env','#frmParametros').unbind('keypress').bind('keypress', function(e) {
		
		if ( $('#intempo_prop_env','#frmParametros').hasClass('campoTelaSemBorda') ) { return false; }
		
		if ( e.keyCode == 9 || e.keyCode == 13 ) {	
			$('#btAlterarIntegracao').focus();
			return false;
		}	
	});
	
	return false;
	
}

function eventTipoOpcao (){
	$('#cdcooper','#frmCab').desabilitaCampo();
	$('#btnOK','#frmCab').desabilitaCampo();
	
	if ($('#cdcooper','#frmCab').val() > 0) {
		// Abre a tela de Parametros
		abreTelaParametrosCDC();
	}else{
		$('#cdcooper','#frmCab').habilitaCampo();
		$('#btnOK','#frmCab').habilitaCampo();
	}
	return false;
}

function formataCabecalho() {

	$('input,select', '#frmCab').removeClass('campoErro');
	$('#divTela').css({'display':'inline'}).fadeTo(0,0.1);
	removeOpacidade('divTela');	

	cTodosCabecalho = $('input[type="text"],select','#frmCab'); 
	cTodosCabecalho.limpaFormulario();

	// cabecalho
	rCdcooper			= $('label[for="cdcooper"]','#frmCab'); 
	
	cCdcooper			= $('#cdcooper','#frmCab'); 
	
	//Rótulos
	rCdcooper.css('width','44px');
	
	//Campos	
	cCdcooper.css({'width':'475px'}).habilitaCampo().focus();
	
	controlaFoco();
	layoutPadrao();

	return false;	

}

function btnVoltar(){
	$('#frmParametros').css('display','none');
	$('#cdcooper','#frmCab').habilitaCampo().focus().val(0);
	$('#btnOK','#frmCab').habilitaCampo();
	$('#btSalvar','#divBotoes').css('display','none');
	$('#btVoltar','#divBotoes').css('display','none');
	$("#btAlterarIntegracao").html("Alterar");
	return false;
}

function abreTelaParametrosCDC() {

	showMsgAguardo('Aguarde, carregando...');
	
	// Executa script de bloqueio através de ajax
	$.ajax({		
		type: "POST",
		dataType: 'html',
		url: "form_parametros.php", 
		data: {		
			cdcooper: $('#cdcooper','#frmCab').val(),
			redirect: "html_ajax"
		}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","blockBackground(parseInt($('#divTela').css('z-index')))");
			$('#cdcooper','#frmCab').habilitaCampo();
			$('#btnOK','#frmCab').habilitaCampo();			
		},
		success : function(response) {
			hideMsgAguardo();
			bloqueiaFundo($('#divRotina'));
			exibeRotina($('#divRotina'));
			$('#divRotina').html(response);
		}		
	});
    return false;
}

// Funcao para acessar opcoes da rotina
function acessaOpcaoAba(id) {
    
	// Esconde as abas
	$('.clsAbas').hide();
		    
	// Atribui cor de destaque para aba da opcao
	for (var i = 0; i < 4; i++) {
		$("#botoesAba" + i).hide();
		if (id == i) { // Atribui estilos para foco da opcao
			$("#linkAba" + id).attr("class","txtBrancoBold");
			$("#imgAbaEsq" + id).attr("src",UrlImagens + "background/mnu_sle.gif");				
			$("#imgAbaDir" + id).attr("src",UrlImagens + "background/mnu_sld.gif");
			$("#imgAbaCen" + id).css("background-color","#969FA9");
      $("#divAba" + id).show();
			$("#botoesAba" + id).show();			
			continue;			
		}
		$("#linkAba" + i).attr("class","txtNormalBold");
		$("#imgAbaEsq" + i).attr("src",UrlImagens + "background/mnu_nle.gif");			
		$("#imgAbaDir" + i).attr("src",UrlImagens + "background/mnu_nld.gif");
		$("#imgAbaCen" + i).css("background-color","#C6C8CA");
	}
	
	if(id == 0){
		desabilitaCamposIntegracao();
	}
	layoutPadrao();
}

function alterarIntegracao(){
	
	if($("#btAlterarIntegracao").html() == "Alterar"){
		$("#inintegra_cont").habilitaCampo();
		$("#nrprop_env").habilitaCampo();
		$("#intempo_prop_env").habilitaCampo();
		$("#btAlterarIntegracao").html("Concluir");
		$("#inintegra_cont").focus();
	}else{
		if($('#hdnCdcooper','#frmParametros').val() == 99){
			showConfirmacao('Os valores ser&atilde;o alterados para todas as cooperativas, deseja proceder com a altera&ccedil;&atilde;o?','Confirma&ccedil;&atilde;o - Ayllos','manterParametros();','bloqueiaFundo(divRotina);','sim.gif','nao.gif');		
		}else{
			manterParametros();
		}
	}
}

function desabilitaCamposIntegracao(){
	$("#inintegra_cont").desabilitaCampo();
	$("#nrprop_env").desabilitaCampo();
	$("#intempo_prop_env").desabilitaCampo();
}

// Formata tabela de Segmentos
function formataTabelaSegmento() {
    
	var metodoTabela = '';
	var divRegistro = $('div.divRegistros', '#divAba1');
	var tabela = $('#tableSegmento', divRegistro);
	var linha = $('#tableSegmento table > tbody > tr', divRegistro);

	$('#tableSegmento').css({ 'margin-top': '5px' });
	divRegistro.css({ 'height': '160px', 'width': '750px', 'padding-bottom': '2px' });

	var ordemInicial = new Array();
	ordemInicial = [[0, 0]];
	var arrayLargura = new Array();
	var arrayAlinha = new Array();
	
	arrayLargura[0] = '75px';
					
	arrayAlinha[0] = 'center';
	arrayAlinha[1] = 'left';
	
	tabela.formataTabela(ordemInicial, arrayLargura, arrayAlinha, metodoTabela);
	
	layoutPadrao();

	return false;
}

// Formata tabela de Segmentos
function formataTabelaSubsegmento() {
    
	var metodoTabela = '';
	var divRegistro = $('div.divRegistros', '#divAba1');
	var tabela = $('#tableSubsegmento', divRegistro);
	var linha = $('#tableSubsegmento table > tbody > tr', divRegistro);

	$('#tableSubsegmento').css({ 'margin-top': '5px' });
	divRegistro.css({ 'height': '160px', 'width': '750px', 'padding-bottom': '2px' });

	var ordemInicial = new Array();
	ordemInicial = [[0, 0]];
	var arrayLargura = new Array();
	var arrayAlinha = new Array();
	
	arrayLargura[0] = '75px';
	arrayLargura[1] = '400px';
	arrayLargura[2] = '120px';
					
	arrayAlinha[0] = 'center';
	arrayAlinha[1] = 'left';
	arrayAlinha[2] = 'right';
	arrayAlinha[3] = 'right';
	
	tabela.formataTabela(ordemInicial, arrayLargura, arrayAlinha, metodoTabela);
	
	layoutPadrao();

	return false;
}

function rotinaSegmento(cddopcao){
	if(cddopcao == "I"){
		manterRotinaSegmento(cddopcao);
	}else{
		$('#tableSegmento > tbody > tr', 'div.divRegistros').each(function() {
				if ($(this).hasClass('corSelecao')) {
					if($(this).val() == "" || $(this).val() == undefined || $(this).val() == null){
						showError('error', 'Selecione um segmento!', 'Alerta - Ayllos', 'bloqueiaFundo(divRotina);');
						return false;
					}else{
						glbCdsegmento = $(this).val();
						if(cddopcao == "A"){
							manterRotinaSegmento(cddopcao,$(this).val());
						}else if(cddopcao == "E"){
							showConfirmacao('Deseja excluir o segmento?','Confirma&ccedil;&atilde;o - Ayllos','salvaDados(0,"E",'+$(this).val()+',0);','bloqueiaFundo(divRotina);','sim.gif','nao.gif');
						}
					}
				}
		});
	}
}

function manterRotinaSegmento(cddopcao,cdsegmento) {
	
	// Executa script de bloqueio através de ajax
	$.ajax({		
		type: "POST",
		dataType: 'html',
		url: "form_cadastro.php", 
		data: {		
			tpcadast: 0,
			cddopcao: cddopcao,
			cdsegmento: cdsegmento,
			redirect: "html_ajax"
		}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","blockBackground(parseInt($('#divTela').css('z-index')))");
		},
		success : function(response) {
			exibeRotina($('#divUsoGenerico'));
			$('#divUsoGenerico').html(response);
			hideMsgAguardo();
			bloqueiaFundo($('#divUsoGenerico'));
		}		
	});
    return false;
}

function rotinaSubsegmento(cddopcao){
	if(cddopcao == "I"){
		manterRotinaSubsegmento(cddopcao);
	}else{
		$('#tableSubsegmento > tbody > tr', 'div.divRegistros').each(function() {
				if ($(this).hasClass('corSelecao')) {
					if($(this).val() == "" || $(this).val() == undefined || $(this).val() == null || $(this).val() == 0){
						showError('error', 'Selecione um subsegmento!', 'Alerta - Ayllos', 'bloqueiaFundo(divRotina);');
						return false;
					}else{						
						if(cddopcao == "A"){
							manterRotinaSubsegmento(cddopcao,$(this).val());
						}else if(cddopcao == "E"){
							showConfirmacao('Deseja excluir o Subsegmento?','Confirma&ccedil;&atilde;o - Ayllos','salvaDados(1,"E",0,' + $(this).val() + ');','bloqueiaFundo(divRotina);','sim.gif','nao.gif');
						}
					}
				}
		});
	}
}

function manterRotinaSubsegmento(cddopcao,cdsubsegmento) {
	
	// Executa script de bloqueio através de ajax
	$.ajax({		
		type: "POST",
		dataType: 'html',
		url: "form_cadastro.php", 
		data: {		
			tpcadast: 1,
			cddopcao: cddopcao,
			cdsegmento: glbCdsegmento,
			cdsubsegmento: cdsubsegmento,
			redirect: "html_ajax"
		}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","blockBackground(parseInt($('#divTela').css('z-index')))");
			$('#cdcooper','#frmCab').habilitaCampo();
			$('#btnOK','#frmCab').habilitaCampo();			
		},
		success : function(response) {
			exibeRotina($('#divUsoGenerico'));
			$('#divUsoGenerico').html(response);
			hideMsgAguardo();
			bloqueiaFundo($('#divUsoGenerico'));
		}		
	});
    return false;
}

function manterParametros() {
	
	showMsgAguardo('Aguarde, salvando...');	
		
	// Executa script de bloqueio através de ajax
	$.ajax({		
		type: "POST",
		dataType: 'html',
		url: "manter_parametros.php", 
		data: {		
			cddopcao: 'I',
			cdcooper: $('#hdnCdcooper','#frmParametros').val(),
			inintegra_cont:$('#inintegra_cont','#frmParametros').val(),
			nrprop_env:$('#nrprop_env','#frmParametros').val(),
			intempo_prop_env:$('#intempo_prop_env','#frmParametros').val(),
			redirect: "html_ajax"
		}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
		success : function(response) {
			hideMsgAguardo();
			showError("inform","Atualiza&ccedil;&atilde;o executada com sucesso!","Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
			$("#inintegra_cont").desabilitaCampo();
			$("#nrprop_env").desabilitaCampo();
			$("#intempo_prop_env").desabilitaCampo();
			$("#btAlterarIntegracao").html("Alterar");
			$("#btVoltarintegracao").focus();
		}		
	});
	return false;
}

function detalheSubsegmento(cdsegmento){
	
	glbCdsegmento = cdsegmento;
	
	$.ajax({		
		type: "POST",
		dataType: 'html',
		url: "tab_subsegmentos.php", 
		data: {		
			cdsegmento: cdsegmento,
			redirect: "html_ajax"
		}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","blockBackground(parseInt($('#divTela').css('z-index')))");
		},
		success : function(response) {
			$('#divSubsegmentos').html(response);
		}		
	});
}

function salvaDados(tpcadast,cddopcao,cdsegmento,cdsubsegmento){
	
	if(cddopcao != "E"){
		cdsegmento = $('#cdsegmento','#frmCadastro').val();
		cdsubsegmento = $('#cdsubsegmento','#frmCadastro').val();
		
		if(tpcadast == 0){
		 
		 if(cdsegmento == 0 || cdsegmento == "" || cdsegmento == undefined || cdsegmento == null){
				showError("error","Informe o c&oacute;digo do segmento.","Alerta - Ayllos","blockBackground(parseInt($('#divUsoGenerico').css('z-index'))); $('#cdsegmento','#frmCadastro').focus();");
				return false;
			}
			if($('#dssegmento','#frmCadastro').val() == 0 || $('#dssegmento','#frmCadastro').val() == "" || $('#dssegmento','#frmCadastro').val() == undefined || $('#dssegmento','#frmCadastro').val() == null){
				showError("error","Informe a descri&ccedil;&atilde;o do segmento.","Alerta - Ayllos","blockBackground(parseInt($('#divUsoGenerico').css('z-index'))); $('#dssegmento','#frmCadastro').focus();");
				return false;
			}	
			
		}else if(tpcadast == 1){
			
			if(cdsegmento == 0 || cdsegmento == "" || cdsegmento == undefined || cdsegmento == null){
				showError("error","Informe o c&oacute;digo do segmento.","Alerta - Ayllos","blockBackground(parseInt($('#divUsoGenerico').css('z-index'))); $('#cdsegmento','#frmCadastro').focus();");
				return false;
			}
			
			if(cdsubsegmento == 0 || cdsubsegmento == "" || cdsubsegmento == undefined || cdsubsegmento == null){
				showError("error","Informe o c&oacute;digo do subsegmento.","Alerta - Ayllos","blockBackground(parseInt($('#divUsoGenerico').css('z-index'))); $('#cdsubsegmento','#frmCadastro').focus();");
				return false;
			}
			
			if($('#dssubsegmento','#frmCadastro').val() == 0 || $('#dssubsegmento','#frmCadastro').val() == "" || $('#dssubsegmento','#frmCadastro').val() == undefined || $('#dssubsegmento','#frmCadastro').val() == null){
				showError("error","Informe a descri&ccedil;&atilde;o do subsegmento.","Alerta - Ayllos","blockBackground(parseInt($('#divUsoGenerico').css('z-index'))); $('#dssubsegmento','#frmCadastro').focus();");
				return false;
			}	
		
		}		
	}		
		
	showMsgAguardo('Aguarde, salvando...');	
			
	// Executa script de bloqueio através de ajax
	$.ajax({		
		type: "POST",
		dataType: 'html',
		url: "manter_segmentos.php", 
		data: {		
			tpcadast: tpcadast,
			cddopcao: cddopcao,
			cdsegmento: cdsegmento,
			dssegmento: $('#dssegmento','#frmCadastro').val(),
			cdsubsegmento: cdsubsegmento,
			dssubsegmento: $('#dssubsegmento','#frmCadastro').val(),
			nrmax_parcela: $('#nrmax_parcela','#frmCadastro').val(),
			vlmax_financ: $('#vlmax_financ','#frmCadastro').val(),
			redirect: "html_ajax"
		}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","blockBackground(parseInt($('#divUsoGenerico').css('z-index')))");
		},
		success : function(response) {
			hideMsgAguardo();
			eval(response);
		}		
	});
	
}