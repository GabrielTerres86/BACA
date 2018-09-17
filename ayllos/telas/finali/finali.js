/*!
 * FONTE        : finali.js
 * CRIAÇÃO      : André Santos / SUPERO
 * DATA CRIAÇÃO : 15/08/2013
 * OBJETIVO     : Biblioteca de funções - Tela FINALI
 * --------------
 * ALTERACOES   : 10/08/2015 - Alterações e correções (Lunelli SD 102123)
 * --------------
 */

var cddopcao;
var cdfinemp;
var dsfinemp;

var frmCab = 'frmCab';
var frmFinali = 'frmFinali';
var tabDados = 'tabFinali';

var arrayRegLinha = new Array();
var arrayLinhasCred = new Array();

//Labels/Campos do cabeçalho
var rCddopcao, rCdfinemp, rDsfinemp, rDssitfin, rCddlinha, rCdlcremp,
    cCddopcao, cCdfinemp, cDsfinemp, cDssitfin, cCddlinha, cCdlcremp, cDslcremp, cTodosCabecalho, btnCab;
	
// Inicio
$(document).ready(function() {
    estadoInicial();
    highlightObjFocus($('#' + frmCab));    
    return false;
});

// Formatação
function estadoInicial() {
	
	cddopcao = 'C';
	cdfinemp = 0;
	dsfinemp = '';

    hideMsgAguardo();
    unblockBackground();
    $('#divTela').fadeTo(0, 0.1)
    removeOpacidade('divTela');
    formataCabecalho();

    $('#' + frmCab).css({'display': 'block'});
    $('#divBotoes', '#divTela').css({'display': 'none'});
    $('#divPesquisaRodape').remove();

    $('#cddopcao', '#' + frmCab).habilitaCampo();
    $('#cddopcao', '#' + frmCab).focus();
	
    cCddopcao.val(cddopcao);
    cCdfinemp.val(cdfinemp);
    cDsfinemp.val(dsfinemp);

    $('#cdfinemp', '#' + frmCab).desabilitaCampo();
    $('#dsfinemp', '#' + frmCab).desabilitaCampo();

    // Removendo Classe de Erro
    $('input,select', '#' + frmCab).removeClass('campoErro');
	$('#divResultado').html('');
    controlaFoco();
}

function formataCabecalho() {

    // Labels
    rCddopcao = $('label[for="cddopcao"]', '#' + frmCab);
    rCdfinemp = $('label[for="cdfinemp"]', '#' + frmCab);
    rDsfinemp = $('label[for="dsfinemp"]', '#' + frmCab);
    rDssitfin = $('label[for="dssitfin"]', '#frmFinali');
    rCdlcremp = $('label[for="cdlcremp"]', '#frmFinali');

    // Campos
    cCddopcao = $('#cddopcao', '#' + frmCab);
    cCdfinemp = $('#cdfinemp', '#' + frmCab);
    cDsfinemp = $('#dsfinemp', '#' + frmCab);
    cDssitfin = $('#dssitfin', '#frmFinali');
    cCdlcremp = $('#cdlcremp', '#frmFinali');
    cDslcremp = $('#dslcremp', '#frmFinali');
	
    cTodosCabecalho = $('input[type="text"],select', '#' + frmCab);
    btnCab = $('#btOK', '#' + frmCab);

    rCddopcao.css('width', '105px');
    rCdfinemp.addClass('rotulo-linha').css({'width': '105px'});
    rDsfinemp.addClass('rotulo-linha').css({'width': '82px'});
    rDssitfin.addClass('rotulo').css({'width': '100px'});
    rCdlcremp.addClass('rotulo').css({'width': '110px'});
	
    cCddopcao.css({'width': '350px'});
    cCdfinemp.addClass('inteiro').css({'width': '50px'}).setMask('INTEGER','zzz','/.-','');
    cDsfinemp.addClass('campo').css({'width': '213px'}).attr('maxlength', '29');
    cDssitfin.addClass('campo').css({'width': '170px'});
	cCdlcremp.addClass('campo').css({'width': '70px'}).attr('maxlength', '4').setMask('INTEGER','zzzz','/.-','');
    cDslcremp.addClass('campo').css({'width': '250px'});
	
	highlightObjFocus($('#' + frmFinali));
	
    layoutPadrao();
    return false;
}

