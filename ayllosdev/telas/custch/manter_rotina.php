<?php
	/*!
	 * FONTE        : manter_rotina.php
	 * CRIAÇÃO      : Douglas Quisinski
	 * DATA CRIAÇÃO : 08/05/2015
	 * OBJETIVO     : Rotina para manter as operações da tela CUSTCH
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
	
	$nrdconta = !isset($_POST["nrdconta"]) ? 0  : $_POST["nrdconta"];
	$dscheque = !isset($_POST["dscheque"]) ? "" : $_POST["dscheque"];
		
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],"I")) <> '') {
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}
	
	// Verifica se os parâmetros necessários foram informados
	if (!validaInteiro($nrdconta)) exibirErro('error','Conta inv&aacute;lida.','Alerta - Ayllos','',false);
	if ($dscheque === "") exibirErro('error','Parametro inv&aacute;lido.','Alerta - Ayllos','',false);
		
	// Montar o xml de Requisicao
	$xml .= "<Root>";
	$xml .= " <Dados>";
	$xml .= "   <nrdconta>".$nrdconta."</nrdconta>";
	$xml .= "   <dscheque>".$dscheque."</dscheque>";
	$xml .= " </Dados>";
	$xml .= "</Root>";
	
	$xmlResult = mensageria($xml, "CUSTCH", "CUSTCH_CADASTRAR", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObj = getObjectXML($xmlResult);		
		
	//-----------------------------------------------------------------------------------------------
	// Controle de Erros
	//-----------------------------------------------------------------------------------------------
	
	if(strtoupper($xmlObj->roottag->tags[0]->name == 'VALIDAR_CMC7')){	
		foreach($xmlObj->roottag->tags[0]->tags as $erroCmc7){
			$cmc7    = $erroCmc7->tags[0]->cdata; // CMC-7 que ocorreu o erro
            $critica = $erroCmc7->tags[1]->cdata; // Crítica do erro
			$id = "#id_".$cmc7;
			echo "$('" . $id . "').css('background', '#FF8C69');";
			echo "$('#aux_dscritic','" . $id . "').text('" . $critica . "');";
		}
		$msgErro = 'Aconteceram erros durante a validação dos cheques para custodiar. <br> Verifique os cheques destacados.';
		exibirErro('error',$msgErro,'Alerta - Ayllos','',false);
		exit();
	} else {
		if(strtoupper($xmlObj->roottag->tags[0]->name == 'ERRO')){	
			$msgErro = $xmlObj->roottag->tags[0]->cdata;
			if($msgErro == null || $msgErro == ''){
				$msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
			}
			exibirErro('error',$msgErro,'Alerta - Ayllos','',false);
			exit();
		}else{
			echo "solicitaImpressaoCustodiaEmitida();";
		}
	}
?>
