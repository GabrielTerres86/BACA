<?php
/*!
 * FONTE        : busca_gravames.php                    Última alteração: 14/07/2016
 * CRIAÇÃO      : Andrei (RKAM)
 * DATA CRIAÇÃO : Maio/2016 
 * OBJETIVO     : Rotina para buscar os gravames do contrato informado
 * --------------
 * ALTERAÇÕES   :  14/07/2016 - Ajustes para que este fonte considere apenas a busca de gravames 
                               (Andrei - RKAM).
 */
?> 

<?php	
 
  session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();		
	
	// Carrega permissões do operador
	require_once('../../includes/carrega_permissoes.php');		
	
	$cddopcao = (isset($_POST["cddopcao"])) ? $_POST["cddopcao"] : '';
	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {		
	
		exibirErro('error',$msgError,'Alerta - Aimaro','',false);
	}

  $nrdconta = (isset($_POST["nrdconta"])) ? $_POST["nrdconta"] : 0;
  $nrctrpro = (isset($_POST["nrctrpro"])) ? $_POST["nrctrpro"] : 0;
  $nrregist = (isset($_POST["nrregist"])) ? $_POST["nrregist"] : 30;
  $nriniseq = (isset($_POST["nriniseq"])) ? $_POST["nriniseq"] : 1;
  
  // Monta o xml de requisição		
	$xml  		= "";
	$xml 	   .= "<Root>";
	$xml 	   .= "  <Dados>";
	$xml 	   .= "     <nrdconta>".$nrdconta."</nrdconta>";
  $xml 	   .= "     <nrctrpro>".$nrctrpro."</nrctrpro>";
	$xml 	   .= "     <nrregist>".$nrregist."</nrregist>";	
  $xml 	   .= "     <nriniseq>".$nriniseq."</nriniseq>";
	$xml 	   .= "  </Dados>";
	$xml 	   .= "</Root>";
	
	// Executa script para envio do XML	
	$xmlResult = mensageria($xml, "TELA_GRAVAM", "BUSCAGRAVAMES", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObj = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObj->roottag->tags[0]->name) == "ERRO") {
	
		$msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
		exibirErro('error',$msgErro,'Alerta - Aimaro','$(\'#btVoltar\',\'#divBotoes\').focus();',false);		
					
	} 
		
	$contratos = $xmlObj->roottag->tags[0]->tags;
  $qtregist  = $xmlObj->roottag->attributes["QTREGIST"];	
	  
    
 ?>

<table cellpadding="0" cellspacing="0" border="0" width="100%">
	<tr>
		<td align="center">		
			<table border="0" cellpadding="0" cellspacing="0" width="100%">
				<tr>
					<td>
						<table width="100%" border="0" cellspacing="0" cellpadding="0">
							<tr>
								<td width="11"><img src="<?php echo $UrlImagens; ?>background/tit_tela_esquerda.gif" width="11" height="21"></td>
								<td class="txtBrancoBold ponteiroDrag" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif">Gravames</td>
								<td width="12" id="tdTitTela" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif"><a href="#" onClick="controlaVoltar('4','<?echo $tpconsul;?>');return false;"><img src="<?php echo $UrlImagens; ?>geral/excluir.jpg" width="12" height="12" border="0"></a></td>
								<td width="8"><img src="<?php echo $UrlImagens; ?>background/tit_tela_direita.gif" width="8" height="21"></td>
							</tr>
						</table>     
					</td> 
				</tr>    
				<tr>
					<td class="tdConteudoTela" align="center">	
						<table width="100%" border="0" cellspacing="0" cellpadding="0">
							<tr>
								<td>
									<table border="0" cellspacing="0" cellpadding="0">
										<tr>
											<td><img src="<?php echo $UrlImagens; ?>background/mnu_nle.gif" width="4" height="21" id="imgAbaEsq0"></td>
											<td align="center" style="background-color: #C6C8CA;" id="imgAbaCen0"><a href="#" id="linkAba0" class="txtNormalBold">Principal</a></td>
											<td><img src="<?php echo $UrlImagens; ?>background/mnu_nld.gif" width="4" height="21" id="imgAbaDir0"></td>
											<td width="1"></td>
										</tr>
									</table>
								</td>
							</tr>
							<tr>
								<td align="center" style="border: 2px solid #969FA9; background-color: #F4F3F0; padding: 2px;">
									<div id="divConteudoOpcao">


										<div id="divRegistros" class="divRegistros">
										  <table>
											<thead>
											  <tr>
												<th>Gravames</th>
											  </tr>
											</thead>
											<tbody>
												<?
												for($i=0; $i<count($contratos); $i++){		    
											
													// Recebo todos valores em variáveis
                          $nrgravam = getByTagName($contratos[$i]->tags,'nrgravam');
                
                          ?>
                            <tr>
                              <td>
                                <span>
                                  <? echo $nrgravam ?>
                                </span>
                                <? echo $nrgravam; ?>
															
														    
                              </td>
                              <input type="hidden" id="nrgravam" value="<?echo $nrgravam;?>"/>

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
													<?					
													//
													if (isset($qtregist) and $qtregist == 0) $nriniseq = 0;
													
													// Se a paginação não está na primeira, exibe botão voltar
													if ($nriniseq > 1) { 
														?> <a class='paginacaoAnt'><<< Anterior</a> <? 
													} else {
														?> &nbsp; <?
													}
													?>
												</td>
												<td>
													<?
														if (isset($nriniseq)) { 
															?> Exibindo <? echo $nriniseq; ?> at&eacute; <? if (($nriniseq + $nrregist) > $qtregist) { echo $qtregist; } else { echo ($nriniseq + $nrregist - 1); } ?> de <? echo $qtregist; ?><?
														}
													?>
												</td>
												<td>
													<?
														// Se a paginação não está na &uacute;ltima página, exibe botão proximo
														if ($qtregist > ($nriniseq + $nrregist - 1)) {
															?> <a class='paginacaoProx'>Pr&oacute;ximo >>></a> <?
														} else {
															?> &nbsp; <?
														}
													?>			
												</td>
											</tr>
										  </table>
										</div>
									
									</div>

                  <div id="divBotoesContratos" style="margin-top:5px; margin-bottom :10px; display:none; text-align: center;">

                    <a href="#" class="botao" id="btVoltar" onClick="controlaVoltar('4','<?echo $tpconsul;?>');">Voltar</a>

                  </div>
                  
								</td>
							</tr>
						</table>
					</td>
				</tr>
		    </table>
		</td>
	</tr>
</table>


<script type="text/javascript">

  // centraliza a divRotina
  $('#divRotina').css({'width':'350px'});
  $('#divConteudo', '#divRotina').css({'width':'380px'});
   
  exibeRotina($('#divRotina'));

  $('a.paginacaoAnt').unbind('click').bind('click', function() {
      buscaContratos(<? echo "'".($nriniseq - $nrregist)."','".$nrregist."'"; ?>);					      
	});
  
	$('a.paginacaoProx').unbind('click').bind('click', function() {
			buscaContratos(<? echo "'".($nriniseq + $nrregist)."','".$nrregist."'"; ?>);
	});	
		
	$('#divPesquisaRodape').formataRodapePesquisa();
  $('#divTabelaRelatorios').css('display','block');
  $('#divBotoesContratos').css('display','block');
  formataTabelaContratosGravames('G');
  blockBackground(parseInt($('#divRotina').css('z-index')));

</script>