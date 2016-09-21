/*!
 * FONTE        : aliena.js
 * CRIAÇÃO      : Rogerius Militão (DB1)
 * DATA CRIAÇÃO : 22/07/2011
 * OBJETIVO     : Biblioteca de funções da tela ALIENA
 * --------------
 * ALTERAÇÕES   : 20/11/2012 - Incluso efeito highlightObjFocus e fadeTo, incluso
 *                             navegacao campos usando enter, alterado funcao controlaPesquisas,
 *                             alteracao posicionamento campos na tela.
 *                             Incluso funcao LiberaCampos (Daniel).
 *
 *                21/11/2013 - Novas colunas GRAVAMES (Guilherme/SUPERO)
 *
 * 				  05/01/2015 -  Padronizando a mascara do campo nrctremp.
 *								10 Digitos - Campos usados apenas para visualização
 *								8 Digitos - Campos usados para alterar ou incluir novos contratos
 *								(Kelvin - SD 233714) 
 * --------------
 */

// Definição de algumas variáveis globais
var cddopcao		='C';
var nrdconta 		= 0 ; // Armazena o Número da Conta/dv
var nrctremp 		= 0 ; // Armazena o Número da Conta/dv
var arrayAliena		= new Array();
var arrayAux		= new Array();

// Variaveis auxilires
var erro			= '';

var aux_dtmvtolt	= ''; // cabecalho
var aux_nmprimtl	= ''; // cabecalho

var total			= 0 ;
var indice			= 0 ;


//Formulários
var frmCab   		= 'frmCab';
var frmDados 		= 'frmAliena';
var tabDados		= 'tabAliena';

//Labels/Campos do cabeçalho
var rCddopcao, rNrdconta, rNrctremp, rDtmvtolt, rNmprimtl,
    cCddopcao, cNrdconta, cNrctremp, cDtmvtolt, cNmprimtl, cTodosCabecalho, btnCab;

//Labels/Campos do formulário de dados
var rDsaliena, rFlgalfid, rDtvigseg, rFlglbseg, rFlgrgcar, rDtatugrv, rTpinclus, rCdsitgrv,
    cDsaliena, cFlgalfid, cDtvigseg, cFlglbseg, cFlgrgcar, cDtatugrv, cTpinclus, cCdsitgrv,
    cTodosDados, btnForm;

$(document).ready(function() {

    estadoInicial();

    highlightObjFocus( $('#'+frmCab) );
    highlightObjFocus( $('#'+frmDados) );
    highlightObjFocus( $('#'+tabDados) );

    $('fieldset > legend').css({'font-size':'11px','color':'#777','margin-left':'5px','padding':'0px 2px'});
    $('fieldset').css({'clear':'both','border':'1px solid #777','margin':'3px 0px','padding':'10px 3px 5px 3px'});

});


