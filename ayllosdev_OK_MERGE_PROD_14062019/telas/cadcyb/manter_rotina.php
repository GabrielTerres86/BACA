<? 
/*!
 * FONTE        : manter_rotina.php
 * CRIAÇÃO      : Lucas R.
 * DATA CRIAÇÃO : Agosto/2013
 * OBJETIVO     : Rotina para manter as operações da tela CADCYB
 * --------------
 * ALTERAÇÕES   : 01/10/2013 - Ajustado variavel $retornoAposErro para voltar ao estado inicial (Lucas R.)
 *
 *                31/08/2015 - Adicionado os campos de Assessoria e Motivo CIN (Douglas - Melhoria 12)
 *
 *                18/08/2018 - Adicionado tratativa produto desconto de titulo (GFT)
 * -------------- 
 */
 
    session_start();
	require_once("../../includes/config.php");
	require_once("../../includes/funcoes.php");
	require_once("../../includes/controla_secao.php");
	require_once("../../class/xmlfile.php");
	isPostMethod();		

	// Recebe a operação que está sendo realizada
	$lsdconta = $_POST["strNrdconta"]; 
	$lscontra = $_POST["strNrctremp"]; 
	$lsborder = $_POST["strNrborder"]; 
	$lstitulo = $_POST["strNrtitulo"]; 
	$lsorigem = $_POST["strCdorigem"]; 
	$lsjudici = $_POST["strFlgjudic"];
	$lsextjud = $_POST["strFlextjud"];
	$lsgehvip = $_POST["strFlgehvip"];	
	$lsdtenvc = $_POST["strDtcnvcbr"];
	$lsmotcin = $_POST["strCdmotcin"];
	$lsassess = $_POST["strCdassess"];
	
	$retornoAposErro = "estadoInicial();";
	
	// Monta o xml dinâmico de acordo com a operação 
	$xml  = "";
	$xml .= "<Root>";
	$xml .= "	<Cabecalho>";
	$xml .= "		<Bo>b1wgen0170.p</Bo>";
	$xml .= "		<Proc>grava-dados-crapcyc</Proc>";
	$xml .= "	</Cabecalho>";
	$xml .= "	<Dados>";
	$xml .= "       <cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xml .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xml .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xml .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xml .= "		<dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";	
	$xml .= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";	
	$xml .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";
    $xml .= "		<inproces>".$glbvars["inproces"]."</inproces>";
    $xml .= "       <idseqttl>1</idseqttl>";		
	$xml .= "       <lsdconta>".$lsdconta."</lsdconta>";
	$xml .= "       <lscontra>".$lscontra."</lscontra>";
	$xml .= "       <lsborder>".$lsborder."</lsborder>";
	$xml .= "       <lstitulo>".$lstitulo."</lstitulo>";
	$xml .= "       <lsorigem>".$lsorigem."</lsorigem>";
	$xml .= "       <lsjudici>".$lsjudici."</lsjudici>";
	$xml .= "       <lsextjud>".$lsextjud."</lsextjud>";
	$xml .= "       <lsgehvip>".$lsgehvip."</lsgehvip>";
	$xml .= "       <lsdtenvc>".$lsdtenvc."</lsdtenvc>";
	$xml .= "       <lsmotcin>".$lsmotcin."</lsmotcin>";
	$xml .= "       <lsassess>".$lsassess."</lsassess>";
	$xml .= "	</Dados>";
	$xml .= "</Root>";
	
	$xmlResult = getDataXML($xml);
	$xmlObjeto = getObjectXML($xmlResult);
	
	//----------------------------------------------------------------------------------------------------------------------------------	
	// Controle de Erros
	//----------------------------------------------------------------------------------------------------------------------------------
	if ( strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO" ) {
		$msgErro	= $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;
		exibirErro("error",$msgErro,"Alerta - Ayllos",$retornoAposErro,false);
	}
	
	echo "showError('inform','Lan&ccedil;amentos efetuados com sucesso.','Notifica&ccedil;&atilde;o - Ayllos','estadoInicial();');";

?>