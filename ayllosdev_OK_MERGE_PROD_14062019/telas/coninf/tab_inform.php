<? 
/*!
 * FONTE        : tab_inform.php
 * CRIA��O      : Gabriel Capoia (DB1)
 * DATA CRIA��O : 29/11/2012
 * OBJETIVO     : Tabela que apresenda os informativos da tela Coninf
 * ALTERA��ES   : 14/08/2013 - Altera��o da sigla PAC para PA (Carlos).
 */	
?>

<div id="teste" class="divRegistros">
	<table>
		<thead>
			<tr><th>Coop.</th>
				<th>Data</th>
				<th>PA</th>
				<th>Tipo Carta</th>
				<th>Qtde.</th>
				<th><? echo utf8ToHtml('Destino') ?></th>
				<th>Fornec.</th>				
			</tr>			
		</thead>
		<tbody>
			<?
			foreach($registros as $i) {
				// Recebo todos valores em vari�veis
				$cdcooper	= getByTagName($i->tags,'cdcooper');
				$dtmvtolt	= getByTagName($i->tags,'dtmvtolt');
				$cdagenci 	= getByTagName($i->tags,'cdagenci');
				$dstpdcto	= getByTagName($i->tags,'dstpdcto');
				$qtinform	= getByTagName($i->tags,'qtinform');
				$dsdespac 	= getByTagName($i->tags,'dsdespac');
				$nmfornec 	= getByTagName($i->tags,'nmfornec');
											
			?>			
				<tr>
					<td> <? echo $cdcooper ?> </td>
				    <td> <? echo $dtmvtolt ?> </td>
				    <td> <? echo $cdagenci ?> </td>
				    <td> <? echo $dstpdcto ?> </td>
				    <td> <? echo $qtinform ?> </td>
				    <td> <? echo $dsdespac ?> </td>
				    <td> <? echo $nmfornec ?> </td>
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
					
					// Se a pagina��o n�o est� na primeira, exibe bot�o voltar
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
					// Se a pagina��o n�o est� na &uacute;ltima p�gina, exibe bot�o proximo
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
		buscaInformativo(<? echo "'".($nriniseq - $nrregist)."','".$nrregist."'"; ?>);
	});
	$('a.paginacaoProx').unbind('click').bind('click', function() {
		buscaInformativo(<? echo "'".($nriniseq + $nrregist)."','".$nrregist."'"; ?>);
	});	
	$('#divPesquisaRodape').formataRodapePesquisa();
</script>