/***********************************************************************
 Fonte: cadsoa.js                                                  
 Autor: Tiago Castro - RKAM
 Data : Jul/2015                Última Alteração:  
                                                                   
 Objetivo  : Cadastro de servicos ofertados na tela Atenda
                                                                   	 
 Alterações: 
						  
						  
************************************************************************/

var first = true;
var cTpobrigatorio;
var cTpopcional;
var cInpessoa_1;
var cInpessoa_2;
var cInpessoa_3;
var cTpconta;
var cVlmincapi;
var cTpproduto;
var cDsproduto;
var cDsaderido; 
var servicos;
var cVlrminimo;
var cVlrmaximo;
var glb_tipos_de_conta;
var glb_aderidos;
var glb_disponiveis;

$(document).ready(function() {	
	estadoInicial();
	montaCampos();
});


function estadoInicial(){
	$("#btAlterar","#divMsgAjuda").hide();
	
	$("#btVoltar","#divMsgAjuda").hide();
	
	$("#divMsgAjuda").css('display','block');
	
	$('#frmCabCadsoa').fadeTo(0,0.1);
	$('#frmCadsoa').fadeTo(0,0.1);
	
	removeOpacidade('frmCabCadsoa');
	removeOpacidade('frmCadsoa');
	
	$('fieldset > legend').css({'font-size':'11px','color':'#777','margin-left':'5px','padding':'0px 2px'});
	$('fieldset').css({'clear':'both','border':'1px solid #777','margin':'3px 0px','padding':'10px 3px 5px 3px'});
	
	
	formataMsgAjuda('');
	$("#divMsgAjuda").css('display','block'); 
	
	//$("input:radio").removeAttr("checked");
	
	$('#inpessoa_1','#frmCabCadsoa').focus();
}

