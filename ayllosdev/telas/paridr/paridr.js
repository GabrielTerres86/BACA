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
var abaAtual = 0;
var cTodosCabecalho;
var divRotina, frmCab, frmIndicador, frmVinculacao, divFormulario, divBotoes;

$(document).ready(function() {

	// Inicializando os seletores principais
	frmIndicador	= $('#frmIndicador');
	frmVinculacao	= $('#frmVinculacao');
	divRotina 		= $('#divTela', '#divAba0');				
	frmCab			= $('#frmCab');
	divFormulario	= $('#divFormulario');
	divBotoes		= $('#divBotoes', '#divAba0');
	
    estadoInicial();

    highlightObjFocus();

    return false;
});

function getAbaAtual() {
	return $('#divAba'+abaAtual);
}

function getForm() {
	return abaAtual === 0 ? frmIndicador : frmVinculacao;
}

function getDivFormulario() {
	return $('#divFormulario', getAbaAtual());
}

function getDivBotoes() {
	return $('#divBotoes', getAbaAtual());
}

function estadoInicial() {

    frmCab.css({'display': 'block'});
	frmIndicador.css({'display':'none'}).limpaFormulario();
	frmVinculacao.css({'display':'none'}).limpaFormulario();
	$("#btVoltar", getDivBotoes()).attr('onClick', "voltarCab();");				
	
    formataCabecalho();	
	//formataFormulario();
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
            obtemConsulta();
            return false;
        }
    });

    cCdcooper.unbind('changed').bind('changed', function(e) {
        obtemConsulta();
        return false;
    });
		
	if (cdcooper != 3){
		$('#btnOK', '#frmCab').click();		
	}
		
	layoutPadrao();
	return false;

}

function formataFormularioIndicadores() {
	var cTodos      = $('input',frmIndicador);		
	var rIdindica	= $('label[for="idindicador"]',frmIndicador);
	var rTpindica	= $('label[for="tpindicador"]',frmIndicador);
	var rCdprodut	= $('label[for="cdproduto"]',frmIndicador);
	var rInpessoa	= $('label[for="inpessoa"]',frmIndicador);
	var rVlminimo	= $('label[for="vlminimo"]',frmIndicador);	
	var rVlmaximo	= $('label[for="vlmaximo"]',frmIndicador);	
	var rPerscore	= $('label[for="perscore"]',frmIndicador);	
	var rPertoler	= $('label[for="pertolera"]',frmIndicador);	
	var rPerpeso	= $('label[for="perpeso"]',frmIndicador);	
	var rPerdesc	= $('label[for="perdesc"]',frmIndicador);	
		
	rIdindica.css('width', '100px').addClass('rotulo');
	rTpindica.css('width', '100px').addClass('rotulo-linha');
	rCdprodut.css('width', '100px').addClass('rotulo');
	rInpessoa.css('width', '100px').addClass('rotulo-linha');
	rVlminimo.css('width', '100px').addClass('rotulo');		
	rVlmaximo.css('width', '144px').addClass('rotulo-linha');		
	rPerscore.css('width', '100px').addClass('rotulo');		
	rPertoler.css('width', '144px').addClass('rotulo-linha');		
	rPerpeso.css('width', '100px').addClass('rotulo-linha');
	rPerdesc.css('width', '100px').addClass('rotulo-linha');
		
	// cTodos.desabilitaCampo();
	$('#idindicador', frmIndicador).addClass('codigo pesquisa').css({'width': '40px'});
	$('#nmindicador', frmIndicador).css({'width': '290px'});
	$('#idindicador', frmIndicador).css({'width': '100px'});
	$('#cdproduto', frmIndicador).addClass('codigo pesquisa').css({'width': '40px'});
	$('#dsproduto', frmIndicador).css({'width': '290px'});	
	$('#inpessoa', frmIndicador).css({'width': '100px'});	
	$('#vlminimo', frmIndicador).css({'width': '100px'});
	$('#vlmaximo', frmIndicador).css({'width': '100px'});
	$('#perpeso', frmIndicador).css({'width': '100px'});
	$('#perdesc', frmIndicador).css({'width': '100px'});
	
	if ($('#tpindicador', frmIndicador).val() == 'Q' ) {
		$('#vlminimo', frmIndicador).setMask('INTEGER','zzz.zzz.zzz.zz9');
		$('#vlmaximo', frmIndicador).setMask('INTEGER','zzz.zzz.zzz.zz9');
	}else if ($('#tpindicador', frmIndicador).val() == 'M' ){
		$('#vlminimo', frmIndicador).setMask('DECIMAL','zzz.zzz.zzz.zz9,99','.','');
		$('#vlmaximo', frmIndicador).setMask('DECIMAL','zzz.zzz.zzz.zz9,99','.','');
	}
	$('#perscore', frmIndicador).css({'width': '100px'}).setMask('DECIMAL','zz9,99','.','');
	$('#pertolera', frmIndicador).css({'width': '100px'}).setMask('DECIMAL','zz9,99','.','');
	$('#perpeso', frmIndicador).setMask('DECIMAL','zz9,99','.','');
	$('#perdesc', frmIndicador).setMask('DECIMAL','zz9,99','.','');
		
	$('#idindicador', frmIndicador).unbind('keydown').bind('keydown', function(e) {
		if ( e.keyCode == 13 || e.keyCode == 9 )  {
			controlaPesquisa('I');
			return false;
		}
	});
	
	$('#cdproduto', frmIndicador).unbind('keydown').bind('keydown', function(e) {
		if ( e.keyCode == 13 || e.keyCode == 9)  {
			controlaPesquisa('P');
			return false;
		}
	});
		
	$('#inpessoa', frmIndicador).unbind('keydown').bind('keydown', function(e) {
		if ( e.keyCode == 13 || e.keyCode == 9)  {
			if ($('#tpindicador').val() != 'A'){
				$('#vlminimo', frmIndicador).focus();
			}else{
				$('#perscore', frmIndicador).focus();
			}
			return false;
		}
	});
	
	$('#vlminimo', frmIndicador).unbind('keydown').bind('keydown', function(e) {
		if ( e.keyCode == 13 )  {			
			$('#vlmaximo', frmIndicador).focus();
			return false;
		}
	});
	
	$('#vlmaximo', frmIndicador).unbind('keydown').bind('keydown', function(e) {
		if ( e.keyCode == 13 )  {			
			$('#perscore', frmIndicador).focus();
			return false;
		}
	});
	
	$('#perscore', frmIndicador).unbind('keydown').bind('keydown', function(e) {
		if ( e.keyCode == 13 )  {
			if ($('#pertolera', frmIndicador).prop('disabled')){
				$("#btProsseguir", getDivBotoes()).click();
				return false;
			}else{
				$('#pertolera', frmIndicador).focus();
				return false;
			}
		}
	});
	
	$('#pertolera', frmIndicador).unbind('keydown').bind('keydown', function(e) {
		if ( e.keyCode == 13 )  {					
			$("#btProsseguir", getDivBotoes()).click();
			return false;
		}
	});
	
	layoutPadrao();
}

