<?php
	/*!
	* FONTE        : form_cabecalho.php
	* DATA CRIAÇÃO : 19/01/2018
	* OBJETIVO     : Cabeçalho para a tela TAB057
	* --------------
	* ALTERAÇÕES   : 
	* --------------
	*/

	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');	
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();
  
?>

<form id="frmCab" name="frmCab" class="formulario cabecalho" width="800px">
  <input id="glcooper" type="hidden" value="<?php echo $glbvars["cdcooper"]; ?>" />
	<table width="100%">
		<tr>
			<td>
				<label for="cddopcao">Op&ccedil;&atilde;o:</label>
				<select id="cddopcao" name="cddopcao">
					<option value="C">C - Consultar</option>
					<option value="A">A - Alterar</option>
				</select>
			</td>
      <td>
				<label for="cdagente">Agente:</label>
				<select id="cdagente" name="cdagente">
					<option value="S">S - Sicred</option>
					<option value="B">B - Bancoob</option>
				</select>
				<a href="#" class="botao" id="btnOK" name="btnOK" style = "text-align:right;">OK</a>
			</td>
		</tr>
	</table>
</form>
