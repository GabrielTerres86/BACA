<? 
/*!
 * FONTE        : tipo-seguro.php
 * CRIAÇÃO      : Michel M. Candido (DB1)
 * DATA CRIAÇÃO : 19/09/2011 
 * OBJETIVO     : Tipo de Seguro
 * --------------
 * ALTERAÇÕES   : 
 * --------------
 */
 ?>
<form name="frmNovaProp" id="frmNovaProp" class="formulario condensado">	
	<input type='hidden' value='' name='cdsitdct' id='cdsitdct'>
	<input type='hidden' value='' name='nmprimtl' id='nmprimtl'>
	<input type='hidden' value='<? echo $glbvars["cdcooper"] ;?>' name='cdcooper' id='cdcooper'>
	<fieldset>
		<legend><? echo utf8ToHtml('Tipo de Seguro') ?></legend>	
		<label for="tpemprst">Tipo:</label>
		<select name="tpemprst" id="tpemprst">
			<option>Carregando...</option>
		</select>		
	</fieldset>
</form>
<div id="divBotoes">
	<input type="image" id="btVoltar"    src="<? echo $UrlImagens; ?>botoes/voltar.gif"    onClick="controlaOperacao('');return false;"  />
	<input type="image" id="btContinuar"   src="<? echo $UrlImagens; ?>botoes/continuar.gif"   onClick="controlaOperacao('TF');"   />
</div>

<script type="text/javascript">

</script>