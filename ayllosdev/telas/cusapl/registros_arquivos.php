<?
//*********************************************************************************************//
//*** Fonte: registro_arquivos.php                                     						          ***//
//*** Autor: Rafael B. Arins - Envolti                                           						***//
//*** Data : Abril/2018                  Última Alteração: --/--/----  					            ***//
//***                                                                  						          ***//
//*** Objetivo  : Busca o lista arquivos e monta a tela. (CUSAPL_LISTA_CONT_ARQ).           ***//
//***                                                                  						          ***//
//*** Alterações: 																			                                    ***//
//*********************************************************************************************//

 session_start();
 require_once('../../includes/config.php');
 require_once('../../includes/funcoes.php');
 require_once('../../includes/controla_secao.php');
 require_once('../../class/xmlfile.php');
 isPostMethod();

	//Função para transformar string 
	function getXML($xmlStr) {
		$xmlStr = str_replace(array("\n", "\r", "\t"), '', $xmlStr);
		$xmlStr = trim(str_replace('"', "'", $xmlStr));
		$xml = simplexml_load_string($xmlStr);
		return $xml;
	}

 // Guardo os parâmetos do POST em variáveis
 $idArquivo  = (isset($_POST['idarquivo']))  ? $_POST['idarquivo'] : 0 ;
$inacao    = (isset($_POST['inacao']))  ? $_POST['inacao'] : 'TELA';
$cdcooper  = (isset($_POST['cdcooper']))  ? $_POST['cdcooper'] : '';
$nrdconta  = (isset($_POST['nrdconta']))  ? $_POST['nrdconta'] : 0 ;
$nraplica  = (isset($_POST['nraplica']))  ? $_POST['nraplica'] : 0 ;
$flgcritic = (isset($_POST['flgcritic']))  ? $_POST['flgcritic'] : 0 ;
$datade    = (isset($_POST['datade']))  ? $_POST['datade'] : '';
$datate    = (isset($_POST['datate']))  ? $_POST['datate'] : '';
$nmarquiv  = (isset($_POST['nmarquiv']))  ? $_POST['nmarquiv'] : '' ;
$dscodib3  = (isset($_POST['dscodib3']))  ? $_POST['dscodib3'] : '' ;
$nrregist  = (isset($_POST["nrregist"]) && $_POST["nrregist"] > 0) ? $_POST["nrregist"] : 15;
$nriniseq  = (isset($_POST["nriniseq"]) && $_POST["nriniseq"] > 0) ? $_POST["nriniseq"] : 1;

 // Montar o xml de Requisicao
 $xmlCarregaDados = "";
 $xmlCarregaDados .= "<Root>";
 $xmlCarregaDados .= " <Dados>";
 $xmlCarregaDados .= " <idarquivo>".$idArquivo."</idarquivo>";
$xmlCarregaDados .= "		<cdcooper>".$cdcooper."</cdcooper>";
$xmlCarregaDados .= "		<nrdconta>".$nrdconta."</nrdconta>";
$xmlCarregaDados .= "		<nraplica>".$nraplica."</nraplica>";
$xmlCarregaDados .= "		<flgcritic>".$flgcritic."</flgcritic>";
$xmlCarregaDados .= "		<datade>".$datade."</datade>";
$xmlCarregaDados .= "		<datate>".$datate."</datate>";
$xmlCarregaDados .= "		<nmarquiv>".$nmarquiv."</nmarquiv>";
$xmlCarregaDados .= "		<dscodib3>".$dscodib3."</dscodib3>";
$xmlCarregaDados .= "		<inacao>".$inacao."</inacao>";
$xmlCarregaDados .= "		<nriniseq>".$nriniseq."</nriniseq>";
$xmlCarregaDados .= "		<nrregist>".$nrregist."</nrregist>";
 $xmlCarregaDados .= " </Dados>";
 $xmlCarregaDados .= "</Root>";

