<?
//*********************************************************************************************//
//*** Fonte: busca_log_operacoes.php                                    						        ***//
//*** Autor: Rafael B. Arins - Envolti                                           						***//
//*** Data : Abril/2018                  Última Alteração: --/--/----  					            ***//
//***                                                                  						          ***//
//*** Objetivo  : Busca log de operacoes da tela CUSAPL                   						      ***//
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

 // Guardo os parâmetos do POST em variáveis
 $cdcooper  = (isset($_POST['cdcooper']))  ? $_POST['cdcooper'] : '';
 $nrdconta  = (isset($_POST['nrdconta']))  ? $_POST['nrdconta'] : 0 ;
 $nraplica  = (isset($_POST['nraplica']))  ? $_POST['nraplica'] : 0 ;
 $flgcritic  = (isset($_POST['flgcritic']))  ? $_POST['flgcritic'] : 0 ;
 $datade  = (isset($_POST['datade']))  ? $_POST['datade'] : '';
 $datate  = (isset($_POST['datate']))  ? $_POST['datate'] : '';
 $nmarquiv  = (isset($_POST['nmarquiv']))  ? $_POST['nmarquiv'] : '' ;
 $dscodib3  = (isset($_POST['dscodib3']))  ? $_POST['dscodib3'] : '' ;

 // Parametros para utilizar na paginação
 $nrregist = (isset($_POST['nrregist'])) ? $_POST['nrregist'] : 15;
 $nriniseq = (isset($_POST['nriniseq'])) ? $_POST['nriniseq'] : 1;


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
 $xmlCarregaDados .= " <nriniseq>". $nriniseq ."</nriniseq>";
 $xmlCarregaDados .= " <nrregist>". $nrregist ."</nrregist>"; 
 $xmlCarregaDados .= " </Dados>";
 $xmlCarregaDados .= "</Root>";

   // Executa script para envio do XML
 $xmlResult =  mensageria($xmlCarregaDados
                         ,"TELA_CUSAPL"
                         ,"CUSAPL_LISTA_OPERAC"
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
$qtregist = count($teste[0]->tags); // Pega a quantidade de registros

$xml = getXML( $xmlResult );
$att = $xml->Dados[0]->attributes();
$qtregist = $att['qtdregis'];
?>

<style>
.tituloRegistros{    cursor: pointer;}
	.linha{cursor: pointer;}
	.linha:hover { outline: rgb(107,121,132) solid 1px !important; }
	.atu 	{width:1.5em;}
	.codif 	{width:7.2em;}
	.coop 	{width:7.6em;}
	.conta 	{width:4.2em;}
	.apli 	{width:2.9em;}
	.apli2 	{width:6.5em;}
	.dtref 	{width:5.3em;}
	.hist 	{width:3.0em;}
	.tpreg 	{width:3.5em;}
	.val 	{width:4.7em;}
	.reenv 	{width:3.3em;}
	.sit 	{width:6.6em;}
</style>
<br /><br />
<h2> Registros do Arquivo </h2>
<p><b>Legenda Tipo Registro:</b> REG: Registro e Dep&oacute;sito da Emiss&atilde;o&nbsp;&nbsp;&nbsp;&nbsp;RGT: Resgate Antecipado&nbsp;&nbsp;&nbsp;&nbsp;RIR: Reten&ccedil;&atilde;o I</p>
<br />
  <table class="tituloRegistros" style="background-color: #f7d3ce;" onload="formataTabArquivos();">
  	<thead>
				<tr>
          <th class="headerSort atu"><input type="checkbox" id="ckbAll" onclick="atualizaSelecao('*','')"></th>
          <th class="headerSort codif" onclick="sortTable('tableOperacoes', 2)">Codigo If</th>
          <th class="headerSort coop" onclick="sortTable('tableOperacoes', 3)">Cooperativa</th>
          <th class="headerSort conta" onclick="sortTable('tableOperacoes', 4)">Conta</th>
          <th class="headerSort apli" onclick="sortTable('tableOperacoes', 5)">Aplic</th>
          <th class="headerSort apli2" onclick="sortTable('tableOperacoes', 6)">Aplic</th>
          <th class="headerSort dtref" onclick="sortTable('tableOperacoes', 7)">Dt Ref</th>
          <th class="headerSort hist" onclick="sortTable('tableOperacoes', 8)">Hist</th>
          <th class="headerSort tpreg" onclick="sortTable('tableOperacoes', 9)">Tipo Reg</th>
          <th class="headerSort val" onclick="sortTable('tableOperacoes', 10)">Valor</th>
          <th class="headerSort reenv" onclick="sortTable('tableOperacoes', 11)">Re Envio</th>
          <th class="headerSort sit" onclick="sortTable('tableOperacoes', 12)"><?php echo utf8ToHtml('Situação'); ?></th>
          <th class="headerSort" onclick="sortTable('tableOperacoes', 13)"><?php echo utf8ToHtml('Crítica'); ?></th>
          <th class="ordemInicial"></th>
			</tr>
		</thead>
	</table>
  <div class="divRegistros tabelasorting">
	<table id="tableOperacoes">
    <thead class="tituloRegistros" style="background-color: #f7d3ce;" onload="formataTabArquivos();">
      <tr>
        <th class="headerSort"><input type="checkbox" id="ckbAll" onclick="atualizaSelecao('*','')"></th>
        <th class="headerSort" onclick="sortTable('tableOperacoes', 2)">Codigo If</th>
        <th class="headerSort" onclick="sortTable('tableOperacoes', 3)">Cooperativa</th>
        <th class="headerSort" onclick="sortTable('tableOperacoes', 4)">Conta</th>
        <th class="headerSort" onclick="sortTable('tableOperacoes', 5)">Aplic</th>
        <th class="headerSort" onclick="sortTable('tableOperacoes', 6)">Aplic</th>
        <th class="headerSort" onclick="sortTable('tableOperacoes', 7)">Dt Ref</th>
        <th class="headerSort" onclick="sortTable('tableOperacoes', 8)">Hist</th>
        <th class="headerSort" onclick="sortTable('tableOperacoes', 9)">Tipo Reg</th>
        <th class="headerSort" onclick="sortTable('tableOperacoes', 10)">Valor</th>
        <th class="headerSort" onclick="sortTable('tableOperacoes', 11)">Re Envio</th>
        <th class="headerSort" onclick="sortTable('tableOperacoes', 12)"><?php echo utf8ToHtml('Situação'); ?></th>
        <th class="headerSort" onclick="sortTable('tableOperacoes', 13)"><?php echo utf8ToHtml('Crítica'); ?></th>
        <th class="ordemInicial"></th>
		  </tr>
    </thead>
		<tbody style="text-align: center;">
		<?php
            $parImpar=1; //echo json_encode(getByTagName( $itemGrid->tags, 'dssituac')); die();
			foreach($teste[0]->tags as $itemGrid)
            {
        $classelinha='';
        $tdcbk='<td class="celula" style="width:1.5em;"></td>';
        $selecionavel='';
                        
				$IDLANCTO = getByTagName( $itemGrid->tags, 'idlancto');
				$DSCODIB3 = getByTagName( $itemGrid->tags, 'dscodib3');
				$DSCOOPER = getByTagName( $itemGrid->tags, 'dscooper');
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
                $APLICACAO = getByTagName( $itemGrid->tags, 'idaplicacao');

                if($parImpar==1) { 
                    $classelinha='even corImpar'; 
                    $parImpar=2; 
                } else if($parImpar==2) { 
                    $classelinha='odd corPar';    
                    $parImpar=1; 
                }
        if($DSSITUAC=='Erro'){
                    $tdcbk='<td class="celula arqselecionavel" style="width:1.5em;" data-linha="'.$IDLANCTO.'" ><input type="checkbox" id="ckb'.$IDLANCTO.'" class="ckbSelecionaLinha" onclick="atualizaSelecao(\'ckb'.$IDLANCTO.'\',\'NRSEQLIN-'.$IDLANCTO.'\');" value="'.$IDLANCTO.'" /></td>';
                    //$selecionavel='arqselecionavel';
        }
				
                // Monta a função js para chamar o bloco filho com o histórico da aplicação
                $buscaHistoricoAplicacao = 'new buscaHistoricoAplicacao(\'' . $APLICACAO . '\',\'\',\'\');';
                
				echo '<tr class="linha ',$classelinha,'"  id="linhatableOperacoes',$IDLANCTO,'" onclick="selecionaLinha(\'tableOperacoes\',\'linhatableOperacoes',$IDLANCTO,'\');">
                ',$tdcbk,'
                        <td id="DSCODIB3-',$IDLANCTO,'" class="celula codif" title="',utf8ToHtml('Código IF'),'" onclick="'.$buscaHistoricoAplicacao.'" >', ($DSCODIB3),'</td>
                        <td id="DSCOOPER-',$IDLANCTO,'" class="celula coop" title="Coop" onclick="'.$buscaHistoricoAplicacao.'" >',                        ($DSCOOPER),'</td>
                        <td id="NRDCONTA-',$IDLANCTO,'" class="celula conta" title="Conta" onclick="'.$buscaHistoricoAplicacao.'" >',                       ($NRDCONTA),'</td>
                        <td id="NRAPLICA-',$IDLANCTO,'" class="celula apli" title="',utf8ToHtml('Aplicação'),'" onclick="'.$buscaHistoricoAplicacao.'" >', ($NRAPLICA),'</td>
                        <td id="DSTPAPLI-',$IDLANCTO,'" class="celula apli2" title="Tipo Aplic" onclick="'.$buscaHistoricoAplicacao.'" >',                  ($DSTPAPLI),'</td>
                        <td id="DTREFERE-',$IDLANCTO,'" class="celula dtref" title="Data Ref" onclick="'.$buscaHistoricoAplicacao.'" >',                    ($DTREFERE),'</td>
                        <td id="CDHISTOR-',$IDLANCTO,'" class="celula hist" title="',utf8ToHtml('Histórico'),'" onclick="'.$buscaHistoricoAplicacao.'" >', ($CDHISTOR),'</td>
                        <td id="CDTIPREG-',$IDLANCTO,'" class="celula tpreg" title="Tipo Reg." onclick="'.$buscaHistoricoAplicacao.'" >',                   ($CDTIPREG),'</td>
                        <td id="VLLANCTO-',$IDLANCTO,'" class="celula val" title="Valor" onclick="'.$buscaHistoricoAplicacao.'" >',                       ($VLLANCTO),'</td>
                        <td id="IDREENVI-',$IDLANCTO,'" class="celula reenv" title="Re-Envio" onclick="'.$buscaHistoricoAplicacao.'" >',                    ($IDREENVI),'</td>
                        <td id="DSSITUAC-',$IDLANCTO,'" class="celula sit" title="',utf8ToHtml('Situação'),'" onclick="'.$buscaHistoricoAplicacao.'" >',   ($DSSITUAC),'</td>
                        <td id="DSCRITIC-',$IDLANCTO,'" class="celula" title="',utf8ToHtml('Crítica'),'" onclick="'.$buscaHistoricoAplicacao.'" >', utf8ToHtml($DSCRITIC),'</td>
							</tr>';
			}
		?>

	</tbody>
</table>
</div>
<div id="divPesquisaRodape" class="divPesquisaRodape">
        <table>
            <tr>
                <td>
                    <?php
                    if (isset($qtregist) and $qtregist == 0) $nriniseq = 0;
                    if ($nriniseq > 1) {
                    ?> <a class='paginacaoAnterior'><<< Anterior</a> <?php
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
                    ?> <a class='paginacaoProximo'>Pr&oacute;ximo >>></a> <?php
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

    $('a.paginacaoAnterior').unbind('click').bind('click', function() {
        buscaLogOperacoes(<?php echo "'" . ($nriniseq - $nrregist) . "','" . $nrregist . "'"; ?>);
    });

    $('a.paginacaoProximo').unbind('click').bind('click', function() {
        buscaLogOperacoes(<?php echo "'" . ($nriniseq + $nrregist) . "','" . $nrregist . "'"; ?>);
    });

    $('#divPesquisaRodape', '#divTela').formataRodapePesquisa();
</script>
<br />