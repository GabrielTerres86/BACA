<?
/*!
 * FONTE        : form_cabecalho.php
 * CRIAÇÃO      : Marcel Kohls /AMCom
 * DATA CRIAÇÃO : 20/03/2018
 * OBJETIVO     : Cabeçalho para a tela ATVPRB
 */

?>


<form id="frmCab" name="frmCab" class="formulario cabecalho">

	<label for="cddopcao"><? echo utf8ToHtml('Opção:') ?></label>
	<select id="cddopcao" name="cddopcao">
		<option value="H" <?php echo $cddopcao == 'H' ? 'selected' : '' ?> >H - Visualizar Hist&oacute;rico de Registros de Ativos Problem&aacute;ticos</option>
		<option value="C" <?php echo $cddopcao == 'C' ? 'selected' : '' ?> >C - Consultar Registro de Ativo Problem&aacute;tico</option>
		<option value="I" <?php echo $cddopcao == 'I' ? 'selected' : '' ?> >I - Incluir Registro de Ativo Problem&aacute;tico</option>
		<option value="A" <?php echo $cddopcao == 'A' ? 'selected' : '' ?> >A - Alterar Registro de Ativo Problem&aacute;tico</option>
		<option value="E" <?php echo $cddopcao == 'E' ? 'selected' : '' ?> >E - Excluir Registro de Ativo Problem&aacute;tico.</option>
	</select>

	<a href="#" class="botao" id="btnOk1">Ok</a>
	<br style="clear:both" />	
	
</form>