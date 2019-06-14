<?php 
	/*!
	 * FONTE        : carrega_combo.php
	 * CRIAÇÃO      : Jean Michel       
	 * DATA CRIAÇÃO : 24/06/2014 
	 * OBJETIVO     : Rotina para montar combo com indexadores
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
	
	$funcaoAposErro = "btnVoltar();";
		
	$cddopcao = !isset($_POST["cddopcao"]) ? 0 : $_POST["cddopcao"];
	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {		
		exibirErro('error',$msgError,'Alerta - Ayllos',$funcaoAposErro,false);
	}
	
	if($cddopcao == "R"){
		$cddopcao = "C";
	}
	
	// Montar o xml de Requisicao
	$xml .= "<Root>";
	$xml .= " <Dados>";
	$xml .= "   <cddindex>0</cddindex>";
	$xml .= " </Dados>";
	$xml .= "</Root>";	
	
	// Chama procedure consulta indexadores	
	$xmlResult = mensageria($xml, "INDICE", "CINDEX", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObj = getObjectXML($xmlResult);	
	
	// Verifica se houve erro
	if(strtoupper($xmlObj->roottag->tags[0]->name == 'ERRO')){	
		$msgErro = $xmlObj->roottag->tags[0]->cdata;
		$msgErro = $xmlObj->roottag->tags[0]->cdata;
		if($msgErro == null || $msgErro == ''){
			$msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
		}	
		exibirErro('error',$msgErro,'Alerta - Ayllos',$funcaoAposErro,false);
		exit();
	}else{	
		$registros = $xmlObj->roottag->tags;
		
		echo "$('#cddindex".$cddopcao."','#frmCab').empty();";
		echo "$('#cddindex".$cddopcao."','#frmCab').append('<option value=\"0\">-- Selecione --</option>');";
		
		foreach($registros as $registro) {
			echo "$('#cddindex".$cddopcao."','#frmCab').append('<option value=\"".str_replace(PHP_EOL, '', $registro->tags[0]->cdata)."\">".$registro->tags[1]->cdata."</option>');";
		}		
		
	}	
?>