<?
/*!
 * FONTE        : form_cabecalho.php
 * CRIAÇÃO      : Odirlei Busana - AMcom
 * DATA CRIAÇÃO : 04/12/2017
 * OBJETIVO     : Cabeçalho para a tela CONVEN
 * -------------- 
 * ALTERAÇÕES   : 
 *
 * --------------
 */

 /*
$xml = "<Root>";
$xml .= " <Dados>";
$xml .= "   <cdcooper>0</cdcooper>";
$xml .= "   <flgativo>1</flgativo>";
$xml .= " </Dados>";
$xml .= "</Root>";

$xmlResult = mensageria($xml, "CADA0001", "LISTA_COOPERATIVAS", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
$xmlObj = getObjectXML($xmlResult);

if (strtoupper($xmlObj->roottag->tags[0]->name) == "ERRO") {
    $msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
    if ($msgErro == "") {
        $msgErro = $xmlObj->roottag->tags[0]->cdata;
    }

    exibeErroNew($msgErro);
    exit();
}

$registros = $xmlObj->roottag->tags[0]->tags;
*/
function exibeErroNew($msgErro) {
    echo 'hideMsgAguardo();';
    echo 'showError("error","' . $msgErro . '","Alerta - Ayllos","desbloqueia()");';
    exit();
}
 
 
?>
<div id="divCab">
<form id="frmCab" name="frmCab" class="formulario cabecalho">

	<input id="registro" name="registro" type="hidden" value=""  />
	<input type="hidden" name="sidlogin" id="sidlogin" value="<?php echo $glbvars["sidlogin"]; ?>">
		
	<label for="cddopcao"><? echo utf8ToHtml('Opção:') ?></label>
	<select id="cddopcao" name="cddopcao" >
		<option value="A" <? echo $cddopcao == 'A' ? 'selected' : '' ?> > <? echo utf8ToHtml('A - Alteração') ?></option> 		
        <option value="C" <? echo $cddopcao == 'C' ? 'selected' : '' ?> > <? echo utf8ToHtml('C - Consulta') ?></option> 		   
        <option value="E" <? echo $cddopcao == 'E' ? 'selected' : '' ?> > <? echo utf8ToHtml('E - Exclusão') ?></option> 		
        <option value="I" <? echo $cddopcao == 'I' ? 'selected' : '' ?> > <? echo utf8ToHtml('I - Inclusão') ?></option> 		
        <option value="X" <? echo $cddopcao == 'X' ? 'selected' : '' ?> > <? echo utf8ToHtml('X - Replicação') ?></option> 		
	</select>
    
    <br style="clear:both" />	
        
    <label for="cdempcon"><? echo utf8ToHtml('Empresa:') ?></label>
    <input name="cdempcon" id="cdempcon" type="text" value="" >
    <a style="margin-top:5px"><img id="lupaEmp" name = "lupaEmp" src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"></a>
    
    <label for="cdsegmto"><? echo utf8ToHtml('Segmento:') ?></label>
    <select id="cdsegmto" name="cdsegmto">    
    
        <option value="1"> <? echo utf8ToHtml('1 - Prefeituras'); ?></option> 
        <option value="2"> <? echo utf8ToHtml('2 - Saneamento'); ?></option> 
        <option value="3"> <? echo utf8ToHtml('3 - Energia Elétria e Gás'); ?></option> 
        <option value="4"> <? echo utf8ToHtml('4 - Telecomunicações'); ?></option> 
        <option value="5"> <? echo utf8ToHtml('5 - Orgãos Governamentais'); ?></option> 
        <option value="6"> <? echo utf8ToHtml('6 - Orgãos identificados através do CNPJ'); ?></option> 
        <option value="7"> <? echo utf8ToHtml('7 - Multas de Trânsito'); ?></option> 
        <option value="9"> <? echo utf8ToHtml('9 - Uso interno do banco'); ?></option> 
    
    </select>
    <a href="#" class="botao" id="btnBusca" onClick="buscaDados(); return false;">OK</a>	
    <br style="clear:both" />		
	
</form>
</div>