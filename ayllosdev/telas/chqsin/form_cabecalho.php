<?
/*!
 * FONTE        : form_cabecalho.php
 * CRIA��O      : Cristian Filipe Fernandes        
 * DATA CRIA��O : Setembro/2013
 * OBJETIVO     : Cabecalho para a tela ADMCRD
 * --------------
 * ALTERA��ES   : 25/02/2014 - Revis�o e Corre��o (Lucas).
 * --------------
 *				  16/10/2015 - (Lucas Ranghetti #326872) - Altera��o referente ao projeto melhoria 217, cheques sinistrados fora. 
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
				<label for="cdtipchq"><? echo utf8ToHtml('Tipo') ?></label>	
				<select class='campo' id='cdtipchq' name='cdtipchq'>
					<option value='O'>O - Cheques de outras institui��es financeiras</option>
					<option value='I'>I - Cheques internos</option>					
				</select>
				</br>
				</br>

				<label for="cddopcao" id="cddopcao"><? echo utf8ToHtml('Op&ccedil;&atilde;o') ?></label>	
				<select class='campo' id='cddopcao' name='cddopcao'>
					<option value='C'>C - Consultar Cheques Sinistrados</option>
					<option value='I'>I - Incluir Cheques Sinistrados</option>
					<option value='E'>E - Excluir Cheques Sinistrados</option>
				</select>
				<a href="#" class="botao" id="btOK" name="btnOK" onClick = "liberaCampos();" style = "text-align:right;">OK</a>
			</td>
			
		</tr>
		
	</table>
</form>