<?php
    /*
     * FONTE        : form_regras.php
     * CRIA��O      : Jaison
     * DATA CRIA��O : 07/01/2016
     * OBJETIVO     : Formulario de Regras.
     * --------------
     * ALTERA��ES   : 11/07/2016 - Adicionados novos campos para a fase 3 do projeto de Pre aprovado. (Lombardi)
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
								<td class="txtBrancoBold ponteiroDrag" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif">Regras do Cr�dito Pr�-aprovado para Pessoa <?php echo ($inpessoa == 1 ? 'F�sica' : 'Jur�dica'); ?></td>
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

                                            <td><img src="<?php echo $UrlImagens; ?>background/mnu_nle.gif" width="4" height="21" id="imgAbaEsq1"></td>
											<td align="center" style="background-color: #C6C8CA;" id="imgAbaCen1"><a href="#" id="linkAba1" class="txtNormalBold" onClick="acessaOpcaoAba(1);return false;">Risco</a></td>
											<td><img src="<?php echo $UrlImagens; ?>background/mnu_nld.gif" width="4" height="21" id="imgAbaDir1"></td>
											<td width="1"></td>

                                            <td><img src="<?php echo $UrlImagens; ?>background/mnu_nle.gif" width="4" height="21" id="imgAbaEsq2"></td>
											<td align="center" style="background-color: #C6C8CA;" id="imgAbaCen2"><a href="#" id="linkAba2" class="txtNormalBold" onClick="acessaOpcaoAba(2);return false;">Devolu��o de Cheque</a></td>
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
                                                        <label for="nrmcotas">Multiplicar Cotas Capital:</label>	
                                                        <input name="nrmcotas" type="text"  id="nrmcotas" /> <label>&nbsp;vezes</label>
                                                    </td>
                                                </tr>
                                                <tr>		
                                                    <td>
                                                        <label for="dssitdop">Situa&ccedil;&atilde;o das Contas:</label>
                                                        <?php
                                                            $arrsitua = array('1','2','3','4','5','6','8','9');
                                                            foreach ($arrsitua as $codsitua => $flgsitua) {
                                                                echo '<label for="sit' . $codsitua . '">' . $flgsitua . '</label>';
                                                                echo '<input type="checkbox" name="dssitdop" id="sit' . $codsitua . '" value="' . $flgsitua . '"/>';
                                                            }
                                                        ?>
                                                    </td>
                                                </tr>
                                                <tr>		
                                                    <td>
                                                        <label for="qtmescta">Tempo de Conta:</label>	
                                                        <input name="qtmescta" type="text"  id="qtmescta" /> <label>&nbsp;meses</label>
                                                    </td>
                                                </tr>
                                                <?php
                                                    if ($inpessoa == 1) { 
                                                        ?>
                                                        <tr>		
                                                            <td>
                                                                <label for="qtmesadm">Tempo Admiss�o Emprego Atual:</label>	
                                                                <input name="qtmesadm" type="text"  id="qtmesadm" /> <label>&nbsp;meses</label>
                                                            </td>
                                                        </tr>
                                                        <?php
                                                    } else {
                                                        ?>
                                                        <tr>		
                                                            <td>
                                                                <label for="qtmesemp">Tempo Funda��o Empresa:</label>	
                                                                <input name="qtmesemp" type="text"  id="qtmesemp" /> <label>&nbsp;meses</label>
                                                            </td>
                                                        </tr>
                                                        <?php
                                                    }
                                                ?>
                                                <tr>
                                                    <td>
                                                        <label for="nrrevcad">Revis&atilde;o Cadastral:</label>	
                                                        <input name="nrrevcad" type="text"  id="nrrevcad" /> <label>&nbsp;meses</label>
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
                                                        <label for="vlpercom">Comprometimento de Renda:</label>	
                                                        <input name="vlpercom" type="text"  id="vlpercom"/> <label>&nbsp;(%)</label>
                                                        <label for="qtdiaver">Verificar opera��es inclusas h�:</label>	
                                                        <input name="qtdiaver" type="text"  id="qtdiaver"/> <label>&nbsp;dias</label>
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td>
                                                        <label for="vlmaxleg">Multiplicar Valor M&aacute;x. Legal:</label>	
                                                        <input name="vlmaxleg" type="text"  id="vlmaxleg"/> <label>&nbsp;(%)</label>
                                                        <label for="qtmesblq">Per�odo de Bloqueio de Limite por Refinanciamento:</label>	
                                                        <input name="qtmesblq" type="text"  id="qtmesblq"/> <label>&nbsp;meses</label>
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td>
                                                        <div id="divLimiteCoop"></div>
                                                    </td>
                                                </tr>
                                            </table>
                                        </div>

                                        <div id="divAba1" class="clsAbas">
											<div style="margin-top: 10px;" ></div>
                                            <div id="divRiscos">
												<div class="divRegistros">
													<table>
														<thead>
															<tr>
																<th>Risco</th>
																<th>Valor Limite (R$)</th>
																<th>Linha de Cr&eacute;dito</th>
																<th>Taxa (%)</th>
															</tr>
														</thead>
														<tbody>
														<?
															$letra = array('A','B','C','D','E','F','G','H');
															
															for ($i = 0; $i < 8; $i++) {?>
																<tr style="cursor: pointer;">
																	<td><b><p class="dsrisco" id="dsrisco_<?echo $letra[$i]?>"></p></b></td>
																	<td><input class="vllimite" name="vllimite_<?echo $letra[$i]?>" type="text"  id="vllimite_<?echo $letra[$i]?>" /></td>
																	<td>
																		<input class="cdlcremp" type="text" name="cdlcremp_<?echo $letra[$i]?>" id="cdlcremp_<?echo $letra[$i]?>" />
																		<a><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"></a>
																		<input class="dslcremp" name="dslcremp_<?echo $letra[$i]?>" id="dslcremp_<?echo $letra[$i]?>" type="text" />
																		<input type="hidden" name="txmensal_<?echo $letra[$i]?>" type="text" />
																	</td>
																	<td><b><p class="txmensal" id="txmensal_<?echo $letra[$i]?>"></p></b></td>
																</tr>
															<?}?>
														</tbody>
													</table>
												</div>
												<div style="margin-top: 10px;" ></div>
											</div>
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
												<legend align="left">Al�neas de Devolu��o de Cheque</legend>
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
                                                        <label for="qtdevolu">Quantidade de devolu&ccedil;&otilde;es:</label>	
                                                        <input name="qtdevolu" type="text"  id="qtdevolu" />
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td>
                                                        <label for="qtdiadev">Per&iacute;odo de devolu&ccedil;&otilde;es:</label>	
                                                        <input name="qtdiadev" type="text"  id="qtdiadev" /> <label>&nbsp;dias &uacute;teis</label>
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
                                                            <input name="qtctaatr" type="text"  id="qtctaatr" /> <label>&nbsp;dias &uacute;teis</label>
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td>
                                                            <label for="qtepratr">Empr&eacute;stimo em Atraso:</label>	
                                                            <input name="qtepratr" type="text"  id="qtepratr" /> <label>&nbsp;dias corridos</label>
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
                                                            <input name="qtdiaest" type="text"  id="qtdiaest" /> <label>&nbsp;dias &uacute;teis</label>
                                                        </td>
                                                    </tr>
                                                </table>
                                            </fieldset>
                                            <fieldset>
                                                <legend align="left">Opera&ccedil;&otilde;es como avalista</legend>
                                                <table width="100%">
                                                    <tr>
                                                        <td>
                                                            <label for="qtavlatr">Qtd. dias em Atraso:</label>	
                                                            <input name="qtavlatr" type="text"  id="qtavlatr" />
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td>
                                                            <label for="vlavlatr">Valor em Atraso:</label>	
                                                            <input name="vlavlatr" type="text"  id="vlavlatr" />
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td>
                                                            <label for="qtavlope">Qtd. Opera&ccedil;&otilde;es em Atraso:</label>	
                                                            <input name="qtavlope" type="text"  id="qtavlope" />
                                                        </td>
                                                    </tr>
                                                </table>
                                            </fieldset>
                                            <fieldset>
                                                <legend align="left">Opera&ccedil;&otilde;es de C&ocirc;njuge</legend>
                                                <table width="100%">
                                                    <tr>
                                                        <td>
                                                            <label for="qtcjgatr">Qtd. dias em Atraso:</label>	
                                                            <input name="qtcjgatr" type="text"  id="qtcjgatr" />
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td>
                                                            <label for="vlcjgatr">Valor em Atraso:</label>	
                                                            <input name="vlcjgatr" type="text"  id="vlcjgatr" />
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td>
                                                            <label for="qtcjgope">Qtd. Opera&ccedil;&otilde;es em Atraso:</label>	
                                                            <input name="qtcjgope" type="text"  id="qtcjgope" />
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