<?php
/* !
 * FONTE        : manter_rotina.php
 * CRIAÇÃO      : Luiz Otávio Olinger Momm - AMcom
 * DATA CRIAÇÃO : 05/02/2019
 * OBJETIVO     : Rotina para controlar as operações da tela RATMOV
 * --------------
 * ALTERAÇÕES   :
 * 
 * 001: [28/03/2019] - P450 - Alteração na visualização da consulta do Alterar Rating P450 (Luiz Otávio Olinger Momm - AMCOM).
 * 002: [15/04/2019] - Identificação quando for Analisar e quando for Alterar Rating P450 (Luiz Otávio Olinger Momm - AMCOM).
 * 003: [30/05/2019] - P450 - Trocado a sigla do limite de crédito de CRE para LIM (Luiz Otávio Olinger Momm - AMCOM).
 * 004: [15/08/2019] - P450 - Adicionado Produto Pré Aprovado (Luiz Otavio Olinger Momm - AMCOM).
 */

// error_reporting(E_ALL ^ E_NOTICE);
// ini_set('display_errors', 1);

session_start();
require_once('../../includes/config.php');
require_once('../../includes/funcoes.php');
require_once('../../includes/controla_secao.php');
require_once('../../class/xmlfile.php');
isPostMethod();

$arrtpproduto = array();
$arrtpproduto[90] = array('descricao' => 'Empréstimo/financiamento',    'sigla' => 'EMP');
$arrtpproduto[2] =  array('descricao' => 'Limite Desconto Cheque',      'sigla' => 'CHQ');
$arrtpproduto[1] =  array('descricao' => 'Limite Crédito',              'sigla' => 'LIM');;
$arrtpproduto[3] =  array('descricao' => 'Desconto Título',             'sigla' => 'TIT');
$arrtpproduto[68] = array('descricao' => 'Limites de Pré-aprovado',     'sigla' => 'LPA');
$GLOBALS['arrtpproduto'] = $arrtpproduto;

$arrfinalidade = array();
$arrfinalidade[68] = array('descricao' => 'Contratos de Pré-aprovado',  'sigla' => 'CPA');
$GLOBALS['arrfinalidade'] = $arrfinalidade;

$arrtpstatus = array();
$arrtpstatus[0] = array('descricao' => 'Não Enviado');
$arrtpstatus[1] = array('descricao' => 'Em Análise');
$arrtpstatus[2] = array('descricao' => 'Analisado');
$arrtpstatus[3] = array('descricao' => 'Vencido');
$arrtpstatus[4] = array('descricao' => 'Efetivado');
$arrtpstatus[5] = array('descricao' => 'Contingência');
$GLOBALS['arrtpstatus'] = $arrtpstatus;

/*
******************************
* chamadas AJAX ou IMPRESSAO *
******************************
*/

if (isset($_GET['paramAcao'])) {
	if ($_GET['paramAcao'] == 'impressaoHistorico') {
		$cPesquisa = new pesquisaRating();
		pesquisarRatingHistorico($cPesquisa);
		return false;
	}
}

if (isset($_POST['paramAcao'])) {
	if ($_POST['paramAcao'] == 'validarRating') {
		validarPARRAT($_POST['paramRating']);
		return;
	}
	if ($_POST['paramAcao'] == 'salvarRating') {
		salvarRating($_POST['paramRating']);
		return;
	}
	if ($_POST['paramAcao'] == 'pesquisarRating') {
		$cPesquisa = new pesquisaRating();
		if ($cPesquisa->cddopcao == 'H') {
			// pesquisarRatingHistorico($cPesquisa);
		} else {
			pesquisarRating($cPesquisa);
		}
		return;
	}
}
/*
******************************
* chamadas AJAX ou IMPRESSAO *
******************************
*/

class pesquisaRating {
	var $cddopcao;
	var $nrdconta;
	var $nrctro;
	var $nrcpfcgc;
	var $crawepr;
	var $crapbdc;
	var $craplim;
	var $crapbdt;
	var $crapcpa;
	var $status;
	var $fldtinic;
	var $fldtfina;
	var $contratoLiquidado;

