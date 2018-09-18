<?php 

	//************************************************************************//
	//*** Fonte: acumula_calcular_saldo.php                                ***//
	//*** Autor: David                                                     ***//
	//*** Data : Outubro/2009                 &Uacute;ltima Altera&ccedil;&atilde;o: 01/12/2010 ***//
	//***                                                                  ***//
	//*** Objetivo  : Script para calcular saldo acumulado                 ***//		
	//***                                                                  ***//	 
	//*** Altera&ccedil;&otilde;es:                                        ***//
	//***																   ***//
	//***    	01/12/2010 - Alterado a chamada da BO b1wgen0004.p para    ***//
	//***       		     a BO b1wgwen0081.p (Adriano).		           ***//
	//************************************************************************//
	
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
	if (!isset($_POST["nrdconta"]) || !isset($_POST["tpaplica"]) || !isset($_POST["vlaplica"]) || !isset($_POST["dtvencto"]) || !isset($_POST["cdperapl"])) {
		exibeErro("Par&acirc;metros incorretos.");
	}	

	$nrdconta = $_POST["nrdconta"];
	$tpaplica = $_POST["tpaplica"];		
	$vlaplica = $_POST["vlaplica"];		
	$dtvencto = $_POST["dtvencto"];		
	$cdperapl = $_POST["cdperapl"];
	
	// Verifica se n&uacute;mero da conta &eacute; um inteiro v&aacute;lido
	if (!validaInteiro($nrdconta)) {
		exibeErro("Conta/dv inv&aacute;lida.");
	}	
	
	// Verifica se tipo de aplica&ccedil;&atilde;o &eacute; um inteiro v&aacute;lido
	if (!validaInteiro($tpaplica)) {
		exibeErro("Tipo de aplica&ccedil;&atilde;o inv&aacute;lida.");
	}	
	
	// Verifica se valor da aplica&ccedil;&atilde;o &eacute; um decimal v&aacute;lido
	if (!validaDecimal($vlaplica)) {
		exibeErro("Valor inv&aacute;lido.");
	}
	
	// Verifica se &eacute; uma data de vencimento v&aacute;lida
	if (!validaData($dtvencto)) {
		exibeErro("Vencimento inv&aacute;lido.");
	}	
	
	// Verifica se per&iacute;odo de car&ecirc;ncia &eacute; um inteiro v&aacute;lido
	if (!validaInteiro($cdperapl)) {
		exibeErro("Per&iacute;odo de car&ecirc;ncia inv&aacute;lido.");
	}	
	
	// Monta o xml de requisi&ccedil;&atilde;o
	$xmlSaldo  = "";
	$xmlSaldo .= "<Root>";
	$xmlSaldo .= "	<Cabecalho>";
	$xmlSaldo .= "		<Bo>b1wgen0081.p</Bo>";
	$xmlSaldo .= "		<Proc>simular-saldo-acumulado</Proc>";
	$xmlSaldo .= "	</Cabecalho>";
	$xmlSaldo .= "	<Dados>";
	$xmlSaldo .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlSaldo .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xmlSaldo .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xmlSaldo .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xmlSaldo .= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
	$xmlSaldo .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";	
	$xmlSaldo .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xmlSaldo .= "		<idseqttl>1</idseqttl>";
	$xmlSaldo .= "		<tpaplica>".$tpaplica."</tpaplica>";		
	$xmlSaldo .= "		<vlaplica>".$vlaplica."</vlaplica>";
	$xmlSaldo .= "		<dtvencto>".$dtvencto."</dtvencto>";
	$xmlSaldo .= "		<cdperapl>".$cdperapl."</cdperapl>";
	$xmlSaldo .= "		<dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";	
	$xmlSaldo .= "		<cdprogra>".$glbvars["nmdatela"]."</cdprogra>";	
	$xmlSaldo .= "	</Dados>";
	$xmlSaldo .= "</Root>";	
	
	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlSaldo);
	
	// Cria objeto para classe de tratamento de XML
	$xmlObjSaldo = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra cr&iacute;tica
	if (strtoupper($xmlObjSaldo->roottag->tags[0]->name) == "ERRO") {
		exibeErro($xmlObjSaldo->roottag->tags[0]->tags[0]->tags[4]->cdata);
	} 
	
	$saldos   = $xmlObjSaldo->roottag->tags[1]->tags;
	$qtSaldos = count($saldos);
	
	// Fun&ccedil;&atilde;o para exibir erros na tela atrav&eacute;s de javascript
	function exibeErro($msgErro) { 
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Aimaro","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
		exit();
	}	
		
?>
$("#txaplica","#frmSimula" + $("#tpaplica option:selected","#frmSimular").text()).val("<?php echo number_format(str_replace(",",".",$xmlObjSaldo->roottag->tags[0]->tags[0]->tags[6]->cdata),6,",","."); ?>");
$("#txaplmes","#frmSimula" + $("#tpaplica option:selected","#frmSimular").text()).val("<?php echo number_format(str_replace(",",".",$xmlObjSaldo->roottag->tags[0]->tags[0]->tags[7]->cdata),6,",","."); ?>");		

if ($("#tpaplica option:selected","#frmSimular").text() == "RDCPRE") {
	$("#vlsldrdc","#frmSimula" + $("#tpaplica option:selected","#frmSimular").text()).val("<?php echo number_format(str_replace(",",".",$xmlObjSaldo->roottag->tags[0]->tags[0]->tags[5]->cdata),2,",","."); ?>");
} 

var strHTML = "";
strHTML += '<table width="100%" border="0" cellpadding="1" cellspacing="2">';				
<?php 
$cor = "";

for ($i = 0; $i < $qtSaldos; $i++) { 
	if ($cor == "#F4F3F0") {
		$cor = "#FFFFFF";
	} else {
		$cor = "#F4F3F0";
	}
?>
strHTML += '	<tr style="background-color: <?php echo $cor; ?>;">';
strHTML += '		<td width="70" class="txtNormal" align="right"><?php echo formataNumericos("zzz.zzz.zzz",$saldos[$i]->tags[0]->cdata,"."); ?></td>';
strHTML += '		<td width="110" class="txtNormal"><?php echo $saldos[$i]->tags[1]->cdata; ?></td>';
strHTML += '		<td class="txtNormal" align="right"><?php echo number_format(str_replace(",",".",$saldos[$i]->tags[2]->cdata),2,",","."); ?></td>';
strHTML += '	</tr>';
<?php 
} // Fim do for						
?>									
strHTML += '</table>';	

$("#divSaldosAcumulados").html(strHTML);

$("#tdTotal").html("<?php echo number_format(str_replace(",",".",$xmlObjSaldo->roottag->tags[0]->tags[0]->tags[9]->cdata),2,",","."); ?>");

hideMsgAguardo();
blockBackground(parseInt($("#divRotina").css("z-index")));