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

 ?>
 <script type="text/javascript" src="../../scripts/funcoes.js"></script>
 <?

 // Guardo os parâmetos do POST em variáveis
 $idArquivo  = (isset($_POST['idarquivo']))  ? $_POST['idarquivo'] : 0 ;
 // Montar o xml de Requisicao
 $xmlCarregaDados = "";
 $xmlCarregaDados .= "<Root>";
 $xmlCarregaDados .= " <Dados>";
 $xmlCarregaDados .= " <idarquivo>".$idArquivo."</idarquivo>";
 $xmlCarregaDados .= " </Dados>";
 $xmlCarregaDados .= "</Root>";
 $xmlResult = mensageria($xmlCarregaDados
  ,"TELA_CUSAPL"
  ,"CUSAPL_LISTA_CONT_ARQ"
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
?>

<style>
	.tabela {    font-family: arial, sans-serif;    border-collapse: collapse;    width: 100%;}
	.celula {    border: 1px solid #dddddd;    text-align: left;    padding: 8px;}
	.linha:nth-child(even) {    background-color: #dddddd;}
	.trcabecalho{background-color: #b6c0c1;}
</style>
<br />
<h2> Registros do Arquivo </h2>
<br />
<table class="tituloRegistros" style="background-color: #f7d3ce;" onload="formataTabArquivos)();">
	<thead>
				<tr>
          <th class="headerSort" onclick="sortTable('tableRegistros', 0)" style="width:2.3em;">Lin</th>
  		    <th class="headerSort" onclick="sortTable('tableRegistros', 1)" style="width:7.2em;">Codigo If</th>
  		    <th class="headerSort" onclick="sortTable('tableRegistros', 2)" style="width:7.6em;">Cooperativa</th>
  		    <th class="headerSort" onclick="sortTable('tableRegistros', 3)" style="width:4.7em;">Conta</th>
  		    <th class="headerSort" onclick="sortTable('tableRegistros', 4)" style="width:2.9em;">Aplic</th>
  		    <th class="headerSort" onclick="sortTable('tableRegistros', 5)" style="width:4.5em;">Tipo Aplic</th>
  		    <th class="headerSort" onclick="sortTable('tableRegistros', 6)" style="width:3.0em;">Hist</th>
  		    <th class="headerSort" onclick="sortTable('tableRegistros', 7)" style="width:3.5em;">Tipo Reg</th>
  		    <th class="headerSort" onclick="sortTable('tableRegistros', 8)" style="width:4.7em;">Valor</th>
  		    <th class="headerSort" onclick="sortTable('tableRegistros', 9)" style="width:3.3em;">Re Envio</th>
  		    <th class="headerSort" onclick="sortTable('tableRegistros', 10)" style="width:6.6em;"><?php echo utf8ToHtml('Situação'); ?></th>
  		    <th class="headerSort" onclick="sortTable('tableRegistros', 11)" style=""><?php echo utf8ToHtml('Crítica'); ?></th>
					<th class="ordemInicial"></th>
			</tr>
		</thead>
	</table>
	<div class="divRegistros tabelasorting">
	<table id="tableRegistros" class="tabela">
    <thead>
  				<tr>
            <th class="headerSort" style="width:4%">Lin</th>
    		    <th class="headerSort" style="width:10%">Codigo If</th>
    		    <th class="headerSort" style="width:11%">Cooperativa</th>
    		    <th class="headerSort" style="width:6%">Conta</th>
    		    <th class="headerSort" style="width:5%">Aplic</th>
    		    <th class="headerSort" style="width:6%">Aplic</th>
    		    <th class="headerSort" style="width:5%">Hist</th>
    		    <th class="headerSort" style="width:5%">Tipo Reg</th>
    		    <th class="headerSort" style="width:6%">Valor</th>
    		    <th class="headerSort" style="width:6%">Re Envio</th>
    		    <th class="headerSort" style="width:7.5%"><?php echo utf8ToHtml('Situação'); ?></th>
    		    <th class="headerSort" style=""><?php echo utf8ToHtml('Crítica'); ?></th>
  					<th class="ordemInicial"></th>
  			</tr>
  		</thead>
		<tbody>
		<?php
    if(count($teste[0]->tags)){
			foreach($teste[0]->tags as $itemGrid){
				$NRSEQLIN = $itemGrid->tags[0]->cdata;
				$DSCODIB3 = $itemGrid->tags[1]->cdata;
				$DSCOOPER = $itemGrid->tags[2]->cdata;
				$NRDCONTA = $itemGrid->tags[3]->cdata;
				$NRAPLICA = $itemGrid->tags[4]->cdata;
				$DSTPAPLI = $itemGrid->tags[5]->cdata;
				$CDHISTOR = $itemGrid->tags[6]->cdata;
				$CDTIPREG = $itemGrid->tags[7]->cdata;
				$VLLANCTO = $itemGrid->tags[8]->cdata;
				$IDREENVI = $itemGrid->tags[9]->cdata;
				$DSSITUAC = $itemGrid->tags[10]->cdata;
				$DSCRITIC = $itemGrid->tags[11]->cdata;
				echo '<tr class="linha" id="linhatableRegistros',$NRSEQLIN,'" onclick="selecionaLinha(\'tableRegistros\',\'linhatableRegistros',$NRSEQLIN,'\');">
								<td id="DSTIPARQ" class="celula" style="width: 2.3em; text-align: right;" title="Linha">',                       ($NRSEQLIN),'</td>
								<td id="DSTIPARQ" class="celula" style="width: 7.2em;" title="Código IF">',                                      ($DSCODIB3),'</td>
								<td id="DSTIPARQ" class="celula" style="width:7.6em;" title="Coop">',                                            ($DSCOOPER),'</td>
								<td id="DSTIPARQ" class="celula" style="width:4.7em; text-align: right;" title="Conta">',                        ($NRDCONTA),'</td>
								<td id="DSTIPARQ" class="celula" style="width: 2.9em; text-align: right;" title="',utf8ToHtml('Aplicação'),'">', ($NRAPLICA),'</td>
								<td id="DSTIPARQ" class="celula" style="width: 4.5em;" title="Tipo Aplic">',                                     ($DSTPAPLI),'</td>
								<td id="DSTIPARQ" class="celula" style="width:3.0em; text-align: right;" title="',utf8ToHtml('Histórico'),'">',  ($CDHISTOR),'</td>
								<td id="DSTIPARQ" class="celula" style="width:3.5em;" title="Tipo Reg.">',                                       ($CDTIPREG),'</td>
								<td id="DSTIPARQ" class="celula" style="width:4.7em; text-align: right;" title="Valor">',                        ($VLLANCTO),'</td>
								<td id="DSTIPARQ" class="celula" style="width:3.3em;" title="Re-Envio">',                                        ($IDREENVI),'</td>
								<td id="DSTIPARQ" class="celula" style="width:6.6em;" title="',utf8ToHtml('Situação'),'">',                      ($DSSITUAC),'</td>
								<td id="DSTIPARQ" class="celula" style="" title="',utf8ToHtml('Crítica'),'">',   ($DSCRITIC),'</td>
							</tr>';
			}
    }else {
      echo '<tr class="linha">
              <td class="celula" colspan="12">Sem Registros Encontrados!</td>
            </tr>';
    }
		?>

	</tbody>
</table>
</div>

<br />
<div id="Legenda2">
	<p>
	  <b>Legenda Tipo Registro:</b> REG: Registro e Dep&oacute;sito da Emiss&atilde;o&nbsp;&nbsp;&nbsp;&nbsp;RGT: Resgate Antecipado&nbsp;&nbsp;&nbsp;&nbsp;RIR: Reten&ccedil;&atilde;o IR&nbsp;&nbsp;&nbsp;&nbsp;CNC: Concilia&ccedil;&atilde;o
	</p>
</div>