function formataTabela() {
	
	var divRegistro = $('div.divRegistros', '#'+tabDados);		
	var cddopcao 	= $('#cddopcao', '#' + frmCab).val();
	var tabela      = $('table', divRegistro );
	
	$('#'+tabDados).css({'margin-top':'5px'});
	divRegistro.css({'height':'205px','padding-bottom':'2px'});

	var ordemInicial = new Array();
	
	var arrayLargura = new Array();
	if (cddopcao == "I" || cddopcao == "D"){
		arrayLargura[0] = '35px';
		arrayLargura[1] = '127px';
	} else {
		arrayLargura[0] = '127px';
	}
	
	var arrayAlinha = new Array();
	if (cddopcao == "I" || cddopcao == "D"){
		arrayAlinha[0] = 'center';
		arrayAlinha[1] = 'center';
		arrayAlinha[2] = 'left';
	} else {
		arrayAlinha[0] = 'center';
		arrayAlinha[1] = 'left';
	}
	
	tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha, '' );	
	
	if (cddopcao == "I" || cddopcao == "D"){
		$("th:eq(0)", tabela).removeClass();
		$("th:eq(0)", tabela).unbind('click');
		
		// Adiciona função que ao selecionar o checkbox header, marca/desmarca todos os checkboxs da tabela
		 $("input[type=checkbox][name='checkTodos']").unbind('click').bind('click', function (){
			var selec = this.checked;
			$("input[type=checkbox][name='cdsqelcr[]']").prop("checked", selec );
		});
	}
	
	return false;
}

function controlaLayout() {
    
	var cddopcao = $('#cddopcao', '#' + frmCab).val();
	
	formataCabecalho();
	formataTabela();
	
	cDsfinemp.val(dsfinemp);		
	cDssitfin.desabilitaCampo();
	
	if (cddopcao == "C") {
		$('#btSalvar', '#divBotoes').hide();
		$('#btVoltar', '#divBotoes').focus();
	}
	if (cddopcao == "A") {
		trocaBotao('btnAlterarFinali()', 'Alterar');		
		cDsfinemp.habilitaCampo();
		cDsfinemp.focus();
	} else 
	if (cddopcao == "B" || 
	    cddopcao == "L") {
		if (cddopcao == "B") {
			trocaBotao('btnBloqueLibera()', 'Bloquear');
		} else {
			trocaBotao('btnBloqueLibera()', 'Liberar');
		}
		$('#btSalvar', '#divBotoes').focus();		
	} else 
	if (cddopcao == "I") {
	    cDslcremp.desabilitaCampo();
        trocaBotao('btnIncluirFinali()', 'Incluir');
	   
	    //Nova Finalidade
	    if  ($('#tbRegLinhaCred tbody tr').length < 1 && dsfinemp == '') {			
	 		cDssitfin.val("LIBERADA");  //Defaut para novas Finalidades
 			cDsfinemp.habilitaCampo(); 			
			cDsfinemp.focus();
	    } else {
			cCdlcremp.focus();
		}
	} else 
	if (cddopcao == "E") {
        trocaBotao('btnExcluirFinali()', 'Excluir');
		$('#btSalvar', '#divBotoes').focus();		
	} else 
	if (cddopcao == "D") {
        trocaBotao('btnExcluirLcrFinali()', 'Excluir Linhas de Cr&eacute;dito');
		$('#btSalvar', '#divBotoes').focus();
	}
	
	controlaFoco();	
    return false;
}

function LiberaCampos() {
	
    if (cCddopcao.hasClass('campoTelaSemBorda')) { return false; }
		
    trocaBotao('btnContinuar()', 'Prosseguir');
	
    cCddopcao.desabilitaCampo();
    cCdfinemp.habilitaCampo();
    cCdfinemp.val('').focus();    	
    $('#divBotoes', '#divTela').css({'display': 'block'});
	
    return false;
}

