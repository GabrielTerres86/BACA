<?php 
/*
 * FONTE        : tab_integrante_grupo_economico.php
 * CRIAÇÃO      : Mauro (MOUTS)
 * DATA CRIAÇÃO : 13/07/2017
 * OBJETIVO     : Div que apresenta os integrantes do Grupo Economico
 */
?>
<div>
		<div id="divIntegrantes" class="divRegistros">
			<table width="100%" class="fixed">
				<thead>
					<tr>
					    <th>&nbsp;</th>
						<th>Tipo Pessoa</th>
						<th>Conta</th>
						<th>Documento</th>
						<th>Nome</th>
						<th><?= utf8ToHtml('Tipo de Vínculo') ?></th>
						<th><?= utf8ToHtml('% Participação') ?></th>
						<th><?= utf8ToHtml('Data Inclusão') ?></th>                    
						<th><?= utf8ToHtml('Operador Inclusão') ?></th>                    
						<th><?= utf8ToHtml('Data Exclusão') ?></th>                    
						<th><?= utf8ToHtml('Operador Exclusão') ?></th>
					</tr>
				</thead>
				<tbody>
				<?php
				foreach ($aRegistros as $oIntegrante) {
				?>
					<tr>
						<td><input type="checkbox" class="clsCheckbox" recid="<?= getByTagName($oIntegrante->tags,'idintegrante') ?>" /></td>
						<td><?= getByTagName($oIntegrante->tags,'tppessoa_desc') ?></td>
						<td><?= getByTagName($oIntegrante->tags,'nrdconta') ?></td>
						<td><?= getByTagName($oIntegrante->tags,'nrcpfcgc') ?></td>
						<td><?= getByTagName($oIntegrante->tags,'nmintegrante') ?></td>
						<td><?= getByTagName($oIntegrante->tags,'tpvinculo_desc') ?></td>
						<td><?= getByTagName($oIntegrante->tags,'peparticipacao') ?></td>
						<td><?= getByTagName($oIntegrante->tags,'dtinclusao') ?></td>
						<td><?= getByTagName($oIntegrante->tags,'cdoperad_inclusao') ?></td>
						<td><?= getByTagName($oIntegrante->tags,'dtexclusao') ?></td>
						<td><?= getByTagName($oIntegrante->tags,'cdoperad_exclusao') ?></td>						
					</tr>
				<?php
				}
				?>
				</tbody>
			</table>
		</div>
</div>