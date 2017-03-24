<?
/*!
 * FONTE        : form_cabecalho.php
 * CRIAÇÃO      : Lucas Reinert
 * DATA CRIAÇÃO : 19/01/2017
 * OBJETIVO     : Cabecalho para a tela OPECEL
 * --------------
 * ALTERAÇÕES   : 
 * --------------
 */
	
	session_start();
	
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');		
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();		
?>

<form id="frmCab" name="frmCab" class="formulario cabecalho" onSubmit="return false;" style="display:none">
	<table width="100%">
		<tr>		
			<td> 	
				<label for="cddopcao">Op&ccedil;&atilde;o:</label>
				<select id="cddopcao" name="cddopcao" style="width: 460px;">
					<option value="C"> C - Consultar par&acirc;metros </option> 
					<option value="A"> A - Alterar par&acirc;metros </option>
					<option value="M"> M - Mensagens </option>
				</select>
				<label for="cdcooper">Cooperativa:</label>
				<select id="cdcooper" name="cdcooper">
				<?php
				foreach ($registros as $r) {					
					if ( getByTagName($r->tags, 'cdcooper') <> '' ) {
						?>
						<option value="<?= getByTagName($r->tags, 'cdcooper'); ?>"><?= getByTagName($r->tags, 'nmrescop'); ?></option> 
						<?php
					}
				}
				?>
				</select>
				<a href="#" class="botao" id="btnOK" name="btnOK" style = "text-align:right;">OK</a>								
			</td>
		</tr>
	</table>
</form>