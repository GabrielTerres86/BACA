<?php 

	/************************************************************************
	  Fonte: alterar_limitecredito_validalimite.php
	  Autor: Guilherme
	  Data : Abril/2008                 �ltima Altera��o: 05/11/2010

	  Objetivo  : Validar dados e mostrar avais para efetuar a troca do limite 
	              de cr�dito de Cart�es de Cr�dito

	  Altera��es: 05/11/2010 - Adapta��o Cart�o PJ (David).
	************************************************************************/
	
	session_start();
	
	// Includes para controle da session, vari�veis globais de controle, e biblioteca de fun��es
	require_once("../../../includes/config.php");
	require_once("../../../includes/funcoes.php");		
	require_once("../../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo m�todo POST
	isPostMethod();	
		
	// Classe para leitura do xml de retorno
	require_once("../../../class/xmlfile.php");
	
	// Verifica permiss�o
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"A")) <> "") {
		exibeErro($msgError);		
	}	
	
	// Verifica se os par�metros necess�rios foram informados
	if (!isset($_POST["nrdconta"]) ||
	    !isset($_POST["inpessoa"]) ||
        !isset($_POST["nrctrcrd"]) ||
		!isset($_POST["repsolic"]) ||
		!isset($_POST["vllimcrd"])) {
		exibeErro("Par&acirc;metros incorretos.");
	}

	$nrdconta = $_POST["nrdconta"];
	$inpessoa = $_POST["inpessoa"];
	$nrctrcrd = $_POST["nrctrcrd"];
	$vllimcrd = $_POST["vllimcrd"];
	$repsolic = $_POST["repsolic"];

	// Verifica se n�mero da conta � um inteiro v�lido
	if (!validaInteiro($nrdconta)) {
		exibeErro("Conta/dv inv&aacute;lida.");
	}
	
	// Verifica se n�mero do contrato � um inteiro v�lido
	if (!validaInteiro($nrctrcrd)) {
		exibeErro("N&uacute;mero do contrato inv&aacute;lido.");
	}	
	
	// Monta o xml de requisi��o
	$xmlSetLimDebCrd  = "";
	$xmlSetLimDebCrd .= "<Root>";
	$xmlSetLimDebCrd .= "	<Cabecalho>";
	$xmlSetLimDebCrd .= "		<Bo>b1wgen0028.p</Bo>";
	$xmlSetLimDebCrd .= "		<Proc>valida_dados_limcred_cartao</Proc>";
	$xmlSetLimDebCrd .= "	</Cabecalho>";
	$xmlSetLimDebCrd .= "	<Dados>";
	$xmlSetLimDebCrd .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlSetLimDebCrd .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xmlSetLimDebCrd .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xmlSetLimDebCrd .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xmlSetLimDebCrd .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xmlSetLimDebCrd .= "		<dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
	$xmlSetLimDebCrd .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";
	$xmlSetLimDebCrd .= "		<idseqttl>1</idseqttl>";
	$xmlSetLimDebCrd .= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
	$xmlSetLimDebCrd .= "		<nrctrcrd>".$nrctrcrd."</nrctrcrd>";
	$xmlSetLimDebCrd .= "		<vllimcrd>".$vllimcrd."</vllimcrd>";	
	$xmlSetLimDebCrd .= "		<repsolic>".$repsolic."</repsolic>";
	$xmlSetLimDebCrd .= "	</Dados>";
	$xmlSetLimDebCrd .= "</Root>";
	
	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlSetLimDebCrd);

	// Cria objeto para classe de tratamento de XML
	$xmlObjLimDebCrd = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra cr�tica
	if (strtoupper($xmlObjLimDebCrd->roottag->tags[0]->name) == "ERRO") {
		exibeErro($xmlObjLimDebCrd->roottag->tags[0]->tags[0]->tags[4]->cdata);
	}	
	
	$avais = $xmlObjLimDebCrd->roottag->tags[0]->tags;
	
	$flgAval01 = count($avais) == 1 || count($avais) == 2 ? true : false;
	$flgAval02 = count($avais) == 2 ? true : false;	
	
	$idconfir = $xmlObjLimDebCrd->roottag->tags[1]->tags[0]->tags[0]->cdata;
	$dsmensag = $xmlObjLimDebCrd->roottag->tags[1]->tags[0]->tags[1]->cdata;
	
	// Fun��o para exibir erros na tela atrav�s de javascript
	function exibeErro($msgErro) { 
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Ayllos","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
		exit();
	}
	
