/***********************************************************************
 Fonte: sitcta.js                                                  
 Autor: Tiago Castro - RKAM
 Data : Jul/2015                Última Alteração:  
                                                                   
 Objetivo  : Cadastro de servicos ofertados na tela Atenda
                                                                   	 
 Alterações: 
						  
						  
************************************************************************/

var first = true;
var cSituacao;
var cIdimpede_credito;
var cIdimpede_talionario;
var cIdcontratacao_produto;
var cRdTodos;
var cRdBoletos;
var cRdAceTodos;
var cRdAceEspecial;
var cRdSomSistema;



var cDslancmto;
var cDspermtdo; 
var glb_tipos_de_conta;
var glb_aderidos;
var glb_disponiveis;

$(document).ready(function() {	
	estadoInicial();
});


function estadoInicial(){
	
	$('#divTela').html('');
	formataCabecalho();
	
}

function formataCabecalho() {
	
	var rSituacao = $('label[for="situacao"]','#frmCabSitcta');
	rSituacao.addClass('rotulo').css({'width':'160px','text-align':'right'});
	
	cSituacao = $('#situacao','#frmCabSitcta');
	cSituacao.css({'margin-left':'3px','width':'265px'}).habilitaCampo();
	
	var btOk = $('#btOk','#frmCabSitcta');
	btOk.css('width', '20px').habilitaCampo();
	
	//Define ação para ENTER e TAB no campo Opção
	cSituacao.unbind('keypress').bind('keypress', function(e) {
		if (e.keyCode == 9 || e.keyCode == 13) {
			buscaSituacao();
			return false;
		}
    });
	
	btOk.unbind('click').bind('click', function(e) {
		buscaSituacao();
	});
	
	cSituacao.focus();
}

function buscaSituacao() {

    var situacao = cSituacao.val();
	
	cSituacao.desabilitaCampo();
	
    showMsgAguardo("Aguarde ...");

    //Requisição para montar o form correspondente a opção escolhida
    $.ajax({
        type: "POST",
        url: UrlSite + "telas/sitcta/form_sitcta.php",
        data: {
			situacao: situacao,
            redirect: "script_ajax"
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Ayllos", "estadoInicial();");
        },
        success: function (response) {

            hideMsgAguardo();
            if (response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1) {
                try {

                    $('#divTela').html(response);
					formataSituacao();
                    return false;
                } catch (error) {

                    showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message, "Alerta - Ayllos", "estadoInicial();");
                }
            } else {
                try {

                    eval(response);
                } catch (error) {

                    showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message, "Alerta - Ayllos", "estadoInicial();");
                }
            }
        }

    });

    return false;

}

function formataSituacao(){
	
	cIdimpede_credito = $('#idimpede_credito','#frmSitcta');
	cIdimpede_talionario = $('#idimpede_talionario','#frmSitcta');
	cIdcontratacao_produto = $('#idcontratacao_produto','#frmSitcta');
	cRdTodos   = $('#rdTodos','#frmSitcta');
	cRdBoletos = $('#rdBoletos','#frmSitcta');
	cRdAceTodos = $('#rdAceTodos','#frmSitcta');
	cRdAceEspecial = $('#rdAceEspecial','#frmSitcta');
	cRdSomSistema = $('#rdSomSistema','#frmSitcta');
	cVlmincapi = $('#vlmincapi','#frmSitcta');
	cDslancmto = $('#dslancmto','#frmSitcta');
	cDspermtdo = $('#dspermtdo','#frmSitcta');
	var btVoltar = $('#btVoltar','#frmSitcta');
	var btGravar = $('#btGravar','#frmSitcta');
	var btLeft = $('#btLeft','#frmSitcta');
	var btRigth = $('#btRigth','#frmSitcta');
	
	
	var rTpobrigatorio	= $('label[for="tpObrigatorio"]','#frmSitcta');
	var rTpopcional	= $('label[for="tpOpcional"]','#frmSitcta');
	var rTpservico = $('label[for="tpServico"]','#frmSitcta');
	var rDspermtdo  = $('label[for="dspermtdo"]','#frmSitcta');
	var rSpanInfo = $('#SpanInfo', '#frmSitcta');
	var rTpproduto = $('#servico','#frmCabSitcta');
	
	/* cIdimpede_credito*/
	cIdimpede_credito.addClass('rotulo');
	
	/* cIdimpede_talionario*/
	cIdimpede_talionario.addClass('rotulo');
	
	/* cIdcontratacao_produto*/
	cIdcontratacao_produto.addClass('rotulo');
	
	if (cIdcontratacao_produto.is(':checked') != 1) {
		/* cRdTodos*/
		cRdTodos.addClass('rotulo').desabilitaCampo();
		
		/* cRdBoletos*/
		cRdBoletos.addClass('rotulo').desabilitaCampo();
	}
	
	/*dslancmto	*/	
	cDslancmto.addClass('campo').css({'width':'310px','height':'250px','float':'left','margin':'0px 0px 0px 0px','padding-right':'1px'});
	cDslancmto.css('float','left'); 
	
	/*dspermtdo	*/
	rDspermtdo.addClass('rotulo-linha').css('margin-left','460px');
	cDspermtdo.addClass('campo').css({'width':'310px','height':'250px','float':'left','margin':'0px 0px 0px 25px','padding-right':'1px'});
	cDspermtdo.css('float', 'left');
	
	/*Botoes*/
	btVoltar.css({'width': '80px','margin-left': '250px','margin-bottom': '10px'});
	btGravar.css({'width': '80px','margin-left': '10px','margin-bottom': '10px'});
	btLeft.css({'margin-left': '20px','margin-top': '80px','width': '20px'});
	btRigth.css({'margin-left': '-34px','margin-top': '150px','width': '20px'});
	
	/* Label */
	rSpanInfo.css({'margin-left':'10px','font-style':'italic','font-size':'10px','display':'inline','float':'center','position':'relative','top':'1px'});
		
	btGravar.unbind('click').bind('click', function(e) {
		alterar_situacao();
	});
	
	btVoltar.unbind('click').bind('click', function(e) {
		estadoInicial();
		return false;
	});
	
	cIdcontratacao_produto.unbind('change').bind('change', function(e) {
		
		var idcontratacao_produto = cIdcontratacao_produto.is(':checked') ? 1 : 0;
		
		if (idcontratacao_produto == 0) {
			cRdTodos.addClass('rotulo').desabilitaCampo().removeAttr("checked");
			cRdBoletos.addClass('rotulo').desabilitaCampo().removeAttr("checked");
		} else {
			cRdTodos.addClass('rotulo').habilitaCampo();
			cRdBoletos.addClass('rotulo').habilitaCampo();
		}
	});
	
	// FUNCAO DE ADICIONAR SERVICO
	var adicionarServicos = function(){
		$("#dslancmto").find("option:selected").each(function(){
			var intCentros = $("#dspermtdo").find("option[value=" + $(this).val() + "]").size();
			if (intCentros < 1) {
				$("#dspermtdo").append($(this).clone());
			}
		});
	};

	// FUNCAO DE REMOVER SERVICO
	var removerServicos = function(){
	  $("#dspermtdo").find("option:selected").each(function(){
		$("#dslancmto").find("option[value=" + $(this).val() + "]").css("color","black");
		
		$(this).remove();
	  });
	};
	
	// ATRIBUI A FUNCAO DE ADICIONAR SERVICO AO CAMPO SELECT E AO BOTAO
	$("#dslancmto").dblclick(adicionarServicos);
	$("#btRigth").click(adicionarServicos);

	// ATRIBUI A FUNCAO DE REMOVER SERVICO AO CAMPO SELECT E AO BOTAO
	$("#dspermtdo").dblclick(removerServicos);
	$("#btLeft").click(removerServicos);
	
	layoutPadrao();
}