function trocaBotao(funcao, botao) {

    $('#divBotoes', '#divTela').html('');
    $('#divBotoes', '#divTela').append('<a href="#" class="botao" id="btVoltar" onclick="btnVoltar(); return false;" >Voltar</a>&nbsp;');
	
    if (botao != '') {
        $('#divBotoes', '#divTela').append('<a href="#" class="botao" id="btSalvar" onclick="' + funcao + '; return false;" >' + botao + '</a>');
    }
    return false;
}

function controlaPesquisaLcr() {

	if ($("#cdlcremp","#frmFinali").prop("disabled") == true)  { return; }
	
	var campoAnterior = '';
	var bo, procedure, titulo, qtReg, filtros, colunas, cdlcremp, titulo_coluna, dslcremp;	
	
	$('input,select', '#frmFinali').removeClass('campoErro');
	
	cdlcremp = $('#cdlcremp','#frmFinali').val();		
	titulo_coluna = "Linhas de Credito";	
	bo			= 'b1wgen0167.p'; 
	procedure	= 'lista-linha-credito';
	titulo      = 'Linhas de Credito';
	qtReg		= '20';
	filtros 	= 'Codigo;cdlcremp;80px;S;' + cdlcremp + ';S|Descricao;dslcremp;280px;S;' + dslcremp + ';S';
	colunas 	= 'Codigo;cdlcremp;20%;right|' + titulo_coluna + ';dslcremp;50%;left';
	mostraPesquisa(bo,procedure,titulo,qtReg,filtros,colunas,$('#divTela'),'$(\'#cdlcremp\',\'#frmFinali\').val()');
	
	return false;
}

// Botoes
function btnVoltar() {	
    $('#divResultado').css({'display': 'none'});
    estadoInicial();
    return false;
}

function btnContinuar() {	
    ConsultaDados(1,100);
    return false;
}

function btnBloqueLibera() {
    showConfirmacao('Confirma Opera&ccedil;&atilde;o?', "Confirma&ccedil;&atilde;o - Ayllos", 'bloqueiaLiberaFinali();', '$("#divResultado").css({"display":"none"});estadoInicial();', "sim.gif", "nao.gif");
    return false;
}

function btnAlterarFinali() {
    showConfirmacao('Confirma Opera&ccedil;&atilde;o?', "Confirma&ccedil;&atilde;o - Ayllos", 'alterarFinali();', '$("#divResultado").css({"display":"none"});estadoInicial();', "sim.gif", "nao.gif");
    return false;
}

function btnIncluirFinali() {
    showConfirmacao('Confirma Opera&ccedil;&atilde;o?', "Confirma&ccedil;&atilde;o - Ayllos", 'incluirFinali();', '$("#divResultado").css({"display":"none"});estadoInicial();', "sim.gif", "nao.gif");
    return false;
}

function btnExcluirFinali() {
    showConfirmacao('Excluir Finalidade?', "Confirma&ccedil;&atilde;o - Ayllos", 'excluirFinali();', '$("#divResultado").css({"display":"none"});estadoInicial();', "sim.gif", "nao.gif");
    return false;
}

function btnExcluirLcrFinali() {
    showConfirmacao('Excluir Linha(s) de Credito?', "Confirma&ccedil;&atilde;o - Ayllos", 'excluirLcrFinali();', '$("#divResultado").css({"display":"none"});estadoInicial();', "sim.gif", "nao.gif");
    return false;
}

