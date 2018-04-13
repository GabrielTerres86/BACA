<?php

/***********************************************************************
  Fonte: imprimir_consulta_custas_csv.php                                              
  Autor: Hélinton Steffens                                                  
  Data : Abril/2018                       última Alteração: - 		   
	                                                                   
  Objetivo  : Gerar o CSV das custas e tarifas.              
	                                                                 
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
    $cdcooper 			= (isset($_POST['cdcooper'])) ? $_POST['cdcooper'] : 0;
    $nrdconta 			= $_POST["nrdconta"] !== "" ? $_POST["nrdconta"] : 0;
	$cduflogr 			= (isset($_POST['cduflogr'])) ? $_POST['cduflogr'] : null;
    $dscartor 			= (isset($_POST['dscartor'])) ? $_POST['dscartor'] : null;

	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {		
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}

	// Verifica se o número da conta é um inteiro válido
	if (!validaInteiro($nrdconta)) {
		?><script language="javascript">alert('Conta/dv inv&aacute;lida.');</script><?php
		exit();
	}

	$xml  = "";
	$xml .= "<Root>";
	$xml .= " <Dados>";
    $xml .= "   <cdcooper_usr>".$glbvars["cdcooper"]."</cdcooper_usr>";
	$xml .= "   <cdcooper>".(int) $cdcooper."</cdcooper>";
    $xml .= "   <nrdconta>".$nrdconta."</nrdconta>";	
    $xml .= "   <dtinicial>".$inidtpro."</dtinicial>";
	$xml .= "   <dtfinal>".$fimdtpro."</dtfinal>";
	$xml .= "   <cduflogr>".$cduflogr."</cduflogr>";
	$xml .= "   <cartorio>".$dscartor."</cartorio>";
	$xml .= " </Dados>";
	$xml .= "</Root>";

	$xmlResult = mensageria($xml, "TELA_MANPRT", "EXPORTA_CONSULTA_CUSTAS", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObjeto = getObjectXML($xmlResult);

	// Se ocorrer um erro, mostra critica
	if ($xmlObjeto->roottag->tags[0]->name == "ERRO") {
		exibeErro($xmlObjeto->roottag->tags[0]->cdata);		 
	}

	$nmarqcsv = $xmlObjeto->roottag->cdata;
	visualizaCSV($nmarqcsv);

	// Função para exibir erros na tela através de javascript
	function exibeErro($msgErro) { 
	    echo '<script>alert("'.$msgErro.'");</script>';	
	    exit();
	}
 
?>