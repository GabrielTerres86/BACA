<?php
	/*!
	 * FONTE        : botao_acao.php
	 * CRIAÇÃO      : Jean Michel         
	 * DATA CRIAÇÃO : 13/09/2017
	 * OBJETIVO     : Arquivo com parte responsável pelo div Botão Ação
	 * --------------
	 * ALTERAÇÕES   :
	 * --------------
	 */
	 
	$xml  = '';
	$xml .= '<Root><Dados></Dados></Root>';

	// Enviar XML de ida e receber String XML de resposta		pc_relatorio_custos_orcados_
	$xmlResultTelas = mensageria($xml, 'TELA_ENVNOT','TELA_MOBILE', $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObjetoTelas = getObjectXML($xmlResultTelas);

	// Se ocorrer um erro, mostra cr&iacute;tica
	if (isset($xmlObjetoTelas->roottag->tags[0]->name) && strtoupper($xmlObjetoTelas->roottag->tags[0]->name) == "ERRO") {
		exibeErro($xmlObjetoTelas->roottag->tags[0]->tags[0]->tags[4]->cdata);
		die();
	}

	$telas = $xmlObjetoTelas->roottag->tags[0]->tags[0]->tags;
	$qtTelas = count($telas);
	 
?>
	<div class="condensado" style="padding-top: 15px;">
		<fieldset>
			<legend>
				<label for="inexibe_botao_acao_mobile"><? echo utf8ToHtml('Botão de A&ccedil;&atilde;o no Cecred Mobile:') ?></label>
				<input type="checkbox" name="inexibe_botao_acao_mobile" id="inexibe_botao_acao_mobile" <?php echo($inexibe_botao_acao_mobile);?> onClick="exibeAcao();" />
			</legend>
			<div id="divBtnAcaoConteudo" name="divBtnAcaoConteudo" >
				<table>
					<tr style="height: 30px;">
						<td>
							<label for="dstexto_botao_acao_mobile" ><? echo utf8ToHtml('Texto do bot&atilde;o de a&ccedil;&atilde;o:') ?></label>
							<input type="text" style="width:338px" class="campo" name="dstexto_botao_acao_mobile" id="dstexto_botao_acao_mobile" maxlength="20" value="<?php echo($dstexto_botao_acao_mobile); ?>"/>
						</td>
					</tr>
					<tr style="height: 30px;">
						<td>
							<input type="radio" value="1" name="idacao_botao_acao_mobile" id="idacao_botao_acao_mobile_url" onClick="acaoRadio(1,this.value);" />
							<label for="dstexto_botao_acao_mobile">&nbsp;&nbsp;<? echo utf8ToHtml('Abrir URL:') ?></label>
							<input type="text" class="campo" name="dslink_acao_mobile" maxlength="1000" id="dslink_acao_mobile" style="width: 388px;" value="<?php echo($dslink_acao_mobile); ?>"/>
						</td>
					</tr>
					<tr style="height: 30px;">
						<td>
							<input type="radio" value="2" name="idacao_botao_acao_mobile" id="idacao_botao_acao_mobile_tela" onClick="acaoRadio(2,this.value);" />
							<label for="cdmenu_acao_mobile">&nbsp;&nbsp;<? echo utf8ToHtml('Abrir tela do Cecred Mobile:') ?></label>
							<select id="cdmenu_acao_mobile" name="cdmenu_acao_mobile" class="Campo" style="width:290px;">
								<option value="0">-- SELECIONE --</option>
								 <?php 
									for ($x = 0; $x < $qtTelas; $x++){ 
										echo ("<option value='".getByTagName($telas[$x]->tags,'MENUMOBILEID')."'>".getByTagName($telas[$x]->tags,'NOME')."</option>");
									}
								?>
							</select>
						</td>
					</tr>
					<tr>
						<td>
							<input type="checkbox" name="chk_dsmensagem_acao_mobile" id="chk_dsmensagem_acao_mobile" <?php echo($chk_dsmensagem_acao_mobile); ?> onClick="msgAcaoMobile('');" />
							<label for="chk_dsmensagem_acao_mobile">&nbsp;&nbsp;<? echo utf8ToHtml('Solicitar confirmação ao clicar no botão de ação:') ?></label>
						</td>
					</tr>
					<tr style="height: 30px;">
						<td>
							<input type="text" class="campo" name="dsmensagem_acao_mobile" id="dsmensagem_acao_mobile" maxlength="1000" style="width: 477px;" />
							<br/>
							<span style="display: inline-block;"><?php echo utf8ToHtml('<b>Observação: </b>Após ler a mensagem de confirmação, o cooperado terá duas opções para selecionar: “Cancelar e OK”') ?></span>
						</td>
					</tr>
				</table>
			</div>
		</fieldset>
		<script>
			exibeAcao();
			acaoRadio(<?php echo($idacao_botao_acao_mobile . "," . $cdmenu_acao_mobile); ?>);
			msgAcaoMobile("<?php echo($dsmensagem_acao_mobile); ?>");
		</script>
	</div>