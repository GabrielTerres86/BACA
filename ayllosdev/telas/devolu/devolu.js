/*! 
 * FONTE        : DEVOLU.php
 * CRIAÇÃO      : Andre Santos - SUPERO
 * DATA CRIAÇÃO : 25/09/2013
 * OBJETIVO     : Mostrar tela DEVOLU
 * --------------
 * ALTERAÇÕES   : #273953 Alinhamento das colunas das tabelas (Carlos)
 * --------------
 *                12/07/2016 #451040 Retirar o botão "Executar Devolução" (Carlos)
 *
 *				  19/08/2016 - Ajustes referentes a Melhoria 69 - Devolucao Automatica de Cheques(Lucas Ranghetti #484923)
 * 
 *				  07/11/2016 - Validar horario para devolucao de acordo com o parametrizado na TAB055(Lucas Ranghetti #539626)
 * 
 *                11/04/2017 - Permitir acessar o Ayllos mesmo vindo do CRM. (Jaison/Andrino)
 * 
 *			  	  16/01/2018 - Aumentado tamanho do campo de senha para 30 caracteres. (PRJ339 - Reinert)
 *
 *                03/10/2018 - Scripts para tratamento de opcao de excluir.
 *                             Bruno Luiz K. - Chamado SCTASK0029653 (Mouts).
 *              
 *                
 *  
 *                23/01/2019 - Alteracao na rotina de alteracao de alinea e
 *                             melhoria na gravacao do log na verlog.
 *                             Chamado - PRB0040476 - Gabriel Marcos (Mouts).
 *
 */

// Definição de algumas variáveis globais
var nrdconta  =  0 ;
var cdagenci  =  0 ;
var nmprimtl  =  '';
var selecBan  =  0 ; // Guarda o selecao do banco selecionado.
var dsbccxlt;
var banco;
var cdcooper;
var nrcheque;
var alinea;
var nrdctitg;
var cdbccxlt;
var cdbanchq;
var cdagechq;
var cddsitua;
var nrdrecid;
var vllanmto;
var nrctachq;
var nmoperad;
var nrdconta_tab;
var flag;
var iqtSelecao = 0;
var altalinea;
var dstabela;

var camposDc, dadosDc;

// Formulários
var frmCab   	= 'frmCab';
    frmDevolu   = 'frmDevolu';

// Labels/Campos do Cabeçalho
var rNmprimtl, rNrdconta, rCdagenci,
    cNmprimtl, cNrdconta, cCdagenci, cTodosCabecalho, btnCab;

// Labels/Campos de Opcoes de Banco
var rCddopcao,
    cCddopcao;

// Labels/Campos de Alinea
var rCdalinea,
    cCdalinea;

var arrayRegLinha = new Array();
var arrayRegDados = new Array();

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

    arrayRegLinha = new Array();
    arrayRegDados = new Array();

    camposDc = '';
	dadosDc  = '';

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
	cCdagenci.val( '' );
	cNrdconta.val( '' );
	cNmprimtl.val( nmprimtl );
	$('#cdagenci','#'+frmCab).habilitaCampo();
	$('#nrdconta','#'+frmCab).habilitaCampo();
	$('#cdagenci','#'+frmCab).select();
	trocaBotao('Prosseguir','btnContinuar();');
	$('#btVoltar','#divBotoes').hide();

    btFechaImagem();

    // Desabilita Campos
	$('#nmprimtl','#'+frmCab).desabilitaCampo();

    // Seta os valores caso tenha vindo do CRM
    if ($("#crm_inacesso","#frmCab").val() == 1) {
        $("#nrdconta","#frmCab").val($("#crm_nrdconta","#frmCab").val());
    }

    controlaFoco();
	highlightObjFocus( $('#'+frmCab) );
}


