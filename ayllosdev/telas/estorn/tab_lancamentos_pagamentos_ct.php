<?php 
/*
 * FONTE        : tab_lancamentos_pagamentos_ct.php
 * CRIAÇÃO      : Diego Simas
 * DATA CRIAÇÃO : 28/08/2018
 * OBJETIVO     : Div que apresenta os lancamentos para estornar da Conta Transitória (Bloqueado Prejuízo)
 * -------------- 
 * ALTERAÇÕES   : 
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
		<legend>Lan&ccedil;amento</legend>
			
		<div id="divLancamentoParcelaCT" class="divRegistros">
			<table width="100%">
				<thead>
					<tr>
						<th>Data Pagamento</th>
						<th>Pagamento</th>						
					</tr>
				</thead>
				<tbody>
					<tr>
						<td><?php echo $datalanc; ?></td>
						<td><?php echo formataMoeda($totestor); ?></td>
					</tr>
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