/*!
 * FONTE        : pcapta.js
 * CRIAÇÃO      : Carlos Rafael Tanholi
 * DATA CRIAÇÃO : 02/07/2014
 * OBJETIVO     : Biblioteca de funções da tela PCAPTA
 * --------------
 * ALTERAÇÕES   : 25/09/2018 - Inclusão do campo indplano (Apl. Programada) - Proj. 411.2  (CIS Corporate)
 * --------------
 *                23/10/2018 - Inclusão dos campos para Teimosinha,Debito parcial, Valor Minimo
 *                             Autoatendimento e Resg. Programado (Apl. Programada) - Proj. 411.2  (CIS Corporate)
 * 
 */

//Formulários
var frmCab = 'frmCab';

var rNmprodut, rNommitra, rIdsitpro, rCddindex, rIdtippro, rIdtxfixa, rIdacumul, rIndplano, rCdprodut, rQtdiacar, rQtdiaprz, rVlrfaixa, rVlperren, rVltxfixa, rCdcooper, rCdnomenc, rDsnomenc, rQtmincar, rVlminapl;
var rNmprodus, rIdsitnom, rCdhscacc, rCdhsvrcc, rCdhsraap, rCdhsnrap, rCdhsprap, rCdhsrvap, rCdhsrdap, rCdhsirap, rCdhsrgap, rCdhsvtap, rDtmvtolt, rCddopcao, rIndteimo, rIndparci, rVlminimo;
var rAutoAten, rIndRgtPr, rDsCaract

var cNmprodut, cNommitra, cIdsitpro, cCddindex, cIdtippro, cIdtxfixa, cIdacumul, cIndplano, cCdprodut, cQtdiacar, cQtdiaprz, cVlrfaixa, cVlperren, cVltxfixa, cCdcooper, cCdnomenc, cDsnomenc, cQtmincar, cQtmaxcar, cVlminapl, cVlmaxapl;
var cNmprodus, cIdsitnom, cCdhscacc, cCdhsvrcc, cCdhsraap, cCdhsnrap, cCdhsprap, cCdhsrvap, cCdhsrdap, cCdhsirap, cCdhsrgap, cCdhsvtap, cDtmvtolt, cCddopcao, cIndteimo, cIndparci, cVlminimo;
var cAutoAten, CIndRgtPr, cDsCaract

var btnAltera, btnConsul, btnExclui, btnInclui, btnVoltar, btnAtivar, btnBloque, btnDesblo, btnDefini, btnFiltra, btnProseg, btnCancel;

var glb_nriniseq = 1;  /* Numero inicial da listagem de registros, opcao C e R */
var glb_nrregist = 20; /* Numero de registros por pagina, opcao C e R */

$(document).ready(function() {

    estadoInicial();

    highlightObjFocus($('#' + frmCab));

    $('fieldset > legend').css({'font-size': '11px', 'color': '#777', 'margin-left': '5px', 'padding': '0px 2px'});
    $('fieldset').css({'clear': 'both', 'border': '1px solid #777', 'margin': '3px 0px', 'padding': '10px 3px 5px 3px'});

    return false;

});

