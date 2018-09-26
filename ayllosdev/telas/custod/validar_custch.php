
<?php
	/*!
	 * FONTE        : validar_custch.php
	 * CRIAÇÃO      : Lucas Reinert
	 * DATA CRIAÇÃO : 13/10/2016
	 * OBJETIVO     : Rotina para validar custodia de cheque
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
	
	$xmlResult = mensageria($xml, "CUSTCH", "CUSTCH_VALIDAR", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObj = getObjectXML($xmlResult);		
		
	//-----------------------------------------------------------------------------------------------
	// Controle de Erros
	//-----------------------------------------------------------------------------------------------
	
	if(isset($xmlObj->roottag->tags[0]->name) && strtoupper($xmlObj->roottag->tags[0]->name == 'VALIDAR_CMC7')){	
		foreach($xmlObj->roottag->tags[0]->tags as $erroCmc7){
			$cmc7    = $erroCmc7->tags[0]->cdata; // CMC-7 que ocorreu o erro
            $critica = $erroCmc7->tags[1]->cdata; // Crítica do erro
			$id = "#id_".$cmc7;
			echo "$('" . $id . "').css('background', '#FF8C69');";
			echo "$('#aux_dscritic','" . $id . "').text('" . $critica . "');";
		}
		$msgErro = 'Aconteceram erros durante a validação dos cheques para custodiar. <br> Verifique os cheques destacados.';
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
		}else{			
			// Se retornou inemiten falta cadastrar emitentes
			if(isset($xmlObj->roottag->tags[0]->name) && strtoupper($xmlObj->roottag->tags[0]->name == 'EMITENTES')){
				echo 'mostraDivEmiten();';
				$aux_cont = 0;
				// Chamar tela de cadastro de emitentes
				foreach($xmlObj->roottag->tags[0]->tags as $emitente){
					$cdcmpchq = $emitente->tags[0]->cdata; // Comp
					$cdbanchq = $emitente->tags[1]->cdata; // Banco
					$cdagechq = $emitente->tags[2]->cdata; // Agência
					$nrctachq = $emitente->tags[3]->cdata; // Nr. da conta cheque
					echo 'criaEmitente('.$cdcmpchq.','.$cdbanchq.','.$cdagechq.','.$nrctachq.','.$aux_cont.');';
					$aux_cont++;
				}
				if ($aux_cont > 0 ){
					// Foca no cpf do primeiro emitente
					echo 'cNrcpfcnpj[0].focus()';
				}
				exit();
			}else{
			// Emitentes já cadastrados, finalizar custodia
				echo "finalizarCustodia();";
			}
		}
	}
?>
