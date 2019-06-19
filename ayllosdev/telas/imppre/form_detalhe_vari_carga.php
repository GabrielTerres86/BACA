<?
/* !
 * FONTE        : form_detalhe_vari_carga.php
 * CRIAÇÃO      : Christian Grauppe - ENVOLTI
 * DATA CRIAÇÃO : Fevereiro/2019
 * OBJETIVO     : Rotina para buscar os detalhes da carga
 * --------------
 * ALTERAÇÕES   :
 * --------------
 */

?>
<div id="divFiltro">
	<form id="frmDetVaricarga" name="frmDetVaricarga" class="formulario" style="display:none;">
		<fieldset id="fsetFiltro" name="fsetFiltro" style="padding:0px 10px 10px 10px; margin:0px;">
			<legend>Detalhes da Carga</legend>
			<div id="divFiltroCarga">
				<table>
					<tr>
						<td>
							<label for="vlrmediapar"><?php echo utf8ToHtml('Média de Parcelas:'); ?></label>
						</td>
						<td>
							<label for="qtregispf"><?php echo utf8ToHtml('Quantidade PF:'); ?></label>
						</td>
						<td>
							<label for="qtregispj"><?php echo utf8ToHtml('Quantidade PJ:'); ?></label>
						</td>
					</tr>
					<tr>
						<td>
							<input type="text" id="vlrmediapar" name="vlrmediapar" />
						</td>
						<td>
							<input type="text" id="qtregispf" name="qtregispf" />
						</td>
						<td>
							<input type="text" id="qtregispj" name="qtregispj" />
						</td>
					</tr>
					<tr>
						<td>
							<label for="vlrparmax"> <?php echo utf8ToHtml('Parcela Máxima:'); ?></label>
						</td>
						<td>
							<label for="vlmincarga"> <?php echo utf8ToHtml('Parcela Mínima:'); ?></label>
						</td>
						<td>
						</td>
					</tr>
					<tr>
						<td>
							<input type="text" id="vlrparmax" name="vlrparmax" />
						</td>
						<td>
							<input type="text" id="vlmincarga" name="vlmincarga" />
						</td>
						<td>
						</td>
					</tr>
					<tr>
						<td>
							<label for="qtremovman"> <?php echo utf8ToHtml('Quantidade de Rejeições<br/> p/ carga Manual:'); ?></label>
						</td>
						<td>
							<label for="pervariault"> <?php echo utf8ToHtml('%Variação da Carga <br/>ref. a última Carga:'); ?></label>
						</td>
						<td>
							<label for="pervarapri"> <?php echo utf8ToHtml('%Variação da Carga <br/>ref. a primeira Carga:'); ?></label>
						</td>
					</tr>
					<tr>
						<td>
							<input type="text" id="qtremovman" name="qtremovman" />
						</td>
						<td>
							<input type="text" id="pervariault" name="pervariault" />
						</td>
						<td>
							<input type="text" id="pervarapri" name="pervarapri" />
						</td>
					</tr>
				</table>
			</div> 	
	</fieldset>
</div>