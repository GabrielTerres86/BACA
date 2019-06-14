<? 
/*!
 * FONTE        : form_opcao_q.php
 * CRIAÇÃO      : Rogérius Militao - (DB1)
 * DATA CRIAÇÃO : 18/01/2012 
 * OBJETIVO     : Formulario que apresenta a opcao Q da tela DESCTO
 * --------------
 * ALTERAÇÕES   :
 * --------------
 */
 
?>

<?php
 	session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');	
	require_once('../../class/xmlfile.php');
	isPostMethod();		
	
	include('form_cabecalho.php');
	
?>

<form id="frmOpcao" class="formulario" onSubmit="return false;">

	<?php include('form_associado.php'); ?>

	<fieldset>
	<legend> Cheques </legend>

	<div class="divRegistros">	
		<table class="tituloRegistros">
			<thead>
				<tr>
					<th><? echo utf8ToHtml('Desctdo em'); ?></th>
					<th><? echo utf8ToHtml('Liberar em'); ?></th>
					<th><? echo utf8ToHtml('Desctdo por');  ?></th>
					<th></th>
					<th><? echo utf8ToHtml('Cheque');  ?></th>
					<th><? echo utf8ToHtml('Valor');  ?></th>
				</tr>
			</thead>
			<tbody>
				<?
				foreach ( $registro as $r ) { 
				?>
					<tr>
						<td><span><? echo dataParaTimestamp(getByTagName($r->tags,'dtmvtolt')); ?></span>
							      <? echo getByTagName($r->tags,'dtmvtolt'); ?>
						</td>
						<td><span><? echo dataParaTimestamp(getByTagName($r->tags,'dtlibera')); ?></span>
							      <? echo getByTagName($r->tags,'dtlibera'); ?>
						</td>
						<td><span><? echo getByTagName($r->tags,'nrdconta'); ?></span>
							      <? echo getByTagName($r->tags,'nrdconta'); ?>
						</td>
						<td><span><? echo getByTagName($r->tags,'nmprimtl'); ?></span>
							      <? echo stringTabela(getByTagName($r->tags,'nmprimtl'),25,'maiuscula'); ?>
						</td>
						<td><span><? echo getByTagName($r->tags,'nrcheque'); ?></span>
							      <? echo getByTagName($r->tags,'nrcheque'); ?>
						</td>
						<td><span><? echo getByTagName($r->tags,'vlcheque'); ?></span>
							      <? echo formataMoeda(getByTagName($r->tags,'vlcheque')); ?>
						</td>
					</tr>
			<? } ?>	
			</tbody>
		</table>
	</div>
	</fieldset>

	<fieldset>
		<legend> Total </legend>	
		
		<label for="vldescto">Total Descontado:</label>
		<input type="text" id="vldescto" name="vldescto" value="<?php echo formataMoeda($vldescto) ?>"/>
		
	</fieldset>		
	
</form>

<div id="divBotoes" style="padding-bottom:10px">
	<a href="#" class="botao" id="btVoltar" onclick="btnVoltar(); return false;">Voltar</a>
	<a href="#" class="botao" onclick="btnContinuar(); return false;" >Prosseguir</a>
</div>



