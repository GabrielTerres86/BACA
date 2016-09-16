/*!
 * FONTE        : DEVOLU.php
 * CRIAÇÃO      : Andre Santos - SUPERO
 * DATA CRIAÇÃO : 25/09/2013
 * OBJETIVO     : Mostrar tela DEVOLU
 * --------------
 * ALTERAÇÕES   : #273953 Alinhamento das colunas das tabelas (Carlos)
 *
 *                12/07/2016 #451040 Retirar o botão "Executar Devolução" (Carlos)
 *
 * --------------
 */

// Definição de algumas variáveis globais
var nrdconta  =  0 ;
var nmprimtl  =  '';
var selecBan  =  0 ; // Guarda o selecao do banco selecionado.
var dsbccxlt;
var banco;
var cdcooper;
var nrdocmto;
var alinea;
var nrdctitg;
var cdbanchq;
var cdagechq;
var cddsitua;
var nrdrecid;
var vllanmto;
var nrctachq;
var nmoperad;
var flag;

// Formulários
var frmCab   	= 'frmCab';
    frmDevolu   = 'frmDevolu';

// Labels/Campos do Cabeçalho
var rNmprimtl, rNrdconta,
    cNmprimtl, cNrdconta, cTodosCabecalho, btnCab;

// Labels/Campos de Opcoes de Banco
var rCddopcao,
    cCddopcao;

// Labels/Campos de Alinea
var rCdalinea,
    cCdalinea;


// Inicio
$(document).ready(function() {
	estadoInicial();
	highlightObjFocus( $('#'+frmCab) );
    return false;
});


// Seletores
function estadoInicial() {

    // Preparando a Tela
    hideMsgAguardo();
    unblockBackground();
    removeOpacidade('divTela');
	formataCabecalho();

	// Limpa HTML
	$('#divResultado').html('');
	$('#divConteudo').html('');
	$('#divRotina').html('');
	$('#divConteudoSenha').html('');
	$('#divConteudoAlinea').html('');
	$('#divRegistros').html('');

	$('#'+frmCab).css({'display':'block'});
    $('#divBotoes', '#divTela').css({'display':'block'});
	$('#divResultado').css({'display':'none'});
	$('#divPesquisaRodape').remove();

	// Inicializa Variaveis do Cabeçalho
	cNrdconta.val( nrdconta );
	cNmprimtl.val( nmprimtl );
	$('#nrdconta','#'+frmCab).habilitaCampo();
	$('#nrdconta','#'+frmCab).select();
	trocaBotao('Prosseguir','btnContinuar();');
	$('#btVoltar','#divBotoes').hide();

    // Desabilita Campos
	$('#nmprimtl','#'+frmCab).desabilitaCampo();

	$('input,select','#'+frmCab).removeClass('campoErro');
    controlaFoco();
}


// Formata Cabeçalho Principal
function formataCabecalho() {

	// Labels
	rNrdconta		= $('label[for="nrdconta"]','#'+frmCab);
	rNmprimtl       = $('label[for="nmprimtl"]','#'+frmCab);

    // Campos
	cNrdconta		= $('#nrdconta','#'+frmCab);
	cNmprimtl       = $('#nmprimtl','#'+frmCab);
	cTodosCabecalho	= $('input[type="text"],select','#'+frmCab);

	//Rótulos
	rNrdconta.addClass('rotulo-linha').css({'width':'80px'});
    rNmprimtl.addClass('rotulo-linha').css({'width':'0px'});

    // Campos
	cNrdconta.css({'width':'83px'});
    cNmprimtl.css({'width':'350px'});

	layoutPadrao();
	return false;
}

// Formata a exibicao dos campos na tela
function formataBanco() {

	highlightObjFocus($('#frmBanco'));

	rCddopcao 	= $('label[for="cddopcao"]','#frmBanco');
	cCddopcao	= $('#cddopcao', '#frmBanco');

	rCddopcao.addClass('rotulo-linha').css({'width':'50px'});
	cCddopcao.css({'width':'230px'});

	$('#divConteudo').css({'width':'300px', 'height':'110px'});

	// centraliza a divRotina
	$('#divRotina').css({'width':'425px'});
	$('#divConteudo').css({'width':'300px'});
	$('#divRotina').centralizaRotinaH();

	hideMsgAguardo();
	bloqueiaFundo( $('#divRotina') );
	cCddopcao.focus();

	return false;
}

