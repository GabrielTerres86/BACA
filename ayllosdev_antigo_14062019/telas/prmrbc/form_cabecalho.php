<?php
/*!
 * FONTE        : form_cabecalho.php
 * CRIAÇÃO      : Andre Santos - SUPERO
 * DATA CRIAÇÃO : Janeiro/2014
 * OBJETIVO     : Mostrar tela PRMRBC
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
	
	$lsBureaux = ( isset($xmlObjeto->roottag->tags[0]->attributes['LISTA']) ) ? $xmlObjeto->roottag->tags[0]->attributes['LISTA'] : '';
	$qtBureaux = ( isset($xmlObjeto->roottag->tags[0]->attributes['QTD']) ) ? $xmlObjeto->roottag->tags[0]->attributes['QTD'] : 0;
	
	// Separando os registros
	$arrayBureaux = explode(',',$lsBureaux);

?>
<form id="frmCab" name="frmCab" class="formulario cabecalho" onSubmit="return false;" style="display:none">
	<label for="cddopcao"><? echo utf8ToHtml('Op&ccedil;&atilde;o:') ?></label>
	<select id="cddopcao" name="cddopcao" alt="Informe um dos tipos de remessa.">
		<option value="G"><? echo utf8ToHtml('Par&acirc;metros Gerais') ?></option>
		<option value="B"><? echo utf8ToHtml('Par&acirc;metros por Bureaux') ?></option>
	</select>
	<a href="#" class="botao" id="btnOK" style="float:none;" >OK</a>

    <div id="divCabBur" style="display:none">
	
		<br style="clear:both" />
	
		<label for="lstpreme"><? echo utf8ToHtml('Bureaux:') ?></label>
		<select id="lstpreme" name="lstpreme" alt="Informe um dos tipos de remessa.">
			<?php   for ($i = 0; $i < $qtBureaux; $i++){ ?>
			<option value="<?php echo $arrayBureaux[$i] ?>"><?php echo $arrayBureaux[$i] ?></option>
			<?php } ?>
		</select>
		<a href="#" class="botao" id="btnOK1" style="float:none;" >OK</a>
		
	</div>

	<br style="clear:both" />
</form>