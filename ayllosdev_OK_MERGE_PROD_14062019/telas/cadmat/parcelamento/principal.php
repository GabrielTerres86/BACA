<? 
/*!
 * FONTE        : principal.php
 * CRIAÇÃO      : Rodolpho Telmo (DB1)
 * DATA CRIAÇÃO : 23/06/2010 
 * OBJETIVO     : Entrada principal para a rotina de parcelamento da tela MATRIC
 *
 * ALTERAÇÃO    : 05/12/2016 - P341-Automatização BACENJUD - Removido passagem do departamento 
 *                             como parametros pois a BO não utiliza o mesmo (Renato Darosci)
 */
?>
<?
    session_start();
	require_once('../../../includes/config.php');
	require_once('../../../includes/funcoes.php');
	require_once('../../../includes/controla_secao.php');
	require_once('../../../class/xmlfile.php');
	isPostMethod();	
	
	// Guardo os parâmetos do POST em variáveis	
	$nrdconta = (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : '';
	$operParc = (isset($_POST['operParc'])) ? $_POST['operParc'] : '';
	$dtdebito = (isset($_POST['dtdebito'])) ? $_POST['dtdebito'] : '';
	$qtparcel = (isset($_POST['qtparcel'])) ? $_POST['qtparcel'] : '';
	$vlparcel = (isset($_POST['vlparcel'])) ? $_POST['vlparcel'] : '';
	$msgRetor = (isset($_POST['msgRetor'])) ? $_POST['msgRetor'] : '';
	
	if ( $operParc != '' ){
		// Monta o xml de requisição
		$xml  = '';
		$xml .= '<Root>';
		$xml .= '	<Cabecalho>';
		$xml .= '		<Bo>b1wgen0052.p</Bo>';
		$xml .= '		<Proc>valida_parcelamento</Proc>';
		$xml .= '	</Cabecalho>';
		$xml .= '	<Dados>';
		$xml .= '       <cdcooper>'.$glbvars['cdcooper'].'</cdcooper>';
		$xml .= '		<cdagenci>'.$glbvars['cdagenci'].'</cdagenci>';
		$xml .= '		<nrdcaixa>'.$glbvars['nrdcaixa'].'</nrdcaixa>';
		$xml .= '		<cdoperad>'.$glbvars['cdoperad'].'</cdoperad>';
		$xml .= '		<nmdatela>'.$glbvars['nmdatela'].'</nmdatela>';	
		$xml .= '		<idorigem>'.$glbvars['idorigem'].'</idorigem>';	
		$xml .= '		<nrdconta>'.$nrdconta.'</nrdconta>';
		$xml .= '		<dtdebito>'.$dtdebito.'</dtdebito>';
		$xml .= '		<qtparcel>'.$qtparcel.'</qtparcel>';
		$xml .= '		<vlparcel>'.$vlparcel.'</vlparcel>';
		$xml .= '	</Dados>';
		$xml .= '</Root>';
		
		$xmlResult = getDataXML($xml);	
		$xmlObjeto = getObjectXML($xmlResult);
		
		if (strtoupper($xmlObjeto->roottag->tags[0]->name) == 'ERRO') exibirErro('error',$xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata,'Alerta - Ayllos','bloqueiaFundo( $(\'#divUsoGenerico\') );',false);
		
		// Define a variágel que guarda todos os itens
		$registros = $xmlObjeto->roottag->tags[0]->tags;		
		
		//Recebo mensagem de retorno do Progress
		$msgRetParc = $xmlObjeto->roottag->tags[0]->attributes['MSGRETOR'];		
	}
	?>
	<form name="frmParcelamento" id="frmParcelamento" class="formulario condensado">
		<input name="msgRetor" id="msgRetor" type="hidden" value="<? echo $msgRetor; ?>" />
		
		<label for="dtdebito">Iniciar em:</label>
		<input name="dtdebito" id="dtdebito" type="text" value="<? echo $dtdebito; ?>" />
		<br />
		
		<label for="vlparcel">Valor a parcelar:</label>
		<input name="vlparcel" id="vlparcel" type="text" value="<? echo $vlparcel; ?>" />
		<br />
		
		<label for="qtparcel">Qtd. de parcelas:</label>
		<input name="qtparcel" id="qtparcel" type="text" value="<? echo $qtparcel; ?>" />
		<br style='clear:both;' />
	</form>
	<?
	include('tabela_parcelamento.php');
?>	
<script type="text/javascript">		
	var msgRetParc= '<? echo $msgRetParc;?>';
	controlaLayoutParcelamento('');
</script>