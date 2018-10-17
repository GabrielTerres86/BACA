<?php  
	/*********************************************************************
	 Fonte: form_filtro.php                                                 
	 Autor: Jonata - Mouts
	 Data : Agosto/2018                 Última Alteração: 
	                                                                  
	 Objetivo  : Mostrar o de filtro para pesquisa da TAB085.                                  
	                                                                  
	 Alterações: 
	 
	 
	
	**********************************************************************/
	
?>

<?php
	
    session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();		
	
	$cddopcao = (isset($_POST["cddopcao"])) ? $_POST["cddopcao"] : '';
	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {		
	
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}

	$xml = "<Root>";
	$xml .= " <Dados>";
	$xml .= "   <cdcopsel>".($glbvars["cdcooper"] == 3 ? 0 : $glbvars["cdcooper"])."</cdcopsel>";
	$xml .= "   <flgativo>1</flgativo>";
	$xml .= " </Dados>";
	$xml .= "</Root>";

	$xmlResult = mensageria($xml, "TELA_TAB085", "LISTAR_COOPERATIVAS", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObject = getObjectXML($xmlResult);
	
	if (strtoupper($xmlObject->roottag->tags[0]->name) == "ERRO") {
		$msgErro = $xmlObject->roottag->tags[0]->tags[0]->tags[4]->cdata;
		if ($msgErro == "") {
			$msgErro = $xmlObject->roottag->tags[0]->cdata;
		}

		exibirErro('error',$msgErro,'Alerta - Ayllos','estadoInicial();',false);
	}

	$registros = $xmlObject->roottag->tags[0]->tags;

	include("form_filtro.php");
	
	?>
	