// Formata a exibicao dos campos na tela
function formataSenhaSistema() {
    highlightObjFocus($('#frmSenha'));

	rCodsenha 	= $('label[for="cddsenha"]','#frmSenha');
	cCodsenha	= $('#cddsenha', '#frmSenha');

	rCodsenha.addClass('rotulo-linha').css({'width':'50px'});
	cCodsenha.css({'width':'120px'});

	$('#divConteudoSenha').css({'width':'220px', 'height':'110px'});

	// centraliza a divRotina
	$('#divRotina').css({'width':'300px'});
	$('#divConteudo').css({'width':'220px'});
	$('#divRotina').centralizaRotinaH();

	hideMsgAguardo();
	bloqueiaFundo( $('#divRotina') );
	cCodsenha.focus();

	return false;
}

// Formata a exibicao dos campos na tela
function formataSenhaCoord() {

	highlightObjFocus($('#frmSenhaCoord'));

	rOperador 	= $('label[for="operauto"]', '#frmSenhaCoord');
	rSenha		= $('label[for="codsenha"]', '#frmSenhaCoord');

	rOperador.addClass('rotulo').css({'width':'165px'});
	rSenha.addClass('rotulo').css({'width':'165px'});

	cOperador	= $('#operauto', '#frmSenhaCoord');
	cSenha		= $('#codsenha', '#frmSenhaCoord');

	cOperador.addClass('campo').css({'width':'100px'}).attr('maxlength','10');
    cSenha.addClass('campo').css({'width':'100px'}).attr('maxlength','10');

	$('#divConteudoSenha').css({'width':'400px', 'height':'120px'});

	// centraliza a divRotina
	$('#divRotina').css({'width':'425px'});
	$('#divConteudoSenha').css({'width':'400px'});
	$('#divRotina').centralizaRotinaH();

	hideMsgAguardo();
	bloqueiaFundo( $('#divRotina') );
	cOperador.focus();

	return false;
}

// Formata a exibicao dos campos na tela
function formataAlinea() {

    highlightObjFocus($('#frmAlinea'));

	rCdalinea 	= $('label[for="cdalinea"]','#frmAlinea');
	cCdalinea	= $('#cdalinea', '#frmAlinea');

	rCdalinea.addClass('rotulo-linha').css({'width':'125px'});
	cCdalinea.addClass('inteiro').css({'width':'30px'}).attr('maxlength','3');

	$('#divConteudoAlinea').css({'width':'220px', 'height':'110px'});

	// centraliza a divRotina
	$('#divRotina').css({'width':'300px'});
	$('#divConteudoAlinea').css({'width':'220px'});
	$('#divRotina').centralizaRotinaH();

	hideMsgAguardo();
	bloqueiaFundo( $('#divRotina') );
	cCdalinea.focus();

	return false;
}


// Controle dos Campos
function controlaFoco() {

	$('#nrdconta','#'+frmCab).unbind('keypress').bind('keypress', function(e) {
        if ( e.keyCode == 9 || e.keyCode == 13 ) {
            $('#nrdconta','#'+frmCab).desabilitaCampo();
			btnContinuar();
            return false;
        }else {// Seta máscara ao campo
            return $('#nrdconta','#'+frmCab).setMask('INTEGER','zzzz.zzz-z','.-','');
        }
	});

	$('#btSalvar','#divBotoes').unbind('keypress').bind('keypress', function(e) {
        if ( e.keyCode == 9 || e.keyCode == 13 ) {
			$('#nrdconta','#'+frmCab).desabilitaCampo();
		    BuscaDevolu(1,30);
			return false;
        }
	});

	$('#btSalvar','#divBotoes').unbind('click').bind('click', function(){
		$('#nrdconta','#'+frmCab).desabilitaCampo();
	    return false;
	});
}


// Controle de Botoes
function trocaBotao( botao , funcao ) {
	$('#divBotoes','#divTela').html('');
	$('#divBotoes','#divTela').append('<a href="#" class="botao" id="btVoltar" onclick="btnVoltar(); return false;" >Voltar</a>&nbsp;');

	if (botao != '') {
		$('#divBotoes','#divTela').append('<a href="#" class="botao" id="btSalvar" onclick=' + funcao + ' return false;" >' + botao + '</a>');
	}
	return false;
}


// Botoes
function btnVoltar() {
    estadoInicial();
	return false;
}

// Botao Principal
function btnContinuar() {
   BuscaDevolu(1,30);
   return false;
}

// Botao Executa as Devolucoes
function ExecutaDevolucao() {
    mostraBanco();
    return false;
}

// Botao Devolver Cheque
function Devolver() {
    marcar_cheque_devolu();
    return false;
}

// Botao Auxiliar - Devolver Cheque
function proc_gera_dev() {
    showConfirmacao('Confirma Opera&ccedil;&atilde;o?',"Confirma&ccedil;&atilde;o - Ayllos",'verifica_alinea();','fechaRotina($("#divRotina"));',"sim.gif","nao.gif");
    return false;
}


