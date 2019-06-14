<?
/*
 * FONTE        : form_cabecalho.php
 * CRIAÇÃO      : Ricardo Linhares
 * DATA CRIAÇÃO : Dezembro/2016									ÚLTIMA ALTERAÇÃO: --/--/----
 * OBJETIVO     : Cabeçalho para a tela TAB098
 * --------------
 * ALTERAÇÕES   : 
 * --------------
 */ 
?>

<form id="frmCab" name="frmCab" class="formulario cabecalho" style="display:none;">	

	<label for="cddopcao">Op&ccedil;&atilde;o:</label>
	<select id="cddopcao" name="cddopcao">
		<option value="C"> C - Consultar Parametriza&ccedil;&atilde;o</option> 
		<option value="A"> A - Alterar Parametriza&ccedil;&atilde;o</option>
	</select>

    <?php
        if ($glbvars["cdcooper"] == 3) {
    ?>
			<label for="cdcooper">Cooperativa:</label>
			<select name="cdcooper" id="cdcooper" >
			</select>
    <?php
	}
    ?>

	<a href="#" class="botao" id="btnOK" onClick="btnOK();return false;" style="text-align: right;">OK</a>
	<br style="clear:both" />	

</form>

