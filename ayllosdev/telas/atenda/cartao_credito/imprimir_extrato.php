<?php 

	/************************************************************************  
	  Fonte: imprimir_extrato.php                                             
	  Autor: Guilherme/Supero
	  Data : Agosto/2011                   Última Alteração: 00/00/0000

	  Objetivo  : Carregar dados para impressões do extrato do
             	  cartão de crédito Cecred Visa

	  Alterações: 

	************************************************************************/ 

	session_cache_limiter("private");
	session_start();
	
	// Includes para controle da session, variáveis globais de controle, e biblioteca de funções	
	require_once("../../../includes/config.php");
	require_once("../../../includes/funcoes.php");		
	require_once("../../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo método POST
	isPostMethod();	
		
	// Classe para leitura do xml de retorno
	require_once("../../../class/xmlfile.php");
	
	// Verifica permissão
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"M")) <> "") {
		?><script language="javascript">alert('<?php echo $msgError; ?>');</script><?php
		exit();
	}	

	// Verifica se o número da conta foi informado
	if (!isset($_POST["nrdconta"]) || 		
		!isset($_POST["nrcrcard"]) || 
		!isset($_POST["idimpres"]) || 
		!isset($_POST["dtvctini"]) || 
		!isset($_POST["dtvctfim"])) {
		?><script language="javascript">alert('Par&acirc;metros incorretos.');</script><?php
		exit();
	}	

	$nrdconta = $_POST["nrdconta"];	
	$nrcrcard = $_POST["nrcrcard"];
	$idimpres = $_POST["idimpres"];
	$dtvctini = $_POST["dtvctini"];
	$dtvctfim = $_POST["dtvctfim"];

	// Monta o xml de requisição
	$xmlDadosImpres  = "";
	$xmlDadosImpres .= "<Root>";
	$xmlDadosImpres .= "	<Cabecalho>";
	$xmlDadosImpres .= "		<Bo>b1wgen0028.p</Bo>";
	$xmlDadosImpres .= "		<Proc>extrato_bradesco_impressao</Proc>";
	$xmlDadosImpres .= "	</Cabecalho>";
	$xmlDadosImpres .= "	<Dados>";
	$xmlDadosImpres .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlDadosImpres .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xmlDadosImpres .= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
	$xmlDadosImpres .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";	
	$xmlDadosImpres .= "		<nmendter>".session_id().getmypid()."</nmendter>";

	$xmlDadosImpres .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xmlDadosImpres .= "		<nrcrcard>".$nrcrcard."</nrcrcard>";
	$xmlDadosImpres .= "		<dtvctini>".$dtvctini."</dtvctini>";
	$xmlDadosImpres .= "		<dtvctfim>".$dtvctfim."</dtvctfim>";

	$xmlDadosImpres .= "		<dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";	
	$xmlDadosImpres .= "		<idimpres>".$idimpres."</idimpres>";
	$xmlDadosImpres .= "	</Dados>";
	$xmlDadosImpres .= "</Root>";

	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlDadosImpres);

	// Cria objeto para classe de tratamento de XML
	$xmlObjDadosImpres = getObjectXML($xmlResult);

	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjDadosImpres->roottag->tags[0]->name) == "ERRO") {
		$msg = $xmlObjDadosImpres->roottag->tags[0]->tags[0]->tags[4]->cdata;
		?>
		<script language="javascript">
			alert('<?php echo $msg; ?>'); 
			window.close();
		</script>
		<?php
		exit();
	}
	
	// Obtém nome do arquivo PDF copiado do Servidor PROGRESS para o Servidor Web
	$nmarqpdf = $xmlObjDadosImpres->roottag->tags[0]->attributes["NMARQPDF"];
	
	// Chama função para mostrar PDF do impresso gerado no browser
	visualizaPDF($nmarqpdf);

?>