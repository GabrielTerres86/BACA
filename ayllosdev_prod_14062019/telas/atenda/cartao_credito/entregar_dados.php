<?php 

	/************************************************************************
	  Fonte: entregar_dados.php
	  Autor: Guilherme
	  Data : Marco/2008                 Última Alteração: 08/07/2011

	  Objetivo  : Carrega dados para opção entrega

	  Alterações: 14/05/2009 - Acerto no campo da data de validade (David)
	  
	              04/11/2010 - Adaptação Cartão PJ (David)
				  
				  01/02/2011 - Numero do cartao de credito, alterado
							   de 4 campos para 1 (Jorge). 

				  08/07/2011 - Alterado para layout padrão ( Gabriel - DB1 )
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
	if (!isset($_POST["nrdconta"]) || !isset($_POST["nrctrcrd"]) || !isset($_POST["inpessoa"])){
		exibeErro("Par&acirc;metros incorretos.");
	}

	$nrdconta = $_POST["nrdconta"];
	$nrctrcrd = $_POST["nrctrcrd"];
	$inpessoa = $_POST["inpessoa"];

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
		exibeErro("Tipo de pessoa inv&aacute;lida.");
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
	$xmlSetCartao .= "		<inconfir>99</inconfir>";
	$xmlSetCartao .= "		<nrctrcrd>".$nrctrcrd."</nrctrcrd>";
	$xmlSetCartao .= "		<nrcrcard></nrcrcard>";
	$xmlSetCartao .= "		<nrcrcard2></nrcrcard2>";
	$xmlSetCartao .= "		<dtvalida></dtvalida>";
	$xmlSetCartao .= "		<repsolic></repsolic>";
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

	if ($inpessoa == "2") {
		// Monta o xml de requisição
		$xmlGetRepresen  = "";
		$xmlGetRepresen .= "<Root>";
		$xmlGetRepresen .= "	<Cabecalho>";
		$xmlGetRepresen .= "		<Bo>b1wgen0028.p</Bo>";
		$xmlGetRepresen .= "		<Proc>carrega_representante</Proc>";
		$xmlGetRepresen .= "	</Cabecalho>";
		$xmlGetRepresen .= "	<Dados>";
		$xmlGetRepresen .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";		
		$xmlGetRepresen .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
		$xmlGetRepresen .= "		<nrdconta>".$nrdconta."</nrdconta>";		
		$xmlGetRepresen .= "	</Dados>";
		$xmlGetRepresen .= "</Root>";
		
		// Executa script para envio do XML
		$xmlResult = getDataXML($xmlGetRepresen);

		// Cria objeto para classe de tratamento de XML
		$xmlObjRepresen = getObjectXML($xmlResult);
		
		$repsolic = explode(",",$xmlObjRepresen->roottag->tags[0]->attributes["REPRESEN"]);
		$cpfrepre = explode(",",$xmlObjRepresen->roottag->tags[0]->attributes["CPFREPRE"]);
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

<form action="" name="frmEntregarDados" id="frmEntregarDados">
	<fieldset>
		<legend>Entregar</legend>
		
		<?php if ($inpessoa == "2") { ?>
			<label for="repsolic"><? echo utf8ToHtml('Representante Solicitante:') ?></label>
			<select name="repsolic" id="repsolic">
				<?php for ($i = 0; $i < count($repsolic); $i++) { ?>
				<option value="<?php echo $cpfrepre[$i]; ?>"<?php if ($i == 0) echo " selected"; ?>><?php echo $repsolic[$i]; ?></option>
				<?php } ?>
			</select>
			<br />
		<?php } ?>
		
		<label for="cfseqca"><? echo utf8ToHtml('Cartão:') ?></label>
		<input type="text" name="cfseqca" id="cfseqca" value="" />
		<br />
		
		<label for="dtvalida"><? echo utf8ToHtml('Data de Validade:') ?></label>
		<input type="text" name="dtvalida" id="dtvalida" value="" />
		<br />
		
	</fieldset>
</form>
<div class="divBotoes">
	<input type="image" src="<?php echo $UrlImagens; ?>botoes/voltar.gif" onClick="voltaDiv(2,1,4);return false;" />
	<input type="image" src="<?php echo $UrlImagens; ?>botoes/prosseguir.gif" onClick="confirmaDadosEntrega();return false;" />
</div>

<script type="text/javascript">
// Mostra o div da Tela da opção
$("#divOpcoesDaOpcao2").css("display","block");
// Esconde os cartões
$("#divOpcoesDaOpcao1").css("display","none");

controlaLayout('frmEntregarDados');

// Esconde mensagem de aguardo
hideMsgAguardo();

// Bloqueia conteúdo que está atrás do div da rotina
blockBackground(parseInt($("#divRotina").css("z-index")));
</script>