// seletores
function estadoInicial() {

    $('#divTela').fadeTo(0, 0.1);
    $('#frmCab').css({'display': 'block'});

    // Botões
    btnAltera = $('#btAltera', '#' + frmCab);
    btnConsul = $('#btConsul', '#' + frmCab);
    btnExclui = $('#btExclui', '#' + frmCab);
    btnInclui = $('#btInclui', '#' + frmCab);
    btnVoltar = $('#btVoltar', '#' + frmCab);
    btnProseg1 = $('#btProseg', '#' + frmCab);
    btnCancel1 = $('#btCancel', '#' + frmCab);
    btnFiltra = $('#btFiltrar', '#' + frmCab);
    btnAtivar = $('#btAtivar', '#' + frmCab);
    btnBloque = $('#btBloque', '#' + frmCab);
    btnDesblo = $('#btDesblo', '#' + frmCab);
    btnDefini = $('#btDefini', '#' + frmCab);

    //Label
    rCddopcao = $('label[for="cddopcao"]', '#' + frmCab);
    rNmprodut = $('label[for="nmprodut"]', '#' + frmCab);
    rNmprodus = $('label[for="nmprodus"]', '#' + frmCab);
    rNommitra = $('label[for="nommitra"]', '#' + frmCab);
    rIdsitpro = $('label[for="idsitpro"]', '#' + frmCab);
    rCddindex = $('label[for="cddindex"]', '#' + frmCab);
    rIdtippro = $('label[for="idtippro"]', '#' + frmCab);
    rIdtxfixa = $('label[for="idtxfixa"]', '#' + frmCab);
    rIdacumul = $('label[for="idacumul"]', '#' + frmCab);
    rIndplano = $('label[for="indplano"]', '#' + frmCab);
    rCdprodut = $('label[for="cdprodut"]', '#' + frmCab);
    rQtdiacar = $('label[for="qtdiacar"]', '#' + frmCab);
    rQtdiaprz = $('label[for="qtdiaprz"]', '#' + frmCab);
    rVlrfaixa = $('label[for="vlrfaixa"]', '#' + frmCab);
    rVlperren = $('label[for="vlperren"]', '#' + frmCab);
    rVltxfixa = $('label[for="vltxfixa"]', '#' + frmCab);
    rCdcooper = $('label[for="cdcooper"]', '#' + frmCab);
    rCdnomenc = $('label[for="cdnomenc"]', '#' + frmCab);
    rDsnomenc = $('label[for="dsnomenc"]', '#' + frmCab);
    rQtmincar = $('label[for="qtmincar"]', '#' + frmCab);
    rVlminapl = $('label[for="vlminapl"]', '#' + frmCab);
    rIdsitnom = $('label[for="idsitnom"]', '#' + frmCab);
    rCdhscacc = $('label[for="cdhscacc"]', '#' + frmCab);
    rCdhsvrcc = $('label[for="cdhsvrcc"]', '#' + frmCab);
    rCdhsraap = $('label[for="cdhsraap"]', '#' + frmCab);
    rCdhsnrap = $('label[for="cdhsnrap"]', '#' + frmCab);
    rCdhsprap = $('label[for="cdhsprap"]', '#' + frmCab);
    rCdhsrvap = $('label[for="cdhsrvap"]', '#' + frmCab);
    rCdhsrdap = $('label[for="cdhsrdap"]', '#' + frmCab);
    rCdhsirap = $('label[for="cdhsirap"]', '#' + frmCab);
    rCdhsrgap = $('label[for="cdhsrgap"]', '#' + frmCab);
    rCdhsvtap = $('label[for="cdhsvtap"]', '#' + frmCab);
    rDtmvtolt = $('label[for="dtmvtolt"]', '#' + frmCab);
    rIndteimo = $('label[for="indteimo"]', '#' + frmCab);
    rIndparci = $('label[for="indparci"]', '#' + frmCab);
    rVlminimo = $('label[for="vlminimo"]', '#' + frmCab);
    rAutoAten = $('label[for="indautoa"]', '#' + frmCab);
    rIndRgtPr = $('label[for="indrgtpr"]', '#' + frmCab);
    rDsCaract = $('label[for="dscaract"]', '#' + frmCab);

    //Campos
    cCddopcao = $('#cddopcao', '#' + frmCab);
    cNmprodut = $('#nmprodut', '#' + frmCab);
    cNmprodus = $('#nmprodus', '#' + frmCab);
    cNommitra = $('#nommitra', '#' + frmCab);
    cIdsitpro = $('#idsitpro', '#' + frmCab);
    cCddindex = $('#cddindex', '#' + frmCab);
    cIdtippro = $('#idtippro', '#' + frmCab);
    cIdtxfixa = $('#idtxfixa', '#' + frmCab);
    cIdacumul = $('#idacumul', '#' + frmCab);
    cIndplano = $('#indplano', '#' + frmCab);
    cCdprodut = $('#cdprodut', '#' + frmCab);
    cQtdiacar = $('#qtdiacar', '#' + frmCab);
    cQtdiaprz = $('#qtdiaprz', '#' + frmCab);
    cVlrfaixa = $('#vlrfaixa', '#' + frmCab);
    cVlperren = $('#vlperren', '#' + frmCab);
    cVltxfixa = $('#vltxfixa', '#' + frmCab);
    cCdcooper = $('#cdcooper', '#' + frmCab);
    cCdnomenc = $('#cdnomenc', '#' + frmCab);
    cDsnomenc = $('#dsnomenc', '#' + frmCab);
    cQtmincar = $('#qtmincar', '#' + frmCab);
    cQtmaxcar = $('#qtmaxcar', '#' + frmCab);
    cVlminapl = $('#vlminapl', '#' + frmCab);
    cVlmaxapl = $('#vlmaxapl', '#' + frmCab);
    cIdsitnom = $('#idsitnom', '#' + frmCab);
    cCdhscacc = $('#cdhscacc', '#' + frmCab);
    cCdhsvrcc = $('#cdhsvrcc', '#' + frmCab);
    cCdhsraap = $('#cdhsraap', '#' + frmCab);
    cCdhsnrap = $('#cdhsnrap', '#' + frmCab);
    cCdhsprap = $('#cdhsprap', '#' + frmCab);
    cCdhsrvap = $('#cdhsrvap', '#' + frmCab);
    cCdhsrdap = $('#cdhsrdap', '#' + frmCab);
    cCdhsirap = $('#cdhsirap', '#' + frmCab);
    cCdhsrgap = $('#cdhsrgap', '#' + frmCab);
    cCdhsvtap = $('#cdhsvtap', '#' + frmCab);
    cDtmvtolt = $('#dtmvtolt', '#' + frmCab);
    cIndteimo = $('#indteimo', '#' + frmCab);
    cIndparci = $('#indparci', '#' + frmCab);
    cVlminimo = $('#vlminimo', '#' + frmCab);
    cAutoAten = $('#indautoa', '#' + frmCab);
    cIndRgtPr = $('#indrgtpr', '#' + frmCab);
    cDsCaract = $('#dscaract', '#' + frmCab);

    removeOpacidade('divTela');
    unblockBackground();
    hideMsgAguardo();
    layoutPadrao();
    formataCabecalho();
    controlaFoco();

    cCdcooper.attr("disabled", true);
    cNmprodut.attr("disabled", true);
    cNmprodus.attr("disabled", true);
    cCdprodut.attr("disabled", true);
    cNommitra.attr("disabled", true);
    cIdsitpro.attr("disabled", true);
    cCddindex.attr("disabled", true);
    cIdtippro.attr("disabled", true);
    cIdtxfixa.attr("disabled", true);
    cIdacumul.attr("disabled", true);
    cIndplano.attr("disabled", true);
    cVltxfixa.attr("disabled", true);  
    cVlperren.attr("disabled", true);  
    cIndteimo.attr("disabled", true);
    cIndparci.attr("disabled", true);
    cVlminimo.attr("disabled", true);
    cAutoAten.attr("disabled", true);
    cIndRgtPr.attr("disabled", true);
    cDsCaract.attr("readonly", true);    

    // PCAPTA - Historicos
    cCdhscacc.attr("disabled", true);
    cCdhsvrcc.attr("disabled", true);
    cCdhsraap.attr("disabled", true); 
    cCdhsnrap.attr("disabled", true); 
    cCdhsprap.attr("disabled", true);
    cCdhsrvap.attr("disabled", true);
    cCdhsrdap.attr("disabled", true); 
    cCdhsirap.attr("disabled", true); 
    cCdhsrgap.attr("disabled", true); 
    cCdhsvtap.attr("disabled", true);    
    cCdnomenc.attr("disabled", true);
    cQtmincar.attr("disabled", true);    
    cQtmaxcar.attr("disabled", true);    
    cVlminapl.attr("disabled", true);    
    cVlmaxapl.attr("disabled", true);    
    cIdsitnom.attr("disabled", true);    

    $('input,select', '#frmCab').removeClass('campoErro');
    rCddopcao.css('width', '45px');
    cCddopcao.css({'width': '455px'});
    $('#cddopcao', '#' + frmCab).focus();
}

