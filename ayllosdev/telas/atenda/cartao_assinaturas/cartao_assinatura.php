<? 
/*!
 * FONTE        : cartao_assinatura.php
 * CRIAÇÃO      : Jean Michel
 * DATA CRIAÇÃO : 23/07/2013
 * OBJETIVO     : Mostrar opcao de cartao_assinaturas
 *
 * 
 */
 ?>
 
 <?
	session_start();
	require_once("../../../includes/config.php");
	require_once("../../../includes/funcoes.php");
	require_once("../../../includes/controla_secao.php");	
	require_once("../../../class/xmlfile.php");
	isPostMethod();	
	
	// Verifica permissões de acessa a tela
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"@")) <> "") exibirErro('error',$msgError,'Alerta - Aimaro','fechaRotina(divRotina)');
	
	// Verifica se o número da conta foi informado
	if (!isset($_POST["nrdconta"]) || !isset($_POST["idseqttl"])) exibirErro('error','Par&acirc;metros incorretos.','Alerta - Aimaro','bloqueiaFundo(divRotina)');

	// Guardo os parâmetos do POST em variáveis	
	$nrdconta = $_POST["nrdconta"] == "" ?  0  : $_POST["nrdconta"];
	$idseqttl = $_POST["idseqttl"] == "" ?  0  : $_POST["idseqttl"];
	$inpessoa = $_POST["inpessoa"] == "" ?  0  : $_POST["inpessoa"];
	
	// Verifica se o número da conta e o titular são inteiros válidos
	if (!validaInteiro($nrdconta)) exibirErro('error','Conta/dv inv&aacute;lida.','Alerta - Aimaro','bloqueiaFundo(divRotina)');
	if (!validaInteiro($idseqttl)) exibirErro('error','Seq.Ttl n&atilde;o foi informada.','Alerta - Aimaro','bloqueiaFundo(divRotina)');
	
?>
<form name="frmImpressao" id="frmImpressao" ></form>

<div id="divImpCartaoAssinatura">
	<?php 
		if ($inpessoa == 1){
	?>
		<div id="titular">Imprimir Titular</div>
	<?php
		}
	?>	
	<div id="procurador">Imprimir Procurador</div>
	<div id="todos">Imprimir Todos</div>
	<div id="btVoltar" onClick="fechaRotina(divRotina);return false;">Cancelar</div>
	<input type="hidden" id="inpessoa" name="inpessoa" value="<?echo $inpessoa;?>" />
</div>


<script type="text/javascript">		
	var inpessoa = "<? echo $inpessoa; ?>";	
	controlaLayout(inpessoa);
	$(".tableImp").css("width","200px");
</script>