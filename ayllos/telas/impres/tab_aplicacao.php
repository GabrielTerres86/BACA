<? 
/*!
 * FONTE        : tab_aplicacao.php
 * CRIAÇÃO      : Rogérius Militao - (DB1)
 * DATA CRIAÇÃO : 01/09/2011 
 * OBJETIVO     : Tabela que apresenta as aplicações
 * --------------
 * ALTERAÇÕES   : 29/11/2012 - Alterado botões do tipo tag <input> para
 *					           tag <a> novo layout (Daniel).
 *   			  28/01/2015 - Alterado para apresentar os novos produtos 
 *							   de captação. (Reinert)
 * --------------
 */	
?>

<div id="divAplicacao">
	<div class="divRegistros">	
		<table>
			<thead>
				<tr>
					<th><? echo utf8ToHtml('Data');  ?></th>
					<th><? echo utf8ToHtml('Aplicação'); ?></th>
					<th></th>
					<th><? echo utf8ToHtml('Valor');  ?></th>
				</tr>
			</thead>
			<tbody>
				<? foreach( $registros as $r ) { ?>
					<tr>
						<td><span><? echo dataParaTimestamp(getByTagName($r->tags,'dtmvtolt')) ?></span>
							      <? echo getByTagName($r->tags,'dtmvtolt') ?>
								  <input type="hidden" id="nraplica" name="nraplica" value="<? echo mascara(getByTagName($r->tags,'nraplica'),'###.###') ?>" />								  
						</td>
						<td><span><? echo getByTagName($r->tags,'nraplica') ?></span>
							      <? echo mascara(getByTagName($r->tags,'nraplica'),'###.###') ?>
								  
						</td>
						<td><span><? echo getByTagName($r->tags,'dsaplica') ?></span>
							      <? echo getByTagName($r->tags,'dsaplica') ?>
						</td>
						<td><span><? echo converteFloat(getByTagName($r->tags,'vlaplica'), 'MOEDA') ?></span>
							      <? echo formataMoeda(getByTagName($r->tags,'vlaplica')) ?>
						</td>
					</tr>
			<? } ?>	
			<? foreach( $registros2 as $r ) { ?>
					<tr>
						<td><span><? echo (dataParaTimestamp($r->tags[11]->cdata)); ?></span>
							      <? echo ($r->tags[11]->cdata); ?>
								  <input type="hidden" id="nraplica" name="nraplica" value="<? echo mascara(($r->tags[0]->cdata),'###.###') ; ?>" />								  						
						</td>
						<td><span><? echo ($r->tags[0]->cdata); ?></span>
							      <? echo mascara(($r->tags[0]->cdata),'###.###'); ?>
								  
						</td>
						<td><span><? echo ($r->tags[4]->cdata); ?></span>
							      <? echo ($r->tags[4]->cdata); ?>
						</td>
						<td><span><? echo converteFloat(($r->tags[6]->cdata), 'MOEDA'); ?></span>
							      <? echo formataMoeda(str_replace('.',',',$r->tags[6]->cdata)); ?>
						</td>
					</tr>
				<? } ?>	
			</tbody>
		</table>
	</div>	
</div>

<div id="divBotoes" style="display:none" >
	<a href="#" class="botao" id="btVoltar" onClick="fechaRotina($('#divRotina')); cNraplica.focus(); return false;" >Voltar</a>
	<a href="#" class="botao" id="btSalvar" onClick="selecionaAplicacao(); return false;" >Continuar</a>
</div>