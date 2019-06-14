<?php

/* !
 * FONTE        : principal.php
 * CRIAÇÃO      : Daniel Zimmermann
 * DATA CRIAÇÃO : 04/09/2015 
 * OBJETIVO     : Fonte baseado no fonte principal.php da rotina de prestações da tela ATENDA 
 * 
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

$cddopcao = (($_POST['cddopcao'] != '') ? $_POST['cddopcao'] : '@');

// Verifica permissões de acessa a tela
if (($msgError = validaPermissao($glbvars['nmdatela'], $glbvars['nmrotina'], $cddopcao)) <> '') {
    exibirErro('error', $msgError, 'Alerta - Ayllos', "controlaOperacao('');", false);
}

// Verifica se o número da conta e o titular foram informados
if (!isset($_POST['nrdconta']) || !isset($_POST['idseqttl'])) {
    exibirErro('error', 'Parâmetros incorretos.', 'Alerta - Ayllos', 'fechaRotina(divRotina)', false);
}

// Guardo os parâmetos do POST em variáveis	
$nrdconta = $_POST['nrdconta'] == '' ? 0 : $_POST['nrdconta'];
$idseqttl = $_POST['idseqttl'] == '' ? 1 : $_POST['idseqttl'];
$operacao = (isset($_POST['operacao'])) ? $_POST['operacao'] : '';
$nrctremp = (isset($_POST['nrctremp'])) ? $_POST['nrctremp'] : 0;
$prejuizo = (isset($_POST['prejuizo'])) ? $_POST['prejuizo'] : 0;
$tpemprst = (isset($_POST['tpemprst'])) ? $_POST['tpemprst'] : 0;
$nrparepr = (isset($_POST['nrparepr'])) ? $_POST['nrparepr'] : 0;
$vlpagpar = (isset($_POST['vlpagpar'])) ? $_POST['vlpagpar'] : 0;
$nrregist = (isset($_POST['nrregist'])) ? $_POST['nrregist'] : 0;
$nriniseq = (isset($_POST['nriniseq'])) ? $_POST['nriniseq'] : 0;
$nrparepr_pos = (isset($_POST['nrparepr_pos'])) ? $_POST['nrparepr_pos'] : 0;
$vlpagpar_pos = (isset($_POST['vlpagpar_pos'])) ? $_POST['vlpagpar_pos'] : 0;

$dtcopemp = (isset($_POST['dtcopemp'])) ? $_POST['dtcopemp'] : '';

//echo 'principal ' . $dtcopemp;
// Verifica se o número da conta e o titular são inteiros válidos
if (!validaInteiro($nrdconta)) {
    exibirErro('error', 'Conta/dv inválida.', 'Alerta - Ayllos', 'fechaRotina(divRotina)', false);
}
if (!validaInteiro($idseqttl)) {
    exibirErro('error', 'Seq.Ttl inválida.', 'Alerta - Ayllos', 'fechaRotina(divRotina)', false);
}

$procedure = 'calcula_desconto_parcela';

if (in_array($operacao, array('C_PAG_PREST', 'C_DESCONTO'))) {

    $xml = "<Root>";
    $xml .= "	<Cabecalho>";
    $xml .= "		<Bo>b1wgen0084a.p</Bo>";
    $xml .= "		<Proc>" . $procedure . "</Proc>";
    $xml .= "	</Cabecalho>";
    $xml .= "	<Dados>";
    $xml .= "       <cdcooper>" . $glbvars["cdcooper"] . "</cdcooper>";
    $xml .= "		<cdagenci>" . $glbvars["cdagenci"] . "</cdagenci>";
    $xml .= "		<nrdcaixa>" . $glbvars["nrdcaixa"] . "</nrdcaixa>";
    $xml .= "		<cdoperad>" . $glbvars["cdoperad"] . "</cdoperad>";
    $xml .= "		<nmdatela>" . 'ATENDA' . "</nmdatela>";
    $xml .= "		<idorigem>" . $glbvars["idorigem"] . "</idorigem>";
    $xml .= "		<nrdconta>" . $nrdconta . "</nrdconta>";
    $xml .= "		<idseqttl>" . $idseqttl . "</idseqttl>";
    $xml .= "		<nrctremp>" . $nrctremp . "</nrctremp>";
    $xml .= "		<nrparepr>" . $nrparepr . "</nrparepr>";
    $xml .= "		<vlpagpar>" . $vlpagpar . "</vlpagpar>";

    if ($dtcopemp == '') {
        $xml .= "	<dtmvtolt>" . $glbvars["dtmvtolt"] . "</dtmvtolt>";
    } else {
        $xml .= "	<dtmvtolt>" . $dtcopemp . "</dtmvtolt>";
    }

    $xml .= "		<flgerlog>TRUE</flgerlog>";
    $xml .= "	</Dados>";
    $xml .= "</Root>";

    $xmlResult = getDataXML($xml);

    $xmlObjeto = getObjectXML($xmlResult);

    if (strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO") {
        exibirErro('error', $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata, 'Alerta - Ayllos', "controlaOperacao('')", false);
    }

    $descontos = $xmlObjeto->roottag->tags[0]->tags;

    for ($i = 0; $i < count($descontos); $i++) {

        $nr_parcela = getByTagName($descontos[$i]->tags, 'nrparepr');
        $vldespar = number_format(str_replace(",", ".", getByTagName($descontos[$i]->tags, 'vldespar')), 2, ",", ".");

        echo "$('#vldespar_' + $nr_parcela ,'#divTabela').html(' $vldespar ');";
    }
} else if(in_array($operacao,array('C_DESCONTO_POS'))) {

        // Montar o xml de Requisicao
        $xml  = "<Root>";
        $xml .= "   <Dados>";
        if ($dtcopemp == '') {
        $xml .= "       <dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
        } else {
            $xml .= "   <dtmvtolt>" . $dtcopemp . "</dtmvtolt>";
        }
        $xml .= "       <dtmvtoan>".$glbvars["dtmvtoan"]."</dtmvtoan>";
        $xml .= "       <cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
        $xml .= "       <nrdconta>".$nrdconta."</nrdconta>";
        $xml .= "       <nrctremp>".$nrctremp."</nrctremp>";
        $xml .= "       <nrparepr>".$nrparepr_pos."</nrparepr>";
        $xml .= "       <vlsdvpar>".$vlpagpar_pos."</vlsdvpar>";
        $xml .= "   </Dados>";
        $xml .= "</Root>";

        $xmlResult = mensageria($xml, "EMPR0011", "EMPR0011_BUSCA_DESC_POS", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
        $xmlObject = getObjectXML($xmlResult);

        //-----------------------------------------------------------------------------------------------
        // Controle de Erros
        //-----------------------------------------------------------------------------------------------

        if(strtoupper($xmlObject->roottag->tags[0]->name == 'ERRO')){   
            $msgErro = $xmlObject->roottag->tags[0]->cdata;
            if($msgErro == null || $msgErro == ''){
                $msgErro = $xmlObject->roottag->tags[0]->tags[0]->tags[4]->cdata;
            }
            exibirErro('error',$msgErro,'Alerta - Aimaro',"controlaOperacao('')",false);
        }

        $registro = $xmlObject->roottag->tags[0];

        echo "$('#vldespar_".$nrparepr_pos."','#divTabela').html('TE".getByTagName($registro->tags,'vldescto')."');";
}

$qtregist = $xmlObjeto->roottag->tags[0]->attributes['QTREGIST'];