function formataFormularioVinculacao() {
	var cTodos        = $('input','#frmVinculacao');		
	var rIdVinculacao = $('label[for="idvinculacao"]','#frmVinculacao');
	var rCdprodut	  = $('label[for="cdproduto"]','#frmVinculacao');
	var rInpessoa	  = $('label[for="inpessoa"]','#frmVinculacao');
	var rPerpeso	  = $('label[for="perpeso"]','#frmVinculacao');
	var rPerdesc	  = $('label[for="perdesc"]','#frmVinculacao');
		
	rIdVinculacao.css('width', '100px').addClass('rotulo');
	rCdprodut.css('width', '100px').addClass('rotulo');
	rInpessoa.css('width', '100px').addClass('rotulo-linha');
	rPerpeso.css('width', '100px').addClass('rotulo');
	rPerdesc.css('width', '100px').addClass('rotulo-linha');
		
	// cTodos.desabilitaCampo();
	$('#idvinculacao', frmVinculacao).addClass('codigo pesquisa').css({'width': '40px'});
	$('#nmvinculacao', frmVinculacao).css({'width': '290px'});
	$('#cdproduto', frmVinculacao).addClass('codigo pesquisa').css({'width': '40px'});
	$('#dsproduto', frmVinculacao).css({'width': '290px'});	
	$('#inpessoa', frmVinculacao).css({'width': '100px'});	
	$('#perpeso', frmVinculacao).css({'width': '100px'}).setMask('DECIMAL','zz9,99','.','');
	$('#perdesc', frmVinculacao).css({'width': '100px'}).setMask('DECIMAL','zz9,99','.','');
		
	$('#idvinculacao', frmVinculacao).unbind('keydown').bind('keydown', function(e) {
		if ( e.keyCode == 13 || e.keyCode == 9 )  {
			controlaPesquisa('V');
			return false;
		}
	});
	
	$('#cdproduto', frmVinculacao).unbind('keydown').bind('keydown', function(e) {
		if ( e.keyCode == 13 || e.keyCode == 9)  {
			controlaPesquisa('P');
			return false;
		}
	});
		
	$('#inpessoa', frmVinculacao).unbind('keydown').bind('keydown', function(e) {
		if ( e.keyCode == 13 || e.keyCode == 9)  {
			$('#perpeso', frmVinculacao).focus();
			return false;
		}
	});

	$('#perpeso', frmVinculacao).unbind('keydown').bind('keydown', function(e) {
		if ( e.keyCode == 13 || e.keyCode == 9)  {
			$('#perdesc', frmVinculacao).focus();
			return false;
		}
	});
	
	$('#perdesc', frmVinculacao).unbind('keydown').bind('keydown', function(e) {
		if ( e.keyCode == 13 )  {					
			$("#btProsseguir", getDivBotoes()).click();
			return false;
		}
	});
	
	layoutPadrao();
}

function formataFormulario() {

	if (abaAtual === 0) {
		formataFormularioIndicadores();
	} else if (abaAtual === 1) {
		formataFormularioVinculacao();
	}

}

// Botao Voltar
function voltarCab() {
	if (cdcooper == 3){
		getForm().hide();
		getDivBotoes().hide();
		cTodosCabecalho.habilitaCampo();
	}
    return false;
}

function voltarTabela(){
	$('#btAlterar',getDivBotoes()).show();
	$('#btIncluir',getDivBotoes()).show();
	$('#btExcluir',getDivBotoes()).show();
	$('#btProsseguir',getDivBotoes()).hide();
	getForm().hide();
	getForm().limpaFormulario();
	getDivFormulario().show();
	$("#btVoltar", getDivBotoes()).attr('onClick', "voltarCab();");				
	return false;
}

