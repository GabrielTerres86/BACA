/*!
/*!
 * FONTE        : manccf.js
 * CRIAÇÃO      : Gabriel Capoia (DB1) 
 * DATA CRIAÇÃO : 11/01/2013
 * OBJETIVO     : Biblioteca de funções da tela MANCCF
 * --------------
 * ALTERAÇÕES   : 23/03/2016 - Alterado a funcao manterrotina pois nao estava passando opcao
 *                             ocasionando problemas de permissionamento do operador
 *                             (Tiago SD)
 *
 *                29/08/2016 - #481330 Ajustes de navegação, validações e layout (Carlos)
 *
 *                11/04/2017 - Permitir acessar o Ayllos mesmo vindo do CRM. (Jaison/Andrino)
 *
 * --------------
 */
var nometela;

//Formulários e Tabela
var frmCab   		= 'frmCab';
var frmLocal   		= 'frmLocal';
var tabDados		= 'tabConinf';
var divTabela;
var dsdircop;
var linha;
var registro;

var aux_mensagem;

var cdcooper,	dsiduser, 	cdcoopea, 	cdagenca, 	tpdocmto, 	indespac, 	cdfornec, 	dtmvtol1,
 	dtmvtol2, 	tpdsaida, 	nrregist, 	nriniseq, 	rCddopcao, rNrdrelat, rCdagenca, nrseqdig,
	nrdconta,	nmprimtl,	nrcpfcgc, msgconta, idseqttl, nmoperad, dtfimest, flgctitg,	
	cCddopcao, cNrdrelat, cCdagenca, cTodosCabecalho, btnOK,
	rCdcoopea, rDtmvtola, rDtmvtol2, rCdagenca, rTpdocmto, rIndespac, rCdfornec, rTpdsaida,
	cCdcoopea, cDtmvtola, cDtmvtol2, cCdagenca, cTpdocmto, cIndespac, cCdfornec, cTpdsaida,
	rNrdconta, rNmprimtl, rNrcpfcgc, cNrdconta, cNmprimtl, cNrcpfcgc, iqtSelecao;

var flgvepac 		= '';
var arrayConinf		= new Array();

var nrJanelas		= 0;
	
$(document).ready(function() {	
	divTabela		= $('#divTabela');
	estadoInicial();			
	return false;
		
});

function carregaDados(){

	nrdconta = normalizaNumero( $('#nrdconta','#'+frmCab).val() );
			
	return false;
}


// Inicio
function estadoInicial() {

	$('#frmCab').fadeTo(0,0.1);
					
	$('#divTabela').html('');
	
	formataCabecalho();
	
	cTodosCabecalho.limpaFormulario();
	
	removeOpacidade('frmCab');	

    // Seta os valores caso tenha vindo do CRM
    if ($("#crm_inacesso","#frmCab").val() == 1) {
        $("#nrdconta","#frmCab").val($("#crm_nrdconta","#frmCab").val());
    }
	
	return false;
	
}

// Formata
function formataCabecalho() {

	// cabecalho
	rNrdconta = $('label[for="nrdconta"]','#'+frmCab); 
	rNmprimtl = $('label[for="nmprimtl"]','#'+frmCab); 	
		
	cNrdconta = $('#nrdconta','#'+frmCab); 
	cNmprimtl = $('#nmprimtl','#'+frmCab); 
	
	cTodosCabecalho		= $('input[type="text"],select','#'+frmCab);
	btnOK				= $('#btnOK','#'+frmCab);
	
	//Label
	rNrdconta.addClass('rotulo').css({'width':'110px'});	
	rNmprimtl.addClass('rotulo-linha').css({'width':'85px'});
		
	//Campos
	cNrdconta.css({'width':'90px'}).addClass('conta pesquisa');	
	cNmprimtl.css({'width':'360px'});
		
	cTodosCabecalho.habilitaCampo();
	cNmprimtl.desabilitaCampo();
	highlightObjFocus( $('#frmCab') );
	
	cNrdconta.unbind('keypress').bind('keypress', function(e) {
		if ( divError.css('display') == 'block' ) { return false; }		
		// Se é a tecla ENTER, 
		if ( e.keyCode == 13 ) {
			btnOK.click();
			return false;
		} 
	});	
	
	cNrdconta.focus();	
	
	// Se clicar no botao OK
	btnOK.unbind('click').bind('click', function() {
				
		if ( divError.css('display') == 'block' ) { return false; }		
		if ( cNrdconta.hasClass('campoTelaSemBorda')  ) { return false; }		
		
		buscaContrato();
		
		return false;
			
	});	
	
	layoutPadrao();
	// controlaPesquisas();
	return false;	
}

