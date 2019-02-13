<?php	
	/*!
	 * FONTE        : homologar_autorizacao_debito.php
	 * CRIAÇÃO      : Jonata (Mouts)
	 * DATA CRIAÇÃO : Outubro/2018 
	 * OBJETIVO     : Rotina para Homologacao de aut. de debito 
	 * --------------
	 * ALTERAÇÕES   : 
	 */
	 
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
	
		exibirErro('error',$msgError,'Alerta - Aimaro','',false);
	}
    
	$cdconven = (isset($_POST["cdconven"])) ? $_POST["cdconven"] : 0;
	
	validaDados();
	
	// Monta o xml de requisição		
	$xml  		= "";
	$xml 	   .= "<Root>";
	$xml 	   .= " <Dados>";
    $xml 	   .= "     <cdconven>".$cdconven."</cdconven>";		
	$xml 	   .= " </Dados>";
	$xml 	   .= "</Root>";
	
	// Executa script para envio do XML	
	$xmlResult = mensageria($xml, "TELA_HCONVE", "HOMOL_AUTO_DEB_CONV", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObjParametros = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjParametros->roottag->tags[0]->name) == "ERRO") {
		
		$msgErro = $xmlObjParametros->roottag->tags[0]->tags[0]->tags[4]->cdata;
				
		exibirErro('error',utf8_encode($msgErro),'Alerta - Aimaro','formataFormOpcaoA();$(\'#btVoltar\',\'#divBotoes\').focus();',false);		
					
	}

	$flgcvuni = $xmlObjParametros->roottag->tags[0]->tags[0]->cdata;

	if ( $flgcvuni == null ) {

		exibirErro('inform','Sucesso! Convênio aguardando execução na central.','Alerta - Aimaro','formataFormOpcaoA();$(\'#btVoltar\',\'#divBotoesOpcaoA\').focus();',false);		
	
	} else if (($flgcvuni == 0) || ($flgcvuni == 1 and $glbvars["cdcooper"] == 3)) {
		
		$nmarquiv = $xmlObjParametros->roottag->tags[0]->tags[1]->cdata;
		echo 'Gera_Impressao("'.$nmarquiv.'","controlaVoltar(\'1\');");';	
		
	} 
	
    function validaDados(){

		//Código do convênio
        if (  $GLOBALS["cdconven"] == 0 ){
            exibirErro('error','C&oacute;digo do conv&ecirc;nio inv&aacute;lido.','Alerta - Aimaro','formataFormOpcaoA();$(\'input, select\',\'#frmOpcaoA\').removeClass(\'campoErro\');focaCampoErro(\'cdconven\',\'frmOpcaoA\');',false);
        }
		
	}

 ?>
