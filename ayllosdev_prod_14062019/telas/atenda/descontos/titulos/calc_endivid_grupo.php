<?php 

	/************************************************************************
	 Fonte: calc_endivid_grupo.php
	 Autor: Adriano                                                 
	 Data : Novembro/2012                          Última Alteração: 
	                                                                  
	 Objetivo  : Realiza o cálculo do endividamento e risco do grupo
	                                                                  	 
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
	if (!isset($_POST["nrdconta"]) || 
		!isset($_POST["nrdgrupo"])){
		exibeErro("Par&acirc;metros incorretos.");
	}
	$tipo = (isset($_POST['tipo'])) ? $_POST['tipo'] : "CONTRATO";
	$nrdconta = $_POST["nrdconta"];
	$nrdgrupo = $_POST["nrdgrupo"];
	// PRJ 438 - Sprint 7 - Flag para nao validar o avalista, que já é validado anteriormente (0 não validar / 1 validar (default))
	$flgValidarAvalistas = (isset($_POST['flgValidarAvalistas'])) ? $_POST['flgValidarAvalistas'] : 1;
	
	// Verifica se o número da conta é um inteiro válido
	if (!validaInteiro($nrdconta)) {
		exibeErro("Conta/dv inv&aacute;lida.");
	}
	
	// Verifica se o número do grupo é um inteiro válido
	if (!validaInteiro($nrdgrupo)) {
		exibeErro("N&uacute;mero do grupo inv&aacute;lido.");
	}

	// Monta o xml de requisi&ccedil;&atilde;o
	$xmlCalEndivRiscoGrupo  = "";
	$xmlCalEndivRiscoGrupo .= "<Root>";
	$xmlCalEndivRiscoGrupo .= "	<Cabecalho>";
	$xmlCalEndivRiscoGrupo .= "		<Bo>b1wgen0138.p</Bo>";
	$xmlCalEndivRiscoGrupo .= "		<Proc>calc_endivid_grupo</Proc>";
	$xmlCalEndivRiscoGrupo .= "	</Cabecalho>";
	$xmlCalEndivRiscoGrupo .= "	<Dados>";
	$xmlCalEndivRiscoGrupo .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlCalEndivRiscoGrupo .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xmlCalEndivRiscoGrupo .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xmlCalEndivRiscoGrupo .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xmlCalEndivRiscoGrupo .= "		<dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
	$xmlCalEndivRiscoGrupo .= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
	$xmlCalEndivRiscoGrupo .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";
	$xmlCalEndivRiscoGrupo .= "		<nrdgrupo>".$nrdgrupo."</nrdgrupo>";
	$xmlCalEndivRiscoGrupo .= "		<tpdecons>true</tpdecons>"; /*Consulta por conta*/
	$xmlCalEndivRiscoGrupo .= "	</Dados>";
	$xmlCalEndivRiscoGrupo .= "</Root>";

	// Executa script para envio do XML
	$xmlResultCalcEndivRiscoGrupo = getDataXML($xmlCalEndivRiscoGrupo);

	// Cria objeto para classe de tratamento de XML
	$xmlObjCalcEndivRiscoGrupo = getObjectXML($xmlResultCalcEndivRiscoGrupo);
	
	if (strtoupper($xmlCalEndivRiscoGrupo->roottag->tags[0]->name) == "ERRO") {
	
		exibeErro($xmlCalEndivRiscoGrupo->roottag->tags[0]->tags[0]->tags[4]->cdata);
		
	}
	
	$dsdrisco = $xmlObjCalcEndivRiscoGrupo->roottag->tags[0]->attributes['DSDRISCO'];
	$vlendivi = $xmlObjCalcEndivRiscoGrupo->roottag->tags[0]->attributes['VLENDIVI'];
	$grupo = $xmlObjCalcEndivRiscoGrupo->roottag->tags[1]->tags;
	
	
	echo "strHTML = '';";
	echo "strHTML2 = '';";
			
	echo "strHTML2 += '<form name=\'frmGrupoEconomico\' id=\'frmGrupoEconomico\' class=\'formulario\'>';";
	echo "strHTML2 +=	'<br />';";
	echo "strHTML2 +=	'Conta pertence a grupo econ&ocirc;mico.';";
	echo "strHTML2 +=	'<br />';";
	echo 'strHTML2 +=	\'Risco Atual do Grupo "'.$dsdrisco.'".\';';
	echo "strHTML2 +=	'<br />';";
	echo "strHTML2 +='</form>';";
	
	echo "strHTML +='<br style=\'clear:both\' />';";
	echo "strHTML +='<br style=\'clear:both\' />';";
	echo "strHTML +='<div class=\'divRegistros\'>';";
	echo "strHTML +=	'<table>';";
	echo "strHTML +=		'<thead>';";
	echo "strHTML +=			'<tr>';";
	echo 'strHTML +=				\'<th>'.utf8ToHtml("Contas Relacionadas").'</th>\';';
	echo "strHTML +=			'</tr>';";
	echo "strHTML +=		'</thead>';";
	echo "strHTML +=		'<tbody>';";

	for ($i = 0; $i < count($grupo); $i++) {
			
		echo "strHTML +=				'<tr>';";
		echo "strHTML +=					'</td>';";
		echo 'strHTML +=					\'<td><span>'.$grupo[$i]->tags[2]->cdata.'</span>\';';
		echo 'strHTML +=							\''.formataContaDV($grupo[$i]->tags[2]->cdata).'\';';
		echo "strHTML +=					'</td>';";
		echo "strHTML +=				'</tr>';";
				
	}
	
	echo "strHTML +=		'</tbody>';";
	echo "strHTML +=	'</table>';";
		
	echo "mostraMsgsGrupoEconomico();";
	echo "formataGrupoEconomico();";
	if($flgValidarAvalistas == 0){
		echo 'dsmetodo = \'continuarSemValidarAvalistas("'.$tipo.'");\';';
	}else{
    	echo 'dsmetodo = \'validarAvalistas("'.$tipo.'");\';';
	}
	

	
	// Função para exibir erros na tela através de javascript
	function exibeErro($msgErro) { 
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Aimaro","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
		exit();
	}

		
	
?>