?>

<?php 

if ($flgAval01) { 
	
?>

$("#nrctaav1","#frmValorLimCre").val("<?php echo formataNumericos('zzzz.zzz-z',$avais[0]->tags[0]->cdata,'.-'); ?>");
$("#nmdaval1","#frmValorLimCre").val("<?php echo $avais[0]->tags[1]->cdata; ?>");
$("#nrcpfav1","#frmValorLimCre").val('<?php if ($avais[0]->tags[2]->cdata > 0) { echo formataNumericos("99999999999999",$avais[0]->tags[2]->cdata,".-"); } else { echo "00000000000000"; } ?>');
$("#tpdocav1","#frmValorLimCre").val("<?php echo $avais[0]->tags[3]->cdata; ?>");
$("#dsdocav1","#frmValorLimCre").val("<?php echo $avais[0]->tags[4]->cdata; ?>");
$("#nmdcjav1","#frmValorLimCre").val("<?php echo $avais[0]->tags[5]->cdata; ?>");
$("#cpfcjav1","#frmValorLimCre").val('<?php if ($avais[0]->tags[6]->cdata > 0) { echo formataNumericos("99999999999999",$avais[0]->tags[6]->cdata,".-"); } else { echo "00000000000000"; } ?>');
$("#tdccjav1","#frmValorLimCre").val("<?php echo $avais[0]->tags[7]->cdata; ?>");
$("#doccjav1","#frmValorLimCre").val("<?php echo $avais[0]->tags[8]->cdata; ?>");
$("#ende1av1","#frmValorLimCre").val("<?php echo $avais[0]->tags[9]->cdata; ?>");
$("#ende2av1","#frmValorLimCre").val("<?php echo $avais[0]->tags[10]->cdata; ?>");
$("#nrcepav1","#frmValorLimCre").val('<?php echo formataNumericos("zzzzz-zzz",$avais[0]->tags[15]->cdata,"-"); ?>');
$("#nmcidav1","#frmValorLimCre").val("<?php echo $avais[0]->tags[13]->cdata; ?>");
$("#cdufava1","#frmValorLimCre").val("<?php echo $avais[0]->tags[14]->cdata; ?>");
$("#nrfonav1","#frmValorLimCre").val("<?php echo $avais[0]->tags[11]->cdata; ?>");
$("#emailav1","#frmValorLimCre").val("<?php echo $avais[0]->tags[12]->cdata; ?>");

$("#nrender1","#frmValorLimCre").val("<?php echo getByTagName($avais[0]->tags,'nrendere'); ?>");	
$("#complen1","#frmValorLimCre").val("<?php echo getByTagName($avais[0]->tags,'complend'); ?>");	
$("#nrcxaps1","#frmValorLimCre").val("<?php echo getByTagName($avais[0]->tags,'nrcxapst'); ?>");	

<?php 

} else { 
	
?>

$("#nrctaav1","#frmValorLimCre").val("0");
$("#nrcpfav1","#frmValorLimCre").val("00000000000000");
$("#cpfcjav1","#frmValorLimCre").val("00000000000000");
$("#nrcepav1","#frmValorLimCre").val("0");

<?php 
	
} 

