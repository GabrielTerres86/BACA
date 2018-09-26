<?
/*!
 * FONTE        : 2via_entrega_carregadados.php
 * CRIAÇÃO      : Guilherme
 * DATA CRIAÇÃO : Março/2008
 * OBJETIVO     : Carregar os dados para efetuar a entrega da segunda via de Cartões de Crédito
 * --------------
 * ALTERAÇÕES   :
 * --------------
 * 000: [04/09/2008] David     (CECRED) : Adaptação para solicitação de 2 via de senha de cartão de crédito
 * 000: [14/05/2009] David     (CECRED) : Corrigir FORMAT do campo dtvalida para "99/9999" 
 * 000: [08/11/2010] David     (CECRED) : Adaptação Cartão PJ
 * 000: [01/02/2011] Jorge     (CECRED) : Numero do cartao de credito, alterado de 4 campos para 1
 * 001: [05/05/2011] Rodolpho     (DB1) : Adaptações para o formulário genérico de avalistas
 * 002: [05/07/2011] Gabriel      (DB1) : Alterado para layout padrão
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
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"2")) <> "") {
		exibirErro('error',$msgError,'Alerta - Aimaro',$funcaoAposErro);
	}	
	
	// Verifica se os parâmetros necessários foram informados
	if (!isset($_POST["nrdconta"]) || !isset($_POST["nrctrcrd"]) || !isset($_POST["inpessoa"])) {
		exibirErro('error','Par&acirc;metros incorretos.','Alerta - Aimaro',$funcaoAposErro);
	}

	$nrdconta = $_POST["nrdconta"];
	$nrctrcrd = $_POST["nrctrcrd"];
	$inpessoa = $_POST["inpessoa"];

	// Verifica se número da conta é um inteiro válido
	if (!validaInteiro($nrdconta)) exibirErro('error','Conta/dv inv&aacute;lida.','Alerta - Aimaro',$funcaoAposErro);

	// Verifica se número do contrato é um inteiro válido
	if (!validaInteiro($nrctrcrd)) exibirErro('error','N&uacute;mero do contrato inv&aacute;lido.','Alerta - Aimaro',$funcaoAposErro);

	// Monta o xml de requisição
	$xmlSetCartao  = "";
	$xmlSetCartao .= "<Root>";
	$xmlSetCartao .= "	<Cabecalho>";
	$xmlSetCartao .= "		<Bo>b1wgen0028.p</Bo>";
	$xmlSetCartao .= "		<Proc>valida_carregamento_entrega2via_cartao</Proc>";
	$xmlSetCartao .= "	</Cabecalho>";
	$xmlSetCartao .= "	<Dados>";
	$xmlSetCartao .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlSetCartao .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xmlSetCartao .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xmlSetCartao .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xmlSetCartao .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xmlSetCartao .= "		<nrctrcrd>".$nrctrcrd."</nrctrcrd>";
	$xmlSetCartao .= "		<dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
	$xmlSetCartao .= "	</Dados>";
	$xmlSetCartao .= "</Root>";
	
	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlSetCartao);

	// Cria objeto para classe de tratamento de XML
	$xmlObjCartao = getObjectXML($xmlResult);

	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjCartao->roottag->tags[0]->name) == "ERRO") {
		exibirErro('error',$xmlObjCartao->roottag->tags[0]->tags[0]->tags[4]->cdata,'Alerta - Aimaro',$funcaoAposErro);	
	}
	
	$dados = $xmlObjCartao->roottag->tags[0]->tags;
	
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

<script type="text/javascript">
	var funcaoVoltar = "voltaDiv(1,2,4);blockBackground(parseInt($('#divRotina').css('z-index')));";
</script>
<form action="" class="formulario" name="frmEntrega2via" id="frmEntrega2via">
	<div id="divDadosEntrega">
		<fieldset>
			<legend><? echo utf8ToHtml('Entregar Segunda Via de Cartão') ?></legend>
			
			<? if ($inpessoa == "2") { ?>
				<label for="repsolic"><? echo utf8ToHtml('Representante Solicitante:') ?></label>
				<select name="repsolic" id="repsolic">
					<? for ($i = 0; $i < count($repsolic); $i++) { ?>
					<option value="<? echo $cpfrepre[$i]; ?>"<? if ($i == 0) echo " selected"; ?>><? echo $repsolic[$i]; ?></option>
					<? } ?>
				</select>
				<br />
			<?}?>
			
			<label for="cfseqca"><? echo utf8ToHtml('Número do novo cartão:') ?></label>
			<input type="text" name="cfseqca" id="cfseqca" value="" />
			<br />
			
			<label for="dtvalida"><? echo utf8ToHtml('Nova data de validade:') ?></label>
			<input type="text" id="dtvalida" name="dtvalida" />
			<br />
			
			<label for="flgimpnp"><? echo utf8ToHtml('Promissória:') ?></label>
			<select name="flgimpnp" id="flgimpnp" >
				<option value="yes" selected>Imprime</option>
			</select>
		</fieldset>
		
		<div id="divBotoes" >
			<input type="image" src="<? echo $UrlImagens; ?>botoes/voltar.gif"     onClick="voltaDiv(1,2,4);return false;">
			<input type="image" src="<? echo $UrlImagens; ?>botoes/prosseguir.gif" onClick="validaMostraavaisEntrega2viaCartao();return false;">
		</div>
	</div>
	
	<div id="divDadosAvalistasEntrega" class="condensado">
		<? 
			// ALTERAÇÃO 001: Substituido formulário antigo pelo include				
			include('../../../includes/avalistas/form_avalista.php'); 
		?>
		<div id="divBotoes">
			<input type="image" src="<? echo $UrlImagens; ?>botoes/cancelar.gif" onClick="showConfirmacao('Deseja cancelar a entrega de segunda via do cr&eacute;dito do cart&atilde;o?','Confirma&ccedil;&atilde;o - Aimaro',funcaoVoltar,'blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))','sim.gif','nao.gif');return false;">
			<input type="image" id="btSalvar" src="<? echo $UrlImagens; ?>botoes/concluir.gif" onClick="validarAvalistas(2);return false;">
		</div>
	</div>
</form>
<script type="text/javascript">
	// Mostra o div da Tela da opção
	$("#divOpcoesDaOpcao3").css("display","block");
		
	controlaLayout('frmEntrega2via');
	
	layoutPadrao();
	hideMsgAguardo();
	bloqueiaFundo(divRotina);
</script>