// Formata Cabeçalho Principal
function formataCabecalho() {

    // Labels
	rCdagenci       = $('label[for="cdagenci"]','#'+frmCab);
	rNrdconta		= $('label[for="nrdconta"]','#'+frmCab);
	rNmprimtl       = $('label[for="nmprimtl"]','#'+frmCab);

    // Campos
	cCdagenci		= $('#cdagenci','#'+frmCab);
	cNrdconta		= $('#nrdconta','#'+frmCab);
	cNmprimtl       = $('#nmprimtl','#'+frmCab);
	cTodosCabecalho	= $('input[type="text"],select','#'+frmCab);

    //Rótulos
	rCdagenci.addClass('rotulo-linha').css({'width':'40px'});
	rNrdconta.addClass('rotulo-linha').css({'width':'60px'});
    rNmprimtl.addClass('rotulo-linha').css({'width':'0px'});

    // Campos
	cCdagenci.css({'width':'40px'}).setMask('INTEGER','zzz','','');
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
    cSenha.addClass('campo').css({'width':'100px'}).attr('maxlength','30');

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
	cCdalinea.css({'width':'70px'}).setMask('INTEGER','zzz','','');

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

	$('#cdagenci','#'+frmCab).unbind('keydown').bind('keydown', function(e) {
        if ( e.keyCode == 9 || e.keyCode == 13 ) { 
            // Caso NAO tenha vindo do CRM
            if ($("#crm_inacesso","#frmCab").val() != 1) {
                $('#nrdconta','#frmCab').val('');
            }
			$('#nrdconta','#frmCab').select();
            return false;
        }
    });

	$('#nrdconta','#'+frmCab).unbind('keypress').bind('keypress', function(e) {
        if ( e.keyCode == 9 || e.keyCode == 13 ) { 
			$('#cdagenci','#'+frmCab).desabilitaCampo();
            $('#nrdconta','#'+frmCab).desabilitaCampo();
            btnContinuar('CI');
            return false;
        }else {// Seta máscara ao campo
            return $('#nrdconta','#'+frmCab).setMask('INTEGER','zzzz.zzz-z','.-','');
        }
    });

	$('#btSalvar','#divBotoes').unbind('keypress').bind('keypress', function(e) {
        if ( e.keyCode == 9 || e.keyCode == 13 ) {
			$('#cdagenci','#'+frmCab).desabilitaCampo();
			$('#nrdconta','#'+frmCab).desabilitaCampo();
            btnContinuar('CI');
            return false;
        }
    });

	$('#btSalvar','#divBotoes').unbind('click').bind('click', function(){
		$('#cdagenci','#'+frmCab).desabilitaCampo();
		$('#nrdconta','#'+frmCab).desabilitaCampo();
        return false;
    });

}


// Controle de Botoes
function trocaBotao( botao , funcao ) {
	$('#divBotoes','#divTela').html('');
	$('#divBotoes','#divTela').append('<a href="#" class="botao" id="btVoltar" onclick="btnVoltar(); return false;" >Voltar</a>&nbsp;');

	if(botao == 'Lancamento' ){
		$('#divBotoes','#divTela').append('<a href="#" class="botao" id="btMarcar" onClick="Marcar(); return false;" >Marcar</a>&nbsp;');
		$('#divBotoes','#divTela').append('<a href="#" class="botao" id="btDesmarcar" onClick="Desmarcar(); return false;" >Desmarcar</a>');
	}else {
		$('#divBotoes','#divTela').append('<a href="#" class="botao" id="btSalvar" onclick=' + funcao + ' return false;" >' + botao + '</a>');
    }
    $('#divBotoes','#divTela').append('<a href="#" class="botao" id="btExcluir" onClick="btExcluir(); return false;" >Excluir</a>');
	$('#divBotoes','#divTela').append('<a href="#" class="botao" id="btFechaImagem" onClick="btFechaImagem(); return false;" >Fechar Imagem</a>');

	$('#btFechaImagem','#divBotoes').hide(); 
    $('#btExcluir','#divBotoes').hide();
    $('#btDesmarcar').trocaClass('botao', 'botaoDesativado');
    return false;
}

// Botoes
function btnVoltar() {
    estadoInicial();
    return false;
}

// Botao Principal
function btnContinuar(opcao) {
   BuscaDevolu(1,30,opcao);
    return false;
}

// Botao Executa as Devolucoes
function ExecutaDevolucao() {
    mostraBanco();
    return false;
}

function Marcar(){

	if (iqtSelecao > 0 || alinea > 0 || alinea == 35   || cddsitua == 1) {return false;}

    marcar_cheque_devolu();

    return false;
}

function Desmarcar(){

	if (iqtSelecao == 0 || iqtSelecao.typeof == 'undefined') {return false;}

    marcar_cheque_devolu();
    return false;
}

// Botao Auxiliar - Devolver Cheque
function proc_gera_dev() {
	if (altalinea == true){
		showConfirmacao('Confirma Opera&ccedil;&atilde;o?',"Confirma&ccedil;&atilde;o - Aimaro",'verifica_alinea("AL");','fechaRotina($("#divRotina"));',"sim.gif","nao.gif");
	}else{
		showConfirmacao('Confirma Opera&ccedil;&atilde;o?',"Confirma&ccedil;&atilde;o - Aimaro",'verifica_alinea();','fechaRotina($("#divRotina"));',"sim.gif","nao.gif");
    }
    return false;
}

