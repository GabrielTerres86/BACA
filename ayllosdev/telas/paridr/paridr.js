//*********************************************************************************************//
//*** Fonte: paridr.js                                                 						***//
//*** Autor: Lucas Reinert                                           						***//
//*** Data : Março/2016                  Última Alteração: --/--/----  						***//
//***                                                                  						***//
//*** Objetivo  : Biblioteca de funções da tela PARIDR                 						***//
//***                                                                  						***//	 
//*** Alterações: 																			***//
//*********************************************************************************************//

var cCdcooper;
var cTodos;
var cddopcao = 'C';
var cTodosCabecalho;
var divRotina, frmCab, frmIndicador, divFormulario, divBotoes;
// Variaveis do form de indicadores
var cIdindica, cNmindica, cTpindica, cCdprodut, cDsprodut, cInpessoa, cVlminimo, cVlmaximo, cPerscore, cPertoler;

$(document).ready(function() {

	// Inicializando os seletores principais
	frmIndicador	= $('#frmIndicador');
	divRotina 		= $('#divTela');				
	frmCab			= $('#frmCab');
	divFormulario	= $('#divFormulario');
	divBotoes		= $('#divBotoes');
	
	cIdindica = $('#idindicador','#frmIndicador');
	cNmindica = $('#nmindicador','#frmIndicador');
	cTpindica = $('#tpindicador','#frmIndicador');
	cCdprodut = $('#cdproduto','#frmIndicador');
	cDsprodut = $('#dsproduto','#frmIndicador');
	cInpessoa = $('#inpessoa','#frmIndicador');
	cVlminimo = $('#vlminimo','#frmIndicador');
	cVlmaximo = $('#vlmaximo','#frmIndicador');
	cPerscore = $('#perscore','#frmIndicador');
	cPertoler = $('#pertolera','#frmIndicador');
    estadoInicial();

    highlightObjFocus();

    return false;
});

function estadoInicial() {

    frmCab.css({'display': 'block'});
	frmIndicador.css({'display':'none'}).limpaFormulario();
	$("#btVoltar", "#divBotoes").attr('onClick', "voltarCab();");				
	
    formataCabecalho();	
	formataFormulario();
    cTodosCabecalho.habilitaCampo();
	
    removeOpacidade('divTela');
    unblockBackground();
    hideMsgAguardo();
	
    return false;
}

function formataCabecalho() {

    cTodosCabecalho = $('input[type="text"],select', '#frmCab');

    var rCdcooper = $('label[for="cdcooper"]', '#frmCab');

    rCdcooper.css('width', '100px').addClass('rotulo');

    cCdcooper = $('#cdcooper', '#frmCab');
    cCdcooper.html(slcooper);
    cCdcooper.css('width', '125px').attr('maxlength', '2');

    cCdcooper.unbind('keypress').bind('keypress', function(e) {
        if (e.keyCode == 13) {
            buscaIndicadores();
            return false;
        }
    });

    cCdcooper.unbind('changed').bind('changed', function(e) {
        buscaIndicadores();
        return false;
    });
		
	if (cdcooper != 3){
		$('#btnOK', '#frmCab').click();		
	}
		
	layoutPadrao();
	return false;

}

