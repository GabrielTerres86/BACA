<? 
/*!
 * FONTE        : tabela_extrato.php
 * CRIAÇÃO      : André Socoloski - DB1
 * DATA CRIAÇÃO : 29/03/2011 
 * OBJETIVO     : Tabela de extratos
 */	
?>


<div class="divRegistros">	
	<table>
		<thead>
			<tr>
				<th>Data</th>
				<th>Hist&oacute;rico</th>
				<th>Docmto</th>
				<th>D/C</th>
				<th>Valor</th>
				<th>Saldo</th>
			</tr>			
		</thead>
		<tbody>
			<tr>
				<td>&nbsp;</td>
				<td><?php if (count($extrato) > 0) { echo "SALDO ANTERIOR"; } else { echo "&nbsp;"; } ?></td>
				<td>&nbsp;</td>
				<td>&nbsp;</td>
				<td>&nbsp;</td>
				<td><?php if (count($extrato) > 0) { echo number_format(str_replace(",",".",$aux_vlsldant),2,",","."); } else { echo "&nbsp;"; } ?></td>
			</tr>

			<? foreach( $extrato as $extr ) {?>
				<tr>
					<td><span><? echo dataParaTimestamp($extr->tags[0]->cdata) ?></span>
						<?php echo $extr->tags[0]->cdata; ?></td>
					<td><?php echo $extr->tags[1]->cdata; ?></td>
					<td><?php echo formataNumericos("zz.zzz.zzz",$extr->tags[2]->cdata,"."); ?></td>
					<td><?php echo $extr->tags[4]->cdata; ?></td>
					<td><span><? echo str_replace(',','.',$extr->tags[5]->cdata) ?></span>
						<?php echo number_format(str_replace(",",".",$extr->tags[5]->cdata),2,",","."); ?></td>
					<td><span><? echo str_replace(',','.',$extr->tags[6]->cdata) ?></span>
						<?php echo number_format(str_replace(",",".",$extr->tags[6]->cdata),2,",","."); ?></td>
				</tr>				
			<? } ?>			
		</tbody>		
	</table>
</div>	

