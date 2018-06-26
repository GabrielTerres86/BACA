<?php
/* !
 * FONTE        : form_gerar_boleto.php
 * CRIAÇÃO      : Luis Fernando (GFT)
 * DATA CRIAÇÃO : 22/05/2018
 * OBJETIVO     : Tela do formulario de geração de Boletopara a COBTIT
 */
?>

<?php
session_start();
require_once('../../includes/config.php');
require_once('../../includes/funcoes.php');
require_once('../../includes/controla_secao.php');
require_once('../../class/xmlfile.php');
isPostMethod();

$flavalis = (isset($_POST['flavalis'])) ? $_POST['flavalis'] : 0;
$nrdconta = (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : 0;
$nrborder = (isset($_POST['nrborder'])) ? $_POST['nrborder'] : 0;

// Montar o xml de Requisicao

$xml  = "<Root>";
$xml .= " <Dados>";
$xml .= " </Dados>";
$xml .= "</Root>";

$xmlResultado = mensageria($xml, "COBTIT", "BUSCA_PRAZO_VCTO_MAX_COBTIT", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
$xmlObj = getClassXML($xmlResultado);
$root = $xmlObj->roottag;
// Se ocorrer um erro, mostra crítica
if ($root->erro){
    exibeErro(htmlentities($root->erro->registro->dscritic));
    exit;
}
$przmax = $root->dados->przmaximo;

$maxDate = DateTime::createFromFormat("d/m/Y",$glbvars["dtmvtolt"]);
$maxDate = $maxDate->add(new DateInterval('P'.$przmax.'D'));
$maxDate = $maxDate->format("d/m/Y");


if ($flavalis == 1) {
    $xml = "<Root>";
    $xml .= " <Dados>";
    $xml .= "   <nrdconta>".$nrdconta."</nrdconta>";
    $xml .= "   <nrborder>".$nrborder."</nrborder>";
    $xml .= " </Dados>";
    $xml .= "</Root>";

    $xmlResult = mensageria($xml,"COBTIT","LISTA_AVALISTAS", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
    $xmlObj = getClassXML($xmlResult);
    $root = $xmlObj->roottag;
    // Se ocorrer um erro, mostra crítica
    if ($root->erro){
        exibeErro(htmlentities($root->erro->registro->dscritic));
        exit;
    }

    $avalistas = $root->dados->find("avalista");
}
?>

<script>
    $(document).ready(function() {
        retornaListaFeriados();
        function isAvailable (date) {
            var mes = "";
            var dia = "";
            var ano = "";
            if (date.getMonth() < 9){
              mes = "0" + (date.getMonth() + 1).toString();
            } else{
              mes = (date.getMonth() + 1).toString(); ;
            }

            if (date.getDate() < 10){
              dia = "0" + date.getDate().toString();
            } else{
              dia = date.getDate().toString();
            }
            ano = date.getFullYear().toString();
            var dateAsString = ano + "/" + mes + "/" + dia;
            var resultado = $.inArray (dateAsString, arrayFeriados) == - 1 ?  [true]: [false];
            if (date.getDay() == 0 || date.getDay() == 6){
              resultado = false;
            }
            return resultado;
        }

        $.datepicker.setDefaults($.datepicker.regional[ "pt-BR" ]);
        $("#dtvencto").datepicker({
            defaultDate: "<?php echo $glbvars["dtmvtolt"]; ?>",
            minDate: "<?php echo $glbvars["dtmvtolt"]; ?>",
            maxDate: "<?php echo $maxDate; ?>",
            beforeShowDay: isAvailable,
            showOn: "button",
            buttonImage: UrlSite + "imagens/geral/btn_calendario.gif",
            buttonImageOnly: true,
            buttonText: "Calendario"
        });
        $("#dtvencto").datepicker("option", "dateFormat", "dd/mm/yy");
        $("#dtvencto").datepicker("option", "gotoCurrent", true);
        habilitaDataVencimentoTR();
        habilitaAvalista();
    });
</script>
<style>
    .ui-datepicker-trigger{
        float:left;
        margin-left:2px;
        margin-top:3px;
    }
</style> 

<table width="100%" id="telaGerarBoleto" cellpadding="0" cellspacing="0" border="0" >
    <tr>
        <td align="center">		
            <table width="100%" border="0" cellpadding="0" cellspacing="0"  >
                <tr>
                    <td>
                        <table width="100%" border="0" cellspacing="0" cellpadding="0">
                            <tr>
                                <td width="11"><img src="<?php echo $UrlImagens; ?>background/tit_tela_esquerda.gif" width="11" height="21"></td>
                                <td class="txtBrancoBold ponteiroDrag" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif"><?php echo utf8ToHtml('Gerar Boleto') ?></td>
                                <td width="12" id="tdTitTela" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif"><a href="#" onClick="fechaRotina($('#divRotina')); return false;"><img src="<?php echo $UrlImagens; ?>geral/excluir.jpg" width="12" height="12" border="0"></a></td>
                                <td width="8"><img src="<?php echo $UrlImagens; ?>background/tit_tela_direita.gif" width="8" height="21"></td>
                            </tr>
                        </table>     
                    </td> 
                </tr>    
                <tr>
                    <td class="tdConteudoTela" align="center">	
                        <table width="100%" border="0" cellspacing="0" cellpadding="0">
                            <tr>
                                <td>
                                    <table border="0" cellspacing="0" cellpadding="0">
                                        <tr>
                                            <td width="1"></td>
                                        </tr>
                                    </table>
                                </td>
                            </tr>
                            <tr>
                                <td align="center" style="border: 2px solid #969FA9; background-color: #F4F3F0; padding: 2px;">
                                    <div id="divGerarBoleto" >
                                        <form id="frmGerarBoleto" name="frmGerarBoleto" class="formulario" onSubmit="return false;">

                                            <br style="clear:both" />       

                                            <fieldset>
                                                <legend align="left">Vencimento</legend>
                                                <input type="radio" id="rdvencto1" class="campo" name="rdvencto" value="1" onclick="$('#dtvencto').val('');habilitaDataVencimentoTR(false)" /> <label style="margin-left:10px">Nesta Data</label>
                                                <br style="clear:both" />   
                                                <input type="radio" id="rdvencto2" class="campo" name="rdvencto" value="2" onclick="habilitaDataVencimentoTR(true)" /> <label style="margin-left:10px">Data Futura:</label>
                                                <input type="text" id="dtvencto" class="campo" name="dtvencto" readonly="true"/>
                                                <input type="hidden" id="dtmvtolt" class="campo" name="dtmvtolt" value="<?php echo $glbvars["dtmvtolt"]; ?>"/>
                                            </fieldset>
                                            <br style="clear:both" />

                                            <?php
                                                // Se possui Avalista
                                                if ($flavalis == 1) {
                                                    ?>
                                                    <fieldset>
                                                        <legend align="left">Sacado</legend>
                                                        <input type="radio" id="rdsacado1" class="campo" name="rdsacado" value="1" onclick="$('#nrcpfava').val('');habilitaAvalista(1)" /> <label style="margin-left:10px">Devedor</label>
                                                        <br style="clear:both" />   
                                                        <input type="radio" id="rdsacado2" class="campo" name="rdsacado" value="2" onclick="habilitaAvalista(2)" /> <label style="margin-left:10px">Avalista:</label>
                                                        <select name="nrcpfava" id="nrcpfava" class="campo">
                                                            <option value=""></option>
                                                            <?php
                                                                foreach ($avalistas as $aval) {
                                                                    echo '<option value="'.$aval->nrcpfcgc.'">'.$aval->nmdavali.'</option>';
                                                                }
                                                            ?>
                                                        </select>
                                                    </fieldset>
                                                    <br style="clear:both" />
                                                    <?php
                                                }
                                            ?>

                                            <div id="divBotoesGerarBoleto" style="margin-bottom: 5px; text-align:center;">
                                                <a href="#" class="botao" id="btVoltar" style="float:none" onClick="<?php echo 'fechaRotina($(\'#divRotina\')); '; ?> return false;">Voltar</a>
                                                <a href="#" class="botao" id="btEnviar" style="float:none" onClick="listaTitulos(); return false;">Avancar</a>
                                            </div>

                                            <br style="clear:both" />   

                                        </form>

                                        <div id="divTitulos"></div>


                                    </div>
                                </td>
                            </tr>
                        </table>			    
                    </td> 
                </tr>
            </table>
        </td>
    </tr>
</table>