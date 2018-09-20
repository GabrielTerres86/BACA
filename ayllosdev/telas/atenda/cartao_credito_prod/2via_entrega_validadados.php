<?php 

	/************************************************************************
	 Fonte: 2via_entrega_validadados.php                              
	 Autor: Guilherme                                                 
	 Data : Março/2008                   Última Alteração: 11/04/2013 
	                                                                  
	 Objetivo  : Validar os dados informados e mostrar o div dos      
	             avais                                                
	                                                                  
	 Alterações: 04/09/2008 - Adaptação para solicitação de 2 via de  
	                          senha de cartão de crédito (David)      
	                                                                  
	             14/05/2009 - Tirar validação de data para parâmetro  
	                          "dtvalida" (David).                     
	                                                                  
	             08/11/2010 - Adaptação Cartão PJ (David)             
	
				 11/04/2013 - Incluido a passagem do parâmetro idorigem na
						      chamada da procedure valida_dados_entrega2via_cartao
							 (Adriano).
	
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
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"2")) <> "") {
		exibeErro($msgError);		
	}	
	
	// Verifica se os parâmetros necessários foram informados
	if (!isset($_POST["nrdconta"]) || !isset($_POST["nrctrcrd"]) || !isset($_POST["nrcrcard"]) || !isset($_POST["inpessoa"]) || 
	    !isset($_POST["dtvalida"]) || !isset($_POST["flgimpnp"]) || !isset($_POST["repsolic"])){
		exibeErro("Par&acirc;metros incorretos.");
	}

	$nrdconta = $_POST["nrdconta"];
	$nrctrcrd = $_POST["nrctrcrd"];
	$nrcrcard = $_POST["nrcrcard"];
	$dtvalida = $_POST["dtvalida"];	
	$inpessoa = $_POST["inpessoa"];
	$flgimpnp = $_POST["flgimpnp"];
	$repsolic = $_POST["repsolic"];
	
	// Verifica se número da conta é um inteiro válido
	if (!validaInteiro($nrdconta)) {
		exibeErro("Conta/dv inv&aacute;lida.");
	}

	// Verifica se número do contrato é um inteiro válido
	if (!validaInteiro($nrctrcrd)) {
		exibeErro("N&uacute;mero do contrato inv&aacute;lido.");
	}	
	
	// Verifica se tipo de pessoa é um inteiro válido
	if (!validaInteiro($inpessoa)) {
		exibeErro("Tipo de pessoa inv&aacute;lido.");
	}

	// Verifica se número do cartão é um inteiro válido
	if (!validaInteiro($nrcrcard)) {
		exibeErro("N&uacute;mero do cart&atilde;o inv&aacute;lido.");
	}	
	
	// Verifica se data de validade é um inteiro válido - 999999 = MMYYYY
	if (!validaInteiro($dtvalida)) {
		exibeErro("Data de validade inv&aacute;lida.");		
	}	
	
	// Monta o xml de requisição
	$xmlSetCartao  = "";
	$xmlSetCartao .= "<Root>";
	$xmlSetCartao .= "	<Cabecalho>";
	$xmlSetCartao .= "		<Bo>b1wgen0028.p</Bo>";
	$xmlSetCartao .= "		<Proc>valida_dados_entrega2via_cartao</Proc>";
	$xmlSetCartao .= "	</Cabecalho>";
	$xmlSetCartao .= "	<Dados>";
	$xmlSetCartao .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlSetCartao .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xmlSetCartao .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xmlSetCartao .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xmlSetCartao .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";
	$xmlSetCartao .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xmlSetCartao .= "		<nrctrcrd>".$nrctrcrd."</nrctrcrd>";
	$xmlSetCartao .= "		<nrcrcard>".$nrcrcard."</nrcrcard>";
	$xmlSetCartao .= "		<dtvalida>".$dtvalida."</dtvalida>";
	$xmlSetCartao .= "		<flgimpnp>".$flgimpnp."</flgimpnp>";	
	$xmlSetCartao .= "		<repsolic>".$repsolic."</repsolic>";
	$xmlSetCartao .= "	</Dados>";
	$xmlSetCartao .= "</Root>";

	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlSetCartao);
	
	// Cria objeto para classe de tratamento de XML
	$xmlObjCartao = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjCartao->roottag->tags[0]->name) == "ERRO") {
		exibeErro($xmlObjCartao->roottag->tags[0]->tags[0]->tags[4]->cdata);
	} 	
	
	$avais = $xmlObjCartao->roottag->tags[0]->tags;
	
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

$("#nrctaav1","#frmEntrega2via").val("<?php echo formataNumericos('zzzz.zzz-z',$avais[0]->tags[0]->cdata,'.-'); ?>");
$("#nmdaval1","#frmEntrega2via").val("<?php echo $avais[0]->tags[1]->cdata; ?>");
$("#nrcpfav1","#frmEntrega2via").val('<?php if ($avais[0]->tags[2]->cdata > 0) { echo formataNumericos("99999999999999",$avais[0]->tags[2]->cdata,".-"); } else { echo "00000000000000"; } ?>');
$("#tpdocav1","#frmEntrega2via").val("<?php echo $avais[0]->tags[3]->cdata; ?>");
$("#dsdocav1","#frmEntrega2via").val("<?php echo $avais[0]->tags[4]->cdata; ?>");
$("#nmdcjav1","#frmEntrega2via").val("<?php echo $avais[0]->tags[5]->cdata; ?>");
$("#cpfcjav1","#frmEntrega2via").val('<?php if ($avais[0]->tags[6]->cdata > 0) { echo formataNumericos("99999999999999",$avais[0]->tags[6]->cdata,".-"); } else { echo "00000000000000"; } ?>');
$("#tdccjav1","#frmEntrega2via").val("<?php echo $avais[0]->tags[7]->cdata; ?>");
$("#doccjav1","#frmEntrega2via").val("<?php echo $avais[0]->tags[8]->cdata; ?>");
$("#ende1av1","#frmEntrega2via").val("<?php echo $avais[0]->tags[9]->cdata; ?>");
$("#ende2av1","#frmEntrega2via").val("<?php echo $avais[0]->tags[10]->cdata; ?>");
$("#nrcepav1","#frmEntrega2via").val('<?php echo formataNumericos("zzzzz-zzz",$avais[0]->tags[15]->cdata,"-"); ?>');
$("#nmcidav1","#frmEntrega2via").val("<?php echo $avais[0]->tags[13]->cdata; ?>");
$("#cdufava1","#frmEntrega2via").val("<?php echo $avais[0]->tags[14]->cdata; ?>");
$("#nrfonav1","#frmEntrega2via").val("<?php echo $avais[0]->tags[11]->cdata; ?>");
$("#emailav1","#frmEntrega2via").val("<?php echo $avais[0]->tags[12]->cdata; ?>");

$("#nrender1","#frmEntrega2via").val("<?php echo getByTagName($avais[0]->tags,'nrendere'); ?>");	
$("#complen1","#frmEntrega2via").val("<?php echo getByTagName($avais[0]->tags,'complend'); ?>");	
$("#nrcxaps1","#frmEntrega2via").val("<?php echo getByTagName($avais[0]->tags,'nrcxapst'); ?>");	

<?php 
} else {
?>

$("#nrctaav1","#frmEntrega2via").val("0");
$("#nrcpfav1","#frmEntrega2via").val("00000000000000");
$("#cpfcjav1","#frmEntrega2via").val("00000000000000");
$("#nrcepav1","#frmEntrega2via").val("0");

<?php
}
if ($flgAval02) { 
?>

$("#nrctaav2","#frmEntrega2via").val("<?php echo formataNumericos('zzzz.zzz-z',$avais[1]->tags[0]->cdata,'.-'); ?>");
$("#nmdaval2","#frmEntrega2via").val("<?php echo $avais[1]->tags[1]->cdata; ?>");
$("#nrcpfav2","#frmEntrega2via").val('<?php if ($avais[1]->tags[2]->cdata > 0) { echo formataNumericos("99999999999999",$avais[1]->tags[2]->cdata,".-"); } else { echo "00000000000000"; } ?>');
$("#tpdocav2","#frmEntrega2via").val("<?php echo $avais[1]->tags[3]->cdata; ?>");
$("#dsdocav2","#frmEntrega2via").val("<?php echo $avais[1]->tags[4]->cdata; ?>");
$("#nmdcjav2","#frmEntrega2via").val("<?php echo $avais[1]->tags[5]->cdata; ?>");
$("#cpfcjav2","#frmEntrega2via").val('<?php if ($avais[1]->tags[6]->cdata > 0) { echo formataNumericos("99999999999999",$avais[1]->tags[6]->cdata,".-"); } else { echo "00000000000000"; } ?>');
$("#tdccjav2","#frmEntrega2via").val("<?php echo $avais[1]->tags[7]->cdata; ?>");
$("#doccjav2","#frmEntrega2via").val("<?php echo $avais[1]->tags[8]->cdata; ?>");
$("#ende1av2","#frmEntrega2via").val("<?php echo $avais[1]->tags[9]->cdata; ?>");
$("#ende2av2","#frmEntrega2via").val("<?php echo $avais[1]->tags[10]->cdata; ?>");
$("#nrcepav2","#frmEntrega2via").val('<?php echo formataNumericos("zzzzz-zzz",$avais[1]->tags[15]->cdata,"-"); ?>');
$("#nmcidav2","#frmEntrega2via").val("<?php echo $avais[1]->tags[13]->cdata; ?>");
$("#cdufava2","#frmEntrega2via").val("<?php echo $avais[1]->tags[14]->cdata; ?>");
$("#nrfonav2","#frmEntrega2via").val("<?php echo $avais[1]->tags[11]->cdata; ?>"); 
$("#emailav2","#frmEntrega2via").val("<?php echo $avais[1]->tags[12]->cdata; ?>");	

$("#nrender2","#frmEntrega2via").val("<?php echo getByTagName($avais[1]->tags,'nrendere'); ?>");	
$("#complen2","#frmEntrega2via").val("<?php echo getByTagName($avais[1]->tags,'complend'); ?>");	
$("#nrcxaps2","#frmEntrega2via").val("<?php echo getByTagName($avais[1]->tags,'nrcxapst'); ?>");	

<?php
} else {
?>

$("#nrctaav2","#frmEntrega2via").val("0");
$("#nrcpfav2","#frmEntrega2via").val("00000000000000");
$("#cpfcjav2","#frmEntrega2via").val("00000000000000");
$("#nrcepav2","#frmEntrega2via").val("0");

<?php 

} 

if ($inpessoa == "1") { 
	
?>

// Esconde o div dos dados
$("#divDadosEntrega").css("display","none");
// Mostra o div dos avalistas
$("#divDadosAvalistasEntrega").css("display","block");

hideMsgAguardo();

// Bloqueia conteúdo que está atrás do div da rotina
blockBackground(parseInt($("#divRotina").css("z-index")));

<?php 
	
}  else {

?>

hideMsgAguardo();

// Bloqueia conteúdo que está atrás do div da rotina
blockBackground(parseInt($("#divRotina").css("z-index")));

// Mostra mensagem de confirmação para finalizar a operação
showConfirmacao('Deseja cadastrar entrega de segunda via do cr&eacute;dito do cart&atilde;o?','Confirma&ccedil;&atilde;o - Aimaro','efetuaEntrega2viaCartao()','blockBackground(parseInt($("#divRotina").css("z-index")))','sim.gif','nao.gif');

<?php

}

?>