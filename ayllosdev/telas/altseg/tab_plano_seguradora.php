<? 
/*!
 * FONTE        : tab_plano_seguradora.php
 * CRIAÇÃO      : Cristian Filipe Fernandes
 * DATA CRIAÇÃO : 16/09/2013
 * OBJETIVO     : Tabela que apresenta as seguradoras
 * --------------
 * ALTERAÇÕES   : 
 * --------------
 */	
?>
<div id="divTabPlanosSeguradora">
	<div class="divRegistros">	
		<table>
			<thead>
				<tr>
					<th><? echo utf8ToHtml('Plano'); ?></th>
					<th><? echo utf8ToHtml('Descri&ccedil;&atilde;o'); ?></th>
					<th><? echo utf8ToHtml('Valor do Premio'); ?></th>
					<th><? echo utf8ToHtml('Tabela'); ?></th>
				</tr>
			</thead>
			<tbody>
				<? foreach($registros as $values){ ?>
					<tr>
						<td><span><? echo getByTagName($values->tags, 'tpplaseg'); ?></span>
							      <? echo getByTagName($values->tags, 'tpplaseg'); ?>
						</td>
						<td><span><? echo getByTagName($values->tags, 'dsmorada');?></span>
							      <? echo getByTagName($values->tags, 'dsmorada');?>
						</td>
						<td><span><? echo converteFloat(getByTagName($values->tags, 'vlplaseg'),'MOEDA');?></span>
							      <? echo formataMoeda(getByTagName($values->tags, 'vlplaseg'));?>
						</td>
						<td><span><? echo getByTagName($values->tags, 'nrtabela');?></span>
							      <? echo getByTagName($values->tags, 'nrtabela');?>
						</td>
					</tr>
			<? } ?>	
			</tbody>
		</table>
	</div>	
</div>