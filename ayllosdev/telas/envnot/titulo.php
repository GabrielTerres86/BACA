<?php
	/*!
	 * FONTE        : titulo.php
	 * CRIAÇÃO      : Jean Michel         
	 * DATA CRIAÇÃO : 13/09/2017
	 * OBJETIVO     : Formulário com informações do título das mensagens
	 * --------------
	 * ALTERAÇÕES   :
	 * --------------
	 */
	 	 
	$xml  = '';
	$xml .= '<Root><Dados></Dados></Root>';

	// Enviar XML de ida e receber String XML de resposta		pc_relatorio_custos_orcados_
	$xmlResultIcones = mensageria($xml, 'TELA_ENVNOT', 'ICONE_NOTIFICACAO', $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObjetoIcones = getObjectXML($xmlResultIcones);

	// Se ocorrer um erro, mostra cr&iacute;tica
	if (isset($xmlObjetoIcones->roottag->tags[0]->name) && strtoupper($xmlObjetoIcones->roottag->tags[0]->name) == "ERRO") {
		exibeErro($xmlObjetoIcones->roottag->tags[0]->tags[0]->tags[4]->cdata);
		die();
	}
	
	$icones = $xmlObjetoIcones->roottag->tags[0]->tags[0]->tags;
	$qtIcones = count($icones);
?>
 <!-- CABECALHO -->
	<input type="hidden" id="hdn_cdorigem_mensagem" name="hdn_cdorigem_mensagem" value="<?php echo($cdorigem_mensagem); ?>" />
	<input type="hidden" id="hdn_cdmotivo_mensagem" name="hdn_cdmotivo_mensagem" value="<?php echo($cdmotivo_mensagem); ?>" />
	<input type="hidden" id="cdtipo_mensagem" name="cdtipo_mensagem" value="<?php echo($cdtipo_mensagem); ?>" />
	<input type="hidden" id="dsurl_sevidor_imagem" name="dsurl_sevidor_imagem" value="<?php echo($dsurl_sevidor_imagem ); ?>" />
	<div class="condensado" style="border-top: 0px; border-bottom: 0px;">
		<table style="width: 100%;">
			<tr style="height: 25px;">
				<td style="text-align:right; width: 20%;">
					<label for="dstitulo_mensagem"><? echo utf8ToHtml('Título:') ?></label>
				</td>	
				<td style="text-align:left; width: 350px;" >
					<input type="text" id="dstitulo_mensagem" name="dstitulo_mensagem" class="campo" style="width:350px;" maxlength="50" value="<?php echo($dstitulo_mensagem); ?>"/>
				</td>
				<td>&nbsp;</td>
			</tr>
			<tr style="height: 25px;">
				<td style="text-align:right;">
					<label for="cdicone"><? echo utf8ToHtml('Ícone da Notificação:') ?></label>
				</td>
				<td style="text-align:left; width: 350px;">
					<select id="cdicone" name="cdicone" class="Campo" onchange="carregaIcone();" style="width:340px;">
					<option value="0" urlImg="-">-- SELECIONE --</option>
					<?php 
						for ($z = 0; $z < $qtIcones; $z++){ 
						  echo "<option value='".getByTagName($icones[$z]->tags,'CDICONE')."' urlImg='".getByTagName($icones[$z]->tags,'URLIMAGEM_ICONE')."'";
							if($cdicone == getByTagName($icones[$z]->tags,'CDICONE')){
								echo " SELECTED ";
							}
							echo " >".getByTagName($icones[$z]->tags,'NMICONE')."</option>";
						}
					?>
					</select>
				</td>
				<td style="text-align:left;">
					<div id="divIcone" name="divIcone" style="border: 1px solid gray; height:48px; width:48px; "></div>
				</td>
			</tr>
			<?php if($cddopcao != "N"){ ?>
			<tr style="height: 25px;">
				<td style="text-align:right;">
					<label for="inmensagem_ativa" ><? echo utf8ToHtml('Situação da Notificação:'); ?></label>
				</td>
				<td style="text-align:left;" colspan="2" >
					<select id="inmensagem_ativa" name="inmensagem_ativa" class="Campo" style="width:340px;">
						<option value="1" <?php if($inmensagem_ativa == 1){ echo "SELECTED"; } ?>>Habilitada</option>
						<option value="2" <?php if($inmensagem_ativa == 0){ echo "SELECTED"; } ?>>Desabilitada</option>
					</select>
				</td>
			</tr>
			<?php } ?>
			<tr style="height: 25px;">
				<td style="text-align:right;">
					<label for="inenviar_push" ><? echo utf8ToHtml('Enviar push notification:'); ?></label>
				</td>
				<td style="text-align:left;" colspan="2">
					<select id="inenviar_push" name="inenviar_push" class="Campo" style="width:340px;">
						<option value="1" <?php if($inenviar_push == 1){ echo "SELECTED"; } ?>>Habilitado</option>
						<option value="0" <?php if($inenviar_push == 0){ echo "SELECTED"; } ?>>Desabilitado</option>
					</select>
				</td>
			</tr>
			<tr style="height: 25px;">
				<td colspan="3">
					<label><? echo utf8ToHtml('Mensagem (Exibida na Central de Notificações e nas notificações PUSH do Cecred Mobile, m&aacute;ximo de 140 caracteres.):'); ?></label>
				</td>
			</tr>
			<tr>
				<td colspan="3">
					<textarea id="dstexto_mensagem" name="dstexto_mensagem" rows="2" maxlength="140" cols="100" class="textarea" style="text-align:left; height: 30px; width: 100%;"><?php echo($dstexto_mensagem); ?></textarea>
				</td>
			</tr>
			<tr style="height: 25px;">
				<td colspan="3">
					<label for="dstexto_mensagem"><?php echo utf8ToHtml('(Variáveis disponíveis: '.$dsvariaveis_mensagem.')'); ?></label>
				</td>
			</tr>
		</table>
		<script>carregaIcone();</script>
	</div>