<? 
/*!
 * FONTE        : tab_gt0003.php
 * CRIAÇÃO      : Jéssica (DB1)
 * DATA CRIAÇÃO : 20/09/2013
 * OBJETIVO     : Tabela que apresenta os dados da tela GT0003
 *
 */	
session_start();
require_once('../../includes/config.php');
require_once('../../includes/funcoes.php');
require_once('../../includes/controla_secao.php');
require_once('../../class/xmlfile.php');
isPostMethod();
?>	
<form class="formulario">
	<fieldset>
		<legend>Arrecadações</legend>
		<div id="divRegistros" class="divRegistros">
			<table>
				<thead>
					<tr><th>Cp.</th>
						<th>Cnv</th>
						<th>Data</th>				
						<th>Credito</th>
						<th>Qtd.</th>
						<th>Arrec.</th>
						<th>Tarifa</th>
						<th>Pagar</th>
					</tr>			
				</thead>
				<tbody>
		<?
					foreach($registros as $i) {      
				
						// Recebo todos valores em variáveis
						$cdcooper	= getByTagName($i->tags,'cdcooper');
						$cdconven 	= getByTagName($i->tags,'cdconven');
						$dtmvtolt 	= getByTagName($i->tags,'dtmvtolt');				
						$dtcredit 	= getByTagName($i->tags,'dtcredit');
						$qtdoctos 	= getByTagName($i->tags,'qtdoctos');
						$vldoctos 	= getByTagName($i->tags,'vldoctos');
						$vltarifa 	= getByTagName($i->tags,'vltarifa');
						$vlapagar 	= getByTagName($i->tags,'vlapagar');
		?>
						<tr>
							<td><span><? echo $cdcooper ?></span>
								<? echo $cdcooper; ?>
								
								<input type="hidden" id="dtmvtolt" name="dtmvtolt" value="<? echo getByTagName($i->tags,'dtmvtolt') ?>" />
								<input type="hidden" id="cdcooper" name="cdcooper" value="<? echo getByTagName($i->tags,'cdcooper') ?>" />
								<input type="hidden" id="nmrescop" name="nmrescop" value="<? echo getByTagName($i->tags,'nmrescop') ?>" />
								<input type="hidden" id="cdcopdom" name="cdcopdom" value="<? echo getByTagName($i->tags,'cdcopdom') ?>" />
								<input type="hidden" id="cdconven" name="cdconven" value="<? echo getByTagName($i->tags,'cdconven') ?>" />
								<input type="hidden" id="nrcnvfbr" name="nrcnvfbr" value="<? echo getByTagName($i->tags,'nrcnvfbr') ?>" />
								<input type="hidden" id="nmempres" name="nmempres" value="<? echo getByTagName($i->tags,'nmempres') ?>" />
								<input type="hidden" id="dtcredit" name="dtcredit" value="<? echo getByTagName($i->tags,'dtcredit') ?>" />
								<input type="hidden" id="nmarquiv" name="nmarquiv" value="<? echo getByTagName($i->tags,'nmarquiv') ?>" />
								<input type="hidden" id="qtdoctos" name="qtdoctos" value="<? echo mascara( getByTagName($i->tags,'qtdoctos') , '###.###' ) ?>" />
								<input type="hidden" id="vldoctos" name="vldoctos" value="<? echo formataMoeda($vldoctos) ?>" />
								<input type="hidden" id="vltarifa" name="vltarifa" value="<? echo formataMoeda($vltarifa) ?>" />
								<input type="hidden" id="vlapagar" name="vlapagar" value="<? echo formataMoeda($vlapagar) ?>" />
								<input type="hidden" id="nrsequen" name="nrsequen" value="<? echo getByTagName($i->tags,'nrsequen') ?>" />
								<input type="hidden" id="totqtdoc" name="totqtdoc" value="<? echo getByTagName($i->tags,'totqtdoc') ?>" />
								<input type="hidden" id="totvldoc" name="totvldoc" value="<? echo getByTagName($i->tags,'totvldoc') ?>" />
								<input type="hidden" id="tottarif" name="tottarif" value="<? echo getByTagName($i->tags,'tottarif') ?>" />
								<input type="hidden" id="totpagar" name="totpagar" value="<? echo getByTagName($i->tags,'totpagar') ?>" />

							</td>
												
							<td> <? echo $cdconven ?> </td>
							<td> <? echo $dtmvtolt ?> </td>
							<td> <? echo $dtcredit ?> </td>
							
							<td> <span><? echo $qtdoctos ?> </span>
									<? echo mascara($qtdoctos,'###.###') ?></td>
												
							<td><span><? echo converteFloat($vldoctos,'MOEDA') ?></span>
									  <? echo formataMoeda($vldoctos); ?></td>
							
							<td><span><? echo converteFloat($vltarifa,'MOEDA') ?></span>
									  <? echo formataMoeda($vltarifa); ?></td>
									  
							<td><span><? echo converteFloat($vlapagar,'MOEDA') ?></span>
									  <? echo formataMoeda($vlapagar); ?></td>
															
																
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
	</fieldset>
</form>

<script type="text/javascript">
	$('a.paginacaoAnt').unbind('click').bind('click', function() {
		buscaGt0003( <? echo "'".($nriniseq - $nrregist)."'"; ?> , false);
	});
	$('a.paginacaoProx').unbind('click').bind('click', function() {
		buscaGt0003( <? echo "'".($nriniseq + $nrregist)."'"; ?> , false);
	});	
	$('#divPesquisaRodape').formataRodapePesquisa();
</script>
