<?
/*!
 * FONTE        : LISTAL.php
 * CRIAÇÃO      : André Euzébio / SUPERO
 * DATA CRIAÇÃO : 16/08/2013
 * OBJETIVO     : Formulário - tela LISTAL
 * --------------
 * ALTERAÇÕES   : 147/10/2013 - Ajustado "C" para "@" na validação de permissão e retirado
								a chamada da função exibeErro(Adriano);
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

	// Classe para leitura do xml de retorno
	require_once("../../class/xmlfile.php");

	// Monta o xml de requisição
	$xmlCooperativas  = "";
	$xmlCooperativas .= "<Root>";
	$xmlCooperativas .= "	<Cabecalho>";
	$xmlCooperativas .= "		<Bo>b1wgen9999.p</Bo>";
	$xmlCooperativas .= "		<Proc>consulta-cooperativas</Proc>";
	$xmlCooperativas .= "	</Cabecalho>";
	$xmlCooperativas .= "	<Dados>";
	$xmlCooperativas .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlCooperativas .= "	</Dados>";
	$xmlCooperativas .= "</Root>";

	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlCooperativas);


	// Cria objeto para classe de tratamento de XML
	$xmlObjCooperativas = getObjectXML($xmlResult);

	$cooperativas   = $xmlObjCooperativas->roottag->tags[0]->tags;
	$qtCooperativas = count($cooperativas);
		

?>

<form id="frmCab" name="frmCab" class="formulario" onSubmit="return false;" style="display:none">
<fieldset>
    <legend><? echo utf8ToHtml('Par&acirc;metros de Pesquisa') ?></legend>

    <label for="cddopcao"><? echo utf8ToHtml('Op&ccedil;&atilde;o:') ?></label>
    <select id="cddopcao" name="cddopcao">
        <option value="T"> T - Visualizar relat&oacute;rio </option>
        <option value="I"> I - Imprimir relat&oacute;rio </option>
    </select>
    <a href="#" class="botao" id="btnOK" name="btnOK" onClick="LiberaCampos()"; return false;" style = "text-align:right;" >OK</a>
    <br style="clear:both" />


    <label for="cdcooper"><? echo utf8ToHtml('Cooperativa:') ?></label>
    <select id="cdcooper" name="cdcooper" style="width: 150px;">
        <option value="0">TODAS</option>
        <?php   for ($i = 0; $i < $qtCooperativas; $i++){
        $cdcooper = getByTagName($cooperativas[$i]->tags,"CDCOOPER");
        $nmrescop = getByTagName($cooperativas[$i]->tags,"NMRESCOP");?>
        <option value="<?php echo $cdcooper ?>"><?php echo $nmrescop ?></option>
        <?php } ?>
    </select>
    <br style="clear:both" />


	<label for="insitreq">Situacao Requisição:</label>
	<select id="insitreq" name="insitreq" style="width: 120px;">
		<option value="1"><? echo utf8ToHtml(' N&atilde;o executado'); ?></option>
		<option value="2"><? echo utf8ToHtml(' Executado');     ?></option>
		<option value="3"><? echo utf8ToHtml(' Rejeitado');     ?></option>
	</select>
	<br style="clear:both" />

	<label for="tprequis">Tipo Requisição:</label>
	<select id="tprequis" name="tprequis" style="width: 120px;">
		<option value="5"><? echo utf8ToHtml(' Avulso A4');             ?></option>
		<option value="2"><? echo utf8ToHtml(' TB');                    ?></option>
		<option value="3"><? echo utf8ToHtml(' Formul&aacute;rio Cont&iacute;nuo');   ?></option>
		<option value="8"><? echo utf8ToHtml(' Bloqueto Pr&eacute;-Impresso'); ?></option>
	</select>
	<br style="clear:both" />

    <label for="dtinicio"><? echo utf8ToHtml('Periodo:') ?></label>
    <input name="dtinicio" id="dtinicio" type="text" value="<? echo $dtinicio ?>" autocomplete="off" />

    <label for="dttermin"><? echo utf8ToHtml('a') ?></label>
    <input name="dttermin" id="dttermin" type="text" value="<? echo $dttermin ?>" autocomplete="off" />
    <br style="clear:both" />

</fieldset>

</form>

<br style="clear:both" />
<div id="divResultado" style="display:block;">
</div>
<form name="frmImprimir" id="frmImprimir">
	<input type="hidden" name="sidlogin" id="sidlogin" value="<?php echo $glbvars["sidlogin"]; ?>">
	<input name="cddopcao" id="cddopcao" type="hidden" value="" />
    <input name="cdcooper" id="cdcooper" type="hidden" value="" />
    <input name="insitreq" id="insitreq" type="hidden" value="" />
    <input name="tprequis" id="tprequis" type="hidden" value="" />
	<input name="dtinicio" id="dtinicio" type="hidden" value="" />
	<input name="dttermin" id="dttermin" type="hidden" value="" />

</form>