	public function __construct() {
		$this->cddopcao = isset($_POST['cddopcao']) ? $_POST['cddopcao'] : '';
		$this->nrdconta = isset($_POST['nrdconta']) ? $_POST['nrdconta'] : '';
		$this->nrctro = isset($_POST['nrctro']) ? $_POST['nrctro'] : '';
		$this->nrcpfcgc = isset($_POST['nrcpfcgc']) ? $_POST['nrcpfcgc'] : '';
		$this->crawepr = isset($_POST['tpproduto_emp']) ? $_POST['tpproduto_emp'] : '';
		$this->crapbdc = isset($_POST['tpproduto_che']) ? $_POST['tpproduto_che'] : '';
		$this->craplim = isset($_POST['tpproduto_cre']) ? $_POST['tpproduto_cre'] : '';
		$this->crapbdt = isset($_POST['tpproduto_des']) ? $_POST['tpproduto_des'] : '';
		$this->crapcpa = isset($_POST['tpproduto_cpa']) ? $_POST['tpproduto_cpa'] : '';
		$this->status = isset($_POST['prstatus']) ? $_POST['prstatus'] : '';;
		$this->fldtinic = isset($_POST['fldtinic']) ? $_POST['fldtinic'] : '';
		$this->fldtfina = isset($_POST['fldtfina']) ? $_POST['fldtfina'] : '';
		$this->contratoLiquidado = isset($_POST['contratoLiquidado']) ? $_POST['contratoLiquidado'] : '';
	}
	
	public function retornaConsultaXML() {

		$this->crapbdc = $this->consultaOpcao($this->crapbdc);
		$this->crapbdt = $this->consultaOpcao($this->crapbdt);
		$this->craplim = $this->consultaOpcao($this->craplim);
		$this->crawepr = $this->consultaOpcao($this->crawepr);
		$this->crapcpa = $this->consultaOpcao($this->crapcpa);

		if ($this->crapbdc == 'N' && $this->crapbdt == 'N' && $this->craplim == 'N' && $this->crawepr == 'N' && $this->crapcpa == 'N') {
			$this->crapbdc = 'S';
			$this->crapbdt = 'S';
			$this->craplim = 'S';
			$this->crawepr = 'S';
			$this->crapcpa = 'S';
		}

		$xml = "<Root>";
		$xml .= "<Dados>";
		$xml .= "	<nrcpfcgc>".$this->converterNumeros($this->nrcpfcgc)."</nrcpfcgc>";
		$xml .= "	<nrdconta>".$this->converterNumeros($this->nrdconta)."</nrdconta>";
		$xml .= "	<nrctro>".$this->converterNumeros($this->nrctro)."</nrctro>";
		$xml .= "   <status>".$this->status."</status>";
		$xml .= "	<datafim>".$this->fldtfina."</datafim>";
		$xml .= "	<dataini>".$this->fldtinic."</dataini>";
		$xml .= "	<crapbdc>".$this->crapbdc."</crapbdc>";
		$xml .= "	<crapbdt>".$this->crapbdt."</crapbdt>";
		$xml .= "	<craplim>".$this->craplim."</craplim>";
		$xml .= "	<crawepr>".$this->crawepr."</crawepr>";
		$xml .= "   <crapcpa>".$this->crapcpa."</crapcpa>";
		$xml .= "	<contrliq>".$this->consultaOpcao($this->contratoLiquidado)."</contrliq>";
		$xml .= "</Dados>";
		$xml .= "</Root>";

		return $xml;
	}

	public function consultaOpcao($str) {
		$str = strtoupper($str);
		if ($str != 'S' && $str != 'N') {
			$str = 'N';
		}
		return $str;
	}
	
	static function converterNumeros($str) {
		$str = str_replace('.', '', $str);
		$str = str_replace('-', '', $str);
		$str = str_replace(' ', '', $str);
		$str = str_replace('/', '', $str);
		return $str;
	}
}