// Busca Dados do Associado
function BuscaDevolu(nriniseq, nrregist,opcao) {

    var nrdconta = $('#nrdconta','#'+frmCab).val().replace(".", "").replace("-", "");
	var cdagenci = $('#cdagenci','#'+frmCab).val();

    altalinea = false;

    showMsgAguardo("Aguarde, buscando devolu&ccedil;&otilde;es...");

    $.ajax({
        type	: 'POST',
        url		: UrlSite + 'telas/devolu/principal.php',
        dataType: 'html',
        data    :
                {
                    nrdconta : nrdconta,
					cdagenci : cdagenci,
					nriniseq : nriniseq,
				    nrregist : nrregist,
					opcao    : opcao,
                    redirect : 'script_ajax'
                },
        error   : function(objAjax,responseError,objExcept) {
            hideMsgAguardo();
                    showError('error','N&atilde;o foi possível concluir a requisi&ccedil;&atilde;o.','Alerta - Aimaro','estadoInicial();');
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
                        showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Aimaro','');
                    }
                } else {
                    try {
                        eval(response);
						$('#nrdconta','#'+frmCab).habilitaCampo();
						$('#cdagenci','#'+frmCab).habilitaCampo();
                        return false;
                    } catch(error) {
                        hideMsgAguardo();
                        showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Aimaro','estadoInicial();');
                    }
                }
            } catch(error) {
                showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message,"Alerta - Aimaro","blockBackground(parseInt($('#divRotina').css('z-index')))");
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
	divRegistro.css({'height':'280px','width':'970px'});

	$('#divRegistrosRodape','#divConsulta').formataRodapePesquisa();

    var ordemInicial = new Array();
    ordemInicial = [[0]];

    var arrayLargura = new Array();
    arrayLargura[0]  = '33px'; // 
	arrayLargura[1]  = '33px'; // bco
	arrayLargura[2]  = '65px'; // age
	arrayLargura[3]  = '65px'; // cta
	arrayLargura[4]  = '65px'; // chq
	arrayLargura[5]  = '60px'; // valor
	arrayLargura[6]  = '60px'; // alinea
	arrayLargura[7]  = '';     // situcao
	arrayLargura[8]  = '60px'; // operador
	arrayLargura[9]  = '60px'; // aplicacao
    arrayLargura[10] = '60px'; // contato
    arrayLargura[11] = '60px'; // imagem

    var arrayAlinha = new Array();
	arrayAlinha[0]  = 'center';
    arrayAlinha[1]  = 'center';
	arrayAlinha[2]  = 'center';
	arrayAlinha[3]  = 'center';
	arrayAlinha[4]  = 'center';
	arrayAlinha[5]  = 'center';
	arrayAlinha[6]  = 'center';
	arrayAlinha[7]  = 'center';
	arrayAlinha[8]  = 'center';
	arrayAlinha[9]  = 'left';
    arrayAlinha[10] = 'center';
    arrayAlinha[11] = 'center';
    arrayAlinha[12] = 'center';

	tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha);
    hideMsgAguardo();

    $('#btSalvar','#divBotoes').hide();
    $('#btVoltar','#divBotoes').show();
    $('#btExcluir','#divBotoes').show();
	$('#btVoltar','#divBotoes').focus();

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

    var tables = $('.tituloRegistros');
    $(tables[0]).find('tr').each(function(){
        $(this).unbind('click').bind('click',function(){
            $(tables[1]).find('tr').each(function(){
                $(this).removeClass('corSelecao');
                $(this).unbind('click').bind('click',function(){
                    $('.corSelecao',tables[1]).each(function(){$(this).removeClass('corSelecao')});
                    $(this).toggleClass('corSelecao');
                    selecionaTabela($(this));
                });
            });
        });
    });

    return false;
}

function btExcluir(){
    showConfirmacao("Deseja realmente excluir a devolu&ccedil&atilde;o do cheque "+nrcheque+" no valor de "+formataMoeda(parseFloat(vllanmto))+"?",
                    'Confirma&ccedil;&atilde;o - Ayllos',
                    'excluir_cheque_devolu()',
                    'console.log("nao")',
                    'sim.gif',
                    'nao.gif');
}

function excluir_cheque_devolu(){

    $.ajax({
        type    :    'POST',
        url     :    UrlSite + 'telas/devolu/excluir_cheque_devolu.php',
        dataType:    'html',
        data    :
                {
                     cdbanchq : cdbccxlt,
                     cdagechq : cdagechq,
                     nrdconta : nrdconta_tab,
                     nrctachq : nrctachq,
                     nrdocmto : nrcheque,
                    redirect: 'script_ajax'
                },
        error: function(objAjax,responseError,objExcept) {
            hideMsgAguardo();
                     showError('error','Não foi possível concluir a requisição.','Alerta - Aimaro',"unblockBackground();");
        },
        success: function(response) {
            eval(response);
        }
    });

    return false; //return false to allow default event  tag <a>

}

function btFechaImagem(){
	$('#btFechaImagem','#divBotoes').hide(); 
	$('#divImagem','#divTela').css({'display':'none'});
}

