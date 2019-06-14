<?
/*!
 * FONTE        	: form_uf.php
 * CRIAÇÃO      	: Jaison Fernando
 * DATA CRIAÇÃO 	: Novembro/2015
 * OBJETIVO     	: Form para a tela TAB097
 * ÚLTIMA ALTERAÇÃO : 08/10/2018
 * --------------
 * ALTERAÇÕ•ES   	: 
 * --------------
 * 
 *  08/10/2018 - Inclusao de parametro dsnegufds referente às UFs não autorizadas 
                 a protestar boletos com DS. (projeto "PRJ352 - Protesto" - 
                 Marcelo R. Kestring - Supero)
 *
 */ 
    session_start();

    // Includes para controle da session, variáveis globais de controle, e biblioteca de funções

    require_once('../../includes/config.php');
    require_once('../../includes/funcoes.php');
    require_once('../../includes/controla_secao.php');	
    require_once('../../class/xmlfile.php');

	$cddopcao   = (isset($_POST['cddopcao'])) ? $_POST['cddopcao'] : '' ;
	$dsvalor    = (isset($_POST['dsvalor']))  ? $_POST['dsvalor']  : '' ;
	$arrDados   = explode('|', $dsvalor);
	$indexcecao = $arrDados[0];
	$dsuf       = $arrDados[1];

    if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao,false)) <> '') {
		exibirErro('error',$msgError,'Alerta - Aimaro','',true);
	}

	// Montar o xml de Requisicao
	$xml  = "";
	$xml .= "<Root>";
	$xml .= " <Dados>";	
    $xml .= "   <indexcecao>".$indexcecao."</indexcecao>";
	$xml .= "   <dsuf>".$dsuf."</dsuf>";
	$xml .= " </Dados>";
	$xml .= "</Root>";

	// Requisicao dos dados de parametrizacao da excecao de negativacao Serasa
	$xmlResult = mensageria($xml, "TELA_TAB097", "BUSCA_PARAM_NEG_EXC", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObj = getObjectXML($xmlResult);

	if ( strtoupper($xmlObj->roottag->tags[0]->name) == 'ERRO' ) {
		exibirErro('error',$xmlObj->roottag->tags[0]->cdata,'Alerta - Aimaro','',false);
	}

	$param_ufnegdif = $xmlObj->roottag->tags[0]->tags[1]->tags[0];
	$qtminimo_negativacao = getByTagName($param_ufnegdif->tags,'qtminimo_negativacao');
?>

<script type="text/javascript">
	$('label','#frmUF').addClass('rotulo').css('width','200px');
	$('#dsuf','#frmUF').addClass('campo');
    $('#qtminimo_negativacao','#frmUF').addClass('campo').css('width', '80px').setMask('INTEGER', 'zz', '', '');
</script>

<table id="telaDetalhamento"cellpadding="0" cellspacing="0" border="0" width="100%">
	<tr>
		<td align="center">		
			<table border="0" cellpadding="0" cellspacing="0" width="550">
				<tr>
					<td>
						<table width="100%" border="0" cellspacing="0" cellpadding="0">
							<tr>
								<td width="11"><img src="<?php echo $UrlImagens; ?>background/tit_tela_esquerda.gif" width="11" height="21"></td>
								<td class="txtBrancoBold ponteiroDrag" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif">Informe a UF</td>
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
								<td align="center" style="border: 2px solid #969FA9; background-color: #F4F3F0; padding: 2px 2px 8px;">
									<div id="divConteudoOpcao">
                                        <form name="frmUF" id="frmUF" class="formulario" onsubmit="javascript:confirmaInclusao('UF'); return false;">
										<input name="cddopcao" id="cddopcao" type="hidden" value="<?php echo $cddopcao; ?>">
										<input name="indexcecao" id="indexcecao" type="hidden" value="<?php echo $indexcecao; ?>">
                                            <table width="100%">
                                            <tr>
                                                <td>
                                                    <label for="dsuf"><? echo utf8ToHtml('Unidade Federativa:') ?></label>
                                                    <?php echo selectEstado('dsuf',$dsuf); ?>
                                                </td>
                                            </tr>
											<?php
												// Se for excecao da negativacao Serasa
												if ($indexcecao == 2) {
													?>
													<tr>
														<td>
															<label for="qtminimo_negativacao"><? echo utf8ToHtml('Prazo:') ?></label>					
															<input name="qtminimo_negativacao" id="qtminimo_negativacao" value="<?php echo $qtminimo_negativacao; ?>" type="text" />
														</td>
													</tr>
													<?php
												}
											?>
                                            </table>
                                        </form>
                                        <div id="divBotoes">
                                            <a href="#" class="botao" id="btCNAEVoltar" onClick="fechaRotina($('#divRotina')); return false;">Voltar</a>
											
											<?php
												// Se for excecao da negativacao Serasa
												if ($indexcecao == 3) {
													?>
                                            		<a href="#" class="botao" id="btNegUFDSIncluir" onClick="confirmaInclusao('NEGUFDS');"><?php echo $cddopcao == 'A' ? 'Alterar' : 'Incluir' ?></a>
													<?php
												} else {
													?>
                                            <a href="#" class="botao" id="btCNAEIncluir" onClick="confirmaInclusao('UF');"><?php echo $cddopcao == 'A' ? 'Alterar' : 'Incluir' ?></a>
													<?php
												}
											?>
                                        </div>
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