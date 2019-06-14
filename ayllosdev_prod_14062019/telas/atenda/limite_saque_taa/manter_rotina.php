<?php
   /*
 * FONTE        : mannter_rotina.php
 * CRIA��O      : James Prust Junior
 * DATA CRIA��O : Julho/2015
 * OBJETIVO     : Gravacao dos dados da tela Limite Saque TAA
 * --------------
	* ALTERA��ES   : Corrigi o retorno XML de erro. SD 479874 (Carlos R.)
 * --------------
 */	

	session_start();
	
	// Includes para controle da session, vari�veis globais de controle, e biblioteca de fun��es	
	require_once("../../../includes/config.php");
	require_once("../../../includes/funcoes.php");
	require_once("../../../includes/controla_secao.php");
	require_once("../../../class/xmlfile.php");
	
	// Verifica se tela foi chamada pelo m�todo POST
	isPostMethod();		
	
	// Recebe a opera��o que est� sendo realizada
	$nrdconta 			 = (isset($_POST['nrdconta'])) 		 		  ? $_POST['nrdconta'] 	   					: '';
	$nomeRotinaPai 		 = (isset($_POST['nomeRotinaPai']))  		  ? $_POST['nomeRotinaPai'] 			    : '';
	$fVllimiteSaque 	 = (isset($_POST['vllimite_saque'])) 		  ? converteFloat($_POST['vllimite_saque']) : '';
	$iEmissaoReciboSaque = (isset($_POST['flgemissao_recibo_saque'])) ? $_POST['flgemissao_recibo_saque'] 		: '';
	
	// Somente sera verificado o privilegio, quando a rotina for acessada da Atenda -> Limite de Saque TAA
	if (($nomeRotinaPai != 'magnetico') && ($nomeRotinaPai != 'cartao_credito')){
		
		if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],'A')) <> "")
		   exibirErro('error',$msgError,'Alerta - Aimaro','bloqueiaFundo(divRotina)',false);
	}
	
	// Verifica se o n�mero da conta e o titular s�o inteiros v�lidos
	if (!validaInteiro($nrdconta)) 
		exibirErro('error','Conta/dv inv&aacute;lida.','Alerta - Aimaro','bloqueiaFundo(divRotina)',false);
	
	// Monta o xml de requisicao
	$xml  = "";
	$xml .= "<Root>";
	$xml .= " <Dados>";
	$xml .= "   <nrdconta>".$nrdconta."</nrdconta>";
	$xml .= "   <dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
	$xml .= "   <vllimite_saque>".$fVllimiteSaque."</vllimite_saque>";
	$xml .= "   <flgemissao_recibo_saque>".$iEmissaoReciboSaque."</flgemissao_recibo_saque>";
	$xml .= " </Dados>";
	$xml .= "</Root>";

	$xmlResult = mensageria($xml, "LIMITE_SAQUE_TAA", "LIMITE_SAQUE_TAA_ALTERAR", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObjeto = getObjectXML($xmlResult);

	if (isset($xmlObjeto->roottag->tags[0]->name) && strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO"){
		exibirErro('error',$xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata,'Alerta - Aimaro','bloqueiaFundo(divRotina);',false);
	}
	
	if ($nomeRotinaPai == 'magnetico'){
		echo 'entregarCartaoMagnetico();';
		
	}else if ($nomeRotinaPai == 'cartao_credito'){	
		echo 'efetuaEntregaCartao();';
		
	}else{
		echo 'showError("inform","Limite Saque TAA alterado com sucesso!","Alerta - Aimaro","controlaOperacaoLimiteSaqueTAA();");';
	}
?>