// Busca Dados do Associado
function BuscaDevolu(nriniseq, nrregist) {

    var nrdconta = $('#nrdconta','#'+frmCab).val().replace(".", "").replace("-", "");

    showMsgAguardo("Aguarde, buscando devolu&ccedil;&otilde;es...");

    $.ajax({
        type	: 'POST',
        url		: UrlSite + 'telas/devolu/principal.php',
        dataType: 'html',
        data    :
                {
                    nrdconta : nrdconta,
					nriniseq : nriniseq,
				    nrregist : nrregist,
                    redirect : 'script_ajax'
                },
        error   : function(objAjax,responseError,objExcept) {
                    hideMsgAguardo();
                    showError('error','N&atilde;o foi possível concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','estadoInicial();');
                },
        success : function(response) {
            try {
                if ( response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1 ) {
                    try {
                        $('input,select','#'+frmCab).removeClass('campoErro');
						$('#divResultado').html('');
						$('#divResultado').html(response);
						cNmprimtl.val($('#nmprimtl','#'+frmDevolu).val());
						if (nrdconta == 0) {
                            formataTabelaDevolu();
                        } else {
							formataTabelaLancto();
                        }
					} catch(error) {
                        hideMsgAguardo();
                        showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','');
                    }
                } else {
                    try {
                        eval(response);
						$('#nrdconta','#'+frmCab).habilitaCampo();
                        return false;
                    } catch(error) {
                        hideMsgAguardo();
                        showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','estadoInicial();');
                    }
                }
            } catch(error) {
                showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message,"Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
                hideMsgAguardo();
            }
        }
    });

    return false;
}


// Formata Browse da Tela
function formataTabelaDevolu() {

	// Tabela
	$('#tabDevoluDados').css({'display':'block'});
    $('#divResultado').css({'display':'block'});

    var divRegistro = $('div.divRegistros', '#tabDevoluDados');
	var tabela      = $('table', divRegistro );
	var linha       = $('table > tbody > tr', divRegistro );

    $('#tabDevoluDados').css({'margin-top':'5px'});
	divRegistro.css({'height':'250px','width':'650px','padding-bottom':'2px'});

	$('#divRegistrosRodape','#divConsulta').formataRodapePesquisa();
	
	var ordemInicial = new Array();

	var arrayLargura = new Array();
    arrayLargura[0] = '33px'; //bco
	arrayLargura[1] = '33px'; //age
	arrayLargura[2] = '62px'; //cta
	arrayLargura[3] = '65px'; //chq
	arrayLargura[4] = '65px'; //
	arrayLargura[5] = '60px';
	arrayLargura[6] = '60px';
//	arrayLargura[7] = '255px'; //operador (deixar livre p preencher com espaco restante)

    var arrayAlinha = new Array();
	arrayAlinha[0] = 'center';
    arrayAlinha[1] = 'center';
	arrayAlinha[2] = 'right';
	arrayAlinha[3] = 'right';
	arrayAlinha[4] = 'right';
	arrayAlinha[5] = 'center';
	arrayAlinha[6] = 'center';
	arrayAlinha[7] = 'left';

	tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha, '' );
	hideMsgAguardo();
    	
    $('#btSalvar','#divBotoes').hide();  
  
    $('#btVoltar','#divBotoes').show();
	$('#btVoltar','#divBotoes').focus();

	return false;
}

function formataTabelaLancto() {

	// Tabela
    $('#tabDevoluConta').css({'display':'block'});
    $('#divResultado').css({'display':'block'});

    var divRegistro = $('div.divRegistros', '#tabDevoluConta');
	var tabela      = $('table', divRegistro );
	var linha       = $('table > tbody > tr', divRegistro );

    $('#tabDevoluConta').css({'margin-top':'5px'});
	divRegistro.css({'height':'180px','width':'650px','padding-bottom':'2px'});

	var ordemInicial = new Array();
		
	var arrayLargura = new Array();
	
    arrayLargura[0] = '100px'; //banco
	arrayLargura[1] = '40px';  //ag
	arrayLargura[2] = '60px';  //cheque/doc
	arrayLargura[3] = '60px';  //valor
	arrayLargura[4] = '60px';  //situacao
	arrayLargura[5] = '55px';  //alinea
	
//    arrayLargura[6] = '260px'; //operador (deixar livre p preencher com espaco restante)

	var arrayAlinha = new Array();
	arrayAlinha[0] = 'center';
	arrayAlinha[1] = 'center';
	arrayAlinha[2] = 'right';
    arrayAlinha[3] = 'right';
	arrayAlinha[4] = 'center';
	arrayAlinha[5] = 'center';	
	arrayAlinha[6] = 'left';


	tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha, '' );
	hideMsgAguardo();
    trocaBotao('Devolver','Devolver();'); //label e funcao

	/********************
	  EVENTO COMPLEMENTO
	*********************/

    // seleciona o registro que é clicado
	$('table > tbody > tr', divRegistro).click( function() {
		selecionaTabela($(this));
	});

    // seleciona o registro que é focado
	$('table > tbody > tr', divRegistro).focus( function() {
		selecionaTabela($(this));
	});

	$('table > tbody > tr:eq(0)', divRegistro).click();
	return false;
}

