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
<div class="condensado" style="padding-top: 30px;">
	<fieldset>
		<legend><b>Banner no Detalhamento</b></legend>
		</br>
		<label for="inexibir_banner">Exibir Banner: </label>
		<input type="checkbox" name="inexibir_banner" id="inexibir_banner" <?php echo($inexibir_banner);?> onClick="exibeBanner();" />
		</br></br>
		<input type="hidden" id="urlimagem_banner" name="urlimagem_banner" value="<?php echo($urlimagem_banner); ?>" />
		<input type="hidden" id="nmimagem_banner" name="nmimagem_banner" value="<?php echo($nmimagem_banner); ?>" />
		<div id="divNmimagem_banner" id="divNmimagem_banner" style="float:left; width:310px; height: 192px; border: 1px solid gray; ">
			<div style="padding-top:90px; text-align: center;">
				<b>IMAGEM N&Atilde;O CARREGADA</b>
			</div>
		</div>
		<div id="divBannerObs" name="divBannerObs" style="padding-left: 30px;">
			<b>Observa&ccedil;&otilde;es</b>
			</br>
			- Tamanho ideal da imagem: 620x383px
			</br></br>
			- Defina o nome da imagem de maneira espec&iacute;fica, pois n&atilde;o ser&aacute; poss&iacute;vel efetuar upload de imagem com nome j&aacute; existente no servidor
			</br></br>
			<input type="file" name="arq_upload[]" id="dirimagem_banner" style="width: 350px;" onChange="carregaImagem(0);"/>
		</div>
		<script>
			exibeBanner();
			carregaImagem(1);
		</script>
	</fieldset>
</div>