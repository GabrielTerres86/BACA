<?php 

	/***********************************************************************************
	 Fonte: acumula_permanencia.php                                   
	 Autor: David                                                     
	 Data : Outubro/2009                           Última atualização: 26/06/2014
	                                                                  
	 Objetivo  : Script para calcular permanência (vencimento) da     
	             aplicação.                                   
	                                                                  
	 Alterações: 01/12/2010 - Alterado a chamada da BO b1wgen0004.p para 
	                          a BO b1wgen0081.p (Adriano).               
							  
			     26/06/2014 - Ajustes refente ao projeto de captação
							  (Adriano).
							  
	************************************************************************************/
	
	session_start();
	
	// Includes para controle da session, vari&aacute;veis globais de controle, e biblioteca de fun&ccedil;&otilde;es	
	require_once("../../../includes/config.php");
	require_once("../../../includes/funcoes.php");		
	require_once("../../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo m&eacute;todo POST
	isPostMethod();	
	
	// Classe para leitura do xml de retorno
	require_once("../../../class/xmlfile.php");	
	
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"A")) <> "") {
		exibeErro($msgError);		
	}	
	
	// Se par&acirc;metros necess&aacute;rios n&atilde;o foram informados
	if (!isset($_POST["nrdconta"]) || 
		!isset($_POST["tpaplica"]) || 
		!isset($_POST["qtdiaapl"]) || 
		!isset($_POST["qtdiacar"]) || 
		!isset($_POST["dtvencto"])) {
		exibeErro("Par&acirc;metros incorretos.");
	}	

	$nrdconta = $_POST["nrdconta"];
	$tpaplica = $_POST["tpaplica"];		
	$qtdiaapl = $_POST["qtdiaapl"];		
	$qtdiacar = $_POST["qtdiacar"];		
	$dtvencto = $_POST["dtvencto"];		
	
	// Verifica se n&uacute;mero da conta &eacute; um inteiro v&aacute;lido
	if (!validaInteiro($nrdconta)) {
		exibeErro("Conta/dv inv&aacute;lida.");
	}	
	
	// Verifica se tipo de aplica&ccedil;&atilde;o &eacute; um inteiro v&aacute;lido
	if (!validaInteiro($tpaplica)) {
		exibeErro("Tipo de aplica&ccedil;&atilde;o inv&aacute;lida.");
	}	
	
	// Verifica se quantidade de dias &eacute; um inteiro v&aacute;lido
	if (!validaInteiro($qtdiaapl)) {
		exibeErro("Quantidade de dias inv&aacute;lida.");
	}
	
	// Verifica se quantidade de dias &eacute; um inteiro v&aacute;lido
	if (!validaInteiro($qtdiacar)) {
		exibeErro("Quantidade de dias inv&aacute;lida.");
	}
	
	// Verifica se &eacute; uma data v&aacute;lida
	if ($dtvencto <> "" && !validaData($dtvencto)) {
		exibeErro("Data de vencimento inv&aacute;lida.");
	}
			
	// Monta o xml de requisi&ccedil;&atilde;o
	$xmlPermanencia  = "";
	$xmlPermanencia .= "<Root>";
	$xmlPermanencia .= "	<Cabecalho>";
	$xmlPermanencia .= "		<Bo>b1wgen0081.p</Bo>";
	$xmlPermanencia .= "		<Proc>calcula-permanencia-resgate</Proc>";
	$xmlPermanencia .= "	</Cabecalho>";
	$xmlPermanencia .= "	<Dados>";
	$xmlPermanencia .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlPermanencia .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xmlPermanencia .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xmlPermanencia .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xmlPermanencia .= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
	$xmlPermanencia .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";	
	$xmlPermanencia .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xmlPermanencia .= "		<idseqttl>1</idseqttl>";
	$xmlPermanencia .= "		<tpaplica>".$tpaplica."</tpaplica>";
	$xmlPermanencia .= "		<dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";	
	$xmlPermanencia .= "		<qtdiaapl>".$qtdiaapl."</qtdiaapl>";
	$xmlPermanencia .= "		<qtdiacar>".$qtdiacar."</qtdiacar>";
	$xmlPermanencia .= "		<dtvencto>".$dtvencto."</dtvencto>";	
	$xmlPermanencia .= "	</Dados>";
	$xmlPermanencia .= "</Root>";	
	
	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlPermanencia);
	
	// Cria objeto para classe de tratamento de XML
	$xmlObjPermanencia = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra cr&iacute;tica
	if (strtoupper($xmlObjPermanencia->roottag->tags[0]->name) == "ERRO") {
		exibeErro($xmlObjPermanencia->roottag->tags[0]->tags[0]->tags[4]->cdata);
	} 	
	
	// Fun&ccedil;&atilde;o para exibir erros na tela atrav&eacute;s de javascript
	function exibeErro($msgErro) { 
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Aimaro","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
		exit();
	}

?>

glbqtdia = "<?php echo $xmlObjPermanencia->roottag->tags[0]->attributes["QTDIAAPL"]; ?>";
glbvenct = "<?php echo $xmlObjPermanencia->roottag->tags[0]->attributes["DTVENCTO"]; ?>";

/*RDCPRE*/
if('<?php echo $tpaplica;?>' == '7'){
	
	$("#qtdiaapl","#frmSimula" + $("#tpaplica option:selected","#frmSimular").text()).val("<?php echo $xmlObjPermanencia->roottag->tags[0]->attributes["QTDIAAPL"]; ?>");
	$("#dtvencto","#frmSimula" + $("#tpaplica option:selected","#frmSimular").text()).val("<?php echo $xmlObjPermanencia->roottag->tags[0]->attributes["DTVENCTO"]; ?>");
	
}else{
	
	$("#dtvencto","#frmSimula" + $("#tpaplica option:selected","#frmSimular").text()).val("<?php echo $xmlObjPermanencia->roottag->tags[0]->attributes["DTVENCTO"]; ?>");
	$("#dtvencto","#frmSimula" + $("#tpaplica option:selected","#frmSimular").text()).habilitaCampo().focus();
	
}

hideMsgAguardo();
blockBackground(parseInt($("#divRotina").css("z-index")));

