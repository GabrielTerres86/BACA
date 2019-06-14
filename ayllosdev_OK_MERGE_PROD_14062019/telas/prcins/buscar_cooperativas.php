<?php
	/*!
	 * FONTE        : buscar_cooperativas.php
	 * CRIAÇÃO      : Douglas Quisinski
	 * DATA CRIAÇÃO : 24/09/2015
	 * OBJETIVO     : Rotina para carregar as cooperativas do sistema
	 * --------------
	 * ALTERAÇÕES   : 16/10/2015 - Ajustes para liberação (Adriano).
	 * -------------- 
	 */		

    session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();			
	
	$cddopcao = (isset($_POST["cddopcao"])) ? $_POST["cddopcao"] : '';
	$tipopera = (isset($_POST["tipopera"])) ? $_POST["tipopera"] : '';
	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}
	
	// Montar o xml de Requisicao
	$xml .= "<Root>";
	$xml .= " <Dados>";
	$xml .= "    <cddopcao>" . $cddopcao . "</cddopcao>";
	$xml .= "    <tipopera>" . $tipopera . "</tipopera>";
	$xml .= " </Dados>";
	$xml .= "</Root>";
	
	$xmlResult = mensageria($xml, "TELA_PRCINS", "BUSCAR_COOPERATIVAS", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObj = getObjectXML($xmlResult);		
		
	//-----------------------------------------------------------------------------------------------
	// Controle de Erros
	//-----------------------------------------------------------------------------------------------
	if(strtoupper($xmlObj->roottag->tags[0]->name == 'ERRO')){	
		$msgErro = $xmlObj->roottag->tags[0]->cdata;
		if($msgErro == null || $msgErro == ''){
			$msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
		}
		exibirErro('error',$msgErro,'Alerta - Ayllos','',false);
	}
	
	// Limpar campos
	echo '$("#cdcooper","#frmExcluirLancamento").empty();';
	echo '$("#cdcopaux","#frmSolicitar").empty();';
	echo '$("#cdcopaux","#frmResumo").empty();';
	
	// Percorrer cada nó do xml - cada um é uma cooperativa retonada
	foreach($xmlObj->roottag->tags[0]->tags as $coop){
		echo '$("#cdcooper","#frmExcluirLancamento").append(\'<option value="'.getByTagName($coop->tags,'cdcooper').'">'.getByTagName($coop->tags,'nmrescop').'</option>\');';
		echo '$("#cdcopaux","#frmSolicitar").append(\'<option value="'.getByTagName($coop->tags,'cdcooper').'">'.getByTagName($coop->tags,'nmrescop').'</option>\');';
		echo '$("#cdcopaux","#frmResumo").append(\'<option value="'.getByTagName($coop->tags,'cdcooper').'">'.getByTagName($coop->tags,'nmrescop').'</option>\');';
	}
	
	if($cddopcao == 'R'){
		echo 'liberaAcaoResumo();';
	}else if($cddopcao == 'S'){
		echo 'liberaAcaoSolicitar();';
	}
?>