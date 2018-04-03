<? 
/*!
 * FONTE        : altera_cadcyb.php
 * CRIAÇÃO      : Lucas R.
 * DATA CRIAÇÃO : Agosto/2013
 * OBJETIVO     : Rotina para alterar as informações da tela CADCYB
 * --------------
 * ALTERAÇÕES   : 01/09/2015 - Adicionado os campos de Assessoria e Motivo CIN (Douglas - Melhoria 12)
 *                03/04/2018 - Convertido para chamada via Oracle (Chamado 806202)
 * -------------- 
 */
 
    session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();		

	echo 'blockBackground(parseInt($("#divRotina").css("z-index")));';	
	
	// Recebe a operação que está sendo realizada
	$nrdconta = (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : 0 ; 
	$nrctremp = (isset($_POST['nrctremp'])) ? $_POST['nrctremp'] : 0 ; 
	$cdorigem = (isset($_POST['cdorigem'])) ? $_POST['cdorigem'] : 0 ; 
	$flgjudic = $_POST["flgjudic"];
	$flextjud = $_POST["flextjud"];
	$flgehvip = $_POST["flgehvip"];
	$dtenvcbr = $_POST["dtenvcbr"];
	$cdassess = $_POST["cdassess"];
	$cdmotcin = $_POST["cdmotcin"];
	
	// Monta o xml dinâmico de acordo com a operação 
	$xml  = "";
	$xml .= "<Root>";
	$xml .= "	<Cabecalho>";
	$xml .= "		<Bo>b1wgen0170.p</Bo>";
	$xml .= "		<Proc>altera-dados-crapcyc</Proc>";
	$xml .= "	</Cabecalho>";
	$xml .= "	<Dados>";
	$xml .= "       <cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xml .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xml .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xml .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xml .= "		<dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";	
	$xml .= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";	
	$xml .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";
    $xml .= "       <nrdconta>".$nrdconta."</nrdconta>";
	$xml .= "       <nrctremp>".$nrctremp."</nrctremp>";
	$xml .= "       <cdorigem>".$cdorigem."</cdorigem>";
	$xml .= "       <flgjudic>".$flgjudic."</flgjudic>";
	$xml .= "       <flextjud>".$flextjud."</flextjud>";
	$xml .= "       <flgehvip>".$flgehvip."</flgehvip>";
	$xml .= "       <dtenvcbr>".$dtenvcbr."</dtenvcbr>";
	$xml .= "       <cdassess>".$cdassess."</cdassess>";
	$xml .= "       <cdmotcin>".$cdmotcin."</cdmotcin>";
	$xml .= "	</Dados>";
	$xml .= "</Root>";
	
	$xmlResult = getDataXML($xml);
	$xmlObjeto = getObjectXML($xmlResult);
	
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
		exibirErro('error',$msgErro,'Alerta - Ayllos','estadoInicial();',false);
	} else {
		echo 'showError("inform","Lan&ccedil;amentos alterados com sucesso.","Notifica&ccedil;&atilde;o - Ayllos","estadoInicial();");';		
	}

?>