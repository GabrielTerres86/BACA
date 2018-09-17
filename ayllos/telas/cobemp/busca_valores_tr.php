<?php
session_start();
require_once('../../includes/config.php');
require_once('../../includes/funcoes.php');
require_once('../../includes/controla_secao.php');
require_once('../../class/xmlfile.php');
isPostMethod();

//$nrregist = (isset($_POST['nrregist'])) ? $_POST['nrregist'] : 0;
//$nriniseq = (isset($_POST['nriniseq'])) ? $_POST['nriniseq'] : 0;
$nrdconta = (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : 0;
$nrctremp = (isset($_POST['nrctremp'])) ? $_POST['nrctremp'] : 0;
$dtmvtolt = (isset($_POST['dtmvtolt'])) ? $_POST['dtmvtolt'] : '';
// Montar o xml de Requisicao
$xml .= "<Root>";
$xml .= " <Dados>";
$xml .= "   <nrdconta>" . $nrdconta . "</nrdconta>";
$xml .= "   <nrctremp>" . $nrctremp . "</nrctremp>";
$xml .= "   <dtmvtolt>" . $dtmvtolt . "</dtmvtolt>";
$xml .= " </Dados>";
$xml .= "</Root>";

$xmlResult = mensageria($xml, "EMPR0007", "BUSCA_DADOS_TR", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
$xmlObj = getObjectXML($xmlResult);
/*
  echo '<pre>';
  print_r($xmlObj);
  echo '</pre>';
 
exit();
 * 
 */

if (strtoupper($xmlObj->roottag->tags[0]->name == 'ERRO')) {
    $msgErro = $xmlObj->roottag->tags[0]->cdata;
    if ($msgErro == null || $msgErro == '') {
        $msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
    }
    exibirErro('error', $msgErro, 'Alerta - Ayllos', '', false);

    exit();
} else {    
    $vlsdeved = number_format(str_replace(",", ".", $xmlObj->roottag->tags[0]->cdata), 2, ",", ".");
    $vlatraso = number_format(str_replace(",", ".", $xmlObj->roottag->tags[1]->cdata), 2, ",", ".");
}
?>

<br style="clear:both" />		

<input type="radio" id="tpvlpgto1" class="campo" name="tpvlpgto" value="1" onclick="habilitaValorParcial(1)"/> 
<label style="margin-left:110px">Total Atraso: </label>
<input type="text" id="vlrpgto1" class="campo" name="vlrpgto1" readonly="true" value="<?php echo $vlatraso ?> "/>
<br style="clear:both" />	
<input type="radio" id="tpvlpgto2" class="campo" name="tpvlpgto" value="2" onclick="habilitaValorParcial(2)" /> 
<label style="margin-left:48px">Valor Parcial do Atraso:	</label>
<input type="text" id="vlrpgto2" class="campo" name="vlrpgto2" />
<br style="clear:both" />	
<input type="radio" id="tpvlpgto3" class="campo" name="tpvlpgto" value="3" onclick="habilitaValorParcial(3)"/> 
<label style="margin-left:10px">Total Saldo Devedor/Quitacao:	</label>
<input type="text" id="vlrpgto3" class="campo" name="vlrpgto3" readonly="true" value="<?php echo $vlsdeved ?> "/>