/* Alterna a situação do botão de refazer regularização conforme a situação do cheque */
function clicouCheque(flgctitg) {	

	if (flgctitg != 1) {
		$('#btRefazer').trocaClass('botao','botaoDesativado');
		$('#btRefazer').removeAttr('onclick');
	} else {
		$('#btRefazer').trocaClass('botaoDesativado','botao');
		$('#btRefazer').attr('onclick','RefazRegulariza()');
	}

    return false;
}

function selecionaCheque() {

    if ($('table > tbody > tr', '#divTabela').hasClass('corSelecao')) {

        $('table > tbody > tr', '#divTabela').each(function() {
            if ($(this).hasClass('corSelecao')) {

                linha = $(this);
                nrseqdig = $('#nrseqdig', $(this)).val();				
                nmoperad = $('#nmoperad', $(this)).val();
                dtfimest = $('#dtfimest', $(this)).val();
                flgctitg = $('#flgctitg', $(this)).val();
                nrdocmtosrt = $('#nrdocmto', $(this)).val();

                aux_mensagem = 'Confirma Regulariza&ccedil;&atilde;o do Cheque: ' + mascara(nrdocmtosrt, '###.###.#') + ' ?';
            }
        });
    }

    return false;
}

function geraSelecao(){

	var auxSelecao = "";

	$('input:checkbox:checked', divTabela ).each(function () {
		auxSelecao +=  $(this).val() + ',';
	});	
	
	return auxSelecao;
}

// imprimir
function Gera_Impressao() {

	var divRegistro = $('div.divRegistros', divTabela );	

	registro = $('table > tbody > tr:eq(0) > td > input', divRegistro);	 
	
	var action = UrlSite + 'telas/'+nometela+'/imprimir_dados.php';	
	
	var dsseqdig = geraSelecao();

	if ( dsseqdig == '' ){showError('error','Nao ha cheques selecionados!','Alerta - Ayllos','registro.focus();');return false;}		
	
	$('#dsseqdig', '#'+frmCab ).val( dsseqdig );	
	$('#nrdcontaImp', '#'+frmCab ).val( $('#nrdconta', '#'+frmCab ).val() );	
	
	carregaImpressaoAyllos(frmCab,action,"");
	
	return false;
	
}

// botoes
function btnVoltar() {
	estadoInicial();
	return false;
}

function buscaContrato() {

	showMsgAguardo('Aguarde, consultando Cheques...');
    
	carregaDados();
	
	buscaContrato2();
}

function buscaContrato2() {	
	
	msgconta = "";
			
	$.ajax({		
		type	: 'POST',
		dataType: 'html',
		url		: UrlSite + 'telas/'+nometela+'/busca_contrato.php', 
		data    :
				{ nrdconta	: nrdconta,				  
				  redirect: 'script_ajax'
				  
				},
		error   : function(objAjax,responseError,objExcept) {
					hideMsgAguardo();
					showError('error','Não foi possível concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','$(\'#nrdconta\',\'#frmCab\').focus();');
				},
		success : function(response) { 
					hideMsgAguardo();
					
					if ( response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1 ) {
						try {
							$('#divTabela').html(response);		
							$('#nrdconta','#'+frmCab).desabilitaCampo();	// Daniel	
							$('input,select', '#frmCab').removeClass('campoErro');							
							$('#btRefazer').trocaClass('botao',    'botaoDesativado');
							return false;
						} catch(error) {
							hideMsgAguardo();
							showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','$(\'#nrdconta\',\'#frmCab\').focus();');
						}
					} else {
						try {
							eval( response );
						} catch(error) {
							hideMsgAguardo();
							showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','$(\'#nrdconta\',\'#frmCab\').focus();');
						}
					}
					
				}
	}); 
}

