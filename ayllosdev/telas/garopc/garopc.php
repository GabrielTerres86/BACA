<?php
/*!
 * FONTE        : garopc.php
 * CRIACAO      : Jaison Fernando
 * DATA CRIACAO : Novembro/2017
 * OBJETIVO     : Rotina da tela GAROPC

   Alteracoes   : 07/04/2018 - A tela de garantias deve ser apresentada bloqueada para o 
                               tipo PRICE TR, da mesma forma como é feito para CDC (Renato - Supero)
				  19/04/2019 - Ajuste na tela garantia de operação, para salvar seus dados apenas no 
                               final da inclusão, alteração de empréstimo - PRJ 438. (Mateus Z / Mouts)
 */

    session_start();
		
    require_once('../../includes/config.php');
    require_once('../../includes/funcoes.php');
    require_once('../../class/xmlfile.php');
	
    isPostMethod();
	
    $gar_tipaber  = (isset($_POST['tipaber']))      ? $_POST['tipaber']      : 'C';
    $gar_nmdatela = (isset($_POST['nmdatela']))     ? $_POST['nmdatela']     : '';
    $gar_nrdconta = (isset($_POST['nrdconta']))     ? $_POST['nrdconta']     : 0;
	$gar_tpemprst = (isset($_POST['tpemprst']))     ? $_POST['tpemprst']     : 9;
    $gar_tpctrato = (isset($_POST['tpctrato']))     ? $_POST['tpctrato']     : 0;
    $gar_idcobert = (isset($_POST['idcobert']))     ? $_POST['idcobert']     : 0;
    $gar_codlinha = (isset($_POST['codlinha']))     ? $_POST['codlinha']     : 0;
    $gar_vlropera = (isset($_POST['vlropera']))     ? $_POST['vlropera']     : 0;
    $gar_dsctrliq = (isset($_POST['dsctrliq']))     ? $_POST['dsctrliq']     : '';
	$gar_cdfinemp = (isset($_POST['cdfinemp']))     ? $_POST['cdfinemp']     : 0;
    $ret_nomcampo = (isset($_POST['ret_nomcampo'])) ? $_POST['ret_nomcampo'] : '';
    $ret_nomformu = (isset($_POST['ret_nomformu'])) ? $_POST['ret_nomformu'] : '';
    $ret_execfunc = (isset($_POST['ret_execfunc'])) ? $_POST['ret_execfunc'] : '';
    $ret_voltfunc = (isset($_POST['ret_voltfunc'])) ? $_POST['ret_voltfunc'] : '';
    $ret_errofunc = (isset($_POST['ret_errofunc'])) ? $_POST['ret_errofunc'] : '';
    $divanterior  = (isset($_POST['divanterior']))  ? $_POST['divanterior']  : '';

    $xml  = "";
    $xml .= "<Root>";
    $xml .= "   <Dados>";
    $xml .= "	   <idcobert>".$gar_idcobert."</idcobert>";	
    $xml .= "	   <tipaber>".$gar_tipaber."</tipaber>";
    $xml .= "	   <nrdconta>".$gar_nrdconta."</nrdconta>";	
    $xml .= "	   <tpctrato>".$gar_tpctrato."</tpctrato>";
    $xml .= "	   <codlinha>".$gar_codlinha."</codlinha>";
    $xml .= "	   <cdfinemp>".$gar_cdfinemp."</cdfinemp>";
    $xml .= "	   <vlropera>".converteFloat($gar_vlropera)."</vlropera>";
    $xml .= "	   <dsctrliq>".$gar_dsctrliq."</dsctrliq>";
    $xml .= "   </Dados>";
    $xml .= "</Root>";

    $xmlResult = mensageria($xml, "TELA_GAROPC", "GAROPC_BUSCA_DADOS", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
    $xmlObject = getObjectXML($xmlResult);
	
    if (strtoupper($xmlObject->roottag->tags[0]->name) == "ERRO"){
        $msgErro = utf8_encode($xmlObject->roottag->tags[0]->tags[0]->tags[4]->cdata);
        exibirErro('error',$msgErro,'Alerta - Ayllos',$ret_errofunc, true);
    }

    $registros = $xmlObject->roottag->tags[0];
    $gar_lintpctr = getByTagName($registros->tags,'LINTPCTR');
    $gar_lablinha = getByTagName($registros->tags,'LABLINHA');
    $gar_labgaran = getByTagName($registros->tags,'LABGARAN');
    $gar_deslinha = getByTagName($registros->tags,'DESLINHA');
    $gar_permingr = getByTagName($registros->tags,'PERMINGR');
    $gar_vlgarnec = getByTagName($registros->tags,'VLGARNEC');
    $gar_desbloqu = getByTagName($registros->tags,'DESBLOQU');
    $gar_inaplpro = getByTagName($registros->tags,'INAPLPRO');
    $gar_vlaplpro = getByTagName($registros->tags,'VLAPLPRO');
    $gar_inpoupro = getByTagName($registros->tags,'INPOUPRO');
    $gar_vlpoupro = getByTagName($registros->tags,'VLPOUPRO');
    $gar_inresaut = getByTagName($registros->tags,'INRESAUT');
    $gar_inresper = getByTagName($registros->tags,'INRESPER');
    $gar_diatrper = getByTagName($registros->tags,'DIATRPER');
    $gar_inaplter = getByTagName($registros->tags,'INAPLTER');
    $gar_vlaplter = getByTagName($registros->tags,'VLAPLTER');
    $gar_inpouter = getByTagName($registros->tags,'INPOUTER');
    $gar_vlpouter = getByTagName($registros->tags,'VLPOUTER');
    $gar_nrctater = getByTagName($registros->tags,'NRCTATER');
    $gar_nmctater = getByTagName($registros->tags,'NMCTATER');
	$gar_flfincdc = getByTagName($registros->tags,'FLGFINCDC');
	
	// Se for CDC ou se o tipo do empréstimo for PRICE TR
	if ($gar_flfincdc == 1 || $gar_tpemprst ==0){
		$gar_tipaber = 'C';
	}

	if ($gar_tpemprst == 0 || $gar_tpemprst == 2){
		$gar_inresaut = 0;
	}
?>
<script type="text/javascript" src="../../telas/garopc/garopc.js"></script>

<!-- INCLUDE DA TELA DE PESQUISA ASSOCIADO -->
<? require_once("../../includes/pesquisa/pesquisa_associados.php"); ?>

<table cellpadding="0" cellspacing="0" border="0" width="100%">
    <tr>
        <td align="center">		
            <table border="0" cellpadding="0" cellspacing="0" width="100%">
                <tr>
                    <td>
                        <table width="100%" border="0" cellspacing="0" cellpadding="0">
                            <tr>
                                <td width="11"><img src="<?php echo $UrlImagens; ?>background/tit_tela_esquerda.gif" width="11" height="21"></td>
                                <td class="txtBrancoBold ponteiroDrag" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif"><?php echo utf8ToHtml('GARANTIA PARA COBERTURA DA OPERAÇÃO'); ?></td>
                                <td width="12" id="tdTitTela" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif"><a href="#" onClick="$('#<?echo $cp_desmensagem?>').val('NOK');fechaRotina($('#divUsoGAROPC')<?if ($divanterior != ""){?>,$('#<?echo $divanterior;?>')<?}?>);<?if ($divanterior != ""){?>$('#<?echo $divanterior;?>').css({'display':'block'});<?}?> <? echo $ret_voltfunc; ?> return false;"><img src="<?php echo $UrlImagens; ?>geral/excluir.jpg" width="12" height="12" border="0"></a></td>
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
                                            <td align="center" style="background-color: #C6C8CA;" id="imgAbaCen0"><span class="txtNormalBold">Principal</span></td>
                                            <td><img src="<?php echo $UrlImagens; ?>background/mnu_nld.gif" width="4" height="21" id="imgAbaDir0"></td>
                                            <td width="1"></td>
                                        </tr>
                                    </table>
                                </td>
                            </tr>
                            <tr>
                                <td align="center" style="border: 2px solid #969FA9; background-color: #F4F3F0; padding: 2px;">
                                    <form name="frmGAROPC" id="frmGAROPC" class="formulario" onSubmit="return false;">
                                        <input name="gar_cdcooper"     id="gar_cdcooper"     type="hidden" value="<?php echo $glbvars["cdcooper"]; ?>" />
                                        <input name="gar_nmdatela"     id="gar_nmdatela"     type="hidden" value="<?php echo $gar_nmdatela; ?>" />
                                        <input name="gar_idcobert"     id="gar_idcobert"     type="hidden" value="<?php echo $gar_idcobert; ?>" />
                                        <input name="gar_tipaber"      id="gar_tipaber"      type="hidden" value="<?php echo $gar_tipaber; ?>"  />
                                        <input name="gar_tpctrato"     id="gar_tpctrato"     type="hidden" value="<?php echo $gar_tpctrato; ?>" />
                                        <input name="gar_nrdconta"     id="gar_nrdconta"     type="hidden" value="<?php echo $gar_nrdconta; ?>" />
                                        <input name="gar_dsctrliq"     id="gar_dsctrliq"     type="hidden" value="<?php echo $gar_dsctrliq; ?>" />
                                        <input name="gar_diatrper"     id="gar_diatrper"     type="hidden" value="<?php echo $gar_diatrper; ?>" />
                                        <input name="gar_inresper"     id="gar_inresper"     type="hidden" value="<?php echo $gar_inresper; ?>" />
                                        <input name="gar_inresaut"     id="gar_inresaut"     type="hidden" value="<?php echo $gar_inresaut; ?>" />
                                        <input name="gar_lintpctr"     id="gar_lintpctr"     type="hidden" value="<?php echo $gar_lintpctr; ?>" />
                                        <input name="gar_ter_apli_sld" id="gar_ter_apli_sld" type="hidden" value="<?php echo $gar_vlaplter; ?>" />
                                        <input name="gar_ter_poup_sld" id="gar_ter_poup_sld" type="hidden" value="<?php echo $gar_vlpouter; ?>" />

                                        <fieldset>
                                            <legend><?php echo utf8ToHtml('Operação'); ?></legend>

                                            <label for="gar_vlropera"><?php echo utf8ToHtml('Valor da Operação:'); ?></label>
                                            <input name="gar_vlropera" id="gar_vlropera" type="text" value="<?php echo $gar_vlropera; ?>" />
                                            <br />

                                            <label for="gar_codlinha"><?php echo $gar_lablinha; ?></label>
                                            <input name="gar_codlinha" id="gar_codlinha" type="text" value="<?php echo $gar_codlinha; ?>" />
                                            <input name="gar_deslinha" id="gar_deslinha" type="text" value="<?php echo $gar_deslinha; ?>" />
                                            <br />

                                            <label for="gar_permingr"><?php echo $gar_labgaran; ?></label>
                                            <input name="gar_permingr" id="gar_permingr" type="text" value="<?php echo $gar_permingr; ?>" vlr_permingr="<?php echo $gar_permingr; ?>" />
                                            <label class="rotulo-linha">% &nbsp;&nbsp; </label>
                                            <input name="gar_vlgarnec" id="gar_vlgarnec" type="text" value="<?php echo $gar_vlgarnec; ?>" />
                                            <img id="imgGAROPC" urlimage="<?php echo $UrlImagens; ?>geral/" style="float:left; margin:3 0 0 7" />
                                            <br clear="all" />

                                            <?php
                                                // Somente mostra caso possuir informacoes
                                                if ($gar_desbloqu) {
                                                    echo '<div class="rotulo" style="color:red; font-weight:bold; font-size:10px; margin:7px;">'.$gar_desbloqu.'</div>';
                                                }
                                            ?>
                                        </fieldset>

                                        <fieldset>
                                            <legend><?php echo utf8ToHtml('Aplicação Própria'); ?></legend>

                                            <label for="gar_pro_apli"><?php echo utf8ToHtml('Aplicação:'); ?></label>
                                            <input name="gar_pro_apli" id="gar_pro_apli_1" value="1" type="radio" class="radio" />
                                            <label for="gar_pro_apli_1" class="radio">Sim</label>
                                            <input name="gar_pro_apli" id="gar_pro_apli_0" value="0" type="radio" class="radio" />
                                            <label for="gar_pro_apli_0" class="radio"><?php echo utf8ToHtml('Não'); ?></label>
                                            <label for="gar_pro_apli_sld"><?php echo utf8ToHtml('Saldo Disponível:'); ?></label>
                                            <input name="gar_pro_apli_sld" id="gar_pro_apli_sld" type="text" value="<?php echo $gar_vlaplpro; ?>" />
                                            <br />

                                            <label for="gar_pro_poup"><?php echo utf8ToHtml('Aplicação Programada:'); ?></label>
                                            <input name="gar_pro_poup" id="gar_pro_poup_1" value="1" type="radio" class="radio" />
                                            <label for="gar_pro_poup_1" class="radio">Sim</label>
                                            <input name="gar_pro_poup" id="gar_pro_poup_0" value="0" type="radio" class="radio" />
                                            <label for="gar_pro_poup_0" class="radio"><?php echo utf8ToHtml('Não'); ?></label>
                                            <label for="gar_pro_poup_sld"><?php echo utf8ToHtml('Saldo Disponível:'); ?></label>
                                            <input name="gar_pro_poup_sld" id="gar_pro_poup_sld" type="text" value="<?php echo $gar_vlpoupro; ?>" />
                                            <br />

                                            <label for="gar_pro_raut"><?php echo utf8ToHtml('Resgate Automático:'); ?></label>
                                            <input name="gar_pro_raut" id="gar_pro_raut_1" value="1" type="radio" class="radio" />
                                            <label for="gar_pro_raut_1" class="radio">Sim</label>
                                            <input name="gar_pro_raut" id="gar_pro_raut_0" value="0" type="radio" class="radio" />
                                            <label for="gar_pro_raut_0" class="radio"><?php echo utf8ToHtml('Não'); ?></label>
                                        </fieldset>

                                        <fieldset>
                                            <legend><?php echo utf8ToHtml('Aplicação de Terceiro'); ?></legend>

                                            <label for="gar_ter_ncta">Conta:</label>
                                            <input name="gar_ter_ncta" id="gar_ter_ncta" type="text" value="<?php echo $gar_nrctater?>" />
                                            <a style="margin-top:5px;" href="#" id="btLupaAssociado"><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif" /></a>
                                            <input name="gar_ter_nome" id="gar_ter_nome" type="text" value="<?php echo $gar_nmctater?>" />
                                            <br />

                                            <label for="gar_ter_apli"><?php echo utf8ToHtml('Aplicação:'); ?></label>
                                            <input name="gar_ter_apli" id="gar_ter_apli_1" value="1" type="radio" class="radio" />
                                            <label for="gar_ter_apli_1" class="radio">Sim</label>
                                            <input name="gar_ter_apli" id="gar_ter_apli_0" value="0" type="radio" class="radio" />
                                            <label for="gar_ter_apli_0" class="radio"><?php echo utf8ToHtml('Não'); ?></label>
                                            <br />

                                            <label for="gar_ter_poup"><?php echo utf8ToHtml('Aplicação Programada:'); ?></label>
                                            <input name="gar_ter_poup" id="gar_ter_poup_1" value="1" type="radio" class="radio" />
                                            <label for="gar_ter_poup_1" class="radio">Sim</label>
                                            <input name="gar_ter_poup" id="gar_ter_poup_0" value="0" type="radio" class="radio" />
                                            <label for="gar_ter_poup_0" class="radio"><?php echo utf8ToHtml('Não'); ?></label>
                                        </fieldset>

                                        <div id="divBotoes" style="margin-bottom:10px;">
                                            <a href="#" class="botao" id="btVoltar" onClick="fechaRotina($('#divUsoGAROPC')<?if ($divanterior != ""){?>,$('#<?echo $divanterior;?>')<?}?>);<?if ($divanterior != ""){?>$('#<?echo $divanterior;?>').css({'display':'block'});<?}?> <? echo $ret_voltfunc; ?> return false;">Voltar</a>
                                            <?php
                                                // Se veio da ADITIV em modo Consulta
                                                if ($gar_nmdatela == 'ADITIV' && $gar_tipaber == 'C') {
                                                    ?><a href="#" class="botao" id="btImprimir" onClick="Gera_Impressao(); return false;">Imprimir</a><?php
                                                } elseif ($gar_tipaber == 'C') {
													?><a href="#" class="botao" id="btConfirmar" onClick="fechaRotina($('#divUsoGAROPC')); eval('<?php echo $ret_execfunc ?>');">Continuar</a><?php
													
												} else if ($gar_nmdatela == 'EMPRESTIMOS') {
                                                    ?><a href="#" class="botao" id="btConfirmar" onClick="validarGAROPC('<?php echo $ret_execfunc; ?>', 'bloqueiaFundo($(\'#divUsoGAROPC\'))');">Continuar</a><?php
												} else {
                                                    ?><a href="#" class="botao" id="btConfirmar" onClick="gravarGAROPC('<?php echo $ret_nomcampo; ?>','<?php echo $ret_nomformu; ?>','<?php echo $ret_execfunc; ?>', 'bloqueiaFundo($(\'#divUsoGAROPC\'))');">Continuar</a><?php
                                                }
                                            ?>
                                        </div>
                                    </form>
                                    <?php
                                        // Se veio da ADITIV em modo Consulta
                                        if ($gar_nmdatela == 'ADITIV' && $gar_tipaber == 'C') {
                                            ?><form id="frmTipo"></form><?php
                                        }
                                    ?>
                                </td>
                            </tr>
                        </table>			    
                    </td> 
                </tr>
            </table>
        </td>
    </tr>
</table>
<script language="Javascript">
    $('#gar_pro_apli_<?php echo $gar_inaplpro; ?>').prop("checked", true);
    $('#gar_pro_poup_<?php echo $gar_inpoupro; ?>').prop("checked", true);
    $('#gar_pro_raut_<?php echo $gar_inresaut; ?>').prop("checked", true);
    $('#gar_ter_apli_<?php echo $gar_inaplter; ?>').prop("checked", true);
    $('#gar_ter_poup_<?php echo $gar_inpouter; ?>').prop("checked", true);

    mostraImagemGAROPC();

</script>