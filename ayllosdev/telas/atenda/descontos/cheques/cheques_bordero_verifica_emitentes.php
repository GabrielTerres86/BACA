<?php
	/*!
	 * FONTE        : cheques_bordero_verifica_emitentes.php
	 * CRIAÇÃO      : Lucas Reinert
	 * DATA CRIAÇÃO : 16/11/2016
	 * OBJETIVO     : Rotina para verificar emitentes dos cheques informados no borderô
	 * --------------
	 * ALTERAÇÕES   : 16/04/2018 - Incluida chamada para a rotina validaValorProduto. PRJ366 (Lombardi)
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
	$vlcompcr = !isset($_POST["vlcompcr"]) ? 0  : $_POST["vlcompcr"];
	
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
	
	$xmlResult = mensageria($xml, "TELA_ATENDA_DESCTO", "VERIFICA_EMITENTES", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObj = getObjectXML($xmlResult);		
		
	//-----------------------------------------------------------------------------------------------
	// Controle de Erros
	//-----------------------------------------------------------------------------------------------
	
	if(isset($xmlObj->roottag->tags[0]->name) && strtoupper($xmlObj->roottag->tags[0]->name == 'ERRO')){	
		$msgErro = $xmlObj->roottag->tags[0]->cdata;
		if($msgErro == null || $msgErro == ''){
			$msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
		}
		exibirErro('error',$msgErro,'Alerta - Aimaro','blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));',false);
		exit();
	}else{
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
		echo "validaValorProduto(".$nrdconta.", 34, ".$vlcompcr.",\"prosseguirManterBordero();\",\"divRotina\", 0);";
		}
	}	
?>
