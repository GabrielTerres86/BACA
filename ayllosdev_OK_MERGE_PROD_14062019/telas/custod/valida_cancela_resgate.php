<?php
	/*!
	 * FONTE        : valida_cancela_resgate.php
	 * CRIAÇÃO      : Lucas Reinert
	 * DATA CRIAÇÃO : 05/09/2016
	 * OBJETIVO     : Rotina para validar os cheques informados para cancelamento de resgate
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
	$inresgte = !isset($_POST["inresgte"]) ? 0 : $_POST["inresgte"];
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],"X")) <> '') {
		exibirErro('error',$msgError,'Alerta - Aimaro','',false);
	}
	
	// Verifica se os parâmetros necessários foram informados
	if (!validaInteiro($nrdconta)) exibirErro('error','Conta inv&aacute;lida.','Alerta - Aimaro','',false);
	if ($dscheque === "") exibirErro('error','Parametro inv&aacute;lido.','Alerta - Aimaro','',false);
		
	// Montar o xml de Requisicao
	$xml  = "<Root>";
	$xml .= " <Dados>";
	$xml .= "   <nrdconta>".$nrdconta."</nrdconta>";
	$xml .= "   <dscheque>".$dscheque."</dscheque>";
	$xml .= " </Dados>";
	$xml .= "</Root>";
	
	$xmlResult = mensageria($xml, "TELA_CUSTOD", "CUSTOD_VALIDA_CANC_RESGATE", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObj = getObjectXML($xmlResult);		
		
	//-----------------------------------------------------------------------------------------------
	// Controle de Erros
	//-----------------------------------------------------------------------------------------------
	
	if(isset($xmlObj->roottag->tags[0]->name) && strtoupper($xmlObj->roottag->tags[0]->name == 'INFO_CHEQUES')){	
		foreach($xmlObj->roottag->tags[0]->tags as $infoCheques){
			$cmc7    = $infoCheques->tags[0]->cdata; // CMC-7 que ocorreu o erro
            $vlcheque = $infoCheques->tags[1]->cdata; // Valor do cheque
            $dtlibera = $infoCheques->tags[2]->cdata; // Data boa
			$id = "#id_".$cmc7;
			echo "$('#aux_vlcheque','" . $id . "').text('" . $vlcheque . "');";
			echo "$('#aux_dtlibera','" . $id . "').text('" . $dtlibera . "'); ";
		}
	}
	if(isset($xmlObj->roottag->tags[1]->name) && strtoupper($xmlObj->roottag->tags[1]->name == 'VALIDAR_CMC7')){	
		foreach($xmlObj->roottag->tags[1]->tags as $erroCmc7){
			$cmc7    = $erroCmc7->tags[0]->cdata; // CMC-7 que ocorreu o erro
            $critica = $erroCmc7->tags[1]->cdata; // Crítica do erro
			$id = "#id_".$cmc7;
			echo "$('" . $id . "').css('background', '#FF8C69');";
			echo "$('#aux_dscritic','" . $id . "').text('" . $critica . "');";
		}
		$msgErro = 'Não é possível efetuar o cancelamento do resgate pois existem cheques com críticas. <br> Remova-os e tente novamente.';
		exibirErro('error',$msgErro,'Alerta - Aimaro','',false);
		exit();
	} else {
		if(isset($xmlObj->roottag->tags[0]->name) && strtoupper($xmlObj->roottag->tags[0]->name == 'ERRO')){	
			$msgErro = $xmlObj->roottag->tags[0]->cdata;
			if($msgErro == null || $msgErro == ''){
				$msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
			}
			exibirErro('error',$msgErro,'Alerta - Aimaro','',false);
			exit();
		}
	}

	if ($inresgte == 1){
		// Montar o xml de Requisicao
		$xml  = "<Root>";
		$xml .= " <Dados>";
		$xml .= "   <nrdconta>".$nrdconta."</nrdconta>";
		$xml .= "   <dscheque>".$dscheque."</dscheque>";
		$xml .= " </Dados>";
		$xml .= "</Root>";
		
		$xmlResult = mensageria($xml, "TELA_CUSTOD", "CUSTOD_EFETUA_CANC_RESGATE", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
		$xmlObj = getObjectXML($xmlResult);		
		
		if(isset($xmlObj->roottag->tags[1]->name) && strtoupper($xmlObj->roottag->tags[1]->name == 'VALIDAR_CMC7')){	
			$contErro = 0;
			foreach($xmlObj->roottag->tags[1]->tags as $erroCmc7){
				$contErro ++;
				$cmc7    = $erroCmc7->tags[0]->cdata; // CMC-7 que ocorreu o erro
				$critica = $erroCmc7->tags[1]->cdata; // Crítica do erro
				$id = "#id_".$cmc7;
				echo "$('" . $id . "').css('background', '#FF8C69');";
			}
			$msgErro = 'Não foi possível efetuar o cancelamento do resgate de ' || $contErro || ' cheque(s). <br> Verifique cheque(s) destacado(s)..';
			exibirErro('error',utf8_encode($msgErro),'Alerta - Aimaro','',false);
			exit();
		}else {
			if($xmlObj->roottag->tags[0]->name && strtoupper($xmlObj->roottag->tags[0]->name == 'ERRO')){	
				$msgErro = $xmlObj->roottag->tags[0]->cdata;
				if($msgErro == null || $msgErro == ''){
					$msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
				}
				exibirErro('error',$msgErro,'Alerta - Aimaro','',false);
				exit();
			}else{
				echo 'limpaGridCheques();';
				echo 'estadoInicial();';
				$msgErro = 'Cancelamento de resgate efetuado com sucesso!';
				exibirErro('inform',$msgErro,'Alerta - Aimaro','',false);
			}
		}
	}

?>