function formataTabela() {
	
	var divRegistro = $('div.divRegistros', divTabela );
	
	var tabela      = $('table', divRegistro );

	divRegistro.css({'height':'207px','border-bottom':'1px dotted #777','padding-bottom':'2px'});

	var ordemInicial = new Array();

	var arrayLargura = new Array();
	arrayLargura[0] = '20px';
	arrayLargura[1] = '59px';
	arrayLargura[2] = '70px';
	arrayLargura[3] = '70px';
	arrayLargura[4] = '70px';
	arrayLargura[5] = '60px';
	arrayLargura[6] = '30px';
	arrayLargura[7] = '70px';
	arrayLargura[8] = '95px';
    arrayLargura[9] = '30px';
/*	arrayLargura[10] = '20px';
*/
	var arrayAlinha = new Array();
	arrayAlinha[0] = 'center';	
	arrayAlinha[1] = 'right';
	arrayAlinha[2] = 'center';
	arrayAlinha[3] = 'center';
	arrayAlinha[4] = 'right';
	arrayAlinha[5] = 'right';	
	arrayAlinha[6] = 'right';	
	arrayAlinha[7] = 'center';	
	arrayAlinha[8] = 'center';	
	arrayAlinha[9] = 'center';	
	arrayAlinha[10] = 'center';		
	arrayAlinha[11] = 'center';	
	
	tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha, 'Regulariza();' );
		
	$('#complemento','#linha').addClass('txtNormalBold').css({'width':'90%','text-align':'center'})
	
	divTabela.css({'display':'block'});		
	
	cNrdconta.focus();	
	
	return false;
}

