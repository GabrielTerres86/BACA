<? 
/*!
 * FONTE        : tab_operacao.php
 * CRIAÇÃO      : Rogérius Militao - (DB1)
 * DATA CRIAÇÃO : 26/10/2011 
 * OBJETIVO     : Tabela que apresenta a consulta OPERAÇÃO
 * --------------
 * ALTERAÇÕES   : 17/09/2012 - Implementação do novo layout (David Kruger).
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

<form id="frmOperacao" name="frmOperacao" class="formulario" onSubmit="return false;">

	<fieldset>
	<legend><? echo utf8ToHtml('Operação do Terminal de Saques em '. $dtlimite); ?></legend>

	<div class="divRegistros">	
		<table class="tituloRegistros">
			<thead>
				<tr>
					<th><? echo utf8ToHtml('Data'); ?></th>
					<th><? echo utf8ToHtml('Horario');  ?></th>
					<th><? echo utf8ToHtml('Operador');  ?></th>
					<th><? echo utf8ToHtml('Tarefa');  ?></th>
					<th><? echo utf8ToHtml('Valor');  ?></th>
				</tr>
			</thead>
			<tbody>
				<? 
				foreach( $registro as $r ) { 
								
				?>
					<tr>
						<td><span><? echo dataParaTimestamp(getByTagName($r->tags,'dttransa')); ?></span>
							      <? echo getByTagName($r->tags,'dttransa'); ?>
 
						</td>
						<td><span><? echo getByTagName($r->tags,'hrtransa'); ?></span>
							      <? echo getByTagName($r->tags,'hrtransa'); ?>
						</td>
						<td><span><? echo getByTagName($r->tags,'dsoperad'); ?></span>
							      <? echo stringTabela(getByTagName($r->tags,'dsoperad'),30,'maiuscula'); ?>
						</td>
						<td><span><? echo getByTagName($r->tags,'dstarefa'); ?></span>
							      <? echo stringTabela(getByTagName($r->tags,'dstarefa'),16,'maiuscula'); ?>
						</td>
						<td><span><? echo converteFloat(getByTagName($r->tags,'vllanmto')); ?></span>
								  <? echo formataMoeda(getByTagName($r->tags,'vllanmto')); ?>
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
		highlightObjFocus($('#frmOperacao'));
	});

</script>