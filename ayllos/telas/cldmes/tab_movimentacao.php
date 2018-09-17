<? 
/*!
 * FONTE        : tab_movimentacao.php
 * CRIAÇÃO      : Cristian Filipe
 * DATA CRIAÇÃO : 15/10/2013 								Última alteração: 24/11/2014
 * OBJETIVO     : Tabela que apresenta as movimentações
 * --------------
 * ALTERAÇÕES   : 24/11/2014 - Ajustes para liberação (Adriano).
 * --------------
 */	
 
 	session_start();	
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');	
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();
?>

<div id="divTabMovimentacao">
	<div class="divRegistros">	
		<table>
			<thead>
				<tr>
					<th><? echo utf8ToHtml('PA'); ?></th>
					<th><? echo utf8ToHtml('Conta/dv');  ?></th>
					<th><? echo utf8ToHtml('Nome');  ?></th>
					<th><? echo utf8ToHtml('Rendimento');  ?></th>
					<th><? echo utf8ToHtml('Credito');  ?></th>
					<th><? echo utf8ToHtml('Credito/Renda');  ?></th>
				</tr>
			</thead>
			<tbody>
				<?
				foreach($registros as $values){  ?>
					<tr>
						<td>
							<span><? echo getByTagName($values->tags, 'cdagenci'); ?></span>
							<? echo getByTagName($values->tags, 'cdagenci'); ?>
							<input type="hidden" id="hcdagenci" name="hcdagenci" value="<? echo getByTagName($values->tags, 'cdagenci'); ?>" />								  								  
						</td>
						<td>
							<span><? echo getByTagName($values->tags, 'nrdconta'); ?></span>
							<? echo mascara(getByTagName($values->tags, 'nrdconta'),'###.###-#'); ?>
							<input type="hidden" id="hnrdconta" name="hnrdconta" value="<? echo getByTagName($values->tags, 'nrdconta'); ?>" />	
						</td>
						<td>
							<span><? echo getByTagName($values->tags, 'nmprimtl'); ?></span>
							<? echo getByTagName($values->tags, 'nmprimtl'); ?>
							<input type="hidden" id="hnmprimtl" name="hnmprimtl" value="<? echo getByTagName($values->tags, 'nmprimtl'); ?>" />	
						</td>
						<td>
							<span><? echo converteFloat(getByTagName($values->tags, 'vlrendim') ,'MOEDA'); ?></span>
							<? echo formataMoeda(getByTagName($values->tags, 'vlrendim')) ;?>
							<input type="hidden" id="hvlrendim" name="hvlrendim" value="<? echo getByTagName($values->tags, 'vlrendim'); ?>" />	
						</td>
						<td>
							<span><? echo converteFloat(getByTagName($values->tags, 'vltotcre') ,'MOEDA'); ?></span>
							<? echo formataMoeda(getByTagName($values->tags, 'vltotcre')) ;?>
							<input type="hidden" id="hvltotcre" name="hvltotcre" value="<? echo getByTagName($values->tags, 'vltotcre'); ?>" />	
						</td>

						<td>
							<span><? echo getByTagName($values->tags, 'qtultren'); ?></span>
							<input type="hidden" id="hqtultren" name="hqtultren" value="<? echo getByTagName($values->tags, 'qtultren'); ?>" />	
							<? echo getByTagName($values->tags, 'qtultren'); ?>
						</td>
					</tr>
			<? } ?>	
			</tbody>
		</table>
	</div>	
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
					// Se a paginação não está na última página, exibe botão proximo
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

<script type="text/javascript">

	$('a.paginacaoAnt').unbind('click').bind('click', function() {
		manterRotina(<? echo "'".($nriniseq - $nrregist)."','".$nrregist."'"; ?>);
	});
	$('a.paginacaoProx').unbind('click').bind('click', function() {
		manterRotina(<? echo "'".($nriniseq + $nrregist)."','".$nrregist."'"; ?>);
	});	
	
	$('#divPesquisaRodape','#divTela').formataRodapePesquisa();

</script>
