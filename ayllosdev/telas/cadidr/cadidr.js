/*!
 * FONTE        : cadidr.js
 * CRIA��O      : Lucas Reinert
 * DATA CRIA��O : 03/02/2016
 * OBJETIVO     : Biblioteca de fun��es da tela CADIDR
 * --------------
 * ALTERA��ES   : 
 * --------------
 */

// Vari�veis globais para alguns seletores �teis
var divTabela, divRotina, divRegistro, form;

var abaAtual = 0;

$(document).ready(function() {			
	
	// Inicializando os seletores principais
	form      = $('#frmCadidr');
	divTabela = $('#divTabela');
	divRotina = $('#divTela');				
	
	$('fieldset > legend').css({'font-size': '12px', 'color': '#777', 'margin-left': '5px', 'padding': '0px 2px'});
    $('fieldset').css({'clear': 'both', 'border': '1px solid #777', 'margin': '3px 0px', 'padding': '10px 10px 5px'});	

	estadoInicial();
    
    $(document).keyup(function(e){
        if (e.keyCode == 38 || e.keyCode == 40) { // 38:Seta para cima --- 40:Seta para baixo
            selecionaLinha('');
            return false;
        }
    });

});


function controlaLayout() {
	var divAbaAtual = $('#divAba'+abaAtual);

	form = $('#frmCadidr', divAbaAtual);
	divTabela = $('#divTabela', divAbaAtual);

	formataFormulario();
	formataTabela();	
	layoutPadrao();		
}

function formataTabela() {

	divRegistro   = $('div.divRegistros', divTabela );	
	
	var divDescIndica = $('div.divDescIndica', divTabela );	
	var tabela        = $('table', divRegistro );

	divRegistro.css({'height':'170px','border-bottom':'1px dotted #777','padding-bottom':'2px'});	
	
	$('tr.sublinhado > td',divRegistro).css({'text-decoration':'underline'});	
	
	var ordemInicial = new Array();

	var arrayLargura = new Array();
	arrayLargura[0] = '50px';
	arrayLargura[1] = '320px';
	arrayLargura[2] = '50px';

	var arrayAlinha = new Array();
	arrayAlinha[0] = 'right';
	arrayAlinha[1] = 'left';
	arrayAlinha[2] = 'left';
	arrayAlinha[3] = 'left';
	
	tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha, '' );
	
	// Seleciona primeiro indicador
	selecionaLinha('');
	
	$('table > tbody > tr', divRegistro).click( function() {
		selecionaLinha('');
	});	
	
	divTabela.css({'display':'block'});	
	
	return false;
}

function formataFormulario() {

	if (abaAtual == 0) {
		// $('input',form).desabilitaCampo();
		$('#idindica',form).css({'width': '40px'});
		$('#nmindica',form).css({'width': '380px'});
		$('#tpindica',form).css({'width': '150px'});	
		$('#flgativo',form).css({'width':'50px'});	
		$('#dsindica',form).css({'width':'380px', 'height':'80px'});

		$('#nmindica',form).unbind('keydown').bind('keydown', function(e) {
			if ( e.keyCode == 13 )  {
				$('#tpindica',form).focus();
				return false;
			}
		});
		
		$('#tpindica',form).unbind('change').bind('change', function() {
			$('#flgativo',form).focus();
			return false;
		});
		
		$('#flgativo',form).unbind('change').bind('change', function() {
			$('#dsindica',form).focus();
			return false;
		});
	} else if (abaAtual == 1) {
		// $('input',form).desabilitaCampo();
		$('#idvinculacao',form).css({'width':'40px'});
		$('#nmvinculacao',form).css({'width':'380px'});
		$('#flgativo',form).css({'width':'50px'});	

		$('#nmvinculacao',form).unbind('keydown').bind('keydown', function(e) {
			if ( e.keyCode == 13 )  {
				$('#flgativo',form).focus();
				return false;
			}
		});
	}
		
}