function controlaFoco() {
	
    $('#cddopcao', '#' + frmCab).unbind('keypress').bind('keypress', function(e) {
        if (e.keyCode == 9 || e.keyCode == 13) {        
			LiberaCampos();
			return false;
        }
    });

    $('#cdfinemp', '#' + frmCab).unbind('keypress').bind('keypress', function(e) {
        if (e.keyCode == 9 || e.keyCode == 13) {

			$('#dsfinemp', '#' + frmCab).desabilitaCampo();			
			btnContinuar();
			
            return false;
        }
    });

    $('#dsfinemp', '#' + frmCab).unbind('keypress').bind('keypress', function(e) {
        if (e.keyCode == 9 || e.keyCode == 13) {
            if ($('#cddopcao', '#' + frmCab).val() == 'I') {
               cCdlcremp.focus();
            } else
            if ($('#cddopcao', '#' + frmCab).val() == 'A') {
                $('#btSalvar', '#divBotoes').focus();
            }
            return false;
        }
    });
		
	cCdlcremp.unbind('keypress').bind('keypress', function(e) {		
        if (e.keyCode == 9 || e.keyCode == 13) {			
			if (cCdlcremp.val() == ''){
				$('#btSalvar', '#divBotoes').focus();
			} else {
				buscaLinhaCred(cCdlcremp.val());				
				$('#btInserir', '#frmFinali').focus();
			}
            return false;
        }
    });
	
	if ( $.browser.msie ) {
		cCdlcremp.unbind('change').bind('change', function(e) {		
		   if (e.keyCode != 13) {			   
			   if (cCdlcremp.val() == ''){
				   $('#btSalvar', '#divBotoes').focus();
				} else {
					buscaLinhaCred(cCdlcremp.val());					
					$('#btInserir', '#frmFinali').focus();
				}
		   }
		});
	}
	
    $('#btSalvar', '#divBotoes').unbind('keypress').bind('keypress', function(e) {
        if (e.keyCode == 9 || e.keyCode == 13) {
            if ($('#cddopcao', '#' + frmCab).val() == 'C') { // Consultar
                btnContinuar();
            } else
            if ($('#cddopcao', '#' + frmCab).val() == 'B') { // Bloquear
                btnBloqueLibera();
            } else
            if ($('#cddopcao', '#' + frmCab).val() == 'L') { // Liberar
                btnBloqueLibera();
            } else
            if ($('#cddopcao', '#' + frmCab).val() == 'A') { // Alterar
                btnAlterarFinali();
            } else
            if ($('#cddopcao', '#' + frmCab).val() == 'I') { // Incluir
                btnIncluirFinali();
            } else
            if ($('#cddopcao', '#' + frmCab).val() == 'E') { // Excluir
                btnExcluirFinali();
            } else
			if ($('#cddopcao', '#' + frmCab).val() == 'D') { // Excluir
                btnExcluirLcrFinali();
            }
            return false;
        }
    });

    $('#btSalvar', '#divBotoes').unbind('click').bind('click', function() {
        return false;
    });
}

// Operações
function ConsultaDados(nriniseq, nrregist) {

	var cddopcao = $('#cddopcao', '#' + frmCab).val();
    var cdfinemp = $('#cdfinemp', '#' + frmCab).val();
	
	if (cddopcao == "I" || cddopcao == "D") {
		
		if ($.trim(cdfinemp) == '' || cdfinemp == 0) {
			hideMsgAguardo();
			showError("error","Insira o c&oacute;digo da Finalidade.","Alerta - Ayllos",'focaCampoErro(\'cdfinemp\',\''+ frmCab +'\');');
			return false;				
		}	
		
		arrayLinhasCred  = new Array();
		arrayRegLinha = new Array();
	}
	
    showMsgAguardo("Aguarde, buscando registros...");

	$.ajax({
		type: "POST",
		url: UrlSite + "telas/finali/consulta_finali.php", 
		data: {
			cddopcao: cddopcao,
			cdfinemp: cdfinemp,
			nriniseq: nriniseq,
			nrregist: nrregist,
			redirect: "script_ajax"
		}, 
		error: function(objAjax,responseError,objExcept) {			
			hideMsgAguardo();
			showError('error', 'N&atilde;o foi possível concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'estadoInicial();');
		},
		success: function(response) {
            hideMsgAguardo();	
			
			if ( response.indexOf('showError("error"') == -1 && 
				 response.indexOf('XML error:') == -1 && 
				 response.indexOf('#frmErro') == -1 ) {
				try {					
					$('input,select', '#' + frmCab).removeClass('campoErro');
					$('#divResultado').css({'display': 'block'});
					$('#cdfinemp', '#' + frmCab).desabilitaCampo();
					
					$('#divResultado').html(response);
					controlaLayout();
				} catch(error) {									
					showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'estadoInicial();');
				}
			} else {
				try {
					eval(response);
                    return false;						
				} catch(error) {			
					showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'estadoInicial();');
				}
			}		
        }
    });
    return false;
}

