<? 
/*!
 * FONTE        : imprime_grupo_economico.php
 * CRIAÇÃO      : Mauro (MOUTS)
 * DATA CRIAÇÃO : Agosto/2017
 * OBJETIVO     : Imprime o relatorio do Grupo Economico
 * --------------
 * ALTERAÇÕES   : 
 * --------------
 */	

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
	
	$idgrupo     = $_POST["idgrupo_rel"] == "" ? 0  : $_POST["idgrupo_rel"];
	$listarTodos = (($_POST["listarTodos"] == "on") ? 1 : 0);
	$nrdconta    = $_POST["nrdconta_rel"] == "" ? 0 : $_POST["nrdconta_rel"];
	
	$xml  = "<Root>";
	$xml .= " <Dados>";
	$xml .= "   <idgrupo>".$idgrupo."</idgrupo>";
	$xml .= "   <listar_todos>".$listarTodos."</listar_todos>";
	$xml .= "   <nrdconta>".$nrdconta."</nrdconta>";
	$xml .= " </Dados>";
	$xml .= "</Root>";

	// Executa script para envio do XML
	$xmlResult = mensageria($xml, "TELA_GRUPO_ECONOMICO", "GRUPO_ECONOMICO_IMPRIMIR", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	// Cria objeto para classe de tratamento de XML
	$xmlObjeto = getObjectXML($xmlResult);
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO") {
		?><script>alert('<?= $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata ?>');</script><?php
		exit();
	}
	
	// Chama função para mostrar PDF do impresso gerado no browser
	visualizaPDF(getByTagName($xmlObjeto->roottag->tags[0]->tags,'NMARQPDF'));
?>	