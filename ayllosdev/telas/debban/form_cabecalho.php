<?
/*!
 * FONTE        : form_cabecalho.php
 * CRIAÇÃO      : Odirlei Busana - AMcom
 * DATA CRIAÇÃO : 09/01/2017
 * OBJETIVO     : Cabeçalho para a tela DEBBAN
 * -------------- 
 * ALTERAÇÕES   : 
 *
 * --------------
 */

 
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

$dtmvtopg = $glbvars["dtmvtolt"];



function exibeErroNew($msgErro) {
    echo 'hideMsgAguardo();';
    echo 'showError("error","' . $msgErro . '","Alerta - Ayllos","desbloqueia()"); ';
    exit();
}
 
 
?>
<div id="divCab">
<form id="frmCab" name="frmCab" class="formulario cabecalho">

	<input id="registro" name="registro" type="hidden" value=""  />
	<input type="hidden" name="sidlogin" id="sidlogin" value="<?php echo $glbvars["sidlogin"]; ?>">
    <input type="hidden" name="cddepart" id="cddepart" value="<?php echo $glbvars["cddepart"]; ?>">
		
	<label for="cddopcao"><? echo utf8ToHtml('Opção:') ?></label>
	<select id="cddopcao" name="cddopcao" >
		<option value="C" <? echo $cddopcao == 'C' ? 'selected' : '' ?> > <? echo utf8ToHtml('C - Consultar') ?></option> 		   
        <option value="P" <? echo $cddopcao == 'P' ? 'selected' : '' ?> > <? echo utf8ToHtml('P - Processar') ?></option> 		
        <option value="S" <? echo $cddopcao == 'S' ? 'selected' : '' ?> > <? echo utf8ToHtml('S - Sumário') ?></option> 		
	</select>
    
    <br style="clear:both" />	
    
    <div id="divCooper" style="left-padding:2x">
		<label for="nmrescop"><? echo utf8ToHtml('Cooperativa:') ?></label>
		<select id="nmrescop" name="nmrescop">
        <option value="0"><? echo utf8ToHtml(' Todas') ?></option> 
		<?php
		foreach ($registros as $r) {
			
			if ( getByTagName($r->tags, 'cdcooper') <> '' && getByTagName($r->tags, 'cdcooper') <> 3) {
		   ?>
			<option value="<?= getByTagName($r->tags, 'cdcooper'); ?>"><?= getByTagName($r->tags, 'nmrescop'); ?></option> 
			
			<?php
			}
		}
		?>
		</select>
	</div>
            
    <label for="dtmvtopg"><? echo utf8ToHtml('Data Agendamento:') ?></label>
    <input name="dtmvtopg" id="dtmvtopg" type="text" value="<? // usar a data do movimento, ja existe tratamento para se o processo 
                                                               // estiver rodando a data ser setada com a data "atual"
                                                               echo $dtmvtopg; ?> "> 
    
            
    <a href="#" class="botao" id="btnBusca" onClick="LiberaCampos(); return false;">OK</a>	
    <br style="clear:both" />	
	
	<br style="clear:both" />	
	
</form>
</div>