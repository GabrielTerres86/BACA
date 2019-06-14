<?php
/*!
 * FONTE        : busca_cheques_resgatados.php
 * CRIAÇÃO      : Mateus Zimmermann (Mouts)
 * DATA CRIAÇÃO : 15/12/2017
 * OBJETIVO     : Rotina para buscar os cheques custodiados resgatados
 * --------------
 * ALTERAÇÕES   : 02/05/2019 - Alterado o metodo de formatacao "number_format" para a function formataMoeda().
 *                             (Daniel Lombardi - Mouts'S) 
 * -------------- 
 */		

session_start();
require_once('../../includes/config.php');
require_once('../../includes/funcoes.php');
require_once('../../includes/controla_secao.php');
require_once('../../class/xmlfile.php');
isPostMethod();			

$nrdconta = !isset($_POST["nrdconta"]) ? 0  : $_POST["nrdconta"];
$dtresgat = !isset($_POST["dtresgat"]) ? "" : $_POST["dtresgat"];
$nrcheque = !isset($_POST["nrcheque"]) ? "" : $_POST["nrcheque"];

if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],"L")) <> '') {
	exibirErro('error',$msgError,'Alerta - Aimaro','',false);
}

// Verifica se os parâmetros necessários foram informados
if (!validaInteiro($nrdconta)) exibirErro('error','Conta inv&aacute;lida.','Alerta - Aimaro','',false);
if ($dtresgat == "" && $nrcheque == "") exibirErro('error','Preencha a data ou n&uacute;mero do cheque.','Alerta - Aimaro','',false);

// Montar o xml de Requisicao
$xml  = "<Root>";
$xml .= " <Dados>";
$xml .= "   <nrdconta>".$nrdconta."</nrdconta>";
$xml .= "   <dtresgat>".$dtresgat."</dtresgat>";
$xml .= "   <nrcheque>".$nrcheque."</nrcheque>";
$xml .= " </Dados>";
$xml .= "</Root>";

$xmlResult = mensageria($xml, "TELA_CUSTOD", "BUSCA_CHEQUES_RESGATADOS", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
$xmlObj = getObjectXML($xmlResult);		
//-----------------------------------------------------------------------------------------------
// Controle de Erros
//-----------------------------------------------------------------------------------------------

if(strtoupper($xmlObj->roottag->tags[0]->name == 'ERRO')){	
	$msgErro = $xmlObj->roottag->tags[0]->cdata;
	if($msgErro == null || $msgErro == ''){
		$msgErro = utf8_encode($xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata);
	}
	exibirErro('error',$msgErro,'Alerta - Aimaro','',false);
	exit();
}

?>
<div class="divRegistros" id="divCheques">	
	<table class="tituloRegistros" id="tbCheques">
		<thead>
			<tr>
				<th></th>
				<th>Compe</th>
				<th>Banco</th>
				<th>Ag&ecirc;ncia</th>
				<th>Cheque</th>
				<th>Valor</th>
				<th>CMC-7</th>
			</tr>
		</thead>
		<tbody>
			<?
			foreach($xmlObj->roottag->tags[0]->tags as $infoCheque){
				$aux_dsdocmc7 = $infoCheque->tags[0]->cdata; // Cmc7
				$aux_cddbanco = substr($aux_dsdocmc7, 1, 3); // Cód. do banco
				$aux_cdagenci = substr($aux_dsdocmc7, 4, 4); // Cód. da agencia
				$aux_compcheq = substr($aux_dsdocmc7, 10, 3); // Comp
				$aux_nrcheque = substr($aux_dsdocmc7, 13, 6); // Nr. do cheque	
				$aux_vlcheque = $infoCheque->tags[1]->cdata; // Valor cheque
				//$aux_nomeresg = $infoCheque->tags[2]->cdata; // Nome da pessoa que resgatou
				//$aux_docuresg = $infoCheque->tags[3]->cdata; // Documento(CPF) da pessoa que resgatou
				?>
				<tr>
					<td><input type="checkbox" id="flgcompr<? echo $aux_nrcheque ?>" name="flgcompr<? echo $aux_nrcheque ?>"></td>
					<td><input type="hidden" id="aux_comp" name="aux_comp" value="<? echo $aux_compcheq ?>"><? echo $aux_compcheq ?></td>
					<td><input type="hidden" id="aux_banco" name="aux_banco" value="<? echo $aux_cddbanco ?>"><? echo $aux_cddbanco ?></td>
					<td><input type="hidden" id="aux_agencia" name="aux_agencia" value="<? echo $aux_cdagenci ?>"><? echo $aux_cdagenci ?></td>
					<td><input type="hidden" id="aux_cheque" name="aux_cheque" value="<? echo $aux_nrcheque ?>"><? echo $aux_nrcheque ?></td>
					<td><input type="hidden" id="aux_vlcheque" name="aux_vlcheque" value="<? echo formataMoeda($aux_vlcheque) ?>"><? echo formataMoeda($aux_vlcheque) ?></td>
          <td><input type="hidden" id="aux_cmc7" name="aux_cmc7" value="<? echo $aux_dsdocmc7?>"><? echo $aux_dsdocmc7 ?></td>
				</tr>
			<?
			}		
		?>
		</tbody>
	</table>
</div>