function bloqueiaLiberaFinali() {

    var cddopcao = $('#cddopcao', '#' + frmCab).val();
    var cdfinemp = $('#cdfinemp', '#' + frmCab).val();
	
	if (cddopcao == 'B') {
		showMsgAguardo("Aguarde, bloqueando registro...");
	} else {			
		showMsgAguardo("Aguarde, liberando registro...");
	}

    $.ajax({
        type: 'POST',
        url: UrlSite + 'telas/finali/bloqueia_libera_finali.php',
        dataType: 'html',
        data: {
			cddopcao: cddopcao,
			cdfinemp: cdfinemp,
			redirect: 'script_ajax'
		},
        error: function(objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'estadoInicial();');
        },
        success: function(response) {            
			hideMsgAguardo();
			
			if ( response.indexOf('showError("error"') == -1 && 
				 response.indexOf('XML error:') == -1 && 
				 response.indexOf('#frmErro') == -1 ) {					 
				try {					
					showError('inform', response, 'Alerta - Ayllos', 'btnContinuar();');
				} catch(error) {									
					showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'estadoInicial();');
				}
			} else {
				try {			
					eval(response);
                    return false;						
				} catch(error) {			
					showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'estadoInicial();');
				}
			}
        }
    });
    return false;
}

function alterarFinali() {

	var cddopcao = $('#cddopcao', '#' + frmCab).val();
    var cdfinemp = $('#cdfinemp', '#' + frmCab).val();
    var dsfinemp = $('#dsfinemp', '#' + frmCab).val();
	
	showMsgAguardo("Aguarde, alterando registro...");

    $.ajax({
        type: 'POST',
        url: UrlSite + 'telas/finali/alterar_finali.php',
        dataType: 'html',
        data: {
			cddopcao: cddopcao,
			cdfinemp: cdfinemp,
			dsfinemp: dsfinemp,
			redirect: 'script_ajax'
		},
        error: function(objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'estadoInicial();');
        },
        success: function(response) {
            hideMsgAguardo();
			
			if ( response.indexOf('showError("error"') == -1 && 
				 response.indexOf('XML error:') == -1 && 
				 response.indexOf('#frmErro') == -1 ) {
					 
				try {					
					showError('inform', 'Registro atualizado com sucesso', 'Alerta - Ayllos', '$("#divResultado").css({"display":"none"});estadoInicial();');
				} catch(error) {
					showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'estadoInicial();');
				}
			} else {
				try {			
					eval(response);
                    return false;						
				} catch(error) {			
					showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'estadoInicial();');
				}
			}
        }
    });
    return false;
}

function buscaLinhaCred(cdlcremp) {
    
	if (cdlcremp == '' || cdlcremp == 0){ return false }
	
	var cddopcao = $('#cddopcao', '#' + frmCab).val();
	
	showMsgAguardo("Aguarde, buscando linha de cr&eacute;dito...");	

    $.ajax({
        type: 'POST',
        url: UrlSite + 'telas/finali/consulta_linha_credito.php',
        dataType: 'html',
        data: {			
			cddopcao: cddopcao,
			cdlcremp: cdlcremp,
			redirect: 'script_ajax'
		},
        error: function(objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'estadoInicial();');
        },
        success: function(response) {
            hideMsgAguardo();
			
			if ( response.indexOf('showError("error"') == -1 && 
				 response.indexOf('XML error:') == -1 && 
				 response.indexOf('#frmErro') == -1 ) {					 
				try {					
					cDslcremp.val(response);
				} catch(error) {									
					showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message, "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')))");
				}
			} else {
				try {			
					eval(response);
                    return false;						
				} catch(error) {			
					showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'estadoInicial();');
				}
			}
        }
    });
    return false;
}

