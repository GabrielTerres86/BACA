<? 
/*!
 * FONTE        : tabela_extrato.php
 * CRIAÇÃO      : André Socoloski - DB1
 * DATA CRIAÇÃO : 30/03/2011 
 * OBJETIVO     : Tabela que apresenta o extrato
 */	
?>

<div class="divRegistros">	
	<table>
		<thead>
			<tr>
				<th>Data</th>
				<th><? echo utf8ToHtml('Histórico') ?></th>
				<th>Documento</th>
				<th>D/C</th>				
				<th>Valor</th>
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
