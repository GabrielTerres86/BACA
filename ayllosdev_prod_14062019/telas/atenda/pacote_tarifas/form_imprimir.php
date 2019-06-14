<?
/*!
 * FONTE        : form_imprimir.php
 * CRIAÇÃO      : Lombardi
 * DATA CRIAÇÃO : Abril/2016
 * OBJETIVO     : Tela do formulario de opções de impressão
 */	 

	session_start();
	require_once('../../../includes/config.php');
	require_once('../../../includes/funcoes.php');
	require_once('../../../includes/controla_secao.php');	
	require_once('../../../class/xmlfile.php');
	isPostMethod();
	
	$nrdconta 		 = (isset($_POST['nrdconta']))        ? $_POST['nrdconta']        : 0;
	$flgsituacao     = (isset($_POST['flgsituacao']))     ? $_POST['flgsituacao']     : 'cancelado';
	$cdreciprocidade = (isset($_POST['cdreciprocidade'])) ? $_POST['cdreciprocidade'] : 0;
	$dtadesao		 = (isset($_POST['dtadesao'])) ? $_POST['dtadesao'] : '';

	// margin: 4px 10px 4px 0px;
?>


<div id="divBotoes">
	<form name="frmAlteraDebito" id="frmAlteraDebito" class="formulario" >

		<a href="#" class="botao" style="padding: 2px; text-align: center;" id="btVoltar" onClick="acessaOpcaoAba(1,0,0);return false;">Voltar </a>
		<a href="#" class="botao" style="padding: 2px; text-align: center;" id="btTermoAdesao" onClick="imprimirAdesaoPct('<?echo $nrdconta;?>','<? echo $dtadesao;?>');return false;">Termo ades&atilde;o</a>
		<?if(strtolower($flgsituacao) ==  'cancelado') {?>
			<a href="#" class="botao" style="padding: 2px;" id="btTermoCancela" onClick="imprimirCancelaPct('<?echo $nrdconta;?>',0);return false;">Termo cancelamento</a>
		<?}
		if($cdreciprocidade > 0) {?>
			<a href="#" class="botao" style="padding: 2px;" id="btConfirmar" onClick="imprimirIR('<?echo $nrdconta;?>','<? echo $dtadesao;?>');return false;">Indicadores de reciprocidade</a>
			<a href="#" class="botao" style="padding: 2px;" id="btConfirmar" onClick="chamaTelaPeriodo('<?echo $nrdconta;?>','<? echo $dtadesao;?>');return false;">Extrato de reciprocidade</a>
		<?}?>	
	</form>
</div>
										
<script type="text/javascript">

// Esconde mensagem de aguardo
hideMsgAguardo();

// Bloqueia conteúdo que está átras do div da rotina
blockBackground(parseInt($("#divRotina").css("z-index")));
</script>