function selecionaTabela(tr) {
	cdcooper = $('#cdcooper', tr).val();
    dsbccxlt = $('#dsbccxlt', tr).val();
    banco = $('#banco', tr).val();
    nrdocmto = $('#nrdocmto', tr).val();
    nrdctitg = $('#nrdctitg', tr).val();
	cdbanchq = $('#cdbanchq', tr).val();
    cdagechq = $('#cdagechq', tr).val();
	cddsitua = $('#cddsitua', tr).val();
    nrdrecid = $('#nrdrecid', tr).val();
    vllanmto = $('#vllanmto', tr).val();
    nrctachq = $('#nrctachq', tr).val();
	alinea   = $('#cdalinea', tr).val();
    nmoperad = $('#nmoperad', tr).val();
    flag     = $('#flag', tr).val();
    return false;
}

// Processo de Devolucao - Por Conta
function marcar_cheque_devolu() {

	showMsgAguardo('Aguarde, verificando horario de execucao...');

	$.ajax({
		type    : 'POST',
		dataType: 'html',
		url     : UrlSite + 'telas/devolu/marcar_cheque_devolu.php',
		data    :
                {
                    dsbccxlt : dsbccxlt,
                    cdcooper : cdcooper,
                    nrdocmto : nrdocmto,
                    nrdctitg : nrdctitg,
                    cdbanchq : cdbanchq,
                    cdagechq : cdagechq,
                    cddsitua : cddsitua,
                    nrdrecid : nrdrecid,
                    vllanmto : vllanmto,
                    flag     : flag,
                    redirect: 'script_ajax'
                },
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError('error','Não foi possível concluir a requisição.','Alerta - Ayllos',"unblockBackground();");
		},
		success: function(response) {
			try {
				hideMsgAguardo();
				eval(response);
			   // Solicitado pela Pamela para não pedir mais a senha do coordenador após as 11:30
               // if(execucao == 'yes'){
                   // if(pedsenha == 'yes'){ // Mostra campo de senha para o coordenador autorizar a devolução
                   //     showError('inform',dscritic,'Alerta - Ayllos','mostraSenhaCoord();');
						//showError('error',dscritic,'Alerta - Ayllos',"unblockBackground();");
                   // }else {
                   //     showError('inform',dscritic,'Alerta - Ayllos','estadoInicial();');
                  //  }
               // }else{				   
                    verifica_folha_cheque();
               // }

			} catch(error) {
				hideMsgAguardo();
				showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message,"Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
			}
		}
	});

	return false;
}

// Processo de Devolucao - Por Conta
// Senha - Autorizacao do Coordenador
function mostraSenhaCoord() {

	showMsgAguardo('Aguarde, abrindo...');

	// Executa script de confirmação através de ajax
	$.ajax({
		type    : 'POST',
		dataType: 'html',
		url     : UrlSite + 'telas/devolu/senha_coord.php',
		data    :
                {
                    redirect: 'html_ajax'
                },
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError('error','Não foi possível concluir a requisição.','Alerta - Ayllos',"unblockBackground()");
		},
		success: function(response) {
			$('#divRotina').html(response);
			buscaSenhaCoord();
			return false;
		}
	});

	return false;
}

// Chamada de Formulário de Senha - Autorizacao do Coordenador
function buscaSenhaCoord() {

	hideMsgAguardo();
	showMsgAguardo('Aguarde, abrindo ...');

	$.ajax({
		type    : 'POST',
		dataType: 'html',
		url     : UrlSite + 'telas/devolu/form_senha_coord.php',
		data    :
                {
                    redirect: 'script_ajax'
                },
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError('error','Não foi possível concluir a requisição.','Alerta - Ayllos',"unblockBackground();");
		},
		success: function(response) {
			if ( response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1 ) {
				try {
                    $('input,select','#'+frmCab).removeClass('campoErro');
					$('#divConteudoSenha').html(response);
					exibeRotina($('#divRotina'));
					formataSenhaCoord();

					$('#codsenha','#frmSenhaCoord').unbind('keypress').bind('keypress', function(e) {
						if ( e.keyCode == 13 || e.keyCode == 9 ) {
							validarSenha();
							return false;
						}
					});

					return false;
				} catch(error) {
					hideMsgAguardo();
					showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','unblockBackground()');
				}
			} else {
				try {
					eval( response );
				} catch(error) {
					hideMsgAguardo();
					showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','unblockBackground()');
				}
			}
		}
	});

	return false;
}

