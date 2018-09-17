<?
/*!
 * FONTE        : form_cabecalho.php
 * CRIAÇÃO      : Jaison
 * DATA CRIAÇÃO : 03/09/2015
 * OBJETIVO     : Cabecalho para a tela ALTTAR
 * --------------
 * ALTERAÇÕES   : 26/11/2015 - Ajustado para buscar os convenios de folha
 *                             de pagamento. (Andre Santos - SUPERO) 
 * --------------
 */
	
	session_start();
	
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');		
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();		
	
	// Monta o xml de requisição
	$xmlConsulta  = "";
	$xmlConsulta .= "<Root>";
	$xmlConsulta .= "  <Cabecalho>";
	$xmlConsulta .= "    <Bo>b1wgen0153.p</Bo>";
	$xmlConsulta .= "    <Proc>lista-int</Proc>";
	$xmlConsulta .= "  </Cabecalho>";
	$xmlConsulta .= "  <Dados>";
	$xmlConsulta .= "    <cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlConsulta .= "    <cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xmlConsulta .= "    <nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xmlConsulta .= "    <cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xmlConsulta .= "    <nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
	$xmlConsulta .= "    <idorigem>".$glbvars["idorigem"]."</idorigem>";
	$xmlConsulta .= "    <nrregist>999</nrregist>";
	$xmlConsulta .= "    <nriniseq>1</nriniseq>";
	$xmlConsulta .= "    <cdinctar>0</cdinctar>";
	$xmlConsulta .= "  </Dados>";
	$xmlConsulta .= "</Root>";		
				
	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlConsulta);

	// Cria objeto para classe de tratamento de XML
	$xmlObjeto = getObjectXML($xmlResult);
	
	if (strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO") {
		exibirErro('error',$xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata,'Alerta - Ayllos',"controlaOperacao('')",false);
	}	
	
	$incidencia = $xmlObjeto->roottag->tags[0]->tags;
	
?>

<form id="frmCab" name="frmCab" class="formulario cabecalho" onSubmit="return false;" style="display:none">
	<input type="hidden" id="glbcdcooper" name="glbcdcooper" value="<? echo $glbvars["cdcooper"] ?>" />	
	<input type="hidden" id="glbdtmvtolt" name="glbdtmvtolt" value="<? echo $glbvars["dtmvtolt"] ?>" />	
	<input type="hidden" id="cdtipcat" name="cdtipcat" value="<? echo $cdtipcat == 0 ? '' : $cdtipcat ?>" />	
	<input type="hidden" id="cdinctar" name="cdinctar" value="<? echo $cdinctar == 0 ? '' : $cdinctar ?>" />	
	<table width="100%">
		<tr>		
			<td> 	
				<label for="cddopcao"><? echo utf8ToHtml('Op&ccedil;&atilde;o:') ?></label>
				<select id="cddopcao" name="cddopcao" style="width: 460px;">
					<option value="A"> A - Alterar Listagem de Tarifas </option>
				</select>
				<a href="#" class="botao" id="btnOK" name="btnOK" onClick="LiberaCampos(); return false;" style = "text-align:right;">OK</a>
			</td>
		</tr>
		<tr>
			<td>
				<label for="cdtarifa"><? echo utf8ToHtml('C&oacute;digo:') ?></label>
				<input type="text" id="cdtarifa" name="cdtarifa" value="<? echo $cdtarifa == 0 ? '' : $cdtarifa ?>" />	
				<a style="padding: 3px 0 0 3px;" href="#" onClick="controlaPesquisa(1);return false;"><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"/></a>				
				<input type="text" class="campo alphanum" name="dstarifa" id="dstarifa"  value="<? echo $dstarifa; ?>" />

			</td>
		</tr>
		<tr>
			<td>
				<label for="cddgrupo"><? echo utf8ToHtml('Grupo:') ?></label>
				<input type="text" id="cddgrupo" name="cddgrupo" value="<? echo $cddgrupo == 0 ? '' : $cddgrupo ?>" />	
				<a style="padding: 3px 0 0 3px;" href="#" onClick="controlaPesquisa(2);return false;"><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"/></a>				
				<input type="text" name="dsdgrupo" id="dsdgrupo"  value="<? echo $dsdgrupo; ?>" />
			</td>
		</tr>
		<tr>
			<td>
				<label for="cdsubgru"><? echo utf8ToHtml('Sub-grupo:') ?></label>
				<input type="text" id="cdsubgru" name="cdsubgru" value="<? echo $cdsubgru == 0 ? '' : $cdsubgru ?>" />	
				<a style="padding: 3px 0 0 3px;" href="#" onClick="controlaPesquisa(3);return false;"><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"/></a>				
				<input type="text" name="dssubgru" id="dssubgru"  value="<? echo $dssubgru; ?>" />
			</td>
		</tr>
		<tr>
			<td>
				<label for="cdcatego"><? echo utf8ToHtml('Categoria:') ?></label>
				<input type="text" id="cdcatego" name="cdcatego" value="<? echo $cdcatego == 0 ? '' : $cdcatego ?>" />	
				<a style="padding: 3px 0 0 3px;" href="#" onClick="controlaPesquisa(4);return false;"><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"/></a>				
				<input type="text" name="dscatego" id="dscatego"  value="<? echo $dscatego; ?>" />
			</td>
		</tr>
		<tr id="linCobranca" style="display:none;">
			<td>
				<label for="nrconven"><? echo utf8ToHtml('Conv&ecirc;nio:') ?></label>
				<input type="text" id="nrconven" name="nrconven" value="<? echo $nrconven == 0 ? '' : $nrconven ?>" />	
				<a style="padding: 3px 0 0 3px;" href="#" onClick="controlaPesquisa(5);return false;"><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"/></a>				
				<input type="text" name="dsconven" id="dsconven"  value="<? echo $dsconven; ?>" />
			</td>
		</tr>
		<tr id="linEmprestimo" style="display:none;">
			<td>
				<label for="cdlcremp"><? echo utf8ToHtml('Linha de Cr&eacute;dito:') ?></label>
				<input type="text" id="cdlcremp" name="cdlcremp" value="<? echo $cdlcremp == 0 ? '' : $cdlcremp ?>" />	
				<a style="padding: 3px 0 0 3px;" href="#" onClick="controlaPesquisa(6);return false;"><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"/></a>				
				<input type="text" name="dslcremp" id="dslcremp"  value="<? echo $dslcremp; ?>" />
			</td>
		</tr>
		<tr>
			<td>
                <label for="dtdivulg"><? echo utf8ToHtml('Data de divulga&ccedil;&atilde;o:') ?></label>
                <input type="text" id="dtdivulg" name="dtdivulg" value="<? echo $dtdivulg == 0 ? '' : $dtdivulg ?>" />	
                <label for="dtvigenc"><? echo utf8ToHtml('Data in&iacute;cio vig&ecirc;ncia:') ?></label>
                <input type="text" id="dtvigenc" name="dtvigenc" value="<? echo $dtvigenc == '' ? '' : $dtvigenc ?>" />
			</td>
		</tr>
	</table>
</form>