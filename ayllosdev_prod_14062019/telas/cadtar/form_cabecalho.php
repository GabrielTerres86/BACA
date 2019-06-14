<?
/*!
 * FONTE        : form_cabecalho.php
 * CRIAÇÃO      : Daniel Zimmermann         
 * DATA CRIAÇÃO : 
 * OBJETIVO     : Cabecalho para a tela CADTAR
 * --------------
 * ALTERAÇÕES   : 20/08/2013 - Alteracao layout e incluso campo cdtipcat (Daniel).
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

<form id="frmCab" name="frmCab" class="formulario cabecalho" onSubmit="return false;"  style="display:none">
	<input type="hidden" id="glbcdcooper" name="glbcdcooper" value="<? echo $glbvars["cdcooper"] ?>" />	
	<input type="hidden" id="glbdtmvtolt" name="glbdtmvtolt" value="<? echo $glbvars["dtmvtolt"] ?>" />	
	<input type="hidden" id="cdtipcat" name="cdtipcat" value="<? echo $cdtipcat == 0 ? '' : $cdtipcat ?>" />	
	<table width="100%">
		<tr>		
			<td> 	
				<label for="cddopcao"><? echo utf8ToHtml('Op&ccedil;&atilde;o:') ?></label>
				<select id="cddopcao" name="cddopcao" style="width: 460px;">
					<? if  ( $glbvars["cdcooper"] <> 3 ) { ?>
					<option value="X"> Consultar Tarifa e Alterar Detalhamento </option> 
					<? } ?>
					<? if  ( $glbvars["cdcooper"] == 3 ) { ?>
					<option value="C"> C - Consultar Tarifa </option> 
					<option value="A"> A - Alterar Tarifa </option>
					<option value="E"> E - Excluir Tarifa </option>
					<option value="I"> I - Incluir Tarifa </option>
					<? } ?>
				</select>
				<a href="#" class="botao" id="btnOK" name="btnOK" onClick="LiberaCampos(); return false;" style = "text-align:right;">OK</a>
			</td>
		</tr>
		<tr>
			<td>
				<label for="cddgrupo"><? echo utf8ToHtml('Grupo:') ?></label>
				<input type="text" id="cddgrupo" name="cddgrupo" value="<? echo $cddgrupo == 0 ? '' : $cddgrupo ?>" />	
				<a style="padding: 3px 0 0 3px;" href="#" onClick="controlaPesquisa(1);return false;"><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"/></a>				
				<input type="text" name="dsdgrupo" id="dsdgrupo"  value="<? echo $dsdgrupo; ?>" />
			</td>
		</tr>
		<tr>
			<td>
				<label for="cdsubgru"><? echo utf8ToHtml('Sub-grupo:') ?></label>
				<input type="text" id="cdsubgru" name="cdsubgru" value="<? echo $cdsubgru == 0 ? '' : $cdsubgru ?>" />	
				<a style="padding: 3px 0 0 3px;" href="#" onClick="controlaPesquisa(2);return false;"><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"/></a>				
				<input type="text" name="dssubgru" id="dssubgru"  value="<? echo $dssubgru; ?>" />
			</td>
		</tr>
		<tr>
			<td>
				<label for="cdcatego"><? echo utf8ToHtml('Categoria:') ?></label>
				<input type="text" id="cdcatego" name="cdcatego" value="<? echo $cdcatego == 0 ? '' : $cdcatego ?>" />	
				<a style="padding: 3px 0 0 3px;" href="#" onClick="controlaPesquisa(3);return false;"><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"/></a>				
				<input type="text" name="dscatego" id="dscatego"  value="<? echo $dscatego; ?>" />
			</td>
		</tr>
		<tr>
			<td>
				<label for="cdtarifa"><? echo utf8ToHtml('C&oacute;digo:') ?></label>
				<input type="text" id="cdtarifa" name="cdtarifa" value="<? echo $cdtarifa == 0 ? '' : $cdtarifa ?>" />	
				<a style="padding: 3px 0 0 3px;" href="#" onClick="controlaPesquisa(6);return false;"><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"/></a>				
				<input type="text" class="campo alphanum" name="dstarifa" id="dstarifa"  value="<? echo $dstarifa; ?>" />

			</td>
		</tr>
		<tr>
			<td>
				<label for="inpessoa">Aplic&aacute;vel a:</label>
				<select name="inpessoa" id="inpessoa">
					<option value="1">Pessoa F&iacute;sica</option> 
					<option value="2">Pessoa Jur&iacute;dica</option> 
				</select>	
			</td>
		</tr>
		<tr>
			<td>
				<input type="checkbox" id="flglaman" name="flglaman" style="margin-left:120px;margin-right:3px;" value="<? echo $flglaman == 'no' ? false : true ?>" />
				<label for="flglaman" style="margin-left:3px;margin-right:3px;"><? echo utf8ToHtml('Permite lan&ccedil;amento manual') ?></label>
				<input type="checkbox" id="flgpacta" name="flgpacta" style="margin-left:20px;margin-right:3px;" readonly value="<? echo $flgpacta == 'no' ? false : true ?>" />
				<label for="flgpacta" style="margin-left:3px;margin-right:3px;"><? echo utf8ToHtml('Habilita pacote de tarifas') ?></label>
			</td>
		</tr>
		<tr>
			<td>
				<label for="cdinctar">Tipo de Incid&ecirc;ncia:</label>
				<select name="cdinctar" id="cdinctar">
				<option value=""><? echo utf8ToHtml('< Nenhum >') ?></option> 
				
					<?
						$total = count($incidencia);						
						foreach($incidencia as $registro ) {
						
							$cdinctar = getByTagName($registro->tags,'cdinctar');
							$dsinctar = getByTagName($registro->tags,'dsinctar'); 
					?>
							<option value="<? echo $cdinctar; ?>"><? echo $dsinctar; ?></option>
					<? } ?>		
					
				</select>
			</td>
		</tr>
		<tr>
			<td>
				<div id="divOcorrenciaMotivo" name="divOcorrenciaMotivo" style="display:none">
					<label for="cdocorre"><? echo utf8ToHtml('Ocorr&ecirc;ncia:') ?></label>
					<input type="text" id="cdocorre" name="cdocorre" value="<? echo $cdocorre == 0 ? '' : $cdocorre ?>" />	
					<label for="cdmotivo"><? echo utf8ToHtml('Motivo da ocorr&ecirc;ncia:') ?></label>
					<input type="text" id="cdmotivo" name="cdmotivo" value="<? echo $cdmotivo == '' ? '' : $cdmotivo ?>" />
				</div>
			</td>
		</tr>
	</table>
</form>