// seletores
function estadoInicial() {

    $('#divTela').fadeTo(0,0.1);
    $('#frmCab').css({'display':'block'});

    atualizaSeletor();
    formataCabecalho();

    $('#'+frmDados).css({'display':'none'});
    $('#'+tabDados).css({'display':'none'});

    cTodosCabecalho.limpaFormulario();
    cCddopcao.val( cddopcao );

    setGlobais();

    removeOpacidade('divTela');

    $('#nrdconta','#frmCab').desabilitaCampo();
    $('#nrctremp','#frmCab').desabilitaCampo();

    $("#btSalvar","#divBotoes").hide();
    $("#btVoltar","#divBotoes").hide();


    $('#cddopcao','#frmCab').unbind('keypress').bind('keypress', function(e) {
        if ( e.keyCode == 9 || e.keyCode == 13 ) {
                $('#btnOK','#frmCab').focus();
                return false;
            }
    });

    // nrdconta
    $('#btnOK','#frmCab').unbind('keypress').bind('keypress', function(e) {
            if ( e.keyCode == 9 || e.keyCode == 13 ) {
                LiberaCampos();
                $('#nrdconta','#frmCab').focus();
                return false;
            }
    });

    $('#nrdconta','#frmCab').unbind('keypress').bind('keypress', function(e) {
            if ( e.keyCode == 9 || e.keyCode == 13 ) {
                if ( $('#nrdconta','#frmCab').val() == '' ) {
                    controlaPesquisas(1) ;
                } else {
                    $('#nrctremp','#frmCab').focus();
                    return false;
                }
            }
    });

    $('#nrctremp','#frmCab').unbind('keypress').bind('keypress', function(e) {
            if ( e.keyCode == 9 || e.keyCode == 13 ) {
                if ( $('#nrctremp','#frmCab').val() == '' ) {
                    controlaPesquisas(2) ;
                } else {
                    btnContinuar();
                    return false;
                }
            }
    });

    // Alienação
    $('#flgalfid','#frmAliena').unbind('keypress').bind('keypress', function(e) {
            if ( e.keyCode == 9 || e.keyCode == 13 ) {
                $('#dtvigseg','#frmAliena').focus();
                return false;
            }
    });

    // Venc. Seg.
    $('#dtvigseg','#frmAliena').unbind('keypress').bind('keypress', function(e) {
            if ( e.keyCode == 9 || e.keyCode == 13 ) {
                $('#flglbseg','#frmAliena').focus();
                return false;
            }
    });

    // Lib. Seg.
    $('#flglbseg','#frmAliena').unbind('keypress').bind('keypress', function(e) {
            if ( e.keyCode == 9 || e.keyCode == 13 ) {
                $('#flgrgcar','#frmAliena').focus();
                return false;
            }
    });

    // Reg. Cart.
    $('#flgrgcar','#frmAliena').unbind('keypress').bind('keypress', function(e) {
            if ( e.keyCode == 9 || e.keyCode == 13 ) {
                $('#btnFormulario','#frmAliena').focus();
                return false;
            }
    });


}

function atualizaSeletor(){

    // cabecalho
    rCddopcao			= $('label[for="cddopcao"]','#'+frmCab);
    rNrdconta			= $('label[for="nrdconta"]','#'+frmCab);
    rNrctremp			= $('label[for="nrctremp"]','#'+frmCab);
    rDtmvtolt			= $('label[for="dtmvtolt"]','#'+frmCab);
    rNmprimtl	        = $('label[for="nmprimtl"]','#'+frmCab);

    cCddopcao			= $('#cddopcao','#'+frmCab);
    cNrdconta			= $('#nrdconta','#'+frmCab);
    cNrctremp			= $('#nrctremp','#'+frmCab);
    cDtmvtolt			= $('#dtmvtolt','#'+frmCab);
    cNmprimtl			= $('#nmprimtl','#'+frmCab);
    cTodosCabecalho		= $('input[type="text"],select','#'+frmCab);
    btnCab				= $('#btSalvar','#'+frmCab);

    // dados
    rDsaliena			= $('label[for="dsaliena"]','#'+frmDados);
    rFlgalfid			= $('label[for="flgalfid"]','#'+frmDados);
    rDtvigseg			= $('label[for="dtvigseg"]','#'+frmDados);
    rFlglbseg			= $('label[for="flglbseg"]','#'+frmDados);
    rFlgrgcar			= $('label[for="flgrgcar"]','#'+frmDados);
    rDtatugrv			= $('label[for="dtatugrv"]','#'+frmDados);
    rTpinclus			= $('label[for="tpinclus"]','#'+frmDados);

    cDsaliena			= $('#dsaliena','#'+frmDados);
    cFlgalfid			= $('#flgalfid','#'+frmDados);
    cDtvigseg			= $('#dtvigseg','#'+frmDados);
    cFlglbseg			= $('#flglbseg','#'+frmDados);
    cFlgrgcar			= $('#flgrgcar','#'+frmDados);
    cDtatugrv           = $('#dtatugrv','#'+frmDados);
    cTpinclus           = $('#tpinclus','#'+frmDados);
    cTodosDados			= $('input[type="text"],select','#'+frmDados);
    btnForm				= $('#btnFormulario','#'+frmDados);

    return false;
}


