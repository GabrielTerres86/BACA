<?
/*!
 * FONTE        : tabela_investidor.php
 * CRIAÇÃO      : Christian Grauppe - Envolti
 * DATA CRIAÇÃO : 10/04/2019
 * OBJETIVO     : Tabela que apresenta os detalhes dos investimentos
 */
?>
<?
	session_start();
	// Includes para controle da session, variáveis globais de controle, e biblioteca de funções	
	require_once("../../includes/config.php");
	require_once("../../includes/funcoes.php");
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();
	
	 function formataNumeroBanco($number) {
		return  str_replace('.', ',', $number);
	 }
	 function formataNumeroBancoComP($number) {
		return  str_replace('.', '', $number);
	 }
/*
	$xmlF = '
    <faixas>
      <idfrninv>5065</idfrninv>
      <vlfaixde>0,00</vlfaixde>
      <vlfaixate>600000</vlfaixate>
      <pctaxmen>0,0010833</pctaxmen>
      <vladicio>0,00</vladicio>
    </faixas>
    <faixas>
      <idfrninv>5066</idfrninv>
      <vlfaixde>600000,01</vlfaixde>
      <vlfaixate>1000000</vlfaixate>
      <pctaxmen>0,0010292</pctaxmen>
      <vladicio>0,27</vladicio>
    </faixas>
    <faixas>
      <idfrninv>5014</idfrninv>
      <vlfaixde>1000000,01</vlfaixde>
      <vlfaixate>5000000</vlfaixate>
      <pctaxmen>0,0009777</pctaxmen>
      <vladicio>0,79</vladicio>
    </faixas>
    <faixas>
      <idfrninv>5015</idfrninv>
      <vlfaixde>5000000,01</vlfaixde>
      <vlfaixate>10000000</vlfaixate>
      <pctaxmen>0,0009288</pctaxmen>
      <vladicio>3,23</vladicio>
    </faixas>
    <faixas>
      <idfrninv>5016</idfrninv>
      <vlfaixde>10000000,01</vlfaixde>
      <vlfaixate>100000000</vlfaixate>
      <pctaxmen>0,0006502</pctaxmen>
      <vladicio>31,09</vladicio>
    </faixas>
    <faixas>
      <idfrninv>5017</idfrninv>
      <vlfaixde>100000000,01</vlfaixde>
      <vlfaixate>1000000000</vlfaixate>
      <pctaxmen>0,0004551</pctaxmen>
      <vladicio>226,15</vladicio>
    </faixas>
    <faixas>
      <idfrninv>5018</idfrninv>
      <vlfaixde>1000000000,01</vlfaixde>
      <vlfaixate>10000000000</vlfaixate>
      <pctaxmen>0,0003186</pctaxmen>
      <vladicio>1591,52</vladicio>
    </faixas>
    <faixas>
      <idfrninv>5019</idfrninv>
      <vlfaixde>10000000000,01</vlfaixde>
      <vlfaixate>0,00</vlfaixate>
      <pctaxmen>0,000223</pctaxmen>
      <vladicio>11149,1</vladicio>
    </faixas>';
*/
	foreach ($_POST['vlfaixate'] as $id=>$vlfaixate) {
		$xmlF.= '<faixas>';
		$xmlF.=	'	<idfrninv>'.formataNumeroBanco($_POST['idfrninv'][$id]).'</idfrninv>';
		$xmlF.=	'	<vlfaixde>'.formataNumeroBanco($_POST['vlfaixde'][$id]).'</vlfaixde>';
		$xmlF.= '	<vlfaixate>'.formataNumeroBanco($vlfaixate).'</vlfaixate>';
		$xmlF.= '	<pctaxmen>'.formataNumeroBancoComP($_POST['pctaxmen'][$id]).'</pctaxmen>';
		$xmlF.= '	<vladicio>'.formataNumeroBancoComP($_POST['vladicio'][$id]).'</vladicio>';
		$xmlF.= '</faixas>';
	}

	// Montar o xml de Requisicao
	$xml = "<Root>";
	$xml .= "	<Dados>";
	$xml .= $xmlF;
	$xml .= "	</Dados>";
	$xml .= "</Root>";

	// Executa script para envio do XML e cria objeto para classe de tratamento de XML
	$xmlResult = mensageria($xml ,"TELA_CUSAPL" ,"TELA_CUSAPL_ATZ_FRN_TAB_INV" ,$glbvars["cdcooper"] ,$glbvars["cdagenci"] ,$glbvars["nrdcaixa"] ,$glbvars["idorigem"] ,$glbvars["cdoperad"] ,"</Root>");

	$xmlObjeto = getObjectXML($xmlResult);

	// Se ocorrer um erro, mostra mensagem
	if (strtoupper($xmlObjeto->roottag->tags[0]->name) == 'ERRO') {
		$msgErro  = $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;
		exibirErro('error',$msgErro,'Alerta - Aimaro','bloqueiaFundo(divRotina);mostraTabelaInverstidores();',false);
	} else {
		$msgErro  = $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;
		exibirErro('inform',$msgErro,'Alerta - Aimaro','bloqueiaFundo(divRotina);',false);
	}