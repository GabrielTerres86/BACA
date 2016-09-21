<? 
	/*!
	 * FONTE        : carrega_motivo_cancelamento.php
	 * CRIA��O      : Rog�rio Giacomini de Almeida
	 * DATA CRIA��O : 21/09/2011
	 * OBJETIVO     : Exibir lista de motivos de cancelamento de seguros da tela ATENDA
	 */

	session_start();
	
	// Includes para controle da session, vari�veis globais de controle, e biblioteca de fun��es	
	require_once("../../../includes/config.php");
	require_once("../../../includes/funcoes.php");		
	require_once("../../../includes/controla_secao.php");
	// Classe para leitura do xml de retorno
	require_once("../../../class/xmlfile.php");
	
	// Verifica se tela foi chamada pelo m�todo POST
	isPostMethod();

	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"@")) <> "") {
		exibeErro($msgError);		
	}
	
	// Verifica se o n�mero da conta foi informado
	if (!isset($_POST['nrdconta'])) exibirErro('error','Par�metros incorretos.','Alerta - Ayllos','fechaRotina(divRotina)',false);	

	$nrdconta = $_POST['nrdconta'] == '' ? 0 : $_POST['nrdconta'];
	
	// Monta o xml de requisi��o
	$xml  = "";
	$xml .= "<Root>";
	$xml .= "	<Cabecalho>";
	$xml .= "		<Bo>b1wgen0033.p</Bo>";
	$xml .= "		<Proc>buscar_motivo_can</Proc>";
	$xml .= "	</Cabecalho>";
	$xml .= "	<Dados>";
	$xml .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xml .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xml .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xml .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xml .= "		<dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
	$xml .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xml .= "		<idseqttl>1</idseqttl>";
	$xml .= "		<idorigem>".$glbvars['idorigem']."</idorigem>";
	$xml .= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";	
	$xml .= "	</Dados>";
	$xml .= "</Root>";

		// Executa script para envio do XML
	$xmlResult = getDataXML($xml);
	
	// Cria objeto para classe de tratamento de XML
	$xmlObjeto = getObjectXML($xmlResult);

	// Se ocorrer um erro, mostra cr�tica
	if (strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO") {
		exibeErro($xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata);
	} 
	
	$motivos  = $xmlObjeto->roottag->tags[0]->tags;

	// Fun��o para exibir erros na tela atrav�s de javascript
	function exibeErro($msgErro) { 
		echo '<script type="text/javascript">';
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Ayllos","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
		echo '</script>';
		exit();
	}

	include('motivo_cancelamento.php');
?>