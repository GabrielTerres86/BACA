<?
//*********************************************************************************************//
//*** Fonte: log_arquivos.php                                     						              ***//
//*** Autor: Rafael B. Arins - Envolti                                           						***//
//*** Data : Abril/2018                  Última Alteração: --/--/----  					            ***//
//***                                                                  						          ***//
//*** Objetivo  : Busca o log de arquivos (CUSAPL_LISTA_LOG_ARQ).                           ***//
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
 $nomeArquivo  = (isset($_POST['nomearquivo']))  ? $_POST['nomearquivo'] : '' ;
 $opcaoArquivo  = (isset($_POST['opcaoarquivo']))  ? $_POST['opcaoarquivo'] : '' ;
 $tipoArquivo  = (isset($_POST['tipoarquivo']))  ? $_POST['tipoarquivo'] : '' ;
 // Montar o xml de Requisicao
 $xmlCarregaDados = "";
 $xmlCarregaDados .= "<Root>";
 $xmlCarregaDados .= " <Dados>";
 $xmlCarregaDados .= " <idarquivo>".$idArquivo."</idarquivo>";
 $xmlCarregaDados .= " </Dados>";
 $xmlCarregaDados .= "</Root>";
 $xmlResult = mensageria($xmlCarregaDados
  ,"TELA_CUSAPL"
  ,"CUSAPL_LISTA_LOG_ARQ"
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
	.corpo{height:24em; background-color: #f4f3f0;    text-align: center; padding:1em;}
</style>
<div class="txtBrancoBold ponteiroDrag" style="padding: 0.5em 0.5em 1.0em 0.5em;text-transform: uppercase;background-color: #6f7a86;">
	<span class="tituloJanelaPesquisa"><b>Detalhes de LOG de Arquivo</b></span>
	<a href="#" class="botao" style="position:absolute; right: 0;" onClick="fechaModal();return false;"><b>X</b></a>
</div>

<div class="tableLogsDeArquivo corpo">
  <table class="tituloRegistros" style="background-color: #f7d3ce;" onload="formataTabArquivos)();">
  	<thead>
  				<tr>
            <th style="width:225px" class="headerSort" onclick="sortTable('tableInfoLog', 0)" >Log do Arquivo</th>
      	    <th style="width:194px" class="headerSort" onclick="sortTable('tableInfoLog', 1)" >Tipo Arquivo</th>
      	    <th style="width:115px" class="headerSort" onclick="sortTable('tableInfoLog', 2)" >Op&ccedil;&atilde;o</th>
  					<th class="ordemInicial"></th>
  			</tr>
  		</thead>
  	</table>
    <table id="tableInfoLog" class="tabela">
      <thead style="display:none">
        <tr>
          <th style="width:225px" class="headerSort">Log do Arquivo</th>
          <th style="width:194px" class="headerSort">Tipo Arquivo</th>
          <th style="width:115px" class="headerSort">Op&ccedil;&atilde;o</th>
          <th class="ordemInicial"></th>
      </tr>
    </thead>
	<tbody>
			<tr class="linha">
		    <td style="width:225px" class="celula"><?php echo utf8_decode($nomeArquivo); ?></td>
		    <td style="width:194px" class="celula"><?php echo utf8_decode($tipoArquivo); ?></td>
		    <td style="width:115px" class="celula"><?php echo utf8_decode($opcaoArquivo); ?></td>
		  </tr>
	</tbody>
</table>

<br />
<div style="display:block;height:15em; overflow: auto;">
  <table class="tituloRegistros" style="background-color: #f7d3ce;" onload="formataTabArquivos)();">
  	<thead>
  				<tr>
    		    <th class="headerSort" onclick="sortTable('tableLog', 0)" style="width:11.2em">Data</th>
    		    <th class="headerSort" onclick="sortTable('tableLog', 1)" style="">Log</th>
  					<th class="ordemInicial"></th>
  			</tr>
  		</thead>
  	</table>
<table id="tableLog" class="tabela">
  <thead style="display:none">
        <tr>
          <th class="headerSort" style="width:12em">Data</th>
          <th class="headerSort" style="">Log</th>
          <th class="ordemInicial"></th>
      </tr>
    </thead>
	<tbody>
		<?php
			foreach($teste[0]->tags as $itemGrid){
				$DTLOG = $itemGrid->tags[0]->cdata;
				$DSLOG = $itemGrid->tags[1]->cdata;
				echo '<tr class="linha">
								<td id="DSTIPARQ" class="celula" title="Tipo" style="width:12em">',trim($DTLOG),'</td>
								<td id="DTREFERE" class="celula" title="Dt Ref" style="">',($DSLOG),'</td>
							</tr>';
			}
		?>

	</tbody>
</table>
</div>

<br />
<a href="#" class="botao" id="btVoltar" name="btVoltar" onClick="fechaModal();return false;">Voltar</a>
</div>

<script type="text/javascript">
	$('#divPesquisaRodape','#divTela').formataRodapePesquisa();
</script>
