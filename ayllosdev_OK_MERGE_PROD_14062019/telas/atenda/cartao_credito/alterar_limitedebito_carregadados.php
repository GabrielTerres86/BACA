<?php 

	/************************************************************************
	  Fonte: alterar_limitedebito_carregadados.php
	  Autor: Guilherme
	  Data : Abril/2008                 Última Alteração: 08/11/2010

	  Objetivo  : Carregar os dados para efetuar a troca do limite de débito de
		          Cartões de Crédito

	  Alterações: 08/11/2010 - Adaptação Cartão PJ (David).
		
				  06/07/2011 - Alterado para layout padrão ( Gabriel - DB1).
				  
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
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"A")) <> "") {
		exibeErro($msgError);		
	}	
	
	// Verifica se os parâmetros necessários foram informados
	if (!isset($_POST["nrdconta"]) ||
		!isset($_POST["nrctrcrd"]) ||
		!isset($_POST["nrcrcard"])){
		exibeErro("Par&acirc;metros incorretos.");
	}

	$nrdconta = $_POST["nrdconta"];
	$nrctrcrd = $_POST["nrctrcrd"];
	$nrcrcard = $_POST["nrcrcard"];

	// Verifica se número da conta é um inteiro válido
	if (!validaInteiro($nrdconta)) {
		exibeErro("Conta/dv inv&aacute;lida.");
	}
	
	// Verifica se numero do contrato é um inteiro válido
	if (!validaInteiro($nrctrcrd)) {
		exibeErro("N&uacute;mero do contrato inv&aacute;lido.");
	}	
	
	// Monta o xml de requisição
	$xmlSetLimDebCrd  = "";
	$xmlSetLimDebCrd .= "<Root>";
	$xmlSetLimDebCrd .= "	<Cabecalho>";
	$xmlSetLimDebCrd .= "		<Bo>b1wgen0028.p</Bo>";
	$xmlSetLimDebCrd .= "		<Proc>carrega_dados_limdeb_cartao</Proc>";
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
	$xmlSetLimDebCrd .= "	</Dados>";
	$xmlSetLimDebCrd .= "</Root>";
	
	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlSetLimDebCrd);

	// Cria objeto para classe de tratamento de XML
	$xmlObjLimDebCrd = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjLimDebCrd->roottag->tags[0]->name) == "ERRO") {
		exibeErro($xmlObjLimDebCrd->roottag->tags[0]->tags[0]->tags[4]->cdata);
	}

	$vllimdeb = $xmlObjLimDebCrd->roottag->tags[0]->tags[0]->tags[0]->cdata;

	// Função para exibir erros na tela através de javascript
	function exibeErro($msgErro) { 
		echo '<script type="text/javascript">';
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Aimaro","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
		echo '</script>';
		exit();
	}
	
?>

<script type="text/javascript">
	var metodoBlock = "blockBackground(parseInt($('#divRotina').css('z-index')))";
</script>
<form action="" name="frmValorLimDeb" id="frmValorLimDeb">
	<fieldset>
		<legend><? echo utf8ToHtml('Alterar Limite de Débito:') ?></legend>
		
		<label for="nrcrcard"><? echo utf8ToHtml('Cartão:') ?></label>
		<input type="text" name="nrcrcard" id="nrcrcard" value="<?php echo $nrcrcard ?>" />
		<br />
		
		<label for="vllimdeb"><? echo utf8ToHtml('Valor:') ?></label>
		<input type="text" name="vllimdeb" id="vllimdeb" value="<?php echo number_format(str_replace(",",".",$vllimdeb),2,",",".") ?>" />
		
	</fieldset>
</form>
<div class="divBotoes">
	<input type="image" src="<?php echo $UrlImagens; ?>botoes/voltar.gif" onClick="voltaDiv(2,1,4);return false;">
	<input type="image" src="<?php echo $UrlImagens; ?>botoes/prosseguir.gif" onClick="showConfirmacao('Deseja alterar o limite de d&eacute;bito do cart&atilde;o de cr&eacute;dito?','Confirma&ccedil;&atilde;o - Aimaro','alteraLimDeb()',metodoBlock,'sim.gif','nao.gif');return false;">
</div>

<script type="text/javascript">
// Mostra o div da Tela da opção
$("#divOpcoesDaOpcao2").css("display","block");
// Esconde os cartões
$("#divOpcoesDaOpcao1").css("display","none");

$("#vllimdeb","#frmValorLimDeb").setMask("DECIMAL","zzz.zz9,99","","");
$("#vllimdeb","#frmValorLimDeb").focus();

controlaLayout('frmValorLimDeb');

// Esconde mensagem de aguardo
hideMsgAguardo();

// Bloqueia conteúdo que está atrás do div da rotina
blockBackground(parseInt($("#divRotina").css("z-index")));

</script>