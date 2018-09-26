
<?php
	/*!
	 * FONTE        : validar_cheque_i.php
	 * CRIAÇÃO      : Lucas Reinert
	 * DATA CRIAÇÃO : 31/03/2017
	 * OBJETIVO     : Rotina para validar custodia de cheque (Opção I)
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
		$msgErro = utf8_encode($xmlObj->roottag->tags[0]->tags[0]->tags[1]->cdata);
		exibirErro('error',$msgErro,'Alerta - Aimaro','novoCheque();',false);
		exit();
	} else {
		if(isset($xmlObj->roottag->tags[0]->name) && strtoupper($xmlObj->roottag->tags[0]->name == 'ERRO')){	
			$msgErro = $xmlObj->roottag->tags[0]->cdata;
			if($msgErro == null || $msgErro == ''){
				$msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
			}
			exibirErro('error',$msgErro,'Alerta - Aimaro','novoCheque();',false);
			exit();
		}else{			
			// Se retornou inemiten falta cadastrar emitentes
			if(isset($xmlObj->roottag->tags[0]->name) && strtoupper($xmlObj->roottag->tags[0]->name == 'EMITENTES')){
				$cdcmpchq = $xmlObj->roottag->tags[0]->tags[0]->tags[0]->cdata;
				$cdbanchq = $xmlObj->roottag->tags[0]->tags[0]->tags[1]->cdata;
				$cdagechq = $xmlObj->roottag->tags[0]->tags[0]->tags[2]->cdata;
				$nrctachq = $xmlObj->roottag->tags[0]->tags[0]->tags[3]->cdata;

				echo "mostraFormEmitente($cdcmpchq, $cdbanchq, $cdagechq, $nrctachq);";
			}
			else{
			// Emitentes já cadastrados, finalizar custodia
				echo "adicionaChequeI();";
			}
		}
	}
?>
