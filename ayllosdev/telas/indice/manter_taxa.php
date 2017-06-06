<?php
	/*
	  FONTE        : manter_taxa.php
	  CRIAÇÃO      : Jean Michel       
	  DATA CRIAÇÃO : 25/06/2014 
	  OBJETIVO     : Rotina para cadastrar ou alterar taxas da tela INDICE
	  --------------
	  ALTERAÇÕES   : 29/05/2017 - Realizado ajuste para que ao alterar ou cadastrar tarifas
								  do tipo "TR" seja possível atribuir o valor 0(ZERO), conforme
								  solicitado no chamado 615474 (Kelvin)
	 
	  -------------- 
	*/		

    session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();			
	
	$funcaoAposErro = 'cVlrdtaxa.focus();'; //"btnVoltar();";
			
	// Verifica se os parâmetros necessários foram informados
	if (!isset($_POST["cddindex"])) {
		exibirErro('error','Par&acirc;metros incorretos.','Alerta - Ayllos',$funcaoAposErro,false);
	}else{
		$cddopcao = !isset($_POST["cddopcao"]) ? 0 : $_POST["cddopcao"];
		$cddindex = !isset($_POST["cddindex"]) ? 0 : $_POST["cddindex"];
		$dtperiod = !isset($_POST["dtperiod"]) ? 0 : $_POST["dtperiod"];	    
		$vlrdtaxa = !isset($_POST["vlrdtaxa"]) ? 0 : $_POST["vlrdtaxa"];	    
		
		if (strlen($dtperiod) == 4) {
			$dtperiod = '01/01/'.$dtperiod;
		}else if(strlen($dtperiod) == 7){
			$dtperiod = '01/'.$dtperiod;
		}
		$vlrdtaxa = str_replace(',','.',$vlrdtaxa);
		if (!validaInteiro($cddindex)) exibirErro('error','Per&iacute;odo inv&aacute;lido.','Alerta - Ayllos',$funcaoAposErro,false);
		
		//TR (Caso for TR deixar passar valor zerado SD 615474)
		if($cddindex == 2){
			if ($vlrdtaxa ==  null){ 
				$funcaoAposErro = 'cVlrdtaxa.focus()';
				exibirErro('error','Valor de taxa inv&aacute;lida.','Alerta - Ayllos',$funcaoAposErro,false);
			}
		}
		else{
			if ($vlrdtaxa == 0 || $vlrdtaxa ==  null){ 
				$funcaoAposErro = 'cVlrdtaxa.focus()';
				exibirErro('error','Valor de taxa inv&aacute;lida.','Alerta - Ayllos',$funcaoAposErro,false);
			}
		}
		
		
			
	}
	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {		
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}
	
	// Montar o xml de Requisicao
	$xml .= "<Root>";
	$xml .= " <Dados>";
	$xml .= "   <cddopcao>".$cddopcao."</cddopcao>";	
	$xml .= "   <cddindex>".$cddindex."</cddindex>";
	$xml .= "   <dtperiod>".$dtperiod."</dtperiod>";
	$xml .= "   <vlrdtaxa>".$vlrdtaxa."</vlrdtaxa>";
	$xml .= " </Dados>";
	$xml .= "</Root>";
	
	
	$xmlResult = mensageria($xml, "INDICE", "CADTAX", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
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
	//	echo("$('#cddopcao','#frmCab').val('C');");
		//echo("escolheOpcao();");			
		//echo("cCddopcao.val('C'); limpaTela();cCddopcao.habilitaCampo();cCddopcao.focus();");		
		echo("btnVoltar();");		
		exit();		
	}
	
?>