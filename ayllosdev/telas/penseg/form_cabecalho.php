<?php
/*!
 * FONTE        : form_cabecalho.php
 * CRIAÇÃO      : Guilherme/SUPERO
 * DATA CRIAÇÃO : Junho/2016
 * OBJETIVO     : Mostrar tela PENSEG
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
?>

<form id="frmCab" name="frmCab" class="formulario" onSubmit="return false;" style="display:none">

    <label for="cddopcao"><?php echo utf8ToHtml('Op&ccedil;&atilde;o:') ?></label>
     <select id="cddopcao" name="cddopcao">
        <option value="C" "disable">Consulta - Seguros Pendentes - Sicredi</option>
     </select>
     <br style="clear:both" />
     <br style="clear:both" />
    <div id="divCab" style="display:none">
    </div>
</form>
