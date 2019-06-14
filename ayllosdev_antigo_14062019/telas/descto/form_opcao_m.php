<?php
/* !
 * FONTE        : form_opcao_m.php
 * CRIAÇÃO      : Rogérius Militao - (DB1)
 * DATA CRIAÇÃO : 24/01/2012 
 * OBJETIVO     : Formulario que apresenta a opcao M da tela DESCTO
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

include('form_cabecalho.php');
?>

<form id="frmOpcao" class="formulario">

    <input type="hidden" id="cddopcao" name="cddopcao" value="" />
    <input type="hidden" id="inresgat" name="inresgat" value="" />
    <input type="hidden" name="sidlogin" id="sidlogin" value="<?php echo $glbvars["sidlogin"]; ?>">

    <?php include('form_associado.php'); ?>

    <fieldset>
        <legend>Relat&oacute;rio</legend>

        <label for="dsdopcao">Listar Contas:</label>
        <select id="dsdopcao" name="dsdopcao">
            <option value="1">Cooper</option>
            <option value="2">Demais Associados</option>
            <option value="3">Total Geral</option>
        </select>

        <label for="dsdvalor">Listar Cheques:</label>
        <select id="dsdvalor" name="dsdvalor">
            <option value="1">Qualquer Valor</option>
            <option value="2">Inferiores</option>
            <option value="3">Superiores</option>
        </select>

        <label for="dschqcop">Listar Cheques:</label>
        <select id="dschqcop" name="dschqcop">
            <option value="1">Qualquer Cheque</option>
            <option value="2">Outros Bancos</option>
            <option value="3">Cooperativa</option>
        </select>

        <label for="dtiniper">Listar o Periodo:</label>
        <input type="text" id="dtiniper" name="dtiniper" value="<?php echo $dtiniper; ?>" />
        <label for="dtfimper">at&eacute;</label>
        <input type="text" id="dtfimper" name="dtfimper" value="<?php echo $dtfimper; ?>" />

    </fieldset>	

</form>

<div id="divBotoes" style="padding-bottom:10px">
    <a href="#" class="botao" id="btVoltar" onclick="btnVoltar();return false;">Voltar</a>
    <a href="#" class="botao" onclick="btnContinuar();return false;" >Prosseguir</a>
</div>