function formataFormulario() {

	var cTodos      = $('input','#frmIndicador');		
	var rIdindica	= $('label[for="idindicador"]','#frmIndicador');
	var rTpindica	= $('label[for="tpindicador"]','#frmIndicador');
	var rCdprodut	= $('label[for="cdproduto"]','#frmIndicador');
	var rInpessoa	= $('label[for="inpessoa"]','#frmIndicador');
	var rVlminimo	= $('label[for="vlminimo"]','#frmIndicador');	
	var rVlmaximo	= $('label[for="vlmaximo"]','#frmIndicador');	
	var rPerscore	= $('label[for="perscore"]','#frmIndicador');	
	var rPertoler	= $('label[for="pertolera"]','#frmIndicador');	
		
	rIdindica.css('width', '100px').addClass('rotulo');
	rTpindica.css('width', '100px').addClass('rotulo-linha');
	rCdprodut.css('width', '100px').addClass('rotulo');
	rInpessoa.css('width', '100px').addClass('rotulo-linha');
	rVlminimo.css('width', '100px').addClass('rotulo');		
	rVlmaximo.css('width', '144px').addClass('rotulo-linha');		
	rPerscore.css('width', '100px').addClass('rotulo');		
	rPertoler.css('width', '144px').addClass('rotulo-linha');		
		
	// cTodos.desabilitaCampo();
	cIdindica.addClass('codigo pesquisa').css({'width': '40px'});
	cNmindica.css({'width': '290px'});
	cTpindica.css({'width': '100px'});
	cCdprodut.addClass('codigo pesquisa').css({'width': '40px'});
	cDsprodut.css({'width': '290px'});	
	cInpessoa.css({'width': '100px'});	
	cVlminimo.css({'width': '100px'});
	cVlmaximo.css({'width': '100px'});
	
	if (cTpindica.val() == 'Q' ) {
		cVlminimo.setMask('INTEGER','zzz.zzz.zzz.zz9');
		cVlmaximo.setMask('INTEGER','zzz.zzz.zzz.zz9');
	}else if (cTpindica.val() == 'M' ){
		cVlminimo.setMask('DECIMAL','zzz.zzz.zzz.zz9,99','.','');
		cVlmaximo.setMask('DECIMAL','zzz.zzz.zzz.zz9,99','.','');
	}
	cPerscore.css({'width': '100px'}).setMask('DECIMAL','zz9,99','.','');
	cPertoler.css({'width': '100px'}).setMask('DECIMAL','zz9,99','.','');
		
	cIdindica.unbind('keydown').bind('keydown', function(e) {
		if ( e.keyCode == 13 || e.keyCode == 9 )  {
			controlaPesquisa('I');
			return false;
		}
	});
	
	cCdprodut.unbind('keydown').bind('keydown', function(e) {
		if ( e.keyCode == 13 || e.keyCode == 9)  {
			controlaPesquisa('P');
			return false;
		}
	});
		
	cInpessoa.unbind('keydown').bind('keydown', function(e) {
		if ( e.keyCode == 13 || e.keyCode == 9)  {
			if (cTpindica.val() != 'A'){
				cVlminimo.focus();
			}else{
				cPerscore.focus();
			}
			return false;
		}
	});
	
	cVlminimo.unbind('keydown').bind('keydown', function(e) {
		if ( e.keyCode == 13 )  {			
			cVlmaximo.focus();
			return false;
		}
	});
	
	cVlmaximo.unbind('keydown').bind('keydown', function(e) {
		if ( e.keyCode == 13 )  {			
			cPerscore.focus();
			return false;
		}
	});
	
	cPerscore.unbind('keydown').bind('keydown', function(e) {
		if ( e.keyCode == 13 )  {
			if (cPertoler.prop('disabled')){
				$("#btProsseguir", "#divBotoes").click();
				return false;
			}else{
				cPertoler.focus();
				return false;
			}
		}
	});
	
	cPertoler.unbind('keydown').bind('keydown', function(e) {
		if ( e.keyCode == 13 )  {					
			$("#btProsseguir", "#divBotoes").click();
			return false;
		}
	});
	
	layoutPadrao();

}

// Botao Voltar
function voltarCab() {
	if (cdcooper == 3){
		divFormulario.hide();
		divBotoes.hide();
		cTodosCabecalho.habilitaCampo();
	}
    return false;
}

function voltarTabela(){
	$('#btAlterar','#divBotoes').toggle();
	$('#btIncluir','#divBotoes').toggle();
	$('#btExcluir','#divBotoes').toggle();
	$('#btProsseguir','#divBotoes').toggle();
	frmIndicador.toggle();
	frmIndicador.limpaFormulario();
	divFormulario.toggle();
	$("#btVoltar", "#divBotoes").attr('onClick', "voltarCab();");				
	return false;
}

function buscaIndicadores() {
	
	if ($('#cdcooper', '#frmCab').hasClass('campoTelaSemBorda')) {
        return false;
    }
	
    var cdcooper = $('#cdcooper', '#frmCab').val();

    // Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, carregando informa&ccedil;&otilde;es ...");

    // Carrega conteúdo da opção através de ajax
    $.ajax({
        type: "POST",
        dataType: 'html',
        url: UrlSite + "telas/paridr/obtem_consulta.php",
        data: {
            cdcooper: cdcooper,
            redirect: "script_ajax" // Tipo de retorno do ajax
        },
        error: function(objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Ayllos", "");
        },
        success: function(response) {
            $('#divFormulario').html(response).show();
			formataTabela();
			divBotoes.show();			
			hideMsgAguardo();
			cTodosCabecalho.desabilitaCampo();
		
		}

    });

    return false;

}

