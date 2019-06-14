<? 
/*!
 * FONTE        : solicitar_talonario.php
 * CRIA��O      : Lombardi
 * DATA CRIA��O : 28/05/2018
 * OBJETIVO     : Solicita talonario.
 */

	session_start();
	require_once('../../../includes/config.php');
	require_once('../../../includes/funcoes.php');	
	require_once('../../../includes/controla_secao.php');
	require_once('../../../class/xmlfile.php');
	isPostMethod();	
		
	// Verifica permiss�es de acessa a tela
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],'S',false)) <> '') 
		exibirErro('error',$msgError,'Alerta - Aimaro','bloqueiaFundo(divRotina)',false);
		
	$nrdconta = isset($_POST['nrdconta']) ? $_POST['nrdconta'] : 0;
	
	// Monta o xml de requisi��o
	$xml  = "";
	$xml .= "<Root>";
	$xml .= "	<Dados>";
	$xml .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xml .= "	</Dados>";
	$xml .= "</Root>";
	
	// Executa script para envio do XML
	$xmlResult = mensageria($xml, "CHEQ0001", "SOLICITA_TALONARIO", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObject = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra cr�tica
	if (strtoupper($xmlObject->roottag->tags[0]->name) == "ERRO") {
		$msgErro = $xmlObject->roottag->tags[0]->tags[0]->tags[4]->cdata;
		exibirErro('error',utf8_encode($msgErro),'Alerta - Aimaro','bloqueiaFundo(divRotina)',false);
	}
	
	exibirErro('inform','Talon�rio solicitado com sucesso.','Alerta - Aimaro','bloqueiaFundo(divRotina)',false);
	
?>