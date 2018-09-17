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

$cddopcao = $_POST['cddopcao'] == '' ? 'C'  : $_POST['cddopcao'];

// Guardo o número da conta e titular em variáveis
$nrdconta = $_POST['nrdconta'] == '' ? 0    : $_POST['nrdconta'];
$idseqttl = $_POST['idseqttl'] == '' ? 0    : $_POST['idseqttl'];
$nrcpfcgc = $_POST['nrcpfcgc'] == '' ? 0    : $_POST['nrcpfcgc'];
$nrdctato = $_POST['nrdctato'] == '' ? 0    : $_POST['nrdctato'];	
$nrdrowid = $_POST['nrdrowid'] == '' ? 0    : $_POST['nrdrowid'];	
$operacao = $_POST['operacao'] == '' ? 'CT' : $_POST['operacao'];

// Monta o xml de requisição
$xml  = '';
$xml .= '<Root>';
$xml .= '	<Cabecalho>';
$xml .= '		<Bo>b1wgen0080.p</Bo>';
$xml .= '		<Proc>busca_dados</Proc>';
$xml .= '	</Cabecalho>';
$xml .= '	<Dados>';
$xml .= '		<cdcooper>'.$glbvars['cdcooper'].'</cdcooper>';
$xml .= '		<cdagenci>'.$glbvars['cdagenci'].'</cdagenci>';
$xml .= '		<nrdcaixa>'.$glbvars['nrdcaixa'].'</nrdcaixa>';
$xml .= '		<cdoperad>'.$glbvars['cdoperad'].'</cdoperad>';
$xml .= '		<nmdatela>'.$glbvars['nmdatela'].'</nmdatela>';
$xml .= '		<idorigem>'.$glbvars['idorigem'].'</idorigem>';
$xml .= '		<nrdconta>'.$nrdconta.'</nrdconta>';
$xml .= '		<idseqttl>'.$idseqttl.'</idseqttl>';
$xml .= '		<nrcpfcgc>'.$nrcpfcgc.'</nrcpfcgc>';	
$xml .= '		<cddopcao>'.$cddopcao.'</cddopcao>';	
$xml .= '		<nrdctato>'.$nrdctato.'</nrdctato>';	
$xml .= '		<nrdrowid>'.$nrdrowid.'</nrdrowid>';	
$xml .= '	</Dados>';
$xml .= '</Root>';		

$xmlResult = getDataXML($xml);
$xmlObjeto = getObjectXML($xmlResult);	
$registros = $xmlObjeto->roottag->tags[0]->tags;
?>

<form id="frmConsultaDados" class="formulario" name="frmConsultaDados">
	<fieldset>
		<legend>Participaç&atilde;o Empresas</legend>
		<div class="divRegistros divRegistrosC">
			<table>
				<thead>
					<tr><th>Conta/dv</th>
						<th>Raz&atilde;o Social</th>
						<th>C.N.P.J.</th>
						<th>% Societ&aacute;rio</th>
					</tr>			
				</thead>
				<tbody>
					<?foreach($registros as $empresasPart) {?>
						<tr>
							<td><span><? echo str_replace($search,'',getByTagName($empresasPart->tags,'cddconta')) ?></span>
								<? echo getByTagName($empresasPart->tags,'cddconta'); ?></td>
							<td><? echo stringTabela(getByTagName($empresasPart->tags,'nmprimtl'),30,'maiuscula') ?></td>
							<td><span><? echo str_replace($search,'',getByTagName($empresasPart->tags,'cdcpfcgc')) ?></span>
							<? echo trim(getByTagName($empresasPart->tags,'cdcpfcgc')) ?></td>
							<td><span><? echo str_replace($search,'',getByTagName($empresasPart->tags,'persocio')) ?></span>
							<? echo number_format(str_replace(',','.',getByTagName($empresasPart->tags,'persocio')),2,',','.') ?></td>
						</tr>				
					<? } ?>			
				</tbody>		
			</table>
		</div>
	</fieldset>
</form>