function salvarRating($ratings) {
	global $glbvars;

	if (count($ratings) && is_array($ratings)) {

		foreach ($ratings as $key => $item) {

			$xml = "<Root>";
			$xml .= "<Dados>";
			$xml .= "	<nrcpfcgc>".$item[0]['cpfcfc']."</nrcpfcgc>";
			$xml .= "	<nrdconta>".$item[0]['conta']."</nrdconta>";
			$xml .= "	<nrctro>".$item[0]['contrato']."</nrctro>";
			$xml .= "	<tpproduto>".$item[0]['tipoproduto']."</tpproduto>";
			$xml .= "	<rating_sugerido>".$item[0]['novanota']."</rating_sugerido>";
			$xml .= "	<justificativa>".$item[0]['justificativa']."</justificativa>";
			$xml .= "   <botao_chamada>3</botao_chamada>";
			$xml .= "</Dados>";
			$xml .= "</Root>";

			$xmlResult = mensageria($xml, "TELA_RATMOV", "ALTERARRATING", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
			$xmlObj = getObjectXML($xmlResult);
			
			if (strtoupper($xmlObj->roottag->tags[0]->name) != "ERRO") {
				$registros = $xmlObj->roottag->tags[0]->tags;
				foreach ($registros as $r) {
					// return getByTagName($r->tags, 'pr_qtmeses_expiracao_nota');
					// print_r($r);
				}
			} else {
				// print_r($xmlObj->roottag->tags[0]);
				// echo 'erro';
			}
		}
	}
	$retorno = array('retorno' => $ratings);
	echo json_encode($retorno);
	return;
}

function validarPARRAT($ratings) {
	if (count($ratings) && is_array($ratings)) {
		foreach ($ratings as $key => $item) {
			$nota = $item[0]['nota'];
			$conta = $item[0]['conta'];
			$contrato = $item[0]['contrato'];
			$tipoproduto = $item[0]['tipoproduto'];
			$tipoPessoa = $item[0]['tipoPessoa'];
			$cpfcfc = $item[0]['cpfcfc'];
			$id = $item[0]['id'];
		}
	}
	$retorno = array('retorno' => '');
	echo json_encode($retorno);
	return;
}

function pesquisarRatingHistorico($cPesquisa) {
	global $glbvars;

	$xml = $cPesquisa->retornaConsultaXML();
// Para depurar parametros pois o POST é enviado pela função em JS carregaImpressaoAyllos do form especificado
// echo '<pre>'; print_r($_POST); echo "<textarea rows=10 cols=80>$xml</textarea>"; die();

	$xmlResult = mensageria($xml, "TELA_RATMOV", "PC_IMPRIMIR", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObj = getObjectXML($xmlResult);

	if (strtoupper($xmlObj->roottag->tags[0]->name) == "ERRO") {
		$msgErro = utf8ToHtml($xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata);
		echo "
		<script language=\"javascript\">alert('".$msgErro."');</script>
		";
		exit();
	}

	$nmarqpdf = getByTagName($xmlObj->roottag->tags[0]->tags,'nmarqpdf');

	if($nmarqpdf == 'FALSE') {
		echo "
		<script language=\"javascript\">alert('Nao foi possivel gerar impressao.');</script>
		";
		exit();
	}

	// Chama função para mostrar PDF do impresso gerado no browser
	visualizaPDF($nmarqpdf);
	return;
}

function pesquisarRating($cPesquisa) {
	global $glbvars;

	$ratings = array();

	$xml = $cPesquisa->retornaConsultaXML();

	$xmlResult = mensageria($xml, "TELA_RATMOV", "CONSULTARRAT", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObj = getObjectXML($xmlResult);
	unset($xmlResult);
	$comandoJS = '';

	if (strtoupper($xmlObj->roottag->tags[0]->name) == "ERRO") {
		$msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;

		if ($msgErro == "") {
			$msgErro = $xmlObj->roottag->tags[0]->cdata;
		}

		$nmdcampo = $xmlObj->roottag->tags[0]->attributes['NMDCAMPO'];
		$comandoJS = 'hideMsgAguardo();showError("error","' . utf8_encode($msgErro) . '","Alerta - Aimaro","desbloqueia()");';
		echo json_encode(array('resultadoJS' => $comandoJS));
		return;
	}

	$registros = $xmlObj->roottag->tags[0]->tags;
	unset($xmlObj);

	foreach ($registros as $r) {
		$codTipoProduto = (int)getByTagName($r->tags, 'PR_ORIGEM_CONSULTA');
		$finalidade = (int)getByTagName($r->tags, 'PR_FINALIDADE');
		$codStatus = getByTagName($r->tags, 'PR_STATUS');

		$descstatus = '';
		if (!is_null($codStatus) && strlen($codStatus)) {
		$codStatus = (int)getByTagName($r->tags, 'PR_STATUS');
			$descstatus = $GLOBALS['arrtpstatus'][$codStatus]['descricao'];
		}

		$descTipoProduto = $GLOBALS['arrtpproduto'][$codTipoProduto]['sigla'];
		$descricaoLegenda = $GLOBALS['arrtpproduto'][$codTipoProduto]['descricao'];
		if ($finalidade == 68 && $codTipoProduto == 90) {
			$descTipoProduto = $GLOBALS['arrfinalidade'][$finalidade]['sigla'];
			$descricaoLegenda = $GLOBALS['arrfinalidade'][$finalidade]['descricao'];
		}

		$ratings[] = array(
			'data' => getByTagName($r->tags, 'PR_RAT_ATU_DATA'),
			'tipoproduto' => $codTipoProduto,
			'finalidade' => $finalidade,
			'desctipoproduto' => $descTipoProduto,
			'conta' => formataContaDV(getByTagName($r->tags, 'PR_NRDCONTA')),
			'contrato' => mascara(getByTagName($r->tags, 'PR_CONTRATO'),'#.###.###.###'),
			'valor' => formataMoeda(getByTagName($r->tags, 'PR_VALOR')),
			'ratingModelo' => getByTagName($r->tags, 'PR_RATING_MODELO'),
			'dataModelo' => getByTagName($r->tags, 'PR_RAT_MOD_DATA'),
			'ratingEfetivado' => getByTagName($r->tags, 'PR_RATING_ATUAL'),
			'dataEfetivado' => getByTagName($r->tags, 'PR_DATA_EFET'),
			'vencimento' => getByTagName($r->tags, 'PR_VENCIMENTO'),
			'status' => $codStatus,
			'descstatus' => $descstatus,
			'tipopessoa' => getByTagName($r->tags, 'PR_TIPO_PESSOA'),
			'cpfcgc' => getByTagName($r->tags, 'PR_NRCPFCGC'),
			'alterar' => getByTagName($r->tags, 'PR_SN_ALTERAR_RAT'),
			'descricaoLegenta' => $descricaoLegenda
		);
	}

	$linha = '<table><tbody>';
	$estilo = 'corImpar';

	if (count($ratings) == 0) {
		$linha .= '
		<tr class="even">
			<td>'.utf8_decode('Não encontrado nenhum rating').'</td>
		</tr>
		';
	} else {
		// $arrParametros = array();
		foreach ($ratings as $key => $item) {
			if ($estilo == 'corPar') {
				$estilo = 'corImpar';
			} else {
				$estilo = 'corPar';
			}

			// armazena no array para evitar chamadas repetidas
			// $idParrat = $item['tipoproduto'] . $item['tipopessoa'] . $glbvars["cdcooper"];
			// if (!isset($arrParametros[$idParrat])) {
			//     $arrParametros[$idParrat] = PARRAT_calcularVencimento($item['tipopessoa'], $item['tipoproduto']);
			// }
			// armazena no array para evitar chamadas repetidas
			// $dataVencimento = RATMOV_calcularVencimento($item['dataModelo'], $arrParametros[$idParrat]);

			$id = pesquisaRating::converterNumeros($item['conta'] . $item['contrato'] . $item['tipoproduto']);

			// soma das colunas 860
			$linha .= '
				<tr class="even '.$estilo.'" id="'. $id .'">
					<td style="width: 60px;">'.$item['data'].'</td>
					<td style="width: 40px;" title="'.$item['descricaoLegenta'].'">'.$item['desctipoproduto'].'</td>
					<td style="width: 80px;">'.$item['conta'].'</td>
					<td style="width: 80px;">'.$item['contrato'].'</td>
					<td style="width: 80px;">'.$item['valor'].'</td>
					<td style="width: 55px;">'.$item['ratingModelo'].'</td>
					<td style="width: 70px;">'.$item['dataModelo'].'</td>
					<td style="width: 55px;">'.$item['ratingEfetivado'].'</td>
					<td style="width: 70px;">'.$item['dataEfetivado'].'</td>
					<td style="width: 65px;">'.$item['vencimento'].'</td>
					';
					
					// [001]
					$larguraColuna = '85px';
					if ($item['alterar'] == 'S' && $cPesquisa->cddopcao == 'A') {
						$linha .= '
					<td style="width: 55px;" class="tdAguardandoRating">
						<input type="checkbox" style="margin-left: 25px;"
							data-conta="'.pesquisaRating::converterNumeros($item['conta']).'"
							data-nrcontrato="'.pesquisaRating::converterNumeros($item['contrato']).'"
							data-tipoproduto="'.pesquisaRating::converterNumeros($item['tipoproduto']).'"
							data-pessoafisica="'.pesquisaRating::converterNumeros($item['tipopessoa']).'"
							data-cpfcgc="'.pesquisaRating::converterNumeros($item['cpfcgc']).'"
							data-id="'.$id.'"
							onClick="habilitarAtualizacao(this);" class="habilitarAtualizacaoNota">
					</td>
					<td style="width: 65px;" class="tdCampoRating">
						<input type="text" size="2" maxlength="2" class="campo" style="display: none; width: 40px; margin-left: 10px;"
						onBlur="validarRatingDigitado(this);" id="campoNovoRatingID_'.$id.'">
					</td>
					';
					} else {
						if ($cPesquisa->cddopcao == 'C') {
							$larguraColuna = '205px';
						} else {
							$linha .= '
						<td style="width: 120px;" colspan="2">Não dispon&iacute;vel</td>
						';
						}
					}
					$linha .= '
					<td style="width: '.$larguraColuna.';">'.$item['descstatus'].'</td>
				</tr>
				';
				// [001]
		}
	}

	$linha .= '</tbody></table>';

	if ($cPesquisa->cddopcao != 'A') {
		$comandoJS = "
		$('.habilitarAtualizacaoNota', '#retornoPesquisaRating').desabilitaCampo();
		$('#btnEnviar').hide();
		$('#btnEfetivar').hide();
		";
	} else {
		$comandoJS = "
		$('#btnEnviar').show();
		$('#btnEfetivar').show();
		";
	}
   

	echo json_encode(array('resultadoHTML' => $linha, 'total' => count($ratings), 'desabilitaCheckBox' => $comandoJS));
}

function PARRAT_calcularVencimento($inpessoa, $tpproduto) {
	global $glbvars;

	$xml = "<Root>";
	$xml .= "<Dados>";
	$xml .= "	<inpessoa>".$inpessoa."</inpessoa>";
	$xml .= "	<tpproduto>".$tpproduto."</tpproduto>";
	$xml .= "	<cooperat>".$glbvars["cdcooper"]."</cooperat>";
	$xml .= "</Dados>";
	$xml .= "</Root>";

	$xmlResult = mensageria($xml, "TELA_PARRAT", "PARRAT_CONSULTAR", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObj = getObjectXML($xmlResult);
	
	if (strtoupper($xmlObj->roottag->tags[0]->name) != "ERRO") {
		$registros = $xmlObj->roottag->tags[0]->tags;
		/*
		* Terá apenas um retorno;
		*/
		foreach ($registros as $r) {
			return getByTagName($r->tags, 'pr_qtmeses_expiracao_nota');
		}
	}
	return false;
}

function RATMOV_calcularVencimento($data, $somaDias) {
	if ((int)$somaDias > 0) {
		list($dia, $mes, $ano) = explode('/', $data);
		try {
			$date = new DateTime("$ano-$mes-$dia");
			$date->add(new DateInterval('P'.$somaDias.'D'));
			return $date->format('d/m/Y');
		} catch (Exception $e) {
			// echo 'Exceção capturada: ',  $e->getMessage(), "\n";
			return '';
		}
	} else {
		return $data;
	}
}