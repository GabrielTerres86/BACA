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
var cTpconta;
var cTpproduto;
var cDsproduto;
var cDsaderido; 
var servicos;

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
	
	$('#tpOpcional','#frmCabCadsoa').focus();
}

function montaCampos(){
	
	cTpobrigatorio = $('#tpObrigatorio','#frmCabCadsoa');
	cTpopcional = $('#tpOpcional','#frmCabCadsoa');
	cTpconta = $('#tpconta','#frmCabCadsoa');
	cDsproduto = $('#dsservico','#frmCadsoa');
	cDsaderido = $('#dsaderido','#frmCadsoa');
	cTpproduto = $('input[name="tpServico"]');
	var btConsulta = $('#btConsulta','#frmCabCadsoa');
	var btGravar = $('#btGravar','#frmCadsoa');
	var btAcima = $('#btAcima','#frmCadsoa');
	var btAbaixo = $('#btAbaixo','#frmCadsoa');
	var btLeft = $('#btLeft','#frmCadsoa');
	var btRigth = $('#btRigth','#frmCadsoa');
	
	var rTpobrigatorio	= $('label[for="tpObrigatorio"]','#frmCabCadsoa');
	var rTpopcional	= $('label[for="tpOpcional"]','#frmCabCadsoa');	
	var rTpconta    = $('label[for="tpconta"]','#frmCabCadsoa');	
	var rDsproduto  = $('label[for="dsservico"]','#frmCadsoa');
	var rDsaderido  = $('label[for="dsaderido"]','#frmCadsoa');
	var rSpanInfo = $('#SpanInfo', '#frmCadsoa');
	var rTpproduto = $('#servico','#frmCabCadsoa');
	
	/*rtpObrigatorio*/		
	rTpobrigatorio.addClass('rotulo-linha').css('width','50px');
	cTpobrigatorio.css('margin-left', '20px');
	cTpobrigatorio.css('margin-top','3px');
	
	/*rtpOpcional*/
	cTpopcional.css('margin-left','30px');
	cTpopcional.css('margin-top','3px');
	rTpopcional.addClass('rotulo-linha').css('width','50px');
	
	/* rtpservico*/
	rTpproduto.addClass('rotulo').css({'width':'120px','text-align':'right'});
	
	/*rtpconta */
	rTpconta.addClass('rotulo').css({'width':'120px','text-align':'right'});
	cTpconta.css('margin-left','20px');
	cTpconta.css('width','165px');
	
	/*dsservico	*/	
	rDsproduto.addClass('rotulo').css('margin-left','60px');
	cDsproduto.addClass('campo').css({'width':'250px','height':'250px','float':'left','margin':'0px 0px 0px 0px','padding-right':'1px'});
	cDsproduto.css('float','left'); 
	
	/*dsaderido	*/
	rDsaderido.addClass('rotulo-linha').css('margin-left','200px');
	cDsaderido.addClass('campo').css({'width':'250px','height':'250px','float':'left','margin':'0px 0px 0px 25px','padding-right':'1px'});
	cDsaderido.css('float', 'left');
	
	/*Botoes*/
	btGravar.css('margin-left', '185px');
	btGravar.css('width', '80px');
	btGravar.css('margin-left', '240px');
	btGravar.css('margin-top', '25px');
	btConsulta.css('width', '60px');
	btAcima.css('margin-left', '65px');
	btAcima.css('width', '20px');
	btAcima.css('margin-top', '20px');
	btAbaixo.css('width', '20px');
	btAbaixo.css('margin-top', '20px');
	btAbaixo.css('margin-left', '30px');	
	btLeft.css('margin-left', '20px');	
	btLeft.css('margin-top', '80px');
	btLeft.css('width', '20px');
	btRigth.css('margin-left', '-34px');
	btRigth.css('margin-top', '150px');
	btRigth.css('width', '20px');
	
	/* Label */
	rSpanInfo.css({'margin-left':'10px','font-style':'italic','font-size':'10px','display':'inline','float':'center','position':'relative','top':'1px'});
	
	btGravar.unbind('click').bind('click', function(e) {
			if (valida_dados()== true){
				operacao = 'GRAVAR';
				manter_rotina(null);
			}
	});
	
	btConsulta.unbind('click').bind('click', function(e) {
			if (valida_dados()== true){
				operacao = 'CONSULTA';
				manter_rotina(null);
			}
	});
	
	cTpproduto.unbind('change').bind('change', function(e) {
			if (cTpconta.val() == ""){
				// Limpar combo box
				cDsaderido.html("");
			}else{
				if (valida_dados()== true){
					operacao = 'CONSULTA';
					manter_rotina(null);
				}
			}
	});
	
	cTpconta.unbind('change').bind('change', function(e) {
			if (valida_dados()== true){
				operacao = 'CONSULTA';
				manter_rotina(null);
			}
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
		$(this).remove();
	  });
	};
	
	// FUNCAO DE SUBIR O SERVICO NA LISTA
	var upServicos = function(){
	  var $op = $('#dsaderido option:selected');

	  if ($op.length) {
		$op.first().prev().before($op);
	  }
	};
	
	 // FUNCAO DE DESCER O SERVICO NA LISTA
	var downServicos = function(){
	  var $op = $('#dsaderido option:selected');

	  if ($op.length) {
		$op.last().next().after($op);
	  }
	};
	
	// ATRIBUI A FUNCAO DE ADICIONAR SERVICO AO CAMPO SELECT E AO BOTAO
	$("#dsservico").dblclick(adicionarServicos);
	$("#btRigth").click(adicionarServicos);

	// ATRIBUI A FUNCAO DE REMOVER SERVICO AO CAMPO SELECT E AO BOTAO
	$("#dsaderido").dblclick(removerServicos);
	$("#btLeft").click(removerServicos);

	// ATRIBUI A FUNCAO DE SUBIR E DESCER O SERVICO NA LISTA
	$("#btAcima").click(upServicos);
	$("#btAbaixo").click(downServicos);


}
function consistencia(servicos){
	
	
}
function valida_dados(){
	if ($('input[name="tpServico"]:checked','#frmCabCadsoa').val() == undefined){
		showError('error','Selecione um tipo de serviço.','Alerta - Ayllos','unblockBackground()');
		return false;
	}
	if (cTpconta.val() == ""){
		showError('error','Selecione um tipo de conta.','Alerta - Ayllos','unblockBackground()');
		return false;
	}
	
	return true;
}

