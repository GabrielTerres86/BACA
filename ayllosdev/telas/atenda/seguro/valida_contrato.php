<? 
/*!
 * FONTE        : valida_contrato.php
 * CRIAÇÃO      : Mateus Z (Mouts)
 * DATA CRIAÇÃO : 05/09/2018
 * OBJETIVO     : Rotina para validar o contrato
 * ALTERACOES	: 
 */
?>
 
<?	
    session_start();
	require_once("../../../includes/config.php");
	require_once("../../../includes/funcoes.php");
	require_once("../../../includes/controla_secao.php");
	require_once("../../../class/xmlfile.php");
	isPostMethod();		
	
	// Guardo os parâmetos do POST em variáveis
	$nrdconta = (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : 0;
	$nrctrato = (isset($_POST['nrctrato'])) ? $_POST['nrctrato'] : 0;

	$xml  = "";
	$xml .= "<Root>";
	$xml .= "  <Dados>";
	$xml .= '	 <nrctrato>'.$nrctrato.'</nrctrato>';
	$xml .= '	 <nrdconta>'.$nrdconta.'</nrdconta>';
	$xml .= "  </Dados>";
	$xml .= "</Root>";

		// Executa script para envio do XML
	$xmlResult = mensageria($xml, "SEGU0003", 'VALIDA_CONTRATO_PRESTAMISTA', $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"],  "</Root>");
	$xmlObjeto = getObjectXML($xmlResult);

	$dados = $xmlObjeto->roottag->tags[0]->tags[0]->tags;

	//-----------------------------------------------------------------------------------------------
	// Controle de Erros
	//-----------------------------------------------------------------------------------------------
	if(strtoupper($xmlObjeto->roottag->tags[0]->name == 'ERRO')){	

		$msgErro = $xmlObjeto->roottag->tags[0]->cdata;

		if($msgErro == null || $msgErro == ''){
			$msgErro = $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;
		}								
		exibirErro('error',utf8_encode($msgErro),'Alerta - Ayllos','bloqueiaFundo(divRotina)',false);								
	}

?>