// Processo de Devolucao - Por Conta
function validarSenha() {

	hideMsgAguardo();

	// Situacao
	var operauto 	= $('#operauto','#frmSenhaCoord').val();
	var codsenha 	= $('#codsenha','#frmSenhaCoord').val();

    showMsgAguardo( 'Aguarde, validando dados...' );

	$.ajax({
        type    : 'POST',
		async   : true ,
		url     : UrlSite + 'telas/devolu/valida_senha.php',
		data    :
                {
                    operauto	: operauto,
                    codsenha	: codsenha,
                    redirect	: 'script_ajax'
                },
        error: function(objAjax,responseError,objExcept) {
            hideMsgAguardo();
			showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','');
        },
		success: function(response) {
        try {
            if ( response.indexOf('showError("error"') == -1) {
                try {
                    $('input,select','#frmSenhaCoord').removeClass('campoErro');
                    hideMsgAguardo();
                    verifica_folha_cheque();
                } catch(error) {
                    hideMsgAguardo();
                    showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','unblockBackground()');
                }
            } else {
                try {
                    hideMsgAguardo();
                    eval( response );
                } catch(error) {
                    hideMsgAguardo();
                    showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','unblockBackground()');
                }
            }
            return false;
            } catch(error) {
                hideMsgAguardo();
                showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','');
            }
        }
    });

	return false;
}

// Processo de Devolucao - Por Conta
function verifica_folha_cheque() {

    showMsgAguardo('Aguarde, verificando folha de cheque...');

	$.ajax({
        type    : 'POST',
        dataType: 'html',
        url     : UrlSite + 'telas/devolu/verifica_folha_cheque.php',
        data    :
                {
                    dsbccxlt : dsbccxlt,
                    cdcooper : cdcooper,
                    nrdocmto : nrdocmto,
                    nrdctitg : nrdctitg,
                    cdbanchq : cdbanchq,
                    cdagechq : cdagechq,
                    nrctachq : nrctachq,
                    cddsitua : cddsitua,
                    nrdrecid : nrdrecid,
                    vllanmto : vllanmto,
                    flag     : flag,
                    redirect: 'script_ajax'
                },
        error: function(objAjax,responseError,objExcept) {
            hideMsgAguardo();
            showError('error','Não foi possível concluir a requisição.','Alerta - Ayllos',"unblockBackground();");
        },
        success: function(response) {
            try {
                if ( response.indexOf('showError("error"') == -1) {
                    try {
                        $('input,select','#frmAlinea').removeClass('campoErro');
                        hideMsgAguardo();
						if (flag == 'yes') {
							proc_gera_dev();
						}else {
							mostraAlinea();
						}
                    } catch(error) {
                        hideMsgAguardo();
                        showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','unblockBackground()');
                    }
                } else {
                    try {
                        hideMsgAguardo();
                        eval( response );
                    } catch(error) {
                        hideMsgAguardo();
                        showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','unblockBackground()');
                    }
                }
                return false;
            } catch(error) {
                hideMsgAguardo();
                showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message,"Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
            }
        }
	});

	return false;
}

// Processo de Devolucao - Por Conta
// Exibe a Escolha da Alinea
function mostraAlinea() {

    showMsgAguardo('Aguarde, abrindo...');

	// Executa script de confirmação através de ajax
	$.ajax({
		type    : 'POST',
		dataType: 'html',
		url     : UrlSite + 'telas/devolu/alinea.php',
		data    :
                {
                    redirect: 'html_ajax'
                },
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError('error','Não foi possível concluir a requisição.','Alerta - Ayllos',"unblockBackground()");
		},
		success: function(response) {
			$('#divRotina').html(response);
			buscaAlinea();
			return false;
		}
	});

	return false;
}

