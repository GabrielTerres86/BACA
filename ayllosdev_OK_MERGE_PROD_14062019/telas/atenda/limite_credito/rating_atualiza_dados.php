<?php 
/**
 * Autor: Bruno Luiz Katzjarowski - Mout's
 * Copia de rating_atualiza_dados.php de includes/rating/...
 * Ultima alteração:
 * 
 * Alteraçoes:
 */
	session_start();
	
	// Includes para controle da session, vari�veis globais de controle, e biblioteca de fun��es	
	require_once("../../../includes/config.php");
	require_once("../../../includes/funcoes.php");
	require_once("../../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo m�todo POST
	isPostMethod();	
	
	// Classe para leitura do xml de retorno
	require_once("../../class/xmlfile.php");
	
	// Se par�metros necess�rios n�o foram informados
	if (!isset($_POST["nrdconta"]) || !isset($_POST["nrinfcad"]) || !isset($_POST["nrpatlvr"]) || 
	    !isset($_POST["nrperger"]) || !isset($_POST["nrctrrat"]) || !isset($_POST["tpctrrat"]) ||
		!isset($_POST["iddivcri"])) {
		exibeErro("Par&acirc;metros incorretos.");
	}	

	$nrdconta = $_POST["nrdconta"];
	$nrinfcad = $_POST["nrinfcad"];
	$nrpatlvr = $_POST["nrpatlvr"];
	$nrperger = $_POST["nrperger"];
	$nrctrrat = $_POST["nrctrrat"];
	$tpctrrat = $_POST["tpctrrat"];
	$iddivcri = $_POST["iddivcri"];
	
	// Verifica se n�mero da conta � um inteiro v�lido
	if (!validaInteiro($nrdconta)) {
		exibeErro("Conta/dv inv&aacute;lida.");
	}
	
	// Verifica se identificador de informa��o cadastral � um inteiro v�lido
	if (!validaInteiro($nrinfcad)) {
		exibeErro("Informa&ccedil;&etilde;o cadastral inv&aacute;lida.");
	}
	
	// Verifica se identificador de patrim�nio � um inteiro v�lido
	if (!validaInteiro($nrpatlvr)) {
		exibeErro("Patrim&ocirc;nio pessoal inv&aacute;lido.");
	}
	
	// Verifica se identificador de percep��o � um inteiro v�lido
	if (!validaInteiro($nrperger)) {
		exibeErro("Percep&ccedil;&atilde;o geral inv&aacute;lida.");
	}	
	
	// Verifica se n�mero da conta � um inteiro v�lido
	if (!validaInteiro($tpctrrat)) {
		exibeErro("Indicador de tipo de contrato para rating inv&aacute;lido.");
	}
	
	// Verifica se n�mero da contrato � um inteiro v�lido
	if (!validaInteiro($nrctrrat)) {
		exibeErro("N&uacute;mero de contrato para rating inv&aacute;lido.");
	}	
	
	// Monta o xml de requisi��o
	$xmlRating  = "";
	$xmlRating .= "<Root>";
	$xmlRating .= "  <Cabecalho>";
	$xmlRating .= "    <Bo>b1wgen0043.p</Bo>";
	$xmlRating .= "    <Proc>atualiza_valores_rating</Proc>";
	$xmlRating .= "  </Cabecalho>";
	$xmlRating .= "  <Dados>";
	$xmlRating .= "    <cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlRating .= "    <cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xmlRating .= "    <nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xmlRating .= "    <cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xmlRating .= "    <nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
	$xmlRating .= "    <idorigem>".$glbvars["idorigem"]."</idorigem>";	
	$xmlRating .= "    <nrdconta>".$nrdconta."</nrdconta>";
	$xmlRating .= "    <idseqttl>1</idseqttl>";	
	$xmlRating .= "    <dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
	$xmlRating .= "    <inproces>".$glbvars["inproces"]."</inproces>";	
	$xmlRating .= "    <nrinfcad>".$nrinfcad."</nrinfcad>";		
	$xmlRating .= "    <nrpatlvr>".$nrpatlvr."</nrpatlvr>";
	$xmlRating .= "    <nrperger>".$nrperger."</nrperger>";	
	$xmlRating .= "    <nrctrrat>".$nrctrrat."</nrctrrat>";
	$xmlRating .= "    <tpctrrat>".$tpctrrat."</tpctrrat>";
	$xmlRating .= "  </Dados>";
	$xmlRating .= "</Root>";	
 
	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlRating,false);
	
	// Cria objeto para classe de tratamento de XML
	$xmlObjRating = getObjectXML($xmlResult);

	// Se ocorrer um erro, mostra cr�tica
	if (strtoupper($xmlObjRating->roottag->tags[0]->name) == "ERRO") { 		
		// Monta tabela com cr�ticas do rating
		include ("rating_tabela_criticas.php");
	} else {
		// Encerra mensagem de aguardo e bloqueia fundo da rotina
		echo 'hideMsgAguardo();';
		echo 'blockBackground(parseInt($("#divRotina").css("z-index")));';
		
		// Aciona fun��o para continuidade da opera��o
		echo 'eval(fncRatingSuccess);';
	}		
		
	// Fun��o para exibir erros na tela atrav�s de javascript
	function exibeErro($msgErro) { 
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Ayllos","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
		exit();
	}
	
?>