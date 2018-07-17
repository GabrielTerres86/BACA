<? 
/*!
 * FONTE        : altera_cadcyb.php
 * CRIA��O      : Lucas R.
 * DATA CRIA��O : Agosto/2013
 * OBJETIVO     : Rotina para alterar as informa��es da tela CADCYB
 * --------------
 * ALTERA��ES   : 01/09/2015 - Adicionado os campos de Assessoria e Motivo CIN (Douglas - Melhoria 12)
 *                03/04/2018 - Convertido para chamada via Oracle (Chamado 806202)
 *				  21/06/2018 - Inser��o de bordero e titulo [Vitor Shimada Assanuma (GFT)]
 * -------------- 
 */
 
    session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();		

	echo 'blockBackground(parseInt($("#divRotina").css("z-index")));';	
	
	// Recebe a opera��o que est� sendo realizada
	$nrdconta = (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : 0 ; 
	$nrctremp = (isset($_POST['nrctremp'])) ? $_POST['nrctremp'] : 0 ; 
	$cdorigem = (isset($_POST['cdorigem'])) ? $_POST['cdorigem'] : 0 ; 
	$flgjudic = $_POST["flgjudic"];
	$flextjud = $_POST["flextjud"];
	$flgehvip = $_POST["flgehvip"];
	$dtenvcbr = $_POST["dtenvcbr"];
	$cdassess = $_POST["cdassess"];
	$cdmotcin = $_POST["cdmotcin"];
	
	// Monta o xml din�mico de acordo com a opera��o 
	$xml  = "";
	$xml .= "<Root>";
	$xml .= "	<Dados>";
	$xml .= "       <cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xml .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xml .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xml .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xml .= "		<dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";	
	$xml .= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";	
	$xml .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";
    $xml .= "       <nrdconta>".$nrdconta."</nrdconta>";
	$xml .= "       <nrctremp>".str_replace(".","",str_replace(",","",$nrctremp))."</nrctremp>";
	$xml .= "       <cdorigem>".$cdorigem."</cdorigem>";
	$xml .= "       <flgjudic>".$flgjudic."</flgjudic>";
	$xml .= "       <flextjud>".$flextjud."</flextjud>";
	$xml .= "       <flgehvip>".$flgehvip."</flgehvip>";
	$xml .= "       <dtenvcbr>".$dtenvcbr."</dtenvcbr>";
	$xml .= "       <cdassess>".$cdassess."</cdassess>";
	$xml .= "       <cdmotcin>".$cdmotcin."</cdmotcin>";
	$xml .= "	</Dados>";
	$xml .= "</Root>";
	
	// Executa script para envio do XML
    $xmlResult = mensageria($xml, "CADCYB", "ALTERA_DADOS_CADCYB", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");

	// Cria objeto para classe de tratamento de XML
	$xmlObjeto = getObjectXML($xmlResult);

	//----------------------------------------------------------------------------------------------------------------------------------	
	// Controle de Erros
	//----------------------------------------------------------------------------------------------------------------------------------
	if ( strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO" ) {
		$msgErro	= $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;
		exibirErro('error',$msgErro,'Alerta - Ayllos','',false);
	}
	
	if ( strtoupper($xmlObjeto->roottag->tags[0]->name) == "MSG" ) {
		$msgErro    = $xmlObjeto->roottag->tags[0]->cdata;
		$msgErro    = $msgErro . "Lan&ccedil;amentos alterados com sucesso.";
		echo 'showError("inform","'.$msgErro.'","Notifica&ccedil;&atilde;o - Ayllos","estadoInicial();");';
	} else {
		echo 'showError("inform","Lan&ccedil;amentos alterados com sucesso.","Notifica&ccedil;&atilde;o - Ayllos","estadoInicial();");';		
	}

?>