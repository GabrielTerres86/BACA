<? 
/*!
 * FONTE        : valida_data.php
 * CRIAÇÃO      : Mateus Zimmermann (Mouts)
 * DATA CRIAÇÃO : 13/08/2018
 * OBJETIVO     : Rotina para validar a data
 * --------------
 * ALTERAÇÕES   : 
 * -------------- 
 */
?> 

<?	
    session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();		

	// Varivel de controle do caracter
	$dtprovisao 	= (isset($_POST['dtprovisao'])) ? $_POST['dtprovisao'] : '' ;

	// Montar o xml de Requisicao
	$xml .= "<Root>";
	$xml .= " <Dados>";
	$xml .= "   <cdcooper>"  .$glbvars["cdcooper"]."</cdcooper>";
	$xml .= "   <dtprovisao>".$dtprovisao.         "</dtprovisao>";
	$xml .= " </Dados>";
	$xml .= "</Root>";

	$xmlResult = mensageria($xml, "TELA_PRVSAQ", "PRVSAQ_VALIDA_DATA", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"],
	$glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	
	$xmlObjeto = getObjectXML($xmlResult);

	//----------------------------------------------------------------------------------------------------------------------------------	
	// Controle de Erros
	//----------------------------------------------------------------------------------------------------------------------------------
	if ( strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO" ) {
		$msgErro	= $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;
		$retornoAposErro = '$(\'#dtSaqPagto\',\'#frmInclusao\').focus();';
		exibirErro('error',utf8_encode($msgErro),'Alerta - Ayllos',$retornoAposErro,false);
	}
	
	// Caso não apresentou erro, apenas remover a mensagem de "Aguarde..."
	echo 'hideMsgAguardo();';
?>