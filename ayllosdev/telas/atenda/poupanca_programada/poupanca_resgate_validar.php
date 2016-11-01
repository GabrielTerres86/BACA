<?php 

	//************************************************************************//
	//*** Fonte: poupanca_resgate_validar.php                              ***//
	//*** Autor: David                                                     ***//
	//*** Data : Mar�o/2010                   �ltima Altera��o: 26/07/2016 ***//
	//***                                                                  ***//
	//*** Objetivo  : Validar resgate para poupan�a programada             ***//	
	//***                                                                  ***//	 
	//*** Altera��es: 22/06/2015 - Ajustes para verificar valor de alcada  ***//
	//***                          do operador - projeto melhoria captacao ***//
	//***                          (Tiago/Gielow).                         ***//
	//***			  26/07/2016 - Corrigi o tratamento para retorno de    ***//
	//***						   erro do XML. SD 479874 (Carlos R.)	   ***//
	//************************************************************************//
	
	session_start();
	
	// Includes para controle da session, vari�eis globais de controle, e biblioteca de fun��es	
	require_once("../../../includes/config.php");
	require_once("../../../includes/funcoes.php");		
	require_once("../../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo m�todo POST
	isPostMethod();	
	
	// Classe para leitura do xml de retorno
	require_once("../../../class/xmlfile.php");	
	
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"G")) <> "") {
		exibeErro($msgError);		
	}	
	
	// Se par�metros necess�rios n�o foram informados
	if (!isset($_POST["nrdconta"]) || !isset($_POST["nrctrrpp"]) || !isset($_POST["tpresgat"]) || 
	    !isset($_POST["vlresgat"]) || !isset($_POST["dtresgat"]) || !isset($_POST["flgctain"])) {
		exibeErro("Par&acirc;metros incorretos.");
	}	

	$nrdconta = $_POST["nrdconta"];
	$nrctrrpp = $_POST["nrctrrpp"];	
	$tpresgat = $_POST["tpresgat"];
	$vlresgat = (!isset($_POST['vlresgat'])) ? '0' : $_POST['vlresgat']; 
	$dtresgat = $_POST["dtresgat"];	
	$flgctain = $_POST["flgctain"];
	$cdoperad = (!isset($_POST['cdopera2'])) ? '' : $_POST['cdopera2']; 
	$cddsenha = (!isset($_POST['cddsenha'])) ? '' : $_POST['cddsenha']; 
	$flgsenha = 0;
	
	if($cdoperad != ''){
		$cdoperad = $_POST['cdopera2'];		
		$flgsenha = 1;
	}else{
		$cdoperad = $glbvars["cdoperad"];
	}
	
	// Verifica se n�mero da conta � um inteiro v�lido
	if (!validaInteiro($nrdconta)) {
		exibeErro("Conta/dv inv&aacute;lida.");
	}	
	
	// Verifica se o contrato da poupan�a um inteiro v�lido
	if (!validaInteiro($nrctrrpp)) {
		exibeErro("N&uacute;mero de contrato inv&aacute;lido.");
	}	
	
	// Verifica se o valor de resgate � um decimal v�lido
	if (!validaDecimal($vlresgat)) {
		exibeErro("Valor de resgate inv&aacute;lido.");
	}
	
	// Verifica se a data de resgate � v�lida
	if (!validaData($dtresgat)) {
		exibeErro("Data de resgate inv&aacute;lida.");
	}					
	
	// Verifica se flag de recebimento em conta investimento � v�lida
	if ($flgctain <> "yes" && $flgctain <> "no") {
		exibeErro("Identificador de resgate inv&aacute;lido.");
	}
	
	// Monta o xml de requisi��o
	$xmlResgate  = ""; 
	$xmlResgate .= "<Root>";
	$xmlResgate .= "	<Cabecalho>";
	$xmlResgate .= "		<Bo>b1wgen0006.p</Bo>";
	$xmlResgate .= "		<Proc>valida-resgate</Proc>";
	$xmlResgate .= "	</Cabecalho>";	
	$xmlResgate .= "	<Dados>";
	$xmlResgate .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlResgate .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xmlResgate .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xmlResgate .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xmlResgate .= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
	$xmlResgate .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";	
	$xmlResgate .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xmlResgate .= "		<idseqttl>1</idseqttl>";
	$xmlResgate .= "		<nrctrrpp>".$nrctrrpp."</nrctrrpp>"; 	
	$xmlResgate .= "		<dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";	
	$xmlResgate .= "		<dtmvtopr>".$glbvars["dtmvtopr"]."</dtmvtopr>";
	$xmlResgate .= "		<inproces>".$glbvars["inproces"]."</inproces>";
	$xmlResgate .= "		<cdprogra>".$glbvars["nmdatela"]."</cdprogra>"; 
	$xmlResgate .= "		<tpresgat>".$tpresgat."</tpresgat>"; 
	$xmlResgate .= "		<vlresgat>".$vlresgat."</vlresgat>"; 
	$xmlResgate .= "		<dtresgat>".$dtresgat."</dtresgat>"; 	
	$xmlResgate .= "		<flgoprgt>no</flgoprgt>";	
	$xmlResgate .= "	</Dados>";	
	$xmlResgate .= "</Root>";
	
	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlResgate);
	
	// Cria objeto para classe de tratamento de XML
	$xmlObjResgate = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra cr�tica
	if (strtoupper($xmlObjResgate->roottag->tags[0]->name) == "ERRO") {
		exibeErro($xmlObjResgate->roottag->tags[0]->tags[0]->tags[4]->cdata);
	} 
	
	if($tpresgat == 'T'){
	
		$vltotres = $xmlObjResgate->roottag->tags[0]->attributes["VLRESGAT"];
		
		if(!isset($vltotres)){
			$vltotres = 0;
		}

		if($vltotres > 0){
			$vlresgat = $vltotres;
		}
		
	} 