// Chamada de Formulário de Alinea
function buscaAlinea() {

	hideMsgAguardo();
	showMsgAguardo('Aguarde, abrindo...');

	$.ajax({
		type    : 'POST',
		dataType: 'html',
		url     : UrlSite + 'telas/devolu/form_alinea.php',
		data    :
                {
                    redirect: 'script_ajax'
                },
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError('error','Não foi possível concluir a requisição.','Alerta - Ayllos',"unblockBackground();");
		},
		success: function(response) {
			if ( response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1 ) {
				try {
                    $('input,select','#'+frmCab).removeClass('campoErro');
					$('#divConteudoAlinea').html(response);
					exibeRotina($('#divRotina'));
					formataAlinea();
                    $('#cdalinea','#frmAlinea').focus();

					$('#cdalinea','#frmAlinea').unbind('keypress').bind('keypress', function(e) {
						if ( e.keyCode == 13 || e.keyCode == 9 ) {
							proc_gera_dev();
							return false;
						}
					});

					return false;
				} catch(error) {
					hideMsgAguardo();
					showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','unblockBackground()');
				}
			} else {
				try {
					eval( response );
				} catch(error) {
					hideMsgAguardo();
					showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','unblockBackground()');
				}
			}
		}
	});

	return false;
}

// Processo de Devolucao - Por Conta
function verifica_alinea() {

	var cdalinea;

	if(flag == 'yes') {
		cdalinea = alinea;		
	}else{
		cdalinea = $('#cdalinea','#frmAlinea').val();
		showMsgAguardo('Aguarde, validando alinea...');
	}

	$.ajax({
        type    : 'POST',
        dataType: 'html',
        url     : UrlSite + 'telas/devolu/verifica_alinea.php',
        data    :
                {
                    cdcooper : cdcooper,
                    cdbanchq : cdbanchq,
                    cdagechq : cdagechq,
                    nrctachq : nrctachq,
                    nrdocmto : nrdocmto,
                    cdalinea : cdalinea,
                    redirect: 'script_ajax'
                },
        error: function(objAjax,responseError,objExcept) {
            hideMsgAguardo();
            showError('error','Não foi possível concluir a requisição.','Alerta - Ayllos',"unblockBackground();");
        },
        success: function(response) {
            try {
                if ( response.indexOf('showError("error"') == -1) {
                    try {
                        $('input,select','#frmAlinea').removeClass('campoErro');
                        hideMsgAguardo();
                        geracao_devolu();
                    } catch(error) {
                        hideMsgAguardo();
                        showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','unblockBackground()');
                    }
                } else {
                    try {
                        hideMsgAguardo();
                        eval( response );
                    } catch(error) {
                        hideMsgAguardo();
                        showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','unblockBackground()');
                    }
                }
                return false;
            } catch(error) {
                hideMsgAguardo();
                showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message,"Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
            }
        }
	});

	return false;
}

// Processo de Devolucao - Por Conta
function geracao_devolu() {

	var cdalinea = $('#cdalinea','#frmAlinea').val();
	var nrdconta = $('#nrdconta','#frmCab').val().replace(".", "").replace(".", "").replace("-", "");
	
	var mensagemRetorno = 'Processo de Marca&ccedil;&atilde;o Conclu&iacute;do!';

//	showMsgAguardo('Aguarde...');

	$.ajax({
        type    : 'POST',
        dataType: 'html',
        url     : UrlSite + 'telas/devolu/geracao_devolu.php',
        data    :
                {
                    cdcooper : cdcooper,
					banco    : banco,
                    nrdrecid : nrdrecid,
                    nrdctitg : nrdctitg,
					vllanmto : vllanmto,
					cdalinea : cdalinea,
					cdagechq : cdagechq,
                    nrdconta : nrdconta,
                    nrctachq : nrctachq,
                    nrdocmto : nrdocmto,
					flag     : flag,
                    redirect : 'script_ajax'
                },
        error: function(objAjax,responseError,objExcept) {
            hideMsgAguardo();
            showError('error','Não foi possível concluir a requisição.','Alerta - Ayllos',"unblockBackground();");
        },
        success: function(response) {
            try {
                if ( response.indexOf('showError("error"') == -1) {
                    try {						
						if (flag == 'yes') {
							mensagemRetorno = 'Processo de Desmarca&ccedil;&atilde;o Conclu&iacute;do!';
						}
                        showError('inform',mensagemRetorno,'Alerta - Ayllos','hideMsgAguardo();fechaRotina($("#divRotina"));gera_log();BuscaDevolu(1,30);');
                    } catch(error) {
                        hideMsgAguardo();
                        showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','unblockBackground()');
                    }
                } else {
                    try {
                        hideMsgAguardo();
                        eval( response );
                    } catch(error) {
                        hideMsgAguardo();
                        showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','unblockBackground()');
                    }
                }
                return false;
            } catch(error) {
                hideMsgAguardo();
                showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message,"Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
            }
        }
	});

	return false;
}

