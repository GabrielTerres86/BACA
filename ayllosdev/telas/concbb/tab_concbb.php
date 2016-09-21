<? 
/*!
 * FONTE        : tab_concbb.php
 * CRIAÇÃO      : Rogérius Militao - (DB1)
 * DATA CRIAÇÃO : 22/08/2011 
 * OBJETIVO     : Tabela que apresenta a consulta CONCBB
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
?>

<div id="tabConcbb">
	<div class="divRegistros">	
		<table class="tituloRegistros">
			<thead>
				<tr>
					<th><? echo utf8ToHtml('PAC'); ?></th>
					<th><? echo utf8ToHtml('Caixa'); ?></th>
					<th><? echo utf8ToHtml('Operador'); ?></th>
					<th><? echo utf8ToHtml('Bc/Cx');  ?></th>
					<th><? echo utf8ToHtml('Lote');  ?></th>
					<th><? echo utf8ToHtml('Vlr.Doc');  ?></th>
					<th><? echo utf8ToHtml('Vlr.Pago');  ?></th>
					<th><? echo utf8ToHtml('Atv');  ?></th>
				</tr>
			</thead>
			<tbody>
				<?
				foreach ( $movimento as $r ) { 
				?>
					<tr>
						<td><span><? echo getByTagName($r->tags,'cdagenci'); ?></span>
							      <? echo getByTagName($r->tags,'cdagenci'); ?>
  								  <input type="hidden" id="cdbarras" name="cdbarras" value="<? echo getByTagName($r->tags,'cdbarras') ?>" />								  
  								  <input type="hidden" id="dsdocmto" name="dsdocmto" value="<? echo getByTagName($r->tags,'dsdocmto') ?>" />								  
  								  <input type="hidden" id="dsdocmc7" name="dsdocmc7" value="<? echo getByTagName($r->tags,'dsdocmc7') ?>" />								  
  								  <input type="hidden" id="valordoc" name="valordoc" value="<? echo formataMoeda(getByTagName($r->tags,'valordoc')) ?>" />								  
  								  <input type="hidden" id="vldescto" name="vldescto" value="<? echo formataMoeda(getByTagName($r->tags,'vldescto')) ?>" />								  
  								  <input type="hidden" id="valorpag" name="valorpag" value="<? echo formataMoeda(getByTagName($r->tags,'valorpag')) ?>" />								  
  								  <input type="hidden" id="dtvencto" name="dtvencto" value="<? echo getByTagName($r->tags,'dtvencto') ?>" />								  
  								  <input type="hidden" id="nrautdoc" name="nrautdoc" value="<? echo getByTagName($r->tags,'nrautdoc') ?>" />								  
  								  <input type="hidden" id="flgrgatv" name="flgrgatv" value="<? echo getByTagName($r->tags,'flgrgatv') == 'yes' ? 'Sim' : 'Nao' ?>" />								  
  								  <input type="hidden" id="registro" name="registro" value="<? echo getByTagName($r->tags,'nrdrowid') ?>" />								  

						</td>
						<td><span><? echo getByTagName($r->tags,'nrdcaixa'); ?></span>
							      <? echo getByTagName($r->tags,'nrdcaixa'); ?>
						</td>
						<td><span><? echo getByTagName($r->tags,'nmoperad'); ?></span>
							      <? echo getByTagName($r->tags,'nmoperad'); ?>
						</td>
						<td><span><? echo getByTagName($r->tags,'cdbccxlt'); ?></span>
							      <? echo getByTagName($r->tags,'cdbccxlt'); ?>
						</td>
						<td><span><? echo getByTagName($r->tags,'nrdolote'); ?></span>
							      <? echo getByTagName($r->tags,'nrdolote'); ?>
						</td>
						<td><span><? echo converteFloat(getByTagName($r->tags,'valordoc'),'MOEDA'); ?></span>
							      <? echo formataMoeda(getByTagName($r->tags,'valordoc')); ?>
						</td>
						<td><span><? echo converteFloat(getByTagName($r->tags,'valorpag'),'MOEDA'); ?></span>
							      <? echo formataMoeda(getByTagName($r->tags,'valorpag')); ?>
						</td>
						<td><span><? echo getByTagName($r->tags,'flgrgatv'); ?></span>
							      <? echo getByTagName($r->tags,'flgrgatv') == 'yes' ? 'Sim' : 'Nao'; ?>
						</td>
					</tr>
			<? } ?>	
			</tbody>
		</table>
	</div>	


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
	
	<div id="linha1">
	<ul class="complemento">
	<li><? echo utf8ToHtml('Cod. Barras:'); ?></li>
	<li id="cdbarras"></li>
	<li id="dsdocmto"></li>
	</ul>
	</div>

	<div id="linha2">
	<ul class="complemento">
	<li><? echo utf8ToHtml('CMC-7:'); ?></li>
	<li id="dsdocmc7"></li>
	<li><? echo utf8ToHtml('Valor:'); ?></li>
	<li id="valordoc"></li>
	</ul>
	</div>

	<div id="linha3">
	<ul class="complemento">
	<li><? echo utf8ToHtml('Valor Desconto:'); ?></li>
	<li id="vldescto"></li>
	<li><? echo utf8ToHtml('Valor Pago:'); ?></li>
	<li id="valorpag"></li>
	</ul>
	</div>

	<div id="linha4">
	<ul class="complemento">
	<li><? echo utf8ToHtml('Vencimento:'); ?></li>
	<li id="dtvencto"></li>
	<li><? echo utf8ToHtml('Autent.:'); ?></li>
	<li id="nrautdoc"></li>
	<li><? echo utf8ToHtml('Finalizado:'); ?></li>
	<li id="flgrgatv"></li>
	</ul>
	</div>
	
</div>

<script type="text/javascript">

	$('a.paginacaoAnt').unbind('click').bind('click', function() {
		controlaOperacao(<? echo "'".($nriniseq - $nrregist)."','".$nrregist."'"; ?>);
	});
	$('a.paginacaoProx').unbind('click').bind('click', function() {
		controlaOperacao(<? echo "'".($nriniseq + $nrregist)."','".$nrregist."'"; ?>);
	});	
	
	$('#divPesquisaRodape','#divTela').formataRodapePesquisa();

</script>