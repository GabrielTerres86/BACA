<?php
/*!
 * FONTE        : excluir_periodo_edital_assembleias.php
 * CRIAÇÃO      : Jonata (Mouts)
 * DATA CRIAÇÃO : Setembro/2018 
 * OBJETIVO     : Rotina para excluir periodo do edital de assembleias
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

	$nrano_exercicio = (isset($_POST["nrano_exercicio"])) ? $_POST["nrano_exercicio"] : '';
	$rowid          = (isset($_POST["rowid"])) ? $_POST["rowid"] : 0;
 
	
	// Monta o xml de requisição		
	$xml  		= "";
	$xml 	   .= "<Root>";
	$xml 	   .= " <Dados>";
	$xml 	   .= "     <nrano_exercicio>".$nrano_exercicio."</nrano_exercicio>";		
	$xml 	   .= "     <rowid>".$rowid."</rowid>";	
	$xml 	   .= " </Dados>";
	$xml 	   .= "</Root>";
	
	// Executa script para envio do XML	
	$xmlResult = mensageria($xml, "TELA_CADGRP", "EXCLUIR_PRD_EDT_ASS", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObjParametros = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjParametros->roottag->tags[0]->name) == "ERRO") {
		
		$msgErro = $xmlObjParametros->roottag->tags[0]->tags[0]->tags[4]->cdata;
				
		exibirErro('error',utf8_encode($msgErro),'Alerta - Ayllos','',false);		
					
	}
	
	exibirErro('inform','Exclus&atilde;o efetuada com sucesso.','Alerta - Ayllos','controlaVoltar(\'4\');', false);

	

 ?>
