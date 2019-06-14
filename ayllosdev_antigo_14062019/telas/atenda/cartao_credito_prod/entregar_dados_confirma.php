<?php 

	/************************************************************************
	  Fonte: entrega_dados_confirma.php
	  Autor: Guilherme
	  Data : Abril/2008                 Última Alteração: 26/08/2015

	  Objetivo  : Confirmação do nº cartão para entrega do cartão da 
	              Rotina CARTÃO MAGNÉTICO 

      Alterações: 14/05/2009 - Alterar nome dtvalchr para dtvalida (David)
	 
	              04/11/2010 - Adaptação Cartão PJ (David)
				  
				  01/02/2011 - Numero do cartao de credito, alterado
							   de 4 campos para 1 (Jorge).
							   
		          26/08/2015 - Remover o form da impressao. (James)					   
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
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"F")) <> "") {
		exibeErro($msgError);		
	}			
	
	// Verifica se os parâmetros necessários foram informados
	if (!isset($_POST["nrdconta"]) || !isset($_POST["nrctrcrd"]) || !isset($_POST["dtvalida"]) || !isset($_POST["nrcrcard"]) || !isset($_POST["repsolic"])){
		exibeErro("Par&acirc;metros incorretos.");
	}

	$nrdconta = $_POST["nrdconta"];
	$nrctrcrd = $_POST["nrctrcrd"];
	$repsolic = $_POST["repsolic"];
	$nrcrcard = $_POST["nrcrcard"];
	$dtvalida = $_POST["dtvalida"];

	// Verifica se número da conta é um inteiro válido
	if (!validaInteiro($nrdconta)) {
		exibeErro("Conta/dv inv&aacute;lida.");
	}
	
	// Verifica se número do contrato é um inteiro válido
	if (!validaInteiro($nrctrcrd)) {
		exibeErro("N&uacute;mero do contrato inv&aacute;lido.");
	}	
	
	// Verifica se número do cartão é um inteiro válido
	if (!validaInteiro($nrcrcard)) {
		exibeErro("N&uacute;mero do cart&atilde;o inv&aacute;lido.");
	}

	// Verifica se data de validade é um inteiro válido
	if (!validaInteiro($dtvalida)) {
		exibeErro("Data de validade inv&aacute;lida.");
	}

	// Monta o xml de requisição
	$xmlSetCartao  = "";
	$xmlSetCartao .= "<Root>";
	$xmlSetCartao .= "	<Cabecalho>";
	$xmlSetCartao .= "		<Bo>b1wgen0028.p</Bo>";
	$xmlSetCartao .= "		<Proc>valida_entrega_cartao</Proc>";
	$xmlSetCartao .= "	</Cabecalho>";
	$xmlSetCartao .= "	<Dados>";
	$xmlSetCartao .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlSetCartao .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xmlSetCartao .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xmlSetCartao .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xmlSetCartao .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xmlSetCartao .= "		<dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
	$xmlSetCartao .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";
	$xmlSetCartao .= "		<idseqttl>1</idseqttl>";
	$xmlSetCartao .= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
	$xmlSetCartao .= "		<inconfir>1</inconfir>";
	$xmlSetCartao .= "		<nrctrcrd>".$nrctrcrd."</nrctrcrd>";
	$xmlSetCartao .= "		<nrcrcard>".$nrcrcard."</nrcrcard>";
	$xmlSetCartao .= "		<nrcrcard2>".$nrcrcard."</nrcrcard2>";
	$xmlSetCartao .= "		<dtvalida>".$dtvalida."</dtvalida>";
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

	// Função para exibir erros na tela através de javascript
	function exibeErro($msgErro) { 
		echo '<script type="text/javascript">';
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Aimaro","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
		echo '</script>';
		exit();
	}	
	
?>

<form action="" name="frmConfirmaDados" id="frmConfirmaDados">
	<fieldset>
		<legend><? echo utf8ToHtml('Confirmar o Número do Cartão:') ?></legend>
		
		<label for="cfseqca"><? echo utf8ToHtml('Cartão:') ?></label>
		<input type="text" name="cfseqca" id="cfseqca" class="campo" style="width: 140px;" value="">
				
	</fieldset>
</form>
<div class="divBotoes">
	<input type="image" src="<?php echo $UrlImagens; ?>botoes/voltar.gif"   onClick="voltaDiv(3,2,4);return false;" />
	<input type="image" src="<?php echo $UrlImagens; ?>botoes/entregar.gif" onClick="entregaCartao();return false;" />
</div>
<script type="text/javascript">
// Mostra o div da confirmação
$("#divOpcoesDaOpcao3").css("display","block");
// Esconde o div anterior
$("#divOpcoesDaOpcao2").css("display","none");

controlaLayout('frmConfirmaDados');

// Esconde mensagem de aguardo
hideMsgAguardo();

// Bloqueia conteúdo que está atrás do div da rotina
blockBackground(parseInt($("#divRotina").css("z-index")));
</script>