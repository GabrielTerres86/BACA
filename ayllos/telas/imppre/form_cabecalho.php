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
				<label for="cddopcao"><? echo utf8ToHtml('Op&ccedil;&atilde;o:') ?></label>
				<select id="cddopcao" name="cddopcao" style="width: 477px;">
                    <option value='I'>I - Importar Carga</option>
					<option value='B'>B - Bloquear Carga</option>
					<option value='L'>L - Liberar Carga</option>
					<!-- <option value='E'>E - Excluir Carga</option> -->
					<option value='A'>A - Alterar Carga</option>
				</select>
				<a href="#" class="botao" id="btnOK" name="btnOK" style = "text-align:right;">OK</a>
			</td>
		</tr>
	</table>
</form>