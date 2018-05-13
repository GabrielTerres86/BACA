<?php
	/*!
	 * FONTE        : altera_administradora.php
	 * CRIA��O      : Jean Michel
	 * DATA CRIA��O : Marco/2014
	 * OBJETIVO     : Efetua Downgrade ou Upgrade de administradora de cart�es
	 * --------------
	 * ALTERA��ES   : Incluso regra para efetuar reload da tela de cartoes (Daniel)
	 * --------------
	 * 000: ----- 
	 */

	session_start();
	require_once('../../../includes/config.php');
	require_once('../../../includes/funcoes.php');
	require_once('../../../includes/controla_secao.php');
	require_once('../../../class/xmlfile.php');
	isPostMethod();	
	
	
	$funcaoAposErro = 'bloqueiaFundo(divRotina);';
	
	// Verifica permiss�o
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"N")) <> "") {
		exibirErro('error',$msgError,'Alerta - Ayllos',$funcaoAposErro,false);
	}	
	
	// Verifica se os par�metros necess�rios foram informados
	if (!isset($_POST["nrdconta"]) || !isset($_POST["codaadmi"]) || !isset($_POST["codnadmi"]) || !isset($_POST["nrcrcard"])) {
		exibirErro('error','Par&acirc;metros incorretos.','Alerta - Ayllos',$funcaoAposErro,false);
	}	
	
	$nrdconta = $_POST["nrdconta"];
	$codaadmi = $_POST["codaadmi"];
	$codnadmi = $_POST["codnadmi"];
	$nrcrcard = $_POST["nrcrcard"];
	$nrctrcrd = $_POST['nrctrcrd'];

	// Verifica se n�mero da conta � um inteiro v�lido
	if (!validaInteiro($nrdconta)) exibirErro('error','Conta/dv inv&aacute;lida.','Alerta - Ayllos',$funcaoAposErro,false);
	if (!validaInteiro($codaadmi)) exibirErro('error','Antiga administradora inv&aacute;lida.','Alerta - Ayllos',$funcaoAposErro,false);
	if (!validaInteiro($codnadmi)) exibirErro('error','Nova administradora inv&aacute;lida.','Alerta - Ayllos',$funcaoAposErro,false);
	if (!validaInteiro($nrcrcard)) exibirErro('error','Cart&atilde; inv&aacute;lido.','Alerta - Ayllos',$funcaoAposErro,false);
	
	
    // Monta o xml de requisi��o
	$xmlSetCartao  = "";
	$xmlSetCartao .= "<Root>";
	$xmlSetCartao .= "	<Cabecalho>";
	$xmlSetCartao .= "		<Bo>b1wgen0028.p</Bo>";
	$xmlSetCartao .= "		<Proc>altera_administradora</Proc>";
	$xmlSetCartao .= "	</Cabecalho>";
	$xmlSetCartao .= "	<Dados>";
	$xmlSetCartao .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlSetCartao .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xmlSetCartao .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xmlSetCartao .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";
	$xmlSetCartao .= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
	$xmlSetCartao .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xmlSetCartao .= "		<dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
	$xmlSetCartao .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xmlSetCartao .= "		<codaadmi>".$codaadmi."</codaadmi>";
	$xmlSetCartao .= "		<codnadmi>".$codnadmi."</codnadmi>";
	$xmlSetCartao .= "		<nrcrcard>".$nrcrcard."</nrcrcard>";
	$xmlSetCartao .= "	</Dados>";
	$xmlSetCartao .= "</Root>";

	//xml envio esteira
	$bancoobXML = "<Root>";
	$bancoobXML .= " <Dados>";
	$bancoobXML .= "   <nrdconta>".$nrdconta."</nrdconta>";
	$bancoobXML .= "   <nrctrcrd>".$nrctrcrd."</nrctrcrd>";
	$bancoobXML .= "   <dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
	$bancoobXML .= " </Dados>";
	$bancoobXML .= "</Root>";

	$admresult = mensageria($bancoobXML, "ATENDA_CRD", "INCLUIR_PROPOSTA_ESTEIRA", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$procXML = simplexml_load_string($admresult);
	echo "/* Encaminhado para a esteira  $bancoobXML */";
	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlSetCartao);

    // Cria objeto para classe de tratamento de XML
	$xmlObjCartao = getObjectXML($xmlResult);
		
	// Se ocorrer um erro, mostra cr�tica
	if (strtoupper($xmlObjCartao->roottag->tags[0]->name) == "ERRO") {
		exibirErro('error',$xmlObjCartao->roottag->tags[0]->tags[0]->tags[4]->cdata,'Alerta - Ayllos',$funcaoAposErro,false);	
	}else{
		$dsmensag = $xmlObjCartao->roottag->tags[0]->tags[0]->tags[4]->cdata;
		echo 'showError("inform","'.$dsmensag.'","Alerta - Ayllos","voltaDiv(0,1,4); bloqueiaFundo(divRotina,\'nrctaav1\',\'frmNovoCartao\',false);");';
	}
	
	// Procura indice da opcao "@" - Principal
	$idPrincipal = array_search("@",$glbvars["opcoesTela"]);
	
	// Se o indice da opcao "@" foi encontrado - Carrega o principal novamente.
	if (!($idPrincipal === false)) {
		echo 'acessaOpcaoAba('.count($glbvars["opcoesTela"]).','.$idPrincipal.',"'.$glbvars["opcoesTela"][$idPrincipal].'");';
	}	else {
		echo 'acessaOpcaoAba('.count($glbvars["opcoesTela"]).',0,"'.$glbvars["opcoesTela"][0].'");';
	}
	
?>