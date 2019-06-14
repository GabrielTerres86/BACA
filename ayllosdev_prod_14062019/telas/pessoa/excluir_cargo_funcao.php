<?php
/*!
 * FONTE        : excluir_cargo_funcao.php
 * CRIAÇÃO      : Jonata (Mouts)
 * DATA CRIAÇÃO : Setembro/2018 
 * OBJETIVO     : Rotina para excluir cargo/funcao
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

	$nrcpfcgc = (isset($_POST["nrcpfcgc"])) ? $_POST["nrcpfcgc"] : 0;
	$cdfuncao = (isset($_POST["cdfuncao"])) ? $_POST["cdfuncao"] : 0;
	$nrdrowid = (isset($_POST["nrdrowid"])) ? $_POST["nrdrowid"] : 0;
	
	
	// Monta o xml de requisição		
	$xml  		= "";
	$xml 	   .= "<Root>";
	$xml 	   .= " <Dados>";
	$xml 	   .= "     <nrcpfcgc>".$nrcpfcgc."</nrcpfcgc>";		
	$xml 	   .= "     <cdfuncao>".$cdfuncao."</cdfuncao>";		
	$xml 	   .= "     <nrdrowid>".$nrdrowid."</nrdrowid>";	
	$xml 	   .= " </Dados>";
	$xml 	   .= "</Root>";
	
	// Executa script para envio do XML	
	$xmlResult = mensageria($xml, "TELA_PESSOA", "EXCLUIR_CARGO_FUN", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObjParametros = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjParametros->roottag->tags[0]->name) == "ERRO") {
		
		$msgErro = $xmlObjParametros->roottag->tags[0]->tags[0]->tags[4]->cdata;
				
		exibirErro('error',utf8_encode($msgErro),'Alerta - Ayllos','$(\'#btExcluir\',\'#divBotoesTabelaCadastro\').focus();',false);		
					
	}
	
	exibirErro('inform','Exclus&atilde;o efetuada com sucesso.','Alerta - Ayllos','buscarCooperado(\'1\',\'30\');',false);		

	

 ?>
