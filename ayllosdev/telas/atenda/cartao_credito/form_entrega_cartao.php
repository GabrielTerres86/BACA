<? 
 /*!
 * FONTE        : form_entrega_cartao.php
 * CRIAÇÃO      : James Prust Júnior
 * DATA CRIAÇÃO : 15/05/2014
 * OBJETIVO     : Formulario de entrega de cartao.
 * ALTERACAO    : 
 */	
?>
<div id="divBotoes">
	<form class="formulario">
		<fieldset>
			<legend style="margin-bottom: 5px">Entregar</legend>
			
			<input type="image" src="<?php echo $UrlImagens; ?>botoes/voltar.gif" onClick="voltaDiv(0,1,4);return false;">
			<input type="image" src="<?php echo $UrlImagens; ?>botoes/entregar.gif" onClick="dadosEntrega();return false;">
			<input type="image" src="<?php echo $UrlImagens; ?>botoes/desfazer.gif" onClick="desfazEntregaCartao(1);return false;">
			
		</fieldset>
	</form>
	
	<br />	
</div>