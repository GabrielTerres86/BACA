<?php
/*******************************************************************************************
 * FONTE        : form_cabecalho.php
 * CRIAÇÃO      : Andrey Formigari (Mouts)
 * DATA CRIAÇÃO : 25/10/2011
 * OBJETIVO     : Cabeçalho para a tela HCONVE
 * --------------
 * ALTERAÇÕES   :
 *
 *********************************************************************************************/
?>
<form id="frmCabHconve" name="frmCabHconve" class="formulario cabecalho" style="display:none" >

	<label for="cddopcao"><? echo utf8ToHtml('Opção:') ?></label>
	<select id="cddopcao" name="cddopcao">
		<option value="H">H - <?php echo utf8ToHtml("Criar histórico para novo convênio"); ?></option>
		<option value="F">F - <?php echo utf8ToHtml("Faturas de convênios"); ?></option>
		<option value="A">A - <?php echo utf8ToHtml("Autorização de débito automático"); ?></option>
		<option value="I">I - <?php echo utf8ToHtml("Importação de arquivos"); ?></option>
    </select>
	
	<a href="#" class="botao" id="btOK" name="btOK" style = "text-align:right;">OK</a>

	<br style="clear:both" />	

</form>
