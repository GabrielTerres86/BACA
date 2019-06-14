<?php
/*!
 * FONTE        : importar_arquivo.php                    Última alteração: 19/06/2017
 * CRIAÇÃO      : Jonata (RKAM)
 * DATA CRIAÇÃO : Maio/2017
 * OBJETIVO     : Rotina para importação de arquivo da tela MOVRGP
 * --------------
 * ALTERAÇÕES   : 19/06/2017 - Ajuste para deixar desabilitado o campo de incormações (Jonata - RKAM). 
 *
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

        exibirErro('error',$msgError,'Alerta - Ayllos','',false);
    }

	$cdcopsel = (isset($_POST["cdcopsel"])) ? $_POST["cdcopsel"] : 0;
	$dtrefere = (isset($_POST["dtrefere"])) ? $_POST["dtrefere"] : '';
	$cdproduto = (isset($_POST["cdproduto"])) ? $_POST["cdproduto"] : 0;
	$tpoperacao = (isset($_POST["tpoperacao"])) ? $_POST["tpoperacao"] : '';
	
    validaDados();
  
	$xmlImportar  = "";
	$xmlImportar .= "<Root>";
	$xmlImportar .= "   <Dados>";
	$xmlImportar .= "	   <cddopcao>".$cddopcao."</cddopcao>";
	$xmlImportar .= "	   <cdcopsel>".$cdcopsel."</cdcopsel>";
	$xmlImportar .= "	   <dtrefere>".$dtrefere."</dtrefere>";
	$xmlImportar .= "	   <idproduto>".$cdproduto."</idproduto>";
	$xmlImportar .= "	   <tpoperacao>".$tpoperacao."</tpoperacao>";
	$xmlImportar .= "   </Dados>";
	$xmlImportar .= "</Root>";
		
	// Executa script para envio do XML	
	$xmlResult = mensageria($xmlImportar, "TELA_MOVRGP", "IMPORTARRARQ", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	
	$xmlObjImportar = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjImportar->roottag->tags[0]->name) == "ERRO") {
	
		$msgErro  = $xmlObjImportar->roottag->tags[0]->tags[0]->tags[4]->cdata;
				 
		exibirErro('error',utf8_encode($msgErro),'Alerta - Ayllos','$(\'#cdproduto\',\'#frmFiltroProduto\').focus();',false);		
							
	}
	
	if ($tpoperacao == 'GI'){
		
		if (strtoupper($xmlObjImportar->roottag->tags[0]->name) == "MENSAGEM") {
	
			$msgAviso  = $xmlObjImportar->roottag->tags[0]->tags[0]->cdata;
			
			?>
				<table cellpadding="0" cellspacing="0" border="0" width="100%">
					<tr>
						<td align="center">		
							<table border="0" cellpadding="0" cellspacing="0" width="250px">
								<tr>
									<td>
										<table width="100%" border="0" cellspacing="0" cellpadding="0">
											<tr>
												<td width="11"><img src="<?php echo $UrlImagens; ?>background/tit_tela_esquerda.gif" width="11" height="21"></td>
												<td class="txtBrancoBold"  background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif">INFORMAÇÕES DO MOVIMENTO</td>
												<td width="12" id="tdTitTela" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif"><a href="#" onClick="fechaRotina($('#divRotina')); return false;"><img src="<?php echo $UrlImagens; ?>geral/excluir.jpg" width="12" height="12" border="0"></a></td>
												<td width="8"><img src="<?php echo $UrlImagens; ?>background/tit_tela_direita.gif" width="8" height="21"></td>
											</tr>
										</table>     
									</td> 
								</tr> 																						
								<tr>
									<td class="tdConteudoTela" align="center">
										<table width="100%" border="0" cellspacing="0" cellpadding="0">
											<tr>
												<td align="center" style="border: 2px solid #969FA9; background-color: #F4F3F0; padding: 2px;">
													<table width="100%" height="100%" border="0" cellpadding="0" cellspacing="0">
														<tr>
															<td style="padding-left:30px;" align="left" valign="left">
																<div id="divMensagem">
																</div>
															</td>
														</tr>
														<tr>
															<td align="center" valign="center">
																
																<textarea name="dsinform" id="dsinform" ><? echo str_replace('<br>', "\n", $msgAviso);?></textarea>
																																																				
															</td>
														</tr>
														
													</table>																												
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
					
					$('#dsinform','#divRotina').addClass('textarea');
					$('#dsinform','#divRotina').css({ 'width': '650px','height': '200px','margin': '3px 0px 3px 3px'  });
					$('#dsinform','#divRotina').desabilitaCampo();
					$('#divRotina').centralizaRotinaH();
					exibeRotina($('#divRotina'));
				    hideMsgAguardo();
				    bloqueiaFundo($('#divRotina'));
					
				</script>
			<?
		}				
	}else{
		
		$tpOperac    = $xmlObjImportar->roottag->tags[0]->tags[0]->cdata;
		$qtdRegistro = $xmlObjImportar->roottag->tags[0]->tags[1]->cdata;
		
		if ($qtdRegistro > 0){?>
		
			<script type="text/javascript">
					
				showConfirmacao('J&aacute; existem contratos importados para este Produto na data base e Cooperativa – As informa&ccedil;&atilde;es ser&atilde;o substituidas!','Confirma&ccedil;&atilde;o - Ayllos','showConfirmacao("Voc&ecirc; tem certeza que deseja importar os arquivos do Produto selecionado?","Confirma&ccedil;&atilde;o - Ayllos","importarArquivo(\'<?echo $tpOperac;?>\');","$(\'#cdproduto\',\'#frmFiltroProduto\').focus();","sim.gif","nao.gif");',"$(\'#cdproduto\',\'#frmFiltroProduto\').focus();","sim.gif","nao.gif");

			</script>
			
		<?}else{?>
		
			<script type="text/javascript">
					
				showConfirmacao('Deseja confirmar opera&ccedil;&atilde;o?','Confirma&ccedil;&atilde;o - Ayllos','importarArquivo(\'<?echo $tpOperac;?>\');','$(\'#cdproduto\',\'#frmFiltroProduto\').focus();','sim.gif','nao.gif');
		
			</script>
		
		<?}
		
	}
		
    function validaDados(){
		
		//Código da cooperativa
        if (  $GLOBALS["cdcopsel"] == 0 ){
            exibirErro('error','C&oacute;digo da cooperativa inv&aacute;lida.','Alerta - Ayllos','$(\'#cdproduto\',\'#frmFiltroProduto\').focus();',false);
        }
		
		//Data de referência
        if (  $GLOBALS["dtrefere"] == '' ){
            exibirErro('error','Data de refer&ecirc;ncia inv&aacute;lida.','Alerta - Ayllos','$(\'#cdproduto\',\'#frmFiltroProduto\').focus();',false);
        }
		
		//Código do produto
        if (  $GLOBALS["cdproduto"] == 0 ){
            exibirErro('error','C&oacute;digo do produto inv&aacute;lido.','Alerta - Ayllos','focaCampoErro(\'cdproduto\',\'frmFiltroProduto\');',false);
        }
		
		//Tipo da operação
        if (  $GLOBALS["tpoperacao"] == '' ){
            exibirErro('error','Tipo da opera&ccedil;&atilde;o inv&aacute;lida.','Alerta - Ayllos','$(\'#cdproduto\',\'#frmFiltroProduto\').focus();',false);
        }
		
	}

 ?>
