<?php 

	/************************************************************************
	  Fonte: renovar_valida_mostraavais.php                                                 
  	  Autor: Guilherme                                                     
	  Data : Abril/2008               Última Alteração: 08/11/2010
	                                                               
	  Objetivo  : Validar dados da renovação e mostrar os avalistas para 
	              atualizar
	                                                                  	 
	  Alterações: 14/05/2009 - Tirar validação de data para parâmetro  
	                           "dtvalida" (David).           

                  08/11/2010 - Adaptação para cartão PJ (David).							   
	************************************************************************/
	
	session_start();
	
	// Includes para controle da session, variáveis globais de controle, e biblioteca de funções	
	require_once("../../../includes/config.php");
	require_once("../../../includes/funcoes.php");
	require_once("../../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo método POST
	isPostMethod();	
		
	// Classe para leitura do xml de retorno
	require_once("../../../class/xmlfile.php");
	
	// Verifica permissão
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"R")) <> "") {
		exibeErro($msgError);		
	}			
	
	// Verifica se o número da conta foi informado
	if (!isset($_POST["nrdconta"]) || !isset($_POST["nrctrcrd"]) || !isset($_POST["dtvalida"]) || !isset($_POST["inpessoa"])) {
		exibeErro("Par&acirc;metros incorretos.");
	}	

	$nrdconta = $_POST["nrdconta"];
	$nrctrcrd = $_POST["nrctrcrd"];
	$dtvalida = $_POST["dtvalida"];	
	$inpessoa = $_POST["inpessoa"];

	// Verifica se o número da conta é um inteiro válido
	if (!validaInteiro($nrdconta)) {
		exibeErro("Conta/dv inv&aacute;lida.");
	}
	
	// Verifica se o número do contrato é um inteiro válido
	if (!validaInteiro($nrctrcrd)) {
		exibeErro("N&uacute;mero de contrato inv&aacute;lido.");
	}
	
	// Verifica se a data da nova validade é um inteiro válido
	if (!validaInteiro($dtvalida)) {
		exibeErro("Nova data de validade inv&aacute;lida.");
	}	

	// Verifica se tipo de pessoa é um inteiro válido
	if (!validaInteiro($inpessoa)) {
		exibeErro("Tipo de pessoa inv&aacute;lido.");
	}

	// Monta o xml de requisição
	$xmlGetAvais  = "";
	$xmlGetAvais .= "<Root>";
	$xmlGetAvais .= "	<Cabecalho>";
	$xmlGetAvais .= "		<Bo>b1wgen0028.p</Bo>";
	$xmlGetAvais .= "		<Proc>valida_renovacao_cartao</Proc>";
	$xmlGetAvais .= "	</Cabecalho>";
	$xmlGetAvais .= "	<Dados>";
	$xmlGetAvais .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlGetAvais .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xmlGetAvais .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xmlGetAvais .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xmlGetAvais .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xmlGetAvais .= "		<dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
	$xmlGetAvais .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";	
	$xmlGetAvais .= "		<idseqttl>1</idseqttl>";
	$xmlGetAvais .= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
	$xmlGetAvais .= "		<dtvalida>".$dtvalida."</dtvalida>";
	$xmlGetAvais .= "		<nrctrcrd>".$nrctrcrd."</nrctrcrd>";
	$xmlGetAvais .= "	</Dados>";
	$xmlGetAvais .= "</Root>";
		
	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlGetAvais);
	
	// Cria objeto para classe de tratamento de XML
	$xmlObjAvais = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjAvais->roottag->tags[0]->name) == "ERRO") {
		exibeErro($xmlObjAvais->roottag->tags[0]->tags[0]->tags[4]->cdata);
	} 

	$avais = $xmlObjAvais->roottag->tags[0]->tags;
	
	$flgAval01 = count($avais) == 1 || count($avais) == 2 ? true : false;
	$flgAval02 = count($avais) == 2 ? true : false;

	// Função para exibir erros na tela através de javascript
	function exibeErro($msgErro) { 
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Aimaro","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
		exit();
	}

?>