function formataTabela() {
	var divRegistro = $('div.divRegistros', divRotina );	
	var tabela      = $('table', divRegistro );

	divRegistro.css({'height':'200px','border-bottom':'1px dotted #777','padding-bottom':'2px'});	
	
	$('tr.sublinhado > td',divRegistro).css({'text-decoration':'underline'});	
	
	var ordemInicial = new Array();

	var arrayLargura = new Array();
	arrayLargura[0] =   '60px';
	arrayLargura[1] =   '241px';
	arrayLargura[2] =   '65px';
	arrayLargura[3] =   '135px';
	arrayLargura[4] =   '54px';
	arrayLargura[5] =   '60px';
	arrayLargura[6] =   '60px';
	arrayLargura[7] =   '50px';

	var arrayAlinha = new Array();
	arrayAlinha[0] = 'right';
	arrayAlinha[1] = 'left';
	arrayAlinha[2] = 'left';
	arrayAlinha[3] = 'left';
	arrayAlinha[4] = 'center';
	arrayAlinha[5] = 'right';
	arrayAlinha[6] = 'right';
	arrayAlinha[7] = 'right';
	arrayAlinha[8] = 'right';
	
	tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha, '' );
	
	// Seleciona primeiro indicador
	selecionaIndicador('');
	
	$('table > tbody > tr', divRegistro).click( function() {
		selecionaIndicador('');
	});	
	
	return false;
}

function selecionaIndicador(opcao) {

    var flgSelected = false;

	$('table > tbody > tr', 'div.divRegistros').each( function() {
		if ( $(this).hasClass('corSelecao') ) {
            flgSelected = true;
			
			if (opcao == 'A'){
				cIdindica.val($('#idindicador', $(this)).val()); 
				cNmindica.val($('#nmindicador', $(this)).val()); 
				cTpindica.val($('#tpindicador', $(this)).val().substring(0, 1)); 
				cCdprodut.val($('#cdproduto', $(this)).val()); 
				cDsprodut.val($('#dsproduto', $(this)).val()); 
				cInpessoa.val($('#inpessoa2', $(this)).val()); 
				cVlminimo.val($('#vlminimo', $(this)).val()); 
				cVlmaximo.val($('#vlmaximo', $(this)).val()); 
				cPerscore.val($('#perscore', $(this)).val()); 
				cPertoler.val($('#pertolera', $(this)).val()); 
				$("#btProsseguir", "#divBotoes").attr('onClick', "validaIndicador('A');");				
							
			}else if(opcao == 'E'){
				showConfirmacao('Você tem certeza que deseja excluir esta parametrização? A operação não poderá ser desfeita!', 'Confirma&ccedil;&atilde;o - Ayllos', 'excluirParametro(' + cCdcooper.val()+ ',' + $("#idindicador", $(this)).val() + ',' + $('#cdproduto', $(this)).val() + ',' + $('#inpessoa2', $(this)).val() + ');', 'bloqueiaFundo(divRotina)', 'sim.gif', 'nao.gif');
			}
		}
		
	});

    if (! flgSelected && opcao == 'E') {
        showError("error", "Favor selecionar a parametrização que deseja excluir!", "Alerta - Ayllos", "");
    }
	
	// layoutPadrao();
	return false;
}

