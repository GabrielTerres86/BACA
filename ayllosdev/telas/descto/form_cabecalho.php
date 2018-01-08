<?php
/* !
 * FONTE        : form_cabecalho.php
 * CRIAÇÃO      : Rogerius Militão (DB1)
 * DATA CRIAÇÃO : 26/12/2011
 * OBJETIVO     : Cabeçalho para a tela DESCTO
 * --------------
 * ALTERAÇÕES   : 21/09/2016 - Projeto 300: Inclusao das opcoes L e N. (Jaison/Daniel)
 *                10/04/2017 - Permitir acessar o Ayllos mesmo vindo do CRM. (Jaison/Andrino)
 * --------------
 */

session_start();
require_once('../../includes/config.php');
require_once('../../includes/funcoes.php');
require_once('../../includes/controla_secao.php');
require_once('../../class/xmlfile.php');
isPostMethod();
?>

<form id="frmCab" name="frmCab" class="formulario cabecalho" onSubmit="return false;">
	<input type="hidden" name="crm_inacesso" id="crm_inacesso" value="<?php echo $_SESSION["glbvars"][$glbvars["sidlogin"]]['CRM_INACESSO']; ?>" />
	<input type="hidden" name="crm_nrdconta" id="crm_nrdconta" value="<?php echo $_SESSION["glbvars"][$glbvars["sidlogin"]]['CRM_NRDCONTA']; ?>" />

    <label for="cddopcao"><?php echo utf8ToHtml('Op&ccedil;&atilde;o') ?></label>
    <select id="cddopcao" name="cddopcao">
        <option value="A" <?php echo $cddopcao == 'A' ? 'selected' : '' ?>>A - Alterar dados do cheque.</option>
        <option value="C" <?php echo $cddopcao == 'C' ? 'selected' : '' ?>>C - Consultar cheques descontados por conta corrente ou por CPF/CNPJ.</option>
        <option value="F" <?php echo $cddopcao == 'F' ? 'selected' : '' ?>>F - Consultar liberacoes e resgates de cheques.</option>
        <option value="M" <?php echo $cddopcao == 'M' ? 'selected' : '' ?>>M - Imprimir cheques resgatados.</option>
        <option value="P" <?php echo $cddopcao == 'P' ? 'selected' : '' ?>>P - Pesquisar CMC7 de cheques a serem liberados.</option>
        <option value="Q" <?php echo $cddopcao == 'Q' ? 'selected' : '' ?>>Q - Pesquisar cheques a serem liberados.</option>
        <option value="R" <?php echo $cddopcao == 'R' ? 'selected' : '' ?>>R - Imprimir relatorio de lotes.</option>
        <option value="S" <?php echo $cddopcao == 'S' ? 'selected' : '' ?>>S - Pesquisar dados para conciliacao contabil.</option>
        <option value="T" <?php echo $cddopcao == 'T' ? 'selected' : '' ?>>T - Pesquisar datas de liberacao e loteamento de cheques.</option>
        <option value="O" <?php echo $cddopcao == 'O' ? 'selected' : '' ?>>O - Imprimir relatorio para conferencia de cheques a serem liberados.</option>
        <option value="L" <?php echo $cddopcao == 'L' ? 'selected' : '' ?>>L - Imprimir relatorio de borderos nao liberados.</option>
        <option value="N" <?php echo $cddopcao == 'N' ? 'selected' : '' ?>>N - Imprimir relatorio de limites nao renovados.</option>
    </select>

    <a href="#" class="botao" id="btnOk1">Ok</a>
    <br style="clear:both" />	

</form>