function obtemConsulta() {
	
	// if ($('#cdcooper', '#frmCab').hasClass('campoTelaSemBorda')) {
    //     return false;
    // }
	
    var cdcooper = $('#cdcooper', '#frmCab').val();

    // Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, carregando informa&ccedil;&otilde;es ...");

    // Carrega conteúdo da opção através de ajax
    $.ajax({
        type: "POST",
        dataType: 'html',
        url: UrlSite + "telas/paridr/obtem_consulta.php",
        data: {
			indaba: abaAtual,
            cdcooper: cdcooper,
            redirect: "script_ajax" // Tipo de retorno do ajax
        },
        error: function(objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Ayllos", "");
        },
        success: function(response) {
            getDivFormulario().html(response).show();
			formataTabela();
			getDivBotoes().show();			
			hideMsgAguardo();
			cTodosCabecalho.desabilitaCampo();
		
		}

    });

    return false;

}

function formataTabela() {
	var divRotina   = $('#divTela', getAbaAtual());
	var divRegistro = $('div.divRegistros', divRotina );	
	var tabela      = $('table', divRegistro );

	divRegistro.css({'height':'200px','border-bottom':'1px dotted #777','padding-bottom':'2px'});	
	
	$('tr.sublinhado > td',divRegistro).css({'text-decoration':'underline'});	
	
	var ordemInicial = [],
		arrayLargura = [],
		arrayAlinha  = [];

	if (abaAtual === 0) {
		arrayLargura = ['60px','241px','65px','135px','54px','60px','60px','50px'];
		arrayAlinha = ['right','left','left','left','center','right','right','right','right'];
	} else if (abaAtual === 1) {
		arrayLargura = ['90px','165px','235px','145px','90px'];
		arrayAlinha = ['right','left','left','left','right','right'];
	}
	
	tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha, '' );
	
	// Seleciona primeiro indicador
	selecionaLinha('');
	
	$('table > tbody > tr', divRegistro).click( function() {
		selecionaLinha('');
	});	
	
	return false;
}

function selecionaLinha(opcao) {
    var flgSelected = false;

	var divRegistros = $('div.divRegistros', getAbaAtual());

	$('table > tbody > tr', divRegistros).each( function() {
		if ( $(this).hasClass('corSelecao') ) {
            flgSelected = true;
			
			if (opcao == 'A'){
				if (abaAtual === 0) {
					$('#idindicador', frmIndicador).val($('#idindicador', $(this)).val()); 
					$('#nmindicador', frmIndicador).val($('#nmindicador', $(this)).val()); 
					$('#tpindicador', frmIndicador).val($('#tpindicador', $(this)).val().substring(0, 1)); 
					$('#cdproduto', frmIndicador).val($('#cdproduto', $(this)).val()); 
					$('#dsproduto', frmIndicador).val($('#dsproduto', $(this)).val()); 
					$('#inpessoa', frmIndicador).val($('#inpessoa2', $(this)).val()); 
					$('#vlminimo', frmIndicador).val($('#vlminimo', $(this)).val()); 
					$('#vlmaximo', frmIndicador).val($('#vlmaximo', $(this)).val()); 
					$('#perscore', frmIndicador).val($('#perscore', $(this)).val()); 
					$('#pertolera', frmIndicador).val($('#pertolera', $(this)).val()); 
					$('#perpeso', frmIndicador).val($('#perpeso', $(this)).val());
					$('#perdesc', frmIndicador).val($('#perdesc', $(this)).val());
					$("#btProsseguir", getDivBotoes()).attr('onClick', "validaIndicador('A');");				
				} else if (abaAtual === 1) {
					$('#idvinculacao', frmVinculacao).val($('#idvinculacao', $(this)).val()); 
					$('#nmvinculacao', frmVinculacao).val($('#nmvinculacao', $(this)).val()); 
					$('#cdproduto', frmVinculacao).val($('#cdproduto', $(this)).val()); 
					$('#dsproduto', frmVinculacao).val($('#dsproduto', $(this)).val()); 
					$('#inpessoa', frmVinculacao).val($('#inpessoa2', $(this)).val()); 
					$('#perpeso', frmVinculacao).val($('#perpeso', $(this)).val());
					$('#perdesc', frmVinculacao).val($('#perdesc', $(this)).val());
					$("#btProsseguir", getDivBotoes()).attr('onClick', "validaVinculacao('A');");				
				}
				
							
			}else if(opcao == 'E'){
				if (abaAtual === 0) {
			    	showConfirmacao('Voc&ecirc; tem certeza que deseja excluir esta parametriza&ccedil;&atilde;o? A opera&ccedil;&atilde;o n&atilde;o poder&aacute; ser desfeita!', 'Confirma&ccedil;&atilde;o - Ayllos', 'excluirParametro(' + cCdcooper.val() + ',' + $("#idindicador", $(this)).val() + ',' + $('#cdproduto', $(this)).val() + ',' + $('#inpessoa2', $(this)).val() + ');', 'bloqueiaFundo(divRotina)', 'sim.gif', 'nao.gif');
				} else if (abaAtual === 1) {
					showConfirmacao('Voc&ecirc; tem certeza que deseja excluir esta parametriza&ccedil;&atilde;o? A opera&ccedil;&atilde;o n&atilde;o poder&aacute; ser desfeita!', 'Confirma&ccedil;&atilde;o - Ayllos', 'excluirParametro(' + cCdcooper.val() + ',' + $("#idvinculacao", $(this)).val() + ',' + $('#cdproduto', $(this)).val() + ',' + $('#inpessoa2', $(this)).val() + ');', 'bloqueiaFundo(divRotina)', 'sim.gif', 'nao.gif');
				}
			}
		}
		
	});

    if (! flgSelected && opcao == 'E') {
        showError("error", "Favor selecionar a parametriza&ccedil;&atilde;o que deseja excluir!", "Alerta - Ayllos", "");
    }
	
	// layoutPadrao();
	return false;
}

