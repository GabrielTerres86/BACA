<?php
	/*!
	 * FONTE        : cheques_bordero_custodia_novo_valida.php
	 * CRIAÇÃO      : Lucas Reinert
	 * DATA CRIAÇÃO : 11/11/2016
	 * OBJETIVO     : Rotina para validar custodia de cheque
	 * --------------
	 * ALTERAÇÕES   : 
	 * -------------- 
	 */		

	session_start();
	
	// Includes para controle da session, variáveis globais de controle, e biblioteca de funções	
	require_once("../../../../includes/config.php");
	require_once("../../../../includes/funcoes.php");
	require_once("../../../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo método POST
	isPostMethod();	
		
	// Classe para leitura do xml de retorno
	require_once("../../../../class/xmlfile.php");
	
	$nrdconta = !isset($_POST["nrdconta"]) ? 0  : $_POST["nrdconta"];
	$dscheque = !isset($_POST["dscheque"]) ? "" : $_POST["dscheque"];
	
	// Verifica se os parâmetros necessários foram informados
	if (!validaInteiro($nrdconta)) exibirErro('error','Conta inv&aacute;lida.','Alerta - Aimaro','blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));',false);
	if ($dscheque === "") exibirErro('error','Parametro inv&aacute;lido.','Alerta - Aimaro','blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));',false);
		
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
		$msgErro = 'Aconteceram erros durante a validação dos cheques para inclusão no borderô. <br> Verifique os cheques destacados.';
		exibirErro('error',$msgErro,'Alerta - Aimaro','blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));',false);
		exit();
	} else {
		if(isset($xmlObj->roottag->tags[0]->name) && strtoupper($xmlObj->roottag->tags[0]->name == 'ERRO')){	
			$msgErro = $xmlObj->roottag->tags[0]->cdata;
			if($msgErro == null || $msgErro == ''){
				$msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
			}
			exibirErro('error',$msgErro,'Alerta - Aimaro','blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));',false);
			exit();
		}else{
			echo 'adicionarChqsBordero(1, "tbChequesNovos");';
			// Se retornou inemiten falta cadastrar emitentes
			if(isset($xmlObj->roottag->tags[0]->name) && strtoupper($xmlObj->roottag->tags[0]->name == 'INF_EMITENTES')){
				// Chamar tela de cadastro de emitentes
				foreach($xmlObj->roottag->tags[0]->tags as $emitente){
					$nrcpfcgc = $emitente->tags[0]->cdata; // CPF/CNPJ
					$nmcheque = $emitente->tags[1]->cdata; // Nome emitente
					$idcheque = $emitente->tags[2]->cdata; // Id do cheque da tabela
					echo 'adicionaEmitente(\'b'.$idcheque.'\',\''.$nrcpfcgc.'\',\''.$nmcheque.'\');';
				}
			}
			exit();
		}
	}
?>
