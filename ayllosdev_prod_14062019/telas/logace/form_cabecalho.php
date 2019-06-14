<?
/*!
 * FONTE        : form_cabecalho.php
 * CRIAÇÃO      : Guilherme Boettcher (Supero)
 * DATA CRIAÇÃO : 14/02/2013
 * OBJETIVO     : Cabeçalho para a tela LOGACE
 * --------------
 * ALTERAÇÕES   :
 *
 * --------------
 */

	session_start();

	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();


	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"C")) <> "") {
		exibeErro($msgError);
	}
	// Monta o xml de requisição
	$xmlCooperativas  = "";
	$xmlCooperativas .= "<Root>";
	$xmlCooperativas .= "	<Cabecalho>";
	$xmlCooperativas .= "		<Bo>b1wgen0013.p</Bo>";
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

	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjCooperativas->roottag->tags[0]->name) == "ERRO") {
		exibeErro($xmlObjCooperativas->roottag->tags[0]->tags[0]->tags[4]->cdata);
	}

	$cooperativas   = $xmlObjCooperativas->roottag->tags[0]->tags;
	$qtCooperativas = count($cooperativas);

?>

<form id="frmCab" name="frmCab" class="formulario cabecalho" onSubmit="return false;" style="display:none">
    <table width="100%">
		<tr>
			<td>
				<label for="cdcooper"><? echo utf8ToHtml('Cooperativa:') ?></label>
				<select id="cdcooper" name="cdcooper" style="width: 150px;">
				<option value="99">TODAS</option>
			<?php   for ($i = 0; $i < $qtCooperativas; $i++){
						$cdcooper = getByTagName($cooperativas[$i]->tags,"CDCOOPER");
						$nmrescop = getByTagName($cooperativas[$i]->tags,"NMRESCOP");?>
				<option value="<?php echo $cdcooper ?>"><?php echo $nmrescop ?></option>
			<?php } ?>
				</select>
		    </td>
		</tr>
		<tr>
			<td>
				<label for="dsdatela">Nome da Tela:</label>
				<input type="text" id="dsdatela" name="dsdatela" class="campo" maxlength="6"/>
			</td>
		</tr>
		<tr>
			<td>
				<label for="idorigem">Origem do Acesso:</label>
				<select id="idorigem" name="idorigem" style="width: 120px;">
					<option value="0"><? echo utf8ToHtml(' Ambas Origens');  ?></option>
					<option value="1"><? echo utf8ToHtml(' Ayllos Caracter');  ?></option>
					<option value="2"><? echo utf8ToHtml(' Ayllos WEB');  ?></option>
				</select>
			</td>
		</tr>
		<tr>
			<td>
				<label for="cdfiltro">Filtro por Acesso:</label>
				<select id="cdfiltro" name="cdfiltro" style="width: 79px;" onChange="ocultar(this.value); return false;">
					<option value="1"><? echo utf8ToHtml(' Telas acessadas no período');  ?></option>
					<option value="2"><? echo utf8ToHtml(' Telas NÃO acessadas no período');  ?></option>
					<option value="3"><? echo utf8ToHtml(' Telas Nunca Acessadas');  ?></option>
				</select>
			</td>
		</tr>
		<tr>
			<td>
				<div id="DivPeriodo">
					<label for="dtiniper">Per&iacute;odo de Acesso:</label>
					<input type="text" id="dtiniper" name="dtiniper" class="campo"/>
					<label for="dtfimper"> at&eacute; </label>
					<input type="text" id="dtfimper" name="dtfimper" class="campo" value="<? echo $dtfimper ?>" />
				</div>
			</td>
		</tr>
	</table>
</form>
<div id="divResultado" style="display:block;">
</div>
<script>
$('#dsdatela').keyup(function(){
    this.value = this.value.toUpperCase();
});
</script>