function btnInserirLcr(cdlcremp, dslcremp) {
	
	var existe = false;		
	for (var i in arrayRegLinha) {
	  if (cdlcremp == arrayRegLinha[i]['cdlcrhab']){ existe = true; break; }
	}
	
	if (cdlcremp == '' ||
		existe == true ||
		dslcremp == '' ||
		dslcremp == 'NAO ENCONTRADO') {
		cCdlcremp.val('').focus();
		cDslcremp.val('');
		return false 
	}
		
	var qtdLinhas = $('#tbRegLinhaCred tbody tr').length; // Quantitdade total de linhas da tabela
	var corLinha  = (qtdLinhas%2 === 0) ? 'corImpar' : 'corPar';
	
	// Criar a linha na tabela
	$("#tbRegLinhaCred > tbody")
		.prepend($('<tr>') // Linha
			.attr('id',cdlcremp)
			.attr('class',corLinha)
			.append($('<td>')
				.attr('style','width: 35px; text-align:center')
				.append($('<input>')
					.attr('type','checkbox')
					.attr('name','cdsqelcr[]')
					.attr('id','cdsqelcr')
					.attr('value',arrayRegLinha.length)
				)
			)
			.append($('<td>')
				.attr('style','width: 127px; text-align:center')
				.text(cdlcremp)
				.append($('<input>')
					.attr('type','hidden')
					.attr('name','cdlcremp')
					.attr('id','cdlcremp')
					.attr('value',cdlcremp)
				)
			)
			.append($('<td>')
				.attr('style','text-align:left')
				.text(dslcremp)
				.append($('<input>')
					.attr('type','hidden')
					.attr('name','dslcremp')
					.attr('id','dslcremp')
					.attr('value',dslcremp)
				)
			)
		);
	
	var aux = new Array();
	aux['cdlcrhab'] = cdlcremp;
	arrayRegLinha[arrayRegLinha.length] = aux;
		
	zebradoLinhaTabela($('#tbRegLinhaCred > tbody > tr'));
	
	$('#nrregistros', '#divPesquisaRodape').html('Exibindo 1 at&eacute ' + (qtdLinhas+1) + ' de ' + (qtdLinhas+1));
	
	cCdlcremp.val('').focus();
	cDslcremp.val('');
}

function incluirFinali() {

	var cddopcao = $('#cddopcao', '#' + frmCab).val();
    var cdfinemp = $('#cdfinemp', '#' + frmCab).val();
    var dsfinemp = $('#dsfinemp', '#' + frmCab).val();
	var camposDc = '';
	var dadosDc  = '';

    $('input,select', '#frmFinali').removeClass('campoErro');
	
	showMsgAguardo("Aguarde, incluindo Finalidade...");	
	
	//Adquire as informações das checkbox selecionadas
	$('#cdsqelcr','#tbRegLinhaCred').each(function() {	
		if ($(this).prop('checked')) {			
			arrayLinhasCred[arrayLinhasCred.length] = arrayRegLinha[$(this).val()];
		}
	});
	
	//Verifica se alguma linha de crédito foi selecionada
	if (arrayLinhasCred.length == 0) {
		hideMsgAguardo();
		showError("error","Nenhuma linha de cr&eacute;dito selecionada.","Alerta - Ayllos","unblockBackground(); $('#btSalvar', '#divBotoes').focus();");
		return false;				
	}
	
	// Verifica se há de descrição para Finalidade
	if ($.trim(dsfinemp) == '') {
		hideMsgAguardo();
		showError("error","Insira descri&ccedil;&atilde;o da Finalidade.","Alerta - Ayllos",'focaCampoErro(\'dsfinemp\',\''+ frmCab +'\');');
		return false;				
	}	
	
	camposDc  = retornaCampos( arrayLinhasCred, '|' );
	dadosDc   = retornaValores( arrayLinhasCred, ';', '|',camposDc );
	    
    $.ajax({
        type: 'POST',
        url: UrlSite + 'telas/finali/incluir_finali.php',
        dataType: 'html',
        data: {
			cddopcao: cddopcao,
			cdfinemp: cdfinemp,
			dsfinemp: dsfinemp,
			camposDc: camposDc,
			dadosDc	: dadosDc,
			redirect: 'script_ajax'
		},
        error: function(objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'estadoInicial();');
        },
        success: function(response) {
            hideMsgAguardo();
			
			if ( response.indexOf('showError("error"') == -1 && 
				 response.indexOf('XML error:') == -1 && 
				 response.indexOf('#frmErro') == -1 ) {					 
				try {					
					showError('inform', 'Registro adicionado com sucesso', 'Alerta - Ayllos', '$("#divResultado").css({"display":"none"});estadoInicial();');
				} catch(error) {									
					showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message, "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')))");
				}
			} else {
				try {			
					eval(response);
                    return false;						
				} catch(error) {			
					showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'estadoInicial();');
				}
			}
        }
    });
	
    return false;
}

