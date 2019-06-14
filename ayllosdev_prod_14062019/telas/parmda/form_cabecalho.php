<?
/*!
 * FONTE        : parmda.php
 * CRIAÇÃO      : Dionathan Henchel
 * DATA CRIAÇÃO : 04/05/2016
 * OBJETIVO     : Cabeçalho para a tela PARMDA
 * --------------
 * ALTERAÇÕES   : 30/08/2017 - Incluir a listagem dos produtos através da chamada da ação
 * 							   LISTA_PRODUTOS da mensageria, afim de listar os produtos a 
 *							   serem populados no select. (Renato Darosci - Prj360)
 */ 

/**  BUSCAR A LISTAGEM DE COOPERATIVAS  **/
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

/**  BUSCAR A LISTAGEM DE PRODUTOS  **/

$xml = "<Root>";
$xml .= " <Dados>";
$xml .= " </Dados>";
$xml .= "</Root>";

$xmlResult = mensageria($xml, "PARMDA", "LISTA_PRODUTOS", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
$xmlObj = getObjectXML($xmlResult);

if (strtoupper($xmlObj->roottag->tags[0]->name) == "ERRO") {
    $msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
    if ($msgErro == "") {
        $msgErro = $xmlObj->roottag->tags[0]->cdata;
    }

    exibeErroNew($msgErro);
    exit();
}

$produtos = $xmlObj->roottag->tags;



function exibeErroNew($msgErro) {
    echo 'hideMsgAguardo();';
    echo 'showError("error","' . $msgErro . '","Alerta - Ayllos","desbloqueia()");';
    exit();
}
 
?>

<form id="frmCab" name="frmCab" class="formulario cabecalho">
		<!-- OPÇÕES -->
	<label for="cddopcao"><? echo utf8ToHtml('Opção:') ?></label>
	<select id="cddopcao" name="cddopcao" alt="Informe a opcao desejada (A)." onchange="habilitaopcaotodas();">
		<option value="C"> <? echo utf8ToHtml('C - Consultar Parâmetros') ?> </option>
		<option value="A"> <? echo utf8ToHtml('A - Alterar Parâmetros') ?> </option>
		<?php //<option value="E"> echo utf8ToHtml('E - Excluir Parâmetros') </option> ?>
	</select>
		<!-- PRODUTO -->
		<label for="cdprodut"><? echo utf8ToHtml('Produto:') ?></label>
		<select id="cdprodut" name="cdprodut">
		    <option value=""></option> 
			<?php
			foreach ($produtos as $p) {
				
				if ( getByTagName($p->tags, 'cdproduto') <> '' ) {
			?>
				<option value="<?= getByTagName($p->tags, 'cdproduto'); ?>"><?= getByTagName($p->tags, 'dsproduto'); ?></option> 
				
			<?php
				}
			}
			?>
		</select>
		<!-- COOPERATIVA -->
	<label for="cdcooper"><? echo utf8ToHtml('Cooperativa:') ?></label>
	<select id="cdcooper" name="cdcooper">
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

	<a href="#" class="botao" id="btnOK" name="btnOK" onClick="LiberaCampos(); return false;" style = "text-align:right;">OK</a>
	
	<br style="clear:both" />
	
</form>

<script type='text/javascript'>
	formataCabecalho();
</script>