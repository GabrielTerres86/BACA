<?php
/*!
 * FONTE        : alterar_parametros_fracoes_grupo.php
 * CRIAÇÃO      : Jonata (Mouts)
 * DATA CRIAÇÃO : Setembro/2018 
 * OBJETIVO     : Rotina para alterar os parametros da opção P
 * --------------
 * ALTERAÇÕES   : 
 */
?> 

<?php	
    session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();		
	
	// Carrega permissões do operador
	require_once('../../includes/carrega_permissoes.php');		
	
	$cddopcao = (isset($_POST["cddopcao"])) ? $_POST["cddopcao"] : '';
	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {		
	
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}

	$frmideal = (isset($_POST["frmideal"])) ? $_POST["frmideal"] : 0;
	$frmmaxim = (isset($_POST["frmmaxim"])) ? $_POST["frmmaxim"] : 0;
	
	
	// Monta o xml de requisição		
	$xml  		= "";
	$xml 	   .= "<Root>";
	$xml 	   .= " <Dados>";
	$xml 	   .= "     <frmaxima>".$frmmaxim."</frmaxima>";		
	$xml 	   .= "     <fraideal>".$frmideal."</fraideal>";	
	$xml 	   .= " </Dados>";
	$xml 	   .= "</Root>";
	
	// Executa script para envio do XML	
	$xmlResult = mensageria($xml, "TELA_CADGRP", "ALTERAR_PRM_FRACOES_GRP", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObjParametros = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjParametros->roottag->tags[0]->name) == "ERRO") {
		
		$msgErro = $xmlObjParametros->roottag->tags[0]->tags[0]->tags[4]->cdata;
		$nmdcampo = $xmlObjParametros->roottag->tags[0]->attributes["NMDCAMPO"];
		
		if(empty ($nmdcampo)){ 
			$nmdcampo = "frmideal";
		}
		
		exibirErro('error',utf8_encode($msgErro),'Alerta - Ayllos','controlaFormOpcaoP();focaCampoErro(\''.$nmdcampo.'\',\'frmOpcaoP\');',false);		
					
	}
	
	exibirErro('inform','Atualiza&ccedil;&atilde;o efetuada com sucesso.','Alerta - Ayllos','estadoInicial();', false);

	

 ?>