function trocaVisao(opcao) {

	$("#btVoltar", getDivBotoes()).attr('onClick', "voltarTabela();");				
	if (opcao == 'A'){
		if ( $('table > tbody > tr', 'div.divRegistros').hasClass('corSelecao') ) {
	        // Se a visão está na Tabela, então joga os valores para o formulário
			if ( getDivFormulario().css('display') == 'block' ) selecionaLinha(opcao);
			
			$('#btAlterar',getDivBotoes()).toggle();
			$('#btIncluir',getDivBotoes()).toggle();
			$('#btExcluir',getDivBotoes()).toggle();
			$('#btProsseguir',getDivBotoes()).toggle();
			getForm().toggle();
			getDivFormulario().toggle();

			$('#tpindicador', frmIndicador).prop('disabled', true);
			$('#cdproduto', getForm()).prop('disabled', true);
			$('#idvinculacao', frmVinculacao).prop('disabled', true);
			$('#inpessoa', frmIndicador).prop('disabled', true);				
			if ($('#tpindicador', frmIndicador).val() == 'A'){
				$('#vlminimo', frmIndicador).val(0);
				$('#vlmaximo', frmIndicador).val(0);
				$('#pertolera', frmIndicador).val(0);
				$('#perpeso', frmIndicador).val(0);
				$('#perdesc', frmIndicador).val(0);
				$('#vlminimo', frmIndicador).prop('disabled', true);
				$('#vlmaximo', frmIndicador).prop('disabled', true);
				$('#pertolera', frmIndicador).prop('disabled', true);
				$('#perpeso', frmIndicador).prop('disabled', true);
				$('#perdesc', frmIndicador).prop('disabled', true);
				$('#perscore', frmIndicador).focus();
			}else if ($('#tpindicador', frmIndicador).val() == 'Q' ) {
				$('#vlminimo', frmIndicador).prop('disabled', false);
				$('#vlmaximo', frmIndicador).prop('disabled', false);
				$('#pertolera', frmIndicador).prop('disabled', false);				
				$('#perpeso', frmIndicador).prop('disabled', false);				
				$('#perdesc', frmIndicador).prop('disabled', false);				
				$('#vlminimo', frmIndicador).setMask('INTEGER','zzz.zzz.zzz.zz9');
				$('#vlmaximo', frmIndicador).setMask('INTEGER','zzz.zzz.zzz.zz9');
				$('#vlminimo', frmIndicador).focus();
			}else{
				$('#vlminimo', frmIndicador).prop('disabled', false);
				$('#vlmaximo', frmIndicador).prop('disabled', false);
				$('#pertolera', frmIndicador).prop('disabled', false);				
				$('#perpeso', frmIndicador).prop('disabled', false);				
				$('#perdesc', frmIndicador).prop('disabled', false);				
				$('#vlminimo', frmIndicador).setMask('DECIMAL','zzz.zzz.zzz.zz9,99','.','');
				$('#vlmaximo', frmIndicador).setMask('DECIMAL','zzz.zzz.zzz.zz9,99','.','');
				$('#vlminimo', frmIndicador).focus();
			}			
			
		}
	}else{
		$('#btAlterar',getDivBotoes()).toggle();
		$('#btIncluir',getDivBotoes()).toggle();
		$('#btExcluir',getDivBotoes()).toggle();
		$('#btProsseguir',getDivBotoes()).toggle();
		getForm().toggle();
		getDivFormulario().toggle();
		
		$('#tpindicador', frmIndicador).focus();
		$('#tpindicador', frmIndicador).prop('disabled', false);
		$('#cdproduto', frmIndicador).prop('disabled', false);
		$('#inpessoa', frmIndicador).prop('disabled', false);
		$('#vlminimo', frmIndicador).prop('disabled', false);
		$('#vlmaximo', frmIndicador).prop('disabled', false);
		$('#pertolera', frmIndicador).prop('disabled', false);
		$('#perpeso', frmIndicador).prop('disabled', false);
		$('#perdesc', frmIndicador).prop('disabled', false);
		$("#btProsseguir", getDivBotoes()).attr('onClick', (abaAtual === 0) ? "validaIndicador('I');" : "validaVinculacao('I');");	
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
        showError("error", "Favor selecionar um registro para a devida altera&ccedil;&atilde;o!", "Alerta - Ayllos", "");
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
                        showError('error', 'Não foi possível concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'estadoInicial();');
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
function mostrarPesquisaIndicadores() {
	if ($('#idindicador', '#frmIndicador').prop("disabled")) {
		return false;
}
    //Definição dos filtros
	var filtros = "ID;idindicador;50px;N;;N;|Indicador;nmindicador;200px;S;;S;descricao|Tipo;tpindica;50px;N;;N;|Tipo2;tpindicador;50px;N;;N;";
    //Campos que serão exibidos na tela
	var colunas = 'ID;idindicador;10%;right|Indicador;nmindicador;65%;left|Tipo;tpindica;25%;left|Tipo2;tpindicador;0%;;;N';
    //Exibir a pesquisa
	mostraPesquisa("TELA_PARIDR", "PESQUISA_INDICADORES", "Indicadores", "50", filtros, colunas, divRotina, 'controlaPesquisa("I");');
	$("#divCabecalhoPesquisa > table > thead > tr").append("<td style='width: 18px'>");
}

// Função para abrir a pesquisa de vinculacoes
function mostrarPesquisaVinculacoes() {
	if ($('#idvinculacao', '#frmVinculacao').prop("disabled")) {
		return false;
}
    //Definição dos filtros
	var filtros = "ID;idvinculacao;50px;N;;N;|Vinculacao;nmvinculacao;200px;S;;S;descricao";
    //Campos que serão exibidos na tela
	var colunas = 'ID;idvinculacao;10%;right|Vinculacao;nmvinculacao;65%;left';
    //Exibir a pesquisa
	mostraPesquisa("TELA_PARIDR", "PESQUISA_VINCULACOES", "Vinculacoes", "50", filtros, colunas, divRotina, 'controlaPesquisa("V");');
	$("#divCabecalhoPesquisa > table > thead > tr").append("<td style='width: 18px'>");
}

// Função para abrir a pesquisa de produtos
function mostrarPesquisaProdutos() {
	if ($('#cdproduto', getForm()).prop("disabled")) {
		return false;
	}
    //Definição dos filtros
	var filtros = "Código;cdproduto;50px;N;;N;|Produto;dsproduto;200px;S;;S;descricao";
    //Campos que serão exibidos na tela
	var colunas = 'Código;cdproduto;20%;right|Produto;dsproduto;80%;left';
    //Exibir a pesquisa
	mostraPesquisa("TELA_PARIDR", "PESQUISA_PRODUTOS", "Produtos", "50", filtros, colunas, divRotina, 'controlaPesquisa("P")',abaAtual === 0 ? 'frmIndicador' : 'frmVinculacao');
	$("#divCabecalhoPesquisa > table > thead > tr").append("<td style='width: 18px'>");
}

function controlaPesquisa(tipo){
	if (tipo == 'I'){
		consultaIndicador();
		
		$('#vlminimo', frmIndicador).val('0');
		$('#vlmaximo', frmIndicador).val('0');
		$('#pertolera', frmIndicador).val('0');
		$('#perpeso', frmIndicador).val('0');
		$('#perdesc', frmIndicador).val('0');
		
		$('#cdproduto', frmIndicador).focus();
		
		return false;
	}else if (tipo == 'V'){
		consultaVinculacao();
		
		$('#perpeso', frmVinculacao).val('0');
		$('#perdesc', frmVinculacao).val('0');
		
		$('#cdproduto', frmVinculacao).focus();
		
		return false;
	}else if (tipo == 'P'){
		consultaProduto();
		if (abaAtual === 0) {
			if ($('#inpessoa', frmIndicador).prop('disabled')){
				if ($('#tpindicador', frmIndicador) != 'A'){
					$('#vlminimo', frmIndicador).focus();
				}else{
					$('#perscore', frmIndicador).focus();
				}
			}else{
				$('#inpessoa', frmIndicador).focus();			
			}		
		} else if (abaAtual === 1) {
			$('#inpessoa', frmVinculacao).focus();			
		}
		
		return false;
	}
	
}

function consultaIndicador(){

	var idindica = $('#idindicador', frmIndicador).val();

    if (idindica != '') {

        showMsgAguardo('Aguarde, consultando indicador ...');

	    // Gera requisição ajax para validar o indicador
        $.ajax({
            type: 'POST',
	        dataType: 'html',
	        url: UrlSite + 'telas/paridr/valida_indicador.php',
	        data:
	            {
	            cddopcao: cddopcao,
	            idindica: idindica,
	            redirect: 'script_ajax'
                },
            error : function(objAjax, responseError, objExcept) {
                hideMsgAguardo();
                showError('error', 'N&atilde;o foi possível concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'estadoInicial();');
            },
            success : function(response) {
                        hideMsgAguardo();
                        eval(response);
                        if ($('#tpindicador', frmIndicador).val() == 'Q' ) {
                            $('#vlminimo', frmIndicador).setMask('INTEGER','zzz.zzz.zzz.zz9');
                            $('#vlmaximo', frmIndicador).setMask('INTEGER','zzz.zzz.zzz.zz9');
                            $('#vlminimo', frmIndicador).prop('disabled', false);
                            $('#vlmaximo', frmIndicador).prop('disabled', false);
                            $('#pertolera', frmIndicador).prop('disabled', false);								
                            $('#perpeso', frmIndicador).prop('disabled', false);								
                            $('#perdesc', frmIndicador).prop('disabled', false);								
                        }else if ($('#tpindicador', frmIndicador).val() == 'M' ){
                            $('#vlminimo', frmIndicador).setMask('DECIMAL','zzz.zzz.zzz.zz9,99','.','');
                            $('#vlmaximo', frmIndicador).setMask('DECIMAL','zzz.zzz.zzz.zz9,99','.','');
                            $('#vlminimo', frmIndicador).prop('disabled', false);
                            $('#vlmaximo', frmIndicador).prop('disabled', false);
                            $('#pertolera', frmIndicador).prop('disabled', false);				
                            $('#perpeso', frmIndicador).prop('disabled', false);				
                            $('#perdesc', frmIndicador).prop('disabled', false);				
                        }else{
                            $('#vlminimo', frmIndicador).prop('disabled', true);
                            $('#vlmaximo', frmIndicador).prop('disabled', true);
                            $('#pertolera', frmIndicador).prop('disabled', true);				
                            $('#perpeso', frmIndicador).prop('disabled', true);				
                            $('#perdesc', frmIndicador).prop('disabled', true);				

                        }					

                    }
        });
    }
	
	return false;

}

function consultaProduto() {

	var cdproduto = $('#cdproduto.pesquisa',getAbaAtual()).val();

    if (cdproduto != '') {

        showMsgAguardo('Aguarde, consultando produto ...');

        // Gera requisição ajax para validar o indicador
        $.ajax({
            type: 'POST',
            dataType: 'html',
            url: UrlSite + 'telas/paridr/valida_produto.php',
            data: {
				cddopcao: cddopcao,
				cdproduto: cdproduto,
				redirect: 'script_ajax'
			},
            error: function (objAjax, responseError, objExcept) {
                hideMsgAguardo();
                showError('error', 'Não foi possível concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'estadoInicial();');
            },
            success: function (response) {
                hideMsgAguardo();
                eval(response);
            }
        });
    }

    return false;

}

function consultaVinculacao() {

	var idvinculacao = $('#idvinculacao.pesquisa',frmVinculacao).val();

    if (idvinculacao != '') {

        showMsgAguardo('Aguarde, consultando vinculacao ...');

        // Gera requisição ajax para validar o indicador
        $.ajax({
            type: 'POST',
            dataType: 'html',
            url: UrlSite + 'telas/paridr/valida_vinculacao.php',
            data: {
				cddopcao: cddopcao,
				idvinculacao: idvinculacao,
				redirect: 'script_ajax'
			},
            error: function (objAjax, responseError, objExcept) {
                hideMsgAguardo();
                showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'estadoInicial();');
            },
            success: function (response) {
                hideMsgAguardo();
                eval(response);
            }
        });
    }

    return false;

}

function limpaIndicador(){
	
	$('#idindicador', getAbaAtual()).focus(); 
	$('#idindicador', getAbaAtual()).val("");
	$('#nmindicador', getAbaAtual()).val("");
	
}

function limpaProduto(){
	
	$('#cdproduto', getAbaAtual()).focus(); 
	$('#cdproduto', getAbaAtual()).val("");
	$('#dsproduto', getAbaAtual()).val("");
	
}

function limpaVinculacao(){
	
	$('#idvinculacao', frmVinculacao).focus(); 
	$('#idvinculacao', frmVinculacao).val("");
	$('#nmvinculacao', frmVinculacao).val("");
	
}

function validaIndicador(opcao){
	
	var vlminimo, vlmaximo, perscore, pertolera;
	
	vlminimo = $('#vlminimo', frmIndicador).val().replace(/\./g,"");	
	vlminimo = new Number(vlminimo.replace(",","."));		
	vlmaximo = $('#vlmaximo', frmIndicador).val().replace(/\./g,"");		
	vlmaximo = new Number(vlmaximo.replace(",","."));			
	perscore = new Number($('#perscore', frmIndicador).val().replace(",","."));		
	pertolera = new Number($('#pertolera', frmIndicador).val().replace(",","."));
	perpeso = new Number($('#perpeso', frmIndicador).val().replace(",","."));
	perdesc = new Number($('#perdesc', frmIndicador).val().replace(",","."));
	
	if (opcao == 'I'){
		if (!$('#tpindicador', frmIndicador).val()){		
			showError('error','Todos os campos s&atilde;o obrigat&oacute;rios, favor preench&ecirc;-los!','Alerta - Ayllos','$("#tpindicador", frmIndicador).focus();');
			return false;
		}
		if (!$('#cdproduto', frmIndicador).val()){		
			showError('error','Todos os campos s&atilde;o obrigat&oacute;rios, favor preench&ecirc;-los!','Alerta - Ayllos','$("#cdproduto", frmIndicador).focus();');
			return false;
		}
		if (!$('#inpessoa', frmIndicador).val()){		
			showError('error','Todos os campos s&atilde;o obrigat&oacute;rios, favor preench&ecirc;-los!','Alerta - Ayllos','$("#inpessoa", frmIndicador).focus();');
			return false;
		}
	}
	if ($('#tpindicador', frmIndicador).val() != 'A'){
		if (!$('#vlminimo', frmIndicador).val()){
			showError('error','Todos os campos s&atilde;o obrigat&oacute;rios, favor preench&ecirc;-los!','Alerta - Ayllos','$("#vlminimo", frmIndicador).focus();');
			return false;
		}else{
			if (vlminimo <= 0 || vlminimo > vlmaximo){
				showError('error','Valor M&iacute;nimo inv&aacute;lido! Favor informar um valor superior a 0(zero) e inferior ao Valor M&aacute;ximo!','Alerta - Ayllos','$("#vlminimo", frmIndicador).focus();');
				return false;			
			}
		}
		if (!$('#vlmaximo', frmIndicador).val()){
			showError('error','Todos os campos s&atilde;o obrigat&oacute;rios, favor preench&ecirc;-los!','Alerta - Ayllos','$("#vlmaximo", frmIndicador).focus();');
			return false;
		}else{
			if (vlmaximo <= 0 || vlmaximo < vlminimo){
				showError('error','Valor M&iacute;nimo inv&aacute;lido! Favor informar um valor superior a 0(zero) e inferior ao Valor M&aacute;ximo!','Alerta - Ayllos','$("#vlminimo", frmIndicador).focus();');
				return false;			
			}
		}
		if (pertolera > 100 || pertolera < 0){
			showError('error','Percentuais informados devem estar na faixa de 0,00% a 100,00%!','Alerta - Ayllos','$("#pertolera", frmIndicador).focus();');
			return false;					
		}
	}
	if (perscore > 100 || perscore < 0 || perpeso > 100 || perpeso < 0){
		showError('error','Percentuais informados devem estar na faixa de 0,00% a 100,00%!','Alerta - Ayllos','$("#perscore", frmIndicador).focus();');
		return false;					
	}
	
	if (opcao == 'I'){
		showConfirmacao('Voc&ecirc; tem certeza de que deseja gravar esta parametriza&ccedil;&atilde;o?', 'Confirma&ccedil;&atilde;o - Ayllos', 'inserirParametro();', 'bloqueiaFundo(divRotina)', 'sim.gif', 'nao.gif');
	} else if (opcao == 'A') {
		showConfirmacao('Voc&ecirc; tem certeza de que deseja gravar esta parametriza&ccedil;&atilde;o?', 'Confirma&ccedil;&atilde;o - Ayllos', 'alterarParametro();', 'bloqueiaFundo(divRotina)', 'sim.gif', 'nao.gif');
	}
	
}

function validaVinculacao(opcao){
	
	var perpeso = new Number($('#perpeso', frmVinculacao).val().replace(",","."));
	var perdesc = new Number($('#perdesc', frmVinculacao).val().replace(",","."));
	
	if (opcao == 'I'){
		if (!$('#cdproduto', frmVinculacao).val()){		
			showError('error','Todos os campos s&atilde;o obrigat&oacute;rios, favor preench&ecirc;-los!','Alerta - Ayllos','$("#cdproduto", frmVinculacao).focus();');
			return false;
		}
		if (!$('#inpessoa', frmVinculacao).val()){		
			showError('error','Todos os campos s&atilde;o obrigat&oacute;rios, favor preench&ecirc;-los!','Alerta - Ayllos','$("#inpessoa", frmVinculacao).focus();');
			return false;
		}
	}

	if (perpeso > 100 || perpeso < 0){
		showError('error','Percentuais informados devem estar na faixa de 0,00% a 100,00%!','Alerta - Ayllos','$("#perpeso", frmVinculacao).focus();');
		return false;					
	}
	
	if (opcao == 'I'){
		showConfirmacao('Voc&ecirc; tem certeza de que deseja gravar esta parametriza&ccedil;&atilde;o?', 'Confirma&ccedil;&atilde;o - Ayllos', 'inserirParametro();', 'bloqueiaFundo(divRotina)', 'sim.gif', 'nao.gif');
	} else if (opcao == 'A') {
		showConfirmacao('Voc&ecirc; tem certeza de que deseja gravar esta parametriza&ccedil;&atilde;o?', 'Confirma&ccedil;&atilde;o - Ayllos', 'alterarParametro();', 'bloqueiaFundo(divRotina)', 'sim.gif', 'nao.gif');
	}
	
}

function inserirIndicador() {
	showMsgAguardo('Aguarde, inserindo parametro...');	
	
	var cdcooper = cCdcooper.val();
	var idindica = $('#idindicador', frmIndicador).val();
	var cdprodut = $('#cdproduto', frmIndicador).val();
	var inpessoa = $('#inpessoa', frmIndicador).val();
	var vlminimo = $('#vlminimo', frmIndicador).val().replace(/\./g,"");	
		vlminimo = vlminimo.replace(",",".");		
	var vlmaximo = $('#vlmaximo', frmIndicador).val().replace(/\./g,"");		
		vlmaximo = vlmaximo.replace(",",".");		
	var perscore = $('#perscore', frmIndicador).val().replace(",",".");
	var pertoler = $('#pertolera', frmIndicador).val().replace(",",".");
	var perpeso = $('#perpeso', frmIndicador).val().replace(",",".");
	var perdesc = $('#perdesc', frmIndicador).val().replace(",",".");
	
	$.ajax({		
		type: 'POST',
		dataType: 'script',
		url: UrlSite + 'telas/paridr/insere_param_indicador.php', 
		data: { 
			cdcooper: cdcooper,
			idindica: idindica,
			cdprodut: cdprodut,
			inpessoa: inpessoa,
			vlminimo: vlminimo,
			vlmaximo: vlmaximo,
			perscore: perscore,
			pertoler: pertoler,
			perpeso: perpeso,
			perdesc: perdesc,
			redirect: 'script_ajax'
		},
		error   : function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError('error', 'N&atilde;o foi possível concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', '');
		},
		success: function(response) {
			hideMsgAguardo();
			eval(response);
		} 
	}); 
}

function inserirVinculacao() {
	showMsgAguardo('Aguarde, inserindo parametro...');	
	
	var cdcooper = cCdcooper.val();
	var idvinculacao = $('#idvinculacao', frmVinculacao).val();
	var cdprodut = $('#cdproduto', frmVinculacao).val();
	var inpessoa = $('#inpessoa', frmVinculacao).val();
	var perpeso = $('#perpeso', frmVinculacao).val().replace(",",".");
	var perdesc = $('#perdesc', frmVinculacao).val().replace(",",".");
	
	$.ajax({		
		type: 'POST',
		dataType: 'script',
		url: UrlSite + 'telas/paridr/insere_param_vinculacao.php', 
		data: { 
			cdcooper: cdcooper,
			idvinculacao: idvinculacao,
			cdprodut: cdprodut,
			inpessoa: inpessoa,
			perpeso: perpeso,
			perdesc: perdesc,
			redirect: 'script_ajax'
		},
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError('error', 'N&atilde;o foi possível concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', '');
		},
		success: function(response) {
			hideMsgAguardo();
			eval(response);
		} 
	}); 
}

function inserirParametro(){

	if (abaAtual === 0) {
		inserirIndicador();
	} else if (abaAtual === 1) {
		inserirVinculacao();
	}
	
	return false;
}

function alterarIndicador() {
	
	showMsgAguardo('Aguarde, alterando parametro...');	
	
	var cdcooper = cCdcooper.val();
	var idindica = $('#idindicador', frmIndicador).val();
	var cdprodut = $('#cdproduto', frmIndicador).val();
	var inpessoa = $('#inpessoa', frmIndicador).val();
	var vlminimo = $('#vlminimo', frmIndicador).val().replace(/\./g,"");
		vlminimo = vlminimo.replace(",",".");		
	var vlmaximo = $('#vlmaximo', frmIndicador).val().replace(/\./g,"");
		vlmaximo = vlmaximo.replace(",",".");		
	var perscore = $('#perscore', frmIndicador).val().replace(",",".");
	var pertoler = $('#pertolera', frmIndicador).val().replace(",",".");
	var perpeso = $('#perpeso', frmIndicador).val().replace(",",".");
	var perdesc = $('#perdesc', frmIndicador).val().replace(",",".");
	
	$.ajax({		
		type: 'POST',
		dataType: 'script',
		url: UrlSite + 'telas/paridr/altera_param_indicador.php', 
		data: { 
			cdcooper: cdcooper,
			idindica: idindica,
			cdprodut: cdprodut,
			inpessoa: inpessoa,
			vlminimo: vlminimo,
			vlmaximo: vlmaximo,
			perscore: perscore,
			pertoler: pertoler,
			perpeso: perpeso,
			perdesc: perdesc,
			redirect: 'script_ajax'
		},
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError('error', 'N&atilde;o foi possível concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', '');
		},
		success: function(response) {
			hideMsgAguardo();
			eval(response);
		} 
	}); 
	
	return false;
}

function alterarVinculacao() {
	showMsgAguardo('Aguarde, alterando parametro...');	
	
	var cdcooper = cCdcooper.val();
	var idvinculacao = $('#idvinculacao', frmVinculacao).val();
	var cdprodut = $('#cdproduto', frmVinculacao).val();
	var inpessoa = $('#inpessoa', frmVinculacao).val();
	var perpeso = $('#perpeso', frmVinculacao).val().replace(",",".");
	var perdesc = $('#perdesc', frmVinculacao).val().replace(",",".");
	
	$.ajax({		
		type: 'POST',
		dataType: 'script',
		url: UrlSite + 'telas/paridr/altera_param_vinculacao.php', 
		data: { 
			cdcooper: cdcooper,
			idvinculacao: idvinculacao,
			cdprodut: cdprodut,
			inpessoa: inpessoa,
			perpeso: perpeso,
			perdesc: perdesc,
			redirect: 'script_ajax'
		},
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError('error', 'N&atilde;o foi possível concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', '');
		},
		success: function(response) {
			hideMsgAguardo();
			eval(response);
		} 
	}); 
	
	return false;
}

