<?php
	/*!
	 * FONTE        : form_cabecalho.php
	 * CRIAÇÃO      : Douglas Quisinski
	 * DATA CRIAÇÃO : 08/05/2015
	 * OBJETIVO     : Cabecalho para a tela CUSTCH
	 * --------------
	 * ALTERAÇÕES   : 11/04/2017 - Permitir acessar o Ayllos mesmo vindo do CRM. (Jaison/Andrino)
	 * --------------
	 */
?>

<form id="frmCab" name="frmCab" class="formulario cabecalho" onSubmit="return false;" style="display:none" >
	<input type="hidden" name="crm_inacesso" id="crm_inacesso" value="<?php echo $_SESSION["glbvars"][$glbvars["sidlogin"]]['CRM_INACESSO']; ?>" />
	<input type="hidden" name="crm_nrdconta" id="crm_nrdconta" value="<?php echo $_SESSION["glbvars"][$glbvars["sidlogin"]]['CRM_NRDCONTA']; ?>" />
	<label for="nrdconta">Conta:</label>
	<input type="text" id="nrdconta" name="nrdconta" value="<? echo $nrdconta ?>" />
	<a style="margin-top:5px;"><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif" /></a>
	<a href="#" class="botao" id="btnOK">OK</a>
	<input name="nmprimtl" id="nmprimtl" type="text" value="<? echo $nmprimtl ?>" />
	<br style="clear:both;" />	
</form>

<form id="frmImpressao">
	<input type="hidden" name="sidlogin" id="sidlogin" value="<?php echo $glbvars["sidlogin"]; ?>">
</form>

<script>
	highlightObjFocus( $('#frmCab') ); 
</script>