function selecionaLinha(opcao) {

    var flgSelected = false;
	var divBotoes = $('#divBotoes', $('#divAba'+abaAtual));

	$('table > tbody > tr', divRegistro).each( function() {
		if ( $(this).hasClass('corSelecao') ) {
            flgSelected = true;

			$('#dsindica','#divDescIndica').val($('#dsindicador',  $(this)).val());			

			if (opcao == 'A'){
				if (abaAtual == 0) {
					$('#idindica',form).val($('#idindicador', $(this)).val()); 
					$('#nmindica',form).val($('#nmindicador', $(this)).val()); 
					$('#tpindica',form).val($('#tpindicador', $(this)).val().substring(0, 1)); 
					$('#flgativo',form).val($('#flgativo', $(this)).val()); 
					$('#dsindica',form).val($('#dsindicador', $(this)).val());
					
					$("#btProsseguir", divBotoes).attr('onClick', "validaIndicador('A');");
				} else if (abaAtual == 1) {
					$('#idvinculacao',form).val($('#idvinculacao', $(this)).val()); 
					$('#nmvinculacao',form).val($('#nmvinculacao', $(this)).val()); 
					$('#flgativo',form).val($('#flgativo', $(this)).val()); 

					$("#btProsseguir", divBotoes).attr('onClick', "validaVinculacao('A');");
				}
			}else if(opcao == 'I'){
				buscaId();
				$("#btProsseguir", divBotoes).attr('onClick', (abaAtual == 0 ? "validaIndicador('I');" : "validaVinculacao('I');"));

			}else if(opcao == 'E'){
				showConfirmacao('Voc&ecirc; tem certeza de que deseja excluir este registro?', 'Confirma&ccedil;&atilde;o - Ayllos', 'excluir(' + (abaAtual == 0 ? $("#idindicador", $(this)).val() : $("#idvinculacao", $(this)).val()) + ');', 'bloqueiaFundo(divRotina)', 'sim.gif', 'nao.gif');
			}
		}
		
	});

    if (! flgSelected && opcao == 'E') {
        showError("error", "Favor selecionar o registro que deseja excluir!", "Alerta - Ayllos", "");
    }
	
	return false;
}

function buscaId() {
	showMsgAguardo('Aguarde, buscando c&oacute;digo...');	
	
	$.ajax({		
		type	: 'POST',
		dataType: 'script',
		url		: UrlSite + 'telas/cadidr/busca_id.php', 
		data    : {
					idaba: abaAtual,
					redirect: 'script_ajax'
				},
		error   : function(objAjax,responseError,objExcept) {
					hideMsgAguardo();
					showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','');
				},
		success : function(response) { 
					hideMsgAguardo();
					eval(response);					
				}
	}); 
}

function trocaVisao(opcao) {
	if ( $('table > tbody > tr', divRegistro).hasClass('corSelecao') ) { 
		// Se a vis�o est� na Tabela, ent�o joga os valores para o formul�rio
		if ( divTabela.css('display') == 'block' ) selecionaLinha(opcao);

		var divBotoes = $('#divBotoes', $('#divAba'+abaAtual));

		$('#btAlterar',divBotoes).toggle();
		$('#btIncluir',divBotoes).toggle();
		$('#btExcluir',divBotoes).toggle();
		$('#btVoltar',divBotoes).toggle();
		$('#btProsseguir',divBotoes).toggle();
		form.toggle();
		divTabela.toggle();

	}
	
	if (opcao == ''){
		estadoInicial();
	}else if (opcao == 'A' || opcao == 'I'){
		if (abaAtual == 0)
			$('#nmindica',form).focus();
		else
			$('#nmvinculacao',form).focus();
	}

	return false;
}

function validaIndicador(opcao){

	if (!$('#idindica',form).val()){		
		showError('error','Todos os campos s&atilde;o obrigat&oacute;rios, favor preench&ecirc;-los!','Alerta - Ayllos','$("#idindica",form).focus();');
		return false;
	}
	if (!$('#nmindica',form).val()){		
		showError('error','Todos os campos s&atilde;o obrigat&oacute;rios, favor preench&ecirc;-los!','Alerta - Ayllos','$("#nmindica",form).focus();');
		return false;
	}
	if (!$('#tpindica',form).val()){
		showError('error','Todos os campos s&atilde;o obrigat&oacute;rios, favor preench&ecirc;-los!','Alerta - Ayllos','$("#tpindica",form).focus();');
		return false;
	}
	if (!$('#flgativo',form).val()){
		showError('error','Todos os campos s&atilde;o obrigat&oacute;rios, favor preench&ecirc;-los!','Alerta - Ayllos','$("#flgativo",form).focus();');
		return false;
	}
	if (!$('#dsindica',form).val()){
		showError('error','Todos os campos s&atilde;o obrigat&oacute;rios, favor preench&ecirc;-los!','Alerta - Ayllos','$("#dsindica",form).focus();');
		return false;
	}
	if ($('#nmindica',form).val().length < 15){		
		showError('error','Nome do indicador deve possuir pelo menos 15 caracteres!','Alerta - Ayllos','$("#nmindica",form).focus();');
		return false;
	}
	if ($('#dsindica',form).val().length < 50){
		showError('error','Descri&ccedil;&atilde;o do Indicador deve possuir pelo menos 50 caracteres!','Alerta - Ayllos','$("#dsindica",form).focus();');
		return false;
	}
	
	if (opcao == 'I'){
		showConfirmacao('Voc&ecirc; tem certeza de que deseja incluir o indicador?', 'Confirma&ccedil;&atilde;o - Ayllos', 'inserir();', 'bloqueiaFundo(divRotina)', 'sim.gif', 'nao.gif');
	}else if (opcao == 'A'){
		showConfirmacao('Voc&ecirc; tem certeza de que deseja alterar o indicador?', 'Confirma&ccedil;&atilde;o - Ayllos', 'alterar();', 'bloqueiaFundo(divRotina)', 'sim.gif', 'nao.gif');
	}
	
}