// controle
function controlaOperacao() {

    var mensagem = 'Aguarde, buscando dados ...';
    showMsgAguardo( mensagem );

    // Carrega dados da conta através de ajax
    $.ajax({
        type	: 'POST',
        dataType: 'html',
        url		: UrlSite + 'telas/aliena/principal.php',
        data    :
                {
                    cddopcao	: cddopcao,
                    nrdconta	: nrdconta,
                    nrctremp	: nrctremp,
                    redirect	: 'script_ajax'
                },
        error   : function(objAjax,responseError,objExcept) {
                    hideMsgAguardo();
                    showError('error','N&atilde;o foi possível concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','estadoInicial();');
                },
        success : function(response) {
                    try {
                        eval(response);
                        return false;
                    } catch(error) {
                        hideMsgAguardo();
                        showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','estadoInicial();');
                    }
                }
    });

    return false;
}

function manterRotina( operacao ) {

	hideMsgAguardo();

    var mensagem = '';
    var idseqbem = arrayAliena[indice]['idseqbem'];
    var flgperte = arrayAliena[indice]['flgperte'];
    var nrctrpro = arrayAliena[indice]['nrctrpro'];
    var cdsitgrv = arrayAliena[indice]['cdsitgrv'];
    var flgalfid = cFlgalfid.val();
    var dtvigseg = cDtvigseg.val();
    var flglbseg = cFlglbseg.val();
    var flgrgcar = cFlgrgcar.val();

    switch (operacao) {
        case 'V': mensagem = 'Aguarde, validando...'; break;
        case 'G': mensagem = 'Aguarde, gravando...'; break;
        default: return false; break;
    }

    showMsgAguardo( mensagem );

    $.ajax({
            type  : 'POST',
            url   : UrlSite + 'telas/aliena/manter_rotina.php',
            data: {
                operacao	: operacao,
                cddopcao	: cddopcao,
                nrdconta	: nrdconta,
                idseqttl	: '0',
                nrctrpro	: nrctrpro,
                nrctremp	: nrctremp,
                idseqbem	: idseqbem,
                flgalfid	: flgalfid,
                dtvigseg	: dtvigseg,
                flglbseg	: flglbseg,
                flgrgcar	: flgrgcar,
                flgperte	: flgperte,
                indice		: indice,
                redirect	: 'script_ajax'
            },
            error: function(objAjax,responseError,objExcept) {
                hideMsgAguardo();
                showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','estadoInicial();');
            },
            success: function(response) {
                try {
                    eval(response);
                    return false;
                } catch(error) {
                    hideMsgAguardo();
                    showError('error', error.message  /*'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.'*/,'Alerta - Ayllos','estadoInicial();');
                }
            }
        });

    return false;

}

function controlaPesquisas(opcao) {

    /*---------------------*/
    /*  CONTROLE CONTA/DV  */
    /*---------------------*/

    if (opcao == 1) {
        // Se esta desabilitado o campo da conta
        if ($("#nrdconta","#frmCab").prop("disabled") == true)  {
            return;
        }

        mostraPesquisaAssociado('nrdconta','frmCab','');
        return false;
    }

    /*--------------------*/
    /*  CONTROLE CONTRATO */
    /*--------------------*/

    if (opcao == 2) {
        // Se esta desabilitado o campo contrato
        if ($("#nrctremp","#frmCab").prop("disabled") == true)  {
            return;
        }

        mostraContrato();
        return false;
    }

    return false;

}


