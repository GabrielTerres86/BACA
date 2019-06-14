<? 
/*!
 * FONTE        : tabela_parcelamento.php
 * CRIAÇÃO      : Gabriel Capoia (DB1)
 * DATA CRIAÇÃO : 15/07/2010
 * OBJETIVO     : Tabela para o parcelamento da tela MATRIC
 */	
?>
<div class="divRegistros">
	<table>
		<thead>
			<tr><th>Nº</th>
				<th>Vencimento</th>
				<th>Valor</th></tr>		
		</thead>
		<tbody>
			<? foreach( $registros as $parcela ) { ?>
				<?;?>
				<tr><td><? echo getByTagName($parcela->tags,'nrseqdig') ?></td>
					<td><span><? echo dataParaTimestamp( getByTagName($parcela->tags,'dtrefere') ); ?></span>
						<? echo getByTagName($parcela->tags,'dtrefere') ?></td>
					<td><span><? echo str_replace(',','.',getByTagName($parcela->tags,'vlparcel')) ?></span>
						<? echo number_format(str_replace(',','.',getByTagName($parcela->tags,'vlparcel')),2,',','.') ?></td></tr>				
			<? } ?>			
		</tbody>
	</table>
</div>
<div id="divBotoes">
	<input type="image" id="btVoltar"  src="<? echo $UrlImagens; ?>botoes/voltar.gif"  onClick="fechaRotina($('#divUsoGenerico'));" />
	<input type="image" id="btSalvar" src="<? echo $UrlImagens; ?>botoes/concluir.gif" onClick="showMsgAguardo( 'Aguarde, finalizando ...' );setTimeout('finalizaParcelamento()',100);" />			
</div>
