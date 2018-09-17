<?php
/*!
 * FONTE        : form_gera_arq.php
 * CRIAÇÃO      : Odirlei Busana - AMcom
 * DATA CRIAÇÃO : 14/04/2016
 * OBJETIVO     : Mostrar campos da opcao G = Gera arquivo integração
 * --------------
 * ALTERAÇÕES   : 
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

/* Temporario para forcar a cooperativa Transulcred na lista */
$xml = "<Root>";
$xml .= " <Dados>";
$xml .= "   <cdcooper>17</cdcooper>";
$xml .= "   <flgativo>0</flgativo>";
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

$transulcred = $xmlObj->roottag->tags[0]->tags;

function exibeErroNew($msgErro) {
    echo 'hideMsgAguardo();';
    echo 'showError("error","' . $msgErro . '","Alerta - Ayllos","desbloqueia()");';
    exit();
}
 

?>
<div id="divFiltros">
<form id="frmFiltros" name="frmFiltros" class="formulario" style="display:none;">

	<div id="divCooper">
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
		<?php
		foreach ($transulcred as $r) {
			if ( getByTagName($r->tags, 'cdcooper') <> '' ) {
		?>
			<option value="<?= getByTagName($r->tags, 'cdcooper'); ?>"><?= getByTagName($r->tags, 'nmrescop'); ?></option> 
			
			<?php
			}
		}
		?>
		</select>
	</div>
    
	<br/>
    
    <div id="divInarquiv ">
		<label for="inarquiv"><? echo utf8ToHtml('Arquivo:') ?></label>
		<select id="inarquiv" name="inarquiv">
          <option value="0" <? echo $cdtiparq == '0' ? 'selected' : '' ?> > 0 - Todos </option> 		
          <option value="1" <? echo $cdtiparq == '1' ? 'selected' : '' ?> > 1 - Cadastro de Cooperados</option> 		
          <option value="2" <? echo $cdtiparq == '2' ? 'selected' : '' ?> > 2 - Cadastro de Titulares da conta</option>
          <option value="3" <? echo $cdtiparq == '3' ? 'selected' : '' ?> > 3 - Cadastro de Terceiros Vinculados a Conta</option>          
          <option value="4" <? echo $cdtiparq == '4' ? 'selected' : '' ?> > 4 - Saldo das Opera&ccedil;&otilde;es dos Cooperados</option> 		
          <option value="5" <? echo $cdtiparq == '5' ? 'selected' : '' ?> > 5 - Movimenta&ccedil;&atilde;o das Opera&ccedil;&otilde;es dos Cooperados</option> 		
		</select>
	</div>
    
	<label for="dtiniger"><? echo utf8ToHtml('Periodo de:') ?></label>
	<input id="dtiniger" name="dtiniger" type="text" />

	<label for="dtfimger"><? echo utf8ToHtml('ate:') ?></label>
	<input id="dtfimger" name="dtfimger" type="text"  />
		
	<br/>
	
	<br style="clear:both" />	
	<hr style="background-color:#666; height:1px;" />
	
	<div id="divBotoes" style="margin-bottom: 10px;">	
		<a href="#" class="botao" id="btVoltar" onClick="estadoInicial(); 	return false;">Voltar</a>	
		<a href="#" class="botao" id="btnAlterar" onClick="confirmaGeracao(); return false;">Gerar Arquivos</a>	
	</div>
	
</form>
</div>

<script type='text/javascript'>
	highlightObjFocus($('#frmFiltros')); 
</script>