function formataTabelaLancto() {

    // Tabela
    $('#tabDevoluConta').css({'display':'block'});
    $('#divResultado').css({'display':'block'});

    var divRegistro = $('div.divRegistros', '#tabDevoluConta');
	var tabela      = $('table', divRegistro );
	var linha       = $('table > tbody > tr', divRegistro );

    $('#tabDevoluConta').css({'margin-top':'5px'});
	divRegistro.css({'height':'280px','width':'900px'});

    var ordemInicial = new Array();
    ordemInicial = [[0]];

    var arrayLargura = new Array();
    arrayLargura[0]  = '15px';  //check
	arrayLargura[1]  = '80px'; //bco
	arrayLargura[2]  = '33px'; //age
	arrayLargura[3]  = '65px'; //chq
	arrayLargura[4]  = '85px'; //valor
	arrayLargura[5]  = '65px'; //sit
	arrayLargura[6]  = '40px'; // alinea
	arrayLargura[7]  = ''; // situcao
	arrayLargura[8]  = '60px';     // operador
	arrayLargura[9]  = '60px'; // aplicacao
    arrayLargura[10] = '60px'; // contrato
    arrayLargura[11] = '63px'; // imagem 

    var arrayAlinha = new Array();
	arrayAlinha[0]  = 'center';
    arrayAlinha[1]  = 'center';
	arrayAlinha[2]  = 'center';
	arrayAlinha[3]  = 'center';
	arrayAlinha[4]  = 'center';
	arrayAlinha[5]  = 'center';
	arrayAlinha[6]  = 'center';
	arrayAlinha[7]  = 'center';
	arrayAlinha[8]  = 'center';
	arrayAlinha[9]  = 'center';
    arrayAlinha[10] = 'center';
    arrayAlinha[11] = 'center';
    arrayAlinha[12] = 'center';
    arrayAlinha[13] = 'center';


	tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha );

	$('#complemento','#linha').addClass('txtNormalBold').css({'width':'90%','text-align':'center'})

    hideMsgAguardo();
    trocaBotao('Lancamento',''); //label e funcao
	$('#btMarcar','#divBotoes').hide();
	$('#btDesmarcar','#divBotoes').hide();
    altalinea = false;

    /********************
	  EVENTO COMPLEMENTO
	*********************/

    // seleciona o registro que é clicado
	$('table > tbody > tr', divRegistro).click( function() {
        selecionaTabela($(this));

		$('#btMarcar','#divBotoes').show();
		$('#btDesmarcar','#divBotoes').show();

        if (alinea != 0 || iqtSelecao > 0) {
			$('#btMarcar').trocaClass('botao',    'botaoDesativado');
		}else{
			$('#btMarcar').trocaClass('botaoDesativado',    'botao');
        }
    });

    // seleciona o registro que é focado
	$('table > tbody > tr', divRegistro).focus( function() { 
        selecionaTabela($(this));
    });

    // Se der dois clicks na tabela, altera alinea
	$('table > tbody > tr', divRegistro).dblclick( function() {

        // Se tiver alinea e não for devolvido e não for alineas de contra-ordem(20,21,28,70) e altera alinea para devoluções 35 somente quando haver craplcm
		if (alinea != 0  && cddsitua != 1 &&
		    alinea != 20 && alinea != 21 &&
			alinea != 28 && alinea != 70){

			if (alinea == 35 && dstabela == 'crapdev'){
                altalinea = false;
			}else{
                altalinea = true;
                mostraAlinea('AL');
            }
        }
    });


    $('table > tbody > tr:eq(0)', divRegistro).click();
    return false;
}

function selecionaTabela(tr) {

    cdcooper = $('#cdcooper', tr).val();
    dsbccxlt = $('#dsbccxlt', tr).val();
    banco = $('#banco', tr).val();
    nrcheque = $('#nrcheque', tr).val();
    nrdctitg = $('#nrdctitg', tr).val();
    cdbccxlt = $('#cdbccxlt', tr).val();
    cdbanchq = $('#cdbanchq', tr).val();
    cdagechq = $('#cdagechq', tr).val();
    cddsitua = $('#cddsitua', tr).val();
    nrdrecid = $('#nrdrecid', tr).val();
    vllanmto = $('#vllanmto', tr).val();
    nrctachq = $('#nrctachq', tr).val();
	alinea   = $('#cdalinea', tr).val();
    nmoperad = $('#nmoperad', tr).val();
    nrdconta_tab = $('#nrdconta', tr).val();
    flag     = $('#flag', tr).val();
    dstabela = $('#dstabela', tr).val();
    altalinea = false;
    return false;
}

