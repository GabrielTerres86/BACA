<? 
/*!
 * FONTE        : tab_extcap.php
 * CRIAÇÃO      : Rogérius Militao - (DB1)
 * DATA CRIAÇÃO : 25/08/2011 
 * OBJETIVO     : Tabela que apresenta a consulta EXTCAP
 * --------------
 * ALTERAÇÕES   : 26/10/2012 - Alteração layout tela, alterado input image por botão (Daniel).
 *				  05/06/2013 - Incluir label vlbloque no form frmExtcapSaldo (Lucas R.)
 *                05/09/2013 - Alteração da sigla PAC para PA (Carlos)
 */
 
?>

<?php
 	session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');	
	require_once('../../class/xmlfile.php');
	isPostMethod();		
?>

<div id="tabExtcap">
	<div class="divRegistros">	
		<table class="tituloRegistros">
			<thead>
				<tr>
					<th><? echo utf8ToHtml('Data'); ?></th>
					<th><? echo utf8ToHtml('PA'); ?></th>
					<th><? echo utf8ToHtml('Bcx');  ?></th>
					<th><? echo utf8ToHtml('Lote');  ?></th>
					<th><? echo utf8ToHtml('Historico');  ?></th>
					<th></th>
					<th><? echo utf8ToHtml('Documento');  ?></th>
					<th><? echo utf8ToHtml('Contrato');  ?></th>
					<th><? echo utf8ToHtml('Valor');  ?></th>
				</tr>
			</thead>
			<tbody>
				<? 
				foreach ( $extrato as $e ) { 
				?>
					<tr>
						<td><span><? echo dataParaTimestamp(getByTagName($e->tags,'dtmvtolt')); ?></span>
							      <? echo getByTagName($e->tags,'dtmvtolt'); ?>
						</td>
						<td><span><? echo getByTagName($e->tags,'cdagenci'); ?></span>
							      <? echo getByTagName($e->tags,'cdagenci'); ?>
						</td>
						<td><span><? echo getByTagName($e->tags,'cdbccxlt'); ?></span>
							      <? echo getByTagName($e->tags,'cdbccxlt'); ?>
						</td>
						<td><span><? echo getByTagName($e->tags,'nrdolote'); ?></span>
							      <? echo mascara(getByTagName($e->tags,'nrdolote'),'###.###'); ?>
						</td>
						<td><span><? echo getByTagName($e->tags,'dshistor'); ?></span>
							      <? echo stringTabela(getByTagName($e->tags,'dshistor'), 20, 'maiuscula'); ?>
						</td>
						<td><span><? echo getByTagName($e->tags,'indebcre'); ?></span>
							      <? echo getByTagName($e->tags,'indebcre'); ?>
						</td>
						<td><span><? echo getByTagName($e->tags,'nrdocmto'); ?></span>
							      <? echo mascara(getByTagName($e->tags,'nrdocmto'),'########.###'); ?>
						</td>
						<td><span><? echo getByTagName($e->tags,'nrctrpla'); ?></span>
							      <? echo mascara(getByTagName($e->tags,'nrctrpla'),'###.###'); ?>
						</td>
						<td><span><? echo getByTagName($e->tags,'vllanmto'); ?></span>
							      <? echo formataMoeda(getByTagName($e->tags,'vllanmto')); ?>
						</td>
					</tr>
			<? } ?>	
			</tbody>
		</table>
	</div>	
</div>


<form name="frmExtcapSaldo" id="frmExtcapSaldo" class="formulario" onSubmit="return false;" >	

	<fieldset>
	
		<legend> Saldo </legend>	

		<label for="vlbloque"><? echo utf8ToHtml('Valor Bloq. Judicial:') ?></label>
		<input name="vlbloque" id="vlbloque" type="text" value="<? echo formataMoeda($vlbloque); ?>" />
		
		<label for="vlstotal"><? echo utf8ToHtml('Saldo:') ?></label>
		<input name="vlstotal" id="vlstotal" type="text" value="<? echo formataMoeda($vlsldtot); ?>" />
		
	</fieldset>		

</form>

<div id="divPesquisaRodape" class="divPesquisaRodape">
	<table>	
		<tr>
			<td>
				<?
					
					//
					if (isset($qtregist) and $qtregist == 0) $nriniseq = 0;
					
					// Se a paginação não está na primeira, exibe botão voltar
					if ($nriniseq > 1) { 
						?> <a class='paginacaoAnt'><<< Anterior</a> <? 
					} else {
						?> &nbsp; <?
					}
				?>
			</td>
			<td>
				<?
					if (isset($nriniseq)) { 
						?> Exibindo <? echo $nriniseq; ?> at&eacute; <? if (($nriniseq + $nrregist) > $qtregist) { echo $qtregist; } else { echo ($nriniseq + $nrregist - 1); } ?> de <? echo $qtregist; ?><?
					}
				?>
			</td>
			<td>
				<?
					// Se a paginação não está na &uacute;ltima página, exibe botão proximo
					if ($qtregist > ($nriniseq + $nrregist - 1)) {
						?> <a class='paginacaoProx'>Pr&oacute;ximo >>></a> <?
					} else {
						?> &nbsp; <?
					}
				?>			
			</td>
		</tr>
	</table>
</div>

<div id="divBotoes" style='margin-bottom :10px'>
	<a href="#" class="botao" id="btVoltar" onclick="btnVoltar(); return false;" >Voltar</a>
	<a href="#" class="botao" id="btSalvar" onclick="btnContinuar(); return false;" >Prosseguir</a>
</div>

<script type="text/javascript">

	$('a.paginacaoAnt').unbind('click').bind('click', function() {
		controlaOperacao('extrato', <? echo "'".($nriniseq - $nrregist)."','".$nrregist."'"; ?>);
	});
	$('a.paginacaoProx').unbind('click').bind('click', function() {
		controlaOperacao('extrato', <? echo "'".($nriniseq + $nrregist)."','".$nrregist."'"; ?>);
	});	
	
	$('#divPesquisaRodape','#divTela').formataRodapePesquisa();

</script>