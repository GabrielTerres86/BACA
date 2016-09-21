<? 
/*!
 * FONTE        : tab_depositos.php
 * CRIAÇÃO      : Rogérius Militao - (DB1)
 * DATA CRIAÇÃO : 26/10/2011 
 * OBJETIVO     : Tabela que apresenta os depositos
 * --------------
 * ALTERAÇÕES   :  17/09/2012 - Implementação do novo layout (David Kruger).
 *                27/05/2014 - Incluido a informação de espécie de deposito e
							   relatório do mesmo. (Andre Santos - SUPERO)
 * --------------
 */
 
?>

<?php
	/*
 	session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');	
	require_once('../../class/xmlfile.php');
	isPostMethod();	
	*/
?>

<form id="frmDepositos" name="frmDepositos" class="formulario" onSubmit="return false;">

	<fieldset>
	<legend><? echo utf8ToHtml('Depositos'); ?></legend>

	<div class="divRegistros" >	
		<table class="tituloRegistros">
			<thead>
				<tr>
					<th><? echo utf8ToHtml('Data'); ?></th>
					<th><? echo utf8ToHtml('Hora');  ?></th>
					<th><? echo utf8ToHtml('Conta Fav');  ?></th>
					<th><? echo utf8ToHtml('Envelope');  ?></th>
					<th><? echo utf8ToHtml('ESP');  ?></th>
					<th><? echo utf8ToHtml('Valor Inf');  ?></th>
					<th><? echo utf8ToHtml('Valor Comp');  ?></th>
					<th><? echo utf8ToHtml('Situação');  ?></th>
				</tr>
			</thead>
			<tbody>
				<? 
				foreach( $envelope as $r ) { 
								
				?>
					<tr>
						<td><span><? echo dataParaTimestamp(getByTagName($r->tags,'dtmvtolt')); ?></span>
							      <? echo getByTagName($r->tags,'dtmvtolt'); ?>
 
						</td>
						<td><span><? echo getByTagName($r->tags,'hrtransa'); ?></span>
							      <? echo getByTagName($r->tags,'hrtransa'); ?>
						</td>
						<td><span><? echo getByTagName($r->tags,'nrdconta'); ?></span>
							      <? echo getByTagName($r->tags,'nrdconta'); ?>
						</td>
						<td><span><? echo getByTagName($r->tags,'nrseqenv'); ?></span>
							      <? echo getByTagName($r->tags,'nrseqenv'); ?>
						</td>
						<td><span><? echo getByTagName($r->tags,'dsespeci'); ?></span>
							      <? echo getByTagName($r->tags,'dsespeci'); ?>
						</td>
						<td><span><? echo getByTagName($r->tags,'vlenvinf'); ?></span>
								  <? echo getByTagName($r->tags,'vlenvinf'); ?>
						</td>
						<td><span><? echo getByTagName($r->tags,'vlenvcmp'); ?></span>
								  <? echo getByTagName($r->tags,'vlenvcmp'); ?>
						</td>
						<td><span><? echo getByTagName($r->tags,'dssitenv'); ?></span>
								  <? echo getByTagName($r->tags,'dssitenv'); ?>
						</td>
					</tr>
			<? } ?>	
			</tbody>
		</table>
	</div>	
	
	</fieldset>
</form>

<div id="divBotoes" style="margin-bottom:8px">
    <a href="#" class="botao" id="btVoltar" onclick="fechaOpcao(); return false;">Voltar</a>     
</div>

<script> 
	
	$(document).ready(function(){
		highlightObjFocus($('#frmDepositos'));
	});

</script>