<?
/*!
 * FONTE        : form_cabecalho.php
 * CRIAÇÃO      : Rogerius Militão (DB1)
 * DATA CRIAÇÃO : 30/01/2012
 * OBJETIVO     : Cabeçalho para a tela CUSTOD
 * --------------
 * ALTERAÇÕES   :
 * --------------
 */

?>

<?

	session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');	
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();

?>


<form id="frmCab" name="frmCab" class="formulario cabecalho" onSubmit="return false;">

	<label for="cddopcao"><? echo utf8ToHtml('Opção:') ?></label>
	<select id="cddopcao" name="cddopcao">
	<option value="C" <?php echo $cddopcao == 'C' ? 'selected' : '' ?>>C - Consultar as custodias de cheques.</option>
	<option value="D" <?php echo $cddopcao == 'D' ? 'selected' : '' ?>>D - Alterar cheque de custodia para cheque de desconto.</option>
	<option value="F" <?php echo $cddopcao == 'F' ? 'selected' : '' ?>>F - Consultar o fechamento das custodias de cheques.</option>
	<option value="M" <?php echo $cddopcao == 'M' ? 'selected' : '' ?>>M - Imprimir as custodias de cheques.</option>
	<option value="O" <?php echo $cddopcao == 'O' ? 'selected' : '' ?>>O - Emitir relatorio para conferencia.</option>
	<option value="P" <?php echo $cddopcao == 'P' ? 'selected' : '' ?>>P - Pesquisar uma custodia de cheque especifica.</option>
	<option value="R" <?php echo $cddopcao == 'R' ? 'selected' : '' ?>>R - Listar os lotes de custodias de cheques.</option>
	<option value="S" <?php echo $cddopcao == 'S' ? 'selected' : '' ?>>S - Consultar o saldo contabil.</option>
	<option value="T" <?php echo $cddopcao == 'T' ? 'selected' : '' ?>>T - Pesquisar uma custodia informando apenas o valor.</option>
	</select>

	<a href="#" class="botao" id="btnOk1">Ok</a>
	<br style="clear:both" />	

</form>