<? 
	/*!
	 * FONTE        : valida_plano.php
	 * CRIAÇÃO      : Rogério Giacomini de Almeida
	 * DATA CRIAÇÃO : 27/09/2011
	 * OBJETIVO     : Exibir lista de motivos de cancelamento de seguros da tela ATENDA
	 */

	session_start();
	
	// Includes para controle da session, variáveis globais de controle, e biblioteca de funções	
	require_once("../../../includes/config.php");
	require_once("../../../includes/funcoes.php");		
	require_once("../../../includes/controla_secao.php");
	// Classe para leitura do xml de retorno
	require_once("../../../class/xmlfile.php");
	
	// Verifica se tela foi chamada pelo método POST
	isPostMethod();

	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"@")) <> "") {
		exibeErro($msgError);		
	}
	
	// Verifica se o número da conta foi informado
	if (!isset($_POST['nrdconta'])) exibirErro('error','Parâmetros incorretos.','Alerta - Aimaro','fechaRotina(divRotina)',false);	

	$nrdconta = $_POST['nrdconta'] == '' ? 0 : $_POST['nrdconta'];
	$cdsegura = $_POST['cdsegura'] == '' ? 0 : $_POST['cdsegura'];
	$tpseguro = $_POST['tpseguro'] == '' ? 0 : $_POST['tpseguro'];
	$tpplaseg = $_POST['tpplaseg'] == '' ? 0 : $_POST['tpplaseg'];
	
	// Monta o xml de requisição
	$xml  = "";
	$xml .= "<Root>";
	$xml .= "	<Cabecalho>";
	$xml .= "		<Bo>b1wgen0033.p</Bo>";
	$xml .= "		<Proc>buscar_plano_seguro</Proc>";
	$xml .= "	</Cabecalho>";
	$xml .= "	<Dados>";
	$xml .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xml .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xml .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xml .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xml .= "		<dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
	$xml .= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";	
	$xml .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xml .= "		<tpplaseg>".$tpplaseg."</tpplaseg>";
	$xml .= "		<cdsegura>".$cdsegura."</cdsegura>";
	$xml .= "		<tpseguro>11</tpseguro>";
	$xml .= "		<idorigem>".$glbvars['idorigem']."</idorigem>";
	$xml .= "		<idseqttl>1</idseqttl>";
	$xml .= "		<flgerlog>FALSE</flgerlog>";
	$xml .= "	</Dados>";
	$xml .= "</Root>";

	// Executa script para envio do XML
	$xmlResult = getDataXML($xml);
	
	// Cria objeto para classe de tratamento de XML
	$xmlObjeto = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO") {
		echo 'false|'.$xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;
	}
	else{
		$planos=$xmlObjeto->roottag->tags[0]->tags;
		foreach( $planos as $plano ) {			
			echo 'true|'.getByTagName($plano->tags,'vlplaseg').'|'.getByTagName($plano->tags,'flgunica')."|".getByTagName($plano->tags,'vlplaseg');
		}		
	}		
?>