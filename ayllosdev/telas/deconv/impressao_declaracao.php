<?

 /***********************************************************************
	
	  Fonte: impressao_declaracao.php                                               
	  Autor: Gabriel                                                  
	  Data : Junho/2011                       �ltima Altera��o: 		   
	                                                                   
	  Objetivo  : Gerar o PDF da Declaracao da DECONV.              
	                                                                 
	  Altera��es: 	  
	
	

	***********************************************************************/
	
	session_cache_limiter("private");
	session_start();
	
	// Includes para controle da session, vari�veis globais de controle, e biblioteca de fun��es	
	require_once("../../includes/config.php");
	require_once("../../includes/funcoes.php");	
	require_once("../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo m�todo POST
	isPostMethod();	
		
	// Classe para leitura do xml de retorno
	require_once("../../class/xmlfile.php");
	
	$nrdconta = $_POST["conta"];
	$idseqttl = $_POST["idseqttl"];
	$cdconven = $_POST["convenio"];
		
	$nmendter = session_id();
		
	
	$xml  = "";
	$xml .= "<Root>";
	$xml .= " <Cabecalho>";
	$xml .= "   <Bo>b1wgen0099.p</Bo>";
	$xml .= "   <Proc>gera-declaracao</Proc>";
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
	$xml .= "   <dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
	$xml .= " </Dados>";
	$xml .= "</Root>";
	
		
	// Executa script para envio do XML
	$xmlResult = getDataXML($xml);
	
	$xmlObjCarregaImpressao = getObjectXML($xmlResult);
	

	// Se ocorrer um erro, mostra cr�tica
 	if ($xmlObjCarregaImpressao->roottag->tags[0]->name == "ERRO") {
	    exibeErro($xmlObjCarregaImpressao->roottag->tags[0]->tags[0]->tags[4]->cdata);		 
    }
		
	// Obt�m nome do arquivo PDF copiado do Servidor PROGRESS para o Servidor Web
	$nmarqpdf = $xmlObjCarregaImpressao->roottag->tags[0]->attributes["NMARQPDF"];

	/// Chama fun��o para mostrar PDF do impresso gerado no browser	 
	visualizaPDF($nmarqpdf);
	
	
	// Fun��o para exibir erros na tela atrav�s de javascript
    function exibeErro($msgErro) { 
	  echo $msgErro;
	  exit();
    }
			
?>