function montaCampos(){
	
	cTpobrigatorio = $('#tpObrigatorio','#frmCadsoa');
	cTpopcional = $('#tpOpcional','#frmCadsoa');
	cInpessoa = $('input[name="inpessoa"]');
	cInpessoa_1 = $('#inpessoa_1','#frmCabCadsoa');
	cInpessoa_2 = $('#inpessoa_2','#frmCabCadsoa');
	cInpessoa_3 = $('#inpessoa_3','#frmCabCadsoa');
	cTpconta = $('#tpconta','#frmCabCadsoa');
	cVlmincapi = $('#vlmincapi','#frmCadsoa');
	cDsproduto = $('#dsservico','#frmCadsoa');
	cDsaderido = $('#dsaderido','#frmCadsoa');
	cTpproduto = $('input[name="tpServico"]');
	cVlrminimo = $('#vlrminimo','#frmCadsoa');
	cVlrmaximo = $('#vlrmaximo','#frmCadsoa');
	var btConsulta = $('#btConsulta','#frmCabCadsoa');
	var btGravar = $('#btGravar','#frmCadsoa');
	var btnExcluir = $('#btnExcluir','#frmCadsoa');
	var btAcima = $('#btAcima','#frmCadsoa');
	var btAbaixo = $('#btAbaixo','#frmCadsoa');
	var btLeft = $('#btLeft','#frmCadsoa');
	var btRigth = $('#btRigth','#frmCadsoa');
	
	var rTpobrigatorio	= $('label[for="tpObrigatorio"]','#frmCadsoa');
	var rTpopcional	= $('label[for="tpOpcional"]','#frmCadsoa');
	var rInpessoa_1	= $('label[for="inpessoa_1"]','#frmCadsoa');
	var rInpessoa_2	= $('label[for="inpessoa_2"]','#frmCadsoa');
	var rInpessoa_3	= $('label[for="inpessoa_3"]','#frmCadsoa');
	var rTpconta    = $('label[for="tpconta"]','#frmCabCadsoa');	
	var rVlmincapi = $('label[for="vlmincapi"]','#frmCadsoa');
	var rTpservico = $('label[for="tpServico"]','#frmCadsoa');
	var rDsproduto  = $('label[for="dsservico"]','#frmCadsoa');
	var rDsaderido  = $('label[for="dsaderido"]','#frmCadsoa');
	var rSpanInfo = $('#SpanInfo', '#frmCadsoa');
	var rTpproduto = $('#servico','#frmCabCadsoa');
	var rVlrminimo = $('label[for="vlrminimo"]','#frmCadsoa');
	var rVlrmaximo = $('label[for="vlrmaximo"]','#frmCadsoa');
	
	//highlightObjFocus($('#frmCadsoa'));
	
	/*rInpessoa_1*/		
	rInpessoa_1.addClass('rotulo-linha').css('width','50px');
	cInpessoa_1.css('margin-left', '20px');
	cInpessoa_1.css('margin-top','3px');
	
	/*rInpessoa_2*/
	rInpessoa_2.addClass('rotulo-linha').css('width','50px');
	cInpessoa_2.css('margin-left','30px');
	cInpessoa_2.css('margin-top','3px');
	
	/*rInpessoa_3*/
	rInpessoa_3.addClass('rotulo-linha').css('width','50px');
	cInpessoa_3.css('margin-left','30px');
	cInpessoa_3.css('margin-top','3px');
	
	/* rTpproduto*/
	rTpproduto.addClass('rotulo').css({'width':'120px','text-align':'right'});
	
	/*rtpconta */
	rTpconta.addClass('rotulo').css({'width':'120px','text-align':'right'});
	cTpconta.css('margin-left','20px');
	cTpconta.css('width','165px');
	
	/*rVlmincapi*/
	rVlmincapi.addClass('rotulo').css({'width':'165px','text-align':'right'});
	cVlmincapi.css({'width':'165px','text-align': 'right'});
	cVlmincapi.setMask('DECIMAL','zzz.zzz.zzz.zz9,99','.','');
	cVlmincapi.addClass('campo');
	
	/*rTpservico*/
	rTpservico.addClass('rotulo').css({'width':'165px','text-align':'right'});
	
	/*rtpObrigatorio*/		
	rTpobrigatorio.addClass('rotulo-linha').css('width','50px');
	cTpobrigatorio.css('margin-left', '20px');
	cTpobrigatorio.css('margin-top','3px');
	
	/*rtpOpcional*/
	cTpopcional.css('margin-left','30px');
	cTpopcional.css('margin-top','3px');
	rTpopcional.addClass('rotulo-linha').css('width','50px');
	
	/*dsservico	*/	
	rDsproduto.addClass('rotulo').css('margin-left','60px');
	cDsproduto.addClass('campo').css({'width':'250px','height':'250px','float':'left','margin':'0px 0px 0px 0px','padding-right':'1px'});
	cDsproduto.css('float','left'); 
	
	/*dsaderido	*/
	rDsaderido.addClass('rotulo-linha').css('margin-left','200px');
	cDsaderido.addClass('campo').css({'width':'250px','height':'250px','float':'left','margin':'0px 0px 0px 25px','padding-right':'1px'});
	cDsaderido.css('float', 'left');
	
	/*rVlrminimo*/
	rVlrminimo.addClass('rotulo').css({'width':'430px','text-align':'right','margin-top':'20px'});
	cVlrminimo.css({'width':'105px','margin-top':'20px','text-align':'right'});
	cVlrminimo.setMask('DECIMAL','zzz.zzz.zzz.zz9,99','.','');
	cVlrminimo.addClass('campo');
	cVlrminimo.desabilitaCampo();
	
	/*rVlrmaximo*/
	rVlrmaximo.addClass('rotulo').css({'width':'430px','text-align':'right'});
	cVlrmaximo.css({'width':'105px','text-align':'right'});
	cVlrmaximo.setMask('DECIMAL','zzz.zzz.zzz.zz9,99','.','');
	cVlrmaximo.addClass('campo');
	cVlrmaximo.desabilitaCampo();
	
	/*Botoes*/
	btConsulta.css('width', '60px');
	btGravar.css({'width': '80px','margin-left': '190px','margin-top': '25px'});
	btnExcluir.css({'width': '80px','margin-left': '10px','margin-top': '25px'});
	btAcima.css({'margin-left': '385px','width': '20px','margin-top': '3px'});
	btAbaixo.css({'margin-left': '30px','width': '20px','margin-top': '3px'});
	btLeft.css({'margin-left': '20px','margin-top': '80px','width': '20px'});
	btRigth.css({'margin-left': '-34px','margin-top': '150px','width': '20px'});
	
	/* Label */
	rSpanInfo.css({'margin-left':'10px','font-style':'italic','font-size':'10px','display':'inline','float':'center','position':'relative','top':'1px'});
	
	layoutPadrao();
		
	$('input[type=radio][name=inpessoa]').change(function () {
		verificaInpessoa(this.value);
	});
	
	btGravar.unbind('click').bind('click', function(e) {
		operacao = 'GRAVAR';
			if (valida_dados()== true){
				manter_rotina(null);
			}
	});
	
	btnExcluir.unbind('click').bind('click', function(e) {
			if (valida_dados()== true){
			confirmaExcluir();
			}
	});
	
	btConsulta.unbind('click').bind('click', function(e) {
			consultaTipoConta();
	});
	
	cInpessoa.unbind('change').bind('change', function(e) {
			
			cTpconta.val('');
			cVlmincapi.val('');
			cVlrminimo.desabilitaCampo().val('');
			cVlrmaximo.desabilitaCampo().val('');
			cDsaderido.html("");
			var inpessoa = $('input[type=radio][name=inpessoa]:checked').val();
			buscar_tipos_de_conta(inpessoa);

	});
	
	cTpproduto.unbind('change').bind('change', function(e) {
			consultaTipoConta();
	});
	
	cTpconta.unbind('change').bind('change', function(e) {
			consultaTipoConta();
	});
	
	btRigth.unbind('click').bind('click'),function(e){
		$("#dsservico").find("option:selected").each(function(){
		var intCentros = $("#dsaderido").find("option[value=" + $(this).val() + "]").size();
		if (intCentros < 1) {
		  $("#dsaderido").append($(this).clone());
		  
		}
	  });
	};
	
	// FUNCAO DE ADICIONAR SERVICO
	var adicionarServicos = function(){
	  $("#dsservico").find("option:selected").each(function(){
		var intCentros = $("#dsaderido").find("option[value=" + $(this).val() + "]").size();
		if (intCentros < 1) {
		  servicos = $(this).val();
		  operacao = 'CONSISTENCIA';
		  manter_rotina($(this));
		}
	  });
	};

	// FUNCAO DE REMOVER SERVICO
	var removerServicos = function(){
	  $("#dsaderido").find("option:selected").each(function(){
		$("#dsservico").find("option[value=" + $(this).val() + "]").css("color","black");
		
		for (var i = 0; i < glb_aderidos.length; i++)
			if (glb_aderidos[i].cdproduto == $(this).val())
				glb_aderidos.splice(i, 1);
		
		$(this).remove();
	  });
	};
	
	// FUNCAO DE SUBIR O SERVICO NA LISTA
	var upServicos = function(){
	  var $op = $('#dsaderido option:selected');

		var aderido;
		
		for (var i = 0; i < glb_aderidos.length; i++) {
			if (glb_aderidos[i].cdproduto == $op.val() && i != 0) {
				aderido = glb_aderidos[i - 1];
				glb_aderidos[i - 1] = glb_aderidos[i];
				glb_aderidos[i] = aderido;
			}
		}
		
	  if ($op.length) {
		$op.first().prev().before($op);
	  }
	};
	
	 // FUNCAO DE DESCER O SERVICO NA LISTA
	var downServicos = function(){
	  var $op = $('#dsaderido option:selected');

		var aderido;
		
		for (var i = 0; i < glb_aderidos.length; i++) {
			if (glb_aderidos[i].cdproduto == $op.val() && i != (glb_aderidos.length - 1)) {
				aderido = glb_aderidos[i + 1];
				glb_aderidos[i + 1] = glb_aderidos[i];
				glb_aderidos[i] = aderido;
			}
		}
		
	  if ($op.length) {
		$op.last().next().after($op);
	  }
	};
	
	// FUNCAO PARA POPULAR VALOR MINIMO E MAXIMO DOS PRODUTOS ADERIDOS
	var vlMinMax = function() {
		var fxvalor;
		for (var i = 0; i < glb_disponiveis.length; i++) {
			if (glb_disponiveis[i].cdproduto == $(this).val()) {
				fxvalor = Number(glb_disponiveis[i].fxvalor);
			}
		}
		
		$("#dsaderido").find("option:selected").each(function() {
			for (var i = 0; i < glb_aderidos.length; i++) {
				if (glb_aderidos[i].cdproduto == $(this).val()) {
					if (fxvalor == 1) {
						cVlrminimo.val(glb_aderidos[i].vlminimo);
						cVlrmaximo.val(glb_aderidos[i].vlmaximo);
						cVlrminimo.habilitaCampo().prop('tabindex','0');
						cVlrmaximo.habilitaCampo().prop('tabindex','0');
					} else {
						cVlrminimo.val('');
						cVlrmaximo.val('');
						cVlrminimo.desabilitaCampo();
						cVlrmaximo.desabilitaCampo();
					}
				}
			}
		});
	};
	
	cVlrminimo.unbind('blur').bind('blur', function(e) {
		for (var i = 0; i < glb_aderidos.length; i++) {
			if (glb_aderidos[i].cdproduto == $("#dsaderido").val()) {
				glb_aderidos[i].vlminimo = cVlrminimo.val();
			}
		}
	});
	
	cVlrmaximo.unbind('blur').bind('blur', function(e) {
		for (var i = 0; i < glb_aderidos.length; i++) {
			if (glb_aderidos[i].cdproduto == $("#dsaderido").val()) {
				glb_aderidos[i].vlmaximo = cVlrmaximo.val();
			}
		}
	});
	
	// ATRIBUI A FUNCAO DE ADICIONAR SERVICO AO CAMPO SELECT E AO BOTAO
	$("#dsservico").dblclick(adicionarServicos);
	$("#btRigth").click(adicionarServicos);

	// ATRIBUI A FUNCAO DE REMOVER SERVICO AO CAMPO SELECT E AO BOTAO
	$("#dsaderido").dblclick(removerServicos);
	$("#dsaderido").click(vlMinMax);
	$("#btLeft").click(removerServicos);

	// ATRIBUI A FUNCAO DE SUBIR E DESCER O SERVICO NA LISTA
	$("#btAcima").click(upServicos);
	$("#btAbaixo").click(downServicos);

}

