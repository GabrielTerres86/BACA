<? 
/*!
 * FONTE        : tab_contrato.php
 * CRIAÇÃO      : Rogérius Militao - (DB1)
 * DATA CRIAÇÃO : 08/03/2012 
 * OBJETIVO     : Tabela que apresenta os contrato
 * --------------
 * ALTERAÇÕES   :
 * --------------
 */	
?>

<div id="divContrato">
	<div class="divRegistros">	
		<table>
			<thead>
				<tr>
					<th><? echo utf8ToHtml('Ctr.SPC'); ?></th>
					<th><? echo utf8ToHtml('Divida');  ?></th>
					<th><? echo utf8ToHtml('Inclusao');  ?></th>
					<th><? echo utf8ToHtml('Baixa');  ?></th>
				</tr>
			</thead>
			<tbody>
				<? foreach( $registros as $r ) { ?>
					<tr>
						<td><span><? echo getByTagName($r->tags,'nrctrspc') ?></span>
							      <? echo getByTagName($r->tags,'nrctrspc') ?>
								  <input type="hidden" id="nrdrowid" name="nrdrowid" value="<? echo getByTagName($r->tags,'nrdrowid') ?>" />								  
								  
						</td>
						<td><span><? echo converteFloat(getByTagName($r->tags,'vldivida'),'MOEDA') ?></span>
							      <? echo formataMoeda(getByTagName($r->tags,'vldivida')) ?>
						</td>
						<td><span><? echo dataParaTimestamp(getByTagName($r->tags,'dtinclus')) ?></span>
							      <? echo getByTagName($r->tags,'dtinclus') ?>
						</td>
						<td><span><? echo dataParaTimestamp(getByTagName($r->tags,'dtdbaixa')) ?></span>
							      <? echo getByTagName($r->tags,'dtdbaixa') ?>
						</td>
					</tr>
			<? } ?>	
			</tbody>
		</table>
	</div>	
</div>

<div id="divBotoesContrato" class="divBotoes" style="padding-bottom:7px">
	<a href="#" class="botao" id="btVoltar" onclick="fechaRotina($('#divRotina')); cNrctremp.focus(); return false;">Fechar</a>
	<a href="#" class="botao" onclick="selecionaContrato(); return false;" >Continuar</a>
</div>

