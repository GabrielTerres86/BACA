<?

 /***********************************************************************
	
	  Fonte: impressao_contratos.php                                               
	  Autor: Gabriel                                                  
	  Data : Novembro/2010                       Última Alteração: 		   
	                                                                   
	  Objetivo  : Gerar o PDF dos contratos selecionados da tela Improp.              
	                                                                 
	  Alterações: 	  
	
	

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
	
	$nomedarq = $_POST["nomedarq"];
	$dsiduser = session_id();
	
	$xmlImpressaoContratos  = "";
	$xmlImpressaoContratos .= "<Root>";
	$xmlImpressaoContratos .= " <Cabecalho>";
	$xmlImpressaoContratos .= "   <Bo>b1wgen0024.p</Bo>";
	$xmlImpressaoContratos .= "   <Proc>monta-contratos</Proc>";
	$xmlImpressaoContratos .= " </Cabecalho>";
	$xmlImpressaoContratos .= " <Dados>";
	$xmlImpressaoContratos .= "   <cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlImpressaoContratos .= "   <cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xmlImpressaoContratos .= "   <nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xmlImpressaoContratos .= "   <cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xmlImpressaoContratos .= "   <nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
	$xmlImpressaoContratos .= "   <idorigem>5</idorigem>";
	$xmlImpressaoContratos .= "   <dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
	$xmlImpressaoContratos .= "   <nomedarq>".$nomedarq."</nomedarq>"; 
	$xmlImpressaoContratos .= "   <dsiduser>".$dsiduser."</dsiduser>";
	$xmlImpressaoContratos .= " </Dados>";
	$xmlImpressaoContratos .= "</Root>";
	
	// Executa script para envio do XML
	
	$xmlResult = getDataXML($xmlImpressaoContratos);
	
	$xmlObjCarregaImpressao = getObjectXML($xmlResult);
	
	// Obtém nome do arquivo PDF copiado do Servidor PROGRESS para o Servidor Web
	$nmarqpdf = $xmlObjCarregaImpressao->roottag->tags[0]->attributes["NMARQPDF"];

	/// Chama função para mostrar PDF do impresso gerado no browser	 
	visualizaPDF($nmarqpdf);
			
	
?>