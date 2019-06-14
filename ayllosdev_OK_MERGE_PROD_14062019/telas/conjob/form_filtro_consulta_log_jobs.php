<?php
/*****************************************************************
  Fonte        : form_filtro.php						Última Alteração:  
  Criação      : Mateus Zimmermann - Mouts
  Data criação : Junho/2018
  Objetivo     : Mostrar os filtros para a consulta de logs de jobs da tela CONJOB
  --------------
	Alterações   :  
	
	
 ****************************************************************/
	
 	session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');	
	require_once('../../class/xmlfile.php');
	isPostMethod();	

	$xml = "<Root>";
	$xml .= " <Dados>";
	$xml .= "   <cdcooper>0</cdcooper>";
	$xml .= "   <flgativo>1</flgativo>";
	$xml .= " </Dados>";
	$xml .= "</Root>";

	$xmlResult = mensageria($xml, "PAREST", "PAREST_LISTA_COOPER", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObj = getObjectXML($xmlResult);

	if (strtoupper($xmlObj->roottag->tags[0]->name) == "ERRO") {
	    $msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
	    if ($msgErro == "") {
	        $msgErro = $xmlObj->roottag->tags[0]->cdata;
	    }

	    exibirErro('error',utf8_encode($msgErro),'Alerta - Ayllos','',false);
	}

	$registros = $xmlObj->roottag->tags[0]->tags;
	
?>

<form id="frmFiltroConsultaLogJobs" name="frmFiltroConsultaLogJobs" class="formulario" style="display:none;">	
	
	<fieldset id="fsetFiltroConsultaLogJobs" name="fsetFiltroConsultaLogJobs" style="padding:0px; margin:0px; padding-bottom:10px;">
	
		<legend><? echo "Filtros"; ?></legend>

		<label for="cdcooper"><? echo utf8ToHtml('Cooperativa:') ?></label>
	    <select id="cdcooper" name="cdcooper">
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

		<label for="nmjob">Job:</label>
		<input name="nmjob" id="nmjob" type="text" />
		<a><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"></a>

		<br />

		<label for="data_de">Data De:</label>
		<input name="data_de" id="data_de" type="text" />

		<label for="data_ate"><? echo utf8ToHtml('Data Até:') ?></label>
		<input name="data_ate" id="data_ate" type="text" />

		<label for="id_result">Resultado:</label>
		<select name="id_result" id="id_result" class="campo">
			<option value="-1">Todos</option>
			<option value="0">Erro</option>
			<option value="1">Sucesso</option>
		</select>

	</fieldset>
							
</form>

<div id="divBotoesFiltroConsultaLogJobs" style="margin-top:5px; margin-bottom :10px; display:none; text-align: center;">
		
	<a href="#" class="botao" id="btVoltar" onClick="controlaVoltar('1');">Voltar</a>
	<a href="#" class="botao" id="btProsseguir" onClick="controlaOperacao();return false;">Prosseguir</a>	
				
</div>

<script type="text/javascript">
	
	formataFiltroConsultaLogJobs();
    	 
</script>
