<?php
	/*!
	 * FONTE        : botao_acao.php
	 * CRIAÇÃO      : Gustavo Meyer         
	 * DATA CRIAÇÃO : 26/02/2017
	 * OBJETIVO     : Arquivo com parte responsável pelo div Botão Ação
	 * --------------
	 * ALTERAÇÕES   :
	 * --------------
	 */
	 
	$xml  = '';
	$xml .= '<Root><Dados></Dados></Root>';

	// Enviar XML de ida e receber String XML de resposta		pc_relatorio_custos_orcados_
	$xmlResultTelas = mensageria($xml, 'TELA_PARBAN','TELA_BANNER_MOBILE', $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
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
				<label for="inacao_banner"><? echo utf8ToHtml('A&ccedil;&atilde;o do clique do Banner:') ?></label>
				<input type="checkbox" name="inacao_banner" id="inacao_banner" <?php echo($inacao_banner);?> onClick="exibeAcao();" />
			</legend>
			<div id="divBtnAcaoConteudo" name="divBtnAcaoConteudo" >
				<table>
					<tr style="height: 30px;">
						<td>
							<input type="radio" value="1" name="idacao_banner" id="idacao_banner_url" onClick="acaoRadio(1,this.value);" />
							<label for="dslink_acao_banner">&nbsp;&nbsp;<? echo utf8ToHtml('Abrir URL:') ?></label>
							<input type="text" class="campo" name="dslink_acao_banner" maxlength="1000" id="dslink_acao_banner" style="width: 388px;" value="<?php echo($dslink_acao_banner); ?>"/>
						</td>
					</tr>
					<tr style="height: 30px;">
						<td>
							<input type="radio" value="2" name="idacao_banner" id="idacao_banner_tela" onClick="acaoRadio(2,this.value);" />
							<label for="cdmenu_acao_mobile">&nbsp;&nbsp;<? echo utf8ToHtml('Abrir tela do Cecred Mobile:') ?></label>
							<select id="cdmenu_acao_mobile" name="cdmenu_acao_mobile" class="Campo" style="width:290px;">
								<option value="0">-- SELECIONE --</option>
								 <?php 
									for ($x = 0; $x < $qtTelas; $x++){ 
										echo ("<option   value='".getByTagName($telas[$x]->tags,'MENUMOBILEID')."'>".getByTagName($telas[$x]->tags,'NOME')."</option>");
									}
								?>
							</select>
						</td>
					</tr>
					<tr>
						<td>
							<input type="checkbox" name="inexibe_msg_confirmacao" id="inexibe_msg_confirmacao" <?php echo($inexibe_msg_confirmacao); ?> onClick="msgAcaoMobile('');" />
							<label for="inexibe_msg_confirmacao">&nbsp;&nbsp;<? echo utf8ToHtml('Solicitar confirmação ao clicar no botão de ação:') ?></label>
						</td>
					</tr>
					<tr style="height: 30px;">
						<td>
							<input type="text" class="campo" name="dsmensagem_acao_banner" id="dsmensagem_acao_banner" maxlength="1000" style="width: 477px;" />
							<br/>
							<span style="display: inline-block;"><?php echo utf8ToHtml('<b>Observação: </b>Após ler a mensagem de confirmação, o cooperado terá duas opções para selecionar: “Cancelar e OK”') ?></span>
						</td>
					</tr>
				</table>
			</div>
		</fieldset>
		<script>
			exibeAcao();
			acaoRadio(<?php echo($idacao_banner . "," . $cdmenu_acao_mobile); ?>);
			msgAcaoMobile("<?php echo($dsmensagem_acao_banner); ?>");
		</script>
	</div>