function formataCabecalho() {

    cTodosCabecalho = $('input[type="text"],select', '#' + frmCab);

    var caracteresesp = '!@#$%&*()_+=§:<>;/?[]{}°ºª¬¢£,.´`¨^~¨¹²³£¬§&\'\"\\|';
    var caracteresespDec = '!@#$%&*()_+=§:<>/?[]{}°ºª¬¢£´`¨^~¨¹²³£¬§&\'\"\\|';

    /* Posicionamento Labels */

    rNmprodut.css('width', '130px');
    rNmprodus.css('width', '130px');
    rNommitra.css('width', '130px');
    rIdsitpro.css('width', '130px');
    rCddindex.css('width', '130px');
    rIdtippro.css('width', '130px');
    rIdtxfixa.css('width', '130px');
    rIdacumul.css('width', '130px');
    rIndplano.css('width', '130px');
    rCdprodut.css('width', '130px');
    rQtdiacar.css('width', '130px');
    rQtdiaprz.css('width', '130px');
    rVlrfaixa.css('width', '130px');
    rVlperren.css('width', '130px');
    rVltxfixa.css('width', '130px');
    rCdcooper.css('width', '130px');
    rCdnomenc.css('width', '130px');
    rDsnomenc.css('width', '130px');
    rQtmincar.css('width', '130px');
    rVlminapl.css('width', '130px');
    rIdsitnom.css('width', '130px');
    rCdhscacc.css('width', '250px');
    rCdhsvrcc.css('width', '250px');
    rCdhsraap.css('width', '250px');
    rCdhsnrap.css('width', '250px');
    rCdhsprap.css('width', '250px');
    rCdhsrvap.css('width', '250px');
    rCdhsrdap.css('width', '250px');
    rCdhsirap.css('width', '250px');
    rCdhsrgap.css('width', '250px');
    rCdhsvtap.css('width', '250px');
    rDtmvtolt.css('width', '130px');
    rIndteimo.css('width', '130px');
    rIndparci.css('width', '130px');
    rVlminimo.css('width', '130px');
    rAutoAten.css('width', '130px');
    rIndRgtPr.css('width', '130px');
    rDsCaract.css('width', '130px');
    

    /* Tamanho Campos */
    cNmprodut.css({'width': '150px'});
    cNmprodus.css({'width': '150px'});
    cNommitra.css({'width': '150px'});
    cIdsitpro.css({'width': '150px'});
    cCddindex.css({'width': '150px'});
    cIdtippro.css({'width': '150px'});
    cCdprodut.css({'width': '150px'});
    cQtdiacar.css({'width': '150px'});
    cQtdiaprz.css({'width': '150px'});
    cVlrfaixa.css({'width': '150px'});
    cVlperren.css({'width': '150px'});
    cVltxfixa.css({'width': '150px'});
    cCdcooper.css({'width': '150px'});
    cCdnomenc.css({'width': '180px'});
    cDsnomenc.css({'width': '160px'});
    cQtmincar.css({'width': '70px'});
    cQtmaxcar.css({'width': '70px'});
    cVlminapl.css({'width': '105px'});
    cVlmaxapl.css({'width': '105px'});
    cIdsitnom.css({'width': '125px'});
    cCdhscacc.css({'width': '90px'});
    cCdhsvrcc.css({'width': '90px'});
    cCdhsraap.css({'width': '90px'});
    cCdhsnrap.css({'width': '90px'});
    cCdhsprap.css({'width': '90px'});
    cCdhsrvap.css({'width': '90px'});
    cCdhsrdap.css({'width': '90px'});
    cCdhsirap.css({'width': '90px'});
    cCdhsrgap.css({'width': '90px'});
    cCdhsvtap.css({'width': '90px'});
    cDtmvtolt.css({'width': '150px'});
    cDtmvtolt.css({'text-align': 'right'});
    cVlminimo.css({'width': '150px'});
    cVlminimo.css({'text-align': 'right'});

    cTodosCabecalho.habilitaCampo();

    $("#dtmvtolt", "#" + frmCab).attr("disabled", true);

    $('#nmprodut', '#' + frmCab).focus();

    //elimina os acentos e caracteres especiais
    cNmprodut.setMask('STRING', 'ZZZZZZZZZZZZZZZZZZZZ', caracteresesp);
    cDsnomenc.setMask('STRING', 'ZZZZZZZZZZZZZZZZZZZZ', caracteresesp);

    return false;
}


