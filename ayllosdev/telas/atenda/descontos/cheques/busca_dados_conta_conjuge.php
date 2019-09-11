<?php
/* !
 * FONTE        : busca_dados_conta_conjuge.php
 * CRIAÇÃO      : Mateus Zimmermann (Mouts)
 * DATA CRIAÇÃO : 18/10/2018
 * OBJETIVO     : Buscar os dados da conta conjuge digitada
 * ALTERAÇÕES   : 
 * --------------
 *
 */

session_start();
require_once('../../../../includes/config.php');
require_once('../../../../includes/funcoes.php');
require_once('../../../../includes/controla_secao.php');
require_once('../../../../class/xmlfile.php');
isPostMethod();

$nrdconta = (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : '';
$nomeForm = (isset($_POST['nomeForm'])) ? $_POST['nomeForm'] : '';

$xml  = '';
$xml .= '<Root>';
$xml .= '   <Dados>';
$xml .= '        <nrdconta>'.$nrdconta.'</nrdconta>';
$xml .= '    </Dados>';
$xml .= '</Root>';

$xmlResult = mensageria($xml, "CADA0003", "BUSCAR_DADOS_CONJUGE_ASSOCIADO", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
$xmlObjeto = getObjectXML($xmlResult);

// Se ocorrer um erro, mostra crítica
if (strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO") {
    exibirErro('error',utf8_encode($xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata),'Alerta - Aimaro','',false);
}

$dados = $xmlObjeto->roottag->tags;

if (count($dados) > 0) {
    $nmprimtl = getByTagName($dados[0]->tags,'nmprimtl');
    $nrcpfcgc = getByTagName($dados[0]->tags,'nrcpfcgc');
    $rendimento = getByTagName($dados[0]->tags,'rendimento');
    echo "$('#nmconjug','#". $nomeForm. "').val(\"$nmprimtl\");";
    echo "$('#nrcpfcjg','#". $nomeForm. "').val(\"$nrcpfcgc\");";
    echo "$('#vlrencjg','#". $nomeForm. "').val(\"$rendimento\");";
    exit;
}

?>