<?
/*!
 * FONTE        : form_cabecalho.php
 * CRIAÇÃO      : Rogérius Militão (DB1)
 * DATA CRIAÇÃO : 24/05/2011
 * OBJETIVO     : Cabeçalho para a tela DOMINS
 * --------------
 * ALTERAÇÕES   : 29/11/2012 - Alterado botões do tipo tag <input> para
 *					           tag <a> novo layout (Daniel).
 *                15/08/2013 - Alteração da sigla PAC para PA (Carlos).
 * --------------
 */ 
?>

<form id="frmCabDomins" name="frmCabDomins" class="formulario" style="display:none">
		
	<label for="nrdconta">Conta:</label>
	<input type="text" id="nrdconta" name="nrdconta" value="<? echo $nrdconta == 0 ? '' : $nrdconta ?>" />
	<a style="margin-top:5px;"><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif" /></a>
	<a href="#" class="botao" id="bntOk" onClick="VerificaConta();">OK</a>

	<label for="idseqttl">Seq. Ttl:</label>
	<select id="idseqttl" name="idseqttl">
	</select>
	
	<label for="cdagenci" style="width:35px">PA:</label>
	<input type="text" id="cdagenci" name="cdagenci" />
	<input type="text" id="nmresage" name="nmresage" />
	
	<br style="clear:both" />	
	
</form>
<!--
<script type='text/javascript'>
	formataCabecalho();
</script>
-->