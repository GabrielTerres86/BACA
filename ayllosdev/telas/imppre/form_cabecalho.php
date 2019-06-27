<?
/*!
 * FONTE        : form_cabecalho.php
 * CRIAÇÃO      : Lucas Lombardi
 * DATA CRIAÇÃO : 19/07/2016
 * OBJETIVO     : Cabeçalho para a tela IMPPRE
 * --------------
 * ALTERAÇÕES   : 
 *
 * 000: [11/07/2017] Alteração no controla de apresentação do cargas bloqueadas na opção "A", Melhoria M441. ( Mateus Zimmermann/MoutS )
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
					 * Variáveris a segir foram trocadas para não mexer na tela PERMISS - Problemas de permissão em tela
					 *
					 */
					if ($glbvars["cdcooper"] == 3 && (!validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],"I", false))) {
					?>
                    <option value='I'>L - Liberar Carga Automática</option>
				<?php } ?>
                    <option value='L'>I - Importar Carga Manual</option>
					<option value='D'>D - Detalhes e Variações da Carga</option>
				<?php if ($glbvars["cdcooper"] == 3) { ?>
					<option value='E'>E - Exclusão de CPF/CNPJ via CSV</option>
				<?php } ?>
				</select>
				<a href="#" class="botao" id="btnOK" name="btnOK" style = "text-align:right;">OK</a>
			</td>
		</tr>
	</table>
</form>