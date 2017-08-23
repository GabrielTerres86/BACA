<?php
/* !
 * FONTE        : tab_gerar_boleto_tr.php
 * CRIAÇÃO      : Daniel Zimmermann
 * DATA CRIAÇÃO : 25/08/2015
 * OBJETIVO     : Rotina para busca valores TR.
 * --------------
 * ALTERAÇÕES   : 01/03/2017 - Inclusao de indicador se possui avalista. (P210.2 - Jaison/Daniel)
 * --------------
 */
?>

<?php
session_start();
require_once('../../includes/config.php');
require_once('../../includes/funcoes.php');
require_once('../../includes/controla_secao.php');
require_once('../../class/xmlfile.php');
isPostMethod();

$avalista = (isset($_POST['avalista'])) ? $_POST['avalista'] : 0;
$nrdconta = (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : 0;
$nrctremp = (isset($_POST['nrctremp'])) ? $_POST['nrctremp'] : 0;

// Montar o xml de Requisicao
$xml  = "<Root>";
$xml .= " <Dados>";
$xml .= "   <nrdconta>".$nrdconta."</nrdconta>";
$xml .= "   <nrctremp>".$nrctremp."</nrctremp>";
$xml .= "   <inprejuz>0</inprejuz>";
$xml .= " </Dados>";
$xml .= "</Root>";

$xmlResultado = mensageria($xml, "TELA_COBEMP", "BUSCA_PRAZO_VCTO_MAX", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
$xmlObj = getObjectXML($xmlResultado);

if (strtoupper($xmlObj->roottag->tags[0]->name == 'ERRO')) {
    $msgErro = $xmlObj->roottag->tags[0]->cdata;
    if ($msgErro == null || $msgErro == '') {
        $msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
    }
    exibirErro('error', $msgErro, 'Alerta - Ayllos', '', false);

    exit();
}

$maxDate = $xmlObj->roottag->cdata;
?>

<style>
    .ui-datepicker-trigger{
        float:left;
        margin-left:2px;
        margin-top:3px;
    }
</style> 

<script>

    $(document).ready(function() {

    retornaListaFeriados(<?php echo $glbvars["cdcooper"]; ?>,<?php echo $glbvars["dtmvtolt"]; ?>);
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
            /*	onSelect: function(dateText, inst){
             
             //$("#qtdialib").val("0"); 
             /*	
             if  ( $("#tpemprst").val()  == "0") {
             calculaDiasUteis(dateText); 
             $("#dtlibera","#frmNovaProp").val(dateText); 
             arrayProposta['dtlibera'] = dateText; 		
             }
             else {
             $("#dtlibera","#frmNovaProp").val("<?php echo $glbvars["dtmvtolt"]; ?>"); 
             }
             },*/
            //	onClose: function(dateText, inst) {  },
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
    });</script>

<form id="frmGerarBoletoTR" name="frmGerarBoletoTR" class="formulario" onSubmit="return false;">

    <br style="clear:both" />		

    <fieldset>
        <legend align="left">Vencimento</legend>
        <input type="radio" id="rdvencto1" class="campo" name="rdvencto" value="1" onclick="habilitaDataVencimentoTR(false)" /> <label style="margin-left:10px">Nesta Data</label>
        <br style="clear:both" />	
        <input type="radio" id="rdvencto2" class="campo" name="rdvencto" value="2" onclick="habilitaDataVencimentoTR(true)" /> <label style="margin-left:10px">Data Futura:</label>
        <input type="text" id="dtvencto" class="campo" name="dtvencto" readonly="true"/>
        <input type="hidden" id="dtmvtolt" class="campo" name="dtmvtolt" value="<?php echo $glbvars["dtmvtolt"]; ?>"/>
    </fieldset>
    <br style="clear:both" />		

    <?php
        // Se possui Avalista
        if ($avalista == 1) {
            $xmlResult = mensageria($xml, "TELA_COBEMP", "COBEMP_AVAL", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
            $xmlObject = getObjectXML($xmlResult);

            if (strtoupper($xmlObject->roottag->tags[0]->name) == "ERRO"){
                $msgErro = $xmlObject->roottag->tags[0]->tags[0]->tags[4]->cdata;
                exibirErro('error',$msgErro,'Alerta - Ayllos','', false);
            }

            $regAval = $xmlObject->roottag->tags[0]->tags;
            ?>
            <fieldset>
                <legend align="left">Sacado</legend>
                <input type="radio" id="rdsacado1" class="campo" name="rdsacado" value="1" onclick="habilitaAvalista(1)" /> <label style="margin-left:10px">Devedor</label>
                <br style="clear:both" />	
                <input type="radio" id="rdsacado2" class="campo" name="rdsacado" value="2" onclick="habilitaAvalista(2)" /> <label style="margin-left:10px">Avalista:</label>
                <select name="nrcpfava" id="nrcpfava">
                    <option value=""></option>
                    <?php
                        foreach ($regAval as $reg) {
                            echo '<option value="'.getByTagName($reg->tags,'NRCPFCGC').'">'.getByTagName($reg->tags,'NMDAVALI').'</option>';
                        }
                    ?>
                </select>
            </fieldset>
            <br style="clear:both" />
            <?php
        }
    ?>

    <div id="divBotoesGerarBoletoTR" style="margin-bottom: 5px; text-align:center;">
        <a href="#" class="botao" id="btVoltar" style="float:none" onClick="<?php echo 'fechaRotina($(\'#divRotina\')); '; ?> return false;">Voltar</a>
        <a href="#" class="botao" id="btEnviar" style="float:none" onClick="mostraValoresTR(); return false;">Avancar</a>
    </div>

    <br style="clear:both" />	

    <div id="divValoresTR"></div>

    <br style="clear:both" />
    <br style="clear:both" />

</form>

<div id="divBotoesValoresTR" style="margin-bottom: 5px; text-align:center; display:none" >
    <a href="#" class="botao" id="btVoltar"  	onClick="<?php echo 'fechaRotina($(\'#divRotina\')); '; ?> return false;">Voltar</a>
    <a href="#" class="botao" id="btEnviar"  	onClick="confirmaGeracaoBoletoTR(); return false;">Gerar Boleto</a>
</div>