function confirma () {

	var msgConfirma = "Deseja gravar os serviços selecionados  ?";
	showConfirmacao(msgConfirma,'Confirma&ccedil;&atilde;o - Ayllos','manter_rotina(null)','','sim.gif','nao.gif');

}


// Função para chamar a manter_rotina.php
function manter_rotina (objeto) { 	
	hideMsgAguardo();		
	var mensagem = '';
	var tpconta  = cTpconta.val();	
	var tpproduto = $('input[name="tpServico"]:checked','#frmCabCadsoa').val(); 
	
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
		servicos = $.map($('#dsaderido option'), function(e) { return e.value; }).join(';');			
	};
	if (servicos == "") {
		hideMsgAguardo();
		showError('error','Nao existem servicos para serem aderidos.','Alerta - Ayllos','unblockBackground()');
		return false;
	}
	
	$.ajax({		
			type: 'POST',
			dataType: 'html',
			url: UrlSite + 'telas/cadsoa/manter_rotina.php', 		
			data: {
				tpproduto: tpproduto,
				tpconta:   tpconta,
				operacao:  operacao,
				servicos:  servicos,
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
		
        // Percorrer a TAG <inf>
        $(xml).find('disponiveis').each(function() {

            // Obter o codigo e descricao
            var cdproduto = $(this).find('codigo').text();
            var dsproduto = $(this).find('produto').text();

            // Incluir no combo box.
            cDsproduto.append('<option value=' + cdproduto + '> ' + dsproduto + "</option>");

        });
		// Limpar combo box
        cDsaderido.html("");
		// Percorrer a TAG <inf>
        $(xml).find('aderidos').each(function() {

            // Obter o codigo e descricao
            var cdproduto = $(this).find('codigo').text();
            var dsproduto = $(this).find('produto').text();
			var nrexibicao = $(this).find('exibicao').text();

            // Incluir no combo box.
            cDsaderido.append('<option value=' + cdproduto + '> ' + dsproduto + "</option>");

        });
	}else if (operacao == 'GRAVAR') {
		// Inclusao servicos	
		showError('success','Gravacao efetuada com sucesso!','Alerta - Ayllos','unblockBackground()');		
	}else{ // consistencia
		$("#dsaderido").append(objeto.clone());
	}
}
// Mostrar a mensagem de Ajuda na tela
function formataMsgAjuda() {

	var botoesMensagem = $('input','#divMsgAjuda');
	botoesMensagem.css({'display':'none','float':'right','padding-left':'2px','margin-top':'0px'});	

}
