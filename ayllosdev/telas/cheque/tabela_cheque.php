<? 
/*!
 * FONTE        : tabela_cheque.php
 * CRIAÇÃO      : Rodolpho Telmo (DB1)
 * DATA CRIAÇÃO : 13/05/2011
 * OBJETIVO     : Tabela que apresenda os cheques da conta informada na tela CHEQUE
 *
 * ALTERAÇÕES   : 04/09/2012 - Inclusao de novos campos na tabela_cheque (Tiago).
 *                18/12/2012 - Retirar o campo Conta da TIC (Ze).
 *				  30/06/2014 - Adicionado campo cdageaco nos detalhes do cheque. (Reinert)
 *				  16/09/2014 - Inclusão da coluna Age - cdagechq na tela. (Vanessa)
 * 				  30/05/2019 - Adicionado campo vlacerto P565 (Jackson Barcellos AMcom)
 */	
?>
<? $search  = array('.','-'); ?>
<div class="divRegistros">
	<table>
		<thead>
			<tr><th>Bco</th>
				<th>Age</th>
				<th>Cheque</th>
				<th>Sq</th>
				<th>Tp</th>
				<th>Fm</th>
				<th><? echo utf8ToHtml('Observação') ?></th>
				<th>Emitido</th>
				<th>Retirado</th>
				<th>Compens.</th>
				<th>Conta ITG</th>
			</tr>			
		</thead>
		<tbody>
			<?
			foreach($registros as $cheque) {
				// Recebo todos valores em variáveis
				$cdbanchq	= getByTagName($cheque->tags,'cdbanchq');
				$cdagechq	= getByTagName($cheque->tags,'cdagechq');
				$nrcheque	= getByTagName($cheque->tags,'nrcheque');
				$nrseqems 	= getByTagName($cheque->tags,'nrseqems');
				$tpcheque	= getByTagName($cheque->tags,'tpcheque');
				$tpforchq	= getByTagName($cheque->tags,'tpforchq');
				$dsobserv 	= getByTagName($cheque->tags,'dsobserv');
				$dtemschq 	= getByTagName($cheque->tags,'dtemschq');
				$dtretchq 	= getByTagName($cheque->tags,'dtretchq');
				$dtliqchq  	= getByTagName($cheque->tags,'dtliqchq');
				$nrdctitg 	= getByTagName($cheque->tags,'nrdctitg');
				$nrpedido 	= getByTagName($cheque->tags,'nrpedido');
				$dtsolped 	= getByTagName($cheque->tags,'dtsolped');
				$dtrecped 	= getByTagName($cheque->tags,'dtrecped');
				$dsdocmc7 	= getByTagName($cheque->tags,'dsdocmc7');
				$dscordem 	= getByTagName($cheque->tags,'dscordem');
				$dscorde1 	= getByTagName($cheque->tags,'dscorde1');
				$dtmvtolt 	= getByTagName($cheque->tags,'dtmvtolt');
				$vlcheque 	= getByTagName($cheque->tags,'vlcheque');
				$vldacpmf 	= getByTagName($cheque->tags,'vldacpmf');
				$cdtpdchq 	= getByTagName($cheque->tags,'cdtpdchq');
				$cdbandep 	= getByTagName($cheque->tags,'cdbandep');
				$cdagedep 	= getByTagName($cheque->tags,'cdagedep');
				$nrctadep 	= getByTagName($cheque->tags,'nrctadep');
				$flgsubtd 	= getByTagName($cheque->tags,'flgsubtd');
				$nrdigchq 	= getByTagName($cheque->tags,'nrdigchq'); 
				
				$cdbantic	= getByTagName($cheque->tags,'cdbantic');
				$cdagetic	= getByTagName($cheque->tags,'cdagetic');
				$nrctatic	= getByTagName($cheque->tags,'nrctatic');
				$dtlibtic	= getByTagName($cheque->tags,'dtlibtic');
				$cdageaco	= getByTagName($cheque->tags,'cdageaco');
				//P565
				$vlacerto	= getByTagName($cheque->tags,'vlacerto');
				
			?>			
				<tr <? if($flgsubtd == 'yes') echo 'class="sublinhado"'; ?>>
					<td><input type="hidden" id="nrpedido" value="<? echo $nrpedido ?>" />
						<input type="hidden" id="dtsolped" value="<? echo $dtsolped ?>" />
						<input type="hidden" id="dtrecped" value="<? echo $dtrecped ?>" />
						<input type="hidden" id="dsdocmc7" value="<? echo $dsdocmc7 ?>" />
						<input type="hidden" id="dscordem" value="<? echo $dscordem ?>" />
						<input type="hidden" id="dtmvtolt" value="<? echo $dtmvtolt ?>" />
						<input type="hidden" id="dsobserv" value="<? echo $dsobserv ?>" />
						<input type="hidden" id="vlcheque" value="<? echo $vlcheque ?>" />
						<input type="hidden" id="vldacpmf" value="<? echo $vldacpmf ?>" />
						<input type="hidden" id="cdtpdchq" value="<? echo $cdtpdchq ?>" />
						<input type="hidden" id="cdbandep" value="<? echo $cdbandep ?>" />
						<input type="hidden" id="cdagedep" value="<? echo $cdagedep ?>" />
						<input type="hidden" id="nrctadep" value="<? echo mascara($nrctadep,'##.###.###.###.#') ?>" />
						
						<input type="hidden" id="cdbantic" value="<? echo $cdbantic ?>" />
						<input type="hidden" id="cdagetic" value="<? echo $cdagetic ?>" />
						<input type="hidden" id="dtlibtic" value="<? echo $dtlibtic ?>" />
						<input type="hidden" id="cdageaco" value="<? echo $cdageaco ?>" />
						<input type="hidden" id="vlacerto" value="<? echo $vlacerto ?>" />
						
						<span><? echo str_replace($search,'',$cdbanchq) ?></span>
						<? echo $cdbanchq ?></td>
						
						
					<td><span><? echo str_replace($search,'',$cdagechq) ?></span>
						<? echo $cdagechq ; ?></td>
						
				    <td><span><? echo str_replace($search,'',$nrcheque) ?></span>
						<? echo mascara($nrcheque,'###.###.#') ?></td>
						
					<td><span><? echo str_replace($search,'',$nrseqems) ?></span>
						<? echo $nrseqems ?></td>
					
					<td><span><? echo $tpcheque ?></span>
						<? echo $tpcheque ?></td>
						
					<td><span><? echo $tpforchq ?></span>
						<? echo $tpforchq ?></td>												
					
					<td><span><? echo $dsobserv ?></span>
						<? echo stringTabela($dsobserv,17,'primeira') ?></td>
					
					<td><span><? echo dataParaTimestamp($dtemschq) ?></span>
						<? echo $dtemschq ?></td>
						
					<td><span><? echo dataParaTimestamp($dtretchq) ?></span>
						<? echo $dtretchq ?></td>
						
					<td><span><? echo dataParaTimestamp($dtliqchq) ?></span>
						<? echo $dtliqchq ?></td>
						
					<td><span><? echo str_replace($search,'',$nrdctitg) ?></span>
						<? echo mascara($nrdctitg,'#.###.###-#') ?></td>
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

<script type="text/javascript">
	$('a.paginacaoAnt').unbind('click').bind('click', function() {
		buscaCheque(<? echo "'".($nriniseq - $nrregist)."','".$nrregist."'"; ?>);
	});
	$('a.paginacaoProx').unbind('click').bind('click', function() {
		buscaCheque(<? echo "'".($nriniseq + $nrregist)."','".$nrregist."'"; ?>);
	});	
	$('#divPesquisaRodape').formataRodapePesquisa();
</script>