// formata
function controlaLayout() {

    $('fieldset').css({'clear':'both','border':'1px solid #777','margin':'3px 0px','padding':'2px 3px 5px 3px'});
    $('fieldset > legend').css({'font-size':'11px','color':'#777','margin-left':'5px','padding':'0px 2px'});
    $('#divBotoes').css({'text-align':'center','padding-top':'5px'});

    rDsaliena.addClass('rotulo').css({'width':'100px'});
    rDtatugrv.addClass('rotulo').css({'width':'100px'});
    rTpinclus.addClass('rotulo-linha').css({'width':'76px'});

    rFlgalfid.addClass('rotulo').css({'width':'100px'});
    rDtvigseg.addClass('rotulo-linha').css({'width':'76px'});
    rFlglbseg.addClass('rotulo-linha').css({'width':'73px'});
    rFlgrgcar.addClass('rotulo-linha').css({'width':'85px'});

    cDsaliena.css({'width':'513px'}).attr('maxlength','35');
    cDtatugrv.css({'width':'80px' }).addClass('data');
    cTpinclus.css({'width':'21px'}).attr('maxlength','1');

    cFlgalfid.css({'width':'80px' });
    cDtvigseg.css({'width':'80px' }).addClass('data');
    cFlglbseg.css({'width':'50px' });
    cFlgrgcar.css({'width':'50px' });

    if ( $.browser.msie ) {
        rFlgalfid.css({'width':'100px'});
        rDtatugrv.css({'width':'100px'});
        rTpinclus.css({'width':'76px'});
        rDtvigseg.css({'width':'76px'});
        rFlglbseg.css({'width':'78px'});
        rFlgrgcar.css({'width':'88px'});
        $('#'+frmDados).css({'margin-top': '-6px'});
    }

    cTodosDados.desabilitaCampo();

    // Todas opções
    if ( cddopcao != '' ) {
        cDtmvtolt.val(aux_dtmvtolt);
        cNmprimtl.val(aux_nmprimtl);

        if ( erro != '' ) {
            hideMsgAguardo();
            showError('error',erro,'Alerta - Ayllos','');
            erro = '';
            return false;
        } else {
            $('input, select', '#'+frmCab).desabilitaCampo();
        }

    }

    // Consulta
    if ( cddopcao == 'C' ) {
        montarTabela( arrayAliena );
        $('#btSalvar', '#divBotoes').hide();

    // Alteração
    } else if ( cddopcao == 'A' || cddopcao == 'S' ) {
        var i = indice + 1;

        $('fieldset > legend', '#'+frmDados).html( i + ' / ' + total );

        $('#btSalvar', '#divBotoes').hide();

        if ( indice < total ) {
            // Preenche o formulario conforme a sequencia
            cDsaliena.val( arrayAliena[indice]['dscatbem'] + ' \ ' + arrayAliena[indice]['dsbemfin'] );
            cFlgalfid.val( arrayAliena[indice]['flgalfid'] );
            cDtatugrv.val( arrayAliena[indice]['dtatugrv'] );
            cTpinclus.val( arrayAliena[indice]['tpinclus'] );
            cDtvigseg.val( arrayAliena[indice]['dtvigseg'] );
            cFlglbseg.val( arrayAliena[indice]['flglbseg'] );
            cFlgrgcar.val( arrayAliena[indice]['flgrgcar'] );

            // Habilita o campo conforme a regra estabilecida
            if ( cddopcao == 'A' && arrayAliena[indice]['flgperte'] == 'no' ) {
				cFlgalfid.habilitaCampo().focus();
                cDtvigseg.habilitaCampo();
                cFlglbseg.habilitaCampo();
                cFlgrgcar.habilitaCampo();
            } else if ( cddopcao == 'A' && arrayAliena[indice]['flgperte'] == 'yes' ) {
                cFlgalfid.habilitaCampo().focus();
            } else if ( cddopcao == 'S' ) {
                cDtvigseg.habilitaCampo();
                cDtvigseg.focus();
            }

            cDtatugrv.desabilitaCampo();
            cTpinclus.desabilitaCampo();

            if  (arrayAliena[indice]['cdsitgrv'] != 2) {
                cFlgalfid.habilitaCampo().focus();
            }
            else {
                cDtvigseg.habilitaCampo();
                cDtvigseg.focus();
                cFlgalfid.desabilitaCampo();
            }

            // Mostra o formulario
            $('#'+frmDados).css({'display': 'block'});

        } else {
            // Esconde o formulario após termina a sequencia
            $('#'+frmDados).css({'display': 'none'});
            $('#btSalvar', '#divBotoes').hide();
        }

		// Preencha a tabela
		montarTabela( arrayAux );

    }

    // Se clicar no botao OK
    btnForm.unbind('click').bind('click', function() {
        if ( divError.css('display') == 'block' ) { return false; }
        if ( indice >= total ) { return false; }
        manterRotina( 'V' );
        return false;

    });

    hideMsgAguardo();
    layoutPadrao();
    return false;

}

