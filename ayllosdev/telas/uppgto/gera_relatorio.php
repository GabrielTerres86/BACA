<?php
/*!
 * FONTE        : gera_relatorio.php                    Última alteração: 27/11/2017
 * CRIAÇÃO      : Tiago 
 * DATA CRIAÇÃO : Setembro/2017
 * OBJETIVO     : Rotina para gerar relatorio
 * --------------
 * ALTERAÇÕES   :  27/11/2017- Ajustar a validação de acesso a tela para opção "R" - RELATORIO (Douglas - Melhoria 271.3)
 */
?>
<?php
session_cache_limiter("private");
session_start();

	// Includes para controle da session, variáveis globais de controle, e biblioteca de funções	
	require_once("../../includes/config.php");
	require_once("../../includes/funcoes.php");
//	require_once("../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo método POST
	isPostMethod();

	// Classe para leitura do xml de retorno
	require_once("../../class/xmlfile.php");
	
	
	if (($msgError = validaPermissao($glbvars["nmdatela"], $glbvars["nmrotina"], "R")) <> "") {
		?><script language="javascript">alert('<?php echo $msgError; ?>');</script><?php
		exit();
	}

	$nrdconta = isset($_POST["nrdconta"]) ? $_POST["nrdconta"] : 0;
	$nrremess = isset($_POST["nrremess"]) ? $_POST["nrremess"] : 0;
	$nmarquiv = isset($_POST["nmarquiv"]) ? $_POST["nmarquiv"] : "";
	$nmbenefi = isset($_POST["nmbenefi"]) ? $_POST["nmbenefi"] : "";
	$dscodbar = isset($_POST["dscodbar"]) ? $_POST["dscodbar"] : "";
	$idstatus = isset($_POST["cdsittit"]) ? $_POST["cdsittit"] : 1;
	$tpdata   = isset($_POST["dtrefere"]) ? $_POST["dtrefere"] : 1;
	$dtiniper = isset($_POST["dtiniper"]) ? $_POST["dtiniper"] : "";
	$dtfimper = isset($_POST["dtfimper"]) ? $_POST["dtfimper"] : "";
	$tprelato = isset($_POST["tprelato"]) ? $_POST["tprelato"] : 1;	
		
	// Montar o xml de Requisicao
	$xml .= "<Root>";
	$xml .= " <Dados>";
	$xml .= "   <nrdconta>".$nrdconta."</nrdconta>";
	$xml .= "   <nrremess>".$nrremess."</nrremess>";	
	$xml .= "   <nmarquiv>".$nmarquiv."</nmarquiv>";
	$xml .= "   <nmbenefi>".$nmbenefi."</nmbenefi>";
	$xml .= "   <dscodbar>".$dscodbar."</dscodbar>";
	$xml .= "   <idstatus>".$idstatus."</idstatus>";
	$xml .= "   <tpdata>".$tpdata."</tpdata>";
	$xml .= "   <dtiniper>".$dtiniper."</dtiniper>";
	$xml .= "   <dtfimper>".$dtfimper."</dtfimper>";
	$xml .= "   <tprelato>".$tprelato."</tprelato>";
	$xml .= " </Dados>";
	$xml .= "</Root>";
		
	$xmlResult = mensageria($xml, "PGTA0001", "GERARELATARQPGTO", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObj = getObjectXML($xmlResult);		
	
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObj->roottag->tags[0]->name) == "ERRO") {
	
		$msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
		?><script language="javascript">alert('<?php echo $msgErro; ?>');</script><?php
		
		exit();		
	} 
		
		
	$nmrelato = $xmlObj->roottag->tags[0]->tags[0]->tags[0]->cdata;		  	
	
	// Chama função para mostrar PDF do impresso gerado no browser
	if($tprelato == 1){
		visualizaPDF($nmrelato);		
	}else{
		visualizaCSV($nmrelato);
	}
 ?>
 
 
 
 
