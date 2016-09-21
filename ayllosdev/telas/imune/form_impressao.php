<?
/*!
 * FONTE        : IMUNE.php
 * CRIAÇÃO      : André Santos / SUPERO
 * DATA CRIAÇÃO : 23/08/2013
 * OBJETIVO     : Formulário - tela IMUNE
 * --------------
 * ALTERAÇÕES   : 31/10/2013 - Incluir campo cddopcao como <input> (Lucas R.)
 *
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
<form id="frmCabImp" name="frmCabImp" class="formulario cabecalho" onSubmit="return false;" style="display:none">
	<label for="cddopcao"><? echo utf8ToHtml('Op&ccedil;&atilde;o:') ?></label>
    <select id="cddopcao" name="cddopcao">
        <option value="R"> R - Relatorio referente a Imunidade Tribut&#225;ria</option>
    </select>
    <a href="#" class="botao" id="btnOK1" name="btnOK1" onClick="LiberaCamposImpressao(); return false;" style = "text-align:right;" >OK</a>
    <br style="clear:both" />
    
    <label for="tprelimt"><? echo utf8ToHtml('Tipo:') ?></label>    
    <select id="tprelimt" name="tprelimt">
        <option value="1"> Relatorio de Acompanhamento</option>
        <option value="2"> Relatorio de Acompanhamento por PA</option>
    </select>
    <label for="cdagenci"><? echo utf8ToHtml('PA:') ?></label>
    <input name="cdagenci" id="cdagenci" type="text" value="<? echo $cdagenci ?>" />
    <br style="clear:both" />

    <label for="dtrefini"><? echo utf8ToHtml('Periodo:') ?></label>
    <input name="dtrefini" id="dtrefini" type="text" value="<? echo $dtrefini ?>" autocomplete="off" />

    <label for="dtreffim"><? echo utf8ToHtml('a') ?></label>
    <input name="dtreffim" id="dtreffim" type="text" value="<? echo $dtreffim ?>" autocomplete="off" />

    <label for="cdsitcad"><? echo utf8ToHtml('Situa&ccedil;&atilde;o:') ?></label>    
    <select id="cdsitcad" name="cdsitcad">
        <option value="9"> Todos </option>
        <option value="0"> Pendente </option>
        <option value="1"> Aprovado </option>
        <option value="2"> N&atilde;o Aprovado </option>
        <option value="3"> Cancelado </option>
    </select>

</form>
<br style="clear:both" />
<form name="frmImprimir" id="frmImprimir">
	<input type="hidden" name="sidlogin" id="sidlogin" value="<?php echo $glbvars["sidlogin"]; ?>">
	<input type="hidden" name="tprelimt" id="tprelimt" type="hidden" value="" />
	<input type="hidden" name="cdagenci" id="cdagenci" type="hidden" value="" />
    <input type="hidden" name="dtrefini" id="dtrefini" type="hidden" value="" />
	<input type="hidden" name="dtreffim" id="dtreffim" type="hidden" value="" />
	<input type="hidden" name="cdsitcad" id="cdsitcad" type="hidden" value="" />
	<input type="hidden" name="cddopcao" id="cddopcao" type="hidden" value="" />
</form>