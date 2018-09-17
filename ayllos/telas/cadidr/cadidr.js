/*!
 * FONTE        : cadidr.js
 * CRIAÇÃO      : Lucas Reinert
 * DATA CRIAÇÃO : 03/02/2016
 * OBJETIVO     : Biblioteca de funções da tela CADIDR
 * --------------
 * ALTERAÇÕES   : 
 * --------------
 */

// Variáveis globais para alguns seletores úteis
var divTabela, divRotina, frmIndicador;

// Variáveis globais para o formulario de indicador
var cIdindica, cNmindica, cTpindica, cFlgativo, cDsindica;

$(document).ready(function() {			
	
	// Inicializando os seletores principais
	frmIndicador	= $('#frmIndicador');
	divTabela		= $('#divTabela');
	divRotina 		= $('#divTela');				
	
	$('fieldset > legend').css({'font-size': '12px', 'color': '#777', 'margin-left': '5px', 'padding': '0px 2px'});
    $('fieldset').css({'clear': 'both', 'border': '1px solid #777', 'margin': '3px 0px', 'padding': '10px 10px 5px'});	

	cIdindica = $('#idindica','#frmIndicador');
	cNmindica = $('#nmindica','#frmIndicador');
	cTpindica = $('#tpindica','#frmIndicador');
	cFlgativo = $('#flgativo','#frmIndicador');
	cDsindica = $('#dsindica','#frmIndicador');
	
	estadoInicial();
	controlaLayout();
    
    $(document).keyup(function(e){
        if (e.keyCode == 38 || e.keyCode == 40) { // 38:Seta para cima --- 40:Seta para baixo
            selecionaIndicador('');
            return false;
        }
    });

});


function controlaLayout() {	
	formataFormulario();
	formataTabela();	
	layoutPadrao();		
}

function formataTabela() {

	var divRegistro = $('div.divRegistros', divTabela );	
	var divDescIndica = $('div.divDescIndica', divTabela );	
	var tabela      = $('table', divRegistro );

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
	selecionaIndicador('');
	
	$('table > tbody > tr', divRegistro).click( function() {
		selecionaIndicador('');
	});	
	
	divTabela.css({'display':'block'});	
	
	return false;
}

function formataFormulario() {
	
	var cTodos      = $('input','#frmIndicador');		
	var rIdindica	= $('label[for="idindica"]','#frmIndicador');
	var rNmindica	= $('label[for="nmindica"]','#frmIndicador');
	var rTpindica	= $('label[for="tpindica"]','#frmIndicador');
	var rFlgativo	= $('label[for="flgativo"]','#frmIndicador');
	var rDsindica	= $('label[for="dsindica"]','#frmIndicador');	
	
	rIdindica.css('width', '70px').addClass('rotulo');
	rNmindica.css('width','70px').addClass('rotulo');
	rTpindica.css('width','70px').addClass('rotulo');
	rFlgativo.css('width', '173px').addClass('rotulo-linha');
	rDsindica.css('width', '70px').addClass('rotulo');		
	
	// cTodos.desabilitaCampo();
	cIdindica.css({'width': '40px'});
	cNmindica.css({'width': '380px'});
	cTpindica.css({'width': '150px'});	
	cFlgativo.css({'width':'50px'});	
	cDsindica.css({'width':'380px', 'height':'80px'});
		
	cNmindica.unbind('keydown').bind('keydown', function(e) {
		if ( e.keyCode == 13 )  {
			cTpindica.focus();
			return false;
		}
	});
	
	cTpindica.unbind('change').bind('change', function() {
		cFlgativo.focus();
		return false;
	});
	
	cFlgativo.unbind('change').bind('change', function() {
		cDsindica.focus();
		return false;
	});
		
}

