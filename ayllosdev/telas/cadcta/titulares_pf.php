<?php
/*!
 * FONTE        : titulares_pf.php
 * CRIAÇÃO      : Andrey Formigari (Mouts)
 * DATA CRIAÇÃO : Setembro/2017
 * OBJETIVO     : Listar titulares na tela CADCTA
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

$nrdconta = $_POST["nrdconta"] == "" ? 0 : $_POST["nrdconta"];
 
$xml  = "";
$xml .= "<Root>";
$xml .= "	<Cabecalho>";
$xml .= "		<Bo>b1wgen0059.p</Bo>";
$xml .= "		<Proc>busca_crapttl</Proc>";
$xml .= "	</Cabecalho>";
$xml .= "	<Dados>";
$xml .= "       <cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
$xml .= "		<nrdconta>".$nrdconta."</nrdconta>";
$xml .= "		<nrregist>4</nrregist>";
$xml .= "		<nriniseq>1</nriniseq>";
$xml .= "	</Dados>";
$xml .= "</Root>";

// Executa script para envio do XML
$xmlResult = getDataXML($xml);

// Cria objeto para classe de tratamento de XML
$xmlObjImp = getObjectXML($xmlResult);

$registros = $xmlObjImp->roottag->tags[0]->tags;

function getRelacionamento($cdgraupr){
	switch($cdgraupr){
		case 1:
			return '1 - CÔNJUGE';
		case 2:
			return '2 - PAI / MÃE';
		case 3:
			return '3 - FILHO(A)';
		case 4:
			return '4 - COMPANHEIRO(A)';
		case 6:
			return '6 - COOPERADO(A)';
		default:
			return '0 - PRIMEIRO TITULAR';
	}
}		
?>

<form id="frmConsultaDados" class="formulario" name="frmConsultaDados">
	<fieldset>
		<legend>Titulares</legend>
		<div class="divRegistros divRegistrosC">
			<table>
				<thead>
				<tr><th>Conta/dv</th>
					<th>Nome</th>
					<th>C.P.F.</th>
					<th>Relacionamento</th>
				</tr>			
				</thead>
				<tbody> 
					<?php
                        $idttl = 0; 
						foreach($registros as $registro){
					?>
					<tr id="<? echo $idttl; ?>" >
						<td><?php echo formataContaDV(getByTagName($registro->tags,'nrcadast')); ?>
                        <input type='hidden' name='idseqttl' id='idseqttl' value='<? echo getByTagName($registro->tags,'idseqttl'); ?>'>                        
                        <input type='hidden' name='nrcpfcgc' id='nrcpfcgc' value='<? echo getByTagName($registro->tags,'nrcpfcgc'); ?>'>                        
                        </td>
						<td style="max-width: 200px; overflow-x: hidden; white-space: nowrap;">
                             <?php echo getByTagName($registro->tags,'idseqttl'). ' - ' .getByTagName($registro->tags,'nmextttl'); ?>
                        </td>
						<td><?php echo formataNumericos('999.999.999-10', getByTagName($registro->tags,'nrcpfcgc'),'.-'); ?></td>
						<td><?php echo getRelacionamento(getByTagName($registro->tags,'cdgraupr')); ?></td>
					</tr>
					<? $idttl++; } ?>
				</tbody>		
			</table>
		</div>
	</fieldset>
</form>