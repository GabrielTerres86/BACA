<?php
/* !
 * FONTE        : form_cabecalho.php
 * CRIAÇÃO      : Christian Grauppe - ENVOLTI
 * DATA CRIAÇÃO : Janeiro/2019
 * OBJETIVO     : Mostrar tela CADMOT
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
<form id="frmCab" name="frmCab" class="formulario cabecalho" onSubmit="return false;" style="display:none">
    <div id="divCab" style="display:none">
    </div>
</form>