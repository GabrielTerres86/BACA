<?php
/* !
 * FONTE        : form_cabecalho.php
 * CRIAÇÃO      : Renato Darosci (Supero)
 * DATA CRIAÇÃO : 07/06/2016
 * OBJETIVO     : Cabeçalho para a tela IMOVEL
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

$opcoesTela = $_SESSION["opcoesTela"];

?>


<form id="frmCab" name="frmCab" class="formulario cabecalho" onSubmit="return false;">

    <label for="cddopcao" ><?php echo utf8ToHtml('Op&ccedil;&atilde;o') ?>:</label>
    <select id="cddopcao" name="cddopcao">

		<?php if (in_array('A',$opcoesTela)) { ?>    
			<option value="A" <?php echo $cddopcao == 'A' ? 'selected' : '' ?>>A - Alterar as informa&ccedil;&otilde;es preenchidas no question&aacute;rio.</option>
		<?php } ?>  

		<!-- BAIXA MANUAL NÃO SERÁ CONTEMPLADA NESTA PRIMEIRA ETAPA 
		<?php if (in_array('B',$opcoesTela)) { ?> 
			<option value="B" <?php echo $cddopcao == 'B' ? 'selected' : '' ?>>B - Baixa manual das aliena&ccedil;&otilde;es imobili&aacute;rias.</option>
		<?php } ?>  -->

		<?php if (in_array('C',$opcoesTela)) { ?> 
			<option value="C" <?php echo $cddopcao == 'C' ? 'selected' : '' ?>>C - Consultar as informa&ccedil;&otilde;es preenchidas no question&aacute;rio e status das informa&ccedil;&otilde;es enviadas &agrave; Cetip.</option>
		<?php } ?>  

		<!-- GERAÇÃO DE ARQUIVO NÃO SERÁ CONTEMPLADA NESTA PRIMEIRA ETAPA 
		<?php if ($glbvars["cdcooper"] == 3 && in_array('G',$opcoesTela)) { ?>        
			<option value="G" <?php echo $cddopcao == 'G' ? 'selected' : '' ?>>G - Gerar arquivos.</option>
		<?php } ?>  -->

		<?php if (in_array('I',$opcoesTela)) { ?> 		  
			<option value="I" <?php echo $cddopcao == 'I' ? 'selected' : '' ?>>I - Gerar relat&oacute;rios de acompanhamento.</option>
		<?php } ?>  

		<!-- INCLUSÃO MANUAL NÃO SERÁ CONTEMPLADA NESTA PRIMEIRA ETAPA 
		<?php if (in_array('M',$opcoesTela)) { ?> 
			<option value="M" <?php echo $cddopcao == 'M' ? 'selected' : '' ?>>M - Inclus&atilde;o manual das aliena&ccedil;&otilde;es imobili&aacute;rias.</option>
		<?php } ?>  -->

		<?php if (in_array('N',$opcoesTela)) { ?> 
			<option value="N" <?php echo $cddopcao == 'N' ? 'selected' : '' ?>>N - Incluir Novo Registro, com informa&ccedil;&otilde;es do Im&oacute;vel no question&aacute;rio.</option>
		<?php } ?>  

		<!-- PROCESSAMENTO DE ARQUIVOS DE RETORNO NÃO SERÁ CONTEMPLADA NESTA PRIMEIRA ETAPA 
		<?php if ($glbvars["cdcooper"] == 3 && in_array('R',$opcoesTela)) { ?>
			<option value="R" <?php echo $cddopcao == 'R' ? 'selected' : '' ?>>R - Processar arquivos de retorno.</option>
		<?php } ?>  -->

		<?php if ($glbvars["cdcooper"] == 3 && in_array('X',$opcoesTela)) { ?>        
			<option value="X" <?php echo $cddopcao == 'X' ? 'selected' : '' ?>>X - Alterar as informa&ccedil;&otilde;es preenchidas no question&aacute;rio, ap&oacute;s envio dos dados a CETIP.</option>
		<?php } ?>
    </select>


    <a href="#" class="botao" id="btnOk1">Ok</a>
    <br style="clear:both" />	

</form>