<?php if ($flgAval01) {?>

$("#nrctaav1","#frmNovaValidade").val("<?php echo formataNumericos('zzzz.zzz-z',$avais[0]->tags[0]->cdata,'.-'); ?>");
$("#nmdaval1","#frmNovaValidade").val("<?php echo $avais[0]->tags[1]->cdata; ?>");
$("#nrcpfav1","#frmNovaValidade").val('<?php if ($avais[0]->tags[2]->cdata > 0) { echo formataNumericos("99999999999999",$avais[0]->tags[2]->cdata,".-"); } else { echo "00000000000000"; } ?>');
$("#tpdocav1","#frmNovaValidade").val("<?php echo $avais[0]->tags[3]->cdata; ?>");
$("#dsdocav1","#frmNovaValidade").val("<?php echo $avais[0]->tags[4]->cdata; ?>");
$("#nmdcjav1","#frmNovaValidade").val("<?php echo $avais[0]->tags[5]->cdata; ?>");
$("#cpfcjav1","#frmNovaValidade").val('<?php if ($avais[0]->tags[6]->cdata > 0) { echo formataNumericos("99999999999999",$avais[0]->tags[6]->cdata,".-"); } else { echo "00000000000000"; } ?>');
$("#tdccjav1","#frmNovaValidade").val("<?php echo $avais[0]->tags[7]->cdata; ?>");
$("#doccjav1","#frmNovaValidade").val("<?php echo $avais[0]->tags[8]->cdata; ?>");
$("#ende1av1","#frmNovaValidade").val("<?php echo $avais[0]->tags[9]->cdata; ?>");
$("#ende2av1","#frmNovaValidade").val("<?php echo $avais[0]->tags[10]->cdata; ?>");
$("#nrcepav1","#frmNovaValidade").val('<?php echo formataNumericos("zzzzz-zzz",$avais[0]->tags[15]->cdata,"-"); ?>');
$("#nmcidav1","#frmNovaValidade").val("<?php echo $avais[0]->tags[13]->cdata; ?>");
$("#cdufava1","#frmNovaValidade").val("<?php echo $avais[0]->tags[14]->cdata; ?>");
$("#nrfonav1","#frmNovaValidade").val("<?php echo $avais[0]->tags[11]->cdata; ?>");
$("#emailav1","#frmNovaValidade").val("<?php echo $avais[0]->tags[12]->cdata; ?>");

$("#nrender1","#frmNovaValidade").val("<?php echo getByTagName($avais[0]->tags,'nrendere'); ?>");	
$("#complen1","#frmNovaValidade").val("<?php echo getByTagName($avais[0]->tags,'complend'); ?>");	
$("#nrcxaps1","#frmNovaValidade").val("<?php echo getByTagName($avais[0]->tags,'nrcxapst'); ?>");	

<?php 
} else {
?>

$("#nrctaav1","#frmNovaValidade").val("0");
$("#nrcpfav1","#frmNovaValidade").val("00000000000000");
$("#cpfcjav1","#frmNovaValidade").val("00000000000000");
$("#nrcepav1","#frmNovaValidade").val("0");

<?php
}
if ($flgAval02) { 
?>

$("#nrctaav2","#frmNovaValidade").val("<?php echo formataNumericos('zzzz.zzz-z',$avais[1]->tags[0]->cdata,'.-'); ?>");
$("#nmdaval2","#frmNovaValidade").val("<?php echo $avais[1]->tags[1]->cdata; ?>");
$("#nrcpfav2","#frmNovaValidade").val('<?php if ($avais[1]->tags[2]->cdata > 0) { echo formataNumericos("99999999999999",$avais[1]->tags[2]->cdata,".-"); } else { echo "00000000000000"; } ?>');
$("#tpdocav2","#frmNovaValidade").val("<?php echo $avais[1]->tags[3]->cdata; ?>");
$("#dsdocav2","#frmNovaValidade").val("<?php echo $avais[1]->tags[4]->cdata; ?>");
$("#nmdcjav2","#frmNovaValidade").val("<?php echo $avais[1]->tags[5]->cdata; ?>");
$("#cpfcjav2","#frmNovaValidade").val('<?php if ($avais[1]->tags[6]->cdata > 0) { echo formataNumericos("99999999999999",$avais[1]->tags[6]->cdata,".-"); } else { echo "00000000000000"; } ?>');
$("#tdccjav2","#frmNovaValidade").val("<?php echo $avais[1]->tags[7]->cdata; ?>");
$("#doccjav2","#frmNovaValidade").val("<?php echo $avais[1]->tags[8]->cdata; ?>");
$("#ende1av2","#frmNovaValidade").val("<?php echo $avais[1]->tags[9]->cdata; ?>");
$("#ende2av2","#frmNovaValidade").val("<?php echo $avais[1]->tags[10]->cdata; ?>");
$("#nrcepav2","#frmNovaValidade").val('<?php echo formataNumericos("zzzzz-zzz",$avais[1]->tags[15]->cdata,"-"); ?>');
$("#nmcidav2","#frmNovaValidade").val("<?php echo $avais[1]->tags[13]->cdata; ?>");
$("#cdufava2","#frmNovaValidade").val("<?php echo $avais[1]->tags[14]->cdata; ?>");
$("#nrfonav2","#frmNovaValidade").val("<?php echo $avais[1]->tags[11]->cdata; ?>"); 
$("#emailav2","#frmNovaValidade").val("<?php echo $avais[1]->tags[12]->cdata; ?>");	

$("#nrender2","#frmNovaValidade").val("<?php echo getByTagName($avais[1]->tags,'nrendere'); ?>");	
$("#complen2","#frmNovaValidade").val("<?php echo getByTagName($avais[1]->tags,'complend'); ?>");	
$("#nrcxaps2","#frmNovaValidade").val("<?php echo getByTagName($avais[1]->tags,'nrcxapst'); ?>");	

<?php
} else {
?>

$("#nrctaav2","#frmNovaValidade").val("0");
$("#nrcpfav2","#frmNovaValidade").val("00000000000000");
$("#cpfcjav2","#frmNovaValidade").val("00000000000000");
$("#nrcepav2","#frmNovaValidade").val("0");

<?php
}

if ($inpessoa == "1") {

?>

// Esconde o div dos dados
$("#divDadosNovaValidade").css("display","none");
// Mostra o div dos avalistas
$("#divDadosAvalistasNovaValidade").css("display","block");
//Esconde o titulo da tela
$("#spntitulo").css("display","none");

hideMsgAguardo();

// Bloqueia conte&uacute;do que est&aacute; &aacute;tras do div da rotina
blockBackground(parseInt($("#divRotina").css("z-index")));

<?php 

} else {

?>

hideMsgAguardo();

// Bloqueia conte&uacute;do que est&aacute; &aacute;tras do div da rotina
blockBackground(parseInt($("#divRotina").css("z-index")));

// Mostra mensagem de confirmação para finalizar a operação
showConfirmacao('Deseja renovar o cart&atilde;o de cr&eacute;dito?','Confirma&ccedil;&atilde;o - Aimaro','efetuaRenovacaoCartao()','blockBackground(parseInt($("#divRotina").css("z-index")))','sim.gif','nao.gif');

<?php 

}

?>