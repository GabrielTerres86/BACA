<?php
/*!
 * FONTE        : alterar_grupo_cooperado.php
 * CRIAÇÃO      : Jonata (Mouts)
 * DATA CRIAÇÃO : Setembro/2018 
 * OBJETIVO     : Rotina para alterar o grupo do cooperado
 * --------------
 * ALTERAÇÕES   : 05/07/2019 - Vincular cooperado a grupo - P484.2 (Gabriel Marcos - Mouts).
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

	$nrdgrupo = (isset($_POST["nrdgrupo"])) ? $_POST["nrdgrupo"] : 0;
	$flgvinculo = (isset($_POST["flgvinculo"])) ? $_POST["flgvinculo"] : 0;
	$rowid    = (isset($_POST["rowid"])) ? $_POST["rowid"] : 0;
	
	
	// Monta o xml de requisição		
	$xml  		= "";
	$xml 	   .= "<Root>";
	$xml 	   .= " <Dados>";
	$xml 	   .= "     <nrdgrupo>".$nrdgrupo."</nrdgrupo>";		
	$xml 	   .= "     <flgvinculo>".$flgvinculo."</flgvinculo>";	
	$xml 	   .= "     <rowid>".$rowid."</rowid>";	
	$xml 	   .= " </Dados>";
	$xml 	   .= "</Root>";

	// Executa script para envio do XML	
	$xmlResult = mensageria($xml, "TELA_CADGRP", "ALTERAR_GRUPO_COOP", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObjParametros = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjParametros->roottag->tags[0]->name) == "ERRO") {
		
		$msgErro = $xmlObjParametros->roottag->tags[0]->tags[0]->tags[4]->cdata;
				
		exibirErro('error',utf8_encode($msgErro),'Alerta - Ayllos','buscaGrupoCooperado();',false);		
					
	}
	
	exibirErro('inform','Atualiza&ccedil;&atilde;o efetuada com sucesso.','Alerta - Ayllos','buscaGrupoCooperado();', false);
 ?>
