<?
/*!
 * FONTE        : form_cabecalho.php
 * CRIAÇÃO      : Odirlei Busana - AMcom
 * DATA CRIAÇÃO : 04/10/2016
 * OBJETIVO     : Cabeçalho para a tela CADSMS
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
	<select id="cddopcao" name="cddopcao" onchange="Cabecalho.onChangeOpcao(this);" >
		<option value="A" <? echo $cddopcao == 'A' ? 'selected' : '' ?> > A - Alterar Pacotes de SMS</option>
		<option value="C" <? echo $cddopcao == 'C' ? 'selected' : '' ?> > C - Consultar Pacotes de SMS</option>
		<option value="I" <? echo $cddopcao == 'I' ? 'selected' : '' ?> > I - Incluir Pacotes de SMS</option>
		<option value="M" <? echo $cddopcao == 'M' ? 'selected' : '' ?> > M - Manuten&ccedil;&atilde;o de Mensagens para SMS</option> 		
        <option value="P" <? echo $cddopcao == 'P' ? 'selected' : '' ?> > P - Cadastrar Par&acirc;metros</option> 		

        <option value="O" <? echo $cddopcao == 'O' ? 'selected' : '' ?> > O - Ofertar Servi&ccedil;o</option> 

        <option value="Z" <? echo $cddopcao == 'Z' ? 'selected' : '' ?> > Z - Envio de Remessa para a Zenvia - Conting&ecirc;ncia.</option> 		
	</select>
    
    <div id="divCooper" style="left-padding:2x">
		<label for="nmrescop"><? echo utf8ToHtml('Cooperativa:') ?></label>
		<select id="nmrescop" name="nmrescop">
        <option value="0"><? echo utf8ToHtml(' Todas') ?></option> 
		<?php
		foreach ($registros as $r) {
			
			if ( getByTagName($r->tags, 'cdcooper') <> '' ) {
		?>
			<option value="<?= getByTagName($r->tags, 'cdcooper'); ?>"><?= getByTagName($r->tags, 'nmrescop'); ?></option> 
			
			<?php
			}
		}
		?>
		</select>
	</div>
	
	<a href="#" class="botao" id="btnOK" onClick="LiberaCampos(); return false;">OK</a>	
		
	<br style="clear:both" />	
	
</form>
</div>
