<?
//*********************************************************************************************//
//*** Fonte: busca_log_arquivos.php                                    						          ***//
//*** Autor: Rafael B. Arins - Envolti                                           						***//
//*** Data : Abril/2018                  Última Alteração: --/--/----  					            ***//
//***                                                                  						          ***//
//*** Objetivo  : busca log de arquivos da tela CUSAPL                   						        ***//
//***                                                                  						          ***//
//*** Alterações: 																			                                    ***//
//***                                                                  						***//
//*********************************************************************************************//

ini_set('memory_limit','256M'); // set memory to prevent fatal errors

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
	$cdcooper  = (isset($_POST['cdcooper']))  ? $_POST['cdcooper'] : '';
	$nrdconta  = (isset($_POST['nrdconta']))  ? $_POST['nrdconta'] : 0 ;
	$nraplica  = (isset($_POST['nraplica']))  ? $_POST['nraplica'] : 0 ;
	$flgcritic  = (isset($_POST['flgcritic']))  ? $_POST['flgcritic'] : 0 ;
	$datade  = (isset($_POST['datade']))  ? $_POST['datade'] : '';
	$datate  = (isset($_POST['datate']))  ? $_POST['datate'] : '';
	$nmarquiv  = (isset($_POST['nmarquiv']))  ? $_POST['nmarquiv'] : '' ;
  $dscodib3  = (isset($_POST['dscodib3']))  ? $_POST['dscodib3'] : '' ;
$nriniseq = (isset($_POST["nriniseq"])) ? $_POST["nriniseq"] : 1;
$nrregist =  (isset($_POST["nrregist"])) ? $_POST["nrregist"] : 15;

  // Montar o xml de Requisicao
  $xmlCarregaDados = "";
  $xmlCarregaDados .= "<Root>";
  $xmlCarregaDados .= " <Dados>";
  $xmlCarregaDados .= " <cdcooper>".$cdcooper."</cdcooper>";
  $xmlCarregaDados .= " <nrdconta>".$nrdconta."</nrdconta>";
  $xmlCarregaDados .= " <nraplica>".$nraplica."</nraplica>";
  $xmlCarregaDados .= " <flgcritic>".$flgcritic."</flgcritic>";
  $xmlCarregaDados .= " <datade>".$datade."</datade>";
  $xmlCarregaDados .= " <datate>".$datate."</datate>";
  $xmlCarregaDados .= " <nmarquiv>".$nmarquiv."</nmarquiv>";
  $xmlCarregaDados .= " <dscodib3>".$dscodib3."</dscodib3>";
$xmlCarregaDados .= "		<nriniseq>".$nriniseq."</nriniseq>";
$xmlCarregaDados .= "		<nrregist>".$nrregist."</nrregist>";
  $xmlCarregaDados .= " </Dados>";
  $xmlCarregaDados .= "</Root>"; //echo json_encode($_POST); die();
  	// Executa script para envio do XML
