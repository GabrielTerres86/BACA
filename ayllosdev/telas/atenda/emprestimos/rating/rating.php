<?php
/*!
 * FONTE        : rating.php
 * CRIAÇÃO      : Luiz Otávio Olinger Momm
 * DATA CRIAÇÃO : 25/02/2019
 * OBJETIVO     : 13638 - Rating - Manutenção/Alteração Nota do Rating na tela Atenda. P450 (Luiz Otávio Olinger Momm - AMCOM)
 */
session_start();
require_once('../../../../includes/config.php');
require_once('../../../../includes/funcoes.php');
require_once('../../../../includes/controla_secao.php');
require_once('../../../../class/xmlfile.php');
isPostMethod();

// Aguardando estória para o salvar pelo operador e alteração na rotina.
$nrdconta = isset($_POST['nrdconta']) ? $_POST['nrdconta'] : '';
$contrato = isset($_POST['contrato']) ? $_POST['contrato'] : '';
$tipoProduto = isset($_POST['tipoProduto']) ? $_POST['tipoProduto'] : '';

$ratingMotor = '';

// Consulta nota MOTOR
if ($contrato > 0 && $nrdconta > 0) {

    $oXML = new XmlMensageria();
    $oXML->add('nrdconta', $nrdconta);
    $oXML->add('nrctro', $contrato);
    $oXML->add('tpctrato', $tipoProduto);
    
    $xml = $oXML;
    $xmlResult = mensageria($xml, "TELA_RATMOV", "APRESENTA_RATING_MOTOR", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
    $xmlObj = getObjectXML($xmlResult);
    unset($xmlResult);

    if (strtoupper($xmlObj->roottag->tags[0]->name) == "ERRO") {
        $msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;

        if ($msgErro == "") {
            $msgErro = $xmlObj->roottag->tags[0]->cdata;
        }

        $nmdcampo = $xmlObj->roottag->tags[0]->attributes['NMDCAMPO'];

        // O tratamento será feito no JS
        echo '<!-- ERRO RATING -->' . ($msgErro);
        return;
    } else {
        // Aguardando estória para a implantação da impressão do rating motor
        $registros = $xmlObj->roottag->tags[0]->tags;
        foreach ($registros as $registro) {
            $ratingMotor = getByTagName($registro->tags,'PR_INRISCO_RATING_AUTOM');
        }
    }
}

?>
<style type="text/css">
#frmRatingManutencao fieldset {
    padding: 15px 0;
    text-align: left;
}
#frmRatingManutencao label {
    clear: left;
    width: 120px;
}
#frmRatingManutencao input#notamotor { width: 50px; }
#frmRatingManutencao input#notanova { width: 50px; text-transform: uppercase; }
#frmRatingManutencao textarea#campoJustificativa { width: 200px; height:60px; margin: 0px 0px 0px 3px;}

</style>
<div id="divAlteracaoRating">
    <form name="frmRatingManutencao" id="frmRatingManutencao" class="formulario">
        <fieldset>
            <legend>Manuten&ccedil;&atilde;o/Altera&ccedil;&atilde;o Nota do Rating</legend>

            <label for="notamotor">Rating Motor:</label>
            <input name="notamotor" class="campo" id="notamotor" type="text" value="<?=$ratingMotor?>" size="2" maxlength="2"/>
            <br style="clear:both" />

            <label for="notanova">Rating Novo:</label>
            <input name="notanova" class="campo" id="notanova" type="text" value="" size="2" maxlength="2" />
            <br style="clear:both" />

            <label for="nrcontrato_if_origem">Justificativa:</label>
            <textarea class="textarea campoJustificativa" id="campoJustificativa" name="campoJustificativa" placeholder="Informe uma justificava para a altera&ccedil;&atilde;o do rating"></textarea>
            <span class="contadorJustificativa" id="contadorJustificativa" style="font-size: 10px; float: right; margin-right: 65px; color: red;">0 caracter</span>
        </fieldset>
    </form>
    <div id="divBotoesFormRatingManutencao" style="margin-top:5px; margin-bottom:5px;" data-cdcooper="<?=$cdcooper?>" data-nrcpfcgc="<?=$nrcpfcgc?>" data-nrdconta="<?=$nrdconta?>" data-contrato="<?=$contrato?>">
        <a href="#" class="botao" id="btVoltar">Voltar</a>
        <a href="javascript:void(0);" class="botao" id="btSalvar">Continuar</a>
    </div>
</div>
<script type="text/javascript">
$(function() {
    highlightObjFocus($('#frmRatingManutencao'));
    
    // Consulta virá da rotina
    $('#notamotor','#frmRatingManutencao').desabilitaCampo();
    $('#notanova','#frmRatingManutencao').focus();

    $('#campoJustificativa').keyup(function () {
        var len = $.trim($(this).val().length);
        // Atualiza contador Justificativa
        ratmov_contadorJustificativa($(this), len);
        // Atualiza contador Justificativa
    });
});

function ratmov_contadorJustificativa(textJustificativa, len) {
    var elemento = $('#contadorJustificativa');
    if (len < 11) {
        elemento.removeAttr('color');
        elemento.css('color', 'red');
    } else {
        elemento.removeAttr('color');
        elemento.css('color', '#000');
    }
    elemento.html(len + ' caracteres');
}
</script>