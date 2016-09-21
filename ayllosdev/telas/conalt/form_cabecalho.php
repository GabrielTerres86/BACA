<?
/*!
 * FONTE        : form_cabecalho.php
 * CRIAÇÃO      : Guilherme 
 * DATA CRIAÇÃO : 15/06/2011
 * OBJETIVO     : Cabeçalho para a tela CONALT
 * --------------
 * ALTERAÇÕES   : 15/06/2010 - Incluído descrição nas opções. Alterado botão OK com novo estilo (Guilherme Maba).
 *                14/08/2013 - Alteração da sigla PAC para PA (Carlos).
 * --------------
 */ 
?>

<form id="frmCabConalt" name="frmCabConalt" class="formulario">

	<label for="opcao"><? echo utf8ToHtml('Opção:') ?></label>
	<select id="opcao" name="opcao">
		<option value="C1"> C - Consultar alteracao do tipo da conta.</option> 
		<option value="T1"> T - Consultar transferencias de contas entre PAs.</option> 
	</select>
	<a href="#" class="botao" onclick="manterRotina();return false;">Ok</a>

	<br style="clear:both" />	
	
</form>