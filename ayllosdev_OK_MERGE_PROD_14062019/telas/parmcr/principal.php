<? 
/*!
 * FONTE        : principal.php
 * CRIAÇÃO      : Jonata Cardoso (RKAM)
 * DATA CRIAÇÃO : 09/12/2014 
 * OBJETIVO     : Rotina para manter as operações da tela PARMCR
 * --------------
 * ALTERAÇÕES   : 
 */
?> 

<?	
    session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();		

	
	// Recebe a operação que está sendo realizada
	$operacao	= (isset($_POST['operacao'])) ? $_POST['operacao'] :'C1'; 
	$nrversao   = (isset($_POST['nrversao'])) ? $_POST['nrversao'] : 0  ;
	$nrseqtit   = (isset($_POST['nrseqtit'])) ? $_POST['nrseqtit'] : 0  ;
	$nrseqper   = (isset($_POST['nrseqper'])) ? $_POST['nrseqper'] : 0  ;
	$flgbloqu   = (isset($_POST['flgbloqu'])) ? $_POST['flgbloqu'] : false ;
	$cddopcao   = "C";
	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {		
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}	
	
	switch ($operacao) {
		case 'C1': { $strnomacao = 'CRAPVQS'; break; }
		case 'C2': { $strnomacao = 'CRAPTQS'; break; }
		case 'C3': { $strnomacao = 'CRAPPQS'; break; }
		case 'C4': { $strnomacao = 'CRAPRQS'; break; }
	}
	
	// Montar o xml para requisicao
	$xml  = "";
	$xml .= "<Root>";
	$xml .= " <Dados>";
	$xml .= "    <cdcooper>".$glbvars['cdcooper']."</cdcooper>";
	$xml .= "    <cdoperad>".$glbvars['cdoperad']."</cdoperad>";
	$xml .= "    <cddopcao>".$cddopcao."</cddopcao>";
	$xml .= "    <nrversao>".$nrversao."</nrversao>";
	$xml .= "    <nrseqtit>".$nrseqtit."</nrseqtit>";
	$xml .= "    <nrseqper>".$nrseqper."</nrseqper>";
	$xml .= " </Dados>";
	$xml .= "</Root>";
 
	$xmlResult = mensageria($xml, "PARMCR", $strnomacao, $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["nmoperad"], "</Root>");
	$xmlObj    = getObjectXML($xmlResult);

	//----------------------------------------------------------------------------------------------------------------------------------	
	// Controle de Erros
	//----------------------------------------------------------------------------------------------------------------------------------
	if ( strtoupper($xmlObj->roottag->tags[0]->name) == "ERRO" ) {
		$msgErro	= $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
		exibirErro('error',$msgErro,'Alerta - Ayllos',$retornoAposErro,false);
	}

	$xml_dados = simplexml_load_string($xmlResult);
	$inf       = $xml_dados->inf;
	$qtregist  = count($inf); 	
	
	if ($operacao == "C1") {
		include("tab_crapvqs.php");
	}
	else if ($operacao == "C2") {
		include("tab_craptqs.php");
	}
	else if ($operacao == "C3") {
		include ("tab_crappqs.php");	
	}
	else if ($operacao == "C4") {
		include("tab_craprqs.php");
	}
 ?>