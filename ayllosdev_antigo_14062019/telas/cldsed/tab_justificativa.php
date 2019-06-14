<?
/*!
 * FONTE        : tab_justificativa.php
 * CRIAÇÃO      : Cristian Filipe (GATI)        
 * DATA CRIAÇÃO : Setembro/2013
 * OBJETIVO     : Tabela de justificativas
 * --------------
 * ALTERAÇÕES   : 
 * --------------
 */
?>
<div id="divJustificativas">
	<div class="divRegistros">	
		<table>
			<thead>
				<tr>
					<th><? echo utf8ToHtml('C&oacute;digo'); ?></th>
					<th><? echo utf8ToHtml('Descri&ccedil;&atilde;o');?></th>
				</tr>
			</thead>
			<tbody>
				<? $i = 0;foreach($registros as $values){?>
					<tr>
						<td>	
							<input type="hidden" value="<? echo getByTagName($values->tags, 'cddjusti');?>" id="hcddjusti">
							<input type="hidden" value="<? echo getByTagName($values->tags, 'dsdjusti');?>" id="hdsdjusti">
							<span><? echo getByTagName($values->tags, 'cddjusti') ; ?></span>
									  <? echo getByTagName($values->tags, 'cddjusti') ;?>
						</td>
						<td>
							<span><? echo getByTagName($values->tags, 'dsdjusti'); ?></span>
							      <? echo getByTagName($values->tags, 'dsdjusti');?>
						</td>

					</tr>
			<? } ?>	
			</tbody>
		</table>
	</div>
</div>

<div id="divBotoes" >
	<a href="#" class="botao" id="btVoltar"  onClick="fechaRotina($('#divRotina')); return false;">Voltar</a>
</div>