// Processo de Devolucao - Por Conta
function marcar_cheque_devolu() {

    //Adquire as informações das checkbox selecionadas
	$('#indice','#tabDevoluConta').each(function() { 
        if ($(this).prop('checked')) {
            arrayRegDados[arrayRegDados.length] = arrayRegLinha[$(this).val()];
            arrayRegDados[arrayRegDados.length - 1].cdalinea = $('#cdalinea', $(this).closest('tr')).val();
        }
    });

	if (iqtSelecao > 0){

		camposDc  = retornaCampos( arrayRegDados, '|' );
		dadosDc   = retornaValores( arrayRegDados, ';', '|',camposDc );
    }

    showMsgAguardo('Aguarde, verificando horario de execucao...');

    $.ajax({
		type    : 'POST',
        dataType: 'html',
		url     : UrlSite + 'telas/devolu/marcar_cheque_devolu.php',
		data    :
                {
                    dsbccxlt : dsbccxlt,
                    cdcooper : cdcooper,
                    nrdocmto : nrcheque,
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
			showError('error','Não foi possível concluir a requisição.','Alerta - Aimaro',"unblockBackground();");
        },
		success: function(response) {
            try {
                hideMsgAguardo();
                eval(response);
                // validar horario para devolução de acordo com o parametrizado na TAB055
                if(execucao == 'yes'){                   
                    showError('inform',dscritic,'Alerta - Aimaro','estadoInicial();');                
                }else{				   
                    verifica_folha_cheque();
                }
			} catch(error) {
                hideMsgAguardo();
				showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message,"Alerta - Aimaro","blockBackground(parseInt($('#divRotina').css('z-index')))");
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
			showError('error','Não foi possível concluir a requisição.','Alerta - Aimaro',"unblockBackground()");
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
			showError('error','Não foi possível concluir a requisição.','Alerta - Aimaro',"unblockBackground();");
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
					showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Aimaro','unblockBackground()');
                }
            } else {
                try {
					eval( response );
				} catch(error) {
                    hideMsgAguardo();
					showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Aimaro','unblockBackground()');
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
			showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Aimaro','');
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
                    showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Aimaro','unblockBackground()');
                    }
                } else {
                    try {
                        hideMsgAguardo();
                    eval( response );
                } catch(error) {
                        hideMsgAguardo();
                    showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Aimaro','unblockBackground()');
                    }
                }
                return false;
            } catch(error) {
                hideMsgAguardo();
                showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Aimaro','');
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
                    nrdocmto : nrcheque,
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
            showError('error','Não foi possível concluir a requisição.','Alerta - Aimaro',"unblockBackground();");
        },
        success: function(response) {
            try {
                if ( response.indexOf('showError("error"') == -1) {
                    try {
                        $('input,select','#frmAlinea').removeClass('campoErro');
                        hideMsgAguardo();

                        if (flag == 'yes' || iqtSelecao > 0) {
                            proc_gera_dev();
						}else {
                            mostraAlinea('LA');
                        }
                    } catch(error) {
                        hideMsgAguardo();
                        showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Aimaro','unblockBackground()');
                    }
                } else {
                    try {
                        hideMsgAguardo();
                        eval( response );
                    } catch(error) {
                        hideMsgAguardo();
                        showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Aimaro','unblockBackground()');
                    }
                }
                return false;
            } catch(error) {
                hideMsgAguardo();
                showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message,"Alerta - Aimaro","blockBackground(parseInt($('#divRotina').css('z-index')))");
            }
        }
    });

    return false;
}

// Processo de Devolucao - Por Conta
// Exibe a Escolha da Alinea
function mostraAlinea(opcao) {

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
			showError('error','Não foi possível concluir a requisição.','Alerta - Aimaro',"unblockBackground()");
        },
		success: function(response) {
            $('#divRotina').html(response);
            buscaAlinea(opcao);
            return false;
        }
    });

    return false;
}

// Chamada de Formulário de Alinea
function buscaAlinea(opcao) {

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
			showError('error','Não foi possível concluir a requisição.','Alerta - Aimaro',"unblockBackground();");
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
					showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Aimaro','unblockBackground()');
                }
            } else {
                try {
					eval( response );
				} catch(error) {
                    hideMsgAguardo();
					showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Aimaro','unblockBackground()');
                }
            }
        }
    });

    return false;
}

// Processo de Devolucao - Por Conta
function verifica_alinea(opcao) {

    var cdalinea;

	if(flag == 'yes' && opcao != 'AL') {
        cdalinea = alinea;
	}else{
		cdalinea = $('#cdalinea','#frmAlinea').val();
        showMsgAguardo('Aguarde, validando alinea...');
    }

	if(iqtSelecao > 0 && altalinea == false) {
        geracao_devolu();
	}else {
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
						nrdocmto : nrcheque,
						cdalinea : cdalinea,
					    redirect: 'script_ajax'
					},
			error: function(objAjax,responseError,objExcept) {
                hideMsgAguardo();
				showError('error','Não foi possível concluir a requisição.','Alerta - Aimaro',"unblockBackground();");
            },
			success: function(response) {
                try {
					if ( response.indexOf('showError("error"') == -1) {
                        try {
							$('input,select','#frmAlinea').removeClass('campoErro');
                            hideMsgAguardo();
							if(opcao == 'AL' || altalinea == true){
                                alteraAlinea();
							}else{
                                geracao_devolu();
                            }
						} catch(error) {
                            hideMsgAguardo();
							showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Aimaro','unblockBackground()');
                        }
                    } else {
                        try {
                            hideMsgAguardo();
							eval( response );
						} catch(error) {
                            hideMsgAguardo();
							showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Aimaro','unblockBackground()');
                        }
                    }
                    return false;
				} catch(error) {
                    hideMsgAguardo();
					showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message,"Alerta - Aimaro","blockBackground(parseInt($('#divRotina').css('z-index')))");
                }
            }
        });
    }
    return false;
}

