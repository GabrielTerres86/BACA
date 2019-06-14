<? 
/*!
 * FONTE        : form_situacao_conta.php
 * CRIAÇÃO      : Jonata Cardoso - (RKAM)
 * DATA CRIAÇÃO : 04/02/2015
 * OBJETIVO     : Tela para selecionar as situacoes da conta
 * --------------
 * ALTERAÇÕES   : 26/04/2018 - Buscar situacoes da tabela. PRJ366 (Lombardi).
 */
 
?>

<?php
 	session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');	
	require_once('../../class/xmlfile.php');
	isPostMethod();	
	
	$nr_operacao =  substr($operacao,10,1) + 1;
	
	$situacoes = buscaSituacoesConta();
	
?>

<form id="frmSituacaoConta" name="frmSituacaoConta" class="formulario" onSubmit="return false;">

	<fieldset>
		<legend><? echo utf8ToHtml('Situaç&atilde;o Conta'); ?></legend>

		<br />
		<?php
		foreach ($situacoes as $situacao) { 
			$cdsituacao = getByTagName($situacao->tags,'cdsituacao');
			$dssituacao = getByTagName($situacao->tags,'dssituacao'); ?>
			<input type="checkbox" name="cdsitcta" id="<? echo $dssituacao ?>" value="<? echo $cdsituacao ?>" <? echo (in_array($cdsituacao,explode(";",$dssitcta))) ? "checked" : "" ?> >
			<label> <? echo $cdsituacao ?> - <? echo $dssituacao ?></label>
		<br />
		<br />
		<? }?>
	</fieldset>	

</form>

<div id="divBotoes" style="margin-bottom:8px">
    <a href="#" class="botao" id="btVoltar" onclick="fechaOpcao(); return false;">Voltar</a>  
	<? if ($cddopcao != 'C') { ?>		
		<a href="#" class="botao" id="btSalvar" onclick="atualizaSituacaoConta(); fechaOpcao(); return false;">Continuar</a>  
	<? } ?>
</div>

<script> 

	<? if ($cddopcao == 'C') { ?>		
		$("input","#frmSituacaoConta").desabilitaCampo();
	<? } ?>
	
	$(document).ready(function(){
		formataSituacaoConta();
	});

</script>