function formataCabecalho() {

    rCddopcao.css('width','45px');
    rNrdconta.addClass('rotulo-linha').css({'width':'42px'});
    rNrctremp.addClass('rotulo-linha').css({'width':'121px'});
    rDtmvtolt.addClass('rotulo-linha').css({'width':'160px'});
    rNmprimtl.addClass('rotulo').css({'width':'45px'});

    cCddopcao.css({'width':'571px'});
    cNrdconta.addClass('conta pesquisa').css({'width':'79px'});
    cNrctremp.addClass('contrato3 pesquisa').css({'width':'79px'});
    cDtmvtolt.addClass('data').css({'width':'79px'});
    cNmprimtl.addClass('alphanum').css({'width':'571px'}).attr('maxlength','50');

    if ( $.browser.msie ) {
        rNrdconta.css({'width':'44px'});
        rNrctremp.css({'width':'121px'});
        rDtmvtolt.css({'width':'160px'});
        cNrdconta.css({'width':'81px'});
        cNrctremp.css({'width':'81px'});
        cDtmvtolt.css({'width':'81px'});
    }

    cTodosCabecalho.habilitaCampo();
    cDtmvtolt.desabilitaCampo();
    cNmprimtl.desabilitaCampo();

    $('#cddopcao','#'+frmCab).focus();

    cNrdconta.unbind('keypress').bind('keypress', function(e) {
        if ( divError.css('display') == 'block' ) { return false; }
        // Se é a tecla ENTER,
        if ( e.keyCode == 13 ) {
            cNrctremp.focus();
            return false;
        } else if ( e.keyCode == 118 ) {
            mostraPesquisaAssociado('nrdconta', frmCab );
            return false;
        }
    });

    cNrctremp.unbind('keypress').bind('keypress', function(e) {
        if ( divError.css('display') == 'block' ) { return false; }
        // Se é a tecla ENTER,
        if ( e.keyCode == 13 ) {
            if ( normalizaNumero( cNrctremp.val() ) == 0 ) {
                mostraContrato();
            } else {
                btnContinuar();
            }
            return false;
        }
    });


    layoutPadrao();
    return false;
}


// tabela
function montarTabela( array ) {

    $('#'+tabDados).html(
    '<div class="divRegistros">	'+
        '<table>'+
            '<thead>'+
                '<tr>'+
                    '<th>Bem Financiado / Garantia</th>'+
                    '<th>Alienação</th>'+
                    '<th>Dt.Alien.</th>'+
                    '<th>Reg.</th>'+
                    '<th>Venc.Seg.</th>'+
                    '<th>Lib. Seg.</th>'+
                    '<th>Reg. Cart.</th>'+
                '</tr>'+
            '</thead>'+
            '<tbody>'+
            '</tbody>'+
        '</table>'+
    '</div>'
    );
    formataTabela( array );

}

