<?php
/* !
 * FONTE        : form_opcao_m.php
 * CRIAÇÃO      : Rogérius Militao - (DB1)
 * DATA CRIAÇÃO : 30/01/2012 
 * OBJETIVO     : Formulario que apresenta a opcao M da tela CUSTOD
 * --------------
 * ALTERAÇÕES   :
 * --------------
 *
 * [09/08/2019] Jefferson       (Mout'S) : Alteracao da busca_cheques_em_custodia para considerar
 *                                         a data de custodia ao inves da data de liberacao.
 *                                         INC0016418 (Jefferson - Mout'S)
 *
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

    <fieldset>
        <legend> Associado </legend>	

        <label for="nrdconta">Conta:</label>
        <input type="text" id="nrdconta" name="nrdconta" value="<?php echo formataContaDV($nrdconta) ?>"/>
        <a><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif" /></a>

		<label for="dtcusini">Data Cust&oacute;dia:</label>
		<input type="text" id="dtcusini" name="dtcusini" value=""/>

		<label for="dtcusfim">At&eacute;:</label>
		<input type="text" id="dtcusfim" name="dtcusfim" value=""/>

        <label for="nmprimtl">Titular:</label>
        <input type="text" id="nmprimtl" name="nmprimtl" value="<?php echo $nmprimtl ?>" />

    </fieldset>		


</form>

<div id="divBotoes" style="padding-bottom:10px">
    <a href="#" class="botao" id="btVoltar" onclick="btnVoltar();
                return false;">Voltar</a>
    <a href="#" class="botao" onclick="btnContinuar();
                return false;" >Prosseguir</a>
</div>

