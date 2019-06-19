<?php
    /*
     * FONTE        : form_regras.php
     * CRIAÇÃO      : Jaison
     * DATA CRIAÇÃO : 07/01/2016
     * OBJETIVO     : Formulario de Regras.
     * --------------
     * ALTERAÇÕES   : 11/07/2016 - Adicionados novos campos para a fase 3 do projeto de Pre aprovado. (Lombardi)
     *
     *                27/04/2018 - Alteração  da situação de "1,2,3,4,5,6,8,9" para "1,2,3,4,5,7,8,9". 
     *                             Projeto 366. (Lombardi)
     *
     *                06/02/2019 - Petter - Envolti. Ajustar novos campos e refatorar funcionalidades para o projeto 442.
     * --------------
     */

    session_start();
    require_once('../../includes/config.php');
    require_once('../../includes/funcoes.php');
    require_once('../../includes/controla_secao.php');	
    require_once('../../class/xmlfile.php');

	$cddopcao   = (isset($_POST['cddopcao'])) ? $_POST['cddopcao'] : '' ;
    $inpessoa   = (isset($_POST['inpessoa'])) ? $_POST['inpessoa'] : '' ;

    if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao,false)) <> '') {
		exibirErro('error',$msgError,'Alerta - Ayllos','',true);
	}
    
    // Monta o xml de requisicao
	$xml  = "";
	$xml .= "<Root>";
	$xml .= " <Dados />";
	$xml .= "</Root>";

    // Executa script para envio do XML e cria objeto para classe de tratamento de XML
	$xmlResult = mensageria($xml, "CADPRE", "BUSCA_ALINEA", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObjeto = getObjectXML($xmlResult);
    
    $alinea = $xmlObjeto->roottag->tags[0]->tags;
    $qtregist = $xmlObjeto->roottag->tags[0]->attributes["QTREGIST"];
    $qtmaxcol = Round($qtregist / 3);
?>

<table cellpadding="0" cellspacing="0" border="0" width="100%">
	<tr>
		<td align="center">		
			<table cellpadding="0" cellspacing="0" border="0" width="750">
				<tr>
					<td>
						<table width="100%" border="0" cellspacing="0" cellpadding="0">
							<tr>
								<td width="11"><img src="<?php echo $UrlImagens; ?>background/tit_tela_esquerda.gif" width="11" height="21"></td>
								<td class="txtBrancoBold ponteiroDrag" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif">Regras do Crédito Pré-aprovado para Pessoa <?php echo ($inpessoa == 1 ? 'Física' : 'Jurídica'); ?></td>
								<td width="12" id="tdTitTela" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif"><a id="btSair" href="#" onClick="fechaRotina($('#divRotina')); return false;"><img src="<?php echo $UrlImagens; ?>geral/excluir.jpg" width="12" height="12" border="0"></a></td>
								<td width="8"><img src="<?php echo $UrlImagens; ?>background/tit_tela_direita.gif" width="8" height="21"></td>
							</tr>        
						</table>
					</td>        
				</tr>        
				<tr>
					<td class="tdConteudoTela" align="center">
						<table width="100%"  border="0" cellspacing="0" cellpadding="0">
							<tr>
								<td>
									<table border="0" cellspacing="0" cellpadding="0">
										<tr>
           									<td><img src="<?php echo $UrlImagens; ?>background/mnu_nle.gif" width="4" height="21" id="imgAbaEsq0"></td>
											<td align="center" style="background-color: #C6C8CA;" id="imgAbaCen0"><a href="#" id="linkAba0" class="txtNormalBold" onClick="acessaOpcaoAba(0);return false;">Geral</a></td>
											<td><img src="<?php echo $UrlImagens; ?>background/mnu_nld.gif" width="4" height="21" id="imgAbaDir0"></td>
											<td width="1"></td>

                                            <td><img src="<?php echo $UrlImagens; ?>background/mnu_nle.gif" width="4" height="21" id="imgAbaEsq2"></td>
											<td align="center" style="background-color: #C6C8CA;" id="imgAbaCen2"><a href="#" id="linkAba2" class="txtNormalBold" onClick="acessaOpcaoAba(2);return false;">Devolução de Cheque</a></td>
											<td><img src="<?php echo $UrlImagens; ?>background/mnu_nld.gif" width="4" height="21" id="imgAbaDir2"></td>
											<td width="1"></td>

                                            <td><img src="<?php echo $UrlImagens; ?>background/mnu_nle.gif" width="4" height="21" id="imgAbaEsq3"></td>
											<td align="center" style="background-color: #C6C8CA;" id="imgAbaCen3"><a href="#" id="linkAba3" class="txtNormalBold" onClick="acessaOpcaoAba(3);return false;">Atraso</a></td>
											<td><img src="<?php echo $UrlImagens; ?>background/mnu_nld.gif" width="4" height="21" id="imgAbaDir3"></td>
											<td width="1"></td>
                                        </tr>
									</table>
								</td>
							</tr>
							<tr>
								<td align="center" style="border: 2px solid #969FA9; background-color: #F4F3F0; padding: 2px;">
									<form id="frmRegra" name="frmRegra" class="formulario">

                                        <div id="divAba0" class="clsAbas">
                                            <table width="100%">
                                                <tr>		
                                                    <td>
                                                        <label for="cdfinemp">C&oacute;digo da Finalidade:</label>	
                                                        <input name="cdfinemp" type="text"  id="cdfinemp" />
                                                        <a><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"></a>
                                                        <input name="dsfinemp" id="dsfinemp" type="text" />
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td>
                                                        <label for="vllimmin">Limite M&iacute;nimo Ofertado:</label>	
                                                        <input name="vllimmin" type="text"  id="vllimmin"/> <label>&nbsp;(R$)</label>
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td>
                                                        <label for="vllimctr">Limite M&iacute;nimo Contrata&ccedil;&atilde;o:</label>	
                                                        <input name="vllimctr" type="text"  id="vllimctr"/> <label>&nbsp;(R$)</label>
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td>
                                                        <label for="vlmulpli">Valores M&uacute;ltiplos de:</label>	
                                                        <input name="vlmulpli" type="text"  id="vlmulpli"/> <label>&nbsp;(R$)</label>
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td>
                                                        <label for="vllimman">Limite M&aacute;ximo para Cargas Manuais:</label>	
                                                        <input name="vllimman" type="text"  id="vllimman"/> <label>&nbsp;(R$)</label>
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td>
                                                        <label for="vllimaut">Limite M&aacute;ximo para Cargas Autom&aacute;ticas:</label>	
                                                        <input name="vllimaut" type="text"  id="vllimaut"/> <label>&nbsp;(R$)</label>
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td>
                                                        <label for="qtdiavig">Qtde Dias Máximo de Vigência:</label>
                                                        <input name="qtdiavig" type="text" id="qtdiavig" />
                                                    </td>
                                                </tr>
                                            </table>
                                        </div>

                                        <div id="divAba2" class="clsAbas">
                                            <?php
                                                $dscolun1 = '';
                                                $dscolun2 = '';
												$dscolun3 = '';
                                                $qtcoluna = 1;
                                                foreach ($alinea as $r) {
                                                    $cdalinea = getByTagName($r->tags,'cdalinea');
                                                    $dsalinea = getByTagName($r->tags,'dsalinea');
                                                    $dscoluna = '<input type="checkbox" name="dslstali" id="ali' . $cdalinea . '" value="' . $cdalinea . '" class="clsAlinea" style="margin-right: 5px;" />';
                                                    $dscoluna = $dscoluna . '<label for="ali' . $cdalinea . '">' . $cdalinea.' - '.$dsalinea . '</label><br /><br />';
													switch($qtcoluna){
														case 1:
															$dscolun1 .= $dscoluna;
														break;
														case 2:
															$dscolun2 .= $dscoluna;
														break;
														case 3:
															$dscolun3 .= $dscoluna;
															$qtcoluna = 0;
														break;
													}
                                                    $qtcoluna++;
                                                }
                                            ?>
											<fieldset>
												<legend align="left">Alíneas de Devolução de Cheque</legend>
												<table width="100%">
													<tr>													
														<td valign="top"><?php echo $dscolun1; ?></td>
														<td valign="top"><?php echo $dscolun2; ?></td>
														<td valign="top"><?php echo $dscolun3; ?></td>													
													</tr>
												</table>
											</fieldset>
											<table width="100%">
                                                <tr>
                                                    <td>
                                                        <label for="qtdiadev">Qtd. dias em atraso:</label>	
                                                        <input name="qtdiadev" type="text"  id="qtdiadev" /> <label>&nbsp;dias &uacute;teis</label>
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td>
                                                        <label for="vldiadev">Valor em atraso:</label>
                                                        <input name="vldiadev" type="text" id="vldiadev"/>
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td>
                                                        <label for="qtdevolu">Qtd. Opera&ccedil;&otilde;es em Atraso:</label>	
                                                        <input name="qtdevolu" type="text" id="qtdevolu" />
                                                    </td>
                                                </tr>
                                            </table>
                                        </div>

                                        <div id="divAba3" class="clsAbas">
                                            <fieldset>
                                                <legend align="left">Atraso</legend>
                                                <table width="100%">
                                                    <tr>
                                                        <td>
                                                            <label for="qtctaatr">Conta Corrente em Atraso:</label>	
                                                            <input name="qtctaatr" type="text"  id="qtctaatr" /> <label>&nbsp;dias &uacute;teis &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</label>
                                                            <label for="vlctaatr">Valor Corrente em Atraso:</label>	
                                                            <input name="vlctaatr" type="text"  id="vlctaatr" />
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td>
                                                            <label for="qtepratr">Empr&eacute;stimo em Atraso:</label>	
                                                            <input name="qtepratr" type="text"  id="qtepratr" /> <label>&nbsp;dias corridos</label>
                                                            <label for="vlepratr">Valor Empr&eacute;stimo em Atraso:</label>
                                                            <input name="vlepratr" type="text"  id="vlepratr" />
                                                        </td>
                                                    </tr>
                                                </table>
                                            </fieldset>
                                            <fieldset>
                                                <legend align="left">Estouro de Conta</legend>
                                                <table width="100%">
                                                    <tr>
                                                        <td>
                                                            <label for="qtestour">Quantidade de Estouro:</label>	
                                                            <input name="qtestour" type="text"  id="qtestour" /></label>
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td>
                                                            <label for="qtdiaest">Per&iacute;odo de Estouro:</label>	
                                                            <input name="qtdiaest" type="text"  id="qtdiaest" /> <label>&nbsp;dias &uacute;teis&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</label>
                                                            <label for="vldiaest">Valor em Estouro:</label>
                                                            <input name="vldiaest" type="text"  id="vldiaest" />
                                                        </td>
                                                    </tr>
                                                </table>
                                            </fieldset>
                                            <fieldset>
                                                <legend align="left">Opera&ccedil;&otilde;es como avalista</legend>
                                                <table width="100%">
                                                    <tr>
                                                        <td>
                                                            <label for="qtavlope">Qtd. Opera&ccedil;&otilde;es em Atraso:</label>	
                                                            <input name="qtavlope" type="text"  id="qtavlope" />
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td>
                                                            <label for="qtavlatr">Qtd. dias em Atraso:</label>	
                                                            <input name="qtavlatr" type="text"  id="qtavlatr" /><label>&nbsp;dias corridos</label>
                                                            <label for="vlavlatr">Valor em Atraso:</label>	
                                                            <input name="vlavlatr" type="text"  id="vlavlatr" />
                                                        </td>
                                                    </tr>
                                                </table>
                                            </fieldset>
                                            <fieldset>
                                                <legend align="left">Opera&ccedil;&otilde;es de C&ocirc;njuge</legend>
                                                <table width="100%">
                                                    <tr>
                                                        <td>
                                                            <label for="qtcjgope">Qtd. Opera&ccedil;&otilde;es em Atraso:</label>	
                                                            <input name="qtcjgope" type="text"  id="qtcjgope" />
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td>
                                                            <label for="qtcjgatr">Qtd. dias em Atraso:</label>	
                                                            <input name="qtcjgatr" type="text"  id="qtcjgatr" /><label>&nbsp;dias corridos</label>
                                                            <label for="vlcjgatr">Valor em Atraso:</label>	
                                                            <input name="vlcjgatr" type="text"  id="vlcjgatr" />
                                                        </td>
                                                    </tr>
                                                </table>
                                            </fieldset>
                                            <fieldset>
                                                <legend align="left">Cartão de Crédito</legend>
                                                <table width="100%">
                                                    <tr>
                                                        <td>
                                                            <label for="qtcarcre">Dias em Atraso do Cartão:</label>
                                                            <input name="qtcarcre" type="text" id="qtcarcre" /> <label>&nbsp;dias corridos</label>
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td>
                                                            <label for="vlcarcre">Valor em Atraso do Cartão:</label>
                                                            <input name="vlcarcre" type="text" id="vlcarcre" />
                                                        </td>
                                                    </tr>
                                                </table>
                                            </fieldset>
                                            <fieldset>
                                                <legend align="left">Desconto de Títulos</legend>
                                                <table width="100%">
                                                    <tr>
                                                        <td>
                                                            <label for="qtdtitul">Dias em Atraso dos Títulos:</label>
                                                            <input name="qtdtitul" type="text" id="qtdtitul" /> <label>&nbsp;dias corridos</label>
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td>
                                                            <label for="vltitulo">Valor em Atraso dos Títulos:</label>
                                                            <input name="vltitulo" type="text" id="vltitulo" />
                                                        </td>
                                                    </tr>
                                                </table>
                                            </fieldset>
                                        </div>
                                    </form>
								</td>
							</tr>
						</table>
                        <br />
                        <a href="#" class="botao" id="btVoltar" onClick="fechaRotina($('#divRotina')); btnVoltar(); return false;">Voltar</a>
                        <a href="#" class="botao" id="btConcluir" onClick="confirmaAlteracao();">Concluir</a>
					</td>        
				</tr>   
			</table>				
		</td>
	</tr>
</table>
