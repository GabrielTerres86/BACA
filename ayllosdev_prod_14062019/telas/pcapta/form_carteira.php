<?php
/* !
 * FONTE        : form_carteira.php
 * CRIAÇÃO      : Jean Michel         
 * DATA CRIAÇÃO : 30/04/2014
 * OBJETIVO     : Formulario de carteira da tela PCAPTA
 * --------------
 * ALTERAÇÕES   : 
 * --------------
 */

session_start();
require_once('../../includes/config.php');
require_once('../../includes/funcoes.php');
require_once('../../includes/controla_secao.php');
require_once('../../class/xmlfile.php');
isPostMethod();

setVarSession('nmrotina', 'CARTEIRA');

// Montar o xml de Requisicao
$xml = "<Root>";
$xml .= " <Dados>";
$xml .= " </Dados>";
$xml .= "</Root>";

// Chama procedure consulta indexadores	
$xmlResult = mensageria($xml, "PCAPTA", "CONCOP", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
$xmlObj = getObjectXML($xmlResult);

// Verifica se houve erro
if (strtoupper($xmlObj->roottag->tags[0]->name == 'ERRO')) {
    $msgErro = $xmlObj->roottag->tags[0]->cdata;
    if ($msgErro == null || $msgErro == '') {
        $msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
    }
    echo "<script>";
    exibirErro('error', $msgErro, 'Alerta - Ayllos', '', false);
    echo "</script>";
} else {
    $cooperativas = $xmlObj->roottag->tags;
}
?>
<div id="carteiraConsulta">
    <fieldset>
        <legend>Movimenta&ccedil;&atilde;o da Carteira</legend>
        <table class="tabelaFiltro">
            <tr>
                <td>
                    <label for="dtmvtolt">Movimento:</label>
                    <input class="campo" type="text" name="dtmvtolt" id="dtmvtolt" value="<?php echo $glbvars["dtmvtolt"]; ?>" />
                </td>
            </tr>
            <tr>
                <td>
                    <label style="width: 130px" for="cdcoope">Cooperativa:</label>
                    <select style="width: 150px" class="campo" name="cdcooper" id="cdcoope">
                        <?php if (count($cooperativas) > 1) { ?>
                            <option value="0">-- Todos --</option>    
                            <?php
                        }
                        foreach ($cooperativas as $registro) {
                            echo '<option value="' . str_replace(PHP_EOL, "", $registro->tags[0]->cdata) . '">' . $registro->tags[1]->cdata . '</option>';
                        }
                        ?>                          
                    </select>
                </td>
            </tr>

        </table>
        <div id="divRetorno"></div>
    </fieldset>
    <table class="tableAcoes">
        <tr class="">
            <td>
                <input type="button" id="btVoltar" name="btVoltar" class="botao" value="Voltar" onclick="fnVoltar();" />
            </td>
            <td>
                <input type="button" id="btFiltrar" name="btFiltrar" class="botao" value="Filtrar" onclick="javascript:void(0);" />&nbsp;
            </td>            
        </tr>        
    </table>

</div>
<style type="text/css">
    #pcapta fieldset table {
        margin-left: 85px;
    }
    table.tituloRegistros {
        margin-left: 0px !important;
    }
    #divPesquisaRodape table {
        margin-left: 0px !important;
    }
    table.tableAcoes {
        margin-left: 195px;
    }
</style>
<script type="text/javascript">

    $(function() {
        
        $("#btFiltrar").unbind('click').bind('click', function() {
           listaMovimentacaoCarteira(1, 20); 
        });
        
        // controla foco da tela
        $("#cdcoope").unbind('keypress').bind('keypress', function(e) {
            if (e.keyCode == 9 || e.keyCode == 13) {
                listaMovimentacaoCarteira(1, 20);
                return false;
            }
        });
    });

    /**
     * @opcao C - Carteira de Captacao
     * @name listaMovimentacaoCarteira
     * @param Integer nriniseq
     * @param Integer nrregist
     * @returns tabela com dados filtrados
     */
    function listaMovimentacaoCarteira(nriniseq, nrregist) {
        $("#cdcoope").prop('disabled', true);
        btnFiltra.prop('disabled', true);
        $("tr.linhaBotoes").hide();

        showMsgAguardo("Aguarde, carregando dados...");

        $.ajax({
            type: "POST",
            url: UrlSite + "telas/pcapta/ajax_carteira.php",
            async: false,
            data: {
                cdcooper: $("#cdcoope").val(),
                dtmvtolt: cDtmvtolt.val(),
                nriniseq: nriniseq,
                nrregist: nrregist,
                redirect: "script_ajax"
            },
            success: function(data) {
                if (data.indexOf('showError("error"') == -1) {
                    $('#divRetorno').empty().html(data);
                    formataTabelaIndice();
                    $("table.tableAcoes").hide();
                    ocultaMsgAguardo();
                } else {
                    eval(data);
                    ocultaMsgAguardo();
                }
            }
        });
    }


    /**
     * @opcao C - Carteira de Captacao
     * @name formataTabelaIndice
     * @returns tabela com dados formatada
     */
    function formataTabelaIndice() {

        // Tabela
        $('#tabIndice').css({'display': 'block'});
        $('#divConsulta').css({'display': 'block'});

        var divRegistro = $('div.divRegistros', '#tabIndice');
        var tabela = $('table', divRegistro);
        var linha = $('table > tbody > tr', divRegistro);

        $('#tabIndice').css({'margin-top': '5px'});
        divRegistro.css({'height': '150px', 'width': '590px', 'padding-bottom': '2px'});

        var ordemInicial = new Array();

        var arrayLargura = new Array();
        arrayLargura[0] = '207px';
        arrayLargura[1] = '108px';
        arrayLargura[2] = '108px';
        //arrayLargura[3] = '110px';

        var arrayAlinha = new Array();
        arrayAlinha[0] = 'left';
        arrayAlinha[1] = 'center';
        arrayAlinha[2] = 'center';
        arrayAlinha[3] = 'center';

        var metodoTabela = 'verDetalhe(this)';

        tabela.formataTabela(ordemInicial, arrayLargura, arrayAlinha, metodoTabela);

        return false;
    }

</script>