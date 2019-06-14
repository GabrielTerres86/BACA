<? 
/*!
 * FONTE        : tab_log.php
 * CRIAÇÃO      : Rogérius Militao - (DB1)
 * DATA CRIAÇÃO : 23/02/2012 
 * OBJETIVO     : Tabela de log da tela COBRAN
 * --------------
 * ALTERAÇÕES   :
 * --------------
 */	
?>

<div class="divRegistros">	
	<table>
		<thead>
			<tr>
				<th><? echo utf8ToHtml('Data/Hora'); ?></th>
				<th><? echo utf8ToHtml('Descricao');  ?></th>
				<th><? echo utf8ToHtml('Operador');  ?></th>
			</tr>
		</thead>
		<tbody>
			<? foreach( $registro as $r ) { ?>
				<tr>
					<td><span><? echo dataParaTimestamp(getByTagName($r->tags,'dsdthora')) ?></span>
							  <? echo getByTagName($r->tags,'dsdthora') ?>
					</td>
					<td><span><? echo getByTagName($r->tags,'dsdeslog') ?></span>
							  <? echo getByTagName($r->tags,'dsdeslog') ?>
					</td>
					<td><span><? echo getByTagName($r->tags,'dsoperad') ?></span>
							  <? echo getByTagName($r->tags,'dsoperad') ?>
					</td>
				</tr>
		<? } ?>	
		</tbody>
	</table>
</div>