/* segunda chamada */
	// Monta o xml de requisi��o
	$xmlResgate  = ""; 
	$xmlResgate .= "<Root>";
	$xmlResgate .= "	<Cabecalho>";
	$xmlResgate .= "		<Bo>b1wgen0006.p</Bo>";
	$xmlResgate .= "		<Proc>validar-limite-resgate</Proc>";
	$xmlResgate .= "	</Cabecalho>";	
	$xmlResgate .= "	<Dados>";
	$xmlResgate .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";		
	$xmlResgate .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";	
	$xmlResgate .= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
	$xmlResgate .= "		<idseqttl>1</idseqttl>";
	$xmlResgate .= "		<nrdconta>".$nrdconta."</nrdconta>";	
	$xmlResgate .= "		<vlrrsgat>".$vlresgat."</vlrrsgat>";	
	$xmlResgate .= "		<cdoperad>".$cdoperad."</cdoperad>";	
	$xmlResgate .= "		<cddsenha>".$cddsenha."</cddsenha>";	
	$xmlResgate .= "		<flgsenha>".$flgsenha."</flgsenha>";		
	$xmlResgate .= "	</Dados>";	
	$xmlResgate .= "</Root>";
	
	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlResgate);
	
	// Cria objeto para classe de tratamento de XML
	$xmlObjResgate = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra cr�tica
	if (isset($xmlObjResgate->roottag->tags[0]->name) && strtoupper($xmlObjResgate->roottag->tags[0]->name) == "ERRO") {
		exibeErro($xmlObjResgate->roottag->tags[0]->tags[0]->tags[4]->cdata);
	} 

/* fim segunda chamada */

	
	// Esconde mensagem de aguardo
	echo 'hideMsgAguardo();';	
	
	// Confirma opera��o
	echo 'showConfirmacao("Deseja efetuar o resgate?","Confirma&ccedil;&atilde;o - Ayllos","efetuarResgate(\''.$cdoperad.'\',\''.$tpresgat.'\',\''.$vlresgat.'\',\''.$dtresgat.'\',\''.$flgctain.'\')","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))","sim.gif","nao.gif");';	
	
	// Fun��o para exibir erros na tela atrav�s de javascript
	function exibeErro($msgErro) { 
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Ayllos","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
		exit();
	}
	
?>