function alteraAlinea(){

    var cdalinea;

	cdalinea = $('#cdalinea','#frmAlinea').val();
    showMsgAguardo('Aguarde, alterando alinea...');

    $.ajax({
        type    : 'POST',
        dataType: 'html',
        url     : UrlSite + 'telas/devolu/altera_alinea.php',
        data    :
                {
                    cdbanchq : cdbanchq,
                    cdagechq : cdagechq,
                    nrctachq : nrctachq,
                    nrdocmto : nrcheque,
                    cdalinea : cdalinea,
                    redirect: 'script_ajax'
                },
        error: function(objAjax,responseError,objExcept) {
            hideMsgAguardo();
            showError('error','Não foi possível concluir a requisição.','Alerta - Aimaro',"unblockBackground();");
        },
        success: function(response) {
            try {
                hideMsgAguardo();
                fechaRotina($("#divRotina"));
				eval( response );
            } catch(error) {
                hideMsgAguardo();
				showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Aimaro','unblockBackground()');
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
                    nrdocmto : nrcheque,
					flag     : flag,
					camposDc : camposDc,
					dadosDc  : dadosDc,
                    redirect : 'script_ajax'
                },
        error: function(objAjax,responseError,objExcept) {
            hideMsgAguardo();
            showError('error','Não foi possível concluir a requisição.','Alerta - Aimaro',"unblockBackground();");
        },
        success: function(response) {
            try {
                if ( response.indexOf('showError("error"') == -1) {
                    try {
                        if (iqtSelecao > 0) {
                            mensagemRetorno = 'Processo de Desmarca&ccedil;&atilde;o Conclu&iacute;do!';
                        }
                        var funcao = "BuscaDevolu(1,30,'CA');camposDc = '';dadosDc = '';";
                        showError('inform',mensagemRetorno,'Alerta - Aimaro','hideMsgAguardo();fechaRotina($("#divRotina"));gera_log();iqtSelecao = 0; arrayRegLinha = new Array();arrayRegDados = new Array();'+funcao);
                    } catch(error) {
                        hideMsgAguardo();
                        showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Aimaro','unblockBackground()');
                    }
                } else {
                    try {
                        hideMsgAguardo();
                        eval( response );
                    } catch(error) {
                        hideMsgAguardo();
                        showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Aimaro','unblockBackground()');
                    }
                }
                return false;
            } catch(error) {
                hideMsgAguardo();
                showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message,"Alerta - Aimaro","blockBackground(parseInt($('#divRotina').css('z-index')))");
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
					nrdocmto : nrcheque,
					nrctachq : nrctachq,
					cdbanchq : cdbanchq,
					cdalinea : cdalinea,
					camposDc : camposDc,
					dadosDc  : dadosDc,
                    redirect : 'script_ajax'
                },
        error: function(objAjax,responseError,objExcept) {
            hideMsgAguardo();
            showError('error','Não foi possível concluir a requisição.','Alerta - Aimaro',"unblockBackground();");
        },
        success: function(response) {
            try {
                if ( response.indexOf('showError("error"') == -1) {
                    try {
                        hideMsgAguardo();
                    } catch(error) {
                        hideMsgAguardo();
                        showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Aimaro','unblockBackground()');
                    }
                } else {
                    try {
                        hideMsgAguardo();
                        eval( response );
                    } catch(error) {
                        hideMsgAguardo();
                        showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Aimaro','unblockBackground()');
                    }
                }
                return false;
            } catch(error) {
                hideMsgAguardo();
                showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message,"Alerta - Aimaro","blockBackground(parseInt($('#divRotina').css('z-index')))");
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
                showError('error','Não foi possível concluir a requisição.','Alerta - Aimaro',"unblockBackground()");
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
			showError('error','Não foi possível concluir a requisição.','Alerta - Aimaro',"unblockBackground();");
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
					showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Aimaro','unblockBackground()');
                }
            } else {
                try {
					eval( response );
				} catch(error) {
                    hideMsgAguardo();
					showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Aimaro','unblockBackground()');
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
            showError('error','Não foi possível concluir a requisição.','Alerta - Aimaro',"unblockBackground();");
        },
        success: function(response) {
            if ( response.indexOf('showError("error"') == -1) {
                try {
                    $('input,select','#'+frmCab).removeClass('campoErro');
                    selecBan = $('#cddopcao','#frmBanco').val();
                    showConfirmacao('Confirma Opera&ccedil;&atilde;o?',"Confirma&ccedil;&atilde;o - Aimaro",'mostraSenhaSistema();','fechaRotina($("#divRotina"));',"sim.gif","nao.gif");
                } catch(error) {
                    hideMsgAguardo();
                    showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Aimaro','unblockBackground()');
                }
            } else {
                try {
					bloqueiaFundo( $('#divConteudo') );
                    eval( response );
                } catch(error) {
                    hideMsgAguardo();
                    showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Aimaro','unblockBackground()');
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
			showError('error','Não foi possível concluir a requisição.','Alerta - Aimaro',"unblockBackground()");
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
			showError('error','Não foi possível concluir a requisição.','Alerta - Aimaro',"unblockBackground();");
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
					showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Aimaro','unblockBackground()');
                }
            } else {
                try {
					eval( response );

				} catch(error) {
                    hideMsgAguardo();
					showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Aimaro','unblockBackground()');
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
            showError('error','Não foi possível concluir a requisição.','Alerta - Aimaro',"unblockBackground();");
        },
        success: function(response) {
            if ( response.indexOf('showError("error"') == -1) {
                try {
                    $('input,select','#'+frmCab).removeClass('campoErro');
                    hideMsgAguardo();
                    executa_processo_devolu();
                } catch(error) {
                    hideMsgAguardo();
                    showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Aimaro','unblockBackground()');
                }
            } else {
                try {
                    eval( response );
                } catch(error) {
                    hideMsgAguardo();
                    showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Aimaro','unblockBackground()');
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
            showError('error','Não foi possível concluir a requisição.','Alerta - Aimaro',"unblockBackground();");
        },
        success: function(response) {
            if ( response.indexOf('showError("error"') == -1) {
                try {
                    $('input,select','#'+frmCab).removeClass('campoErro');
                    showError('inform','Devolu&ccedil;&otilde;es Executadas','Alerta - Aimaro','hideMsgAguardo();fechaRotina($("#divRotina"));BuscaDevolu(1,30,"CA");');
                } catch(error) {
                    hideMsgAguardo();
                    showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Aimaro','unblockBackground()');
                }
            } else {
                try {
                    eval( response );
                } catch(error) {
                    hideMsgAguardo();
                    showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Aimaro','unblockBackground()');
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

// Contatos
function mostraContatos() {

    showMsgAguardo('Aguarde, abrindo...');

    // Executa script de confirmação através de ajax
    $.ajax({
		type    : 'POST',
        dataType: 'html',
		url     : UrlSite + 'telas/devolu/contatos.php',
		data    :
                {
                    redirect: 'html_ajax'
                },
		error: function(objAjax,responseError,objExcept) {
            hideMsgAguardo();
			showError('error','Não foi possível concluir a requisição.','Alerta - Aimaro',"unblockBackground()");
        },
		success: function(response) {
            $('#divRotina').html(response);
            buscaContatos(0);
            return false;
        }
    });

    return false;
}

function acessaOpacaAba(nropcoes,id){

    // Mostra mensagem de aguardo
    showMsgAguardo('Aguarde, carregando...');

    // Atribui cor de destaque para aba da opção
    for (var i = 0; i < nropcoes; i++) {
        if ($('#linkAba' + id).length == false) {
            continue;
        }

        if (id == i) { // Atribui estilos para foco da opção			
			$('#linkAba'   + id).attr('class','txtBrancoBold');
			$('#imgAbaEsq' + id).attr('src',UrlImagens + 'background/mnu_sle.gif');				
			$('#imgAbaDir' + id).attr('src',UrlImagens + 'background/mnu_sld.gif');
			$('#imgAbaCen' + id).css('background-color','#969FA9');
            continue;
        }

		$('#linkAba'   + i).attr('class','txtNormalBold');
		$('#imgAbaEsq' + i).attr('src',UrlImagens + 'background/mnu_nle.gif');			
		$('#imgAbaDir' + i).attr('src',UrlImagens + 'background/mnu_nld.gif');
		$('#imgAbaCen' + i).css('background-color','#C6C8CA');
    }

    buscaContatos(id);

}

// Chamada de Formulario de Contatos
function buscaContatos(id) {

    hideMsgAguardo();
    showMsgAguardo('Aguarde, abrindo ...');

	var nrdconta = $('#nrdconta','#frmCab').val().replace(".", "").replace(".", "").replace("-", "");

	if($('#nrdconta','#frmCab').val() != 0) {
        nrdconta_tab = nrdconta;
    }

    $.ajax({
		type    : 'POST',
        dataType: 'html',
		url     : UrlSite + 'telas/devolu/busca_contatos.php',
		data    :
                {
                    nrdconta: nrdconta_tab,
                    redirect: 'script_ajax'
                },
		error: function(objAjax,responseError,objExcept) {
            hideMsgAguardo();
			showError('error','Não foi possível concluir a requisição.','Alerta - Aimaro',"unblockBackground();");
        },
		success: function(response) {
			if ( response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1 ) {
                try {
                    $('#divConteudoContatos').html(response);
                    exibeRotina($('#divRotina'));
                    formataContato(id);
                    return false;
				} catch(error) {
                    hideMsgAguardo();
					showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Aimaro','unblockBackground()');
                }
            } else {
                try {
					eval( response );
				} catch(error) {
                    hideMsgAguardo();
					showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Aimaro','unblockBackground()');
                }
            }
        }
    });

    return false;
}

function formataContato(id){

    $('#divRotina').show();

	if (id == 0){

		$('#tabEmails').css({'display':'none'});
		$('#tabTelefones').css({'display':'block'});
		$('#divConteudoContatos').css({'display':'block'});

        var divRegistro = $('div.divRegistros', '#tabTelefones');
		var tabela      = $('table', divRegistro );
		var linha       = $('table > tbody > tr', divRegistro );

		$('#tabTelefones').css({'margin-top':'5px'});
		divRegistro.css({'height':'250px','width':'300px','padding-bottom':'2px'});		

        var ordemInicial = new Array();

        var arrayLargura = new Array();
        arrayLargura[0] = '35px';
        arrayLargura[1] = '30px';
        arrayLargura[2] = '90px';

        var arrayAlinha = new Array();
        arrayAlinha[0] = 'center';
        arrayAlinha[1] = 'center';
        arrayAlinha[2] = 'left';
	}else{
		$('#tabTelefones').css({'display':'none'});
		$('#tabEmails').css({'display':'block'});
		$('#divConteudoContatos').css({'display':'block'});

        var divRegistro = $('div.divRegistros', '#tabEmails');
		var tabela      = $('table', divRegistro );
		var linha       = $('table > tbody > tr', divRegistro );

		$('#tabEmails').css({'margin-top':'5px'});
		divRegistro.css({'height':'250px','width':'500px','padding-bottom':'2px'});

        var ordemInicial = new Array();

        var arrayLargura = new Array();
        arrayLargura[0] = '35px';
        arrayLargura[1] = '300px';

        var arrayAlinha = new Array();
        arrayAlinha[0] = 'center';
        arrayAlinha[1] = 'left';

    }

	tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha, '' );
    hideMsgAguardo();
    $('#divRotina').centralizaRotinaH();
	bloqueiaFundo( $('#divRotina') );

    return false;

}

function btVoltContatos(){
    $('#divRotina').hide();
    hideMsgAguardo();
    unblockBackground();
}

function baixarArquivo(rand,sidlog,frente,verso){
    var quallado = selbaixa == 'F' ? frente : verso;
		var apagartb = selbaixa == 'F' ? verso  : frente;
		window.open('download.php?keyrand='+rand+'&sidlogin='+sidlog+'&src='+quallado+'&apagartb='+apagartb, '_blank');
}

function consultaCheque(cdagechq,nrctachq,nrcheque) {

    showMsgAguardo("Aguarde, consultando cheque ...");

    $('#divImagem').html("");
	$('#divImagem').css({'display':'none'});

    var cdcmpchq;
	var cheque,tamcheque;

    tamcheque = nrcheque.length;
	cheque = nrcheque.substring(0,tamcheque - 1);

    cdbanchq = 85;

    imgchqF = false; //Frente
    imgchqV = false; // Verso

    // Executa script de consulta através de ajax
    $.ajax({
        type: 'POST',
        dataType: 'html',
        url: UrlSite + 'telas/devolu/consulta_cheque.php',
        data: {
            cdcmpchq: cdcmpchq,
            cdbanchq: cdbanchq,
            cdagechq: cdagechq,
            nrctachq: nrctachq,
            nrcheque: cheque,
            gerarpdf: false,
            tpremess: "S",
            redirect: 'script_ajax'
        },
		error: function(objAjax,responseError,objExcept) {
            hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Aimaro","blockBackground(parseInt($('#divRotina').css('z-index')))");
        },
		success: function(response) {
            try {
                eval(response);
			} catch(error) {
                hideMsgAguardo();
				showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message,"Alerta - Aimaro","blockBackground(parseInt($('#divRotina').css('z-index')))");
            }
        }
    });
}

function limpaChequeTemp(imgrefe,frente, verso) {
    // Executa script de consulta através de ajax
    // Apaga arquivos do temp apenas quando as duas imagens , frente e verso do cheque forem carregadas e nao for gerar pdf
	if(imgrefe == 'imgchqF'){
        imgchqF = true;
	}else if(imgrefe == 'imgchqV'){
        imgchqV = true;
    }
    // as duas imagens do cheque, frente e verso devem estar carregadas e que nao seja para imprimir pdf nem baixar arquivo
	if(imgchqF && imgchqV && !flgerpdf && !flbaiarq){
        $.ajax({
            type: "POST",
            dataType: "html",
            url: UrlSite + "telas/imgchq/limpa_cheque_temp.php",
            data: {
                dsfrente: frente,
                dsdverso: verso,
                redirect: "script_ajax"
            },
			error: function(objAjax,responseError,objExcept) {
                hideMsgAguardo();
				showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Aimaro","blockBackground(parseInt($('#divRotina').css('z-index')))");
            },
			success: function(response) {
                try {
                    eval(response);
				} catch(error) {
                    hideMsgAguardo();
					showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message,"Alerta - Aimaro","blockBackground(parseInt($('#divRotina').css('z-index')))");
                }
            }
        });
    }
}


function validaSelecao(linhaSelec,inprejuz){

    iqtSelecao = 0;

    if (inprejuz == 1) {
		showError("inform","Conta em Prejuizo","Alerta - Aimaro","blockBackground(parseInt($('#divRotina').css('z-index')))");
    }

    $('input:checkbox:checked', '#tabDevoluConta').each(function() {
        iqtSelecao++;
    });

    if (iqtSelecao > 0) {
		$('#btMarcar').trocaClass('botao',    'botaoDesativado');
        $('#btDesmarcar').trocaClass('botaoDesativado', 'botao');
    } else {
        $('#btDesmarcar').trocaClass('botao', 'botaoDesativado');
		$('#btMarcar').trocaClass('botaoDesativado',    'botao');
    }

    if (iqtSelecao === 0)
        $('#complemento', '#linha').html('');
    else if (iqtSelecao <= 20) {
        $('#complemento', '#linha').html(iqtSelecao + ' cheque(s) selecionado(s) - M&aacuteximo 20.');
    } else {
        linhaSelec.prop('checked', false);
    }

    return false;

}

function formataMoeda(valor){
    if(typeof valor !== "float")
        valor = parseFloat(valor);
    return (valor).toLocaleString('pt-BR', { style: 'currency', currency: 'BRL' });
}