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

 ?>
 <script type="text/javascript" src="../../scripts/funcoes.js"></script>
 <?

 // Guardo os parâmetos do POST em variáveis
 $cdcooper  = (isset($_POST['cdcooper']))  ? $_POST['cdcooper'] : '';
 $nrdconta  = (isset($_POST['nrdconta']))  ? $_POST['nrdconta'] : 0 ;
 $nraplica  = (isset($_POST['nraplica']))  ? $_POST['nraplica'] : 0 ;
 $flgcritic  = (isset($_POST['flgcritic']))  ? $_POST['flgcritic'] : 0 ;
 $datade  = (isset($_POST['datade']))  ? $_POST['datade'] : '';
 $datate  = (isset($_POST['datate']))  ? $_POST['datate'] : '';
 $nmarquiv  = (isset($_POST['nmarquiv']))  ? $_POST['nmarquiv'] : '' ;
 $dscodib3  = (isset($_POST['dscodib3']))  ? $_POST['dscodib3'] : '' ;

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



 $retorno = $xmlObject->roottag->tags;
?>

<style>
.tituloRegistros{    cursor: pointer;}
.linha:hover {
    outline: rgb(107,121,132) solid 1px !important;
}
</style>
<br /><br /><br />
<h2> Registros do Arquivo </h2>
<br />
  <table class="tituloRegistros" style="background-color: #f7d3ce;" onload="formataTabArquivos)();">
  	<thead>
				<tr>
          <th class="headerSort" style="width:1.5em;"><input type="checkbox" id="ckbAll" onclick="atualizaSelecao('*','')"></th>
          <th class="headerSort" style="display:none;">Linha</th>
          <th class="headerSort" style="width:7.2em;" onclick="sortTable('tableOperacoes', 2)">Codigo If</th>
          <th class="headerSort" style="width:7.6em;" onclick="sortTable('tableOperacoes', 3)">Cooperativa</th>
          <th class="headerSort" style="width:4.2em;" onclick="sortTable('tableOperacoes', 4)">Conta</th>
          <th class="headerSort" style="width:2.9em;" onclick="sortTable('tableOperacoes', 5)">Aplic</th>
          <th class="headerSort" style="width:4.5em;" onclick="sortTable('tableOperacoes', 6)">Aplic</th>
          <th class="headerSort" style="width:5.3em;" onclick="sortTable('tableOperacoes', 7)">Dt Ref</th>
          <th class="headerSort" style="width:3.0em;" onclick="sortTable('tableOperacoes', 8)">Hist</th>
          <th class="headerSort" style="width:3.5em;" onclick="sortTable('tableOperacoes', 9)">Tipo Reg</th>
          <th class="headerSort" style="width:4.7em;" onclick="sortTable('tableOperacoes', 10)">Valor</th>
          <th class="headerSort" style="width:3.3em;" onclick="sortTable('tableOperacoes', 11)">Re Envio</th>
          <th class="headerSort" style="width:6.6em;" onclick="sortTable('tableOperacoes', 12)"><?php echo utf8ToHtml('Situação'); ?></th>
          <th class="headerSort" onclick="sortTable('tableOperacoes', 13)"><?php echo utf8ToHtml('Crítica'); ?></th>
          <th class="ordemInicial"></th>
			</tr>
		</thead>
	</table>
  <div class="divRegistros tabelasorting">
	<table id="tableOperacoes">
    <thead class="tituloRegistros" style="display: none;background-color: #f7d3ce;" onload="formataTabArquivos)();">
      <tr>
        <th class="headerSort"><input type="checkbox" id="ckbAll" onclick="atualizaSelecao('*','')"></th>
        <th class="headerSort" style="display:none;">Linha</th>
        <th class="headerSort" onclick="sortTable('tableOperacoes', 2)">Codigo If</th>
        <th class="headerSort" onclick="sortTable('tableOperacoes', 3)">Cooperativa</th>
        <th class="headerSort" onclick="sortTable('tableOperacoes', 4)">Conta</th>
        <th class="headerSort" onclick="sortTable('tableOperacoes', 5)">Aplic</th>
        <th class="headerSort" onclick="sortTable('tableOperacoes', 6)">Aplic</th>
        <th class="headerSort" onclick="sortTable('tableOperacoes', 7)">Dt Ref</th>
        <th class="headerSort" onclick="sortTable('tableOperacoes', 8)">Hist</th>
        <th class="headerSort" onclick="sortTable('tableOperacoes', 9)">Tipo Reg</th>
        <th class="headerSort" style="width:3.5%" onclick="sortTable('tableOperacoes', 10)">Valor</th>
        <th class="headerSort" onclick="sortTable('tableOperacoes', 11)">Re Envio</th>
        <th class="headerSort" style="width:8%" onclick="sortTable('tableOperacoes', 12)"><?php echo utf8ToHtml('Situação'); ?></th>
        <th class="headerSort" onclick="sortTable('tableOperacoes', 13)"><?php echo utf8ToHtml('Crítica'); ?></th>
        <th class="ordemInicial"></th>
		  </tr>
    </thead>
		<tbody style="text-align: center;">
		<?php
      $parImpar=1;//echo json_encode($retorno[0]->tags[0]->tags); die();
			foreach($retorno[0]->tags as $itemGrid){
        $classelinha='';
        $tdcbk='<td class="celula" style="width:1.5em;"></td>';
        $selecionavel='';
				$IDLANCTO = $itemGrid->tags[0]->cdata;
				$DSCODIB3 = $itemGrid->tags[1]->cdata;
				$DSCOOPER = $itemGrid->tags[2]->cdata;
				$NRDCONTA = $itemGrid->tags[3]->cdata;
				$NRAPLICA = $itemGrid->tags[4]->cdata;
				$DSTPAPLI = $itemGrid->tags[5]->cdata;
        $DTREFERE = $itemGrid->tags[6]->cdata;
				$CDHISTOR = $itemGrid->tags[7]->cdata;
				$CDTIPREG = $itemGrid->tags[8]->cdata;
				$VLLANCTO = $itemGrid->tags[9]->cdata;
				$IDREENVI = $itemGrid->tags[10]->cdata;
				$DSSITUAC = $itemGrid->tags[11]->cdata;
				$DSCRITIC = $itemGrid->tags[12]->cdata;
             if($parImpar==1){ $classelinha='even corImpar'; $parImpar=2; }
        else if($parImpar==2){ $classelinha='odd corPar';    $parImpar=1; }
        if($DSSITUAC=='Erro'){
          $tdcbk='<td class="celula" style="width:1.5em;"><input type="checkbox" id="ckb'.$IDLANCTO.'" class="ckbSelecionaLinha" onclick="atualizaSelecao(\'ckb'.$IDLANCTO.'\',\'NRSEQLIN-'.$IDLANCTO.'\');"></td>';
          $selecionavel='arqselecionavel';
        }
				echo '<tr class="linha ',$classelinha,'"  id="linhatableOperacoes',$IDLANCTO,'" onclick="selecionaLinha(\'tableOperacoes\',\'linhatableOperacoes',$IDLANCTO,'\');">
                ',$tdcbk,'
								<td id="NRSEQLIN-',$IDLANCTO,'" class="celula ',$selecionavel,'" style="display:none;" title="Linha">',    ($IDLANCTO),'</td>
								<td id="DSCODIB3-',$IDLANCTO,'" class="celula" title="Código IF" style="width:7.2em;">',                   ($DSCODIB3),'</td>
								<td id="DSCOOPER-',$IDLANCTO,'" class="celula" style="width:7.6em;" title="Coop">',                        ($DSCOOPER),'</td>
								<td id="NRDCONTA-',$IDLANCTO,'" class="celula" style="width:4.2em;" title="Conta">',                       ($NRDCONTA),'</td>
								<td id="NRAPLICA-',$IDLANCTO,'" class="celula" style="width:2.9em;" title="',utf8ToHtml('Aplicação'),'">', ($NRAPLICA),'</td>
								<td id="DSTPAPLI-',$IDLANCTO,'" class="celula" style="width:4.5em;" title="Tipo Aplic">',                  ($DSTPAPLI),'</td>
                <td id="DTREFERE-',$IDLANCTO,'" class="celula" style="width:5.3em;" title="Data Ref">',                    ($DTREFERE),'</td>
								<td id="CDHISTOR-',$IDLANCTO,'" class="celula" style="width:3.0em;" title="',utf8ToHtml('Histórico'),'">', ($CDHISTOR),'</td>
								<td id="CDTIPREG-',$IDLANCTO,'" class="celula" style="width:3.5em;" title="Tipo Reg.">',                   ($CDTIPREG),'</td>
								<td id="VLLANCTO-',$IDLANCTO,'" class="celula" style="width:4.7em;" title="Valor">',                       ($VLLANCTO),'</td>
								<td id="IDREENVI-',$IDLANCTO,'" class="celula" style="width:3.3em;" title="Re-Envio">',                    ($IDREENVI),'</td>
								<td id="DSSITUAC-',$IDLANCTO,'" class="celula" style="width:6.6em;" title="',utf8ToHtml('Situação'),'">',   ($DSSITUAC),'</td>
								<td id="DSCRITIC-',$IDLANCTO,'" class="celula" style="" title="',utf8ToHtml('Crítica'),'">', utf8ToHtml($DSCRITIC),'</td>
							</tr>';
			}
		?>

	</tbody>
</table>
</div>
<br />
<p>
  <b>Legenda Tipo Registro:</b> REG: Registro e Dep&oacute;sito da Emiss&atilde;o&nbsp;&nbsp;&nbsp;&nbsp;RGT: Resgate Antecipado&nbsp;&nbsp;&nbsp;&nbsp;RIR: Reten&ccedil;&atilde;o IR
</p>
