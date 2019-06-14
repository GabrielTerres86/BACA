<?
/*!
 * FONTE        : alterar_limitecredito_carregadados.php
 * CRIAÇÃO      : Guilherme
 * DATA CRIAÇÃO : Abril/2008
 * OBJETIVO     : Carregar os dados para efetuar a troca do limite de crédito de cartão crédito
 * --------------
 * ALTERAÇÕES   :
 * --------------
 * 000: [05/11/2010] David     (CECRED) : Adaptações para Cartão PJ
 * 001: [04/05/2011] Rodolpho     (DB1) : Adaptações para o formulário genérico de avalistas
 * 002: [06/07/2011] Gabriel      (DB1) : Alterado para layout padrão
 * 003: [26/08/2015] James				: Remover o form da impressao.
 */
?>

<? 
	session_start();
	require_once('../../../includes/config.php');
	require_once('../../../includes/funcoes.php');
	require_once('../../../includes/controla_secao.php');
	require_once('../../../class/xmlfile.php');
	isPostMethod();	
	
	$funcaoAposErro = 'bloqueiaFundo(divRotina);';
	
	// Verifica permissão
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"A")) <> "") {
		exibirErro('error',$msgError,'Alerta - Aimaro',$funcaoAposErro);	
	}	
	
	// Verifica se os parâmetros necessários foram informados
	if (!isset($_POST["nrdconta"]) ||
        !isset($_POST["nrctrcrd"]) ||
		!isset($_POST["nrcrcard"]) ||
		!isset($_POST["inpessoa"])) {
		exibirErro('error','Par&acirc;metros incorretos.','Alerta - Aimaro',$funcaoAposErro);	
	}

	$nrdconta = $_POST["nrdconta"];
	$inpessoa = $_POST["inpessoa"];
	$nrctrcrd = $_POST["nrctrcrd"];
	$nrcrcard = $_POST["nrcrcard"];

	// Verifica se número da conta é um inteiro válido
	if (!validaInteiro($nrdconta)) exibirErro('error','Conta/dv inv&aacute;lida.','Alerta - Aimaro',$funcaoAposErro);
	
	// Verifica se tipo de pessoa é um inteiro válido
	if (!validaInteiro($inpessoa)) exibirErro('error','Tipo de pessoa inv&aacute;lido.','Alerta - Aimaro',$funcaoAposErro);
	
	// Verifica se número do contrato é um inteiro válido
	if (!validaInteiro($nrctrcrd)) exibirErro('error','N&uacute;mero do contrato inv&aacute;lido.','Alerta - Aimaro',$funcaoAposErro);
	
	// Monta o xml de requisição
	$xmlSetLimCredCrd  = "";
	$xmlSetLimCredCrd .= "<Root>";
	$xmlSetLimCredCrd .= "	<Cabecalho>";
	$xmlSetLimCredCrd .= "		<Bo>b1wgen0028.p</Bo>";
	$xmlSetLimCredCrd .= "		<Proc>carrega_dados_limcred_cartao</Proc>";
	$xmlSetLimCredCrd .= "	</Cabecalho>";
	$xmlSetLimCredCrd .= "	<Dados>";
	$xmlSetLimCredCrd .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlSetLimCredCrd .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xmlSetLimCredCrd .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xmlSetLimCredCrd .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xmlSetLimCredCrd .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xmlSetLimCredCrd .= "		<dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
	$xmlSetLimCredCrd .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";
	$xmlSetLimCredCrd .= "		<idseqttl>1</idseqttl>";
	$xmlSetLimCredCrd .= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
	$xmlSetLimCredCrd .= "		<nrctrcrd>".$nrctrcrd."</nrctrcrd>";
	$xmlSetLimCredCrd .= "	</Dados>";
	$xmlSetLimCredCrd .= "</Root>";
	
	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlSetLimCredCrd);

	// Cria objeto para classe de tratamento de XML
	$xmlObjLimCredCrd = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjLimCredCrd->roottag->tags[0]->name) == "ERRO") {
		exibirErro('error',$xmlObjLimCredCrd->roottag->tags[0]->tags[0]->tags[4]->cdata,'Alerta - Aimaro',$funcaoAposErro);
	}

	$vllimcre = $xmlObjLimCredCrd->roottag->tags[0]->tags[0]->tags[0]->cdata;
	
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
?>
<form action="" class="formulario" name="frmValorLimCre" id="frmValorLimCre">
	<div id="divDadosAlterarLimiteCredito">
		<fieldset>
			<legend><? echo utf8ToHtml('Alterar Limite de Crédito:') ?></legend>
			
			<label for="nrcrcard"><? echo utf8ToHtml('Cartão:') ?></label>
			<input type="text" name="nrcrcard" id="nrcrcard" value="<? echo $nrcrcard ?>" />
			<br />
			
			<? if ($inpessoa == "2") { ?>
				<label for="repsolic"><? echo utf8ToHtml('Representante Solicitante:') ?></label>
				<select name="repsolic" id="repsolic">
					<? for ($i = 0; $i < count($repsolic); $i++) { ?>
					<option value="<? echo $cpfrepre[$i]; ?>"<? if ($i == 0) echo " selected"; ?>><? echo $repsolic[$i]; ?></option>
					<? } ?>
				</select>
				<br />
			<? } ?>
			
			<label for="vllimcrd"><? echo utf8ToHtml('Valor:') ?></label>
			<input type="text" name="vllimcrd" id="vllimcrd" value="<? echo number_format(str_replace(",",".",$vllimcre),2,",",".") ?>" />
			<br />
			
			<? if ($inpessoa == "1") { ?>												
				<label for="flgimpnp"><? echo utf8ToHtml('Promissória:') ?></label>
				<select name="flgimpnp" id="flgimpnp">
					<option value="yes" selected>Imprime</option>
				</select>
				<br />
			<? } ?>
			
		</fieldset>
		
		<div id="divBotoes">
			<input type="image" src="<? echo $UrlImagens; ?>botoes/voltar.gif" onClick="voltaDiv(2,1,4);return false;" />
			<input type="image" src="<? echo $UrlImagens; ?>botoes/prosseguir.gif" onClick="validaLimCre();return false;" />
		</div>
		
	</div>
	<div id="divOpcaoDadosAvalistas" class="condensado">								
		<? 
			// ALTERAÇÃO 001: Substituido formulário antigo pelo include				
			include('../../../includes/avalistas/form_avalista.php'); 
		?>
		<div id="divBotoes">
			<input type="image" src="<? echo $UrlImagens; ?>botoes/voltar.gif" onClick="voltaDiv(2,1,4);return false;">
			<input type="image" src="<? echo $UrlImagens; ?>botoes/cancelar.gif" onClick="showConfirmacao('Deseja cancelar a altera&ccedil;&atilde;o de limite de cr&eacute;dito do cart&atilde;o?','Confirma&ccedil;&atilde;o - Aimaro','voltaDiv(0,2,4)','blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))','sim.gif','nao.gif');return false;">
			<input type="image" src="<? echo $UrlImagens; ?>botoes/concluir.gif" onClick="validarAvalistas(1);return false;">
		</div>
	</div>
	
</form>

<script type="text/javascript">
	// Mostra o div da Tela da opção
	$("#divOpcoesDaOpcao2").css("display","block");
	$("#divDadosAlterarLimiteCredito").css("display","block");

	// Esconde os cartões e avalistas
	$("#divOpcoesDaOpcao1").css("display","none");
	$("#divOpcaoDadosAvalistas").css("display","none");
	
	controlaLayout('frmValorLimCre');

	layoutPadrao();
	hideMsgAguardo();
	bloqueiaFundo(divRotina);
</script>