<?php

/***********************************************************************
  Fonte: imprimir_consulta_ted_csv.php                                              
  Autor: H�linton Steffens                                                  
  Data : Mar�o/2018                       �ltima Altera��o: - 		   
	                                                                   
  Objetivo  : Gerar o CSV dos titulos.              
	                                                                 
  Altera��es: 
  
***********************************************************************/
	session_cache_limiter("private");
	session_start();
		
	// Includes para controle da session, vari�veis globais de controle, e biblioteca de fun��es	
	require_once("../../includes/config.php");
	require_once("../../includes/funcoes.php");		
	require_once("../../includes/controla_secao.php");
	require_once('../../class/xmlfile.php');

	// Verifica se tela foi chamada pelo m�todo POST
	isPostMethod();

	// Verifica Permiss�es
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"@")) <> "") {
		?><script language="javascript">alert('<?php echo $msgError; ?>');</script><?php
		exit();	
	}	

	// Recebe o POST
	$inidtpro 			= $_POST['inidtpro'] ;
	$fimdtpro 			= $_POST['fimdtpro'];
	$inivlpro 			= (isset($_POST['inivlpro'])) ? $_POST['inivlpro'] : 0 ;
	$fimvlpro 			= (isset($_POST['fimvlpro'])) ? $_POST['fimvlpro'] : 0 ;
	$dscartor 			= (isset($_POST['dscartor'])) ? $_POST['dscartor'] : null ;
	$indconci 			= (isset($_POST['indconci'])) ? $_POST['indconci'] : '' ;
	$nriniseq 			= (isset($_POST['nriniseq'])) ? $_POST['nriniseq'] : 1  ;
	$nrregist 			= (isset($_POST['nrregist'])) ? $_POST['nrregist'] : 50  ;

	$xml  = "";
	$xml .= "<Root>";
	$xml .= " <Dados>";
	$xml .= "   <cdcooper>".$glbvars["cdcooper"]."</cdcooper>";	
    $xml .= "   <dtinicial>".$inidtpro."</dtinicial>";
	$xml .= "   <dtfinal>".$fimdtpro."</dtfinal>";
	$xml .= "   <vlinicial>".$inivlpro."</vlinicial>";
	$xml .= "   <vlfinal>".$fimvlpro."</vlfinal>";
	$xml .= "   <cartorio>".$dscartor."</cartorio>";
	$xml .= "   <nrregist>".$nrregist."</nrregist>";
	$xml .= "   <nriniseq>".$nriniseq."</nriniseq>";
	$xml .= "   <flgcon>1</flgcon>";
	$xml .= " </Dados>";
	$xml .= "</Root>";

	$xmlResult = mensageria($xml, "TELA_MANPRT", "EXPORTA_CONCILIACAO", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObjeto = getObjectXML($xmlResult);

	// Se ocorrer um erro, mostra critica
	if ($xmlObjeto->roottag->tags[0]->name == "ERRO") {
		exibeErro($xmlObjeto->roottag->tags[0]->cdata);		 
	}

	$nmarqcsv = $xmlObjeto->roottag->cdata;
	visualizaCSV($nmarqcsv);

	// Fun��o para exibir erros na tela atrav�s de javascript
	function exibeErro($msgErro) { 
	    echo '<script>alert("'.$msgErro.'");</script>';	
	    exit();
	}
 
?>