<? 
/*!
 * FONTE        : tabela_subscricao.php
 * CRIAÇÃO      : André Socoloski - DB1
 * DATA CRIAÇÃO : 29/03/2011 
 * OBJETIVO     : Tabela com subscrição inicial
 */	
?>


<div class="divRegistros">	
	<table>
		<thead>
			<tr>
				<th>Referente</th>
				<th>Debitado em </th>
				<th>Valor</th>
				<th>Total pago</th>
			</tr>			
		</thead>
		<tbody>
			<? foreach( $subscricao as $subs ) {?>
				<tr>
					<td><?php echo $subs->tags[1]->cdata; ?></td>
					<td><?php echo $subs->tags[0]->cdata; ?></td>
					<td><?php echo number_format(str_replace(",",".",$subs->tags[2]->cdata),2,",","."); ?></td>
					<td><?php echo number_format(str_replace(",",".",$subs->tags[3]->cdata),2,",","."); ?></</td>
				</tr>				
			<? } ?>			
		</tbody>		
	</table>
</div>	

