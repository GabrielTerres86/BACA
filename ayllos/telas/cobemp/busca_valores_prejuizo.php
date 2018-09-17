<?php
/* !
 * FONTE        : busca_valores_prejuizo.php
 * CRIAÇÃO      : Jaison Fernando
 * DATA CRIAÇÃO : 08/03/2017
 * OBJETIVO     : Rotina para busca valores de Prejuizo.
 * --------------
 * ALTERAÇÕES   : 
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

$vlsdprej = (isset($_POST['vlsdprej'])) ? $_POST['vlsdprej'] : 0;

// Montar o xml de Requisicao
$xml .= "<Root>";
$xml .= " <Dados>";
$xml .= " </Dados>";
$xml .= "</Root>";

$xmlResult = mensageria($xml, "TELA_COBEMP", "COBEMP_DESCTO", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
$xmlObject = getObjectXML($xmlResult);

if (strtoupper($xmlObject->roottag->tags[0]->name == 'ERRO')) {
    $msgErro = $xmlObject->roottag->tags[0]->cdata;
    if ($msgErro == null || $msgErro == '') {
        $msgErro = $xmlObject->roottag->tags[0]->tags[0]->tags[4]->cdata;
    }
    exibirErro('error', $msgErro, 'Alerta - Ayllos', '', false);

    exit();
} else {    
    $descprej = $xmlObject->roottag->tags[0]->cdata;
    $inperdct = $xmlObject->roottag->tags[1]->cdata;
}
?>
<br style="clear:both" />
<input type="hidden" id="inperdct" name="inperdct" value="<?php echo $inperdct; ?> "/>
<input type="hidden" id="descprej" name="descprej" value="<?php echo $descprej; ?> "/>

<input type="radio" id="tpvlpgto1" class="campo" name="tpvlpgto" value="1" onclick="habilitaValorParcialPrejuizo('1','<?php echo $inperdct; ?>')"/> 
<label style="margin-left:110px">Total Preju&iacute;zo:</label>
<input type="text" id="vlrpgto1" class="campo" name="vlrpgto1" readonly="true" value="<?php echo $vlsdprej; ?> "/>
<br style="clear:both" />

<input type="radio" id="tpvlpgto2" class="campo" name="tpvlpgto" value="2" onclick="habilitaValorParcialPrejuizo('2','<?php echo $inperdct; ?>')" /> 
<label style="margin-left:48px">Valor Parcial do Preju&iacute;zo:</label>
<input type="text" id="vlrpgto2" class="campo" name="vlrpgto2" onblur="exibeValorPrejuizo('P')" />
<br style="clear:both" />

<label style="margin-left:72px">Desconto para Quita&ccedil;&atilde;o (%):</label>
<input type="text" id="vldescto" class="campo" name="vldescto" value="0,00" onblur="exibeValorPrejuizo('D')" />
<br style="clear:both" />

<label style="margin-left:97px">Valor Quita&ccedil;&atilde;o Preju&iacute;zo:</label>
<input type="text" id="vlquitac" class="campo" name="vlquitac" readonly="true" value="<?php echo $vlsdprej; ?> "/>
<?php
// Se o operador nao possuir permissao para conceder desconto
if ($inperdct == 0) {
    echo "<script>";
    echo "$('#vldescto', '#divValoresTR').val('0,00').desabilitaCampo();";
    echo "</script>";
}
?>