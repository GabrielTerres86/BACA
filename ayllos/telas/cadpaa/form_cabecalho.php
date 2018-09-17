<?php
/* !
 * FONTE        : form_cabecalho.php
 * CRIAÇÃO      : Renato Darosci (Supero)
 * DATA CRIAÇÃO : 04/11/2016
 * OBJETIVO     : Cabeçalho para a tela CADPAA
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
			<option value="A" <?php echo $cddopcao == 'A' ? 'selected' : '' ?>>A - Alterar cadastro do PA Administrativo</option>
		<?php } ?>  

		<?php if (in_array('C',$opcoesTela)) { ?> 
			<option value="C" <?php echo $cddopcao == 'C' ? 'selected' : '' ?>>C - Consultar cadastro do PA Administrativo</option>
		<?php } ?>  

		<?php if (in_array('I',$opcoesTela)) { ?> 
			<option value="I" <?php echo $cddopcao == 'I' ? 'selected' : '' ?>>I - Incluir cadastro do PA Administrativo</option>
		<?php } ?>  

		<?php if (in_array('R',$opcoesTela)) { ?>
			<option value="R" <?php echo $cddopcao == 'R' ? 'selected' : '' ?>>R - Replicar cadastro do PA Administrativo</option>
		<?php } ?> 

    </select>


    <a href="#" class="botao" id="btnOk1">Ok</a>
    <br style="clear:both" />	

</form>