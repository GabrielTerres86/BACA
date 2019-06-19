<?
/*!
 * FONTE        : form_cabecalho.php
 * CRIA��O      : Lucas Lombardi
 * DATA CRIA��O : 19/07/2016
 * OBJETIVO     : Cabe�alho para a tela IMPPRE
 * --------------
 * ALTERA��ES   : 
 *
 * 000: [11/07/2017] Altera��o no controla de apresenta��o do cargas bloqueadas na op��o "A", Melhoria M441. ( Mateus Zimmermann/MoutS )
 *
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
	<table width = "100%">
		<tr>		
			<td>
				<label for="cddopcao" style="padding-left: 50px;"><? echo utf8ToHtml('Op&ccedil;&atilde;o:') ?></label>
				<select id="cddopcao" name="cddopcao" style="width: 620px;">
				<?php 
					/*
					 *
					 * Vari�veris a segir foram trocadas para n�o mexer na tela PERMISS - Problemas de permiss�o em tela
					 *
					 */
					if ($glbvars["cdcooper"] == 3 && (!validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],"I", false))) {
					?>
                    <option value='I'>L - Liberar Carga Autom�tica</option>
				<?php } ?>
                    <option value='L'>I - Importar Carga Manual</option>
					<option value='D'>D - Detalhes e Varia��es da Carga</option>
				<?php if ($glbvars["cdcooper"] == 3) { ?>
					<option value='E'>E - Exclus�o de CPF/CNPJ via CSV</option>
				<?php } ?>
				</select>
				<a href="#" class="botao" id="btnOK" name="btnOK" style = "text-align:right;">OK</a>
			</td>
		</tr>
	</table>
</form>