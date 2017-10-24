<?php
	/*!
	 * FONTE        : conteudo.php
	 * CRIAÇÃO      : Jean Michel         
	 * DATA CRIAÇÃO : 13/09/2017
	 * OBJETIVO     : Arquivo com parte responsável pelo conteúdo
	 * --------------
	 * ALTERAÇÕES   :
	 * --------------
	 */
?>

<div class="condensado" >
	<br/>
	<fieldset>
		<legend><b><? echo utf8ToHtml('Conteúdo')?></b></legend>
		<div style="width: 100%; height: 100%; padding-top: 25px;">
			<textarea id="dshtml_mensagem" name="dshtml_mensagem"><?php echo($dshtml_mensagem); ?></textarea>
			<script type="text/javascript">
				CKEDITOR.replace( 'dshtml_mensagem',{toolbar : 'Envnot', customConfig : '/custom/ckeditor_config.js'});		
			</script>
		</div>
		<br/>
		<div for="dsvariaveis_mensagem" ><? echo utf8ToHtml('<b>Variáveis disponíveis: </b>').$dsvariaveis_mensagem; ?></div>
		
	</fieldset>
</div>
<script type="text/javascript">
	window.onload = function(){
		CKEDITOR.replace( 'dshtml_mensagem',{toolbar : 'Envnot', customConfig : '/custom/ckeditor_config.js'});		
	};
</script>