function trocaVisao(opcao) {

	$("#btVoltar", "#divBotoes").attr('onClick', "voltarTabela();");				
	if (opcao == 'A'){
		if ( $('table > tbody > tr', 'div.divRegistros').hasClass('corSelecao') ) {
			// Se a visão está na Tabela, então joga os valores para o formulário
			if ( divFormulario.css('display') == 'block' ) selecionaIndicador(opcao);
			
			$('#btAlterar','#divBotoes').toggle();
			$('#btIncluir','#divBotoes').toggle();
			$('#btExcluir','#divBotoes').toggle();
			$('#btProsseguir','#divBotoes').toggle();
			frmIndicador.toggle();
			divFormulario.toggle();

			cIdindica.prop('disabled', true);
			cCdprodut.prop('disabled', true);
			cInpessoa.prop('disabled', true);				
			if (cTpindica.val() == 'A'){
				cVlminimo.val(0);
				cVlmaximo.val(0);
				cPertoler.val(0);
				cVlminimo.prop('disabled', true);
				cVlmaximo.prop('disabled', true);
				cPertoler.prop('disabled', true);
				cPerscore.focus();
			}else if (cTpindica.val() == 'Q' ) {
				cVlminimo.prop('disabled', false);
				cVlmaximo.prop('disabled', false);
				cPertoler.prop('disabled', false);				
				cVlminimo.setMask('INTEGER','zzz.zzz.zzz.zz9');
				cVlmaximo.setMask('INTEGER','zzz.zzz.zzz.zz9');
				cVlminimo.focus();
			}else{
				cVlminimo.prop('disabled', false);
				cVlmaximo.prop('disabled', false);
				cPertoler.prop('disabled', false);				
				cVlminimo.setMask('DECIMAL','zzz.zzz.zzz.zz9,99','.','');
				cVlmaximo.setMask('DECIMAL','zzz.zzz.zzz.zz9,99','.','');
				cVlminimo.focus();
			}			
			
		}
	}else{
		$('#btAlterar','#divBotoes').toggle();
		$('#btIncluir','#divBotoes').toggle();
		$('#btExcluir','#divBotoes').toggle();
		$('#btProsseguir','#divBotoes').toggle();
		frmIndicador.toggle();
		divFormulario.toggle();
		
		cIdindica.focus();
		cIdindica.prop('disabled', false);
		cCdprodut.prop('disabled', false);
		cInpessoa.prop('disabled', false);
		cVlminimo.prop('disabled', false);
		cVlmaximo.prop('disabled', false);
		cPertoler.prop('disabled', false);
		$("#btProsseguir", "#divBotoes").attr('onClick', "validaIndicador('I');");	
	}
	
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
        showError("error", "Favor selecionar um registro para a devida alteração!", "Alerta - Ayllos", "");
    } else {
        
        showMsgAguardo('Aguarde, validando acesso ...');	

        // Gera requisição ajax para validar o acesso
        $.ajax({		
            type	: 'POST',
            dataType: 'html',
            url		: UrlSite + 'telas/paridr/verifica_acesso.php', 
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

// Função para abrir a pesquisa de indicadores
function mostrarPesquisaIndicadores(){
	if( $('#idindicador','#frmIndicador').prop("disabled") ) {
		return false;
	}
	//Definição dos filtros
	var filtros	= "ID;idindicador;50px;N;;N;|Indicador;nmindicador;200px;S;;S;descricao|Tipo;tpindica;50px;N;;N;|Tipo2;tpindicador;50px;N;;N;";
	//Campos que serão exibidos na tela
	var colunas = 'ID;idindicador;10%;right|Indicador;nmindicador;65%;left|Tipo;tpindica;25%;left|Tipo2;tpindicador;0%;;;N';
	//Exibir a pesquisa
	mostraPesquisa("TELA_PARIDR", "PESQUISA_INDICADORES", "Indicadores","50",filtros,colunas,divRotina,'controlaPesquisa("I");');
	$("#divCabecalhoPesquisa > table > thead > tr").append("<td style='width: 18px'>");
}

// Função para abrir a pesquisa de produtos
function mostrarPesquisaProdutos(){
	if( $('#cdproduto','#frmIndicador').prop("disabled") ) {
		return false;
	}
	//Definição dos filtros
	var filtros	= "Código;cdproduto;50px;N;;N;|Produto;dsproduto;200px;S;;S;descricao";
	//Campos que serão exibidos na tela
	var colunas = 'Código;cdproduto;20%;right|Produto;dsproduto;80%;left';
	//Exibir a pesquisa
	mostraPesquisa("TELA_PARIDR", "PESQUISA_PRODUTOS", "Produtos","50",filtros,colunas,divRotina,'controlaPesquisa("P")');
	$("#divCabecalhoPesquisa > table > thead > tr").append("<td style='width: 18px'>");
}

function controlaPesquisa(tipo){
	if (tipo == 'I'){
		consultaIndicador();
		
		cVlminimo.val('0');
		cVlmaximo.val('0');
		cPertoler.val('0');
		
		cCdprodut.focus();
		
		return false;
	}else if (tipo == 'P'){
		consultaProduto();
		if (cInpessoa.prop('disabled')){
			if (cTpindica != 'A'){
				cVlminimo.focus();
			}else{
				cPerscore.focus();
			}
		}else{
			cInpessoa.focus();			
		}		
		return false;
	}
	
}

function consultaIndicador(){

	var idindica = cIdindica.val();

    if (idindica != '') {

        showMsgAguardo('Aguarde, consultando indicador ...');

        // Gera requisição ajax para validar o indicador
        $.ajax({		
            type	: 'POST',
            dataType: 'html',
            url		: UrlSite + 'telas/paridr/valida_indicador.php', 
            data    : 
                    { 
                        cddopcao    : cddopcao,
                        idindica	: idindica,
                        redirect	: 'script_ajax' 
                    },
            error   : function(objAjax,responseError,objExcept) {
                        hideMsgAguardo();
                        showError('error','N&atilde;o foi possível concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','estadoInicial();');
                    },
            success : function(response) {
                        hideMsgAguardo();
                        eval(response);
                        if (cTpindica.val() == 'Q' ) {
                            cVlminimo.setMask('INTEGER','zzz.zzz.zzz.zz9');
                            cVlmaximo.setMask('INTEGER','zzz.zzz.zzz.zz9');
                            cVlminimo.prop('disabled', false);
                            cVlmaximo.prop('disabled', false);
                            cPertoler.prop('disabled', false);								
                        }else if (cTpindica.val() == 'M' ){
                            cVlminimo.setMask('DECIMAL','zzz.zzz.zzz.zz9,99','.','');
                            cVlmaximo.setMask('DECIMAL','zzz.zzz.zzz.zz9,99','.','');
                            cVlminimo.prop('disabled', false);
                            cVlmaximo.prop('disabled', false);
                            cPertoler.prop('disabled', false);				
                        }else{
                            cVlminimo.prop('disabled', true);
                            cVlmaximo.prop('disabled', true);
                            cPertoler.prop('disabled', true);				

                        }					

                    }
        });
    }
	
	return false;

}

function consultaProduto(){

	var cdproduto = cCdprodut.val();
    
    if (cdproduto != '') {
	
        showMsgAguardo('Aguarde, consultando produto ...');
	
        // Gera requisição ajax para validar o indicador
        $.ajax({		
            type	: 'POST',
            dataType: 'html',
            url		: UrlSite + 'telas/paridr/valida_produto.php', 
            data    : 
                    { 
                        cddopcao    : cddopcao,
                        cdproduto	: cdproduto,
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

function limpaIndicador(){
	
	cIdindica.focus(); 
	cIdindica.val("");
	cNmindica.val("");
	
}

function limpaProduto(){
	
	cCdprodut.focus(); 
	cCdprodut.val("");
	cDsprodut.val("");
	
}

function validaIndicador(opcao){
	
	var vlminimo, vlmaximo, perscore, pertolera;
	
	vlminimo = cVlminimo.val().replace(/\./g,"");	
	vlminimo = new Number(vlminimo.replace(",","."));		
	vlmaximo = cVlmaximo.val().replace(/\./g,"");		
	vlmaximo = new Number(vlmaximo.replace(",","."));			
	perscore = new Number(cPerscore.val().replace(",","."));		
	pertolera = new Number(cPertoler.val().replace(",","."));
	
	if (opcao == 'I'){
		if (!cIdindica.val()){		
			showError('error','Todos os campos s&atilde;o obrigat&oacute;rios, favor preench&ecirc;-los!','Alerta - Ayllos','cIdindica.focus();');
			return false;
		}
		if (!cCdprodut.val()){		
			showError('error','Todos os campos s&atilde;o obrigat&oacute;rios, favor preench&ecirc;-los!','Alerta - Ayllos','cCdprodut.focus();');
			return false;
		}
		if (!cInpessoa.val()){		
			showError('error','Todos os campos s&atilde;o obrigat&oacute;rios, favor preench&ecirc;-los!','Alerta - Ayllos','cInpessoa.focus();');
			return false;
		}
	}
	if (cTpindica.val() != 'A'){
		if (!cVlminimo.val()){
			showError('error','Todos os campos s&atilde;o obrigat&oacute;rios, favor preench&ecirc;-los!','Alerta - Ayllos','cVlminimo.focus();');
			return false;
		}else{
			if (vlminimo <= 0 || vlminimo > vlmaximo){
				showError('error','Valor M&iacute;nimo inv&aacute;lido! Favor informar um valor superior a 0(zero) e inferior ao Valor M&aacute;ximo!','Alerta - Ayllos','cVlminimo.focus();');
				return false;			
			}
		}
		if (!cVlmaximo.val()){
			showError('error','Todos os campos s&atilde;o obrigat&oacute;rios, favor preench&ecirc;-los!','Alerta - Ayllos','cVlmaximo.focus();');
			return false;
		}else{
			if (vlmaximo <= 0 || vlmaximo < vlminimo){
				showError('error','Valor M&iacute;nimo inv&aacute;lido! Favor informar um valor superior a 0(zero) e inferior ao Valor M&aacute;ximo!','Alerta - Ayllos','cVlminimo.focus();');
				return false;			
			}
		}
		if (pertolera > 100 || pertolera < 0){
			showError('error','Percentuais informados devem estar na faixa de 0,00% a 100,00%!','Alerta - Ayllos','cPertoler.focus();');
			return false;					
		}
	}
	if (perscore > 100 || perscore < 0){
		showError('error','Percentuais informados devem estar na faixa de 0,00% a 100,00%!','Alerta - Ayllos','cPerscore.focus();');
		return false;					
	}
	
	if (opcao == 'I'){
		showConfirmacao('Você tem certeza de que deseja gravar esta parametrização?', 'Confirma&ccedil;&atilde;o - Ayllos', 'inserirParametro();', 'bloqueiaFundo(divRotina)', 'sim.gif', 'nao.gif');
	}else if (opcao == 'A'){
		showConfirmacao('Você tem certeza de que deseja gravar esta parametrização?', 'Confirma&ccedil;&atilde;o - Ayllos', 'alterarParametro();', 'bloqueiaFundo(divRotina)', 'sim.gif', 'nao.gif');
	}
	
}

function inserirParametro(){
	
	showMsgAguardo('Aguarde, inserindo parametro...');	
	
	var cdcooper = cCdcooper.val();
	var idindica = cIdindica.val();
	var cdprodut = cCdprodut.val();
	var inpessoa = cInpessoa.val();
	var vlminimo = cVlminimo.val().replace(/\./g,"");	
		vlminimo = vlminimo.replace(",",".");		
	var vlmaximo = cVlmaximo.val().replace(/\./g,"");		
		vlmaximo = vlmaximo.replace(",",".");		
	var perscore = cPerscore.val().replace(",",".");
	var pertoler = cPertoler.val().replace(",",".");
	
	$.ajax({		
		type	: 'POST',
		dataType: 'script',
		url		: UrlSite + 'telas/paridr/insere_param_indicador.php', 
		data    :
				{ 
				cdcooper: cdcooper,
				idindica: idindica,
				cdprodut: cdprodut,
				inpessoa: inpessoa,
				vlminimo: vlminimo,
				vlmaximo: vlmaximo,
				perscore: perscore,
				pertoler: pertoler,
				redirect: 'script_ajax'
				},
		error   : function(objAjax,responseError,objExcept) {
				hideMsgAguardo();
				showError('error','N&atilde;o foi possível concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','');
				},
		success: function(response) {
				hideMsgAguardo();
				eval(response);
		} 
	}); 
	
	return false;
}

function alterarParametro(){
	
	showMsgAguardo('Aguarde, alterando parametro...');	
	
	var cdcooper = cCdcooper.val();
	var idindica = cIdindica.val();
	var cdprodut = cCdprodut.val();
	var inpessoa = cInpessoa.val();
	var vlminimo = cVlminimo.val().replace(/\./g,"");
		vlminimo = vlminimo.replace(",",".");		
	var vlmaximo = cVlmaximo.val().replace(/\./g,"");
		vlmaximo = vlmaximo.replace(",",".");		
	var perscore = cPerscore.val().replace(",",".");
	var pertoler = cPertoler.val().replace(",",".");
	
	$.ajax({		
		type	: 'POST',
		dataType: 'script',
		url		: UrlSite + 'telas/paridr/altera_param_indicador.php', 
		data    :
				{ 
				cdcooper: cdcooper,
				idindica: idindica,
				cdprodut: cdprodut,
				inpessoa: inpessoa,
				vlminimo: vlminimo,
				vlmaximo: vlmaximo,
				perscore: perscore,
				pertoler: pertoler,
				redirect: 'script_ajax'
				},
		error   : function(objAjax,responseError,objExcept) {
				hideMsgAguardo();
				showError('error','N&atilde;o foi possível concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','');
				},
		success: function(response) {
				hideMsgAguardo();
				eval(response);
		} 
	}); 
	
	return false;
}

function excluirParametro(cdcooper,idindica,cdprodut,inpessoa){
	
	showMsgAguardo('Aguarde, excluindo parametro...');	
		
	$.ajax({		
		type	: 'POST',
		dataType: 'script',
		url		: UrlSite + 'telas/paridr/exclui_param_indicador.php', 
		data    :
				{ 
				cdcooper: cdcooper,
				idindica: idindica,
				cdprodut: cdprodut,
				inpessoa: inpessoa,
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