function excluirFinali() {

	var cddopcao = $('#cddopcao', '#' + frmCab).val();
    var cdfinemp = $('#cdfinemp', '#' + frmCab).val();
	
	showMsgAguardo("Aguarde, excluindo finalidade...");	

    $.ajax({
        type: 'POST',
        url: UrlSite + 'telas/finali/excluir_finali.php',
        dataType: 'html',
        data:{
			cddopcao: cddopcao,
			cdfinemp: cdfinemp,
			redirect: 'script_ajax'
		},
        error: function(objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'estadoInicial();');
        },
        success: function(response) {
            hideMsgAguardo();
			
			if ( response.indexOf('showError("error"') == -1 && 
				 response.indexOf('XML error:') == -1 && 
				 response.indexOf('#frmErro') == -1 ) {
					 
				try {					
					showError('inform', 'Registro exclu&iacute;do com sucesso', 'Alerta - Ayllos', '$("#divResultado").css({"display":"none"});estadoInicial();');
				} catch(error) {
					showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message, "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')))");
				}
			} else {
				try {			
					eval(response);
                    return false;						
				} catch(error) {			
					showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'estadoInicial();');
				}
			}
        }
    });
    return false;
}

function excluirLcrFinali() {

	var cddopcao = $('#cddopcao', '#' + frmCab).val();
    var cdfinemp = $('#cdfinemp', '#' + frmCab).val();  
	var camposDc = '';
	var dadosDc  = '';

    $('input,select', '#frmFinali').removeClass('campoErro');
	
	showMsgAguardo("Aguarde, eliminando Linhas de Cr&eacute;dito da Finalidade...");	
	
	//Adquire as informações das checkbox selecionadas
	$('#cdsqelcr','#tbRegLinhaCred').each(function() {	
		if ($(this).prop('checked')) {			
			arrayLinhasCred[arrayLinhasCred.length] = arrayRegLinha[$(this).val()];
		}
	});
	
	//Verifica se alguma linha de crédito foi selecionada
	if (arrayLinhasCred.length == 0) {
		hideMsgAguardo();
		showError("error","Nenhuma linha de cr&eacute;dito selecionada.","Alerta - Ayllos","unblockBackground(); $('#btSalvar', '#divBotoes').focus();");
		return false;				
	}
	
	camposDc  = retornaCampos( arrayLinhasCred, '|' );
	dadosDc   = retornaValores( arrayLinhasCred, ';', '|',camposDc );
	    
    $.ajax({
        type: 'POST',
        url: UrlSite + 'telas/finali/excluir_lcr_finali.php',
        dataType: 'html',
        data: {
			cddopcao: cddopcao,			
			cdfinemp: cdfinemp,			
			camposDc: camposDc,
			dadosDc	: dadosDc,
			redirect: 'script_ajax'
		},
        error: function(objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'estadoInicial();');
        },
        success: function(response) {
            hideMsgAguardo();
			
			if ( response.indexOf('showError("error"') == -1 && 
				 response.indexOf('XML error:') == -1 && 
				 response.indexOf('#frmErro') == -1 ) {
					 
				try {					
					showError('inform', 'V&iacute;nculo eliminado com sucesso', 'Alerta - Ayllos', '$("#divResultado").css({"display":"none"});estadoInicial();');
				} catch(error) {
					showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message, "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')))");
				}
			} else {
				try {			
					eval(response);
                    return false;						
				} catch(error) {			
					showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'estadoInicial();');
				}
			}
        }
    });
	
    return false;
}
