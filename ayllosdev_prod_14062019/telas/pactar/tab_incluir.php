<?php
	/*!
	 * FONTE        : tab_inlcuir.php
	 * CRIAÇÃO      : Jean Michel        
	 * DATA CRIAÇÃO : 03/03/2016
	 * OBJETIVO     : Tabela de inclusao de dados da tela PACTAR
	 * --------------
	 * ALTERAÇÕES   : 
	 * -------------- 
	 */	
	
	$registros = $xmlObj->roottag->tags;

?>
	<!-- DIV COM INFORMACOES DOS PACOTES DE TARIFAS -->
	<div id="tabServicos">
		<div class="divRegistros">
			<table class="tituloRegistros">
				<thead>
					<tr>
						<th></th>
						<th><?php echo utf8ToHtml('Servi&ccedil;os'); ?></th>
						<th><?php echo utf8ToHtml('Qtd. Opera&ccedil;&otilde;es'); ?></th>
					</tr>
				</thead>
				<tbody>
					<?php foreach ($registros as $registro) { ?>
						<tr>
							<td style="text-align : center;">
								<input type="checkbox" id="chkCdtarifa<?php echo($registro->tags[0]->cdata);?>" name="chkCdtarifa<?php echo($registro->tags[0]->cdata);?>" style="border: 1px solid #777;" onClick="habilitaCheck('<?php echo($registro->tags[0]->cdata);?>');" />
							</td>
							<td>
								<?php echo($registro->tags[1]->cdata); ?>
							</td>
							<td style="text-align : center;">
								<input name="txtCdtarifa<?php echo($registro->tags[0]->cdata);?>" type="text" id="txtCdtarifa<?php echo($registro->tags[0]->cdata);?>" class="inteiro" maxlength="3" style="width:35px; text-align: right; border: 1px solid #777;" disabled />
							</td>
						</tr>
					<?php } ?>
				</tbody>
			</table>
		</div>
	</div>
