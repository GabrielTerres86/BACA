<?php 

	/************************************************************************
	 Fonte: grupo_economico.php
	 Autor: Adriano                                                 
	 Data : Novembro/2012                          Última Alteração: 
	                                                                  
	 Objetivo  : Verifica se a conta em questao está em um grupo economico e qual
	                                                                  	 
	 Alterações: 
	************************************************************************/

	session_start();

	// Includes para controle da session, variáveis globais de controle, e biblioteca de funções	
	require_once("../../../../includes/config.php");
	require_once("../../../../includes/funcoes.php");
	require_once("../../../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo método POST
	isPostMethod();	

	// Classe para leitura do xml de retorno
	require_once("../../../../class/xmlfile.php");

	// Verifica se os parâmetros necessários foram informados
	if (!isset($_POST["nrdconta"])){
		exibeErro("Par&acirc;metros incorretos.");
	}

	$nrdconta = $_POST["nrdconta"];
	
	// Verifica se o número da conta é um inteiro válido
	if (!validaInteiro($nrdconta)) {
		exibeErro("Conta/dv inv&aacute;lida.");
	}

	
	// Monta o xml de requisi&ccedil;&atilde;o
	$xmlBuscaGrupo  = "";
	$xmlBuscaGrupo .= "<Root>";
	$xmlBuscaGrupo .= "	<Cabecalho>";
	$xmlBuscaGrupo .= "		<Bo>b1wgen0138.p</Bo>";
	$xmlBuscaGrupo .= "		<Proc>busca_grupo</Proc>";
	$xmlBuscaGrupo .= "	</Cabecalho>";
	$xmlBuscaGrupo .= "	<Dados>";
	$xmlBuscaGrupo .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlBuscaGrupo .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xmlBuscaGrupo .= "	</Dados>";
	$xmlBuscaGrupo .= "</Root>";

	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlBuscaGrupo);

	// Cria objeto para classe de tratamento de XML
	$xmlObjBuscaGrupo = getObjectXML($xmlResult);

	// Se ocorrer um erro, mostra cr&iacute;tica
	if (strtoupper($xmlObjBuscaGrupo->roottag->tags[0]->name) == "ERRO") {
		exibeErro($xmlObjBuscaGrupo->roottag->tags[0]->tags[0]->tags[4]->cdata);
	}
    
	$pertgrup = $xmlObjBuscaGrupo->roottag->tags[0]->attributes['PERTGRUP'];
	$gergrupo = $xmlObjBuscaGrupo->roottag->tags[0]->attributes['GERGRUPO'];
	$nrdgrupo = $xmlObjBuscaGrupo->roottag->tags[0]->attributes['NRDGRUPO'];
			
	if($gergrupo != ""){
						
		echo 'hideMsgAguardo();';
		
		if($pertgrup == "yes" ){
			echo 'showError("inform","'.$gergrupo.'","Alerta - Aimaro","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));calcEndividRiscoGrupo(\''.$nrdgrupo.'\');");';
		}else{
			echo 'showError("inform","'.$gergrupo.'","Alerta - Aimaro","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));validarAvalistas();");';
		}
						
	}else{
	
		echo 'hideMsgAguardo();';
		
		if($pertgrup == "yes"){
			echo 'calcEndividRiscoGrupo(\''.$nrdgrupo.'\');';
		}else{
			echo 'validarAvalistas();';
		}

	}
		
	// Função para exibir erros na tela através de javascript
	function exibeErro($msgErro) { 
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Aimaro","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
		exit();
	}

		
	
?>