<?php
/*!
 * FONTE        : IMUNE.php
 * CRIAÇÃO      : André Santos / SUPERO
 * DATA CRIAÇÃO : 23/08/2013
 * OBJETIVO     : Formulário - tela IMUNE
 * --------------
 * ALTERAÇÕES   : 31/10/2013 - Incluir campo cddopcao como <input> (Lucas R.)
	*				  03/08/2016 - Corrigi o uso desnecessario da funcao session_start. SD 491672 (Carlos R.)
 * --------------
 */

	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
    isPostMethod();
?>
<form id="frmCabImp" name="frmCabImp" class="formulario cabecalho" onSubmit="return false;" style="display:none">
	<label for="cddopcao">Op&ccedil;&atilde;o:</label>
    <select id="cddopcao" name="cddopcao">
        <option value="R"> R - Relat&oacute;rio referente a Imunidade Tribut&#225;ria</option>
    </select>
    <a href="#" class="botao" id="btnOK1" name="btnOK1" onClick="LiberaCamposImpressao(); return false;" style = "text-align:right;" >OK</a>
    <br style="clear:both" />
    
    <label for="tprelimt">Tipo:</label>    
    <select id="tprelimt" name="tprelimt">
        <option value="1"> Relat&oacute;rio de Acompanhamento</option>
        <option value="2"> Relat&oacute;rio de Acompanhamento por PA</option>
    </select>
    <label for="cdagenci">PA:</label>
    <input name="cdagenci" id="cdagenci" type="text" value="<? echo $cdagenci ?>" />
    <br style="clear:both" />

    <label for="dtrefini">Per&iacute;odo:</label>
    <input name="dtrefini" id="dtrefini" type="text" value="<? echo $dtrefini ?>" autocomplete="off" />

    <label for="dtreffim">a</label>
    <input name="dtreffim" id="dtreffim" type="text" value="<? echo $dtreffim ?>" autocomplete="off" />

    <label for="cdsitcad">Situa&ccedil;&atilde;o:</label>    
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