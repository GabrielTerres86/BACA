<?php
//*********************************************************************************************//
//*** Fonte: busca_historico_aplicacao.php                                    						        ***//
//*** Autor: David Valente - Envolti                                           						***//
//*** Data : Abril/2019                  Última Alteração: --/--/----  					            ***//
//***                                                                  						          ***//
//*** Objetivo  : Busca todo o histórico da aplicação selecionada         						      ***//
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

 ?>
 <script type="text/javascript" src="../../scripts/funcoes.js"></script>

 <?php
 
 // Parametros para utilizar na paginação 
 $nriniseq    = (trim($_POST['nriniseq']) != "") ? $_POST['nriniseq'] : 1;
 $nrregist    = (trim($_POST['nrregist']) != "") ? $_POST['nrregist'] : 15;
 $idaplicacao = $_POST['idaplicacao'];

 // Montar o xml de Requisicao
 $xmlCarregaDados = "";
 $xmlCarregaDados .= "<Root>";
 $xmlCarregaDados .= " <Dados>";
 $xmlCarregaDados .= " <idaplicacao>".$idaplicacao."</idaplicacao>";
 $xmlCarregaDados .= " <nriniseq>".$nriniseq."</nriniseq>";
 $xmlCarregaDados .= " <nrregist>".$nrregist."</nrregist>"; 
 $xmlCarregaDados .= " </Dados>";
 $xmlCarregaDados .= "</Root>";

 // Executa script para envio do XML
$xmlResult =  mensageria($xmlCarregaDados
                         ,"TELA_CUSAPL"
                         ,"BUSCA_HIST_APLICACAO"
                         ,$glbvars["cdcooper"]
                         ,$glbvars["cdagenci"]
                         ,$glbvars["nrdcaixa"]
                         ,$glbvars["idorigem"]
                         ,$glbvars["cdoperad"]
                         ,"</Root>");
$xmlObject = getObjectXML($xmlResult);

 if (strtoupper($xmlObject->roottag->tags[0]->name) == 'ERRO') {
  $msgErro = $xmlObject->roottag->tags[0]->cdata;
  if ($msgErro == '') {
    $msgErro = $xmlObject->roottag->tags[0]->tags[0]->tags[4]->cdata;
  }
  exibirErro('error',$msgErro,'Alerta - Ayllos','',false);
 }

$teste = $xmlObject->roottag->tags;
//$qtregist = count($teste[0]->tags); // Pega a quantidade de registros

$xml = getXML( $xmlResult );
$att = $xml->Dados[0]->attributes();
$qtregist = $att['qtdregis'];
?>

<style>
	.tituloRegistros{cursor: pointer;}
	.linha{cursor: pointer;}
	.linha:hover {outline: rgb(107,121,132) solid 1px !important;}
	.conta {width:56px;}
	.aplic {width:2.9em;}
	.aplic2 {width:6.5em;}
	.dtref {width:5.3em;}
	.tpreg {width:3.5em;}
	.val {width:4.7em;}
	.reenv {width:3.3em;}
	.sit {width:6.6em;}
