<?php
	/*!
	 * FONTE        : consulta_data.php
	 * CRIA��O      : Jean Michel       
	 * DATA CRIA��O : 24/11/2014 
	 * OBJETIVO     : Rotina para consultar tipo da data das opcoes "C" e "R".
	 * --------------
	 * ALTERA��ES   : 
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
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}
	
	// Verifica se os par�metros necess�rios foram informados
	if (!isset($_POST["cddindex"])) {
		exibirErro('error','Par&acirc;metros incorretos.','Alerta - Ayllos',$funcaoAposErro,false);
	}else{
		$cddindex = !isset($_POST["cddindex"]) ? 0 : $_POST["cddindex"];
		if (!validaInteiro($cddindex)) exibirErro('error','Per&iacute;odo inv&aacute;lido.','Alerta - Ayllos',$funcaoAposErro,false);		
	}
		
	// Montar o xml de Requisicao
	$xml .= "<Root>";
	$xml .= " <Dados>";
	$xml .= "   <cddindex>".$cddindex."</cddindex>";
	$xml .= " </Dados>";
	$xml .= "</Root>";
	
	
	$xmlResult = mensageria($xml, "INDICE", "CONDATA", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObj = getObjectXML($xmlResult);
		
	//-----------------------------------------------------------------------------------------------
	// Controle de Erros
	//-----------------------------------------------------------------------------------------------
		
	if(strtoupper($xmlObj->roottag->tags[0]->name == 'ERRO')){	
		$msgErro = $xmlObj->roottag->tags[0]->cdata;
		if($msgErro == null || $msgErro == ''){
			$msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
		}
				
		exibirErro('error',$msgErro,'Alerta - Ayllos',$funcaoAposErro,false);		
		exit();
	}else{
		$tipodata = $xmlObj->roottag->tags[0]->tags[0]->cdata;		
		
		if($tipodata == null || $tipodata == ''){
			$tipodata = 1;
		}
		
		echo $tipodata;		
	}
?>