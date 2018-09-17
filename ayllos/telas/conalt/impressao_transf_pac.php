<?

 /***********************************************************************
	
	  Fonte: impressao_transf_pac.php                                               
	  Autor: Guilherme
	  Data : Julho/2011                       Última Alteração: 04/07/2012 		   

	  Objetivo  : Gerar o PDF da transferencias de PAC

	  Alterações: 04/07/2012 - Ajuste em alerta de erro. (Jorge)
	              14/08/2013 - Alteração da sigla PAC para PA (Carlos).
	  
	***********************************************************************/
	
	session_cache_limiter("private");
	session_start();
	
	// Includes para controle da session, variáveis globais de controle, e biblioteca de funções	
	require_once("../../includes/config.php");
	require_once("../../includes/funcoes.php");	
	require_once("../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo método POST
	isPostMethod();	
		
	// Classe para leitura do xml de retorno
	require_once("../../class/xmlfile.php");
	
	// opcao c
	$nrdconta = (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : 0; 

	
	if (!isset($_POST['nrpacori']) ||
	    !isset($_POST['nrpacdes']) ||
		!isset($_POST['dtperini']) ||
		!isset($_POST['dtperfim'])){
		die('Par&aacute;metros incorretos');
	}
	
	// opcao t
	$nrpacori = $_POST['nrpacori'];
	$nrpacdes = $_POST['nrpacdes'];
	$dtperini = $_POST['dtperini'];
	$dtperfim = $_POST['dtperfim'];
	
	if (!validaInteiro($nrpacori)) {
		exibeErro("PA origem inv&aacute;lido.");
		exit();
	}
	
	if (!validaInteiro($nrpacdes)) {
		exibeErro("PA destino inv&aacute;lido.");
		exit();
	}

	if (!validaData($dtperini)) {
		exibeErro("Per&iacute;odo inicial inv&aacute;lido.");
		exit();
	}	
	
	if (!validaData($dtperini)) {
		exibeErro("Per&iacute;odo final inv&aacute;lido.");
		exit();
	}

	$nmendter = session_id();
	
	$xml  = "";
	$xml .= "<Root>";
	$xml .= " <Cabecalho>";
	$xml .= "   <Bo>b1wgen0018.p</Bo>";
	$xml .= "   <Proc>gera-impressao-transf-pac</Proc>";
	$xml .= " </Cabecalho>";
	$xml .= " <Dados>";
	$xml .= "   <cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xml .= "   <cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xml .= "   <nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xml .= "   <cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xml .= "   <nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
	$xml .= "   <idorigem>".$glbvars["idorigem"]."</idorigem>";
	$xml .= "   <nrdconta>".$nrdconta."</nrdconta>";
	$xml .= "   <idseqttl>".$idseqttl."</idseqttl>";
	$xml .= "   <cdconven>".$cdconven."</cdconven>";
	$xml .= "   <nmendter>".$nmendter."</nmendter>";
	$xml .= "	<nrpacori>".$nrpacori."</nrpacori>";
	$xml .= "	<nrpacdes>".$nrpacdes."</nrpacdes>";
	$xml .= "	<dtperini>".$dtperini."</dtperini>";
	$xml .= "	<dtperfim>".$dtperfim."</dtperfim>";	
	$xml .= "   <dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
	$xml .= " </Dados>";
	$xml .= "</Root>";
	
		
	// Executa script para envio do XML
	$xmlResult = getDataXML($xml);
	
	$xmlObjCarregaImpressao = getObjectXML($xmlResult);
	

	// Se ocorrer um erro, mostra crítica
 	if ($xmlObjCarregaImpressao->roottag->tags[0]->name == "ERRO") {
	    exibeErro($xmlObjCarregaImpressao->roottag->tags[0]->tags[0]->tags[4]->cdata);		 
    }
		
	// Obtém nome do arquivo PDF copiado do Servidor PROGRESS para o Servidor Web
	$nmarqpdf = $xmlObjCarregaImpressao->roottag->tags[0]->attributes["NMARQPDF"];

	/// Chama função para mostrar PDF do impresso gerado no browser	 
	visualizaPDF($nmarqpdf);
	
	
	// Função para exibir erros na tela através de javascript
    function exibeErro($msgErro) { 
	  $msg = $msgErro;
	  echo "<script language='javascript'>alert(\"".$msg."\");</script>";
	  exit();
    }

?>