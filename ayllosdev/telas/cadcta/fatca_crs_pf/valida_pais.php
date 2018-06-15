<? 
/*!
 * FONTE        : valida_pais.php
 * CRIAÇÃO      : Mateus Z (Mouts)
 * DATA CRIAÇÃO : 18/04/2018
 * OBJETIVO     : Rotina para validar o pais da tela FATCA/CRS
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
	$cdpais = (isset($_POST['cdpais'])) ? $_POST['cdpais'] : '' ;

	$xml  = "";
	$xml .= "<Root>";
	$xml .= "  <Dados>";
	$xml .= '	 <cdpais>'.$cdpais.'</cdpais>';
	$xml .= "    <nriniseq>1</nriniseq>";
	$xml .= "    <nrregist>9999</nrregist>";
	$xml .= "  </Dados>";
	$xml .= "</Root>";

		// Executa script para envio do XML
	$xmlResult = mensageria($xml, "TELA_FATCA_CRS", 'VALIDA_PAIS', $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"],  "</Root>");
	$xmlObjeto = getObjectXML($xmlResult);

	$dados = $xmlObjeto->roottag->tags[0]->tags[0]->tags;

	//-----------------------------------------------------------------------------------------------
	// Controle de Erros
	//-----------------------------------------------------------------------------------------------
	if(strtoupper($xmlObjeto->roottag->tags[0]->name == 'ERRO')){	

		$msgErro = $xmlObjeto->roottag->tags[0]->cdata;
		$nmdcampo = $xmlObjeto->roottag->tags[0]->attributes["NMDCAMPO"];					

		if($msgErro == null || $msgErro == ''){
			$msgErro = $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;
		}								
		exibirErro('error',utf8_encode($msgErro),'Alerta - Ayllos','bloqueiaFundo(divRotina)',false);								
	}

	echo "$('#inacordo','#frmDadosFatcaCrs').val('". getByTagName($dados,'inacordo') ."');";

?>