// Processo de Devolucao - Por Conta
function gera_log() {

	var cdalinea;

	if(flag == 'yes') {
		cdalinea = alinea;
	}else{
		cdalinea = $('#cdalinea','#frmAlinea').val();
	}

	showMsgAguardo('Aguarde, gerando log...');

	$.ajax({
        type    : 'POST',
        dataType: 'html',
        url     : UrlSite + 'telas/devolu/gera_log.php',
        data    :
                {
                    cdcooper : cdcooper,
					flag     : flag,
					vllanmto : vllanmto,
					nrdocmto : nrdocmto,
					nrctachq : nrctachq,
					cdbanchq : cdbanchq,
					cdalinea : cdalinea,
                    redirect : 'script_ajax'
                },
        error: function(objAjax,responseError,objExcept) {
            hideMsgAguardo();
            showError('error','Não foi possível concluir a requisição.','Alerta - Ayllos',"unblockBackground();");
        },
        success: function(response) {
            try {
                if ( response.indexOf('showError("error"') == -1) {
                    try {
						hideMsgAguardo();
                    } catch(error) {
                        hideMsgAguardo();
                        showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','unblockBackground()');
                    }
                } else {
                    try {
                        hideMsgAguardo();
                        eval( response );
                    } catch(error) {
                        hideMsgAguardo();
                        showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','unblockBackground()');
                    }
                }
                return false;
            } catch(error) {
                hideMsgAguardo();
                showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message,"Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
            }
        }
	});

	return false;
}


// Processo de Execucao de Devolucoes
// Exibe a Escolha dos Bancos Disponiveis - Executar Devolucao
function mostraBanco() {

    showMsgAguardo('Aguarde, abrindo...');

	// Executa Script de Confirmação Através de Ajax
	$.ajax({
		type    : 'POST',
		dataType: 'html',
		url     : UrlSite + 'telas/devolu/banco.php',
		data    :
                {
                    redirect: 'html_ajax'
                },
		error: function(objAjax,responseError,objExcept) {
                hideMsgAguardo();
                showError('error','Não foi possível concluir a requisição.','Alerta - Ayllos',"unblockBackground()");
		},
		success: function(response) {
			$('#divRotina').html(response);
			buscaBanco();
			return false;
		}
	});

	return false;
}

// Processo de Execucao de Devolucoes
// Chamada de Formulário de Opcoes de Banco - Executar Devolucao
function buscaBanco() {

	hideMsgAguardo();
	showMsgAguardo('Aguarde, abrindo ...');

	$.ajax({
		type    : 'POST',
		dataType: 'html',
		url     : UrlSite + 'telas/devolu/form_banco.php',
		data    :
                {
                    redirect: 'script_ajax'
                },
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError('error','Não foi possível concluir a requisição.','Alerta - Ayllos',"unblockBackground();");
		},
		success: function(response) {

			if ( response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1 ) {
				try {
                    $('input,select','#'+frmCab).removeClass('campoErro');
					$('#divConteudo').html(response);
					exibeRotina($('#divRotina'));
					formataBanco();

					$('#cddopcao','#frmBanco').unbind('keypress').bind('keypress', function(e) {
						if ( e.keyCode == 13 || e.keyCode == 9 ) {
							verifica_solicitacao_processo();
							return false;
						}
					});

					return false;
				} catch(error) {
					hideMsgAguardo();
					showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','unblockBackground()');
				}
			} else {
				try {
					eval( response );
				} catch(error) {
					hideMsgAguardo();
					showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','unblockBackground()');
				}
			}
		}
	});

	return false;
}

// Processo de Execucao de Devolucoes
function verifica_solicitacao_processo() {

    var cddevolu = $('#cddopcao','#frmBanco').val();

    $.ajax({
        type    : 'POST',
        dataType: 'html',
        url     : UrlSite + 'telas/devolu/verifica_solicitacao_processo.php',
        data    :
                {
                    cddevolu : cddevolu,
                    redirect : 'script_ajax'
                },
        error: function(objAjax,responseError,objExcept) {
            hideMsgAguardo();
            showError('error','Não foi possível concluir a requisição.','Alerta - Ayllos',"unblockBackground();");
        },
        success: function(response) {
            if ( response.indexOf('showError("error"') == -1) {
                try {
                    $('input,select','#'+frmCab).removeClass('campoErro');
                    selecBan = $('#cddopcao','#frmBanco').val();
                    showConfirmacao('Confirma Opera&ccedil;&atilde;o?',"Confirma&ccedil;&atilde;o - Ayllos",'mostraSenhaSistema();','fechaRotina($("#divRotina"));',"sim.gif","nao.gif");
                } catch(error) {
                    hideMsgAguardo();
                    showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','unblockBackground()');
                }
            } else {
                try {
					bloqueiaFundo( $('#divConteudo') );
                    eval( response );
                } catch(error) {
                    hideMsgAguardo();
                    showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','unblockBackground()');
                }
            }
        }
	});

	return false;
}

