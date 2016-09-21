<? 
/*!
 * FONTE        : tabela_extrato2.php
 * CRIAÇÃO      : Marcelo L. Pereira (GATI)
 * DATA CRIAÇÃO : 29/08/2011
 * OBJETIVO     : Tabela que apresenta o extrato para tipo de empréstimo igual a 1
 */	
?>

<div class="divRegistros">	
	<table>
		<thead>
			<tr>
				<th>Data</th>
				<th><? echo utf8ToHtml('Histórico') ?></th>
				<th>Parcela</th>
				<th><? echo utf8ToHtml('Débito') ?></th>
				<th><? echo utf8ToHtml('Crédito') ?></th>
				<th>Saldo</th>
			</tr>			
		</thead>
		<tbody>
		<? foreach( $registros as $registro ) {?>

			<tr>
				<td><span><? echo dataParaTimestamp(getByTagName($registro->tags,'dtmvtolt')) ?></span>
					<? echo getByTagName($registro->tags,'dtmvtolt') ?></td>
				<td><? echo stringTabela(getByTagName($registro->tags,'dshistor'),50,'maiuscula') ?></td>
				<td><span><? echo getByTagName($registro->tags,'nrdocmto') ?></span>
					<? echo formataNumericos("zzz.zz9",getByTagName($registro->tags,'nrdocmto'),".") ?></td>
				<td><? echo stringTabela(getByTagName($registro->tags,'indebcre'),6,'maiuscula') ?></td>
				<td><span><? echo stringTabela(getByTagName($registro->tags,'vllanmto'),20,'maiuscula') ?></span>
						  <? echo number_format(str_replace(',','.',getByTagName($registro->tags,'vllanmto')),2,',','.') ?></td>
				<td><span><? echo stringTabela(getByTagName($registro->tags,'vllanmto'),20,'maiuscula') ?></span>
						  <? echo number_format(str_replace(',','.',getByTagName($registro->tags,'vllanmto')),2,',','.') ?></td>
			</tr>
		<? } ?>			
		</tbody>
	</table>
</div>	

<div id="divBotoes">
	<? if ( $operacao == 'C_EXTRATO' ) { ?>
		<input type="image" id="btVoltar"    src="<?php echo $UrlImagens; ?>botoes/voltar.gif"    onClick="controlaOperacao('TC'); return false;" />
	<?}?>
</div>
