<?
/*!
 * FONTE        : form_cabecalho.php
 * CRIAÇÃO      : Rogerius Militão (DB1)
 * DATA CRIAÇÃO : 02/03/2012
 * OBJETIVO     : Cabeçalho para a tela CADSPC
 * --------------
 * ALTERAÇÕES   : 15/08/2013 - Alteração da sigla PAC para PA (Carlos)
 * --------------
 */

?>


<form id="frmCab" name="frmCab" class="formulario cabecalho">

	<label for="cddopcao"><? echo utf8ToHtml('Opção:') ?></label>
	<select id="cddopcao" name="cddopcao">
	<option value="A" <?php echo $cddopcao == 'A' ? 'selected' : '' ?> >A - Alterar informacoes de devedor cadastrado no sistema Ayllos.</option>
	<option value="B" <?php echo $cddopcao == 'B' ? 'selected' : '' ?> >B - Incluir data de Baixa no sistema ayllos de devedor registrado no SPC.</option>
	<option value="C" <?php echo $cddopcao == 'C' ? 'selected' : '' ?> >C - Consultar informacoes de devedor cadastrado no sistema Ayllos.</option>
	<option value="I" <?php echo $cddopcao == 'I' ? 'selected' : '' ?> >I - Incluir no sistema ayllos, informacoes do devedor registrado no SPC.</option>
	<option value="M" <?php echo $cddopcao == 'M' ? 'selected' : '' ?> >M - Imprimir por PA relatorio dos associados que se encontram cadastrados no SPC.</option>
	</select>

	<a href="#" class="botao" id="btnOk1">Ok</a>
	<br style="clear:both" />	
	
</form>