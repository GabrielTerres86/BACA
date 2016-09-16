<?
/*!
 * FONTE        : form_limite.php
 * CRIAÇÃO      : Fabricio
 * DATA CRIAÇÃO : 08/12/2011
 * OBJETIVO     : Mostrar campos da opcao L = Limite Operacional
 * --------------
 * ALTERAÇÕES   : 06/03/2013 - Novo layout padrao (Gabriel).
 * --------------
 */

?>
<div id="divLimite">
<form id="frmLimite" name="frmLimite" class="formulario" style="display:none;">

	<div id="divCooper">
		<label for="nmrescop"><? echo utf8ToHtml('Cooperativa:') ?></label>
		<select id="nmrescop" name="nmrescop" onChange="buscaRegistro(false);">
		</select>
	</div>
	
	<label for="vllimpam"><? echo utf8ToHtml('Limite:') ?></label>
	<input id="vllimpam" name="vllimpam" type="text" />

	<label for="vlpamuti"><? echo utf8ToHtml('Limite Utilizado:') ?></label>
	<input id="vlpamuti" name="vlpamuti" type="text"  />
	
	<br/>

	<label for="vlmenpam"><? echo utf8ToHtml('Mensalidade:') ?></label>
	<input id="vlmenpam" name="vlmenpam" type="text"  />
	
	<br/>

	<label for="prtaxpam"><? echo utf8ToHtml('% Tarifa:') ?></label>
	<input id="prtaxpam" name="prtaxpam" type="text"  />
	
	<br style="clear:both" />	
	<hr style="background-color:#666; height:1px;" />
	
	<div id="divBotoes" style="margin-bottom: 10px;">	
		<a href="#" class="botao" id="btVoltar" onClick="estadoInicial(); 	return false;">Voltar</a>	
		<a href="#" class="botao" id="btnAlterar" onClick="verificaPermissao(); return false;">Alterar</a>	
	</div>
	
</form>
</div>

<script type='text/javascript'>
	highlightObjFocus($('#frmLimite')); 
</script>
