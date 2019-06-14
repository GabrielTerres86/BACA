<?php 
/*
 * FONTE        : tab_estornos_ct.php
 * CRIAÇÃO      : Diego Simas (AMcom)
 * DATA CRIAÇÃO : 03/09/2018
 * OBJETIVO     : Rotina para carregar a tabela com os estornos realizados de prejuizo de conta corrente
 * --------------
 * ALTERAÇÕES  
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
		<legend>Estornos de Pagamento de Prejuizo</legend>
			
		<div id="divEstornosCT" class="divRegistros">
			<table width="100%">
				<thead>
					<tr>
						<th>C&oacute;digo</th>
                        <th>Valor</th>
						<th>Data</th>
						<th>Hora</th>                        
						<th>Operador</th>
					</tr>
				</thead>
				<tbody>
				<?php
				foreach ($estornos as $estorno) {
				?>
					<tr>
					    <td>
							<input type="hidden" id="cdestorno" name="cdestorno" value="<? echo getByTagName($estorno->tags,'codigo'); ?>" />
							<? echo getByTagName($estorno->tags,'codigo'); ?>
						</td>
						<td><? echo formataMoeda(getByTagName($estorno->tags,'valor')); ?></td>
						<td><? echo getByTagName($estorno->tags,'data') ?></td>
						<td><? echo getByTagName($estorno->tags,'hora') ?></td>
						<td><? echo getByTagName($estorno->tags,'cdoperad').' - '.getByTagName($estorno->tags,'nmoperad') ?></td>						
					</tr>
				<?php
				}
				?>
				</tbody>
			</table>
		</div>
	</fieldset>
</div>