</style>

  <table class="tituloRegistros" style="background-color: #f7d3ce;" onload="formataTabArquivos();">
  	<thead>
		<tr> 
          <th class="headerSort conta" onclick="sortTable('tableHistoricoOperacoes', 1)">Conta</th>
          <th class="headerSort aplic" onclick="sortTable('tableHistoricoOperacoes', 2)">Aplic</th>
          <th class="headerSort aplic2" onclick="sortTable('tableHistoricoOperacoes', 3)">Aplic</th>
          <th class="headerSort dtref" onclick="sortTable('tableHistoricoOperacoes', 4)">Dt Ref</th>
          <th class="headerSort tpreg" onclick="sortTable('tableHistoricoOperacoes', 5)">Tipo Reg</th>
          <th class="headerSort val" onclick="sortTable('tableHistoricoOperacoes', 6)">Valor</th>
          <th class="headerSort reenv" onclick="sortTable('tableHistoricoOperacoes', 7)">Re Envio</th>
          <th class="headerSort sit" onclick="sortTable('tableHistoricoOperacoes', 8)"><?php echo utf8ToHtml('Situação'); ?></th>
          <th class="headerSort" onclick="sortTable('tableHistoricoOperacoes', 9)"><?php echo utf8ToHtml('Crítica'); ?></th>
          <th class="ordemInicial"></th>
			</tr>
		</thead>
	</table>
  <div class="divRegistros tabelasorting">
	<table id="tableHistoricoOperacoes">
    <thead class="tituloRegistros" style="display: none;background-color: #f7d3ce;" onload="formataTabArquivos();">
      <tr>   
        <th class="headerSort" onclick="sortTable('tableHistoricoOperacoes', 1)">Conta</th>
        <th class="headerSort" onclick="sortTable('tableHistoricoOperacoes', 2)">Aplic</th>
        <th class="headerSort" onclick="sortTable('tableHistoricoOperacoes', 3)">Aplic</th>
        <th class="headerSort" onclick="sortTable('tableHistoricoOperacoes', 4)">Dt Ref</th>    
        <th class="headerSort" onclick="sortTable('tableHistoricoOperacoes', 5)">Tipo Reg</th>
        <th class="headerSort" onclick="sortTable('tableHistoricoOperacoes', 6)">Valor</th>
        <th class="headerSort" onclick="sortTable('tableHistoricoOperacoes', 7)">Re Envio</th>
        <th class="headerSort" onclick="sortTable('tableHistoricoOperacoes', 8)"><?php echo utf8ToHtml('Situação'); ?></th>
        <th class="headerSort" onclick="sortTable('tableHistoricoOperacoes', 9)"><?php echo utf8ToHtml('Crítica'); ?></th>
        <th class="ordemInicial"></th>
		  </tr>
    </thead>
		<tbody style="text-align: center;">
		<?php
            $parImpar=1; //echo json_encode(getByTagName( $itemGrid->tags, 'dssituac')); die();
			foreach($teste[0]->tags as $itemGrid) {
                $classelinha='';
                $selecionavel='';                       
				
				$NRDCONTA = getByTagName( $itemGrid->tags, 'nrdconta'); 
				$NRAPLICA = getByTagName( $itemGrid->tags, 'nraplica');
				$DSTPAPLI = getByTagName( $itemGrid->tags, 'dstpapli'); 
                $DTREFERE = getByTagName( $itemGrid->tags, 'dtrefere');
				$CDHISTOR = getByTagName( $itemGrid->tags, 'cdhistor'); 
				$CDTIPREG = getByTagName( $itemGrid->tags, 'cdtipreg');
				$VLLANCTO = getByTagName( $itemGrid->tags, 'vllancto'); 
				$IDREENVI = getByTagName( $itemGrid->tags, 'idreenvi'); 
				$DSSITUAC = getByTagName( $itemGrid->tags, 'dssituac'); 
				$DSCRITIC = getByTagName( $itemGrid->tags, 'dscritic');
                if($parImpar==1) { 
                    $classelinha='even corImpar'; 
                    $parImpar=2; 
                } else if($parImpar==2) { 
                    $classelinha='odd corPar';    
                    $parImpar=1; 
                }
                if($DSSITUAC=='Erro'){                  
                    $selecionavel='arqselecionavel';
                }
				
                
                echo '<tr class="linha ',$classelinha,'"  id="linhatableOperacoes',$IDLANCTO,'">
                ',$tdcbk,'
                        <td id="NRDCONTA-',$IDLANCTO,'" class="celula conta" title="Conta">',                       ($NRDCONTA),'</td>
                        <td id="NRAPLICA-',$IDLANCTO,'" class="celula aplic" title="',utf8ToHtml('Aplicação'),'">', ($NRAPLICA),'</td>
                        <td id="DSTPAPLI-',$IDLANCTO,'" class="celula aplic2" title="Tipo Aplic">',                 ($DSTPAPLI),'</td>
                        <td id="DTREFERE-',$IDLANCTO,'" class="celula dtref" title="Data Ref">',                    ($DTREFERE),'</td>                        
                        <td id="CDTIPREG-',$IDLANCTO,'" class="celula tpreg" title="Tipo Reg.">',                   ($CDTIPREG),'</td>
                        <td id="VLLANCTO-',$IDLANCTO,'" class="celula val" title="Valor">',                       	($VLLANCTO),'</td>
                        <td id="IDREENVI-',$IDLANCTO,'" class="celula reenv" title="Re-Envio">',                    ($IDREENVI),'</td>
                        <td id="DSSITUAC-',$IDLANCTO,'" class="celula sit" title="',utf8ToHtml('Situação'),'">',	($DSSITUAC),'</td>
                        <td id="DSCRITIC-',$IDLANCTO,'" class="celula" style="" title="',utf8ToHtml('Crítica'),'">', utf8ToHtml($DSCRITIC),'</td>
                    </tr>';
			}
		?>
	</tbody>
</table>
</div>
<div id="divPesquisaRodapeNeto" class="divPesquisaRodape">
        <table>
            <tr>
                <td>
                    <?php
                    if (isset($qtregist) and $qtregist == 0) $nriniseq = 0;
                    if ($nriniseq > 1) {
                    ?> <a class='paginacaoAnteriorNeto'><<< Anterior</a> <?php
                    } else {
                    ?> &nbsp; <?php
                    }
                    ?>
                </td>
                <td>
                    <?php
                    if ($nriniseq) {
                    ?> Exibindo <?php echo $nriniseq; ?> at&eacute; <?php if (($nriniseq + $nrregist) > $qtregist) { echo $qtregist; } else { echo ($nriniseq + $nrregist - 1); } ?> de <?php echo $qtregist; ?>
                    <?php } ?>
                </td>
                <td>
                    <?php
                    if ($qtregist > ($nriniseq + $nrregist - 1)) {
                    ?> <a class='paginacaoProximoNeto'>Pr&oacute;ximo >>></a> <?php
                    } else {
                    ?> &nbsp; <?php
                    }
                    ?>
                </td>
            </tr>
        </table>
    </div>
</div>
<script type="text/javascript">
	
    $('a.paginacaoAnteriorNeto').unbind('click').bind('click', function() {
        buscaHistoricoAplicacao(<?php echo "'" . $idaplicacao . "','" . ($nriniseq - $nrregist) . "','" . $nrregist . "'"; ?>);
    });

    $('a.paginacaoProximoNeto').unbind('click').bind('click', function() {
        buscaHistoricoAplicacao(<?php echo "'" . $idaplicacao . "','" . ($nriniseq + $nrregist) . "','" . $nrregist . "'"; ?>);
    });

    $('#divPesquisaRodapeNeto', '#divTela').formataRodapePesquisa();
</script>