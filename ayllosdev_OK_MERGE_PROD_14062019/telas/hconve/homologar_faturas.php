<?php
/*!
 * FONTE        : homologar_faturas.php
 * CRIAÇÃO      : Jonata (Mouts)
 * DATA CRIAÇÃO : Outubro/2018 
 * OBJETIVO     : Rotina para Homologacao de faturas
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
	
		exibirErro('error',$msgError,'Alerta - Aimaro','',false);
	}

	$cdconven = (isset($_POST["cdconven"])) ? $_POST["cdconven"] : '';
	$flgcvuni = (isset($_POST["flgcvuni"])) ? $_POST["flgcvuni"] : '';

	validaDados();
	
	// Monta o xml de requisição		
	$xml  		= "";
	$xml 	   .= "<Root>";
	$xml 	   .= " <Dados>";
	$xml 	   .= "     <cdconven>".$cdconven."</cdconven>";		
	$xml 	   .= " </Dados>";
	$xml 	   .= "</Root>";
	
	// Executa script para envio do XML	
	$xmlResult = mensageria($xml, "TELA_HCONVE", "HOMOL_FATURAS", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObjParametros = getObjectXML($xmlResult);

	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjParametros->roottag->tags[0]->name) == "ERRO") {
		
		$msgErro = $xmlObjParametros->roottag->tags[0]->tags[0]->tags[4]->cdata;
				
		exibirErro('error',utf8_encode($msgErro),'Alerta - Aimaro','formataFormOpcaoF();$(\'#btVoltar\',\'#divBotoesOpcaoF\').focus();',false);		
					
	}
	
    $flgcvuni = $xmlObjParametros->roottag->tags[0]->tags[0]->cdata;

	if ( $flgcvuni == null ) {

		exibirErro('inform','Sucesso! Convênio aguardando execução na central.','Alerta - Aimaro','formataFormOpcaoF();$(\'#btVoltar\',\'#divBotoesOpcaoF\').focus();',false);		
	
	} else if (($flgcvuni == 0) || ($flgcvuni == 1 && $glbvars["cdcooper"] == 3)) {

		$nmarquiv = $xmlObjParametros->roottag->tags[0]->tags[1]->cdata;
		echo 'Gera_Impressao("'.$nmarquiv.'","controlaVoltar(\'1\');");';	

	}

    function validaDados(){
		
		//Número da conta
        if (  $GLOBALS["cdconven"] == '' ){
            exibirErro('error','C&oacute;digo do convenio inv&aacute;lido.','Alerta - Aimaro','formataFormOpcaoF();$(\'input, select\',\'#frmOpcaoF\').removeClass(\'campoErro\');focaCampoErro(\'cdbarras\',\'frmOpcaoA\');',false);
        }
		
	}

 ?>
