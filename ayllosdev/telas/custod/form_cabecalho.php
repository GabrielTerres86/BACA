<?php
/*!
 * FONTE        : form_cabecalho.php
 * CRIAÇÃO      : Rogerius Militão (DB1)
 * DATA CRIAÇÃO : 30/01/2012
 * OBJETIVO     : Cabeçalho para a tela CUSTOD
 * --------------
 * ALTERAÇÕES   : 01/08/2016 - Corrigi o uso desnecessario da funcao session_start. SD 491672 (Carlos R.)
 *				  16/12/2016 - Alterações referentes ao projeto 300. (Reinert)
 *                11/04/2017 - Permitir acessar o Ayllos mesmo vindo do CRM. (Jaison/Andrino)
 *				  06/02/2018 - Alterações referentes ao projeto 454.1 - Resgate de cheque em custodia. (Mateus Zimmermann - Mouts)
 * --------------
 */

	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');	
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();
	$cddopcao = (isset($cddopcao)) ? $cddopcao : '';
	$glb_dtmvtolt = (isset($glbvars["dtmvtolt"])) ? $glbvars["dtmvtolt"] : '';

?>

<form id="formImpres" ></form>
<form id="frmCab" name="frmCab" class="formulario cabecalho" onSubmit="return false;">
	<input type="hidden" name="crm_inacesso" id="crm_inacesso" value="<?php echo $_SESSION["glbvars"][$glbvars["sidlogin"]]['CRM_INACESSO']; ?>" />
	<input type="hidden" name="crm_nrdconta" id="crm_nrdconta" value="<?php echo $_SESSION["glbvars"][$glbvars["sidlogin"]]['CRM_NRDCONTA']; ?>" />

	<label for="cddopcao">Op&ccedil;&atilde;o:</label>
	<select id="cddopcao" name="cddopcao">
	<option value="C" <?php echo $cddopcao == 'C' ? 'selected' : '' ?>>C - Consultar as cust&oacute;dias de cheques.</option>
	<option value="F" <?php echo $cddopcao == 'F' ? 'selected' : '' ?>>F - Consultar o fechamento das cust&oacute;dias de cheques.</option>
	<option value="M" <?php echo $cddopcao == 'M' ? 'selected' : '' ?>>M - Imprimir as cust&oacute;dias de cheques.</option>
	<option value="O" <?php echo $cddopcao == 'O' ? 'selected' : '' ?>>O - Emitir relat&oacute;rio para confer&ecirc;ncia.</option>
	<option value="P" <?php echo $cddopcao == 'P' ? 'selected' : '' ?>>P - Pesquisar uma cust&oacute;dia de cheque espec&iacute;fica.</option>
	<option value="R" <?php echo $cddopcao == 'R' ? 'selected' : '' ?>>R - Listar os lotes de cust&oacute;dias de cheques.</option>
	<option value="S" <?php echo $cddopcao == 'S' ? 'selected' : '' ?>>S - Consultar o saldo cont&aacute;bil.</option>
	<option value="T" <?php echo $cddopcao == 'T' ? 'selected' : '' ?>>T - Pesquisar uma cust&oacute;dia informando apenas o valor.</option>
	<option value="H" <?php echo $cddopcao == 'H' ? 'selected' : '' ?>>H - Resgatar Cheques em Cust&oacute;dia.</option>
<!--
	<option value="X" <?php echo $cddopcao == 'X' ? 'selected' : '' ?>>X - Cancelamento Resgate de Cheque.</option>
-->
	<option value="L" <?php echo $cddopcao == 'L' ? 'selected' : '' ?>>L - Conciliar/Custodiar Cheque.</option>
	<option value="I" <?php echo $cddopcao == 'I' ? 'selected' : '' ?>>I - Incluir Cheque em Cust&oacute;dia.</option>
	<option value="N" <?php echo $cddopcao == 'N' ? 'selected' : '' ?>>N - Imprimir comprovante de resgate de cheque custodiado.</option>
	</select>

	<input type="hidden" id="glb_dtmvtolt" name="glb_dtmvtolt" value="<?php echo $glb_dtmvtolt; ?>">
	<a href="#" class="botao" id="btnOk1">Ok</a>
	<br style="clear:both" />	

</form>