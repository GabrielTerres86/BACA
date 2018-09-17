<?php
/*!
 * FONTE        : form_cadfra.php
 * CRIAÇÃO      : Jaison
 * DATA CRIAÇÃO : 07/02/2017
 * OBJETIVO     : Formulario do cadastro.
 * --------------
 * ALTERAÇÕES   : 14/06/2018 - Ajustes Antifraude. PRJ381 - Antifraude(pagamentos)(Odirlei-AMcom)
 * --------------
 */
 
 $dominios = buscaDominios('CC', 'TPRETENCAO_ANALISE_FRAUDE');
 
?>
<form id="frmCadfra" name="frmCadfra" class="formulario">
<input type="hidden" id="strhoraminutos">
	<fieldset style="padding-top: 5px;">
        <label for="cdoperacao">Operação:</label>
        <input type="text" id="cdoperacao" name="cdoperacao" />
        <a><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"></a>
        <label for="dsoperacao">Descrição:</label>
        <input type="text" id="dsoperacao" name="dsoperacao" />
        <label for="tpoperacao">Tipo da operação:</label>
        <select id="tpoperacao" name="insitage">
            <option value="1">Online</option>
            <option value="2">Agendada</option>
        </select>
	</fieldset>

    <div id="divTabCampos" style="padding:7px 3px 0px 3px;">
        <table width="100%"  border="0" cellspacing="0" cellpadding="0">
            <tr>
                <td>
                    <table border="0" cellspacing="0" cellpadding="0">
                        <tr>
                            <td><img src="<?php echo $UrlImagens; ?>background/mnu_nle.gif" width="4" height="21" id="imgAbaEsq0"></td>
                            <td align="center" style="background-color: #C6C8CA;" id="imgAbaCen0"><a href="#" id="linkAba0" class="txtNormalBold" onClick="acessaOpcaoAba(0);return false;">Retenção</a></td>
                            <td><img src="<?php echo $UrlImagens; ?>background/mnu_nld.gif" width="4" height="21" id="imgAbaDir0"></td>
                            <td width="1"></td>

                            <td><img src="<?php echo $UrlImagens; ?>background/mnu_nle.gif" width="4" height="21" id="imgAbaEsq1"></td>
                            <td align="center" style="background-color: #C6C8CA;" id="imgAbaCen1"><a href="#" id="linkAba1" class="txtNormalBold" onClick="acessaOpcaoAba(1);return false;">E-mail Entrega</a></td>
                            <td><img src="<?php echo $UrlImagens; ?>background/mnu_nld.gif" width="4" height="21" id="imgAbaDir1"></td>
                            <td width="1"></td>

                            <td><img src="<?php echo $UrlImagens; ?>background/mnu_nle.gif" width="4" height="21" id="imgAbaEsq2"></td>
                            <td align="center" style="background-color: #C6C8CA;" id="imgAbaCen2"><a href="#" id="linkAba2" class="txtNormalBold" onClick="acessaOpcaoAba(2);return false;">E-mail Retorno</a></td>
                            <td><img src="<?php echo $UrlImagens; ?>background/mnu_nld.gif" width="4" height="21" id="imgAbaDir2"></td>
                            <td width="1"></td>
                        </tr>
                    </table>
                </td>
            </tr>
            <tr>
                <td align="center" style="border: 2px solid #969FA9; background-color: #F4F3F0; padding: 2px;">
                    <div id="divAba0" class="clsAbas">
                        <br clear="all" />
                        <input type="hidden" id="flgativo_ori" name="flgativo_ori">
                        <label for="flgativo">Envio análise:</label>
                        <select id="flgativo" name="flgativo">
                            <option value="0">Inativo</option>
                            <option value="1">Ativo</option>
                        </select>
                        
                        <br clear="all" />                        
                        <label for="tpretencao">Tipo de retenção:</label>
                        <select id="tpretencao" name="tpretencao">
                            <?	
                            foreach($dominios as $dominio) {
                                ?> 
                                <option value="<? echo getByTagName($dominio->tags,'cddominio'); ?>"><? echo getByTagName($dominio->tags,'dscodigo'); ?></option>
                                <?
                            }
                            ?>
                        </select>
                        
                        <br clear="all" />
                        <div id="divTipo1" style="padding-top: 5px;">
                            <div id="addInterv">
                                <label for="hrretencao2">Aguardar análise por</label>
                                <select id="qtdminutos_retencao" name="qtdminutos_retencao">
                                    <option value="05">05</option>
                                    <option value="10">10</option>
                                    <option value="15">15</option>
                                    <option value="20">20</option>
                                    <option value="30">30</option>
                                    <option value="40">40</option>
                                    <option value="50">50</option>
                                    <option value="60">60</option>
                                </select>
                                <label for="hrretencao3">minutos das</label>
                                <input type="text" id="hrinicio" name="hrinicio" />
                                <label for="hrretencao4">até as</label>
                                <input type="text" id="hrfim" name="hrfim" />
                                <img onclick="confirmaInclusao();" src="<?php echo $UrlImagens; ?>geral/servico_ativo.gif" style="width:18px; height:18px; margin:3px 15px 3px 8px; float:left; cursor: hand;" />
                                <label for="rotulo_inf">Utilizar formato 24 horas.</label>
                                <br clear="all" />
                                <br clear="all" />
                            </div>
                            <div id="divHora" class="divRegistros">
                                <table>
                                    <thead>
                                        <tr>
                                            <th>Início</th>
                                            <th>Fim</th>
                                            <th>Minutos</th>
                                            <th>Excluir</th>
                                        </tr>
                                    </thead>
                                    <tbody id="tbodyHora"></tbody>
                                </table>
                            </div>
                        </div>

                        <div id="divTipo2" style="padding-top: 5px;">
                            <label for="hrretencao">Aguardar análise até as:</label>
                            <input type="text" id="hrretencao" name="hrretencao" />
                            <label for="rotulo_inf">Utilizar formato 24 horas.</label>
                            <br clear="all" />
                            <br clear="all" />
                        </div>
                        
                        <div id="divTipo3" style="padding-top: 5px;">
                            <label for="hrretencao5">Aguardar análise por mais:</label>
                            <input type="text" id="hrretencao5" name="hrretencao5" />
                            <label for="hrretencao6">minutos</label>
                            <br clear="all" />
                            <br clear="all" />
                        </div>
                        
                    </div>

                    <div id="divAba1" class="clsAbas">
                        <br clear="all" />
                        <label for="flgemail_entrega">Enviar e-mail quando ocorrer falha na entrega para análise?</label>
                        <input name="flgemail_entrega" id="flgYes" type="radio" class="radio" value="1" style="margin-left:10px;" />
                        <label for="flgYes" class="radio">Sim</label>
                        <input name="flgemail_entrega" id="flgNo" type="radio" class="radio" value="0" />
                        <label for="flgNo" class="radio">Não</label>
                        <label for="dsemail_entrega">Endereço:</label>
                        <input type="text" id="dsemail_entrega" name="dsemail_entrega" />
                        <label for="dsemail_entrega"></label>
                        <label for="rotulo_eml">Para mais de um e-mail utilizar ponto e vírgula (;) como separador.</label>
                        <label for="dsassunto_entrega">Assunto:</label>
                        <input type="text" id="dsassunto_entrega" name="dsassunto_entrega" />
                        <label for="dscorpo_entrega">Conteúdo:</label>
                        <textarea name="dscorpo_entrega" id="dscorpo_entrega"></textarea>
                        <br clear="all" />
                        <br clear="all" />
                    </div>

                    <div id="divAba2" class="clsAbas">
                        <br clear="all" />
                        <label for="flgemail_retorno">Enviar e-mail quando ocorrer falha no retorno da análise?</label>
                        <input name="flgemail_retorno" id="flgYesRet" type="radio" class="radio" value="1" style="margin-left:10px;" />
                        <label for="flgYesRet" class="radio">Sim</label>
                        <input name="flgemail_retorno" id="flgNoRet" type="radio" class="radio" value="0" />
                        <label for="flgNoRet" class="radio">Não</label>
                        <label for="dsemail_retorno">Endereço:</label>
                        <input type="text" id="dsemail_retorno" name="dsemail_retorno" />
                        <label for="dsemail_retorno"></label>
                        <label for="rotulo_eml">Para mais de um e-mail utilizar ponto e vírgula (;) como separador.</label>
                        <label for="dsassunto_retorno">Assunto:</label>
                        <input type="text" id="dsassunto_retorno" name="dsassunto_retorno" />
                        <label for="dscorpo_retorno">Conteúdo:</label>
                        <textarea name="dscorpo_retorno" id="dscorpo_retorno"></textarea>
                        <br clear="all" />
                        <br clear="all" />
                    </div>
                </td>
            </tr>
        </table>
    </div>

</form>