<?php
	/*!
	* FONTE        : form_cabecalho.php
	* CRIAÇÃO      : Andre Santos - SUPERO
	* DATA CRIAÇÃO : Novembro/2014
	* OBJETIVO     : Mostrar tela LOGRBC
	* --------------
	* ALTERAÇÕES   : 29/07/2016 - Corrigi o uso da funcao split depreciada. SD 480705 (Carlos R.)
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
	$xml  = '';
	$xml .= '<Root>';
	$xml .= '	<Dados>';
	$xml .= '       <cdcooper>'.$glbvars['cdcooper'].'</cdcooper>';
	$xml .= '		<cdagenci>'.$glbvars['cdagenci'].'</cdagenci>';
	$xml .= '		<nrdcaixa>'.$glbvars['nrdcaixa'].'</nrdcaixa>';
	$xml .= '		<cdoperad>'.$glbvars['cdoperad'].'</cdoperad>';
	$xml .= '		<nmdatela>'.$glbvars['nmdatela'].'</nmdatela>';
	$xml .= '		<idorigem>'.$glbvars['idorigem'].'</idorigem>';
	$xml .= '		<cdprogra>'.$glbvars['nmdatela'].'</cdprogra>';
	$xml .= '	</Dados>';
	$xml .= '</Root>';

	// Executa script para envio do XML e cria objeto para classe de tratamento de XML
	$xmlResult = mensageria($xml, "LOGRBC", "LISBURX", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["nmoperad"], "</Root>");
	$xmlObjeto = getObjectXML($xmlResult);

	// Se ocorrer um erro, mostra mensagem
	if (isset($xmlObjeto->roottag->tags[0]->name) && strtoupper($xmlObjeto->roottag->tags[0]->name) == 'ERRO') {
		$msgErro  = $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;
		exibirErro('error',$msgErro,'Alerta - Ayllos',$retornoAposErro,false);
	}
	
	$lsBureaux   = ( isset($xmlObjeto->roottag->tags[0]->attributes['LISTA']) ) ? $xmlObjeto->roottag->tags[0]->attributes['LISTA'] : '';
	$qtBureaux   = ( isset($xmlObjeto->roottag->tags[0]->attributes['QTD']) ) ? $xmlObjeto->roottag->tags[0]->attributes['QTD'] : 0;
	
	// Separando os registros
	$arrayBureaux = explode(',',$lsBureaux);

?>
<script>
	// Criando variavel DTMVTOLT para exibir a data cadastrada no sistema
	aux_dtmvtolt = "<?php echo $glbvars['dtmvtolt'] ; ?>";
</script>

<form id="frmCab" name="frmCab" class="formulario cabecalho" onSubmit="return false;" style="display:none">

	<div id="divConsulta">
		<label for="idtpreme">Bureaux:</label>
		<select id="idtpreme" onChange="consultaRemessa();" name="idtpreme" alt="Informe um dos tipos de remessa.">
			<?php   for ($i = 0; $i < $qtBureaux; $i++){ ?>
				<option value="<?php echo $arrayBureaux[$i] ?>"><?php echo $arrayBureaux[$i] ?></option>
			<?php } ?>
		</select>
				
		<label for="dtmvtolt">Data:</label>
		<input name="dtmvtolt" id="dtmvtolt" type="text" value="<? echo $glbvars['dtmvtolt'] ; ?>" autocomplete="off" />
		
		<label for="idpenden">Pendentes:</label>
		<input type="checkbox" id="idpenden" name="idpenden" value="1" checked>
		
		<!-- Forma encontrada para utilizar o OK como um botao para prosseguir com a pesquisa -->
		&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
		&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
		<a href="#" class="botao" id="btnOK" style="float:none;" >&nbsp;&nbsp;OK&nbsp;&nbsp;</a>
	</div>

	<div id="divEventos">
		<!-- Forma encontrada para montar o cabecalho acima do campo -->
	    <div id="divCab" style="display:none">
			<label for="lsarquiv1">Envio &nbsp;&nbsp; &nbsp; &nbsp; Retorno &nbsp;&nbsp; &nbsp; Devolu&ccedil;&atilde;o</label>
			<br />
			<br />
		</div>
		<label for="tpremess">Bureaux:</label>
		<input name="tpremess" id="tpremess" type="text" value="" />

		<label for="dtremess">Data:</label>
		<input name="dtremess" id="dtremess" type="text" value="" autocomplete="off" />

		<div id="divArquivos" style="display:none">
			<label for="lsarquiv">Remessa:</label>
			<select id="lsarquiv" onChange="pesquisaEventosArq();" name="lsarquiv" alt="Escolha um dos arquivos de remessa.">
			</select>
		</div>
		
		<div id="divArquivosCancel" style="display:none">
			<label for="lsarqcan">Remessa:</label>
			<select id="lsarqcan" name="lsarqcan" alt="Escolha um dos arquivos de remessa.">
			</select>
		</div>

		<div id="divCancelamento">
			<br /><br /><br />
			<label for="dscancel">Motivo do Cancelamento:</label>
			<textarea name="dscancel" id="dscancel" rows="5" cols="180"></textarea>
		</div>
		
		<input name="rowid" id="rowid" type="hidden" value="" />
		<input name="idopreto" id="idopreto" type="hidden" value="" />

	</div>

    <br style="clear:both" />
</form>