function confirma () {

	var msgConfirma = "Deseja gravar os serviços selecionados  ?";
	showConfirmacao(msgConfirma,'Confirma&ccedil;&atilde;o - Ayllos','alterar_situacao()','','sim.gif','nao.gif');

}

// Função para chamar a alterar_situacao.php
function alterar_situacao () { 	
	hideMsgAguardo();		
	
	if ($("#idcontratacao_produto","#frmSitcta").is(':checked') && $('input[name="idctr_produto"]:checked','#frmSitcta').val() == undefined) {
		showError('error','Escolha uma opção de impedimento para contratação de produtos e serviços.','Alerta - Ayllos','unblockBackground()');
		return false;
	}
	
	var cdsituacao				= cSituacao.val();
	var inimpede_credito		= $("#idimpede_credito","#frmSitcta").is(':checked') ? 1 : 0;
	var inimpede_talionario		= $("#idimpede_talionario","#frmSitcta").is(':checked') ? 1 : 0;
	var incontratacao_produto	= $("#idcontratacao_produto","#frmSitcta").is(':checked') ? $('input[name="idctr_produto"]:checked','#frmSitcta').val() : 0;
	var tpacesso 				= $('input[name="rdAcesso"]:checked','#frmSitcta').val();
	
	showMsgAguardo('Aguarde, alterando situa&ccedil;&atilde;o de conta.');	
	
	// pegar todos lancamentos aderidos		
	var lancamentos = $.map($('#dspermtdo option'), function(e) { return e.value; }).join(';');
	
	$.ajax({
		type: 'POST',
		dataType: 'html',
		url: UrlSite + 'telas/sitcta/alterar_situacao_de_conta.php',
		data: {
			cdsituacao: 			cdsituacao,
			inimpede_credito:   	inimpede_credito,
			inimpede_talionario: 	inimpede_talionario,
			incontratacao_produto:	incontratacao_produto,
			tpacesso:				tpacesso,
			lancamentos:			lancamentos,
			redirect:				'script_ajax'
		}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError('error','Nao foi possivel concluir a operacao.','Alerta - Ayllos','unblockBackground()');
		},
		success: function(response) {
			try {
				hideMsgAguardo();
				eval(response);
				return false;
			} catch(error) {
				hideMsgAguardo();
				showError('error','Nao foi possivel concluir a operacao.','Alerta - Ayllos','unblockBackground()');
			}
		}
	});
}

// Função para chamar a buscar_tipos_de_pessoas.php
function buscar_tipos_de_pessoas (inpessoa) {
	
	$.ajax({
		type: 'POST',
		dataType: 'html',
		url: UrlSite + 'telas/sitcta/buscar_tipos_de_conta.php',
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
				
				var tpconta = cSituacao.val();
				
				
				var xml = response;
				cSituacao.html('<option value=""> Selecione o tipo</option>');
				glb_tipos_de_conta = [];
				
				$(xml).find('tipo_conta').each(function() {
					
					var cdtipo_conta = $(this).find('cdtipo_conta').text();
					var dstipo_conta = $(this).find('dstipo_conta').text();
					var vlminimo_capital = $(this).find('vlminimo_capital').text();
					
					var tipo_de_conta = {
						cdtipo_conta: cdtipo_conta,
						vlminimo_capital: vlminimo_capital
					}
					
					glb_tipos_de_conta.push(tipo_de_conta);
					
					
				});
				
				return false;
			} catch(error) {
				hideMsgAguardo();
				showError('error','Nao foi possivel concluir a operacao.','Alerta - Ayllos','unblockBackground()');
			}
		}
	});
}