function consultaTipoConta() {
	operacao = 'CONSULTA';
	if (valida_dados()== true){
		manter_rotina(null);
}
}
	
function valida_dados(){
	
	if (operacao == 'GRAVAR' && cVlmincapi.val() == '') {
		showError('error','Informe o Valor M&iacute;nimo de Capital.','Alerta - Ayllos','unblockBackground()');
		return false;
}
	
	if ($('input[name="inpessoa"]:checked','#frmCabCadsoa').val() == undefined){
		showError('error','Selecione um tipo de pessoa.','Alerta - Ayllos','unblockBackground()');
		return false;
	}
	
	if (cTpconta.val() == ""){
		showError('error','Selecione um tipo de conta.','Alerta - Ayllos','unblockBackground()');
		return false;
	}
	
	return true;
}
/*
function confirma () {

	var msgConfirma = "Deseja gravar os serviços selecionados  ?";
	showConfirmacao(msgConfirma,'Confirma&ccedil;&atilde;o - Ayllos','manter_rotina(null)','','sim.gif','nao.gif');

}
*/
// Função para chamar a manter_rotina.php
function manter_rotina (objeto) { 	
	hideMsgAguardo();		
	
	if (operacao == 'CONSULTA' && $('input[name="tpServico"]:checked','#frmCadsoa').val() == undefined)
		$("#tpObrigatorio").prop("checked", true);
	
	var mensagem = '';
	var tpconta  = cTpconta.val();	
	var tpproduto = $('input[name="tpServico"]:checked','#frmCadsoa').val();
	var inpessoa = $('input[name="inpessoa"]:checked','#frmCabCadsoa').val();
	var vlmincapi = isNaN(parseFloat($('#vlmincapi', '#frmCadsoa').val().replace(/\./g, "").replace(/\,/g, "."))) ? 0 : parseFloat($('#vlmincapi', '#frmCadsoa').val().replace(/\./g, "").replace(/\,/g, "."));
	
	switch (operacao) {	
	
		case 'CONSULTA': mensagem = 'Aguarde, consultando servicos...'; break;                                                              
		case 'GRAVAR': mensagem = 'Aguarde, gravando servicos...'; break;     
		case 'CONSISTENCIA': mensagem = 'Aguarde, validando servicos...'; break;     
		default: return false; break;		
	}
	
	showMsgAguardo( mensagem );	
	
	if (operacao == 'GRAVAR'){
		
		// pegar todos servicos aderidos		
		servicos = "";
		
		for (var i = 0; i < glb_aderidos.length; i++) {
			if (servicos != "")
				servicos += ';';
			servicos += parseFloat(glb_aderidos[i].cdproduto.replace(/\./g, "").replace(/\,/g, ".")) + '|' +
						parseFloat(glb_aderidos[i].vlminimo.replace(/\./g, "").replace(/\,/g, ".")) + '|' +
						parseFloat(glb_aderidos[i].vlmaximo.replace(/\./g, "").replace(/\,/g, ".")) + '|' +
						(i + 1);
	}
	};
	
	$.ajax({		
			type: 'POST',
			dataType: 'html',
			url: UrlSite + 'telas/cadsoa/manter_rotina.php', 		
			data: {
				tpproduto: tpproduto,
				tpconta:   tpconta,
			    inpessoa:  inpessoa,
				operacao:  operacao,
				servicos:  servicos,
			    vlmincapi: vlmincapi,
				redirect: 'script_ajax'
			}, 
			error: function(objAjax,responseError,objExcept) {
				hideMsgAguardo();
				showError('error','Nao foi possivel concluir a operacao.','Alerta - Ayllos','unblockBackground()');
			},
			success: function(response) {
				try {
					hideMsgAguardo();
					tratarResposta(operacao, response, objeto);
					return false;
				} catch(error) {
					hideMsgAguardo();
					showError('error','Nao foi possivel concluir a operacao.','Alerta - Ayllos','unblockBackground()');
				}
			}
		});				
}