function selecionaIndicador(opcao) {

    var flgSelected = false;

	$('table > tbody > tr', 'div.divRegistros').each( function() {
		if ( $(this).hasClass('corSelecao') ) {
            flgSelected = true;

			$('#dsindica','#divDescIndica').val($('#dsindicador',  $(this)).val());			
			
			if (opcao == 'A'){
				cIdindica.val($('#idindicador', $(this)).val()); 
				cNmindica.val($('#nmindicador', $(this)).val()); 
				cTpindica.val($('#tpindicador', $(this)).val().substring(0, 1)); 
				cFlgativo.val($('#flgativo', $(this)).val()); 
				cDsindica.val($('#dsindicador', $(this)).val()); 
				$("#btProsseguir", "#divBotoes").attr('onClick', "validaIndicador('A');");				
			}else if(opcao == 'I'){
				buscaIdIndicador();
				$("#btProsseguir", "#divBotoes").attr('onClick', "validaIndicador('I');");
			}else if(opcao == 'E'){
				showConfirmacao('Você tem certeza de que deseja excluir este indicador?', 'Confirma&ccedil;&atilde;o - Ayllos', 'excluirIndicador(' + $("#idindicador", $(this)).val() + ');', 'bloqueiaFundo(divRotina)', 'sim.gif', 'nao.gif');
			}
		}
		
	});

    if (! flgSelected && opcao == 'E') {
        showError("error", "Favor selecionar o indicador que deseja excluir!", "Alerta - Ayllos", "");
    }
	
	return false;
}

function buscaIdIndicador() {
	showMsgAguardo('Aguarde, buscando c&oacute;digo do indicador...');	
	
	$.ajax({		
		type	: 'POST',
		dataType: 'script',
		url		: UrlSite + 'telas/cadidr/busca_idindicador.php', 
		data    :
				{ 
				redirect: 'script_ajax'
				},
		error   : function(objAjax,responseError,objExcept) {
					hideMsgAguardo();
					showError('error','Não foi possível concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','');
				},
		success : function(response) { 
					hideMsgAguardo();
					eval(response);					
				}
	}); 
}

function trocaVisao(opcao) {
	if ( $('table > tbody > tr', 'div.divRegistros').hasClass('corSelecao') ) { 
		// Se a visão está na Tabela, então joga os valores para o formulário
		if ( divTabela.css('display') == 'block' ) selecionaIndicador(opcao);

		$('#btAlterar','#divBotoes').toggle();
		$('#btIncluir','#divBotoes').toggle();
		$('#btExcluir','#divBotoes').toggle();
		$('#btVoltar','#divBotoes').toggle();
		$('#btProsseguir','#divBotoes').toggle();
		frmIndicador.toggle();
		divTabela.toggle();

	}
	
	if (opcao == ''){
		estadoInicial();
	}else if (opcao == 'A' || opcao == 'I'){
		cNmindica.focus();
	}

	return false;
}

function validaIndicador(opcao){
	
	if (!cIdindica.val()){		
		showError('error','Todos os campos s&atilde;o obrigat&oacute;rios, favor preench&ecirc;-los!','Alerta - Ayllos','cIdindica.focus();');
		return false;
	}
	if (!cNmindica.val()){		
		showError('error','Todos os campos s&atilde;o obrigat&oacute;rios, favor preench&ecirc;-los!','Alerta - Ayllos','cNmindica.focus();');
		return false;
	}
	if (!cTpindica.val()){
		showError('error','Todos os campos s&atilde;o obrigat&oacute;rios, favor preench&ecirc;-los!','Alerta - Ayllos','cTpindica.focus();');
		return false;
	}
	if (!cFlgativo.val()){
		showError('error','Todos os campos s&atilde;o obrigat&oacute;rios, favor preench&ecirc;-los!','Alerta - Ayllos','cFlgativo.focus();');
		return false;
	}
	if (!cDsindica.val()){
		showError('error','Todos os campos s&atilde;o obrigat&oacute;rios, favor preench&ecirc;-los!','Alerta - Ayllos','cDsindica.focus();');
		return false;
	}
	if (cNmindica.val().length < 15){		
		showError('error','Nome do indicador deve possuir pelo menos 15 caracteres!','Alerta - Ayllos','cNmindica.focus();');
		return false;
	}
	if (cDsindica.val().length < 50){
		showError('error','Descri&ccedil;&atilde;o do Indicador deve possuir pelo menos 50 caracteres!','Alerta - Ayllos','cDsindica.focus();');
		return false;
	}
	
	if (opcao == 'I'){
		showConfirmacao('Você tem certeza de que deseja incluir o indicador?', 'Confirma&ccedil;&atilde;o - Ayllos', 'inserirIndicador();', 'bloqueiaFundo(divRotina)', 'sim.gif', 'nao.gif');
	}else if (opcao == 'A'){
		showConfirmacao('Você tem certeza de que deseja alterar o indicador?', 'Confirma&ccedil;&atilde;o - Ayllos', 'alterarIndicador();', 'bloqueiaFundo(divRotina)', 'sim.gif', 'nao.gif');
	}
	
}

