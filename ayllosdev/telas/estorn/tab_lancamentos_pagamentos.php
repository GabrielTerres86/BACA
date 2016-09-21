<?php 

/*
 * FONTE        : tab_lancamentos_pagamentos.php
 * CRIAÇÃO      : James Prust Júnior
 * DATA CRIAÇÃO : 16/09/2015
 * OBJETIVO     : Div que apresenta os lancamentos para estornar
 * --------------
 * ALTERAÇÕES   : 
 * --------------
 */ ?>

<?php
session_start();
require_once('../../includes/config.php');
require_once('../../includes/funcoes.php');
require_once('../../includes/controla_secao.php');
require_once('../../class/xmlfile.php');
isPostMethod();
?>
<div>
	<fieldset>
		<legend>Lan&ccedil;amentos</legend>
			
		<div id="divLancamentoParcela" class="divRegistros">
			<table width="100%">
				<thead>
					<tr>
						<th><?php echo utf8ToHtml('Parcela') ?></th>
						<th><?php echo utf8ToHtml('Vencimento') ?></th>
						<th><?php echo utf8ToHtml('Data Pagamento') ?></th>
						<th><?php echo utf8ToHtml('Pagamento') ?></th>
						<th><?php echo utf8ToHtml('Multa') ?></th>
						<th><?php echo utf8ToHtml('Juros de Mora') ?></th>                    
					</tr>
				</thead>
				<tbody>
				<?php
				foreach ($aRegistros as $oLancamento) {
				?>
					<tr>
						<td><? echo getByTagName($oLancamento->tags,'nrparepr') ?></td>
						<td><? echo getByTagName($oLancamento->tags,'dtvencto') ?></td>
						<td><? echo getByTagName($oLancamento->tags,'dtdpagto') ?></td>
						<td><? echo formataMoeda(getByTagName($oLancamento->tags,'vlpagpar')) ?></td>
						<td><? echo formataMoeda(getByTagName($oLancamento->tags,'vlpagmta')) ?></td>
						<td><? echo formataMoeda(getByTagName($oLancamento->tags,'vlpagmra')) ?></td>
					</tr>
				<?php
				}
				?>
				</tbody>
			</table>
		</div>
	</fieldset>
</div>
<div>	
	<fieldset>	
		<input type="hidden" id="qtdlacto" name="qtdlacto" value=""/>		
		<label for="dsjustificativa">Justificativa: </label>	
		
		<label for="totalest">Total Estorno: </label>	
		<input type="text" id="totalest" name="totalest" value=""/>
			
		<br />	
		
		<textarea name="dsjustificativa" id="dsjustificativa"></textarea> 
		
	</fieldset>
</div>	