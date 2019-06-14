<?php
/*!
 * FONTE        : consulta_parametros.php
 * CRIAÇÃO      : Jonata (Mouts)
 * DATA CRIAÇÃO : Agosto/2018 
 * OBJETIVO     : Rotina para buscas os parametros para a tela TAB085
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

	$cdcopsel = (isset($_POST["cdcooper"])) ? $_POST["cdcooper"] : 0;
	
	validaDados();
	
	// Monta o xml de requisição		
	$xml  		= "";
	$xml 	   .= "<Root>";
	$xml 	   .= " <Dados>";
	$xml 	   .= "     <cddopcao>".$cddopcao."</cddopcao>";		
	$xml 	   .= "     <cdcopsel>".$cdcopsel."</cdcopsel>";		
	$xml 	   .= " </Dados>";
	$xml 	   .= "</Root>";
	
	// Executa script para envio do XML	
	$xmlResult = mensageria($xml, "TELA_TAB085", "CONSULTAR_PARAMETROS", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObjParametros = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjParametros->roottag->tags[0]->name) == "ERRO") {
		
		$msgErro = $xmlObjParametros->roottag->tags[0]->tags[0]->tags[4]->cdata;
		$nmdcampo = $xmlObjParametros->roottag->tags[0]->attributes["NMDCAMPO"];
		
		if(empty ($nmdcampo)){ 
			$nmdcampo = "cdcooper";
		}
		
		exibirErro('error',utf8_encode($msgErro),'Alerta - Ayllos','$(\'input,select\',\'#frmFiltro\').habilitaCampo();focaCampoErro(\''.$nmdcampo.'\',\'frmFiltro\');',false);		
					
	} 
		
	$parametros	= $xmlObjParametros->roottag->tags[0]->tags[0];	
	
	include("form_tab085.php");

	function validaDados(){
		
		
		if ( $GLOBALS["cdcopsel"] == 0 && $GLOBALS["cddopcao"] == 'C' ){ 
			exibirErro('error','Cooperativa n&atilde;o selecionada.','Alerta - Ayllos','$(\'#cdcooper\',\'#frmFiltro\').habilitaCampo().focus();',false);
		}
	
	}

 ?>