function tratarResposta(operacao, xml, objeto){
	 var dscritic = $(xml).find('dscritic').text();

    // Se retornou erro 
    if (dscritic != "") {
        showError('error',dscritic,'Alerta - Ayllos','unblockBackground()');		
        return false;
    }
	
	// Consulta servicos
    if (operacao == 'CONSULTA') {

        // Limpar combo box
        cDsproduto.html("");
		populaServicos (xml);
		
	}else if (operacao == 'GRAVAR') {
		// Inclusao servicos	
		showError('inform','Gravacao efetuada com sucesso!','Alerta - Ayllos','carregaTipoContaCoop();unblockBackground()');		
	}else{ // consistencia
		var produto = {
			cdproduto: objeto.val(),
			inpessoa: $('input[type=radio][name=inpessoa]:checked').val(),
			vlminimo: '0,00',
			vlmaximo: '0,00'
		}
		glb_aderidos.push(produto);
		$("#dsaderido").append(objeto.clone());
	}
}

function carregaTipoContaCoop() {

	var inpessoa = $('input[type=radio][name=inpessoa]:checked').val();
	
	buscar_tipos_de_conta(inpessoa);
	
	if (cTpconta.val() == ""){
		// Limpar combo box
		cDsaderido.html("");
	}else{
		consultaTipoConta();
	}
}

