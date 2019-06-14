<?php
	/*!
	 * FONTE        : cadastrar_emiten.php
	 * CRIAÇÃO      : Lucas Reinert
	 * DATA CRIAÇÃO : 13/10/2016
	 * OBJETIVO     : Rotina para cadastrar emitentes de cheque
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
	
	$dscheque = !isset($_POST["dscheque"]) ? "" : $_POST["dscheque"];
		
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],"I")) <> '') {
		exibirErro('error',$msgError,'Alerta - Aimaro','',false);
	}
	
	// Verifica se os parâmetros necessários foram informados	
	if ($dscheque === "") exibirErro('error','Parametro inv&aacute;lido.','Alerta - Aimaro','',false);
		
	// Montar o xml de Requisicao
	$xml  = "<Root>";
	$xml .= " <Dados>";
	$xml .= "   <dscheque>".$dscheque."</dscheque>";
	$xml .= " </Dados>";
	$xml .= "</Root>";
	
	$xmlResult = mensageria($xml, "CUSTCH", "CUSTCH_CADASTRAR_EMITEN", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObj = getObjectXML($xmlResult);		
		
	//-----------------------------------------------------------------------------------------------
	// Controle de Erros
	//-----------------------------------------------------------------------------------------------
	
	if(isset($xmlObj->roottag->tags[0]->name) && strtoupper($xmlObj->roottag->tags[0]->name == 'VALIDAR_EMITEN')){	
		foreach($xmlObj->roottag->tags[0]->tags as $erroEmiten){
			$id      = "#id_".$erroEmiten->tags[0]->cdata; // ID do emitente
            $critica = $erroEmiten->tags[1]->cdata; // Crítica do erro
			echo "$('" . $id . "').css('background', '#FF8C69');";
			echo "$('#dscritic','" . $id . "').text('" . $critica . "');";
		}
		$msgErro = 'Aconteceram erros durante a validação dos emitentes. <br> Verifique os emitentes destacados.';
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
			// Emitentes já cadastrados, finalizar custodia
			echo "finalizaCustodiaCheque();";
		}
	}
?>
