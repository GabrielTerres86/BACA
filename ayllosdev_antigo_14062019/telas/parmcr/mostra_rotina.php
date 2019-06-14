<? 
/*!
 * FONTE        : busca_rotina.php
 * CRIAÇÃO      : Jonata Cardoso (RKAM)
 * DATA CRIAÇÃO : 11/12/2014 
 * OBJETIVO     : Rotina para buscar os dados e exibir as rotinas
 *ALTERAÇÃO     :
 */
?>
 
<?
	session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');	
	require_once('../../class/xmlfile.php');
	isPostMethod();		
	
	
	// Guardo os parâmetos do POST em variáveis	
	$operacao = (isset($_POST['operacao'])) ? $_POST['operacao'] : '';
	$cddopcao = (isset($_POST['cddopcao'])) ? $_POST['cddopcao'] : 'C';
	$nrversao = (isset($_POST['nrversao'])) ? $_POST['nrversao'] : 0  ;
	$nrseqtit = (isset($_POST['nrseqtit'])) ? $_POST['nrseqtit'] : 0  ;
	$nrseqper = (isset($_POST['nrseqper'])) ? $_POST['nrseqper'] : 0  ;
	$nrseqres = (isset($_POST['nrseqres'])) ? $_POST['nrseqres'] : 0  ;
	
	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {		
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}
	
	$strnomacao = '';
	
	switch( $operacao ) {
		case 'A_crapvqs_1' : $strnomacao = 'CRAPVQS';  break;
		case 'A_craptqs_1' : $strnomacao = 'CRAPTQS';  break;
		case 'A_crappqs_1' : $strnomacao = 'CRAPPQS';  break;
		case 'A_craprqs_1' : $strnomacao = 'CRAPRQS';  break;
	}
	
	if ($strnomacao != '') {
			
		// Montar o xml para requisicao
		$xml  = "";
		$xml .= "<Root>";
		$xml .= " <Dados>";
		$xml .= "    <cdcooper>".$glbvars['cdcooper']."</cdcooper>";
		$xml .= "    <nrdconta>0</nrdconta>";
		$xml .= "    <nrseqrrq>0</nrseqrrq>";	
		$xml .= "    <inregcal>0</inregcal>";
		$xml .= "    <cdoperad>".$glbvars['cdoperad']."</cdoperad>";
		$xml .= "    <cddopcao>".$cddopcao."</cddopcao>";
		$xml .= "    <nrversao>".$nrversao."</nrversao>";
		$xml .= "    <nrseqtit>".$nrseqtit."</nrseqtit>";
		$xml .= "    <nrseqper>".$nrseqper."</nrseqper>";
		$xml .= "    <nrseqres>".$nrseqres."</nrseqres>";
		$xml .= " </Dados>";
		$xml .= "</Root>";
	 
		$xmlResult = mensageria($xml, "PARMCR", $strnomacao, $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["nmoperad"], "</Root>");
		$xml_dados = simplexml_load_string($xmlResult);
		
		if ( $xml_dados->Erro != "" ) {
			exibirErro('error',$xml_dados->Erro,'Alerta - Ayllos','fechaOpcao()',false);
		}
		
		$dsversao = $xml_dados->inf->dsversao;
		$dtinivig = $xml_dados->inf->dtinivig;
		$nrordtit = $xml_dados->inf->nrordtit;
		$dstitulo = $xml_dados->inf->dstitulo;
		$nrordper = $xml_dados->inf->nrordper;
		$dspergun = $xml_dados->inf->dspergun;
		$inobriga = $xml_dados->inf->inobriga;
		$intipres = $xml_dados->inf->intipres;
		$nrregcal = $xml_dados->inf->nrregcal;	
		$dsregexi = $xml_dados->inf->dsregexi;
		$nrordres = $xml_dados->inf->nrordres;
		$dsrespos = $xml_dados->inf->dsrespos;
		
	}	
		
	if ($operacao == 'I_crapvqs_1' || $operacao == 'A_crapvqs_1' || $operacao == 'D_crapvqs_1' ) {
		include('form_crapvqs.php');
	} 
	else 
	if ($operacao == 'I_craptqs_1' || $operacao == 'A_craptqs_1' ) {
		include('form_craptqs.php');
	} 
	else
	if ($operacao == 'I_crappqs_1' || $operacao == 'A_crappqs_1' ) {
		include('form_crappqs.php');
		include ('form_dsregexi.php');
	} 
	else 
	if ($operacao == 'I_craprqs_1' || $operacao == 'A_craprqs_1') {
		include('form_craprqs.php');
	} 
	else
	if ($operacao == 'C_perguntas_1' || $operacao == 'C_perguntas_2') {
		include('questionario.php');
	}

?>
