<?
/*!
 * FONTE        : extrato_parametros.php
 * CRIAÇÃO      : Guilherme/Supero
 * DATA CRIAÇÃO : Julho/2011
 * OBJETIVO     : Exibir o Extrato do cartão de crédito CECRED VISA
 * --------------
 * ALTERAÇÕES   :
 * --------------
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
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"T")) <> "") {
		exibirErro('error',$msgError,'Alerta - Aimaro',$funcaoAposErro);
	}

	// Verifica se os parâmetros necessários foram informados
	if (!isset($_POST["nrdconta"]) || !isset($_POST["nrcrcard"])) {
		exibirErro('error','Par&acirc;metros incorretos.','Alerta - Aimaro',$funcaoAposErro);
	}

	$nrdconta = $_POST["nrdconta"];
	$nrcrcard = str_replace(".", "", $_POST["nrcrcard"]);
	$anoAtual = explode("/",$glbvars["dtmvtolt"]);
	

	// Verifica se número da conta é um inteiro válido
	if (!validaInteiro($nrdconta)) exibirErro('error','Conta/dv inv&aacute;lida.','Alerta - Aimaro',$funcaoAposErro);
	
	// Verifica se número do Cartao é um inteiro válido
	if (!validaInteiro($nrcrcard)) exibirErro('error','N&uacute;mero do cart&atilde;o inv&aacute;lido. Cartao: '.$nrcrcard,'Alerta - Aimaro',$funcaoAposErro);
?>
<form action="" class="formulario" name="frmExtrato" id="frmExtrato">
	<div id="divExtrato">
		<fieldset>
			<legend><? echo utf8ToHtml('Extrato') ?></legend>

			<label for="nrcrcard"><? echo utf8ToHtml('Número do Cartão:') ?></label>
			<input type="text" name="nrcrcard" id="nrcrcard"  value="<? echo $nrcrcard ?>" />
			<br />

			<label for="dtextrat"><? echo utf8ToHtml('Período Extrato:') ?></label>
			<input type="text" name="dtextrat" id="dtextrat" />
			<br />

		</fieldset>
		
		<div id="divBotoes" >
			<input type="image" src="<? echo $UrlImagens; ?>botoes/voltar.gif" onClick="voltaDiv(0,1,4);return false;" />
			<input type="image" src="<? echo $UrlImagens; ?>botoes/prosseguir.gif" onClick="validaDadosExtrato(<?=$anoAtual[2]; ?>);return false;" />
		</div>
	</div>
	
</form>

<script type="text/javascript">
	// Mostra o div da Tela da opção
	$("#divOpcoesDaOpcao1").css("display","block");
	$("#divConteudoCartoes").css("display","none");
	
	$("#divExtrato").css("display","block");
	
	controlaLayout('frmExtrato');
	
	layoutPadrao();
	hideMsgAguardo();
	bloqueiaFundo(divRotina);
</script>