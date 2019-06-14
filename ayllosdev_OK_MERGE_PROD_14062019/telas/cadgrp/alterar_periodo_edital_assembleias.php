<?php
/*!
 * FONTE        : alterar_periodo_edital_assembleias.php
 * CRIAÇÃO      : Jonata (Mouts)
 * DATA CRIAÇÃO : Setembro/2018 
 * OBJETIVO     : Rotina para alterar os periodos da opcacao E
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

	$rowid               = (isset($_POST["rowid"])) ? $_POST["rowid"] : '';
	$dtinicio_grupo      = (isset($_POST["dtinicio_grupo"])) ? $_POST["dtinicio_grupo"] : '';
	$dtfim_grupo         = (isset($_POST["dtfim_grupo"])) ? $_POST["dtfim_grupo"] : '';
	
	// Monta o xml de requisição		
	$xml  		= "";
	$xml 	   .= "<Root>";
	$xml 	   .= " <Dados>";
	$xml 	   .= "     <rowid>".$rowid."</rowid>";		
	$xml 	   .= "     <dtinicio_grupo>".$dtinicio_grupo."</dtinicio_grupo>";	
	$xml 	   .= "     <dtfim_grupo>".$dtfim_grupo."</dtfim_grupo>";	
	$xml 	   .= " </Dados>";
	$xml 	   .= "</Root>";
	
	// Executa script para envio do XML	
	$xmlResult = mensageria($xml, "TELA_CADGRP", "ALTERAR_PRD_EDT_ASS", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObjParametros = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjParametros->roottag->tags[0]->name) == "ERRO") {
		
		$msgErro = $xmlObjParametros->roottag->tags[0]->tags[0]->tags[4]->cdata;
		$nmdcampo = $xmlObjParametros->roottag->tags[0]->attributes["NMDCAMPO"];
		
		if(empty ($nmdcampo)){ 
			$nmdcampo = "dtinicio_assembleia";
		}
		
		exibirErro('error',utf8_encode($msgErro),'Alerta - Ayllos','formataFormOpcaoE(\'A\');focaCampoErro(\''.$nmdcampo.'\',\'frmOpcaoE\');',false);		
					
	}
	
	exibirErro('inform','Atualiza&ccedil;&atilde;o efetuada com sucesso.','Alerta - Ayllos','controlaVoltar(\'3\');', false);

 ?>
