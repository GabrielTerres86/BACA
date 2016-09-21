<? 
/*!
 * FONTE        : questionario.php
 * CRIAÇÃO      : Jonata Cardoso (RKAM)
 * DATA CRIAÇÃO : 14/01/2015 							Alterações: 
 * OBJETIVO     : Exibe as questoes do microcredito
 *
 */
?>
 
<?
	session_start();
	require_once('../../../../includes/config.php');
	require_once('../../../../includes/funcoes.php');
	require_once('../../../../includes/controla_secao.php');	
	require_once('../../../../class/xmlfile.php');
	isPostMethod();		
	
	// Post
	$operacao = $_POST['operacao'] == '' ? 0 : $_POST['operacao'];
	$nrdconta = $_POST['nrdconta'] == '' ? 0 : $_POST['nrdconta'];
	$nrseqrrq = $_POST['nrseqrrq'] == '' ? 0 : $_POST['nrseqrrq'];
	$qtpergun = $_POST['qtpergun'] == '' ? 0 : $_POST['qtpergun'];
	$cddopcao = 'C';
	$inregcal = 1;

	$strnomacao = 'RETORNA_PERGUNTAS_MCR';
		
	// Montar o xml para requisicao
	$xml  = "";
	$xml .= "<Root>";
	$xml .= " <Dados>";
	$xml .= "    <cdcooper>".$glbvars['cdcooper']."</cdcooper>";
	$xml .= "    <nrdconta>".$nrdconta."</nrdconta>";	
	$xml .= "    <nrseqrrq>".$nrseqrrq."</nrseqrrq>";	
	$xml .= "    <inregcal>".$inregcal."</inregcal>";	
	$xml .= " </Dados>";
	$xml .= "</Root>";
		
	$xmlResult = mensageria($xml, "PARMCR" , $strnomacao, $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["nmoperad"], "</Root>");	
	$xmlObj    = getObjectXML($xmlResult);	
	
	if (strtoupper($xmlObj->roottag->tags[0]->name) == "ERRO") {
	  $msgErro = $xmlObj->roottag->tags[0]->cdata;
	  exibirErro('error',$msgErro,'Alerta - Ayllos',false);
	}
	
	$xml_geral = simplexml_load_string($xmlResult);
	
	$qt_tot_perguntas = 0;
	
	// Contabilizar as perguntas para a paginacao da tela
	for ($i = 0; $i < count($xml_geral->titulos); $i++ ) {

		$questionario = $xml_geral->titulos[$i];
		
		$qt_tot_perguntas += count($questionario->perguntas); 
	
	}
	
	include('form_questionario.php');
			
?>