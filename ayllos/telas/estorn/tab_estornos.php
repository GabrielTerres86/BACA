<?php 
/*
 * FONTE        : tab_estornos.php
 * CRIAÇÃO      : James Prust Júnior
 * DATA CRIAÇÃO : 16/09/2015
 * OBJETIVO     : 
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
		<legend>Estornos</legend>
			
		<div id="divEstornos" class="divRegistros">
			<table width="100%">
				<thead>
					<tr>
						<th>C&oacute;digo</th>
						<th>Data</th>
						<th>Hora</th>
						<th>Operador</th>
					</tr>
				</thead>
				<tbody>
				<?php
				foreach ($aRegistros as $oEstorno) {
				?>
					<tr>
					    <td>
							<input type="hidden" id="cdestorno" name="cdestorno" value="<? echo getByTagName($oEstorno->tags,'cdestorno') ?>" />
							<? echo getByTagName($oEstorno->tags,'cdestorno') ?>
						</td>
						<td><? echo getByTagName($oEstorno->tags,'dtestorno') ?></td>
						<td><? echo getByTagName($oEstorno->tags,'hrestorno') ?></td>
						<td><? echo getByTagName($oEstorno->tags,'cdoperad').' - '.getByTagName($oEstorno->tags,'nmoperad') ?></td>						
					</tr>
				<?php
				}
				?>
				</tbody>
			</table>
		</div>
	</fieldset>
</div>