$xmlResult = mensageria($xmlCarregaDados, "TELA_CUSAPL", "CUSAPL_LISTA_ARQUIVOS", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");

  $xmlObject = getObjectXML($xmlResult);

	//echo 'hideMsgAguardo();';

  if (strtoupper($xmlObject->roottag->tags[0]->name) == 'ERRO') {
    $msgErro = $xmlObject->roottag->tags[0]->cdata;

    if ($msgErro == '') {
      $msgErro = $xmlObject->roottag->tags[0]->tags[0]->tags[4]->cdata;
    }

    echo 'showError',$msgErro;die();
  }

	$teste = $xmlObject->roottag->tags;
//$qtregist = count($teste[0]->tags);
$xml = getXML( $xmlResult );
$att = $xml->lstarqv[0]->attributes();
$qtregist = $att['qtregist'];

?>
<script type="text/javascript" src="../../scripts/funcoes.js"></script>
<style>
.linha{    cursor: pointer;}
.linha:hover {
    outline: rgb(107,121,132) solid 1px !important;
}
</style>
<br />
<div class="tableLogsDeArquivo">
    <table class="tituloRegistros" style="background-color: #f7d3ce;" onload="formataTabArquivos();">
	<thead>
				<tr>
                <th class="headerSort" style="width:4.7em;" onclick="sortTable('tableArquivos',0)">Cooper</th>    
                <th class="headerSort" style="width:2.7em;" onclick="sortTable('tableArquivos',0)">Tipo</th>
			    <th class="headerSort" style="display: none;"></th>
                <th class="headerSort" style="width:4.7em;" onclick="sortTable('tableArquivos',2)">Data Ref.</th>
			    <th class="headerSort" style="display: none;"></th>
			    <th class="headerSort" style="display: none;"></th>
                <th class="headerSort" style="width:15.4em;" onclick="sortTable('tableArquivos',5)">Arquivo de Envio</th>
                <th class="headerSort" style="width:5em;" onclick="sortTable('tableArquivos',6)">Situa&ccedil;&atilde;o</th>
                <th class="headerSort" style="width:9em;" onclick="sortTable('tableArquivos',7)">Data Envio</th>
			    <th class="headerSort" style="display: none;"></th>
			    <th class="headerSort" style="display: none;"></th>
                <th class="headerSort" style="width:16.1em;" onclick="sortTable('tableArquivos',10)">Arquivo Retorno</th>
                <th class="headerSort" style="width:6em;" onclick="sortTable('tableArquivos',11)">Situa&ccedil;&atilde;o</th>
			    <th class="headerSort" style="" onclick="sortTable('tableArquivos', 12)">Data Processo</th>
					<th class="ordemInicial"></th>
			</tr>
		</thead>
	</table>
	<div class="divRegistros tabelasorting">
		<table id="tableArquivos" >
			<thead style="display:none;">
						<tr>
                    <th class="headerSort" style="width:4%">Cooper</th>
							<th class="headerSort" style="width:4%">Tipo</th>
					    <th class="headerSort" style="display: none;"></th>
					    <th class="headerSort" style="width:4.7em">Data Ref.</th>
					    <th class="headerSort" style="display: none;"></th>
					    <th class="headerSort" style="display: none;"></th>
					    <th class="headerSort" style="width:20%">Arquivo de Envio</th>
					    <th class="headerSort" style="width:8%">Situa&ccedil;&atilde;o</th>
					    <th class="headerSort" style="width:12%">Data Envio</th>
					    <th class="headerSort" style="display: none;"></th>
					    <th class="headerSort" style="display: none;"></th>
					    <th class="headerSort" style="width:21%">Arquivo Retorno</th>
					    <th class="headerSort" style="">Situa&ccedil;&atilde;o</th>
					    <th class="headerSort" style="">Data Processo</th>
						<th class="ordemInicial"></th>
					</tr>
				</thead>
			<tbody>
				<?php
				if(count($teste[0]->tags)>0){
					$parImpar=1;
					$idlinha=0;
					foreach($teste[0]->tags as $itemGrid){
						$classelinha='';
                        $DSCOOPER = getByTagName($itemGrid->tags, 'DSCOOPER');
						$DSTIPARQ = $itemGrid->tags[0]->cdata;
						$DSTIPEXT = $itemGrid->tags[1]->cdata;
						$DTREFERE = $itemGrid->tags[2]->cdata;
						$IDARQENV = $itemGrid->tags[3]->cdata;
						$TPOPEENV = $itemGrid->tags[4]->cdata;
						$NMARQENV = $itemGrid->tags[5]->cdata;
						$DSSITENV = $itemGrid->tags[6]->cdata;
						$DTDENVIO = $itemGrid->tags[7]->cdata;
						$IDARQRET = $itemGrid->tags[8]->cdata;
						$TPOPERET = $itemGrid->tags[9]->cdata;
						$NMARQRET = $itemGrid->tags[10]->cdata;
						$DSSITRET = $itemGrid->tags[11]->cdata;
						$DTDRETOR = $itemGrid->tags[12]->cdata;
                        $classeOnClickAbreRegistros = 'consultaRegistrosArquivos(\'' . $IDARQENV . '\',\'\',\'\')';
						$onclickEnvio=$classeOnClickAbreRegistros;
						$onclickRetorno=$classeOnClickAbreRegistros;
                        if ($parImpar == 1) {
                            $classelinha = 'even corImpar';
                            $parImpar = 2;
                        } else if ($parImpar == 2) {
                            $classelinha = 'odd corPar';
                            $parImpar = 1;
                        }
						if( count(trim($NMARQENV)) >0 && $NMARQENV!=''){
							$onclickEnvio='consultaLogsDeArquivos(\''.$IDARQENV.'\',\''.preg_replace( "/\r|\n/", "",$NMARQENV).'\',\'envio\',\''.$DSTIPEXT.'\')';
						}
						if( count(trim($NMARQRET)) >0 && $NMARQRET!=''){
							$onclickRetorno='consultaLogsDeArquivos(\''.$IDARQRET.'\',\''.preg_replace( "/\r|\n/", "",$NMARQRET).'\',\'retorno\',\''.$DSTIPEXT.'\')';
						}
						echo '<tr id="linha-',$idlinha,'" class="linha ',$classelinha,'">
										<td id="DSTIPARQ" class="celula" style="width:4.7em"   onclick="', $classeOnClickAbreRegistros, '" title="Tipo">', $DSCOOPER, '</td>
										<td id="DSTIPARQ" class="celula" style="width:2.7em"   onclick="',$classeOnClickAbreRegistros,'" title="Tipo">',$DSTIPARQ,'</td>
										<td id="DSTIPEXT" class="celula" style="display:none" onclick="',$classeOnClickAbreRegistros,'" title="TipoExtens">',$DSTIPEXT,'</td>
										<td id="DTREFERE" class="celula" style="width:4.7em"     onclick="',$classeOnClickAbreRegistros,'" title="Dt Ref">',$DTREFERE,'</td>
										<td id="IDARQENV" class="celula" style="display:none" onclick="',$classeOnClickAbreRegistros,'" title="IdArqEnvio">',$IDARQENV,'</td>
										<td id="TPOPEENV" class="celula" style="display:none" onclick="',$classeOnClickAbreRegistros,'" title="TpOperEnvi">',$TPOPEENV,'</td>
										<td id="NMARQENV" class="celula" style="width: 15.4em;" onclick="',$onclickEnvio,'" title="ArqDeEnvio"><a href="#">',$NMARQENV,'</a></td>
										<td id="DSSITENV" class="celula" style="width:5em" onclick="',$classeOnClickAbreRegistros,'" title="Situacao">',$DSSITENV,'</td>
										<td id="DTDENVIO" class="celula" style="width:9em" onclick="',$classeOnClickAbreRegistros,'" title="Data">',$DTDENVIO,'</td>
										<td id="IDARQRET" class="celula" style="display:none" onclick="',$classeOnClickAbreRegistros,'" title="IdArqRetor">',$IDARQRET,'</td>
										<td id="TPOPERET" class="celula" style="display:none" onclick="',$classeOnClickAbreRegistros,'" title="TpOperRet">',$TPOPERET,'</td>
										<td id="NMARQRET" class="celula" style="width:16.1em" onclick="',$onclickRetorno,'" title="ArquiDeRet"><a href="#">',$NMARQRET,'</a></td>
										<td id="DSSITRET" class="celula" style="width:6em" onclick="',$classeOnClickAbreRegistros,'" title="Situacao">',$DSSITRET,'</td>
										<td id="DTDRETOR" class="celula" style="" onclick="',$classeOnClickAbreRegistros,'" title="DataProces">',$DTDRETOR,'</td>
									</tr>';
						$idlinha++;
					}
                } else {
					echo '<tr class="linha">
									<td class="celula" colspan="8">Sem registros encontrados!</td></tr>';
				}
					/*
					tipo      {  "cdata":"CNC",                         "attributes":[],  "name":"DSTIPARQ",  "tags":[],  "parent":null,  "curtag":null  }, *1
					TipoExtens{  "cdata":null,                          "attributes":[],  "name":"DSTIPEXT",  "tags":[],  "parent":null,  "curtag":null  },
					Dt Ref    {  "cdata":"20\/03\/18",                  "attributes":[],  "name":"DTREFERE",  "tags":[],  "parent":null,  "curtag":null  }, *2
					IdArqEnvio{  "cdata":"",                            "attributes":[],  "name":"IDARQENV",  "tags":[],  "parent":null,  "curtag":null  },
					TpOperEnvi{  "cdata":"",                            "attributes":[],  "name":"TPOPEENV",  "tags":[],  "parent":null,  "curtag":null  },
					ArqDeEnvio{  "cdata":"",                            "attributes":[],  "name":"NMARQENV",  "tags":[],  "parent":null,  "curtag":null  }, *3
					Situacao  {  "cdata":"",                            "attributes":[],  "name":"DSSITENV",  "tags":[],  "parent":null,  "curtag":null  }, *4
					Data      {  "cdata":"",                            "attributes":[],  "name":"DTDENVIO",  "tags":[],  "parent":null,  "curtag":null  }, *5
					IdArqRetor{  "cdata":"5",                           "attributes":[],  "name":"IDARQRET",  "tags":[],  "parent":null,  "curtag":null  },
					TpOperRet {  "cdata":"Retorno",                     "attributes":[],  "name":"TPOPERET",  "tags":[],  "parent":null,  "curtag":null  },
					ArquiDeRet{  "cdata":"DDDMMMM01012018.CETIP9.RET",  "attributes":[],  "name":"NMARQRET",  "tags":[],  "parent":null,  "curtag":null  }, *6
					Situacao  {  "cdata":"Conciliado",                  "attributes":[],  "name":"DSSITRET",  "tags":[],  "parent":null,  "curtag":null  }, *7
					DataProces{  "cdata":"20\/03\/18 10:15:59",         "attributes":[],  "name":"DTDRETOR",  "tags":[],  "parent":null,  "curtag":null  }  *8
					*/
				?>

			</tbody>
		</table>
	</div>
</div>

<?php if ($qtregist > 0) { ?>

<div id="divPesquisaRodapeLogs" class="divPesquisaRodape">
  <table>
	<tr>
	  <td>
		<?if (isset($qtregist) and $qtregist == 0) $nriniseq = 0;
		  if ($nriniseq > 1) { ?> <a class='paginacaoAnt'> <<< Anterior</a> <? } ?>
	  </td>
	  <td>
		<? if (isset($nriniseq)) { ?>
			Exibindo <? echo $nriniseq; ?> at&eacute; <? if (($nriniseq + $nrregist) > $qtregist) { echo $qtregist; } else { echo ($nriniseq + $nrregist - 1); } ?> de <? echo $qtregist; ?>
		<? } ?>
	  </td>
	  <td>
		<? if($qtregist > ($nriniseq + $nrregist - 1)) { ?> <a class="paginacaoProx">Pr&oacute;ximo >>></a> <? } ?>
	  </td>
	</tr>
  </table>
</div>
<script type="text/javascript">
	$('#divPesquisaRodapeLogs a.paginacaoAnt').unbind('click').bind('click', function() {
		//consulta(nriniseq, nrregist)
		consulta( <? echo ($nriniseq - $nrregist) . "," . $nrregist; ?> );
	});

	$('#divPesquisaRodapeLogs a.paginacaoProx').unbind('click').bind('click', function() {
		consulta( <? echo ($nriniseq + $nrregist) . "," . $nrregist; ?> );
	});

	$('#divPesquisaRodapeLogs').formataRodapePesquisa();

</script>
<?php } ?>

<div id="Legenda1">
	<p>
	  <b>Legenda Tipo Arquivo:</b> REG: Registro das Opera&ccedil;&otilde;es &nbsp;&nbsp;&nbsp;&nbsp;OPE: Registro das Opera&ccedil;&otilde;es&nbsp;&nbsp;&nbsp;&nbsp;CNC: Concilia&ccedil;&atilde;o
	</p>
	<br /><br />
</div>