$xmlResult = mensageria($xmlCarregaDados, "TELA_CUSAPL", "CUSAPL_LISTA_CONT_ARQ", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");

 $xmlObject = getObjectXML($xmlResult);

 if (strtoupper($xmlObject->roottag->tags[0]->name) == 'ERRO') {
  $msgErro = $xmlObject->roottag->tags[0]->cdata;
  if ($msgErro == '') {
  $msgErro = $xmlObject->roottag->tags[0]->tags[0]->tags[4]->cdata;
  }
	exibirErro('error',$msgErro,'Alerta - Ayllos','',true);
 }
if ($inacao == 'TELA') {

$detalhesCus = $xmlObject->roottag->tags[0]->tags;
$xml = getXML( $xmlResult );
$att = $xml->lstcont[0]->attributes();
$qtregist = $att['qtregist'];

$totalizadores = $xmlObject->roottag->tags[1];
?>
<script type="text/javascript" src="../../scripts/funcoes.js">

</script>
<style>
	.tabela {    font-family: arial, sans-serif;    border-collapse: collapse;    width: 100%;}
    .celula { border: 1px solid #dddddd; text-align: left; padding: 2px; }
	.linha:nth-child(even) {    background-color: #dddddd;}
	#tableRegistros.tabela .lin { width:50; text-align: left; } 
	#tableRegistros.tabela .codigo { width:145px; text-align: left; }  
	#tableRegistros.tabela .cooper { width:205px; } 
	#tableRegistros.tabela .conta { width:90px; } 
	#tableRegistros.tabela .cpfcnpj { width:140px; } 
	#tableRegistros.tabela .aplic { width:100px; } 
	#tableRegistros.tabela .tipo { width:260px; } 
	#tableRegistros.tabela .hist { width:150px; }
	#tableRegistros.tabela .tipo_reg { width:100px; } 
	#tableRegistros.tabela .valor { width:100px; } 
	#tableRegistros.tabela .reenvio { width:80px; } 
	#tableRegistros.tabela .cotas { width:100px; } 
	#tableRegistros.tabela .envio { width:100px; } 
	#tableRegistros.tabela .vencimento { width:130px; } 
	#tableRegistros.tabela .taxa { width:80px; } 
	#tableRegistros.tabela .pu { width:100px; } 
	#tableRegistros.tabela .situacao { width:100px; } 
	#tableRegistros.tabela .critica { width:250px; }
	#tableRegistros.tabela .plano { width:50px; } 
	div.divRegistros table#tableRegistros {width:2330px;}
	#divRegistrosArquivo .divRegistros { max-width: 960px; }
	.headerSort {border-right:1px dotted #999; padding: 5px;}
</style>

<h2> Registros do Arquivo </h2>
<br />
<div class="divRegistros" style="overflow-x: scroll; height:290px;">
    <table id="tableRegistros" class="tabela" style="border-collapse: collapse;">
        <thead style="cursor:pointer;background-color:#f7d3ce;display:table-header-group;">
			<tr style="height: 22px;">
				<th class="headerSort lin" onclick="sortTable('tableRegistros', 1)">Lin</th>
				<th class="headerSort codigo" onclick="sortTable('tableRegistros', 2)">Codigo If</th>
				<th class="headerSort cooper" onclick="sortTable('tableRegistros', 3)" >Cooperativa</th>
				<th class="headerSort conta" onclick="sortTable('tableRegistros', 4)">Conta</th>
				<th class="headerSort cpfcnpj" onclick="sortTable('tableRegistros', 5)">CPF/CNPJ</th>
				<th class="headerSort aplic" onclick="sortTable('tableRegistros', 6)" >Aplic</th>
				<th class="headerSort tipo" onclick="sortTable('tableRegistros', 7)" >Tipo Aplic</th>
				<th class="headerSort hist" onclick="sortTable('tableRegistros', 8)" >Hist</th>
				<th class="headerSort tipo_reg" onclick="sortTable('tableRegistros', 9)" >Tipo Reg</th>
				<th class="headerSort reenvio" onclick="sortTable('tableRegistros', 10)" >Re Envio</th>
				<th class="headerSort envio" onclick="sortTable('tableRegistros', 11)" >Emissao</th>
				<th class="headerSort vencimento" onclick="sortTable('tableRegistros', 12)" >Vencimento</th>
				<th class="headerSort taxa" onclick="sortTable('tableRegistros', 13)">Taxa</th>
				<th class="headerSort cotas" onclick="sortTable('tableRegistros', 14)" >Cotas</th>
				<th class="headerSort pu" onclick="sortTable('tableRegistros', 15)">Vlr PU</th>
				<th class="headerSort valor" onclick="sortTable('tableRegistros', 16)" >Valor B3</th>
				<th class="headerSort situacao" onclick="sortTable('tableRegistros', 17)" ><?php echo utf8ToHtml('Situação'); ?></th>
				<th class="headerSort critica" onclick="sortTable('tableRegistros', 18)"><?php echo utf8ToHtml('Crítica'); ?></th>
				<th class="headerSort plano" onclick="sortTable('tableRegistros', 19)">Plano</th>
  			</tr>
  		</thead>
		<tbody>
		<?php
            if (count($detalhesCus)) {
                foreach ($detalhesCus as $itemGrid) {
                    $NRSEQLIN = getByTagName($itemGrid->tags, 'NRSEQLIN');
                    $DSCODIB3 = getByTagName($itemGrid->tags, 'DSCODIB3');
                    $DSCOOPER = getByTagName($itemGrid->tags, 'DSCOOPER');
                    $NRDCONTA = getByTagName($itemGrid->tags, 'NRDCONTA');
                    $NRAPLICA = getByTagName($itemGrid->tags, 'NRAPLICA');
                    $DSTPAPLI = getByTagName($itemGrid->tags, 'DSTPAPLI');
                    $CDHISTOR = getByTagName($itemGrid->tags, 'CDHISTOR');
                    $CDTIPREG = getByTagName($itemGrid->tags, 'CDTIPREG');
                    $VLLANCTO = getByTagName($itemGrid->tags, 'vllancto');
                    $IDREENVI = getByTagName($itemGrid->tags, 'IDREENVI');
                    $NRCPFCNP = getByTagName($itemGrid->tags, 'cpfcnpj');
                    $QTDCOTAS = getByTagName($itemGrid->tags, 'qtdcotas');
                    $DTENVIO  = getByTagName($itemGrid->tags, 'dtenvio');
                    $DTVENCI  = getByTagName($itemGrid->tags, 'dtvencimento');
                    $VLRTAXA  = getByTagName($itemGrid->tags, 'taxavalpu');
                    $VLRPU    = getByTagName($itemGrid->tags, 'valorpu');
                    $DSSITUAC = getByTagName($itemGrid->tags, 'DSSITUAC');
                    $DSCRITIC = getByTagName($itemGrid->tags, 'DSCRITIC');
					$PLANO_APLIC = getByTagName($itemGrid->tags, 'PLANOAPLIC');
				echo '<tr class="linha" id="linhatableRegistros',$NRSEQLIN,'" onclick="selecionaLinha(\'tableRegistros\',\'linhatableRegistros',$NRSEQLIN,'\');">
								<td class="celula lin" title="Linha">', ($NRSEQLIN), '</td>
								<td class="celula codigo" title="', utf8ToHtml('Código IF'), '">', ($DSCODIB3), '</td>
								<td class="celula cooper" title="Coop">', ($DSCOOPER), '</td>
								<td class="celula conta"  title="Conta">', ($NRDCONTA), '</td>
								<td class="celula cpfcnpj" title="">', ($NRCPFCNP), '</td>
								<td class="celula aplic" itle="', utf8ToHtml('Aplicação'), '">', ($NRAPLICA), '</td>
								<td class="celula tipo"  title="Tipo Aplic">', ($DSTPAPLI), '</td>
								<td class="celula hist"  title="', utf8ToHtml('Histórico'), '">', ($CDHISTOR), '</td>
								<td class="celula tipo_reg"  title="Tipo Reg.">', ($CDTIPREG), '</td>
								<td class="celula reenvio"  title="Re-Envio">', ($IDREENVI), '</td>
								<td class="celula envio" title="">', ($DTENVIO), '</td>
								<td class="celula vencimento" title="">', ($DTVENCI), '</td>
								<td class="celula taxa" title="">', ($VLRTAXA), '</td>
								<td class="celula cotas" title="">', ($QTDCOTAS), '</td>
								<td class="celula pu" title="">', ($VLRPU), '</td>
								<td class="celula valor"  title="Valor">', ($VLLANCTO), '</td>
								<td class="celula situacao"  title="', utf8ToHtml('Situação'), '">', ($DSSITUAC), '</td>
								<td class="celula critica"  title="', utf8ToHtml('Crítica'), '">', ($DSCRITIC), '</td>
								<td class="celula plano" title="', $PLANO_APLIC, '">', ($PLANO_APLIC), '</td>
							</tr>';
			}
    }else {
                echo '<tr class="linha"><td class="celula" colspan="19">Sem Registros Encontrados!</td></tr>';
    }
		?>
        </tbody>
    </table>
</div>


<?php if ($qtregist > 0) { ?>

<div id="divPesquisaRodapeArqs" class="divPesquisaRodape">
	<table>
		<tr>
			<td>
				<? if (isset($qtregist) and $qtregist == 0) $nriniseq = 0;
				if ($nriniseq > 1) { ?> <a class='paginacaoAnt'> <<< Anterior</a> <? } ?>
			</td>
			<td>
				<? if (isset($nriniseq)) { ?>
					Exibindo <? echo $nriniseq; ?> at&eacute; <? if (($nriniseq + $nrregist) > $qtregist) { echo $qtregist; } else { echo ($nriniseq + $nrregist - 1); } ?> de <? echo $qtregist; ?>
				<? } ?>
			</td>
			<td>
				<? if ($qtregist > ($nriniseq + $nrregist - 1)) { ?> <a class="paginacaoProx">Pr&oacute;ximo >>></a> <? } ?>
			</td>
		</tr>
</table>
</div>

<script type="text/javascript">
	$('#divPesquisaRodapeArqs a.paginacaoAnt').unbind('click').bind('click', function() {
		//consulta(nriniseq, nrregist)
		consultaRegistrosArquivos( <? echo $idArquivo . "," . ($nriniseq - $nrregist) . "," . $nrregist; ?> );
	});

	$('#divPesquisaRodapeArqs a.paginacaoProx').unbind('click').bind('click', function() {
		consultaRegistrosArquivos( <? echo $idArquivo . "," . ($nriniseq + $nrregist) . "," . $nrregist; ?> );
	});
	$('#divPesquisaRodapeArqs').formataRodapePesquisa();
	
	var idarquivo = <? echo $idArquivo; ?>;

	$("#btExportar").show();
</script>
<?php } ?>

<div id="Legenda2">
	<p>
	  <b>Legenda Tipo Registro:</b> REG: Registro e Dep&oacute;sito da Emiss&atilde;o&nbsp;&nbsp;&nbsp;&nbsp;RGT: Resgate Antecipado&nbsp;&nbsp;&nbsp;&nbsp;RIR: Reten&ccedil;&atilde;o IR&nbsp;&nbsp;&nbsp;&nbsp;CNC: Concilia&ccedil;&atilde;o
	</p>
</div>

<style>
    .linha{ cursor: pointer; }
    .linha:hover {
        outline: rgb(107,121,132) solid 1px !important;
    }
	.divRegistrosTotais tfoot {
		border-top: 2px solid black;
		border-bottom: 2px solid black;
	}
	.divRegistrosTotais thead th, .divRegistrosTotais tbody td, .divRegistrosTotais tfoot td {
		border-top: 1px solid black;
		border-bottom: 1px solid black;
		border-left: 1px dotted #999;
		padding: 2px 10px;
	}
	.divRegistrosTotais td.vlsalcon, .divRegistrosTotais td.valueC {
		text-align: right;
		border-right: 1px dotted #999;
	}
	div.divRegistrosTotais table {
		border-collapse: collapse;
	}
</style>
<br />
<div class="tableListaCustoDevido divRegistrosTotais">
    <div class="divRegistrosCustoDevido">
        <table id="tableArquivos tabelaRegistrosTotais" style="padding:0; margin:0 auto;">
            <tfoot>
                <tr class="linha" style="">
					<td>Total de registros</td>
					<td class="valueC"><? echo getByTagName($totalizadores->tags,'totregistros') ?></td>
				</tr>
				<tr class="linha">
					<td>Total Conciliados</td>
					<td class="valueC"><? echo getByTagName($totalizadores->tags,'totregconcilia') ?></td>
				</tr>
				<tr class="linha">
					<td><?=utf8ToHtml('Total C/Críticas');?></td>
					<td class="valueC"><? echo getByTagName($totalizadores->tags,'totregcritica') ?></td>
				</tr>
				<tr class="linha">
					<td>Total Programada</td>
					<td class="valueC"><? echo getByTagName($totalizadores->tags,'totaplicprogramada') ?></td>
				</tr>
				<tr class="linha">
					<td><?=utf8ToHtml('Total Aplicação');?></td>
					<td class="valueC"><? echo getByTagName($totalizadores->tags,'totaplicacao') ?></td>
				</tr>
				<tr class="linha">
					<td>Total de Cotas</td>
					<td class="valueC"><? echo getByTagName($totalizadores->tags,'totqtdcotas') ?></td>
				</tr>
				<tr class="linha">
					<td>Valor Total</td>
					<td class="valueC"><? echo getByTagName($totalizadores->tags,'totvalorcotas') ?></td>
				</tr>
            </tfoot>
        </table>
    </div>
</div>
<?
} else {
	//$arquivo = getByTagName($xmlObject->roottag->tags, 'arquivoCSV');
	echo "hideMsgAguardo();";
	//echo 'Gera_Impressao(\''.$arquivo.'\',\'\');';
	exibirErro('inform','Exportação efetuada com sucesso.','Alerta - Ayllos','',false);
	exit; //termina processamento para exportar arquivo.
}