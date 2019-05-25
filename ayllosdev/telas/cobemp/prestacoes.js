/*!
 * FONTE        : prestacoes.js
 * CRIAÇÃO      : Daniel Zimmermann
 * DATA CRIAÇÃO : 04/09/2015 
 * OBJETIVO     : Fonte baseado no fonte prestacoes.js da rotina de prestações da tela ATENDA 
 * 
 * --------------
 * ALTERAÇÕES   : 
 * --------------
 */

// Carrega biblioteca javascript referente ao RATING e CONSULTAS AUTOMATIZADAS
////$.getScript(UrlSite + "includes/rating/rating.js");
//$.getScript(UrlSite + "includes/consultas_automatizadas/protecao_credito.js");

var dataGlobal = '';

/* Variáveis para impressão */
var idimpres = 0;
var promsini = 1;
var flgemail = false;
var flgimpnp = '';
var flgimppr = '';
var cdorigem = 0;
var qtpromis = 0;
var nrJanelas = 0;

var nrdlinha = '';
var operacao = '';
var nomeForm = 'frmDadosPrest';
var tabDados = 'tabPrestacao';

var nrctremp = '';
var inprejuz = 0;
var operacao = '';
var cddopcao = '';
var idseqttl = 1;
var indarray = '';
var dtmvtolt = '';
var nrdrecid = '';
var tplcremp = '';
var tpemprst = 0;
var intpextr = '';

var flgPagtoAval = 0;
var nrAvalistas = 0;
var contAvalistas = 0;
var nrAlienacao = 0;
var contAlienacao = 0;
var nrIntervis = 0;
var contIntervis = 0;
var nrHipotecas = 0;
var contHipotecas = 0;
var dtpesqui = '';
var nrparepr = 0;
var vlpagpar = 0;
var glb_nriniseq = 1;
var glb_nrregist = 50;
var idSocio = 0;
var nrparepr_pos  = 0;
var vlpagpar_pos  = 0;
//var arrayBensAssoc = new Array();
var valorTotAPagar, valorAtual, valorTotAtual;

var nrctremp1, qtdregis1, nrdconta1, lstdtvcto1, lstdtpgto1, lstparepr1, lstvlrpag1;

/*!
 * OBJETIVO : Função de controle das ações/operações da Rotina de Bens da tela de CONTAS
 * PARÂMETRO: Operação que deseja-se realizar
 */