function populaServicos (xml) {
	
	var campo_inpessoa = $('input[type=radio][name=inpessoa]:checked').val();
	glb_disponiveis = [];
	
	$('#vlmincapi','#frmCadsoa').val($(xml).find('vlmincapi').text());
	
        // Percorrer a TAG <inf>
        $(xml).find('disponiveis').each(function() {

            // Obter o codigo e descricao
            var cdproduto = $(this).find('codigo').text();
            var dsproduto = $(this).find('produto').text();
		var fxvalor   = $(this).find('fxvalor').text();

		var produto = {
			cdproduto: cdproduto,
			dsproduto: dsproduto,
			fxvalor: fxvalor
		}
		
		glb_disponiveis.push(produto);

            // Incluir no combo box.
            cDsproduto.append('<option value=' + cdproduto + '> ' + dsproduto + "</option>");
        });
	
		glb_aderidos = [];
		
		// Limpar combo box
        cDsaderido.html("");
		cVlrminimo.desabilitaCampo().val("");
		cVlrmaximo.desabilitaCampo().val("");
	
		// Percorrer a TAG <inf>
        $(xml).find('aderidos').each(function() {

            var cdproduto = $(this).find('codigo').text();
            var dsproduto = $(this).find('produto').text();
		var inpessoa = $(this).find('inpessoa').text();
		var vlminimo = $(this).find('vlminimo').text();
		var vlmaximo = $(this).find('vlmaximo').text();
		
		var produto = {
			cdproduto: cdproduto,
			dsproduto: dsproduto,
			inpessoa: inpessoa,
			vlminimo: vlminimo,
			vlmaximo: vlmaximo
		}
		
		glb_aderidos.push(produto);

		if (inpessoa == campo_inpessoa) {
            // Incluir no combo box.
            cDsaderido.append('<option value=' + cdproduto + '> ' + dsproduto + "</option>");
		}
	});
}

