<? 
/*!
 * FONTE        : microcredito.php
 * CRIAÇÃO      : Jonata Cardoso (RKAM)
 * DATA CRIAÇÃO : 05/01/2015 							Alterações: 18/03/2015
 *
 * OBJETIVO     : Verifica se as telas de microcredito devem aparecer 
 *
 * ALTERACOES   : 18/03/2015 - Mostrar a tela do questionario quando alterada a linha de credito
		                       para microcredito (Jonata-RKAM).
 */
?>
 
<?
	session_start();
	require_once('../../../includes/config.php');
	require_once('../../../includes/funcoes.php');
	require_once('../../../includes/controla_secao.php');	
	require_once('../../../class/xmlfile.php');
	isPostMethod();		
	
	// Parametros POST
	$cdlcremp = $_POST['cdlcremp'] == '' ? 0 : $_POST['cdlcremp'];
	$cddopcao = $_POST['cddopcao'] == '' ? 0 : $_POST['cddopcao'];
	$nrseqrrq = $_POST['nrseqrrq'] == '' ? 0 : $_POST['nrseqrrq'];

	
	$strnomacao = 'VERIFICA_MICROCREDITO';
	
	// Montar o xml para requisicao
	$xml  = "";
	$xml .= "<Root>";
	$xml .= " <Dados>";
	$xml .= "    <cdcooper>".$glbvars['cdcooper']."</cdcooper>";
	$xml .= "    <cdlcremp>".$cdlcremp."</cdlcremp>";		
	$xml .= " </Dados>";
	$xml .= "</Root>";
		
	$xmlResult = mensageria($xml, "PARMCR" , $strnomacao, $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["nmoperad"], "</Root>");	
	$xmlObj    = getObjectXML($xmlResult);	
	
	if (strtoupper($xmlObj->roottag->tags[0]->name) == "ERRO") {
	  $msgErro = $xmlObj->roottag->tags[0]->cdata;
	  exibirErro('error',$msgErro,'Alerta - Ayllos',false);
	}
	
	$xml_geral = simplexml_load_string($xmlResult);
	//$xml_geral = $xmlObj->roottag->tags[0];
	
	$inlcrmcr = $xml_geral->inlcrmcr;	

	if ($inlcrmcr == 'N' || ($nrseqrrq == 0 && $cddopcao == 'C') ) {	
		// Se nao eh microcredito, vai para a tela de observacoes
		if ($cddopcao == 'C') {
			echo 'controlaOperacao("");';
		} else {
			echo 'resposta = ""; controlaOperacao("' . $cddopcao . '_ALIENACAO");';
		}
	} 
	else {
		// Se for microcredito, realizar o questionario
		echo 'controlaOperacao("' . $cddopcao . '_MICRO_PERG");';
	}
			
?>