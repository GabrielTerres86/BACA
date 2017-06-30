<? 
/*!
 * FONTE        : cheques_limite_incluir_validaefetuainclusao.php
 * CRIA��O      : Guilherme
 * DATA CRIA��O : Mar�o/2009
 * OBJETIVO     : Validar n�mero do contrato e efetuar a inclus�o do novo limite de desconto	             		        				   
 * --------------
 * ALTERA��ES   :
 * --------------
 * 001: [06/05/2011] Rogerius Militao      (DB1) : Adapta��o no formul�rio de avalista gen�rico
 * 002: [26/05/2017] Odirlei Busana      (AMcom) : Incluido retorno do nrctrlim. PRJ300 - Desconto de cheque
 */
?>

<?php 
	session_start();
	
	// Includes para controle da session, vari�veis globais de controle, e biblioteca de fun��es	
	require_once("../../../../includes/config.php");
	require_once("../../../../includes/funcoes.php");
	require_once("../../../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo m�todo POST
	isPostMethod();	
		
	// Classe para leitura do xml de retorno
	require_once("../../../../class/xmlfile.php");
	
	// Verifica se os par�metros necess�rios foram informados
	$params = array("nrdconta","nrctrlim","cddlinha","vllimite","dsramati","vlmedtit","vlfatura","vloutras","vlsalari","vlsalcon","dsdbens1","dsdbens2","dsobserv","qtdiavig",
                    "nrctaav1","nmdaval1","nrcpfav1","tpdocav1","dsdocav1","nmdcjav1","cpfcjav1","tdccjav1","doccjav1","ende1av1","ende2av1","nrcepav1","nmcidav1","cdufava1","nrfonav1","emailav1",
                    "nrctaav2","nmdaval2","nrcpfav2","tpdocav2","dsdocav2","nmdcjav2","cpfcjav2","tdccjav2","doccjav2","ende1av2","ende2av2","nrcepav2","nmcidav2","cdufava2","nrfonav2","emailav2",
                    "redirect");

	foreach ($params as $nomeParam) {
		if (!in_array($nomeParam,array_keys($_POST))) {			
			exibeErro("Par&acirc;metros incorretos.");
		}	
	}				  

	$nrdconta = $_POST["nrdconta"];
	$nrctrlim = $_POST["nrctrlim"];
	$diaratin = $_POST["qtdiavig"];
	$vllimite = $_POST["vllimite"];
	$dsramati = $_POST["dsramati"];
	$vlmedtit = $_POST["vlmedtit"];
	$vlfatura = $_POST["vlfatura"];
	$vloutras = $_POST["vloutras"];
	$vlsalari = $_POST["vlsalari"];
	$vlsalcon = $_POST["vlsalcon"];
	$dsdbens1 = $_POST["dsdbens1"];
	$dsdbens2 = $_POST["dsdbens2"];
	$dsobserv = $_POST["dsobserv"];
	$qtdiavig = $_POST["qtdiavig"];
	$cddlinha = $_POST["cddlinha"];

	$nrctaav1 = $_POST["nrctaav1"];
	$nmdaval1 = $_POST["nmdaval1"];
	$nrcpfav1 = $_POST["nrcpfav1"];
	$tpdocav1 = $_POST["tpdocav1"];
	$dsdocav1 = $_POST["dsdocav1"];
	$nmdcjav1 = $_POST["nmdcjav1"];
	$cpfcjav1 = $_POST["cpfcjav1"];
	$tdccjav1 = $_POST["tdccjav1"];
	$doccjav1 = $_POST["doccjav1"];
	$ende1av1 = $_POST["ende1av1"];
	$ende2av1 = $_POST["ende2av1"];
	$nrcepav1 = $_POST["nrcepav1"];
	$nmcidav1 = $_POST["nmcidav1"];
	$cdufava1 = $_POST["cdufava1"];
	$nrfonav1 = $_POST["nrfonav1"];	
	$emailav1 = $_POST["emailav1"];	
	$nrender1 = $_POST['nrender1'];	
	$complen1 = $_POST['complen1'];	
	$nrcxaps1 = $_POST['nrcxaps1'];	

	$nrctaav2 = $_POST["nrctaav2"];
	$nmdaval2 = $_POST["nmdaval2"];
	$nrcpfav2 = $_POST["nrcpfav2"];
	$tpdocav2 = $_POST["tpdocav2"];
	$dsdocav2 = $_POST["dsdocav2"];
	$nmdcjav2 = $_POST["nmdcjav2"];
	$cpfcjav2 = $_POST["cpfcjav2"];
	$tdccjav2 = $_POST["tdccjav2"];
	$doccjav2 = $_POST["doccjav2"];
	$ende1av2 = $_POST["ende1av2"];
	$ende2av2 = $_POST["ende2av2"];
	$nrcepav2 = $_POST["nrcepav2"];
	$nmcidav2 = $_POST["nmcidav2"];
	$cdufava2 = $_POST["cdufava2"];
	$nrfonav2 = $_POST["nrfonav2"];
	$emailav2 = $_POST["emailav2"];	
	$nrender2 = $_POST['nrender2'];	
	$complen2 = $_POST['complen2'];	
	$nrcxaps2 = $_POST['nrcxaps2'];	

	// Verifica se n�mero da conta � um inteiro v�lido
	if (!validaInteiro($nrdconta)) {
		exibeErro("Conta/dv inv&aacute;lida.");
	}

	// Verifica se o do contrato � um inteiro v�lido
	if (!validaInteiro($nrctrlim)) {
		exibeErro("N&uacute;mero do contrato inv&aacute;lido.");
	}
	
	// Verifica se o c�digo do contrato � um inteiro v�lido
	if (!validaInteiro($cddlinha)) {
		exibeErro("C&oacute;digo da linha de desconto inv&aacute;lido.");
	}	
	
	// Verifica se n�mero da conta do 1� avalista � um inteiro v�lido
	if (!validaInteiro($nrctaav1)) {
		exibeErro("Conta/dv do 1o Avalista inv&aacute;lida.");
	}
	
	// Verifica se n�mero da conta do 2� avalista � um inteiro v�lido
	if (!validaInteiro($nrctaav2)) {
		exibeErro("Conta/dv do 2o Avalista inv&aacute;lida.");
	}	
	
	// Verifica se CPF do 1� avalista � um inteiro v�lido
	if (!validaInteiro($nrcpfav1)) {
		exibeErro("CPF do 1o Avalista inv&aacute;lido.");
	}	
	
	// Verifica se CPF do Conjug� do 1� avalista � um inteiro v�lido
	if (!validaInteiro($cpfcjav1)) {
		exibeErro("CPF do C&ocirc;njuge do 1o Avalista inv&aacute;lido.");
	}	
	
	// Verifica se CPF do 2� avalista � um inteiro v�lido
	if (!validaInteiro($nrcpfav2)) {
		exibeErro("CPF do 2o Avalista inv&aacute;lido.");
	}	
	
	// Verifica se CPF do Conjug� do 2� avalista � um inteiro v�lido
	if (!validaInteiro($cpfcjav2)) {
		exibeErro("CPF do C&ocirc;njuge do 2o Avalista inv&aacute;lido.");
	}	
	
	// Verifica se CEP do 2� avalista � um inteiro v�lido
	if (!validaInteiro($nrcepav1)) {
		exibeErro("CEP do 1o Avalista inv&aacute;lido.");
	}	
	
	// Verifica se CEP do 2� avalista � um inteiro v�lido
	if (!validaInteiro($nrcepav2)) {
		exibeErro("CEP do 2o Avalista inv&aacute;lido.");
	}		

	// Monta o xml de requisi��o
	$xmlSetDadosLimIncluir  = "";
	$xmlSetDadosLimIncluir .= "<Root>";
	$xmlSetDadosLimIncluir .= "	<Cabecalho>";
	$xmlSetDadosLimIncluir .= "		<Bo>b1wgen0009.p</Bo>";
	$xmlSetDadosLimIncluir .= "		<Proc>efetua_inclusao_limite</Proc>";
	$xmlSetDadosLimIncluir .= "	</Cabecalho>";
	$xmlSetDadosLimIncluir .= "	<Dados>";
	$xmlSetDadosLimIncluir .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlSetDadosLimIncluir .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xmlSetDadosLimIncluir .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xmlSetDadosLimIncluir .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xmlSetDadosLimIncluir .= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
	$xmlSetDadosLimIncluir .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";
	$xmlSetDadosLimIncluir .= "		<idseqttl>1</idseqttl>";
	$xmlSetDadosLimIncluir .= "		<dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
	$xmlSetDadosLimIncluir .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xmlSetDadosLimIncluir .= "		<vllimite>".$vllimite."</vllimite>";
	$xmlSetDadosLimIncluir .= "		<dsramati>".$dsramati."</dsramati>";
	$xmlSetDadosLimIncluir .= "		<vlmedtit>".$vlmedtit."</vlmedtit>";
	$xmlSetDadosLimIncluir .= "		<vlfatura>".$vlfatura."</vlfatura>";
	$xmlSetDadosLimIncluir .= "		<vloutras>".$vloutras."</vloutras>";
	$xmlSetDadosLimIncluir .= "		<vlsalari>".$vlsalari."</vlsalari>";
	$xmlSetDadosLimIncluir .= "		<vlsalcon>".$vlsalcon."</vlsalcon>";
	$xmlSetDadosLimIncluir .= "		<dsdbens1>".$dsdbens1."</dsdbens1>";
	$xmlSetDadosLimIncluir .= "		<dsdbens2>".$dsdbens2."</dsdbens2>";
	$xmlSetDadosLimIncluir .= "		<nrctrlim>".$nrctrlim."</nrctrlim>";
	$xmlSetDadosLimIncluir .= "		<cddlinha>".$cddlinha."</cddlinha>";
	$xmlSetDadosLimIncluir .= "		<dsobserv>".$dsobserv."</dsobserv>";
	$xmlSetDadosLimIncluir .= "		<qtdiavig>".$qtdiavig."</qtdiavig>";
	$xmlSetDadosLimIncluir .= "		<nrctaav1>".$nrctaav1."</nrctaav1>";
	$xmlSetDadosLimIncluir .= "		<nmdaval1>".$nmdaval1."</nmdaval1>";
	$xmlSetDadosLimIncluir .= "		<nrcpfav1>".$nrcpfav1."</nrcpfav1>";
	$xmlSetDadosLimIncluir .= "		<tpdocav1>".$tpdocav1."</tpdocav1>";
	$xmlSetDadosLimIncluir .= "		<dsdocav1>".$dsdocav1."</dsdocav1>";
	$xmlSetDadosLimIncluir .= "		<nmdcjav1>".$nmdcjav1."</nmdcjav1>";
	$xmlSetDadosLimIncluir .= "		<cpfcjav1>".$cpfcjav1."</cpfcjav1>";
	$xmlSetDadosLimIncluir .= "		<tdccjav1>".$tdccjav1."</tdccjav1>";
	$xmlSetDadosLimIncluir .= "		<doccjav1>".$doccjav1."</doccjav1>";
	$xmlSetDadosLimIncluir .= "		<ende1av1>".$ende1av1."</ende1av1>";
	$xmlSetDadosLimIncluir .= "		<ende2av1>".$ende2av1."</ende2av1>";
	$xmlSetDadosLimIncluir .= "		<nrcepav1>".$nrcepav1."</nrcepav1>";
	$xmlSetDadosLimIncluir .= "		<nmcidav1>".$nmcidav1."</nmcidav1>";
	$xmlSetDadosLimIncluir .= "		<cdufava1>".$cdufava1."</cdufava1>";
	$xmlSetDadosLimIncluir .= "		<nrfonav1>".$nrfonav1."</nrfonav1>";
	$xmlSetDadosLimIncluir .= "		<emailav1>".$emailav1."</emailav1>";
	$xmlSetDadosLimIncluir .= "		<nrender1>".$nrender1."</nrender1>";
	$xmlSetDadosLimIncluir .= "		<complen1>".$complen1."</complen1>";
	$xmlSetDadosLimIncluir .= "		<nrcxaps1>".$nrcxaps1."</nrcxaps1>";	
	$xmlSetDadosLimIncluir .= "		<nrctaav2>".$nrctaav2."</nrctaav2>";
	$xmlSetDadosLimIncluir .= "		<nmdaval2>".$nmdaval2."</nmdaval2>";
	$xmlSetDadosLimIncluir .= "		<nrcpfav2>".$nrcpfav2."</nrcpfav2>";
	$xmlSetDadosLimIncluir .= "		<tpdocav2>".$tpdocav2."</tpdocav2>";
	$xmlSetDadosLimIncluir .= "		<dsdocav2>".$dsdocav2."</dsdocav2>";
	$xmlSetDadosLimIncluir .= "		<nmdcjav2>".$nmdcjav2."</nmdcjav2>";
	$xmlSetDadosLimIncluir .= "		<cpfcjav2>".$cpfcjav2."</cpfcjav2>";
	$xmlSetDadosLimIncluir .= "		<tdccjav2>".$tdccjav2."</tdccjav2>";
	$xmlSetDadosLimIncluir .= "		<doccjav2>".$doccjav2."</doccjav2>";
	$xmlSetDadosLimIncluir .= "		<ende1av2>".$ende1av2."</ende1av2>";
	$xmlSetDadosLimIncluir .= "		<ende2av2>".$ende2av2."</ende2av2>";
	$xmlSetDadosLimIncluir .= "		<nrcepav2>".$nrcepav2."</nrcepav2>";
	$xmlSetDadosLimIncluir .= "		<nmcidav2>".$nmcidav2."</nmcidav2>";
	$xmlSetDadosLimIncluir .= "		<cdufava2>".$cdufava2."</cdufava2>";
	$xmlSetDadosLimIncluir .= "		<nrfonav2>".$nrfonav2."</nrfonav2>";
	$xmlSetDadosLimIncluir .= "		<emailav2>".$emailav2."</emailav2>";
	$xmlSetDadosLimIncluir .= "		<nrender2>".$nrender2."</nrender2>";
	$xmlSetDadosLimIncluir .= "		<complen2>".$complen2."</complen2>";
	$xmlSetDadosLimIncluir .= "		<nrcxaps2>".$nrcxaps2."</nrcxaps2>";	
	$xmlSetDadosLimIncluir .= "	</Dados>";
	$xmlSetDadosLimIncluir .= "</Root>";
	
	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlSetDadosLimIncluir);
	
	// Cria objeto para classe de tratamento de XML
	$xmlObjDadosLimIncluir = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra cr�tica
	if (strtoupper($xmlObjDadosLimIncluir->roottag->tags[0]->name) == "ERRO") {
		exibeErro($xmlObjDadosLimIncluir->roottag->tags[0]->tags[0]->tags[4]->cdata);
	}else {
        // Buscar numer do contrato gerado 
        $nrctrlim = $xmlObjLimite->roottag->tags[0]->attributes["NRCTRLIM"];
	} 	

	// Esconde mensagem de aguardo
	// Bloqueia conte�do que est� �tras do div da rotina
	echo 'hideMsgAguardo();';
	echo 'blockBackground(parseInt($("#divRotina").css("z-index")));';
	
	echo 'nrcontrato = '.$nrctrlim.';';
	echo 'idLinhaL = 0;';
	
	// Carrega os limites de desconto de CHEQUES
	echo 'mostraImprimirLimite();';
	
	// Fun��o para exibir erros na tela atrav�s de javascript
	function exibeErro($msgErro) { 
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Ayllos","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
		exit();
	}
		
	
?>
