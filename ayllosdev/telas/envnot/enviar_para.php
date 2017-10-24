<?php
	/*!
	 * FONTE        : enviar_para.php
	 * CRIAÇÃO      : Jean Michel         
	 * DATA CRIAÇÃO : 26/09/2017
	 * OBJETIVO     : Arquivo com parte responsável pelos informações de envio
	 * --------------
	 * ALTERAÇÕES   :
	 * --------------
	 */
?>
<div class="condensado">
	<br/>
	<fieldset>
		<legend><b><? echo utf8ToHtml('Enviar para')?></b></legend>		
			<select id="tpfiltro" name="tpfiltro" class="campo" style="width:300px;" onChange="carregaEnviar(this.value);">
				<option value="1" >Escolher os Filtros</option>
				<option value="2" >Importar arquivo CSV</option>
			</select>
		
		<div id="divFile" name="divFile" style="padding-top: 20px; width: 100%; clear:both;">
			<input name="arq_upload[]" id="nmarquivo_csv" type="file" class="campo" style="width:49%; height: 100%;" alt="<? echo utf8ToHtml('Informe o caminho do arquivo.'); ?>" />
			<div id="divCSVObs" name="divCSVObs" style="width:50%; float: right;">
				<b>Observa&ccedil;&otilde;es:</b>
				</br>
				- Apenas arquivos .csv e .txt
				</br>
				- <? echo utf8ToHtml('As únicas informações que devem constar no arquivo são: cooperativa, conta e titular (1;999;1). Caso não seja informado o titular, a notificação será enviada para todos os titulares da conta.')?>
			</div>
		</div>
		<?php if($glbvars["cdcooper"] == 3){ ?>
			<div id="divCooperativas" name="divCooperativas" style="padding-top: 20px; width: 100%; clear:both;">
				<div id="divEsquerda" name="divEsquerda" style="width: 35%; float: left;">
					<label for="dsfiltro_cooperativas"><? echo utf8ToHtml('Cooperativas:'); ?></label>
					<br/>
					<select multiple id="dsfiltro_cooperativas" name="dsfiltro_cooperativas[]" class="campo" style="width:100%; height: 200px;">
						<?php
							foreach ($msgCooper as $cooper) {
								
								if ( getByTagName($cooper->tags, 'CDCOOPER') <> '' ) {
						?>
							<option value="<?= getByTagName($cooper->tags, 'CDCOOPER'); ?>"><?= getByTagName($cooper->tags, 'NMRESCOP'); ?></option> 
								
						<?php
								}
							}
						?>
					</select>
				</div>
			<?php } ?>
		
			<div id="divDireita" name="divDireita" style=" float: left; padding-top: 10px; padding-left: 60px;">
				<label for="dsfiltro_tipos_conta"><? echo utf8ToHtml('Tipos de Conta:'); ?></label>
				<br/><br/>
				<input type="checkbox" name="dsfiltro_tipos_conta_fis" id="dsfiltro_tipos_conta_fis" <?php echo($dsfiltro_tipos_conta_fis); ?> value="1" style="clear:both;" />
				<label for="inexibir_banner" style="padding-left: 5px;">Pessoa F&iacute;sica</label>
				<br/><br/>
				<input type="checkbox" name="dsfiltro_tipos_conta_jur" id="dsfiltro_tipos_conta_jur" <?php echo($dsfiltro_tipos_conta_jur); ?> value="2" style="clear:both;" />
				<label for="inexibir_banner" style="padding-left: 5px; vertical-align:middle;">Pessoa Jur&iacute;dica</label>			
				<br/><br/>
				<label for="tpfiltro_mobile" style="clear:both;" ><? echo utf8ToHtml('Plataforma:'); ?></label>
				<br/><br/>
				<input type="radio" value="0" name="tpfiltro_mobile" id="tpfiltro_mobile_0" style="clear:both;" />
				<label for="tpfiltro_mobile">&nbsp;&nbsp;<? echo utf8ToHtml('Todas as Plataformas') ?></label>
				<br/>
				<input type="radio" value="1" name="tpfiltro_mobile" id="tpfiltro_mobile_1" style="clear:both;" />
				<label for="tpfiltro_mobile">&nbsp;&nbsp;<? echo utf8ToHtml('Cooperados sem Cecred Mobile') ?></label>
				<br/>
				<input type="radio" value="2" name="tpfiltro_mobile" id="tpfiltro_mobile_2" style="clear:both;" />
				<label for="tpfiltro_mobile">&nbsp;&nbsp;<? echo utf8ToHtml('Todos os Cooperados com Cecred Mobile') ?></label>
				<br/>
				<input type="radio" value="3" name="tpfiltro_mobile" id="tpfiltro_mobile_3" style="clear:both;" />
				<label for="tpfiltro_mobile">&nbsp;&nbsp;<? echo utf8ToHtml('Somente Cooperados com Android') ?></label>
				<br/>
				<input type="radio" value="4" name="tpfiltro_mobile" id="tpfiltro_mobile_4" style="clear:both;" />
				<label for="tpfiltro_mobile">&nbsp;&nbsp;<? echo utf8ToHtml('Somente Cooperados com IOS') ?></label>
			</div>
		</div>
		<script>
			carregaEnviar(<?php echo($tpfiltro); ?>);
			
			$("#tpfiltro_mobile_<?php echo($tpfiltro_mobile); ?>").attr('checked', 'checked');
			
			var arrFiltroCoop = "<?php echo($dsfiltro_cooperativas); ?>";
			
			$.each(arrFiltroCoop.split(","), function(i,e){
					$("#dsfiltro_cooperativas option[value='" + e + "']").prop("selected", true);
			});		
			
		</script>
	</fieldset>
</div>