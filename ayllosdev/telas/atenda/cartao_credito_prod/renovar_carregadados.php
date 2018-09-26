<?
/*!
 * FONTE        : renovar_carregadados.php
 * CRIAÇÃO      : Guilherme
 * DATA CRIAÇÃO : Abril/2008
 * OBJETIVO     : Mostrar opção renovar do cartão de crédito
 * --------------
 * ALTERAÇÕES   :
 * --------------
 * 000: [14/05/2009] David     (CECRED) : Tirar validação de data para parâmetro "dtvalida"   
 * 000: [08/11/2010] David     (CECRED) : Adaptações para Cartão PJ
 * 001: [05/05/2011] Rodolpho     (DB1) : Adaptações para o formulário genérico de avalistas
 * 001: [08/07/2011] Gabriel      (DB1) : Alterado para layout padrão
 * 002: [26/08/2015] James				: Remover o form da impressao. (James)
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
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"R")) <> "") {
		exibirErro('error',$msgError,'Alerta - Aimaro',$funcaoAposErro);
	}			
	
	// Verifica se os parâmetros necessários foram informados
	if (!isset($_POST["nrdconta"]) || !isset($_POST["nrctrcrd"]) || !isset($_POST["nrcrcard"]) || !isset($_POST["inpessoa"])) {
		exibirErro('error','Par&acirc;metros incorretos.','Alerta - Aimaro',$funcaoAposErro);
	}

	$nrdconta = $_POST["nrdconta"];
	$nrctrcrd = $_POST["nrctrcrd"];
	$nrcrcard = $_POST["nrcrcard"];
	$inpessoa = $_POST["inpessoa"];

	// Verifica se número da conta é um inteiro válido
	if (!validaInteiro($nrdconta)) exibirErro('error','Conta/dv inv&aacute;lida.','Alerta - Aimaro',$funcaoAposErro);
	
	// Verifica se número do contrato é um inteiro válido
	if (!validaInteiro($nrctrcrd)) exibirErro('error','N&uacute;mero do contrato inv&aacute;lido.','Alerta - Aimaro',$funcaoAposErro);
	
	// Verifica se tipo de pessoa é um inteiro válido
	if (!validaInteiro($inpessoa)) exibirErro('error','Tipo de pessoa inv&aacute;lido.','Alerta - Aimaro',$funcaoAposErro);
	
	// Monta o xml de requisição
	$xmlSetRenovar  = "";
	$xmlSetRenovar .= "<Root>";
	$xmlSetRenovar .= "	<Cabecalho>";
	$xmlSetRenovar .= "		<Bo>b1wgen0028.p</Bo>";
	$xmlSetRenovar .= "		<Proc>carrega_dados_renovacao</Proc>";
	$xmlSetRenovar .= "	</Cabecalho>";
	$xmlSetRenovar .= "	<Dados>";
	$xmlSetRenovar .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlSetRenovar .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xmlSetRenovar .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xmlSetRenovar .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xmlSetRenovar .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xmlSetRenovar .= "		<nrctrcrd>".$nrctrcrd."</nrctrcrd>";
	$xmlSetRenovar .= "		<dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
	$xmlSetRenovar .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";
	$xmlSetRenovar .= "		<idseqttl>1</idseqttl>";
	$xmlSetRenovar .= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
	$xmlSetRenovar .= "	</Dados>";
	$xmlSetRenovar .= "</Root>";
	
	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlSetRenovar);

	// Cria objeto para classe de tratamento de XML
	$xmlObjRenovar = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjRenovar->roottag->tags[0]->name) == "ERRO") {
		exibirErro('error',$xmlObjRenovar->roottag->tags[0]->tags[0]->tags[4]->cdata,'Alerta - Aimaro',$funcaoAposErro);
	}	

	$dtvalatu = $xmlObjRenovar->roottag->tags[0]->tags[0]->tags[1]->cdata;
	$dtaltval = $xmlObjRenovar->roottag->tags[0]->tags[0]->tags[2]->cdata;
?>
<?/**/?>
<form action="" class="formulario" name="frmNovaValidade" id="frmNovaValidade">
	<div id="divDadosNovaValidade">
		<fieldset>
			<legend><? echo utf8ToHtml('Renovar') ?></legend>
			
			<label for="nrcrcard"><? echo utf8ToHtml('Número do Cartão:') ?></label>
			<input type="text" name="nrcrcard" id="nrcrcard"  value="<? echo $nrcrcard ?>" />
			<br />
			
			<label for="dtvalatu"><? echo utf8ToHtml('Validade Atual:') ?></label>
			<input type="text" name="dtvalatu" id="dtvalatu" value="<? echo $dtvalatu; ?>" />
						
			<label for="dtaltval"><? echo utf8ToHtml('Em:') ?></label>
			<input type="text" name="dtaltval" id="dtaltval" value="<? echo $dtaltval; ?>" />
			<br />
			
			<label for="dtvalida"><? echo utf8ToHtml('Nova Validade:') ?></label>
			<input type="text" name="dtvalida" id="dtvalida" />
			<br />
			
			<? if ($inpessoa == "1") { ?>
				<label for="flgimpnp"><? echo utf8ToHtml('Promissória:') ?></label>
				<select name="flgimpnp" id="flgimpnp">
						<option value="yes" selected>Imprime</option>
				</select>
				<br />
			<? } ?>
			
		</fieldset>
		
		<div id="divBotoes" >
			<input type="image" src="<? echo $UrlImagens; ?>botoes/voltar.gif" onClick="voltaDiv(0,1,4);return false;" />
			<input type="image" src="<? echo $UrlImagens; ?>botoes/prosseguir.gif" onClick="validaDadosRenovacao();return false;" />
		</div>
		
	</div>
	
	<div id="divDadosAvalistasNovaValidade" class="condensado">
		<? 
			// ALTERAÇÃO 001: Substituido formulário antigo pelo include				
			include('../../../includes/avalistas/form_avalista.php'); 
		?>
		<div id="divBotoes">
			<input type="image" id="btVoltar" src="<? echo $UrlImagens; ?>botoes/voltar.gif" onClick="voltaDiv(0,1,4);return false;">
			<input type="image" src="<? echo $UrlImagens; ?>botoes/cancelar.gif" onClick="showConfirmacao('Deseja cancelar a renova&ccedil;&atilde;o do cart&atilde;o de cr&eacute;dito?','Confirma&ccedil;&atilde;o - Aimaro',funcaoVoltar,'blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))','sim.gif','nao.gif');return false;">
			<input type="image" id="btSalvar" src="<? echo $UrlImagens; ?>botoes/concluir.gif" onClick="validarAvalistas(3);return false;">
		</div>
	</div>
	
</form>
<script type="text/javascript">
	// Mostra o div da Tela da opção
	$("#divOpcoesDaOpcao1").css("display","block");
	$("#divDadosNovaValidade").css("display","block");

	// Esconde as opções e avalistas
	$("#divConteudoCartoes").css("display","none");
	$("#divDadosAvalistasNovaValidade").css("display","none");
	
	controlaLayout('frmNovaValidade');
	
	layoutPadrao();
	hideMsgAguardo();
	bloqueiaFundo(divRotina);
</script>