function formataTabela( array ) {

    // tabela
    var divRegistro = $('div.divRegistros', '#'+tabDados);
    var tabela      = $('table', divRegistro );
    var linha       = $('table > tbody > tr', divRegistro );

    $('#'+tabDados).css({'margin-top':'5px'});
    divRegistro.css({'height':'150px','padding-bottom':'2px'});

    // Monta Tabela dos Itens
    $('#tabAliena > div > table > tbody').html('');

    for( var i in array ) {

        //alert('i: ' + i + ' -> ' + array[i]['dsbemfin']);
        var flgalfid = array[i]['flgalfid'] == 'yes' ? 'Ok'  : 'Pendente';
        var flglbseg = array[i]['flglbseg'] == 'yes' ? 'Sim' : 'Não';
        var flgrgcar = array[i]['flgrgcar'] == 'yes' ? 'Sim' : 'Não';

        $('#tabAliena > div > table > tbody').append('<tr></tr>');
        $('#tabAliena > div > table > tbody > tr:last-child').append('<td>'+ array[i]['dscatbem'] +' / '+ array[i]['dsbemfin'] +'</td>');
        $('#tabAliena > div > table > tbody > tr:last-child').append('<td>'+ flgalfid +'</td>');
        $('#tabAliena > div > table > tbody > tr:last-child').append('<td>'+ array[i]['dtatugrv'] +'</td>');
        $('#tabAliena > div > table > tbody > tr:last-child').append('<td>'+ array[i]['tpinclus'] +'</td>');
        $('#tabAliena > div > table > tbody > tr:last-child').append('<td>'+ array[i]['dtvigseg'] +'</td>');
        $('#tabAliena > div > table > tbody > tr:last-child').append('<td>'+ flglbseg +'</td>');
        $('#tabAliena > div > table > tbody > tr:last-child').append('<td>'+ flgrgcar +'</td>');
    }

    var ordemInicial = new Array();

    var arrayLargura = new Array();
    arrayLargura[0] = '230px';
    arrayLargura[1] = '60px';
    arrayLargura[2] = '62px';
    arrayLargura[3] = '32px';
    arrayLargura[4] = '62px';
    arrayLargura[5] = '60px';

    var arrayAlinha = new Array();
    arrayAlinha[0] = 'left';
    arrayAlinha[1] = 'center';
    arrayAlinha[2] = 'center';
    arrayAlinha[3] = 'center';
    arrayAlinha[4] = 'center';
    arrayAlinha[5] = 'center';
    arrayAlinha[6] = 'center';

    tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha, '' );
    $('#'+tabDados).css({'display':'block'});

    if ( cddopcao == 'C' ) {
        $('#btSalvar','#divBotoes').hide();
        $('#btVoltar','#divBotoes').focus();
    } else {
        $('#btSalvar','#divBotoes').hide();
  //      $('#btVoltar','#divBotoes').focus();
   //     cFlgalfid.focus();
    }

    return false;
}


// contrato
function mostraContrato() {

    showMsgAguardo('Aguarde, buscando ...');

    // Executa script de confirmação através de ajax
    $.ajax({
        type: 'POST',
        dataType: 'html',
        url: UrlSite + 'telas/aliena/contrato.php',
        data: {
            redirect: 'html_ajax'
            },
        error: function(objAjax,responseError,objExcept) {
            hideMsgAguardo();
            showError('error','Não foi possível concluir a requisição.','Alerta - Ayllos',"unblockBackground()");
        },
        success: function(response) {
            $('#divRotina').html(response);
            buscaContrato();
            return false;
        }
    });
    return false;

}

