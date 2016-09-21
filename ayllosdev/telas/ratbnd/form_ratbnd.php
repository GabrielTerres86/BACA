<?
/*!
 * FONTE        : form_ratbnd.php
 * CRIAÇÃO      : Andre Santos - SUPERO
 * DATA CRIAÇÃO : 21/11/2013
 * OBJETIVO     : Formulário - Tela RATBND
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

<div id="tabRatbnd">
    <form id="frmNome" name="frmNome" class="formulario" onSubmit="return false;" style="display:block" >
        <input type="hidden" id="nmprimtl" name="nmprimtl" value="<? echo $nmprimtl;?>" />
        <input type="hidden" id="inpessoa" name="inpessoa" value="<? echo getByTagName($associados[0]->tags,'inpessoa');?>" />
        <input type="hidden" id="nrcpfcgc" name="nrcpfcgc" value="<? echo getByTagName($associados[0]->tags,'nrcpfcgc');?>" />
        <input type="hidden" id="contratos" name="contratos" value="<? echo getByTagName($contratos[0]->tags,'contratos');?>" />
    </form>
</div>