function validaSelecao(linhaSelec){

    iqtSelecao = 0;

    $('input:checkbox:checked', divTabela).each(function() {
        iqtSelecao++;
    });    
	
    if (iqtSelecao > 0) {		
		$('#btTitular').trocaClass('botao',    'botaoDesativado');
		$('#btRegulariza').trocaClass('botao', 'botaoDesativado');
		$('#btRefazer').trocaClass('botao',    'botaoDesativado');		
    } else {
	    $('#btTitular').trocaClass('botaoDesativado',   'botao');		
        $('#btRegulariza').trocaClass('botaoDesativado','botao');	

		//Decide se o botao de reenvio de regularizacao fica ativo
		clicouCheque($(linhaSelec).parent().children('#flgctitg').attr('value'));
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

function controlaPesquisas() {

	if ( $('#nrdconta','#frmCab').hasClass('campoTelaSemBorda')  ) { return false; }	
	
	mostraPesquisaAssociado('nrdconta', frmCab );
	return false;
}

function mostraTitular() {

    if (iqtSelecao > 0) return false; // Só prossegue se não selecionar nenhum cheque

    showMsgAguardo('Aguarde, buscando ...');

    selecionaCheque();

    // Executa script de confirmação através de ajax
    $.ajax({
        type: 'POST',
        dataType: 'html',
        url: UrlSite + 'telas/' + nometela + '/titular.php',
        data: {
            redirect: 'html_ajax'
        },
        error: function(objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError('error', 'Não foi possível concluir a requisição.', 'Alerta - Ayllos', "unblockBackground()");
        },
        success: function(response) {
            $('#divRotina').html(response);
            //exibeRotina($('#divRotina'));
            //formataAvalista();
            buscaTitular();
            return false;
        }
    });

    return false;	
}

function buscaTitular() {
		
	showMsgAguardo('Aguarde, buscando Titulares...');
	
	$.ajax({		
		type: 'POST',
		dataType: 'html',
		url: UrlSite + 'telas/'+nometela+'/busca_titular.php', 
		data: {
			nrdconta	: nrdconta,
			redirect: 'script_ajax'			
			}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();			
			showError('error','Não foi possível concluir a requisição.','Alerta - Ayllos',"unblockBackground();");
		},
		success: function(response) {
		
			if ( response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1 ) {
				try {
					$('#divConteudo').html(response);	
					formataTitular();
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

function formataTitular() {

    var rNmprimtl2 = $('label[for="nmprimtl"]', '#frmAvalis');
    var cNmprimtl2 = $('#nmprimtl', '#frmAvalis');

    var divRegistro = $('div.divRegistros', '#divTitular');
    var tabela = $('table', divRegistro);
    var linha = $('table > tbody > tr', divRegistro);

    divRegistro.css({'height': '130px'});

    var ordemInicial = new Array();
    ordemInicial = [[0, 0]];

    var arrayLargura = new Array();
    arrayLargura[0] = '30px';


    var arrayAlinha = new Array();
    arrayAlinha[0] = 'center';
    arrayAlinha[1] = 'left';

    var metodoTabela = 'selecionaTitular();';

    tabela.formataTabela(ordemInicial, arrayLargura, arrayAlinha, metodoTabela);

	// centraliza a divRotina
	$('#divRotina').css({'width':'525px'});
	$('#divConteudo').css({'width':'500px'});
	$('#divRotina').centralizaRotinaH();	
	
	hideMsgAguardo();
	exibeRotina($('#divRotina'));
	bloqueiaFundo( $('#divRotina') );
			
	return false;
}

function selecionaTitular() {

	if ( $('table > tbody > tr', '#divTitular').hasClass('corSelecao') ) {
					
		$('table > tbody > tr', '#divTitular').each( function() {
			if ( $(this).hasClass('corSelecao') ) {
				idseqttl = $('#idseqttl', $(this) ).val(); 
			}	
		});
	}	
	
	manterRotina('titular');	
	return false;
}

function Regulariza(){

    if (iqtSelecao > 0) return false; // Só prossegue se não selecionar nenhum cheque

    selecionaCheque();

	// Se nao selecionou cheque
	if (aux_mensagem == undefined) {		   	    		
		showError('error','Selecione um cheque.','Alerta - Ayllos','registro.focus();');
		return false;
	}	
	
	showConfirmacao(aux_mensagem, 'Confirma&ccedil;&atilde;o - Ayllos', 'manterRotina(\'regulariza\');', 'cNrdconta.focus();', 'sim.gif', 'nao.gif');	

    return false;
}

function RefazRegulariza(){

    if (iqtSelecao > 0) return false; // Só prossegue se não selecionar nenhum cheque

    selecionaCheque();

	// Se nao selecionou cheque
	if (aux_mensagem == undefined) {		   	    		
		showError('error','Selecione um cheque.','Alerta - Ayllos','registro.focus();');
		return false;
	}		

	aux_mensagem = 'Confirma reenvio para regulariza&ccedil;&atilde;o do Cheque: ' + mascara(nrdocmtosrt, '###.###.#') + ' ?';
	showConfirmacao(aux_mensagem, 'Confirma&ccedil;&atilde;o - Ayllos', 'manterRotina(\'refazRegulariza\');', 'cNrdconta.focus();', 'sim.gif', 'nao.gif');

    return false;
}

function manterRotina( operacao ) {
		
	hideMsgAguardo();		
	
	var mensagem = '';
	var cddopcao = '';
		
	switch ( operacao ) {
	    case 'titular': mensagem = 'Aguarde, gravando dados ...'; cddopcao = 'R';	break;
	    case 'regulariza': mensagem = 'Aguarde, gravando dados ...'; cddopcao = 'R'; break;
	    case 'refazRegulariza': mensagem = 'Aguarde, gravando dados ...'; cddopcao = 'R'; break;
		default		      : return false; 	break;
	}	
	
	showMsgAguardo( mensagem );	
	
        $.ajax({
            type: 'POST',
            url: UrlSite + 'telas/' + nometela + '/manter_rotina.php',
            data: {
                cddopcao: cddopcao,
                operacao: operacao,
                nrdconta: nrdconta,
                nrseqdig: nrseqdig,
                idseqttl: idseqttl,
                nmoperad: nmoperad,
                dtfimest: dtfimest,
                flgctitg: flgctitg,
                redirect: 'script_ajax'
            },
            error: function(objAjax, responseError, objExcept) {
                hideMsgAguardo();
                showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'estadoInicial();');
            },
            success: function(response) {
                try {
                    eval(response);
					buscaContrato2();
                    return false;
                } catch (error) {
                    hideMsgAguardo();
                    showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'estadoInicial();');
                }
            }
        });

	return false;		                     
}
