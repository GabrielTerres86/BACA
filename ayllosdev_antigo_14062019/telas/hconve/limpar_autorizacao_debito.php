<?php	
	/*!
	 * FONTE        : limpar_autorizacao_debito.php
	 * CRIAÇÃO      : Gabriel Marcos (Mouts)
	 * DATA CRIAÇÃO : Novembro/2018 
	 * OBJETIVO     : Rotina para realizacao de limpeza dos convenios para as cooperativas
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
	$xmlResult = mensageria($xml, "TELA_HCONVE", "LIMPAR_AUTO_DEB_CONV", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObjParametros = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjParametros->roottag->tags[0]->name) == "ERRO") {
		
		$msgErro = $xmlObjParametros->roottag->tags[0]->tags[0]->tags[4]->cdata;
				
		exibirErro('error',utf8_encode($msgErro),'Alerta - Aimaro','formataFormOpcaoA();$(\'#btVoltar\',\'#divBotoes\').focus();',false);		
					
	}else{
		
		exibirErro('inform','Limpeza conclu&iacute;da com sucesso.','Alerta - Aimaro','controlaVoltar(\'2\');', false);	
		
	}
	
    function validaDados(){
		//Código do convênio
        if (  $GLOBALS["cdconven"] == 0 ){
            exibirErro('error','C&oacute;digo do conv&ecirc;nio inv&aacute;lido.','Alerta - Aimaro','formataFormOpcaoA();$(\'input, select\',\'#frmOpcaoA\').removeClass(\'campoErro\');focaCampoErro(\'cdconven\',\'frmOpcaoA\');',false);
        }
	}

 ?>
