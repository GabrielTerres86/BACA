<?php
	/*!
	* FONTE        : incluir_nacionalidades.php
	* CRIAÇÃO      : Kelvin Souza Ott	
	* DATA CRIAÇÃO : 16/05/2016
	* OBJETIVO     : Rotina para realizar a inclusão das nacionalidades
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

	$dsnacion = isset($_POST["dsnacion"]) ? $_POST["dsnacion"] : "";
	
	// Montar o xml de Requisicao
	$xml .= "<Root>";
	$xml .= " <Dados>";
	$xml .= "   <dsnacion>".$dsnacion."</dsnacion>";
	$xml .= " </Dados>";
	$xml .= "</Root>";
	
	$xmlResult = mensageria($xml, "CADA0001", "INCLUIR_NACIONALIDADE", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"],
	$glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	
	$xmlObj = getObjectXML($xmlResult);		
	
	//-----------------------------------------------------------------------------------------------
	// Controle de Erros
	//-----------------------------------------------------------------------------------------------
	if(strtoupper($xmlObj->roottag->tags[0]->name == 'ERRO')){	
		$msgErro = $xmlObj->roottag->tags[0]->cdata;
		$nmdcampo = $xmlObj->roottag->tags[0]->attributes["NMDCAMPO"];	
		
		
		if(empty ($nmdcampo)){ 
			$nmdcampo = "dsnacion";
		}
		
		if($msgErro == null || $msgErro == ''){
			$msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
		}
		
		exibirErro('error',$msgErro,'Alerta - Aimaro','$(\'input,select\',\'#divConteudo\').habilitaCampo(); focaCampoErro(\''.$nmdcampo.'\',\'divConteudo\');',false);
	}
	
	/*exibirErro('inform','Nacionalidade incluida com sucesso.','Alerta - Aimaro','estadoInicial();',false);	*/
	echo 'bloqueiaFundo($("#divUsoGenerico"));';
							
							
?>