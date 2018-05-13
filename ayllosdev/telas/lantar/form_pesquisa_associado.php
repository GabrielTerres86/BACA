<?
/*!
 * FONTE        : form_pesquisa_associado.php
 * CRIAÇÃO      : Daniel Zimmermann
 * DATA CRIAÇÃO : 15/04/2012 
 * OBJETIVO     : Tela de exibição pesquisa associados
 * --------------
 * ALTERAÇÕES   : 15/08/2013 - Alteração da sigla PAC para PA (Carlos).
 */		
?>

<?

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
	$xmlConsulta .= "    <Proc>lista-tipo-conta</Proc>";
	$xmlConsulta .= "  </Cabecalho>";
	$xmlConsulta .= "  <Dados>";
	$xmlConsulta .= "    <cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlConsulta .= "    <cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xmlConsulta .= "    <nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xmlConsulta .= "    <cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xmlConsulta .= "    <nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
	$xmlConsulta .= "    <idorigem>".$glbvars["idorigem"]."</idorigem>";
	$xmlConsulta .= "  </Dados>";
	$xmlConsulta .= "</Root>";		
				
	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlConsulta);

	// Cria objeto para classe de tratamento de XML
	$xmlObjeto = getObjectXML($xmlResult);
	
	if (strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO") {
		exibirErro('error',$xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata,'Alerta - Ayllos',"controlaOperacao('')",false);
	}	
	
	$contas = $xmlObjeto->roottag->tags[0]->tags;
	
?>

<form id="frmPesquisaAssociado" name="frmPesquisaAssociado"  class="formulario" onSubmit="return false;"  >
	<table width="100%">
		<tr>		
			<td> 	
				<label for="nmprimtl"><? echo utf8ToHtml('Nome do titular') ?></label>
				<input class="campo alphanum" type="text" id="nmprimtl" name="nmprimtl" value="<? echo $nmprimtl == '' ? '' : $nmprimtl ?>" style="text-transform:uppercase;" />	
			</td>
		</tr>
		<tr>
			<td>
				<label for="cdagenci"><? echo utf8ToHtml('PA') ?></label>
				<input type="text" id="cdagenci" name="cdagenci" value="<? echo $cdagenci == 0 ? '' : $cdagenci ?>" />
				<a href="#" onclick="controlaPesquisaPac(); return false;"  style="padding: 3px 0 0 3px;"><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif" /></a>
				<label for="inpessoa"><? echo utf8ToHtml('Tipo pessoa') ?></label>
				<select name="inpessoa" id="inpessoa">
					<option value="1">1 - Pessoa F&iacute;sica</option> 
					<option value="2">2 - Pessoa Jur&iacute;dica</option> 
				</select>
				<label for="cdtipcta"><? echo utf8ToHtml('Tipo conta') ?></label>
				<select name="cdtipcta" id="cdtipcta">
				<option value=""><? echo utf8ToHtml('< Todos >') ?></option> 
					<?
						$total = count($contas);						
						foreach($contas as $registro ) {
						
							$cdtipcta = getByTagName($registro->tags,'cdtipcta');
							$dstipcta = getByTagName($registro->tags,'dstipcta'); 
					?>
							<option value="<? echo $cdtipcta; ?>"><? echo $cdtipcta; ?> - <? echo $dstipcta; ?></option>
					<? } ?>		
					
				</select>
			</td>
		</tr>
		<tr>
			<td>
				<input type="checkbox" id="flgchcus" name="flgchcus" value="<? echo $flgchcus == '' ? 'no' : 'yes' ?>" />
				<label for="flgchcus"><? echo utf8ToHtml('Contas com cheques custodiados') ?></label>
				<label for="mespsqch" style="clear:none"><? echo utf8ToHtml('Per&iacute;odo: ') ?></label>
				<select name="mespsqch" id="mespsqch" style="width: 90px;">
					<option value="1">Janeiro</option> 
					<option value="2">Fevereiro</option> 
					<option value="3">Março</option> 
					<option value="4">Abril</option> 
					<option value="5">Maio</option> 
					<option value="6">Junho</option> 
					<option value="7">Julho</option> 
					<option value="8">Agosto</option> 
					<option value="9">Setembro</option> 
					<option value="10">Outubro</option> 
					<option value="11">Novembro</option> 
					<option value="12">Dezembro</option> 
				</select>
				<label for="anopsqch"><? echo utf8ToHtml('Ano: ') ?></label>
				<input class="campo" type="text" id="anopsqch" name="anopsqch" />
			</td>
		</tr>
		<tr>
			<td>
				<div style="text-align:center;"> 
					<br style="clear:both" />	
					<a href="#" class="botao" id="btBuscar" style="float:none" onClick="buscaDadosAssociado(1,50); return false;">Iniciar Pesquisa</a>
					<br style="clear:both" />
				</div>
			</td>
		</tr>
	</table>
</form>

<div id="divConsultaAssociado" name="divConsultaAssociado" >	
</div>

<script>
	highlightObjFocus( $('#frmPesquisaAssociado') );
</script>