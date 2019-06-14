<? 
/*!
 * FONTE        : titulos_limite_alterar_numero.php
 * CRIA��O      : Lucas Lunelli
 * DATA CRIA��O : Dezembro/2015
 * OBJETIVO     : Realizar altera��o de n�mero do contrato da proposta de 
				  limite de desconto de titulos (SD 360072 [M175])        		        				   
 * --------------
 * ALTERA��ES   :
 * --------------
 * 000: [00/00/0000] : 
 *
 * 
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
	
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"A")) <> "") {
		exibeErro($msgError);		
	}	
	
	// Verifica se o n�mero da conta foi informado
	if (!isset($_POST["nrdconta"]) ||
		!isset($_POST["nrctrant"]) ||
		!isset($_POST["nrctrlim"])) {
		exibeErro("Par&acirc;metros incorretos.");
	}

	$nrdconta = $_POST["nrdconta"];
	$nrctrlim = $_POST["nrctrlim"];
	$nrctrant = $_POST["nrctrant"];

	// Verifica se o n�mero da conta � um inteiro v�lido
	if (!validaInteiro($nrdconta)) {
		exibeErro("Conta/dv inv&aacute;lida.");
	}
	
	// Verifica se o n�mero do contrato � um inteiro v�lido
	if (!validaInteiro($nrctrlim)) {
		exibeErro("N&uacute;mero do contrato inv&aacute;lido.");
	}	
	
	// Monta o xml de requisi��o
	$xmlGetDados = "";
	$xmlGetDados .= "<Root>";
	$xmlGetDados .= "	<Cabecalho>";
	$xmlGetDados .= "		<Bo>b1wgen0030.p</Bo>";
	$xmlGetDados .= "		<Proc>altera-numero-proposta-limite</Proc>";
	$xmlGetDados .= "	</Cabecalho>";
	$xmlGetDados .= "	<Dados>";
	$xmlGetDados .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlGetDados .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xmlGetDados .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xmlGetDados .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xmlGetDados .= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";	
	$xmlGetDados .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";	
	$xmlGetDados .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xmlGetDados .= "		<idseqttl>1</idseqttl>";
	$xmlGetDados .= "		<dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
	$xmlGetDados .= "		<nrctrant>".$nrctrant."</nrctrant>";
	$xmlGetDados .= "		<nrctrlim>".$nrctrlim."</nrctrlim>";
	$xmlGetDados .= "	</Dados>";
	$xmlGetDados .= "</Root>";
		
	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlGetDados);
	
	// Cria objeto para classe de tratamento de XML
	$xmlObjDados = getObjectXML(retiraAcentos(removeCaracteresInvalidos($xmlResult)));
	
	// Se ocorrer um erro, mostra cr�tica
	if (strtoupper($xmlObjDados->roottag->tags[0]->name) == "ERRO") {
		exibeErro($xmlObjDados->roottag->tags[0]->tags[0]->tags[4]->cdata);
	} 
	
	$dados = $xmlObjDados->roottag->tags[0]->tags[0]->tags;
	
	// Fun��o para exibir erros na tela atrav�s de javascript
	function exibeErro($msgErro) {
		echo '<script type="text/javascript">';
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Aimaro","$(\'#new_nrctrlim\',\'#frmNumero\').focus();blockBackground(parseInt($(\'#divUsoGenerico\').css(\'z-index\')))");';
		echo '</script>';
		exit();
	}
	
?>
<script type="text/javascript">
	showError("inform","Registro alterado com sucesso.","Alerta - Aimaro","fechaRotinaAltera();");
</script>