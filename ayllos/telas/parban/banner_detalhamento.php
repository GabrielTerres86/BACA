<?php
	/*!
	 * FONTE        : banner_detalhamento.php
	 * CRIAÇÃO      : Gustavo meyer        
	 * DATA CRIAÇÃO : 26/02/2018
	 * OBJETIVO     : Arquivo com parte responsável pela image do banner
	 * --------------
	 * ALTERAÇÕES   :
	 * --------------
	 */
?>
<div class="condensado" style="padding-top: 15px;">
	<fieldset>
		<legend>
			<legend><b><? echo utf8ToHtml('Imagem') ?></b></legend>
		</legend> 
		<input type="hidden" id="urlimagem_banner" name="urlimagem_banner" value="<?php echo($urlimagem_banner); ?>" />
		<input type="hidden" id="nmimagem_banner" name="nmimagem_banner" value="<?php echo($nmimagem_banner2); ?>" />
		<!--<div id="divBadge_banner" style="width: 65px; height: 25px; background-color: red; position: absolute; opacity: 0.5; margin: 14px; border-radius: 5px;"/>-->
		<div id="divNmimagem_banner" id="divNmimagem_banner" style="float:left; width:310px; height: 178.25px; border: 1px solid gray; margin-right: 10px;background-color: white;">
			
			<?php

				if($nmimagem_banner2 != ""){
					echo("<img src=\"".$urlimagem_banner.$nmimagem_banner2."\" class=\"thumb-image\" height=\"178.25px\" width=\"310px\" />");
				}
				else{
			?>
				<div style="padding-top:90px; text-align: center;">
					<b>IMAGEM N&Atilde;O CARREGADA</b>
				</div>
			<?php
				}
			?>
			
			
		</div>
		<div id="divBannerObs" name="divBannerObs" style="padding-left: 30px;">
			<b>Observa&ccedil;&otilde;es:</b>
			</br></br>
			- Tamanho ideal da imagem: 950px x 552px.
			</br></br>
			- N&atilde;o &eacute; poss&iacute;vel fazer upload de arquivo de imagem com nome j&aacute; existente no servidor.
			</br></br>
			<!--- Qualquer conte&uacute;do na &aacute;rea vermelha da imagem n&atilde;o ser&aacute; vis&iacute;vel no Cecred Mobile.
			</br></br>-->
			<input type="file" name="arq_upload[]" id="dirimagem_banner" style="width: 350px;" value="" onChange="carregaImagem(0);"/>
		</div>
		<script>
			//carregaImagem(1);
		</script>
	</fieldset>
</div>