// Processo de Execucao de Devolucoes
// Senha - Autorizacao do Sistema
function mostraSenhaSistema() {

	showMsgAguardo('Aguarde, abrindo...');

	// Executa script de confirmação através de ajax
	$.ajax({
		type    : 'POST',
		dataType: 'html',
		url     : UrlSite + 'telas/devolu/senha.php',
		data    :
                {
                    redirect: 'html_ajax'
                },
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError('error','Não foi possível concluir a requisição.','Alerta - Ayllos',"unblockBackground()");
		},
		success: function(response) {
			$('#divRotina').html(response);
			buscaSenhaSistema();
			return false;
		}
	});

	return false;
}

// Processo de Execucao de Devolucoes
// Chamada de Formulário de Senha - Autorizacao do Sistema
function buscaSenhaSistema() {

	hideMsgAguardo();
	showMsgAguardo('Aguarde, abrindo ...');

	$.ajax({
		type    : 'POST',
		dataType: 'html',
		url     : UrlSite + 'telas/devolu/form_senha_sistema.php',
		data    :
                {
                    redirect: 'script_ajax'
                },
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError('error','Não foi possível concluir a requisição.','Alerta - Ayllos',"unblockBackground();");
		},
		success: function(response) {

			if ( response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1 ) {
				try {
                    $('input,select','#'+frmCab).removeClass('campoErro');
					$('#divConteudoSenha').html(response);
					exibeRotina($('#divRotina'));
					formataSenhaSistema();

					$('#cddsenha','#frmSenha').unbind('keypress').bind('keypress', function(e) {
						if ( e.keyCode == 13 || e.keyCode == 9 ) {
							grava_processo_solicitacao();
							return false;
						}
					});

					return false;
				} catch(error) {
					hideMsgAguardo();
					showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','unblockBackground()');
				}
			} else {
				try {
					eval( response );

				} catch(error) {
					hideMsgAguardo();
					showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','unblockBackground()');
				}
			}
		}
	});

	return false;
}

// Processo de Execucao de Devolucoes
function grava_processo_solicitacao() {

    var cddevolu = selecBan;
    var cddsenha = $('#cddsenha','#frmSenha').val();

	hideMsgAguardo();
	showMsgAguardo('Aguarde, executando solicitacoes de processo...');

    $.ajax({
        type    : 'POST',
        dataType: 'html',
        url     : UrlSite + 'telas/devolu/grava_processo_solicitacao.php',
        data    :
                {
                    cddevolu : cddevolu,
                    cddsenha : cddsenha,
                    redirect : 'script_ajax'
                },
        error: function(objAjax,responseError,objExcept) {
            hideMsgAguardo();
            showError('error','Não foi possível concluir a requisição.','Alerta - Ayllos',"unblockBackground();");
        },
        success: function(response) {
            if ( response.indexOf('showError("error"') == -1) {
                try {
                    $('input,select','#'+frmCab).removeClass('campoErro');
                    hideMsgAguardo();
					executa_processo_devolu();
                } catch(error) {
                    hideMsgAguardo();
                    showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','unblockBackground()');
                }
            } else {
                try {
                    eval( response );
                } catch(error) {
                    hideMsgAguardo();
                    showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','unblockBackground()');
                }
            }
        }
	});

	return false;
}

// Processo de Execucao de Devolucoes
function executa_processo_devolu() {

    var cddevolu = selecBan;

    hideMsgAguardo();
	showMsgAguardo('Aguarde, executando devolucoes...');

    $.ajax({
        type    : 'POST',
        dataType: 'html',
        url     : UrlSite + 'telas/devolu/executa_processo_devolu.php',
        data    :
                {
                    cddevolu : cddevolu,
                    redirect : 'script_ajax'
                },
        error: function(objAjax,responseError,objExcept) {
            hideMsgAguardo();
            showError('error','Não foi possível concluir a requisição.','Alerta - Ayllos',"unblockBackground();");
        },
        success: function(response) {
            if ( response.indexOf('showError("error"') == -1) {
                try {
                    $('input,select','#'+frmCab).removeClass('campoErro');
                    showError('inform','Devolu&ccedil;&otilde;es Executadas','Alerta - Ayllos','hideMsgAguardo();fechaRotina($("#divRotina"));BuscaDevolu(1,30);');
                } catch(error) {
                    hideMsgAguardo();
                    showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','unblockBackground()');
                }
            } else {
                try {
                    eval( response );
                } catch(error) {
                    hideMsgAguardo();
                    showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','unblockBackground()');
                }
            }
        }
	});

	return false;
}

// Controle de Selecao do Mouse
function LiberaCampos() {
    if ( $('#cddopcao','#frmCab').hasClass('campoTelaSemBorda')  ) { return false; }
    return false;
}