<?php

/***********************************************************************
  Fonte: imprimir_consulta_custas_pdf.php                                              
  Autor: Hélinton Steffens                                                  
  Data : Março/2018                       última Alteração: - 		   
	                                                                   
  Objetivo  : Gerar o PDF com as custas.              
	                                                                 
  Alterações: 
  
***********************************************************************/
	session_cache_limiter("private");
	session_start();
		
	// Includes para controle da session, variáveis globais de controle, e biblioteca de funções	
	require_once("../../includes/config.php");
	require_once("../../includes/funcoes.php");		
	require_once("../../includes/controla_secao.php");
	require_once('../../class/xmlfile.php');

	// Verifica se tela foi chamada pelo método POST
	isPostMethod();

	// Verifica Permissões
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"@")) <> "") {
		?><script language="javascript">alert('<?php echo $msgError; ?>');</script><?php
		exit();	
	}	

	// Recebe o POST
	$inidtpro 			= $_POST['inidtpro'] ;
	$fimdtpro 			= $_POST['fimdtpro'];
    $cdcooper 			= (!empty($_POST['cdcooper'])) ? $_POST['cdcooper'] : 3;
    $nrdconta 			= (!empty($_POST["nrdconta"])) ? $_POST["nrdconta"] : null;
	$cduflogr 			= (isset($_POST['cduflogr']))  ? $_POST['cduflogr'] : null;
    $dscartor 			= (isset($_POST['dscartor']))  ? $_POST['dscartor'] : null;
    $flcustas 			= (!empty($_POST['flcustas'])) ? $_POST['flcustas'] : null;

	$xml  = "";
	$xml .= "<Root>";
	$xml .= " <Dados>";
	$xml .= "   <cdcooper_usr>".$glbvars["cdcooper"]."</cdcooper_usr>";
	$xml .= "   <cdcooper>".$cdcooper."</cdcooper>";
    $xml .= "   <nrdconta>".$nrdconta."</nrdconta>";	
    $xml .= "   <dtinicial>".$inidtpro."</dtinicial>";
	$xml .= "   <dtfinal>".$fimdtpro."</dtfinal>";
	$xml .= "   <cduflogr>".$cduflogr."</cduflogr>";
	$xml .= "   <cartorio>".$dscartor."</cartorio>";
	$xml .= "   <flcustas>".$flcustas."</flcustas>";
	$xml .= " </Dados>";
	$xml .= "</Root>";

	$xmlResult = mensageria($xml, "TELA_MANPRT", "EXPORTA_CONSULTA_CUSTAS_PDF", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObjeto = getObjectXML($xmlResult);

	// Se ocorrer um erro, mostra critica
	if ($xmlObjeto->roottag->tags[0]->name == "ERRO") {
		exibeErro($xmlObjeto->roottag->tags[0]->cdata);		 
	}

	$nmarqcsv = $xmlObjeto->roottag->cdata;
	visualizaPDF($nmarqcsv);

	// Função para exibir erros na tela através de javascript
	function exibeErro($msgErro) { 
	    echo '<script>alert("'.$msgErro.'");</script>';	
	    exit();
	}
 
?>