function buscaContrato() {

    showMsgAguardo('Aguarde, buscando ...');

    var nrdconta = normalizaNumero( cNrdconta.val() );

    $.ajax({
        type: 'POST',
        dataType: 'html',
        url: UrlSite + 'telas/aliena/busca_contrato.php',
        data: {
            nrdconta: nrdconta,
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
                    exibeRotina($('#divRotina'));
                    formataContrato();
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

function formataContrato() {

    var divRegistro = $('div.divRegistros','#divContrato');
    var tabela      = $('table', divRegistro );
    var linha       = $('table > tbody > tr', divRegistro );

    divRegistro.css({'height':'120px','width':'500px'});

    var ordemInicial = new Array();
    ordemInicial = [[0,0]];

    var arrayLargura = new Array();
    arrayLargura[0] = '60px';
    arrayLargura[1] = '62px';
    arrayLargura[2] = '80px';
    arrayLargura[3] = '60px';
    arrayLargura[4] = '80px';
    arrayLargura[5] = '38px';


    var arrayAlinha = new Array();
    arrayAlinha[0] = 'right';
    arrayAlinha[1] = 'left';
    arrayAlinha[2] = 'right';
    arrayAlinha[3] = 'right';
    arrayAlinha[4] = 'right';
    arrayAlinha[5] = 'right';
    arrayAlinha[6] = 'right';

    var metodoTabela = 'selecionaContrato();';

    tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha, metodoTabela );

    hideMsgAguardo();
    bloqueiaFundo( $('#divRotina') );

    return false;
}

function selecionaContrato() {

    if ( $('table > tbody > tr', 'div.divRegistros').hasClass('corSelecao') ) {

        $('table > tbody > tr', 'div.divRegistros').each( function() {
            if ( $(this).hasClass('corSelecao') ) {
                cNrctremp.val( $('#nrctremp', $(this) ).val() );
                return false;

            }
        });
    }

    fechaRotina($('#divRotina'));
    return false;
}


// mensagem
function mensagemAliena( strArray, metodo  ) {
    hideMsgAguardo();
    //alert('mensagemAliena: ' + strArray.length + ' - ' + metodo);
    if ( strArray != '' ) {
        // Definindo as variáveis
        var arrayMensagens	= new Array();
        var novoArray		= new Array();
        var elementoAtual	= '';
        // Setando os valores
        arrayMensagens 	= strArray.split('|');
        elementoAtual	= arrayMensagens.pop();
        arrayMensagens 	= implode( '|' , arrayMensagens);
        // Exibindo mensagem de erro
        showConfirmacao(elementoAtual,'Confirma&ccedil;&atilde;o - Ayllos',"mensagemAliena('"+arrayMensagens+"','"+metodo+"')",'','sim.gif','nao.gif');
    } else {
        eval(metodo);
    }
}


// botoes
function btnVoltar() {

    estadoInicial();
    return false;
}

function btnContinuar() {

    if ( cNrdconta.hasClass('campo') ) {
        if ( divError.css('display') == 'block' ) { return false; }
        if ( cNrdconta.hasClass('campoTelaSemBorda')  ) { return false; }
        //
        setGlobais();

        // Armazena o número da conta na variável global
        nrdconta = normalizaNumero( cNrdconta.val() );
        cddopcao = cCddopcao.val();
        nrctremp = normalizaNumero( cNrctremp.val() );

        // Verifica se o número da conta é vazio
        if ( nrdconta == '' ) { return false; }

        // Verifica se a conta é válida
        if ( !validaNroConta(nrdconta) ) {
            showError('error','Conta/dv inv&aacute;lida.','Alerta - Ayllos','focaCampoErro(\'nrdconta\',\''+ frmCab +'\');');
            return false;
        }

        // Se chegou até aqui, a conta é diferente do vazio e é válida, então realizar a operação desejada
        controlaOperacao( cddopcao );
        return false;

    } else if ( $('#'+frmDados).css('display') == 'block' ) {
        btnForm.click();
    }

    return false;
}


// set global
function setGlobais() {
    nrdconta 		= 0 ;
    nrctremp		= 0 ;

    arrayAliena		= new Array();
    arrayAux		= new Array();

    erro			= '';

    aux_dtmvtolt	= '';
    aux_nmprimtl	= '';

    total			= 0 ;
    indice			= 0 ;

    return false;
}

function LiberaCampos() {

    // Verifica se campo Opção está desativado.
    if( $('#cddopcao','#frmCab').hasClass('campoTelaSemBorda') ){ return false; }

    // Desabilita campo opção
    cTodosCabecalho		= $('input[type="text"],select','#frmCab');
    cTodosCabecalho.desabilitaCampo();

    $('#nrdconta','#frmCab').habilitaCampo();
    $('#nrctremp','#frmCab').habilitaCampo();

    $('#divBotoes', '#divTela').css({'display':'block'});

    $("#btSalvar","#divBotoes").show();
    $("#btVoltar","#divBotoes").show();

    return false;

}