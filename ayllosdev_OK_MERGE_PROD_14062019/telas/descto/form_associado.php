<?php
/*
 * FONTE        : form_associado.php
 * CRIAÇÃO      : Rogerius Militão (DB1)
 * DATA CRIAÇÃO : 26/12/2011
 * OBJETIVO     : Formulário de associado para a tela DESCTO
 * --------------
 * ALTERAÇÕES   : 01/08/2016 - Corrigi o uso desnecessario da funcao session_start. SD 491672 (Carlos R.)
 * --------------
 */

require_once('../../includes/config.php');
require_once('../../includes/funcoes.php');
require_once('../../includes/controla_secao.php');
require_once('../../class/xmlfile.php');
isPostMethod();
?>

<fieldset>
    <legend>Associado</legend>	

    <label for="nrdconta">Conta:</label>
    <input type="text" id="nrdconta" name="nrdconta" value="<?php echo formataContaDV($nrdconta) ?>"/>
    <a><img src="<?php echo $UrlImagens; ?>geral/ico_lupa.gif" /></a>

    <label for="nmprimtl">Titular:</label>
    <input type="text" id="nmprimtl" name="nmprimtl" value="<?php echo $nmprimtl ?>" />

</fieldset>		