function controlaFoco() {

    $('#cddopcao', '#frmCab').unbind('keypress').bind('keypress', function(e) {
        if (e.keyCode == 9 || e.keyCode == 13) {
            escolheOpcao($('#cddopcao').val(), 0);
            return false;
        }
    });

    $('#btFiltrar', '#frmCab').unbind('keypress').bind('keypress', function(e) {
        if (e.keyCode == 9 || e.keyCode == 13) {
            listaMovimentacaoCarteira(1, 20);
            return false;
        }
    });
    /*Fim Opcao C*/

    $('#btnOK', '#frmCab').unbind('keypress').bind('keypress', function(e) {
        if (e.keyCode == 9 || e.keyCode == 13) {
            escolheOpcao($('#cddopcao').val(), 0);
            return false;
        }
    });

}

function fnVoltar() {
    var frmVisible = $("#frmTaxas").is(':visible');

    if (cCddopcao.val() == 'C' && frmVisible == true) {
        escolheOpcao("C", 0);
    } else {
        $("#pcapta div").each(function(i) {

            $(this).hide();
        });
    }

    $("#frmCab").trigger('reset');
    $('#cddopcao', '#' + frmCab).val('C');
    $('#cddopcao', '#' + frmCab).trigger("change");
    $('#cddopcao', '#' + frmCab).focus();

}

/* Funcao de redirecionamento de pagina */
function redirecionaPagina()
{
    $("#divTela").html(resposta);
}