function validaVinculacao(opcao){

	if (!$('#idvinculacao',form).val()){
		showError('error','Todos os campos s&atilde;o obrigat&oacute;rios, favor preench&ecirc;-los!','Alerta - Ayllos','$("#idvinculacao",form).focus();');
		return false;
	}
	if (!$('#nmvinculacao',form).val()){
		showError('error','Todos os campos s&atilde;o obrigat&oacute;rios, favor preench&ecirc;-los!','Alerta - Ayllos','$("#nmvinculacao",form).focus();');
		return false;
	}
	if (!$('#flgativo',form).val()){
		showError('error','Todos os campos s&atilde;o obrigat&oacute;rios, favor preench&ecirc;-los!','Alerta - Ayllos','$("#flgativo",form).focus();');
		return false;
	}
	
	if (opcao == 'I'){
		showConfirmacao('Voc&ecirc; tem certeza de que deseja incluir a vincula&ccedil;&atilde;o?', 'Confirma&ccedil;&atilde;o - Ayllos', 'inserir();', 'bloqueiaFundo(divRotina)', 'sim.gif', 'nao.gif');
	}else if (opcao == 'A'){
		showConfirmacao('Voc&ecirc; tem certeza de que deseja alterar a vincula&ccedil;&atilde;o?', 'Confirma&ccedil;&atilde;o - Ayllos', 'alterar();', 'bloqueiaFundo(divRotina)', 'sim.gif', 'nao.gif');
	}
	
}

function inserir(){
	
	showMsgAguardo('Aguarde, inserindo registro...');	
	
	var idindica = $('#idindica',form).val();
	var nmindica = $('#nmindica',form).val();
	var tpindica = $('#tpindica',form).val();
	var flgativo = $('#flgativo',form).val();
	var dsindica = $('#dsindica',form).val();

	var idvinculacao = $('#idvinculacao',form).val();
	var nmvinculacao = $('#nmvinculacao',form).val();
	
	$.ajax({		
		type: 'POST',
		dataType: 'script',
		url: UrlSite + 'telas/cadidr/insere_cadidr.php', 
		data: { 
			idaba: abaAtual,

			idindica: idindica,
			nmindica: nmindica,
			tpindica: tpindica,
			flgativo: flgativo,
			dsindica: dsindica,

			idvinculacao: idvinculacao,
			nmvinculacao: nmvinculacao,

			redirect: 'script_ajax'
		},
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError('error','N&atilde;o foi poss&iaculte;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','');
		},
		success: function(response) {
			hideMsgAguardo();
			eval(response);
		} 
	}); 
	
	return false;
}

function excluir(id){
	
	showMsgAguardo('Aguarde, excluindo registro...');	
		
	$.ajax({		
		type: 'POST',
		dataType: 'script',
		url: UrlSite + 'telas/cadidr/exclui_cadidr.php', 
		data: { 
			id: id,
			idaba: abaAtual,
			redirect: 'script_ajax'
		},
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','');
		},
		success: function(response) {
			hideMsgAguardo();
			eval(response);
		} 
	}); 
	
	return false;
}

