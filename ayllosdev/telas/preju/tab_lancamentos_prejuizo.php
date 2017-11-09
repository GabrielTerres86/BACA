<?php 
/*
 * FONTE        : tab_lancamentos_pagamentos.php
 * CRIAÇÃO      : James Prust Júnior
 * DATA CRIAÇÃO : 16/09/2015
 * OBJETIVO     : Div que apresenta os lancamentos para estornar
 * --------------
	 * ALTERAÇÕES   : 03/08/2016 - Corrigi o uso desnecessario da funcao session_start. SD 491672 (Carlos R.)
 * --------------
	 */

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
						<th>Parcela</th>
						<th>Vencimento</th>
						<th>Data Pagamento</th>
						<th>Pagamento</th>
						<th>Multa</th>
						<th>Juros de Mora</th>                    
					</tr>
				</thead>
				<tbody>
				<?php
				foreach ($aRegistros as $oLancamento) {
				?>
					<tr>
						<td><?php echo getByTagName($oLancamento->tags,'nrparepr') ?></td>
						<td><?php echo getByTagName($oLancamento->tags,'dtvencto') ?></td>
						<td><?php echo getByTagName($oLancamento->tags,'dtdpagto') ?></td>
						<td><?php echo formataMoeda(getByTagName($oLancamento->tags,'vlpagpar')) ?></td>
						<td><?php echo formataMoeda(getByTagName($oLancamento->tags,'vlpagmta')) ?></td>
						<td><?php echo formataMoeda(getByTagName($oLancamento->tags,'vlpagmra')) ?></td>
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