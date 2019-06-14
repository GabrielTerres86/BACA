<?php 
	
	//************************************************************************//
	//*** Fonte: cria_altera_registro.php                                  ***//
	//*** Autor: Fabrício                                                  ***//
	//*** Data : Dezembro/2011                Última Alteração:            ***//
	//***                                                                  ***//
	//*** Objetivo  : Incluir, alterar registro do Cartao Transportadora   ***//	
	//***                                                                  ***//	 
	//*** Alterações: 08/02/2012 - Ajustes Pamcar (Adriano).     	       ***//
	//***                          									       ***//
	//***															       ***//
	//***             													   ***//
	//***                          									       ***//
	//************************************************************************//
	
	session_start();
	
	// Includes para controle da session, variáveis globais de controle, e biblioteca de funções	
	require_once("../../includes/config.php");
	require_once("../../includes/funcoes.php");		
	require_once("../../includes/controla_secao.php");
	
	// Verifica se tela foi chamada pelo método POST
	isPostMethod();	
	
	// Classe para leitura do xml de retorno
	require_once("../../class/xmlfile.php");
	
	
	// Verifica permiss&atilde;o
	$msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"L");
	
	
	$carregaCoops = $_POST["carregaCoops"];	
	$coopSelected = $_POST["coopSelected"] == "null" ? 1 : $_POST["coopSelected"];
	
	
	if ($carregaCoops == "true"){
		
		// Monta o xml de requisição
		$xmlCooperativas  = "";
		$xmlCooperativas .= "<Root>";
		$xmlCooperativas .= "	<Cabecalho>";
		$xmlCooperativas .= "		<Bo>b1wgen0119.p</Bo>";
		$xmlCooperativas .= "		<Proc>busca_cooperativas</Proc>";
		$xmlCooperativas .= "	</Cabecalho>";
		$xmlCooperativas .= "	<Dados>";
		$xmlCooperativas .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
		$xmlCooperativas .= "	</Dados>";
		$xmlCooperativas .= "</Root>";
	
		// Executa script para envio do XML
		$xmlResult = getDataXML($xmlCooperativas);
		
				
		// Cria objeto para classe de tratamento de XML
		$xmlObjCooperativas = getObjectXML($xmlResult);
		
			
		// Se ocorrer um erro, mostra crítica
		if (strtoupper($xmlObjCooperativas->roottag->tags[0]->name) == "ERRO") {
			exibeErro($xmlObjCooperativas->roottag->tags[0]->tags[0]->tags[4]->cdata);
		}
	
		$cooperativas   = $xmlObjCooperativas->roottag->tags[0]->tags;	
		$qtCooperativas = count($cooperativas);
	
		?>
		lstCooperativas = new Array(); // Inicializar lista de cooperativas
		<? 
		for ($i = 0; $i < $qtCooperativas; $i++){
		
			$cdcooper = getByTagName($cooperativas[$i]->tags,"CODCOOPE");
			$nmrescop = getByTagName($cooperativas[$i]->tags,"NMRESCOP");
			
		?>
			objCooper = new Object();
			objCooper.cdcooper = "<?php echo $cdcooper; ?>";
			objCooper.nmrescop = "<?php echo $nmrescop; ?>";
			lstCooperativas[<?php echo $i; ?>] = objCooper;
		
		<?
		}
		
		if ($carregaCoops == "true")
			echo 'carregaCooperativas("'.$qtCooperativas.'");';
		
	}
		
				
	// Monta o xml de requisição
	$xmlRegistro  = "";
	$xmlRegistro .= "<Root>";
	$xmlRegistro .= "	<Cabecalho>";
	$xmlRegistro .= "		<Bo>b1wgen0119.p</Bo>";
	$xmlRegistro .= "		<Proc>busca_registro</Proc>";
	$xmlRegistro .= "	</Cabecalho>";
	$xmlRegistro .= "	<Dados>";
			
	if (($glbvars["cdcooper"] == 3) && ($carregaCoops == 'true')){
		$xmlRegistro .= "		<cdcopalt>".$coopSelected."</cdcopalt>";
		
	}else{if (($glbvars["cdcooper"] == 3) && ($carregaCoops == 'false')){
		      $xmlRegistro .= "		<cdcopalt>".$coopSelected."</cdcopalt>";
	
	}else{	
			$xmlRegistro .= "		<cdcopalt>".$glbvars["cdcooper"]."</cdcopalt>";
		}	
	}
	
	$xmlRegistro .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";	
	$xmlRegistro .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xmlRegistro .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xmlRegistro .= "	</Dados>";
	$xmlRegistro .= "</Root>";
		
			
	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlRegistro);
		
	// Cria objeto para classe de tratamento de XML
	$xmlObjRegistro = getObjectXML($xmlResult);
		
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjRegistro->roottag->tags[0]->name) == "ERRO") {
		exibeErro($xmlObjRegistro->roottag->tags[0]->tags[0]->tags[4]->cdata);
	}

	$vllimpam = $xmlObjRegistro->roottag->tags[0]->attributes["VLLIMPAM"];
	$vlpamuti = $xmlObjRegistro->roottag->tags[0]->attributes["VLPAMUTI"];
	$vlmenpam = $xmlObjRegistro->roottag->tags[0]->attributes["VLMENPAM"];
	$pertxpam = $xmlObjRegistro->roottag->tags[0]->attributes["PERTXPAM"];
	
			
	echo 'setaValores("'.$vllimpam.'","'.$vlpamuti.'","'.$vlmenpam.'","'.$pertxpam.'");';
	
			
	if ($glbvars["cdcooper"] != 3)
		echo "$('#divCooper').css({'display':'none'});";
	
	echo "$('#divLimite').css({'display':'block'});";
		
	// Esconde mensagem de aguardo
	echo 'hideMsgAguardo();';
		 
	
	// Função para exibir erros na tela através de javascript
	function exibeErro($msgErro) { 
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Ayllos","estadoInicial()");';
		exit();
	}
	
?>