function controlaOperacao(operacao) {
    var mensagem = '';
    var iddoaval_busca = 0;
    var inpessoa_busca = 0;
    var nrdconta_busca = 0;
    var nrcpfcgc_busca = 0;
    var qtpergun = 0;
    var nrseqrrq = 0;

    if (in_array(operacao, [''])) {
        nrctremp = '';
    }

    switch (operacao) {

        case 'C_DESCONTO':
            mensagem = 'consultando desconto ...';
            break;
        case 'C_DESCONTO_POS':
            mensagem = 'consultando desconto ...';
            break;
        default   :
            cddopcao = 'C';
            mensagem = 'abrindo consultar...';
            break;
    }

    var inconcje = 0;

    $('#divContratos > .divRegistros .corSelecao #tpemprst').val()

    if (typeof arrayProposta != 'undefined') { // Consulta ao conjuge
        if (inpessoa == 1 && arrayRendimento['inconcje'] == 'yes') {
            inconcje = 1;
        }
    }

    if (typeof $('#divContratos > .divRegistros .corSelecao #tpemprst').val() != 'undefined'){
        tpemprst = $('#divContratos > .divRegistros .corSelecao #tpemprst').val();
    }

    var dtcnsspc = (typeof arrayProtCred == 'undefined') ? '' : arrayProtCred['dtcnsspc'];

    showMsgAguardo('Aguarde, ' + mensagem);

    // Carrega conteúdo da opção através do Ajax
    $.ajax({
        type: 'POST',
        dataType: 'html',
        url: UrlSite + 'telas/cobemp/principal.php',
        data: {
            nrdconta: nrdconta,
            idseqttl: idseqttl,
            nriniseq: glb_nriniseq,
            nrregist: glb_nrregist,
            operacao: operacao,
            nrctremp: nrctremp,
            prejuizo: inprejuz,
            dtpesqui: dtpesqui,
            tpemprst: tpemprst,
            nrparepr: nrparepr,
            vlpagpar: vlpagpar,
            inconcje: inconcje,
            dtcnsspc: dtcnsspc,
            idSocio: idSocio,
            iddoaval_busca: iddoaval_busca,
            inpessoa_busca: inpessoa_busca,
            nrdconta_busca: nrdconta_busca,
            nrcpfcgc_busca: nrcpfcgc_busca,
            nrseqrrq: nrseqrrq,
            qtpergun: qtpergun,
            cddopcao: cddopcao,
            inprodut: 1,
            nrdocmto: nrctremp,
            dtcopemp: dataGlobal,
            nrparepr_pos: nrparepr_pos,
            vlpagpar_pos: vlpagpar_pos,
            redirect: 'html_ajax'
        },
        error: function(objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError('error', 'N&atilde;o foi possível concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'bloqueiaFundo(divRotina)');
        },
        success: function(response) {

            if (response.indexOf('showError("error"') == -1) {
                if (operacao == 'C_DESCONTO' || operacao == 'C_DESCONTO_POS') {
                    eval(response);
                    hideMsgAguardo();
                    bloqueiaFundo(divRotina);
                }
            } else {
                eval(response);
                controlaFoco(operacao);
            }
            return false;
        }
    });
}

/*!
 * OBJETIVO : Controlar o layout da tela de acordo com a operação
 *            Algumas formatações CSS que não funcionam, são contornadas por esta função
 * PARÂMETRO: Valores válidos: [C] Consultando [A] Alterando [I] Incluindo
 */
function controlaLayout(operacao) {

    // Operação consultando
    if (in_array(operacao, ['C_PAG_PREST'])) {

        nomeForm = 'frmVlParc';
        altura = '295px';
        largura = '780px';

        var rTotAtual = $('label[for="totatual"]', '#' + nomeForm);
        var cTotAtual = $('#totatual', '#' + nomeForm);
        var rTotPagmto = $('label[for="totpagto"]', '#' + nomeForm);
        var cTotPagmto = $('#totpagto', '#' + nomeForm);
        var rVldifpar = $('label[for="vldifpar"]', '#' + nomeForm);
        var cVldifpar = $('#vldifpar', '#' + nomeForm);
        var rVlpagmto = $('label[for="vlpagmto"]', '#frmVlPagar');
        var cVlpagmto = $('#vlpagmto', '#frmVlPagar');

        var rPagtaval = $('label[for="pagtaval"]', '#' + nomeForm);
        var cPagtaval = $('#pagtaval', '#' + nomeForm);

        rTotAtual.addClass('rotulo').css({'width': '110px', 'padding-top': '3px', 'padding-bottom': '3px'});
        rVlpagmto.addClass('rotulo').css({'width': '80px', 'padding-top': '3px', 'padding-bottom': '3px'});

        if ($.browser.msie) {
            rTotPagmto.addClass('rotulo').css({'width': '80px', 'margin-left': '385px'});
            rVldifpar.addClass('rotulo').css({'width': '70px', 'padding-bottom': '5px', 'margin-left': '587px'});
            cTotAtual.addClass('campo').css({'width': '70px', 'padding-top': '3px', 'padding-bottom': '3px'});
            cVlpagmto.addClass('campo').css({'width': '70px', 'margin-right': '10px'});
            cTotPagmto.addClass('campo').css({'width': '70px', 'padding-top': '3px', 'padding-bottom': '3px', 'margin-left': '09px'});
            cVldifpar.addClass('campo').css({'width': '70px', 'margin-left': '0px'});
        } else {
            rTotPagmto.addClass('rotulo').css({'width': '80px', 'margin-left': '392px'});
            rVldifpar.addClass('rotulo').css({'width': '70px', 'padding-bottom': '5px', 'margin-left': '600px'});
            cTotAtual.addClass('campo').css({'width': '70px', 'padding-top': '3px', 'padding-bottom': '3px', 'margin-right': '25px'});
            cVlpagmto.addClass('campo').css({'width': '70px', 'margin-right': '10px'});
            cTotPagmto.addClass('campo').css({'width': '70px', 'padding-top': '3px', 'padding-bottom': '3px', 'margin-right': '25px'});
            cVldifpar.addClass('campo').css({'width': '70px', 'margin-right': '10px'});
        }

        cTotPagmto.addClass('rotulo moeda').desabilitaCampo();
        cVldifpar.addClass('rotulo moeda').desabilitaCampo();
        cTotAtual.addClass('rotulo moeda').desabilitaCampo();
        cVlpagmto.addClass('rotulo moeda');

        // Define se mostra o campo "Pagamento Avalista"
        if (flgPagtoAval) {
            rPagtaval.show();
            cPagtaval.show();
        } else {
            rPagtaval.hide();
            cPagtaval.hide();
        }

        // Configurações da tabela
        var divTabela = $('#divTabela');
        var divRegistro = $('div.divRegistros', divTabela);
        var tabela = $('table', divRegistro);

        divRegistro.css({'height': '160px', 'border-bottom': '1px dotted #777', 'padding-bottom': '2px'});
        divTabela.css({'border': '1px solid #777', 'margin-bottom': '3px', 'margin-top': '3px'});

        $('tr.sublinhado > td', divRegistro).css({'text-decoration': 'underline'});

        var ordemInicial = new Array();

        var arrayLargura = new Array();
        arrayLargura[0] = '13px';
        arrayLargura[1] = '55px';
        arrayLargura[2] = '55px';
        arrayLargura[3] = '52px';
        arrayLargura[4] = '53px';
        arrayLargura[5] = '43px';
        arrayLargura[6] = '73px';
        arrayLargura[7] = '60px';
        arrayLargura[8] = '45px';
        arrayLargura[9] = '57px';
        arrayLargura[9] = '42px';

        var arrayAlinha = new Array();
        arrayAlinha[0] = 'center';
        arrayAlinha[1] = 'center';
        arrayAlinha[2] = 'center';
        arrayAlinha[3] = 'right';
        arrayAlinha[4] = 'right';
        arrayAlinha[5] = 'right';
        arrayAlinha[6] = 'right';
        arrayAlinha[7] = 'right';
        arrayAlinha[8] = 'right';
        arrayAlinha[9] = 'right';
        arrayAlinha[10] = 'center';

        tabela.formataTabela(ordemInicial, arrayLargura, arrayAlinha, '');

        $("th:eq(0)", tabela).removeClass();
        $("th:eq(0)", tabela).unbind('click');

        // Adiciona função que ao selecionar o checkbox header, marca/desmarca todos os checkboxs da tabela
        if (typeof $('#divContratos > .divRegistros .corSelecao #tpemprst').val() != 'undefined'){
            tpemprst = $('#divContratos > .divRegistros .corSelecao #tpemprst').val();
        }

        // Click do chekbox de Todas as parcelas
        $("input[type=checkbox][name='checkTodos']").unbind('click').bind('click', function() {

            var selec = this.checked;

            $("input[type=checkbox][name='checkParcelas[]']").prop("checked", selec);

            $("input[type=checkbox][name='checkParcelas[]']").each(function() {
                habilitaDesabilitaCampo(this, false);
            });

            recalculaTotal();

            vlpagpar = "";

            var vlr = 0;

            $("input[type=text][name='vlpagpar[]']").each(function() {
                nrParcela = this.id.split("_")[1];
                vlPagar = this.value;

                vlr = selec ? $('#check_' + nrParcela).attr('vldescto') : '0,00';

                vlpagpar = (vlpagpar == "") ? nrParcela + ";" + vlPagar : vlpagpar + "|" + nrParcela + ";" + vlPagar;

                //se for pos
                if (tpemprst == 2){
                    descontoPos(nrParcela, vlr);
                }
            });

            if (tpemprst != 2){
            desconto(0);
            }

            // Limpar Valor a pagar
            cVlpagmto.val("");
        });

        // Desabilita o campo 'Valor a antecipar' e define o click do checkbox para habilitar/desabilitar o campo
        $("input[type=text][name='vlpagpar[]']").each(function() {
            nrParcela = this.id.split("_")[1];
            $('#vlpagpar_' + nrParcela, tabela).addClass('rotulo moeda');
            $('#vlpagpar_' + nrParcela, tabela).css({'width': '70px'}).desabilitaCampo();
        });

        $("input[name='checkParcelas[]']", tabela).unbind('click').bind('click', function() {
            nrParcela = this.id.split("_")[1];
            habilitaDesabilitaCampo(this, true);
            vlr = $(this).is(':checked') ? $(this).attr('vldescto') : '0,00';

            //se for pos
            if (tpemprst == 2){
                descontoPos(nrParcela, vlr);
            }else{
            desconto(nrParcela);
            }
            
            cVlpagmto.val("");
        });

        $("input[type=text][name='vlpagpar[]']").blur(function() {
            recalculaTotal();
            nrParcela = this.id.split("_")[1];
            vlr = $(this).is(':checked') ? $(this).attr('vldescto') : '0,00';

            if (!$(this).prop("disabled")) {
                if (tpemprst == 2){
                    descontoPos(nrParcela, vlr);
                }else{
                desconto(nrParcela);
                }
            }
            cVlpagmto.val("");
        });

        cVlpagmto.unbind('blur').bind('blur', function() {
            atualizaParcelas();
            vlpagpar = "";
            $("input[type=text][name='vlpagpar[]']").each(function() {
                nrParcela = this.id.split("_")[1];
                vlPagar = this.value;
                vlpagpar = (vlpagpar == "") ? nrParcela + ";" + vlPagar : vlpagpar + "|" + nrParcela + ";" + vlPagar;
            });
        });

        cVlpagmto.unbind('keypress').bind('keypress', function(e) {
            // Se é a tecla ENTER, 
            if ((e.keyCode == 13) || (e.keyCode == 9)) {
                desconto(0);
            }
        });

        valorTotAPagar = 0;
        $("input[type=hidden][name='vlpagpar[]']").each(function() {
            // Valor total a pagar
            valorTotAPagar = valorTotAPagar + parseFloat(this.value.replace(",", "."));
        });

        valorTotAtual = 0;
        $("input[type=hidden][name='vlatupar[]']").each(function() {
            // Valor total a atual
            valorTotAtual += retiraMascara(this.value);
        });

        $("input[type=hidden][name='vlmtapar[]']").each(function() {
            // Valor total a atual
            valorTotAtual += retiraMascara(this.value);
        });

        $("input[type=hidden][name='vlmrapar[]']").each(function() {
            // Valor total a atual
            valorTotAtual += retiraMascara(this.value);
        });

        $("input[type=hidden][name='vliofcpl[]']").each(function() {
            // Valor total a atual
            valorTotAtual += parseFloat(this.value.replace(",", "."));
        });

        $('#totatual', '#frmVlParc').val(valorTotAtual.toFixed(2).replace(".", ","));
        $('#totpagto', '#frmVlParc').val('0,00');
        $('#vldifpar', '#frmVlParc').val('0,00');
    }

    divRotina.css('width', largura);
    $('#divConteudoOpcao').css({'height': altura, 'width': largura});

    layoutPadrao();

    /* Na tela de pagamento das parcelas, nao podemos disparar o evento onblur */
    if (nomeForm != 'frmVlParc') {
        $('input', '#' + nomeForm).trigger('blur');
    }

    hideMsgAguardo();
    bloqueiaFundo(divRotina);
    removeOpacidade('divConteudoOpcao');
    divRotina.centralizaRotinaH();
    controlaFoco(operacao);
    return false;
}

function strSelect(str, campo, form) {

    var arrayOption = new Array();
    var select = $('#' + campo, '#' + form);

    arrayOption = str.split(',');

    for (i in arrayOption) {
        select.append('<option value="' + arrayOption[i] + '">' + arrayOption[i] + '</option>');
    }
    return false;
}

// Habilita e desabilita os campos de acordo com o checkbox
function habilitaDesabilitaCampo(object, flgRecalcula, nrParcela)
{
    var divTabela = $('#divTabela');
    var divRegistro = $('div.divRegistros', divTabela);
    var tabela = $('table', divRegistro);

    if (typeof (nrParcela) == 'undefined')
    {
        if (typeof (object.id) == 'undefined')
            nrParcela = this.id.split("_")[1];
        else
            nrParcela = object.id.split("_")[1];
    }

    if ($('#check_' + nrParcela + ':checked', tabela).val() == 'on') {

        $('#vlpagpar_' + nrParcela, tabela).habilitaCampo();
        // Manipulação de dados referente aos campos do valor de antecipação de parcelas
        valorAtual = retiraMascara($('#vlatupar_' + nrParcela, tabela).val());
        valorMulta = retiraMascara($('#vlmtapar_' + nrParcela, tabela).val());
        valorMora = retiraMascara($('#vlmrapar_' + nrParcela, tabela).val());
        valorIOF = retiraMascara($('#vliofcpl_' + nrParcela, tabela).val());

        valorAtual += valorMulta + valorMora + valorIOF;

        $('#vlpagpar_' + nrParcela, tabela).val(valorAtual.toFixed(2).replace(".", ","));

    } else {
        $('#vlpagpar_' + nrParcela, tabela).val('0,00').desabilitaCampo();
    }

    $("#vlpagan_" + nrParcela, tabela).val($('#vlpagpar_' + nrParcela, divTabela).val());

    if (flgRecalcula) {
        recalculaTotal();
    }
}

function retiraMascara(numero)
{
    numero = parseFloat(numero.replace(".", "").replace(",", "."));
    return numero;
}

// Recalcula o valor total
function recalculaTotal()
{
    valorAPagar = 0;

    $("input[type=text][name='vlpagpar[]']").each(function() {
        valorAPagar = valorAPagar + retiraMascara($(this).val());
    });

    $('#totpagto', '#frmVlParc').val(valorAPagar.toFixed(2).replace(".", ","));
    $('#vldifpar', '#frmVlParc').val('0,00');
}

// Atualiza o valor das parcelas, caso seja informado o campo total a pagar
function atualizaParcelas()
{
    var valorTotPgto = retiraMascara($('#vlpagmto', '#frmVlPagar').val());
    var divTabela = $('#divTabela');
    var divRegistro = $('div.divRegistros', divTabela);
    var tabela = $('table', divRegistro);
    var valorPagar = 0;
    $('#totpagto', '#totpagto').val("0,00");

    // Desmarca todas as parcelas
    $("input[type=checkbox][name='checkParcelas[]']").each(function() {
        if (this.checked == true)
        {
            this.checked = false;
            habilitaDesabilitaCampo(this, false);
        }
    });

    recalculaTotal();

    if (valorTotPgto > 0)
    {
        var diferenca = false;
        parcela = 1;

        while (!diferenca)
        {
            nrParcela = $('#parcela_' + parcela, tabela).val();
            if (typeof ($('#vlatupar_' + nrParcela, tabela).val()) == 'undefined') {
                diferenca = true;
            }
            else
            {
                valorAtual = retiraMascara($('#vlatupar_' + nrParcela, tabela).val());
                valorPagar = retiraMascara($('#vlpagpar_' + nrParcela, tabela).val());

                if (valorTotPgto >= valorAtual)
                {
                    $('#check_' + nrParcela, tabela).prop('checked', true);
                    habilitaDesabilitaCampo('', true, nrParcela);
                    valorAtual = retiraMascara($('#vlatupar_' + nrParcela, tabela).val());
                    valorPagar = retiraMascara($('#vlpagpar_' + nrParcela, tabela).val());
                    valorTotPgto = valorTotPgto - valorPagar;
                }
                else
                    diferenca = true;
            }
            parcela++;
        }
        $('#vldifpar', '#frmVlParc').val(valorTotPgto.toFixed(2).replace(".", ","));
    }
}

function verificaDesconto(campo, flgantec, parcela) {

    var vlpagan = $("#vlpagan_" + parcela, "#divTabela");

    if (isHabilitado(campo) && retiraMascara(vlpagan.val()) != retiraMascara(campo.val()) && flgantec == 'yes') {
        desconto(parcela);
    }

    vlpagan.val(campo.val());
}

function desconto(parcela) {

    var dtvencto = '';

    if (document.getElementById("rdvencto1").checked == true) {
        dtvencto = $('#dtmvtolt', '#frmGerarBoletoPP').val();
    } else {
        dtvencto = $('#dtvencto', '#frmGerarBoletoPP').val();
    }

    dataGlobal = dtvencto;

    if (parcela != 0) {
        vlpagpar = parcela + ";" + $("#vlpagpar_" + parcela, "#divTabela").val();
    }

    controlaOperacao("C_DESCONTO");
}

function descontoPos (parcela,valor) {
    $('#vldespar_' + parcela ,'#divTabela').html(valor);
}

function verificaDescontoPos(campo , insitpar , parcela) {

    var vlpagan = $("#vlpagan_" + parcela,"#divTabela");

    if (isHabilitado(campo) && retiraMascara(vlpagan.val()) != retiraMascara(campo.val()) && insitpar == 3) { // 3 - A Vencer
        nrparepr_pos = parcela;
        vlpagpar_pos = converteMoedaFloat(campo.val());
        controlaOperacao("C_DESCONTO_POS");
    }
    vlpagan.val(campo.val());

}