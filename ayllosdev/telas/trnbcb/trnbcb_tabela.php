<?
/*!
 * FONTE        : trnbcb_tabela.php
 * CRIAÇÃO      : Lucas Ranghetti
 * DATA CRIAÇÃO : 18/01/2016
 * OBJETIVO     : Tabela de consulta para a tela TRNBCB
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
	
	$cddopcao = $_POST["cddopcao"];
	$cddtrans = $_POST["cddtrans"];		
	$dstrnbcb = $_POST["dsctrans"];
	$flgdebcc = $_POST["flgdebcc"];
	
	$cdhistor = !isset($_POST["cdhistor"]) || is_null($_POST["cdhistor"]) || $_POST["cdhistor"] == '' ? 0 : $_POST["cdhistor"];
	
	$retornoAposErro = 'focaCampoErro(\'cddtrans\', \'frmCab\');';
	
	//exibirErro('error', $cddtrans.'-'.$cddopcao.'-'.$cdhistor, 'Alerta - Ayllos', '', false);
		
	// Montar o xml de Requisicao
	$xml .= "<Root>";
	$xml .= " <Dados>";
	$xml .= "   <cddopcao>".$cddopcao."</cddopcao>";
	$xml .= "   <cdtrnbcb>".$cddtrans."</cdtrnbcb>";
	$xml .= "   <dstrnbcb>".$dstrnbcb."</dstrnbcb>";
	$xml .= "   <cdhistor>".$cdhistor."</cdhistor>";
	$xml .= "   <flgdebcc>".$flgdebcc."</flgdebcc>";
	$xml .= " </Dados>";
	$xml .= "</Root>";
	
	$xmlResult = mensageria($xml, "TRNBCB", "TRNBCB", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObj = getObjectXML($xmlResult);
	
	
//----------------------------------------------------------------------------------------------------------------------------------	
// Controle de Erros
//----------------------------------------------------------------------------------------------------------------------------------
if (strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO") {
    $msgErro = $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;
    exibirErro('error', $msgErro, 'Alerta - Ayllos', '', false);
}

$registros = $xmlObj->roottag->tags[0]->tags;

echo '	<div class="divRegistros">';
echo '		<table>';
echo '			<thead>';
echo '				<tr>';
echo '                  <th >'.utf8ToHtml('Codigo').'</th>';
echo '                  <th >'.utf8ToHtml('Descricao').'</th>';
echo '                  <th >'.utf8ToHtml('Tipo').'</th>';
echo '				</tr>';
echo '			</thead>';
echo '			<tbody>';

foreach ($registros as $r) {
    echo '<tr>';
    echo '	<td id="tabcdhistor"><span>' . getByTagName($r->tags, 'cdhistor') . '</span>';
    echo getByTagName($r->tags, 'cdhistor');
    echo '	</td>';
    echo '	<td id="tabdshistor"><span>' . getByTagName($r->tags, 'dshistor') . '</span>';
    echo getByTagName($r->tags, 'dshistor');
    echo '	<td id="tabtphistor"><span>' . getByTagName($r->tags, 'tphistor') . '</span>';
    echo getByTagName($r->tags, 'dstphistor');
    echo '	</td>';
    echo '</tr>';
}

echo '			</tbody>';
echo '		</table>';
echo '	</div>';

?>