function confirmaExcluir() {
	
	showConfirmacao('Confirma a exclus&atilde;o do Tipo de Conta?', 'Confirma&ccedil;&atilde;o - Ayllos', 'excluirTipodeConta();', '$(\'#btVoltar\',\'#divBotoesConsulta\').focus();', 'sim.gif', 'nao.gif');
}

function excluirTipodeConta() {
	
	var inpessoa = $('input[type=radio][name=inpessoa]:checked').val();
	var tpconta = $("#tpconta","#frmCabCadsoa").val().trim();
	
	// Mostra mensagem de aguardo	
	showMsgAguardo("Aguarde...");
	
	// Executa script de confirmação através de ajax
	$.ajax({
		type: 'POST',
		dataType: 'html',
		url: UrlSite + 'telas/cadsoa/excluir_tipo_de_conta.php',
		data: {
			inpessoa: inpessoa,
			tpconta: tpconta,
			redirect: 'html_ajax'
		},
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();

			showError('error','Não foi possível concluir a requisição.','Alerta - Ayllos',"unblockBackground()");
		},
		success: function(response) {
			hideMsgAguardo();
			eval(response);
			return false;
		}
	});
	
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
				
				var tpconta = cTpconta.val();
				
				var xml = response;
				cTpconta.html('<option value=""> Selecione o tipo</option>');
				glb_tipos_de_conta = [];
				
				$(xml).find('tipo_conta').each(function() {
					
					var cdtipo_conta = $(this).find('cdtipo_conta').text();
					var dstipo_conta = $(this).find('dstipo_conta').text();
					
					var tipo_de_conta = {
						cdtipo_conta: cdtipo_conta
					}
					
					glb_tipos_de_conta.push(tipo_de_conta);
					
					cTpconta.append('<option value="' + cdtipo_conta + '"> ' + cdtipo_conta + ' - ' + dstipo_conta + "</option>");
					
				});
				cTpconta.val(tpconta);

				return false;
			} catch(error) {
				hideMsgAguardo();
				showError('error','Nao foi possivel concluir a operacao.','Alerta - Ayllos','unblockBackground()');
			}
		}
        });
}

function verificaInpessoa(inpessoa) {
	
	cDsaderido.html("");
	
	if (glb_aderidos.length > 0) {
		for (var i = 0;i < glb_aderidos.length; i++) {
			if (glb_aderidos[i].inpessoa == inpessoa) {
				// Incluir no combo box.
				cDsaderido.append('<option value=' + glb_aderidos[i].cdproduto + '> ' + glb_aderidos[i].dsproduto + "</option>");
			}
		}
	}
}

// Mostrar a mensagem de Ajuda na tela
function formataMsgAjuda() {

	var botoesMensagem = $('input','#divMsgAjuda');
	botoesMensagem.css({'display':'none','float':'right','padding-left':'2px','margin-top':'0px'});	

}
