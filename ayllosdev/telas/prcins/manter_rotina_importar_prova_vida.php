<?php
	/*!
	 * FONTE        : manter_rotina_importar_prova_vida.php
	 * CRIAÇÃO      : Douglas Quisinski
	 * DATA CRIAÇÃO : 22/03/2017
	 * OBJETIVO     : Rotina para processar a planilha de prova de vida dos beneficiarios do INSS
	 * --------------
	 * ALTERAÇÕES   :  
	 * -------------- 
	 */		

    session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();			
	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],"I")) <> '') {
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}
	
	// Montar o xml de Requisicao
	$xml .= "<Root>";
	$xml .= " <Dados>";
	$xml .= "   <nmdatela>".$glbvars['nmdatela']."</nmdatela>";
	$xml .= " </Dados>";
	$xml .= "</Root>";
	
	$xmlResult = mensageria($xml, "TELA_PRCINS", "IMPORTAR_PROVA_VIDA", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObj = getObjectXML($xmlResult);		
		
	//-----------------------------------------------------------------------------------------------
	// Controle de Erros
	//-----------------------------------------------------------------------------------------------
	if(strtoupper($xmlObj->roottag->tags[0]->name == 'ERRO')){	
	
		$msgErro = $xmlObj->roottag->tags[0]->cdata;
		$nmdcampo = $xmlObj->roottag->tags[0]->attributes["NMDCAMPO"];	
		
		if($msgErro == null || $msgErro == ''){
			$msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
		}
		exibirErro('error',$msgErro,'Alerta - Ayllos','$(\'input\',\'#frmProcessar\').habilitaCampo(); focaCampoErro(\''.$nmdcampo.'\',\'frmProcessar\');',false);		
		
	} 
	
	exibirErro('inform','Planilha processada com sucesso.','Alerta - Ayllos','',false);
?>