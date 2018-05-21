<?php
	/*!
	 * FONTE        : titulo.php
	 * CRIAÇÃO      : Gustavo Meyer        
	 * DATA CRIAÇÃO : 26/02/2018
	 * OBJETIVO     : Formulário com informações do título 
	 * --------------
	 * ALTERAÇÕES   :
	 * --------------
	 */
?>
 <!-- CABECALHO -->
	<input type="hidden" id="hdncdBanner" name="hdncdBanner" value="<?php echo($cdbanner); ?>" />
	<input type="hidden" id="hdncdCanal" name="hdncdCanal" value="<?php echo($cdcanal); ?>" />
	<input type="hidden" id="hdnOpcao" name="hdnOpcao" value="<?php echo($cddopcao); ?>" />
	<input type="hidden" id="dsurl_sevidor_imagem" name="dsurl_sevidor_imagem" value="<?php echo($dsurl_sevidor_imagem ); ?>" />
	<div class="condensado" style="border-top: 0px; border-bottom: 0px;">
		<table style="width: 100%;">
			<tr style="height: 25px;">
				<td style="text-align:right; width: 40px;">
					<label for="dstitulo_banner"><? echo utf8ToHtml('Título:') ?></label>
				</td>	
				<td style="text-align:left; width: 300px;" >
					<input type="text" id="dstitulo_banner" name="dstitulo_banner" class="campo" style="width:270px;" maxlength="50" value="<?php echo($dstitulo_banner); ?>"/>
				</td>
				<td style="text-align:right;">
					<label for="insituacao_banner" ><? echo utf8ToHtml('Situação:'); ?></label>
				</td>
				<td style="text-align:left;" >
					<select id="insituacao_banner" name="insituacao_banner" class="Campo" style="width:340px;">
						<option value="1" <?php if($insituacao_banner == 1){ echo "SELECTED"; } ?>>Habilitado</option>
						<option value="0" <?php if($insituacao_banner == 0){ echo "SELECTED"; } ?>>Desabilitado</option>
					</select>
				</td>
			</tr>
		</table>
		
	</div>