<?php
	/*!
	 * FONTE        : cheques_bordero_cadastrar_emitente.php
	 * CRIAÇÃO      : Lucas Lombardi
	 * DATA CRIAÇÃO : 06/06/2017
	 * OBJETIVO     : Rotina para cadastrar emitente do cheque no momento da inclusão de custódia
	 * --------------
	 * ALTERAÇÕES   : 
	 * -------------- 
	 */		

    session_start();
	require_once('../../../../includes/config.php');
	require_once('../../../../includes/funcoes.php');
	require_once('../../../../includes/controla_secao.php');
	require_once('../../../../class/xmlfile.php');
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
		$msgErro = utf8_encode($xmlObj->roottag->tags[0]->tags[0]->tags[1]->cdata);
		exibirErro('error',$msgErro,'Alerta - Aimaro','bloqueiaFundo($(\'#divUsoGenerico\'));$(\'#nrcpfcgc\', \'#frmCadastraEmitente\').focus();',false);
		exit();
	} else {
		if(isset($xmlObj->roottag->tags[0]->name) && strtoupper($xmlObj->roottag->tags[0]->name == 'ERRO')){	
			$msgErro = $xmlObj->roottag->tags[0]->cdata;
			if($msgErro == null || $msgErro == ''){
				$msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
			}
			exibirErro('error',$msgErro,'Alerta - Aimaro','bloqueiaFundo($(\'#divUsoGenerico\'));$(\'#nrcpfcgc\', \'#frmCadastraEmitente\').focus();',false);
			exit();
		}else{			
			// Emitente cadastrado, adicionar cheque para custódia
			echo "adicionaChequeGrid();fechaRotina($('#divUsoGenerico')); bloqueiaFundo($('#divRotina'));";
		}
	}
?>