var resposta = '' //variavel que recebe o retorno de erro desta funcao
function escolheOpcao(cddopcao, stropcao) {

    var dsrotina = '';
    var permissao = '';
        
    $("#pcapta div").each(function(i) {
        $(this).hide();
    });

    $("table.tableAcoes").hide();

    if (cddopcao == 'C') {
        dsrotina = 'form_carteira.php';
    } else if (cddopcao == 'D') {
        dsrotina = 'form_definicao.php';
    } else if (cddopcao == 'H') {
        dsrotina = 'form_historico.php';
    } else if (cddopcao == 'M') {
        dsrotina = 'form_modalidade.php';
    } else if (cddopcao == 'N') {
        dsrotina = 'form_nomenclatura.php';
    } else if (cddopcao == 'P') {
        dsrotina = 'form_produto.php';
    }

    if (stropcao == null || stropcao == 0 || stropcao == '') {
        // Mostra mensagem de aguardo
        showMsgAguardo("Aguarde, carregando dados...");

        // Executa script de bloqueio atravï¿½s de ajax
        $.ajax({
            type: "POST",
            dataType: 'html',
            url: UrlSite + "telas/pcapta/" + dsrotina,
            data: {
                redirect: "html_ajax"
            },
            success: function(response) {
                hideMsgAguardo();
                //valida se a sessao do navegador nao expirou
                if ( response.indexOf('Sess&atilde;o n&atilde;o registrada.') != -1 || response.indexOf('login_sistemas.php') != -1) {
                    resposta = response;
                    redirecionaPagina();
                } else {
                    $("#pcapta", "#" + frmCab).html(response);
                    estadoInicial();                    
                }
            }     
        });

    // VALIDACAO DE ACESSO AS OPCOES
    } else if ( stropcao != 'V' ) { //se opcao for diferente de voltar
        // Mostra mensagem de aguardo
        showMsgAguardo("Aguarde, validando acesso...");        
        $.ajax({
            type: "POST",
            url: UrlSite + "telas/pcapta/ajax_valida_acesso.php",
            async: false,
            data: {
                cddopcao: cddopcao,
                stropcao: stropcao
            },
            success: function(data) {
                if ( data != '' ) {
                    hideMsgAguardo();
                    showError("error", data, "Alerta - Ayllos", "");
                    permissao = 'N';
                } else {
                    //caso o operador tenha permissao e a opcao for diferente de Consulta da erro
                    
                    if ( cddopcao == 'D' ) { //definicao politica
                        if ( stropcao != 'C' && ($("#nvoperad").val() != 3 || $("#cdcooper").val() != 3) ) {
                            showError("error", "036 - Opera&ccedil;&atilde;o n&atilde;o autorizada.", "Alerta - Ayllos", "hideMsgAguardo();");
                            permissao = 'N';                            
                        } else {
                            hideMsgAguardo();
                            permissao = 'S';                                                    
                        }
                    } else if ( cddopcao == 'M' ) { //opcao modalidade
                        //if ( stropcao != 'C' && $("#nvoperad").val() != 3 && $("#cdcooper").val() != 3 ) { 
                        if ( stropcao != 'C' && ($("#nvoperad").val() != 3 || $("#cdcooper").val() != 3) ) {
                            showError("error", "036 - Opera&ccedil;&atilde;o n&atilde;o autorizada.", "Alerta - Ayllos", "hideMsgAguardo();");
                            permissao = 'N';
                        } else {
                            hideMsgAguardo();
                            permissao = 'S';                                                    
                        }
                    } else  {
                        hideMsgAguardo();
                        permissao = 'S';                        
                    }
                }
            }
        });
    }

    if ( permissao == 'S' ) {
                
        switch (cddopcao)
        {
            case 'C':
                cCdcooper.prop('disabled', false);
                cCdcooper.attr('disabled', false);
                $("#carteiraConsulta #btFiltrar").focus();
                break;
            case 'D':
                 switch (stropcao) {
                    
                    case 'B':
						carregaComboProdutos('A');
                        $("#hdnCodSubOpcao").val('B');
                        cCdcooper.attr('disabled', false);
                        cCdprodut.attr('disabled', false);
                        $('#definicaoConsulta legend').text('Políticas da Cooperativa - Bloquear');
                        $('#definicaoConsulta, tr.linhaBotoes').show();
                        $("#cdcooper", "#" + frmCab).focus();
                        break;

                    case 'C':
						carregaComboProdutos('T');
                        $("#hdnCodSubOpcao").val('C');
                        cCdcooper.attr('disabled', false);
                        cCdprodut.attr('disabled', false);
                        $('#definicaoConsulta legend').text('Políticas da Cooperativa - Consultar');                    
                        $('#definicaoConsulta, tr.linhaBotoes').show();
                        $("#cdcooper", "#" + frmCab).focus();                        
                        break;

                    case 'I':
						carregaComboProdutos('A');					
                        $("#hdnCodSubOpcao").val('I');
                        cCdcooper.attr('disabled', false);
                        cCdprodut.attr('disabled', false);
                        cQtdiacar.empty().attr('disabled', false);
                        cQtdiaprz.empty().attr('disabled', false);
                        cVlrfaixa.empty().attr('disabled', false);
                        $('#definicaoConsulta legend').text('Políticas da Cooperativa - Inserir');                    
                        $('#definicaoConsulta, tr.linhaBotoes').show();
                        $("#cdcooper", "#" + frmCab).focus();
                        break;

                    case 'D':
						carregaComboProdutos('A');					
                        $("#hdnCodSubOpcao").val('D');
                        cCdcooper.attr('disabled', false);
                        cCdprodut.attr('disabled', false);
                        $('#definicaoConsulta legend').text('Políticas da Cooperativa - Desbloquear');                    
                        $('#definicaoConsulta, tr.linhaBotoes').show();
                        $("#cdcooper", "#" + frmCab).focus();
                        break;

                    case 'E':
						carregaComboProdutos('A');
                        $("#hdnCodSubOpcao").val('E');
                        cCdcooper.attr('disabled', false);
                        cCdprodut.attr('disabled', false);
                        $('#definicaoConsulta legend').text('Políticas da Cooperativa - Excluir');                    
                        $('#definicaoConsulta, tr.linhaBotoes').show();
                        $("#cdcooper", "#" + frmCab).focus();
                        break;

                    case 'A':
						carregaComboProdutos('T');
                        $("#hdnCodSubOpcao").val('A');
                        cCdcooper.attr('disabled', false);
                        cCdprodut.attr('disabled', false);
                        $('#definicaoConsulta legend').text('Políticas da Cooperativa - Alterar');                    
                        $('#definicaoConsulta, tr.linhaBotoes').show();
                        $("#cdcooper", "#" + frmCab).focus();                        
                        break;

                    default:

                        break;
                }
                break;
            case 'H':

                switch (stropcao) {

                    case 'A':
                        carregaComboProdutos('A');
                        $("#historicosDados #hdnAcao").val('A');
                        btnProseg1.hide();
                        $("tr.linhaBotoes #btVoltar").css('margin-left', '215px');                            
                        $('table.tableAcoes').hide();
                        $('#historicosDados .linhaBotoes').show();
                        cCdprodut.attr('disabled', false); 
                        $('#historicosDados legend').eq(0).text('Históricos - Alterar');
                        $('#historicosDados').show();
                        $("#cdprodut", "#" + frmCab).focus();
                        break;

                    case 'C':
                        carregaComboProdutos('C');
                        $("#historicosDados #hdnAcao").val('C');
                        btnProseg1.hide();
                        $("tr.linhaBotoes #btVoltar").css('margin-left', '215px');
                        $('table.tableAcoes').hide();
                        $('#historicosDados .linhaBotoes').show();
                        cCdprodut.attr('disabled', false); 
                        $('#historicosDados legend').eq(0).text('Históricos - Consultar');                    
                        $('#historicosDados').show();
                        $("#cdprodut", "#" + frmCab).focus();
                        break;

                    case 'V':
                        $("#hdnAcao").val('');
                        fnVoltar();
                        break;

                    default:
                        $("#hdnAcao").val('');
                        $('#historicosDados').show();                        
                        break;
                }

                break;
            case 'M':
                $("#stropcao").val(stropcao);
                switch (stropcao) {
                    
                    case 'C':
                        //ambos produtos Ativos - Inativos
                        carregaComboProdutos('C');                        
                        cNmprodut.attr('disabled', false);
                        cCddindex.attr("disabled", true);
                        $('table.tableAcoes').hide();
                        $('#modalidadesProdConsult tr.linhaBotoes').show();
                        $('#modalidadesProdConsult legend').text('Modalidades do Produto - Consultar');
                        $('#modalidadesProdConsult').show();
                        $("#nmprodut", "#" + frmCab).focus();
                        break;

                    case 'E':
                        //apenas produtos Ativos
                        carregaComboProdutos('E');
                        cNmprodut.attr('disabled', false);
                        cCddindex.attr("disabled", true);
                        $('table.tableAcoes').hide();
                        $('#modalidadesProdExcluir tr.linhaBotoes').show();
                        $('#modalidadesProdExcluir').show();
                        $('#modalidadesProdConsult legend').text('Modalidades do Produto - Excluir');                        
                        $("#nmprodut", "#" + frmCab).focus();                        
                        break;

                    case 'I':
                        //apenas produtos Ativos
                        carregaComboProdutos('I');
                        cCdprodut.attr("disabled", false);
                        cQtdiacar.attr("disabled", false);
                        cQtdiaprz.attr("disabled", false);
                        cVlrfaixa.attr("disabled", false);
                        cVltxfixa.attr("disabled", false);  
                        cVlperren.attr("disabled", false);                      
                        $('table.tableAcoes').hide();
                        $('#modalidadesProdIncluir tr.linhaBotoes').show();
                        $('#modalidadesProdIncluir').show();
                        $('#modalidadesProdIncluir legend').text('Modalidades do Produto - Inserir');
                        $("#cdprodut", "#" + frmCab).focus();                        
                        break;

                    case 'V':
                        $('#modalidadesProdConsult').show();
                        $('#modalidadesProdConsult legend').text('Modalidades do Produto');
                        break;
                    default:
                        $('#modalidadesProdConsult').show();
                        $('#modalidadesProdConsult legend').text('Modalidades do Produto');
                        break;
                }

                break;
            case 'N':
                $('#nomenclaturaDados').show();
                $("#hdnAplicacao, #hdnCdnomenc").val('');
                cCdnomenc.show();
                rCdnomenc.show();
                cDsnomenc.hide();
                rDsnomenc.hide();
                $("tr.linhaBotoes #btVoltar").css('margin-left', '120px');
                switch (stropcao) {

                    case 'A':
                        //produtos Ativos
                        carregaComboProdutos('A');                         
                        $("#nomenclaturaDados #hdnAcao").val('A');
                        cCdprodut.attr("disabled", false);

                        $('tr.linhaBotoes').show();   
                        $("#cdprodut", "#" + frmCab).focus();
                        $('#nomenclaturaDados legend').text('Dados Nomenclatura - Alterar');
                        cDsCaract.removeAttr("readonly");
                        break;

                    case 'C':
                        //ambos produtos Ativos - Inativos
                        carregaComboProdutos('C');                         
                        $("#nomenclaturaDados #hdnAcao").val('C');
                        $("tr.linhaBotoes #btVoltar").css('margin-left', '185px');
                        btnProseg1.hide();
                        cCdprodut.attr("disabled", false);
                        cCdnomenc.attr("disabled", false);
                        $('tr.linhaBotoes').show();
                        $("#cdprodut", "#" + frmCab).focus();   
                        $('#nomenclaturaDados legend').text('Dados Nomenclatura - Consultar');                        
                        break;

                    case 'E':
                        //produtos Ativos
                        carregaComboProdutos('A');                        
                        $("#nomenclaturaDados #hdnAcao").val('E');
                        cCdprodut.attr("disabled", false);
                        cCdnomenc.attr("disabled", false);

                        $('tr.linhaBotoes').show();
                        $("#cdprodut", "#" + frmCab).focus();       
                        $('#nomenclaturaDados legend').text('Dados Nomenclatura - Excluir');                        
                        break;

                    case 'I':
                        //produtos Ativos
                        carregaComboProdutos('A');                        
                        $("#nomenclaturaDados #hdnAcao").val('I');
                        cCdnomenc.hide();
                        rCdnomenc.hide();
                        cDsnomenc.show();
                        rDsnomenc.show();                    

                        cDsnomenc.attr("disabled", false);
                        cCdprodut.attr("disabled", false);
                        cCdnomenc.attr("disabled", false);
                        cQtmincar.attr("disabled", false);
                        cQtmaxcar.attr("disabled", false);
                        cVlminapl.attr("disabled", false);
                        cVlmaxapl.attr("disabled", false);
                        cIdsitnom.attr("disabled", false);
                        cDsCaract.removeAttr("readonly");

                        $('tr.linhaBotoes').show();
                        $("#cdprodut", "#" + frmCab).focus();   
                        $('#nomenclaturaDados legend').text('Dados Nomenclatura - Inserir');                        
                        break;

                    case 'V':
                        $('#nomenclaturaDados legend').text('Dados Nomenclatura');                        
                        break;
                    default:

                        break;
                }

                break;
            case 'P':

                $('#dadosProdutos').show();

                switch (stropcao) {

                    case 'A':
                        carregaComboProdutos();
                        $("tr.linhaBotoes #btVoltar").css('margin-left', '125px');
                        $("#hdnAcaoP", "#" + frmCab).val('A');
                        $('tr.linhaBotoes').show();
                        //mostra o campo select de nome
                        cNmprodus.show();
                        rNmprodus.show();
                        //esconde o campo texto de nome
                        cNmprodut.hide();
                        rNmprodut.hide();
                        //habilita os botoes de acao
                        btnProseg1.show();
                        btnVoltar.show();
                        //habilita o campo de filtro para nome
                        cNmprodus.attr("disabled", false);
                        //desabilita os d+ campos
                        cNmprodut.attr("disabled", false);
                        cCddindex.attr("disabled", true);
                        cIdsitpro.attr("disabled", true);
                        cIdtippro.attr("disabled", true);
                        cIdtxfixa.attr("disabled", true);
                        cIdacumul.attr("disabled", true);
                        cIndplano.attr("disabled", true);
                        $("#dadosProdutos legend").text('Dados do Produto - Alterar');
                        $("#nmprodus", "#" + frmCab).focus();                        
                        break;

                    case 'C':
                        btnProseg1.hide();
                        carregaComboProdutos();
                        $("#hdnAcaoP", "#" + frmCab).val('C');
                        $('tr.linhaBotoes').show();
                        $("tr.linhaBotoes #btVoltar").css('margin-left', '170px');
                        //habilita o campo de filtro para nome
                        cNmprodus.attr("disabled", false);
                        cNmprodus.show();
                        rNmprodus.show();
                        //desabilita o campo descritivo de nome
                        cNmprodut.attr("disabled", true);
                        cNmprodut.hide();
                        rNmprodut.hide();

                        cNommitra.attr("disabled", true);
                        cIdsitpro.attr("disabled", true);
                        cCddindex.attr("disabled", true);
                        cIdtippro.attr("disabled", true);
                        cIdtxfixa.attr("disabled", true);
                        cIdacumul.attr("disabled", true);
                        cIndplano.attr("disabled", true);
                        $("#dadosProdutos legend").text('Dados do Produto - Consultar');
                        
                        $("#nmprodus", "#" + frmCab).focus();                        
                        break;

                    case 'E':
                        carregaComboProdutos();
                        $("tr.linhaBotoes #btVoltar").css('margin-left', '125px');                        
                        $("#hdnAcaoP", "#" + frmCab).val('E');
                        $('tr.linhaBotoes').show();
                        //habilita o campo de filtro para nome
                        cNmprodus.attr("disabled", false);
                        cNmprodus.show();
                        rNmprodus.show();
                        //desabilita o campo descritivo de nome
                        cNmprodut.attr("disabled", true);
                        cNmprodut.hide();
                        rNmprodut.hide();

                        cNommitra.attr("disabled", true);
                        cIdsitpro.attr("disabled", true);
                        cCddindex.attr("disabled", true);
                        cIdtippro.attr("disabled", true);
                        cIdtxfixa.attr("disabled", true);
                        cIdacumul.attr("disabled", true);
                        cIndplano.attr("disabled", true);
                        $("#dadosProdutos legend").text('Dados do Produto - Excluir');
                        
                        $("#nmprodus", "#" + frmCab).focus();                        
                        break;

                    case 'I':
                        $("#hdnCarteira, #hdnModalidade").val(''); //limpa os campos carregados na alteracao
                        $("tr.linhaBotoes #btVoltar").css('margin-left', '125px');                        
                        $("#hdnAcaoP", "#" + frmCab).val('I');
                        $('tr.linhaBotoes').show();
                        cNmprodus.hide();
                        rNmprodus.hide();
                        cNmprodut.show();
                        rNmprodut.show();
                        btnProseg1.show();
                        btnVoltar.show();
                        cNmprodut.attr("disabled", false);
                        cNmprodus.attr("disabled", false);
                        cNommitra.attr("disabled", false);
                        cIdsitpro.attr("disabled", false);
                        cCddindex.attr("disabled", false);
                        cIdtippro.attr("disabled", false);
                        cIdtxfixa.attr("disabled", false);
                        cIdacumul.attr("disabled", false);
                        cIndplano.attr("disabled", false);

                        $('input:radio[name=idtxfixa][value=1]').attr('checked', true);
                        $('input:radio[name=idacumul][value=1]').attr('checked', true);
                        $('input:radio[name=indplano][value=1]').attr('checked', true);

                        cNmprodut.focus();
                        $("#dadosProdutos legend").text('Dados do Produto - Inserir');                    
                        break;

                    case 'V':

                        fnVoltar();
                        break;
                    default:

                        break;
                }
                break;
        }
    }
}




