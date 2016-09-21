<?
/*!
 * FONTE        : tab_carrega_creditos.php
 * CRIA��O      : Cristian Filipe (GATI)        
 * DATA CRIA��O : 04/09/2013
 * OBJETIVO     : Tabela de Para op��o C e J
 * --------------
 * ALTERA��ES   : 
 *				  05/08/2014 - Altera��o da Nomeclatura para PA (Vanessa).
 * --------------
 */
?>
<div id="divInfConsultaMovimentacao">
	<div class="divRegistros">	

		<table>
			<thead>
				<tr>
					<th><? echo utf8ToHtml('PA'); ?></th>
					<th><? echo utf8ToHtml('Conta/DV');  ?></th>
					<th><? echo utf8ToHtml('Rendimento');  ?></th>
					<th><? echo utf8ToHtml('Credito');  ?></th>
					<th><? echo utf8ToHtml('Credito/Renda');  ?></th>
					<th><? echo utf8ToHtml('Status');  ?></th>
				</tr>
			</thead>
			<tbody>
				<? 
				 foreach($pesquisa as $values){?>
					<tr>
						<td>
							<input type="hidden" value="<? echo getByTagName($values->tags, 'nmprimtl');?>" id="hnmprimtl">
							<input type="hidden" value="<? echo getByTagName($values->tags, 'nrdrowid');?>" id="nrdrowid">
							<input type="hidden" value="<? echo getByTagName($values->tags, 'inpessoa');?>" id="hinpessoa">
							<input type="hidden" value="<? echo getByTagName($values->tags, 'cdoperad');?>" id="hcdoperad">
							<input type="hidden" value="<? echo getByTagName($values->tags, 'opeenvcf');?>" id="hopeenvcf">
							<input type="hidden" value="<? echo getByTagName($values->tags, 'cddjusti');?>" id="hcddjusti">
							<input type="hidden" value="<? echo getByTagName($values->tags, 'dsdjusti');?>" id="hdsdjusti">
							<input type="hidden" value="<? echo getByTagName($values->tags, 'dsobserv');?>" id="hdsobserv">						 
							<input type="hidden" value="<? echo getByTagName($values->tags, 'infrepcf');?>" id="hinfrepcf">						 
							<input type="hidden" value="<? echo getByTagName($values->tags, 'dsobsctr');?>" id="hdsobsctr">	 	
							<span><? echo getByTagName($values->tags, 'cdagenci') ; ?></span>
									  <? echo getByTagName($values->tags, 'cdagenci') ;?>
						</td>
						<td>
							<span><? echo getByTagName($values->tags, 'nrdconta') ?></span>
							      <? echo mascara(getByTagName($values->tags, 'nrdconta'),'###.###.#');?>
						</td>
						<td>
							<span><? echo converteFloat(getByTagName($values->tags, 'vlrendim') ,'MOEDA') ?></span>
							      <? echo formataMoeda(getByTagName($values->tags, 'vlrendim')) ?>
						</td>
						<td>
							<span><? echo converteFloat(getByTagName($values->tags, 'vltotcre') ,'MOEDA') ?></span>
								  <? echo formataMoeda(getByTagName($values->tags, 'vltotcre')) ?>
						</td>
						<td>
							<span><? echo getByTagName($values->tags, 'qtultren') ?></span>
							      <? echo mascara(getByTagName($values->tags, 'qtultren'),'###.###.###') ?>
						</td>
						<td>
							<span><? echo getByTagName($values->tags, 'dsstatus')?></span>
							      <? echo str_replace(' ', '&nbsp;',getByTagName($values->tags, 'dsstatus'))?>
						</td>
					</tr>
			<? } ?>	
			</tbody>
		</table>
	</div>
</div>	