function alterarParametro(){

	if (abaAtual === 0) {
		alterarIndicador();
	} else if (abaAtual === 1) {
		alterarVinculacao();
	}
	
	return false;
}

function excluirIndicador(cdcooper,id,cdprodut,inpessoa) {
	showMsgAguardo('Aguarde, excluindo parametro...');	
		
	$.ajax({		
		type: 'POST',
		dataType: 'script',
		url: UrlSite + 'telas/paridr/exclui_param_indicador.php', 
		data: { 
			cdcooper: cdcooper,
			idindica: id,
			cdprodut: cdprodut,
			inpessoa: inpessoa,
			redirect: 'script_ajax'
		},
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError('error', 'Não foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', '');
		},
		success: function(response) {
			hideMsgAguardo();
			eval(response);
		} 
	}); 
	
	return false;
}

function excluirVinculacao(cdcooper,id,cdprodut,inpessoa) {
	showMsgAguardo('Aguarde, excluindo parametro...');	
		
	$.ajax({
		type: 'POST',
		dataType: 'script',
		url: UrlSite + 'telas/paridr/exclui_param_vinculacao.php',
		data: { 
			cdcooper: cdcooper,
			idvinculacao: id,
			cdprodut: cdprodut,
			inpessoa: inpessoa,
			redirect: 'script_ajax'
		},
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError('error', 'Não foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', '');
		},
		success: function(response) {
			hideMsgAguardo();
			eval(response);
		} 
	}); 
	
	return false;
}

function excluirParametro(cdcooper,id,cdprodut,inpessoa){

	if (abaAtual === 0) {
		excluirIndicador(cdcooper, id, cdprodut, inpessoa);
	} else if (abaAtual === 1) {
		excluirVinculacao(cdcooper, id, cdprodut, inpessoa);
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

	obtemConsulta();

	formataFormulario();
}