//************* FUNCOES ESPECIFICAS DAS PAGINAS ****************/

function resetaForm(divPrincipal)
{   //redefine o titulo da com a acao do formulario
    var titulo = $("#" + divPrincipal + " fieldset legend").text().split('-');
    $("#" + divPrincipal + " fieldset legend").eq(0).text(titulo[0]);

    $("#" + divPrincipal + " table td select").each(function() {
        $(this).find("option[value=0]").attr("selected", "selected");
        $(this).attr("disabled", true);
    });

    $("#" + divPrincipal + " table td input[type=text]").each(function() {
        $(this).val("");
        $(this).attr("disabled", true);
    });

    $("#" + divPrincipal + " table td input[type=radio]").each(function() {
        $(this).removeAttr("checked");
        $(this).attr("disabled", true);
    });

    $("#" + divPrincipal + " table td textarea").each(function() {
        $(this).val("");
        $(this).attr("readonly", true);
    });

    btnProseg1.show();

    $("table.tableAcoes #btVoltar").css('margin-left', '0px !important');
    
    $("#hdnProdSel, #hdnNomeSel").val('0');

    $("tr.linhaBotoes").hide();
    $("table.tableAcoes").show();
    
    return false;
}

function resetaCampos() {

    $("#pcapta table td select").each(function() {
        $(this).find("option[value=0]").attr("selected", "selected");
        $(this).removeAttr('disabled');
    });

    $("#pcapta table td input[type=text]").each(function() {
        $(this).val("");
        $(this).attr("disabled", true);
    });

    $("#pcapta input[type=hidden]").each(function() {
        $(this).val("");
    });

    $("input#cddindex").each(function() {
        $(this).val('');
    });

    $("#pcapta table td select").each(function() {
        $(this).find("option[value=0]").attr("selected", "selected");
        $(this).removeAttr('disabled');
    });

    $('#indplano', '#frmCab').prop( "checked", false );
    $('#indteimo', '#frmCab').prop( "checked", false );
    $('#indparci', '#frmCab').prop( "checked", false );
    $('#vlminimo', '#frmCab').val('');
    $('#indautoa', '#frmCab').prop( "checked", false );
    $('#indrgtpr', '#frmCab').prop( "checked", false );

    $("div.divRetorno").hide();
    $("tr.linhaBotoes").show();
    return false;
}

function btnVoltarOpcoes()
{

    $("table td select").each(function() {
        $(this).find("option[value=0]").attr("selected", "selected");
        $(this).attr("disabled", true);
    });

    $("table td input[type=text]").each(function() {
        $(this).val("");
        $(this).attr("disabled", true);
    });

    $("table td input[type=radio]").each(function() {
        $(this).removeAttr("checked");
        $(this).attr("disabled", true);
    });    


    $("tr.linhaBotoes").hide();
    $("table.tableAcoes").show();    
    
    return false;
    
}

function ocultaMsgAguardo()
{
    var varHide = false;
    varHide = setTimeout('hideMsgAguardo();', 500);
}