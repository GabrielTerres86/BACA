<?php
	/*!
	 * FONTE        : recorrencia.php
	 * CRIAÇÃO      : Jean Michel         
	 * DATA CRIAÇÃO : 13/09/2017
	 * OBJETIVO     : Arquivo com parte responsável pelo div Recorrencia
	 * --------------
	 * ALTERAÇÕES   :
	 * --------------
	 */
?>
<div class="condensado">
	<fieldset>
		<legend><b><? echo utf8ToHtml('Recorr&ecirc;ncia') ?></b></legend>
		<table style="width: 100%;">
			<tr>
				<td style="text-align: left;">
					<label for="inexibe_botao_acao_mobile"><? echo utf8ToHtml('Hora de Envio:') ?></label>
					<input type="text" class="campo" name="hrenvio_mensagem" id="hrenvio_mensagem" value="<?php echo($hrenvio_mensagem); ?>" style="width:60px;" maxlength="5" />
				</td>
			</tr>
			<tr>
				<td style="heigth: 15px;">&nbsp;</td>
			</tr>
			<tr>
				<td style="text-align: left; padding-left: 20px;">
					<input type="radio" value="1" name="intipo_repeticao" id="intipo_repeticao_sem" onClick="tipoRepeticao(1);" />
					<label for="intipo_repeticao">&nbsp;&nbsp;<? echo utf8ToHtml('Semanal') ?></label>
				</td>
			</tr>
		</table>
		
		<div id="divSemanal" name="divSemanal" style="padding-left:10px; padding-left: 50px;" >
			<table>
				<tr>
					<td style="text-align: left;" >
						<input type="checkbox" id="nrdias_semana_1" name="nrdias_semana_1" />
						<label for="dstexto_botao_acao_mobile">&nbsp;&nbsp;<? echo utf8ToHtml('Domingo') ?></label>
					</td>
					<td>
						<input type="checkbox" id="nrsemanas_1" name="nrsemanas_1" />
						<label for="dstexto_botao_acao_mobile">&nbsp;&nbsp;<? echo utf8ToHtml('1&ordf; semana do m&ecirc;s') ?></label>
					</td>
				</tr>
				
				<tr>
					<td style="text-align: left;" >
						<input type="checkbox" id="nrdias_semana_2" name="nrdias_semana_2" />				
						<label for="dstexto_botao_acao_mobile">&nbsp;&nbsp;<? echo utf8ToHtml('Segunda-feira') ?></label>
					<td>
						<input type="checkbox" id="nrsemanas_2" name="nrsemanas_2" />
						<label for="dstexto_botao_acao_mobile">&nbsp;&nbsp;<? echo utf8ToHtml('2&ordf; semana do m&ecirc;s') ?></label>
					</td>
				</tr>
				
				<tr>
					<td style="text-align: left;" >
						<input type="checkbox" id="nrdias_semana_3" name="nrdias_semana_3" />
						<label for="dstexto_botao_acao_mobile">&nbsp;&nbsp;<? echo utf8ToHtml('Ter&ccedil;-feira') ?></label>
					</td>
					<td>
						<input type="checkbox" id="nrsemanas_3" name="nrsemanas_3" />
						<label for="dstexto_botao_acao_mobile">&nbsp;&nbsp;<? echo utf8ToHtml('3&ordf; semana do m&ecirc;s') ?></label>
					</td>
				</tr>
				
				<tr>
					<td style="text-align: left;" >
						<input type="checkbox" id="nrdias_semana_4" name="nrdias_semana_4" />					
						<label for="dstexto_botao_acao_mobile">&nbsp;&nbsp;<? echo utf8ToHtml('Quarta-feira') ?></label>
					</td>
					<td>
						<input type="checkbox" id="nrsemanas_4" name="nrsemanas_4" />				
						<label for="dstexto_botao_acao_mobile">&nbsp;&nbsp;<? echo utf8ToHtml('4&ordf; semana do m&ecirc;s') ?></label>
					</td>
				</tr>
				
				<tr>
					<td style="text-align: left;" >
						<input type="checkbox" id="nrdias_semana_5" name="nrdias_semana_5" />
						<label for="dstexto_botao_acao_mobile">&nbsp;&nbsp;<? echo utf8ToHtml('Quinta-feira') ?></label>
					</td>
					<td>
						<input type="checkbox" id="nrsemanas_U" name="nrsemanas_U" />
						<label for="dstexto_botao_acao_mobile">&nbsp;&nbsp;<? echo utf8ToHtml('&Uacute;ltima semana do m&ecirc;s') ?></label>
					</td>
				</tr>
				
				<tr>
					<td style="text-align: left;" >
						<input type="checkbox" id="nrdias_semana_6" name="nrdias_semana_6" />
						<label for="dstexto_botao_acao_mobile">&nbsp;&nbsp;<? echo utf8ToHtml('Sexta-feira') ?></label>
					</td>
				</tr>
				
				<tr>
					<td style="text-align: left;" >
						<input type="checkbox" id="nrdias_semana_7" name="nrdias_semana_7" />
						<label for="dstexto_botao_acao_mobile">&nbsp;&nbsp;<? echo utf8ToHtml('Sábado') ?></label>
					</td>
				</tr>
			</table>
		</div>
		
		<table style="padding-top: 10px; width: 100%;">
			<tr>
				<td colspan="2" style="text-align: left; padding-left: 20px;">
					<input type="radio" value="2" name="intipo_repeticao" id="intipo_repeticao_mes" onClick="tipoRepeticao(2);" />
					<label for="dstexto_botao_acao_mobile">&nbsp;&nbsp;<? echo utf8ToHtml('Mensal') ?></label>
				</td>
			</tr>
		</table>
		<div id="divMensal" name="divMensal" style="padding-left: 30px;" >
			<table style="padding-top: 10px; width:60%;">
				<tr>
					<td style="text-align:right; width: 80px;">Nos dias&nbsp;</td>
					<td style="width: 80px;"><input type="text" class="campo" maxlength="100" style="width: 80px;" id="nrdias_mes" name="nrdias_mes" value="<?php echo($nrdias_mes); ?>"/></td>				
					<td style="text-align:left; width:90px;">de cada m&ecirc;s</td>
					<td>
						<input type="checkbox" id="nrmeses_1" name="nrmeses_1" />
						<label for="dstexto_botao_acao_mobile">&nbsp;&nbsp;<? echo utf8ToHtml('Janeiro') ?></label>
					</td>
					<td>
						<input type="checkbox" id="nrmeses_7" name="nrmeses_7" />
						<label for="dstexto_botao_acao_mobile">&nbsp;&nbsp;<? echo utf8ToHtml('Julho') ?></label>
					</td>
				</tr>
				<tr>
					<td colspan="3"style="font-size:8pt; padding-left:33px;">(Dias separados por v&iacute;rgula. Ex: 01,15,20)</td>
					<td>
						<input type="checkbox" id="nrmeses_2" name="nrmeses_2" />
						<label for="dstexto_botao_acao_mobile">&nbsp;&nbsp;<? echo utf8ToHtml('Fevereiro') ?></label>
					</td>
					<td>
						<input type="checkbox" id="nrmeses_8" name="nrmeses_8" />
						<label for="dstexto_botao_acao_mobile">&nbsp;&nbsp;<? echo utf8ToHtml('Agosto') ?></label>
					</td>
				</tr>
				
				<tr>
					<td colspan="3">&nbsp;</td>
					<td>
						<input type="checkbox" id="nrmeses_3" name="nrmeses_3" />
						<label for="dstexto_botao_acao_mobile">&nbsp;&nbsp;<? echo utf8ToHtml('Março') ?></label>
					</td>
					<td>
						<input type="checkbox" id="nrmeses_9" name="nrmeses_9" />
						<label for="dstexto_botao_acao_mobile">&nbsp;&nbsp;<? echo utf8ToHtml('Setembro') ?></label>
					</td>
				</tr>
				
				<tr>
					<td colspan="3">&nbsp;</td>
					<td>
						<input type="checkbox" id="nrmeses_4" name="nrmeses_4" />
						<label for="dstexto_botao_acao_mobile">&nbsp;&nbsp;<? echo utf8ToHtml('Abril') ?></label>
					</td>
					<td>
						<input type="checkbox" id="nrmeses_10" name="nrmeses_10" />
						<label for="dstexto_botao_acao_mobile">&nbsp;&nbsp;<? echo utf8ToHtml('Outubro') ?></label>
					</td>
				</tr>
				
				<tr>
					<td colspan="3">&nbsp;</td>
					<td>
						<input type="checkbox" id="nrmeses_5" name="nrmeses_5" />
						<label for="dstexto_botao_acao_mobile">&nbsp;&nbsp;<? echo utf8ToHtml('Maio') ?></label>
					</td>
					<td>
						<input type="checkbox" id="nrmeses_11" name="nrmeses_11" />
						<label for="dstexto_botao_acao_mobile">&nbsp;&nbsp;<? echo utf8ToHtml('Novembro') ?></label>
					</td>
				</tr>
				
				<tr>
					<td colspan="3">&nbsp;</td>
					<td>
						<input type="checkbox" id="nrmeses_6" name="nrmeses_6" />
						<label for="dstexto_botao_acao_mobile">&nbsp;&nbsp;<? echo utf8ToHtml('Junho') ?></label>
					</td>
					<td>
						<input type="checkbox" id="nrmeses_12" name="nrmeses_12" />
						<label for="dstexto_botao_acao_mobile">&nbsp;&nbsp;<? echo utf8ToHtml('Dezembro') ?></label>
					</td>
				</tr>
			</table>
		</div>
		<script>
			tipoRepeticao(<?php echo($intipo_repeticao); ?>);
			setTimeout(function(){marcaDiaSemana("<?php echo($nrdias_semana); ?>")},300);
			setTimeout(function(){marcaSemana("<?php echo($nrsemanas_repeticao); ?>")},300);
			setTimeout(function(){marcaMes("<?php echo($nrmeses_repeticao); ?>")},300);
			$('#hrenvio_mensagem').css({ 'width': '40px', 'text-align': 'right' }).setMask('STRING', '99:99', ':', '');
		</script>
	</fieldset>
</div>