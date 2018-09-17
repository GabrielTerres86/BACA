<? 
/*!
 * FONTE        : valida_tipo_declarado.php
 * CRIAÇÃO      : Mateus Zimmermann (Mouts)
 * DATA CRIAÇÃO : 15/05/2018
 * OBJETIVO     : Rotina para validar o tipo declarado
 * ALTERACOES	: 
 */
?>
 
<?	
    session_start();
	require_once("../../includes/config.php");
	require_once("../../includes/funcoes.php");
	require_once("../../includes/controla_secao.php");
	require_once("../../class/xmlfile.php");
	isPostMethod();	

	// Guardo os parâmetos do POST em variáveis
	$cdtipo_declarado = (isset($_POST['cdtipo_declarado'])) ? $_POST['cdtipo_declarado'] : '' ;

	$xml  = "";
	$xml .= "<Root>";
	$xml .= "  <Dados>";
	$xml .= '	 <cdtipo_dominio>'.$cdtipo_declarado.'</cdtipo_dominio>';
	$xml .= "    <idtipo_dominio>D</idtipo_dominio>";
	$xml .= "  </Dados>";
	$xml .= "</Root>";

	// Executa script para envio do XML
	$xmlResult = mensageria($xml, "TELA_REPEXT", 'VALIDA_DOMINIO_TIPO', $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"],  "</Root>");
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

	echo "$('#inexige_proprietario','#frmAlterarCompliance').val('". getByTagName($dados,'inexige_proprietario') ."');";

?>