<?php

	/*****************************************************************************************************
	  Fonte: consulta_log.php                                               
	  Autor: Lombardi                                                  
	  Data : Outubro/2013                       						Última Alteração: --/--/----
	                                                                   
	  Objetivo  : Consulta log para o beneficiario em questão.
	                                                                 
	  Alterações: 	
	                                                                  
	*****************************************************************************************************/


	session_start();
	
	// Includes para controle da session, variáveis globais de controle, e biblioteca de funções	
	require_once("../../includes/config.php");
	require_once("../../includes/funcoes.php");	
	require_once("../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo método POST
	isPostMethod();	
		
	// Classe para leitura do xml de retorno
	require_once("../../class/xmlfile.php");
		
	// Carrega permissões do operador
	require_once('../../includes/carrega_permissoes.php');	
	
	$cddopcao = (isset($_POST["cddopcao"])) ? $_POST["cddopcao"] : '';
  
  if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {		
    
		exibirErro('error',$msgError,'Alerta - Aimaro','',false);
	}
  
  $dtreglog = (isset($_POST["dtreglog"])) ? $_POST["dtreglog"] : "";
	$nrrecben = (isset($_POST["nrrecben"])) ? $_POST["nrrecben"] : "";
	$nrdconta = (isset($_POST["nrdconta"])) ? $_POST["nrdconta"] : "";
  
  $nriniseq = (isset($_POST["nriniseq"])) ? $_POST["nriniseq"] : 1;
  $nrregist = (isset($_POST["nrregist"])) ? $_POST["nrregist"] : 1;
  
  $dtreglog = $dtreglog == "" ? "0" : $dtreglog;
  $nrrecben = $nrrecben == "" ? "0" : $nrrecben;
  $nrdconta = $nrdconta == "" || $nrdconta == "0000.000-0" ? "0" : $nrdconta;
  
  
	$xmlConsultaLog  = "";
	$xmlConsultaLog .= "<Root>";
	$xmlConsultaLog .= "   <Dados>";
	$xmlConsultaLog .= "	   <dtmvtlog>".$dtreglog."</dtmvtlog>";	
	$xmlConsultaLog .= "	   <nrdnblog>".$nrrecben."</nrdnblog>";
	$xmlConsultaLog .= "	   <nrdctlog>".$nrdconta."</nrdctlog>";	
	$xmlConsultaLog .= "	   <nriniseq>".$nriniseq."</nriniseq>";
	$xmlConsultaLog .= "	   <qtregist>".$nrregist."</qtregist>";
	$xmlConsultaLog .= "   </Dados>";
	$xmlConsultaLog .= "</Root>";
		
	// Executa script para envio do XML	
	$xmlResult = mensageria($xmlConsultaLog, "INSS", "LOGINSS", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	
	$xmlObjConsultaLog = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjConsultaLog->roottag->tags[0]->name) == "ERRO") {
	
		$msgErro  = $xmlObjConsultaLog->roottag->tags[0]->tags[0]->tags[4]->cdata;
		$nmdcampo = $xmlObjConsultaLog->roottag->tags[0]->attributes["NMDCAMPO"];	
		
		if(empty ($nmdcampo)){ 
			$nmdcampo = "nrrecben";
		}
				 
		exibirErro('error',$msgErro,'Alerta - Aimaro','$(\'input\',\'#divBeneficio\').removeClass(\'campoErro\');unblockBackground(); $(\'#'.$nmdcampo.'\',\'#divBeneficio\').habilitaCampo(); focaCampoErro(\''.$nmdcampo.'\',\'divBeneficio\');',false);		
							
	}   
	
  $registros = $xmlObjConsultaLog->roottag->tags[0]->tags;
  $qtregist = $xmlObjConsultaLog->roottag->tags[1]->cdata;
  
  if ($qtregist > 0) {
    ?>
    <br/>
    <fieldset>      
      <legend> Alterações realizadas </legend>
      <div id="divLog" class="divRegistros" style="display:none">
        <table>
          <thead>
            <tr>
              <th>Conta/dv</th>
              <th>Beneficiário</th>
              <th>Data Alt</th>
              <th>NB</th>
              <th>Operador</th>
            </tr>
          </thead>
          <tbody>
            <? $total_registros = 0;
            foreach( $registros as $registro ) { 
              $total_registros += 1;?>
              
              <tr id="trLog<? echo $total_registros; ?>" style="cursor: pointer;" ondblClick="carregarDetalheLog()">
                <td align="center">
                  <? echo getByTagName($registro->tags,'nrdconta')?>              
                  <input type="hidden" id="hd_dtmvtolt" value="<? echo getByTagName($registro->tags,'dtmvtolt')?>" />
                  <input type="hidden" id="hd_hrmvtolt" value="<? echo getByTagName($registro->tags,'hrmvtolt')?>" />
                  <input type="hidden" id="hd_nrdconta" value="<? echo getByTagName($registro->tags,'nrdconta')?>" />
                  <input type="hidden" id="hd_nmdconta" value="<? echo getByTagName($registro->tags,'nmdconta')?>" />
                  <input type="hidden" id="hd_nrrecben" value="<? echo getByTagName($registro->tags,'nrrecben')?>" />
                  <input type="hidden" id="hd_historic" value="<? echo getByTagName($registro->tags,'historic')?>" />
                  <input type="hidden" id="hd_operador" value="<? echo getByTagName($registro->tags,'operador')?>" />
                </td>
                <td align="left"  ><? echo getByTagName($registro->tags,'nmdconta')?></td>
                <td align="center"><? echo getByTagName($registro->tags,'dtmvtolt')?></td>
                <td align="center"><? echo getByTagName($registro->tags,'nrrecben')?></td>
                <td align="center"><? echo getByTagName($registro->tags,'operador')?></td>
                
              </tr>
              
            <? 
            } ?>
          </tbody>
        </table>
      </div>
      
      <div id="divPesquisaRodape" class="divPesquisaRodape">
        <table>	
          <tr>
            <td>
              <?php
              if (isset($qtregist) and $qtregist == 0) {
                $nriniseq = 0;
              }
                // Se a paginacao nao esta na primeira, exibe botao voltar
              if ($nriniseq > 1) {
                ?> <a class='paginacaoAnt'><<< Anterior</a> <?php
              } else {
                ?> &nbsp; <?php
              }
              ?>
            </td>
            <td>
              <?php
              if (isset($nriniseq)) {
                ?> Exibindo <?php echo $nriniseq; ?> at&eacute; <?php
                if (($nriniseq + $nrregist) > $qtregist) {
                  echo $qtregist;
                } else {
                  echo ($nriniseq + $nrregist - 1);
                }
                ?> de <?php echo $qtregist; ?><?php
              }
              ?>
            </td>
            <td>
              <?php
              // Se a paginacao nao esta na ultima pagina, exibe botao proximo
              if ($qtregist > ($nriniseq + $nrregist - 1)) {
                ?> <a class='paginacaoProx'>Pr&oacute;ximo >>></a> <?php
              } else {
                ?> &nbsp; <?php
              }
              ?>			
            </td>
          </tr>
        </table>
      </div>
    </fieldset>
<?} else { echo "showError('error','Nenhum registro encontrado!','Alerta - Aimaro','$(\'#dtmvtolt\',\'#divConsultaLog\').focus();');";exit();}?>
<div id="divBotoesDetalhar" style="margin-top:5px; margin-bottom :10px; display:block; text-align: center;">
  <a href="#" class="botao" id="btVoltar" onClick="controlaVoltar('V10');return false;">Voltar</a>
  <?if ($qtregist > 0) {?><a href="#" class="botao" id="btDetalhar" onClick="carregarDetalheLog(0); return false;" >Detalhar</a><?}?>
</div>

<script type="text/javascript">
    
    $('input','#divConsultaLog').desabilitaCampo();
    
    $('a.paginacaoAnt').unbind('click').bind('click', function() {
        solicitaConsultaLog(<?php echo "'" . $cddopcao . "','" . $dtreglog . "','"  . $nrrecben . "','"  . $nrdconta . "','" . ($nriniseq - $nrregist) . "','" . $nrregist . "'"; ?>);
    });

    $('a.paginacaoProx').unbind('click').bind('click', function() {
        solicitaConsultaLog(<?php echo "'" . $cddopcao . "','" . $dtreglog . "','"  . $nrrecben . "','"  . $nrdconta . "','" . ($nriniseq + $nrregist) . "','" . $nrregist . "'"; ?>);
    });
</script>