<?php 
/*
 * FONTE        : tab_lancamentos_pagamentos.php
 * CRIAÇÃO      : James Prust Júnior
 * DATA CRIAÇÃO : 16/09/2015
 * OBJETIVO     : Div que apresenta os lancamentos para estornar
 * --------------
	 * ALTERAÇÕES   : 03/08/2016 - Corrigi o uso desnecessario da funcao session_start. SD 491672 (Carlos R.)
	 				  29/10/2018 - Alteração no campo da tabela para variar nome da coluna quando for desconto de titulo 
	 				  31/10/2018 - Alteração para inserir os campos de prejuizo (Vitor S Assanuma)
 * --------------
	 */

require_once('../../includes/config.php');
require_once('../../includes/funcoes.php');
require_once('../../includes/controla_secao.php');
require_once('../../class/xmlfile.php');
isPostMethod();
$inprejuz = getByTagName($aRegistros[0]->tags,'inprejuz');
?>
<input id="inprejuz"  name="inprejuz" type="hidden" value="<?=$inprejuz?>" />
<?php
//Caso não esteja em prejuizo iy seja Parcela
if ($inprejuz == 0 || $cdtpprod == 1) { ?>
	<div>
		<fieldset>
			<legend>Lan&ccedil;amentos</legend>
			
			<div id="divLancamentoParcela" class="divRegistros">
				<table width="100%">
					<thead>
						<tr>
							<th><?php if($cdtpprod == 1){echo('Parcela');}else{echo('T&iacutetulo');} ?></th>
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
<?php } else { ?>
	<label for="dsprejuz"><? echo utf8ToHtml('Atenção! Borderô em prejuízo') ?></label>
	<div>
		<fieldset>
			<legend>Lan&ccedil;amentos</legend>
			
			<div id="divLancamentoParcela" class="divRegistros">
				<table width="100%">
					<thead>
						<tr>
							<th>Data</th>
							<th>Conta</th>
							<th>Border&ocirc;</th>
							<th>Valor Pgto.</th>
							<th>Valor Abono</th>
						</tr>
					</thead>
					<tbody>
					<?php
					foreach ($aRegistros as $oLancamento) {
					?>
						<tr>
							<td><?php echo getByTagName($oLancamento->tags,'dtdpagto') ?></td>
							<td><?php echo formataContaDVsimples(getByTagName($oLancamento->tags,'nrdconta')) ?></td>
							<td><?php echo getByTagName($oLancamento->tags,'nrborder') ?></td>
							<td><?php echo formataMoeda(getByTagName($oLancamento->tags,'vlpagpar')) ?></td>
							<td><?php echo formataMoeda(getByTagName($oLancamento->tags,'vlrabono')) ?></td>
						</tr>
					<?php
					}
					?>
					</tbody>
				</table>
			</div>
		</fieldset>
	</div>
	<fieldset>	
		<label for="dsjustificativa">Justificativa: </label>	
		<br />	
		
		<textarea name="dsjustificativa" id="dsjustificativa"></textarea> 		
	</fieldset>
<?php } ?>