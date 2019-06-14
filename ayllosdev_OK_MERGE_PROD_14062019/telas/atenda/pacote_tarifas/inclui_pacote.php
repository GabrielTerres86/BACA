<? 
/***************************************************************************************
 * FONTE        : inclui_pacote.php				�ltima altera��o: --/--/----
 * CRIA��O      : Lombardi
 * DATA CRIA��O : Abril/2016
 * OBJETIVO     : 
 
	 Altera��es   : 
  		 
     30/10/2018 - Merge Changeset 26538 referente ao P435 - Tarifas Avulsas (Peter - Supero) 
 
 **************************************************************************************/

	session_start();
		
	require_once('../../../includes/config.php');
	require_once('../../../includes/funcoes.php');
	require_once('../../../class/xmlfile.php');
	
	isPostMethod();		
	
	// Guardo os par�metos do POST em vari�veis	
	$cdpacote           = (isset($_POST['cdpacote']))           ? $_POST['cdpacote']           : 0;
	$dtdiadebito        = (isset($_POST['dtdiadebito']))        ? $_POST['dtdiadebito']        : 0;
	$perdesconto_manual = (isset($_POST['perdesconto_manual'])) ? $_POST['perdesconto_manual'] : 0;
	$qtdmeses_desconto  = (isset($_POST['qtdmeses_desconto']))  ? $_POST['qtdmeses_desconto']  : 0;
	$nrdconta           = (isset($_POST['nrdconta']))  			? $_POST['nrdconta']  		   : 0;
	$idparame_reciproci = (isset($_POST['idparame_reciproci'])) ? $_POST['idparame_reciproci'] : 0;
	$idtipo_autorizacao = (isset($_POST['idtipo_autorizacao'])) ? $_POST['idtipo_autorizacao'] : 0;
	
    $xmlValidaInclusao  = "";
	$xmlValidaInclusao .= "<Root>";
	$xmlValidaInclusao .= "   <Dados>";
	$xmlValidaInclusao .= "	   <cdpacote>".$cdpacote."</cdpacote>";
	$xmlValidaInclusao .= "	   <dtdiadebito>".$dtdiadebito."</dtdiadebito>";
	$xmlValidaInclusao .= "	   <perdesconto_manual>".$perdesconto_manual."</perdesconto_manual>";
	$xmlValidaInclusao .= "	   <qtdmeses_desconto>".$qtdmeses_desconto."</qtdmeses_desconto>";
	$xmlValidaInclusao .= "	   <nrdconta>".$nrdconta."</nrdconta>";
	$xmlValidaInclusao .= "	   <idparame_reciproci>".$idparame_reciproci."</idparame_reciproci>";
	$xmlValidaInclusao .= "	   <idtipo_autorizacao>".$idtipo_autorizacao."</idtipo_autorizacao>";
	$xmlValidaInclusao .= "   </Dados>";
	$xmlValidaInclusao .= "</Root>";
  
	// Executa script para envio do XML	
	$xmlResult = mensageria($xmlValidaInclusao, "ADEPAC", "INCLUI_PACOTE", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	
	$xmlObjValidaInclusao = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra cr�tica
	if (strtoupper($xmlObjValidaInclusao->roottag->tags[0]->name) == "ERRO") {
	
		$msgErro  = utf8_encode($xmlObjValidaInclusao->roottag->tags[0]->tags[0]->tags[4]->cdata);
				 
		exibirErro('error',$msgErro,'Alerta - Aimaro','bloqueiaFundo(divRotina);',false);		
							
	} 
		
	exibirErro('inform','Opera&ccedil;&atilde;o efetuada com sucesso!','Alerta - Aimaro','imprimirAdesaoPct('.$nrdconta.',\''.$glbvars["dtmvtolt"].'\'); acessaOpcaoAba(1,0,0);',false);
	
?>