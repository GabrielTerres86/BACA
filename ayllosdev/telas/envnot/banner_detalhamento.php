<?php
	/*!
	 * FONTE        : banner_detalhamento.php
	 * CRIAÇÃO      : Jean Michel         
	 * DATA CRIAÇÃO : 13/09/2017
	 * OBJETIVO     : Arquivo com parte responsável pelo banner
	 * --------------
	 * ALTERAÇÕES   :
	 * --------------
	 */
?>
<div class="condensado" style="padding-top: 15px;">
	<fieldset>
		<legend>
			<label for="inexibir_banner">Banner: </label>
			<input type="checkbox" name="inexibir_banner" id="inexibir_banner" <?php echo($inexibir_banner);?> onClick="exibeBanner();" />
		</legend>
		<input type="hidden" id="urlimagem_banner" name="urlimagem_banner" value="<?php echo($urlimagem_banner); ?>" />
		<input type="hidden" id="nmimagem_banner" name="nmimagem_banner" value="<?php echo($nmimagem_banner); ?>" />
		<div id="divBadge_banner" style="width: 65px; height: 25px; background-color: red; position: absolute; opacity: 0.5; margin: 14px; border-radius: 5px;"/>
		<div id="divNmimagem_banner" id="divNmimagem_banner" style="float:left; width:310px; height: 192px; border: 1px solid gray; margin-right: 10px;background-color: white;">
			<div style="padding-top:90px; text-align: center;">
				<b>IMAGEM N&Atilde;O CARREGADA</b>
			</div>
		</div>
		<div id="divBannerObs" name="divBannerObs" style="padding-left: 30px;">
			<b>Observa&ccedil;&otilde;es:</b>
			</br></br>
			- Tamanho ideal da imagem: 1080px x [altura relativa].
			</br></br>
			- N&atilde;o &eacute; poss&iacute;vel fazer upload de arquivo de imagem com nome j&aacute; existente no servidor.
			</br></br>
			- Qualquer conte&uacute;do na &aacute;rea vermelha da imagem n&atilde;o ser&aacute; vis&iacute;vel no Ailos Mobile.
			</br></br>
			<input type="file" name="arq_upload[]" id="dirimagem_banner" style="width: 350px;" onChange="carregaImagem(0);"/>
		</div>
		<script>
			exibeBanner();
			carregaImagem(1);
		</script>
	</fieldset>
</div>