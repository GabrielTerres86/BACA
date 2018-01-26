<?php
/*!
* FONTE        : responsavel_legal.php
* CRIAÇÃO      : Andrey Formigari (Mouts)
* DATA CRIAÇÃO : Setembro/2017
* OBJETIVO     : Listar Responsaveis Legais na tela CADCTA
* --------------
* ALTERAÇÕES   :
* --------------
*/

session_start();	
require_once("../../includes/config.php");
require_once("../../includes/funcoes.php");		
require_once("../../includes/controla_secao.php");
require_once("../../class/xmlfile.php");	
isPostMethod();

$cddopcao = (isset($_POST['cddopcao'])) ? $_POST['cddopcao'] : 'C';

// Guardo os parâmetos do POST em variáveis
$nrdconta = (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : '';
$idseqttl = (isset($_POST['idseqttl'])) ? $_POST['idseqttl'] : '';
$nrdrowid = (isset($_POST['nrdrowid'])) ? $_POST['nrdrowid'] : '';
$operacao = (isset($_POST['operacao'])) ? $_POST['operacao'] : '';
$cdrelato = (isset($_POST['cdrelato'])) ? $_POST['cdrelato'] : '';
$cdprogra = (isset($_POST['cdprogra'])) ? $_POST['cdprogra'] : '';
$cddfrenv = (isset($_POST['cddfrenv'])) ? $_POST['cddfrenv'] : '';
$cdperiod = (isset($_POST['cdperiod'])) ? $_POST['cdperiod'] : '';

// Monta o xml de requisição
$xml  = '';
$xml .= '<Root>';
$xml .= '	<Cabecalho>';
$xml .= '		<Bo>b1wgen0064.p</Bo>';
$xml .= '		<Proc>busca_dados</Proc>';
$xml .= '	</Cabecalho>';
$xml .= '	<Dados>';
$xml .= '       <cdcooper>'.$glbvars['cdcooper'].'</cdcooper>';
$xml .= '		<cdagenci>'.$glbvars['cdagenci'].'</cdagenci>';
$xml .= '		<nrdcaixa>'.$glbvars['nrdcaixa'].'</nrdcaixa>';
$xml .= '		<cdoperad>'.$glbvars['cdoperad'].'</cdoperad>';
$xml .= '		<nmdatela>'.$glbvars['nmdatela'].'</nmdatela>';	
$xml .= '		<idorigem>'.$glbvars['idorigem'].'</idorigem>';	
$xml .= '		<nrdconta>'.$nrdconta.'</nrdconta>';
$xml .= '		<idseqttl>'.$idseqttl.'</idseqttl>';
$xml .= '		<nrdrowid>'.$nrdrowid.'</nrdrowid>';
$xml .= '		<cddopcao>'.$cddopcao.'</cddopcao>';
$xml .= '		<cdrelato>'.$cdrelato.'</cdrelato>';
$xml .= '		<cdprogra>'.$cdprogra.'</cdprogra>';
$xml .= '		<cddfrenv>'.$cddfrenv.'</cddfrenv>';
$xml .= '		<cdperiod>'.$cdperiod.'</cdperiod>';
$xml .= '		<nriniseq>1</nriniseq>';
$xml .= '		<nrregist>9999</nrregist>';
$xml .= '	</Dados>';
$xml .= '</Root>';

$xmlResult = getDataXML($xml);
$xmlObjeto = getObjectXML($xmlResult);	
$registros = $xmlObjeto->roottag->tags[0]->tags;
?>

<form id="frmConsultaDados" class="formulario" name="frmConsultaDados">
<fieldset>
<legend>Informativos</legend>
<div class="divRegistros divRegistrosC">
	<table>
		<thead>
			<tr>
				<th>Informativo</th>
				<th>Forma Envio</th>
				<th><? echo utf8ToHtml('Período');?></th>
				<th>Recebimento</th>
			</tr>			
		</thead>
		<tbody>
			<? foreach( $registros as $registro ) {?>
				<tr><td><span><? echo getByTagName($registro->tags,'nmrelato') ?></span>
					<? echo getByTagName($registro->tags,'nmrelato') ?>
					<input type="hidden" id="nrdrowid" name="nrdrowid" value="<? echo getByTagName($registro->tags,'nrdrowid') ?>" /></td>					
					<td><? echo getByTagName($registro->tags,'dsdfrenv') ?></td>
					<td><? echo getByTagName($registro->tags,'dsperiod'); ?></td>
					<td><span><? echo getByTagName($registro->tags,'dsrecebe'); ?></span>
						<? echo stringTabela(getByTagName($registro->tags,'dsrecebe'),22,'minuscula')?></td>
					</tr>				
					<? } ?>			
				</tbody>		
			</table>
		</div>
	</fieldset>
</form>
<script type="text/javascript">	
</script>