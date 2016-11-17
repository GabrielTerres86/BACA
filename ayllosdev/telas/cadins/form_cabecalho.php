<?
/*!
 * FONTE        : form_cabecalho.php
 * CRIAÇÃO      : Gabriel Capoia (DB1)
 * DATA CRIAÇÃO : 25/05/2011
 * OBJETIVO     : Cabeçalho para a tela CADINS
 * --------------
 * ALTERAÇÕES   :
 * --------------
 * 23/06/2012 - Jorge     (CECRED) : Retirado onsubmit="return false;" do form "frmCab"
 * 17/12/2012 - Daniel    (CECRED) : Ajuste para layout padrao (Daniel).
 * 13/08/2013 - Carlos    (CECRED) : Alteração da sigla PAC para PA.
 */ 
?>

<form id="frmCab" name="frmCab" class="formulario cabecalho" style="display:none">		
	<label for="cdagcpac">PA:</label>	
	<input type="text" id="cdagcpac" name="cdagcpac" />
	<a style="margin-top:5px;"><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif" /></a>
	<input type="text" id="nmresage" name="nmresage" value="" />
	
	<label style="margin-left:15px" for="nmrecben"><? echo utf8ToHtml('Beneficiário:'); ?></label>
	<input name="nmrecben" id="nmrecben" type="text" value="" />
	<a style="margin-top:5px;"><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif" /></a>
	<a href="#" class="botao" id="btPac" >OK</a>
			
	<br style="clear:both" />	
</form>