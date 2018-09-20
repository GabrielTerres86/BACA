<?php 

	/************************************************************************
	 Fonte: grupo_economico.php
	 Autor: Adriano                                                 
	 Data : Novembro/2012                          �ltima Altera��o: 
	                                                                  
	 Objetivo  : Verifica se a conta em questao est� em um grupo economico e qual
	                                                                  	 
	 Altera��es: 
	************************************************************************/

	session_start();

	// Includes para controle da session, vari�veis globais de controle, e biblioteca de fun��es	
	require_once("../../../../includes/config.php");
	require_once("../../../../includes/funcoes.php");
	require_once("../../../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo m�todo POST
	isPostMethod();	

	// Classe para leitura do xml de retorno
	require_once("../../../../class/xmlfile.php");

	// Verifica se os par�metros necess�rios foram informados
	if (!isset($_POST["nrdconta"])){
		exibeErro("Par&acirc;metros incorretos.");
	}

	$nrdconta = $_POST["nrdconta"];
	
	// Verifica se o n�mero da conta � um inteiro v�lido
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
		
	// Fun��o para exibir erros na tela atrav�s de javascript
	function exibeErro($msgErro) { 
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Aimaro","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
		exit();
	}

		
	
?>