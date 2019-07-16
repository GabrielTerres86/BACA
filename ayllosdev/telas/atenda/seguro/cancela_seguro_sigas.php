<? 
/*!
 * FONTE        : cancela_seguro_sigas.php
 * CRIAÇÃO      : Darlei Zillmer (Supero)
 * DATA CRIAÇÃO : 15/07/2019
 * OBJETIVO     : Altera o status do contrato para cancelado (Sem relação com a seguradora, 
 *                é necessario providenciar o cancelamento do seguro junto a seguradora.
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
	$cdidsegp = (isset($_POST['cdidsegp'])) ? $_POST['cdidsegp'] : 0;

	$xml  = "";
	$xml .= "<Root>";
	$xml .= "  <Dados>";
	$xml .= '	 <cdidsegp>'.$cdidsegp.'</cdidsegp>';
	$xml .= '	 <nrdconta>'.$nrdconta.'</nrdconta>';
	$xml .= "  </Dados>";
	$xml .= "</Root>";

		// Executa script para envio do XML
	$xmlResult = mensageria($xml, "TELA_ATENDA_SEGURO", 'CANCELASEGCASASIGAS', $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"],  "</Root>");
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
		exibirErro('error',utf8_encode($msgErro),'Alerta - Aimaro','bloqueiaFundo(divRotina)',false);								
	}

?>