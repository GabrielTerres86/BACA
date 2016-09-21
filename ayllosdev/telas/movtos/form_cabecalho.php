<?
/*!
 * FONTE        : form_cabecalho.php
 * CRIAÇÃO      : Jéssica (DB1)								Última Alteração: 03/12/2014
 * DATA CRIAÇÃO : 24/02/2014
 * OBJETIVO     : Cabeçalho para a tela MOVTOS
 * --------------
 * ALTERAÇÕES   : 03/12/2014 - Ajustes para liberação (Adriano).
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


<form id="frmCab" name="frmCab" class="formulario cabecalho" style="display:none">

	<label for="cddopcao"><? echo utf8ToHtml('Opção:') ?></label>
	<select id="cddopcao" name="cddopcao">
		<option value="C" selected><? echo utf8ToHtml('C - Consultar cartões BB/Bradesco')?> </option>
		<option value="F" ><? echo utf8ToHtml('F - Consultar contratos') ?> </option>		
		<option value="L" ><? echo utf8ToHtml('L - Liberações') ?> </option>		
		<option value="R" ><? echo utf8ToHtml('R - Recadastramento') ?> </option>		
		<option value="S" ><? echo utf8ToHtml('S - Contas sem movimentação') ?> </option>		
		<option value="A" ><? echo utf8ToHtml('A - Gerar arquivo') ?> </option>		
		<option value="E" ><? echo utf8ToHtml('E - Autorizações de débito') ?> </option>		
	</select>
	
	<a href="#" class="botao" id="btnOK" >OK</a>
	
	<br style="clear:both" />
	
</form>