function inserirIndicador(){
	
	showMsgAguardo('Aguarde, inserindo indicador...');	
	
	var idindica = cIdindica.val();
	var nmindica = cNmindica.val();
	var tpindica = cTpindica.val();
	var flgativo = cFlgativo.val();
	var dsindica = cDsindica.val();
	
	$.ajax({		
		type	: 'POST',
		dataType: 'script',
		url		: UrlSite + 'telas/cadidr/insere_indicador.php', 
		data    :
				{ 
				idindica: idindica,
				nmindica: nmindica,
				tpindica: tpindica,
				flgativo: flgativo,
				dsindica: dsindica,
				redirect: 'script_ajax'
				},
		error   : function(objAjax,responseError,objExcept) {
					hideMsgAguardo();
					showError('error','Não foi possível concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','');
				},
		success: function(response) {
					hideMsgAguardo();
					eval(response);
		} 
	}); 
	
	return false;
}

function excluirIndicador(idindica){
	
	showMsgAguardo('Aguarde, excluindo indicador...');	
		
	$.ajax({		
		type	: 'POST',
		dataType: 'script',
		url		: UrlSite + 'telas/cadidr/exclui_indicador.php', 
		data    :
				{ 
				idindica: idindica,
				redirect: 'script_ajax'
				},
		error   : function(objAjax,responseError,objExcept) {
					hideMsgAguardo();
					showError('error','Não foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','');
				},
		success: function(response) {
					hideMsgAguardo();
					eval(response);
		} 
	}); 
	
	return false;
}

function alterarIndicador(){
	
	showMsgAguardo('Aguarde, alterando indicador...');	
	
	var idindica = cIdindica.val();
	var nmindica = cNmindica.val();
	var tpindica = cTpindica.val();
	var flgativo = cFlgativo.val();
	var dsindica = cDsindica.val();
	
	$.ajax({		
		type	: 'POST',
		dataType: 'script',
		url		: UrlSite + 'telas/cadidr/altera_indicador.php', 
		data    :
				{ 
				idindica: idindica,
				nmindica: nmindica,
				tpindica: tpindica,
				flgativo: flgativo,
				dsindica: dsindica,
				redirect: 'script_ajax'
				},
		error   : function(objAjax,responseError,objExcept) {
					hideMsgAguardo();
					showError('error','Não foi possível concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','');
				},
		success: function(response) {
					hideMsgAguardo();
					eval(response);					
		} 
	});
	
	return false;
}

function estadoInicial() {
	frmIndicador.css({'display':'none'}).limpaFormulario();
	consultaIndicadores();
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
					redirect	: 'script_ajax' 
				},
		error   : function(objAjax,responseError,objExcept) {
					hideMsgAguardo();
					showError('error','Não foi possível concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','estadoInicial();');
				},
		success : function(response) {
					hideMsgAguardo();
					$('#divConsulta').html(response);
					formataTabela();
				}
	});
	
	return false;
}

function verificaAcesso(cddopcao){

	var flgSelected = false;

	$('table > tbody > tr', 'div.divRegistros').each( function() {
		if ( $(this).hasClass('corSelecao') ) {
            flgSelected = true;
        }
    });
    
    if (! flgSelected && cddopcao == 'A') {
        showError("error", "Favor selecionar o indicador que deseja alterar!", "Alerta - Ayllos", "");
    } else {

        showMsgAguardo('Aguarde, validando acesso ...');	

        // Gera requisição ajax para validar o acesso
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
                        showError('error','Não foi possível concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','estadoInicial();');
                    },
            success : function(response) {
                        hideMsgAguardo();
                        eval(response);
                    }
        });

    }
	
	return false;

}