function alterar(){
	
	showMsgAguardo('Aguarde, alterando registro...');

	var idindica = $('#idindica',form).val();
	var nmindica = $('#nmindica',form).val();
	var tpindica = $('#tpindica',form).val();
	var flgativo = $('#flgativo',form).val();
	var dsindica = $('#dsindica',form).val();

	var idvinculacao = $('#idvinculacao',form).val();
	var nmvinculacao = $('#nmvinculacao',form).val();
	
	$.ajax({		
		type: 'POST',
		dataType: 'script',
		url: UrlSite + 'telas/cadidr/altera_cadidr.php', 
		data: {
			idaba: abaAtual,
			idindica: idindica,
			nmindica: nmindica,
			tpindica: tpindica,
			flgativo: flgativo,
			dsindica: dsindica,

			idvinculacao: idvinculacao,
			nmvinculacao: nmvinculacao,
			redirect: 'script_ajax'
		},
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','');
		},
		success: function(response) {
			hideMsgAguardo();
			eval(response);					
		} 
	});
	
	return false;
}

function estadoInicial() {
	$('#frmCadidr','#tdTela').hide().limpaFormulario();
	acessaOpcaoAba(0);
}

function consultaIndicadores(){
	
	showMsgAguardo('Aguarde, obtendo dados ...');	

	// Gera requisição ajax para validar o acesso
	$.ajax({		
		type	: 'POST',
		dataType: 'html',
		url		: UrlSite + 'telas/cadidr/obtem_consulta.php', 
		data    : 
				{
					idaba    : abaAtual,
					redirect : 'script_ajax' 
				},
		error   : function(objAjax,responseError,objExcept) {
					hideMsgAguardo();
					showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','estadoInicial();');
				},
		success : function(response) {
					hideMsgAguardo();
					$('#divConsulta','#divAba0').html(response);
					formataTabela();
				}
	});
	
	return false;
}

function consultaVinculacoes(){
	
	showMsgAguardo('Aguarde, obtendo dados ...');

	// Gera requisição ajax para validar o acesso
	$.ajax({		
		type	: 'POST',
		dataType: 'html',
		url		: UrlSite + 'telas/cadidr/obtem_consulta.php', 
		data    : 
				{
					idaba    : abaAtual,
					redirect : 'script_ajax' 
				},
		error   : function(objAjax,responseError,objExcept) {
					hideMsgAguardo();
					showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','estadoInicial();');
				},
		success : function(response) {
					hideMsgAguardo();
					$('#divConsulta','#divAba1').html(response);
					formataTabela();
				}
	});
	
	return false;
}

function verificaAcesso(cddopcao){

	var flgSelected = false;

	$('table > tbody > tr', divRegistro).each( function() {
		if ( $(this).hasClass('corSelecao') ) {
            flgSelected = true;
        }
    });
    
    if (! flgSelected && cddopcao == 'A') {
        showError("error", "Favor selecionar o registro que deseja alterar!", "Alerta - Ayllos", "");
    } else {

        showMsgAguardo('Aguarde, validando acesso ...');	

        // Gera requisi��o ajax para validar o acesso
        $.ajax({		
            type	: 'POST',
            dataType: 'html',
            url		: UrlSite + 'telas/cadidr/verifica_acesso.php', 
            data    : 
                    { 
                        cddopcao    : cddopcao,
                        redirect	: 'script_ajax' 
                    },
            error   : function(objAjax,responseError,objExcept) {
                        hideMsgAguardo();
                        showError('error','N�o foi poss�vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','estadoInicial();');
                    },
            success : function(response) {
                        hideMsgAguardo();
                        eval(response);
                    }
        });

    }
	
	return false;

}

// Funcao para acessar opcoes da rotina
function acessaOpcaoAba(id) {

	abaAtual = parseInt(id);
    
    // Esconde as abas
    $('.clsAbas','#tdTela').hide();

	// Atribui cor de destaque para aba da opcao
	for (var i = 0; i < 4; i++) {
		if (abaAtual == i) { // Atribui estilos para foco da opcao
			$("#linkAba" + abaAtual).attr("class","txtBrancoBold");
			$("#imgAbaEsq" + abaAtual).attr("src",UrlImagens + "background/mnu_sle.gif");				
			$("#imgAbaDir" + abaAtual).attr("src",UrlImagens + "background/mnu_sld.gif");
			$("#imgAbaCen" + abaAtual).css("background-color","#969FA9");
            $("#divAba" + abaAtual).show();
			continue;			
		}
		$("#linkAba" + i).attr("class","txtNormalBold");
		$("#imgAbaEsq" + i).attr("src",UrlImagens + "background/mnu_nle.gif");			
		$("#imgAbaDir" + i).attr("src",UrlImagens + "background/mnu_nld.gif");
		$("#imgAbaCen" + i).css("background-color","#C6C8CA");
	}

	if (abaAtual == 0) {
		consultaIndicadores();
	} else if (abaAtual == 1) {
		consultaVinculacoes();
	}
	controlaLayout();
}