if ($flgAval02) { 

?>

$("#nrctaav2","#frmValorLimCre").val("<?php echo formataNumericos('zzzz.zzz-z',$avais[1]->tags[0]->cdata,'.-'); ?>");
$("#nmdaval2","#frmValorLimCre").val("<?php echo $avais[1]->tags[1]->cdata; ?>");
$("#nrcpfav2","#frmValorLimCre").val('<?php if ($avais[1]->tags[2]->cdata > 0) { echo formataNumericos("99999999999999",$avais[1]->tags[2]->cdata,".-"); } else { echo "00000000000000"; } ?>');
$("#tpdocav2","#frmValorLimCre").val("<?php echo $avais[1]->tags[3]->cdata; ?>");
$("#dsdocav2","#frmValorLimCre").val("<?php echo $avais[1]->tags[4]->cdata; ?>");
$("#nmdcjav2","#frmValorLimCre").val("<?php echo $avais[1]->tags[5]->cdata; ?>");
$("#cpfcjav2","#frmValorLimCre").val('<?php if ($avais[1]->tags[6]->cdata > 0) { echo formataNumericos("99999999999999",$avais[1]->tags[6]->cdata,".-"); } else { echo "00000000000000"; } ?>');
$("#tdccjav2","#frmValorLimCre").val("<?php echo $avais[1]->tags[7]->cdata; ?>");
$("#doccjav2","#frmValorLimCre").val("<?php echo $avais[1]->tags[8]->cdata; ?>");
$("#ende1av2","#frmValorLimCre").val("<?php echo $avais[1]->tags[9]->cdata; ?>");
$("#ende2av2","#frmValorLimCre").val("<?php echo $avais[1]->tags[10]->cdata; ?>");
$("#nrcepav2","#frmValorLimCre").val('<?php echo formataNumericos("zzzzz-zzz",$avais[1]->tags[15]->cdata,"-"); ?>');
$("#nmcidav2","#frmValorLimCre").val("<?php echo $avais[1]->tags[13]->cdata; ?>");
$("#cdufava2","#frmValorLimCre").val("<?php echo $avais[1]->tags[14]->cdata; ?>");
$("#nrfonav2","#frmValorLimCre").val("<?php echo $avais[1]->tags[11]->cdata; ?>"); 
$("#emailav2","#frmValorLimCre").val("<?php echo $avais[1]->tags[12]->cdata; ?>");	

$("#nrender2","#frmValorLimCre").val("<?php echo getByTagName($avais[1]->tags,'nrendere'); ?>");	
$("#complen2","#frmValorLimCre").val("<?php echo getByTagName($avais[1]->tags,'complend'); ?>");	
$("#nrcxaps2","#frmValorLimCre").val("<?php echo getByTagName($avais[1]->tags,'nrcxapst'); ?>");	

<?php 

} else { 
	
?>

$("#nrctaav2","#frmValorLimCre").val("0");
$("#nrcpfav2","#frmValorLimCre").val("00000000000000");
$("#cpfcjav2","#frmValorLimCre").val("00000000000000");
$("#nrcepav2","#frmValorLimCre").val("0");

<?php 

} 

if ($inpessoa == "1") { 
	
?>

// Esconde o div dos dados
$("#divDadosAlterarLimiteCredito").css("display","none");
// Mostra o div dos avalistas
$("#divOpcaoDadosAvalistas").css("display","block");

hideMsgAguardo();

// Bloqueia conte&uacute;do que est&aacute; &aacute;tras do div da rotina
blockBackground(parseInt($("#divRotina").css("z-index")));
	
<?php 

	// Mostra se Bo retornar mensagem de % da cooperativa
	if ($idconfir == 1) {
		echo 'showError("inform","'.$dsmensag.'","Alerta - Ayllos","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
	} 
} else { 
	
?>

hideMsgAguardo();

// Bloqueia conte&uacute;do que est&aacute; &aacute;tras do div da rotina
blockBackground(parseInt($("#divRotina").css("z-index")));

<?php 

	// Mostra mensagem de confirma��o para finalizar a opera��o
	echo "showConfirmacao('".(trim($dsmensag) <> "" ? $dsmensag."<br><br>" : "")."Deseja cadastrar o novo limite de cr&eacute;dito do cart&atilde;o?','Confirma&ccedil;&atilde;o - Ayllos','alteraLimCre()','blockBackground(parseInt($(\"#divRotina\").css(\"z-index\")))','sim.gif','nao.gif');";
}