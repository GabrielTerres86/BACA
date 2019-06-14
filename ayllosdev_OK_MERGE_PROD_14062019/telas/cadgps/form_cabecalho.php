<?
/*!
 * FONTE        : form_cabecalho.php
 * CRIAÇÃO      : Rogérius Militão (DB1)
 * DATA CRIAÇÃO : 07/05/2011
 * OBJETIVO     : Cabeçalho para a tela CADGPS
 * --------------
 * ALTERAÇÕES   :
 * 001: 21/01/2013 - Daniel (CECRED) : Implantacao novo layout.
 * --------------
 */ 
?>

<form id="frmCabCadgps" name="frmCabCadgps" class="formulario" style="display:none">

	<label for="opcao"><? echo utf8ToHtml('Opção:') ?></label>
	<select id="opcao" name="opcao">
		<option value="C1" > C - Consultar GPS cadastrado.</option> 
		<option value="A1" > A - Alterar dados de GPS cadastrado.</option>
		<option value="I1" > I - Incluir cadastro de GPS.</option>
		<option value="D1" > D - Incluir guia para debito automatico.</option>
	</select>
	<a href="#" class="botao">OK</a>
	
	<label for="cdidenti">Identificador:</label>
	<input type="text" id="cdidenti" name="cdidenti" autocomplete="off" />
	<a style="margin-top:5px" href="#" onClick="controlaPesquisas(3);return false;"><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif" /></a>
	

	<label for="cddpagto"><? echo utf8ToHtml('Código Pgto:') ?></label>
	<input type="text" id="cddpagto" name="cddpagto" />
	
	
	<br style="clear:both" />	
	
</form>