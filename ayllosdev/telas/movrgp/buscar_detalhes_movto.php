<?php
/*!
 * FONTE        : buscar_detalhes_movto.php                    Última alteração:
 * CRIAÇÃO      : Jonata (RKAM)
 * DATA CRIAÇÃO : Maio/2017
 * OBJETIVO     : Rotina responsável por buscar os detalhes do movimento da tela MOVRGP
 * --------------
 * ALTERAÇÕES   :  
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

	$cdcopsel      = (isset($_POST["cdcopsel"])) ? $_POST["cdcopsel"] : 0;
	$idmovto_risco = (isset($_POST["idmovto_risco"])) ? $_POST["idmovto_risco"] : '';
	$idproduto     = (isset($_POST["idproduto"])) ? $_POST["idproduto"] : '';
	
    validaDados();
  
	$xmlBuscaDetalhes  = "";
	$xmlBuscaDetalhes .= "<Root>";
	$xmlBuscaDetalhes .= "   <Dados>";
	$xmlBuscaDetalhes .= "	   <cddopcao>".$cddopcao."</cddopcao>";
	$xmlBuscaDetalhes .= "	   <idmovto_risco>".$idmovto_risco."</idmovto_risco>";
	$xmlBuscaDetalhes .= "	   <idproduto>".$idproduto."</idproduto>";
	$xmlBuscaDetalhes .= "   </Dados>";
	$xmlBuscaDetalhes .= "</Root>";
		
	// Executa script para envio do XML	
	$xmlResult = mensageria($xmlBuscaDetalhes, "TELA_MOVRGP", "DETALHESMVTO", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	
	$xmlObjBuscaDetalhes = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjBuscaDetalhes->roottag->tags[0]->name) == "ERRO") {
	
		$msgErro  = $xmlObjBuscaDetalhes->roottag->tags[0]->tags[0]->tags[4]->cdata;
			 
		exibirErro('error',utf8_encode($msgErro),'Alerta - Ayllos','$(\'#btVoltar\',\'#divBotoesProdutos\').focus();',false);		
							
	}
	
	$registros = $xmlObjBuscaDetalhes->roottag->tags;
	$flpermite_fluxo_financeiro = $xmlObjBuscaDetalhes->roottag->tags[0]->attributes["FLPERMITE_FLUXO_FINANCEIRO"];
	$flpermite_saida_operacao   = $xmlObjBuscaDetalhes->roottag->tags[0]->attributes["FLPERMITE_SAIDA_OPERACAO"];
	$cdclassificacao_produto    = $xmlObjBuscaDetalhes->roottag->tags[0]->attributes["CDCLASSIFICACAO_PRODUTO"];
			
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
										<td class="txtBrancoBold"  background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif">RESUMO DA IMPORTAÇÃO</td>
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
										<td align="left" style="border: 2px solid #969FA9; background-color: #F4F3F0; padding: 2px;">
											<div id="divConteudo">
												<?foreach( $registros as $registro ) { ?>
											
													<?php include('form_detalhes.php'); ?>
												
												<?}?>
											<div>																																						
										</td>
									</tr>
								</table>
							</td>
						</tr>
					</table>
				</td>
			</tr>
			
		</table>																			
		
		
	<?
		
    function validaDados(){
		
		//Código do movimento
        if ( $GLOBALS["cddopcao"] != 'I' && $GLOBALS["idmovto_risco"] == 0 ){
            exibirErro('error','C&oacute;digo do movimento inv&aacute;lido.','Alerta - Ayllos','$(\'#btVoltar\',\'#divBotoesProdutos\').focus();',false);
        }
		
		//Código do produto
        if (  $GLOBALS["idproduto"] == 0 ){
            exibirErro('error','C&oacute;digo do produto inv&aacute;lido.','Alerta - Ayllos','$(\'#btVoltar\',\'#divBotoesProdutos\').focus();',false);
        }
		
		
	}

 ?>
