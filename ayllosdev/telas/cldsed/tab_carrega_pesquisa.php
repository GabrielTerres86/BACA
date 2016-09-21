<?
/*!
 * FONTE        : tab_carrega_pesquisa.php
 * CRIAÇÃO      : Cristian Filipe (GATI)        
 * DATA CRIAÇÃO : 03/09/2013
 * OBJETIVO     : Tabela para opção P
 * --------------
 * ALTERAÇÕES   :
 *				  05/08/2014 - Alteração da Nomeclatura para PA (Vanessa). 
 * --------------
 */

?>
<div id="divInfDetalheMov">
	<div class="divRegistros">	
		<table>
			<thead>
				<tr>
					<th><? echo utf8ToHtml('PA'); ?></th>
					<th><? echo utf8ToHtml('Data');  ?></th>
					<th><? echo utf8ToHtml('Conta/DV');  ?></th>
					<th><? echo utf8ToHtml('Rendimento');  ?></th>
					<th><? echo utf8ToHtml('Credito');  ?></th>
					<th><? echo utf8ToHtml('Credito/Renda');  ?></th>
				</tr>
			</thead>
			<tbody>
				<? 
				 foreach($pesquisa as $values){  ?>
					<tr>
						<td>
							<input type="hidden" value="<? echo getByTagName($values->tags, 'dsdjusti');?>" id="hdsdjusti"/>
							<input type="hidden" value="<? echo getByTagName($values->tags, 'infrepcf');?>" id="hinfrepcf"/>
							<input type="hidden" value="<? echo getByTagName($values->tags, 'dsstatus');?>" id="hdsstatus"/>
							<span><? echo getByTagName($values->tags, 'cdagenci') ; ?></span>
									  <? echo getByTagName($values->tags, 'cdagenci') ;?>
						</td>
						<td>
							<span><? echo getByTagName($values->tags, 'dtmvtolt'); ?></span>
							      <? echo getByTagName($values->tags, 'dtmvtolt'); ?>
						</td>
						<td>
							<span><? echo getByTagName($values->tags, 'nrdconta') ;?></span>
							      <? echo mascara(getByTagName($values->tags, 'nrdconta'),'###.###.#');?>
						</td>
						<td>
							<span><? echo converteFloat(getByTagName($values->tags, 'vlrendim') ,'MOEDA'); ?></span>
							      <? echo formataMoeda(getByTagName($values->tags, 'vlrendim')) ;?>
						</td>
						<td>
							<span><? echo converteFloat(getByTagName($values->tags, 'vltotcre') ,'MOEDA'); ?></span>
								  <? echo formataMoeda(getByTagName($values->tags, 'vltotcre')); ?>
						</td>
						<td>
							<span><? echo getByTagName($values->tags, 'qtultren') ;?></span>
							      <? echo mascara(getByTagName($values->tags, 'qtultren'),'###.###.###') ;?>
						</td>
					</tr>
			<? } ?>	
			</tbody>
		</table>
	</div>
</div>
