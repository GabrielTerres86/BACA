<?php
/*!
 * FONTE        : IMUNE.php
 * CRIAÇÃO      : André Santos / SUPERO
 * DATA CRIAÇÃO : 23/08/2013
 * OBJETIVO     : Formulário - tela IMUNE
 * --------------
	* ALTERAÇÕES   : 03/08/2016 - Corrigi o uso desnecessario da funcao session_start. SD 491672 (Carlos R.)
 *
 * --------------
 */

	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
    isPostMethod();
?>


<form id="frmCab" name="frmCab" class="formulario cabecalho" onSubmit="return false;" style="display:none">
	<label for="cddopcao">Op&ccedil;&atilde;o:</label>
    <select id="cddopcao" name="cddopcao">
        <option value="C"> C - Consultar Imunidade Tribut&aacute;ria</option>
        <option value="A"> A - Alterar Imunidade Tribut&aacute;ria</option>
        <option value="R"> R - Relatorio referente a Imunidade Tribut&#225;ria</option>
    </select>
    <a href="#" class="botao" id="btnOK" name="btnOK" onClick="LiberaCampos(); return false;" style = "text-align:right;" >OK</a>
    
    <br style="clear:both" />
    <label for="nrcpfcgc">CNPJ:</label>
    <input type="text" id="nrcpfcgc" name="nrcpfcgc" value="<? echo $nrcpfcgc == 0 ? '' : $nrcpfcgc ?>" alt="Informe o n&uacute;mero do CNPJ." />
    <input type="text" id="nmprimtl" name="nmprimtl" value="<? echo $nmprimtl; ?>" />
    <br style="clear:both" />
    
    <label for="dsdentid">Entidade:</label>
    <input type="text" id="dsdentid" name="dsdentid" value="<? echo $nmprimtl; ?>" />
    <br style="clear:both" />
		
</form>
<div id="divResultado" style="display:block;">
</div>
