<?php
/*!
 * FONTE        : form_cadpac.php
 * CRIAÇÃO      : Jaison
 * DATA CRIAÇÃO : 05/07/2016
 * OBJETIVO     : Formulario do cadastro.
 * --------------
 * ALTERAÇÕES   : 08/08/2017 - Implementacao da melhoria 438. Heitor (Mouts).
 *				  08/08/2017 - Adicionado novo campo Habilitar Acesso CRM. (Reinert - Projeto 339)
 *                03/01/2018 - M307 Solicitação de senha e limite para pagamento (Diogo / MoutS)
 * --------------
 */	
?>
<form id="frmCadpac" name="frmCadpac" class="formulario">
<input id="cdcooper" type="hidden" value="<?php echo $glbvars["cdcooper"]; ?>" />

	<fieldset style="padding-top: 5px;">
        <label for="cdagenci">PA:</label>
        <input type="text" id="cdagenci" name="cdagenci" />
        <a><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"></a>
        <label for="nmresage">Nome resumido:</label>
        <input type="text" id="nmresage" name="nmresage" />
	</fieldset>

    <fieldset id="fieldOpcaoB" style="padding-top: 5px;">
        <input type="hidden" id="rowidcxa" name="rowidcxa" />
        <label for="nrdcaixa">Número do caixa:</label>
        <input type="text" id="nrdcaixa" name="nrdcaixa" />
        <label for="cdopercx">Código do operador:</label>
        <input type="text" id="cdopercx" name="cdopercx" />
        <label for="dtdcaixa">Data abertura caixa:</label>
        <input type="text" id="dtdcaixa" name="dtdcaixa" />
	</fieldset>

    <fieldset id="fieldOpcaoX" style="padding-top: 5px;">
        <label for="vllimapv_x">Valor de Aprovação do Comitê Local:</label>
        <input type="text" id="vllimapv_x" name="vllimapv_x" />
	</fieldset>

    <fieldset id="fieldOpcaoS" style="padding-top: 5px;">
        <label for="nmpasite">Nome:</label>
        <input type="text" id="nmpasite" name="nmpasite" />
        <label for="dstelsit">Telefone:</label>
        <input type="text" id="dstelsit" name="dstelsit" />
        <label for="dsemasit">E-mail:</label>
        <input type="text" id="dsemasit" name="dsemasit" />
		<label for="hrinipaa">Horário de Atendimento:</label>
        <input type="text" id="hrinipaa" name="hrinipaa" value="00:00" />
        <label for="hrfimpaa">até</label>
        <input type="text" id="hrfimpaa" name="hrfimpaa" value="00:00" />
        <label for="rotulo_h">h</label>
		<label for="dssitpaa">Situação:</label>		
		<input type="text" id="dssitpaa" name="dssitpaa"/>		
		<label for="indspcxa">Possui Caixa Presencial</label>
		<select id="indspcxa" name="indspcxa">
			<option value="0">NAO</option>
			<option value="1">SIM</option>
		</select>
		<br clear="all" />		
		<label for="indsptaa">Possui Caixa Eletrônico</label>
		<select id="indsptaa" name="indsptaa">
			<option value="0">NAO</option>
			<option value="1">SIM</option>
		</select>
		<br clear="all" />
        <label for="nrlatitu">Latitude:</label>
        <input type="text" id="nrlatitu" name="nrlatitu" />
        <label for="nrlongit">Longitude:</label>
        <input type="text" id="nrlongit" name="nrlongit" />
	</fieldset>
    <div id="divTabCampos" style="padding:7px 3px 0px 3px;">
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
                            <td align="center" style="background-color: #C6C8CA;" id="imgAbaCen1"><a href="#" id="linkAba1" class="txtNormalBold" onClick="acessaOpcaoAba(1);return false;">Endereço</a></td>
                            <td><img src="<?php echo $UrlImagens; ?>background/mnu_nld.gif" width="4" height="21" id="imgAbaDir1"></td>
                            <td width="1"></td>

                            <td><img src="<?php echo $UrlImagens; ?>background/mnu_nle.gif" width="4" height="21" id="imgAbaEsq2"></td>
                            <td align="center" style="background-color: #C6C8CA;" id="imgAbaCen2"><a href="#" id="linkAba2" class="txtNormalBold" onClick="acessaOpcaoAba(2);return false;">Horários</a></td>
                            <td><img src="<?php echo $UrlImagens; ?>background/mnu_nld.gif" width="4" height="21" id="imgAbaDir2"></td>
                            <td width="1"></td>

                            <td><img src="<?php echo $UrlImagens; ?>background/mnu_nle.gif" width="4" height="21" id="imgAbaEsq3"></td>
                            <td align="center" style="background-color: #C6C8CA;" id="imgAbaCen3"><a href="#" id="linkAba3" class="txtNormalBold" onClick="acessaOpcaoAba(3);return false;">Complementar</a></td>
                            <td><img src="<?php echo $UrlImagens; ?>background/mnu_nld.gif" width="4" height="21" id="imgAbaDir3"></td>
                            <td width="1"></td>
                        </tr>
                    </table>
                </td>
            </tr>
            <tr>
                <td align="center" style="border: 2px solid #969FA9; background-color: #F4F3F0; padding: 2px;">
                    <div id="divAba0" class="clsAbas">
                        <br clear="all" />
                        <label for="nmextage">Nome:</label>
                        <input type="text" id="nmextage" name="nmextage" />
                        <label for="insitage">Situação do PA:</label>
                        <select id="insitage" name="insitage">
                            <option value="0">EM OBRAS</option>
                            <option value="1">ATIVO</option>
                            <option value="2">INATIVO</option>
                            <option value="3">TEMPORARIAMENTE INDISPONIVEL</option>
                        </select>
                        <label for="cdcxaage">Código caixa:</label>
                        <input type="text" id="cdcxaage" name="cdcxaage" />
                        <br clear="all" />
                        <br clear="all" />
                        <label for="tpagenci">Agência:</label>
                         <select id="tpagenci" name="tpagenci">
                            <option value="0">CONVENCIONAL</option>
                            <option value="1">PIONEIRA</option>
                        </select>
                        <label for="cdccuage">Centro de custo:</label>
                        <input type="text" id="cdccuage" name="cdccuage" />
                        <label for="cdorgpag">Órgão pagador:</label>
                        <input type="text" id="cdorgpag" name="cdorgpag" />
                        <label for="cdagecbn">Agência relacionamento COBAN:</label>
                        <input type="text" id="cdagecbn" name="cdagecbn" />
                        <label for="cdcomchq">Código da COMPE:</label>
                        <input type="text" id="cdcomchq" name="cdcomchq" />
                        <label for="vercoban">Verificar Pendências COBAN:</label>
                        <select id="vercoban" name="vercoban">
                            <option value="0">NAO</option>
                            <option value="1">SIM</option>
                        </select>
                        <br clear="all" />
                        <br clear="all" />
                        <label for="cdbantit">Banco compe TIT:</label>
                        <input type="text" id="cdbantit" name="cdbantit" />
                        <label for="cdagetit">Agência compe TIT:</label>
                        <input type="text" id="cdagetit" name="cdagetit" />
                        <label for="cdbanchq">Banco compe CHEQ:</label>
                        <input type="text" id="cdbanchq" name="cdbanchq" />
                        <label for="cdagechq">Agência compe CHEQ:</label>
                        <input type="text" id="cdagechq" name="cdagechq" />
                        <label for="cdbandoc">Banco compe DOC:</label>
                        <input type="text" id="cdbandoc" name="cdbandoc" />
                        <label for="cdagedoc">Agência compe DOC:</label>
                        <input type="text" id="cdagedoc" name="cdagedoc" />
                        <br clear="all" />
                        <br clear="all" />
                        <label for="flgdsede">PA Sede:</label>
                        <select id="flgdsede" name="flgdsede">
                            <option value="0">NAO</option>
                            <option value="1">SIM</option>
                        </select>
                        <label for="cdagepac">Agência do PA:</label>
                        <input type="text" id="cdagepac" name="cdagepac" />
                        <br clear="all" />
                        <br clear="all" />
						<label for="flmajora">Majoração Lim. Cré.:</label>
                        <select id="flmajora" name="flmajora">
                            <option value="0">NAO</option>
                            <option value="1">SIM</option>
                        </select>
						
						<label for="flgutcrm">Habilitar Acesso CRM:</label>
                        <select id="flgutcrm" name="flgutcrm">
                            <option value="0">N&Atilde;O</option>
                            <option value="1">SIM</option>
                        </select>
                        <br clear="all" />
                        <br clear="all" />
                    </div>

                    <div id="divAba1" class="clsAbas">
                        <br clear="all" />
                        <label for="dsendcop">Endereço:</label>
                        <input type="text" id="dsendcop" name="dsendcop" />
                        <label for="dscomple">Complemento:</label>
                        <input type="text" id="dscomple" name="dscomple" />
                        <label for="nrendere">Número:</label>
                        <input type="text" id="nrendere" name="nrendere" />
                        <label for="nmbairro">Bairro:</label>
                        <input type="text" id="nmbairro" name="nmbairro" />
                        <label for="nrcepend">CEP:</label>
                        <input type="text" id="nrcepend" name="nrcepend" />
                        <label for="cdestado">UF:</label>
                        <?php echo selectEstado('cdestado', "", 1); ?>
                        <label for="idcidade">Cidade:</label>
                        <input type="text" id="idcidade" name="idcidade" />
                        <a><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"></a>
                        <input type="text" id="dscidade" name="dscidade" />
                        <label for="dsdemail">E-mail:</label>
                        <input type="text" id="dsdemail" name="dsdemail" />
                        <label for="dsmailbd">E-mail Borderô:</label>
                        <input type="text" id="dsmailbd" name="dsmailbd" />
                        <label for="dsinform1">Dados para impressão dos cheques:</label>
                        <input type="text" id="dsinform1" name="dsinform1" />
                        <label for="dsinform2"></label>
                        <input type="text" id="dsinform2" name="dsinform2" />
                        <label for="dsinform3"></label>
                        <input type="text" id="dsinform3" name="dsinform3" />
                        <br clear="all" />
                        <br clear="all" />
                    </div>

                    <div id="divAba2" class="clsAbas">
                        <br clear="all" />
                        <label for="hhsicini">Pagamentos Faturas Sicredi:</label>
                        <input type="text" id="hhsicini" name="hhsicini" value="00:00" />
                        <label for="hhsicfim">até</label>
                        <input type="text" id="hhsicfim" name="hhsicfim" value="00:00" />
                        <label for="rotulo_h">h</label>
                        <label for="hhtitini">Pagamentos Titulos/Faturas:</label>
                        <input type="text" id="hhtitini" name="hhtitini" value="00:00" />
                        <label for="hhtitfim">até</label>
                        <input type="text" id="hhtitfim" name="hhtitfim" value="00:00" />
                        <label for="rotulo_h">h</label>
                        <label for="hhcompel">Cheques:</label>
                        <input type="text" id="hhcompel" name="hhcompel" value="00:00" />
                        <label for="rotulo_h">h</label>
                        <label for="hhcapini">Plano Capital/Captação:</label>
                        <input type="text" id="hhcapini" name="hhcapini" value="00:00" />
                        <label for="hhcapfim">até</label>
                        <input type="text" id="hhcapfim" name="hhcapfim" value="00:00" />
                        <label for="rotulo_h">h</label>
                        <label for="hhdoctos">Doctos:</label>
                        <input type="text" id="hhdoctos" name="hhdoctos" value="00:00" />
                        <label for="rotulo_h">h</label>
                        <label for="hhtrfini">Transferência:</label>
                        <input type="text" id="hhtrfini" name="hhtrfini" value="00:00" />
                        <label for="hhtrffim">até</label>
                        <input type="text" id="hhtrffim" name="hhtrffim" value="00:00" />
                        <label for="rotulo_h">h</label>
                        <label for="hhguigps">Guias GPS:</label>
                        <input type="text" id="hhguigps" name="hhguigps" value="00:00" />
                        <label for="rotulo_h">h</label>
                        <label for="hhbolini">Geração/Instruções Cob. Registrada:</label>
                        <input type="text" id="hhbolini" name="hhbolini" value="00:00" />
                        <label for="hhbolfim">até</label>
                        <input type="text" id="hhbolfim" name="hhbolfim" value="00:00" />
                        <label for="rotulo_h">h</label>
                        <label for="hhenvelo">Depósito TAA:</label>
                        <input type="text" id="hhenvelo" name="hhenvelo" value="00:00" />
                        <label for="rotulo_h">h</label>
                        <label for="hhcpaini">Contratação de Crédito Pré-Aprovado:</label>
                        <input type="text" id="hhcpaini" name="hhcpaini" value="00:00" />
                        <label for="hhcpafim">até</label>
                        <input type="text" id="hhcpafim" name="hhcpafim" value="00:00" />
                        <label for="rotulo_h">h</label>
                        <br clear="all" />
                        <br clear="all" />
                        <label for="hhlimcan">Cancelamento de pagamentos:</label>
                        <input type="text" id="hhlimcan" name="hhlimcan" value="00:00" />
                        <label for="rotulo_h">h</label>
                        <label for="nrtelvoz">Telefone:</label>
                        <input type="text" id="nrtelvoz" name="nrtelvoz" />
                        <label for="hhsiccan">Cancelamento pagamento SICREDI:</label>
                        <input type="text" id="hhsiccan" name="hhsiccan" value="00:00" />
                        <label for="rotulo_h">h</label>
                        <label for="nrtelfax">FAX:</label>
                        <input type="text" id="nrtelfax" name="nrtelfax" />
                        <br clear="all" />
                        <label for="vllimpag">Limite m&aacute;x. - pgto sem autor.</label>
                        <input type="text" id="vllimpag" name="vllimpag" />
                        <br clear="all" />
                        <br clear="all" />
                        <label for="rotulopr">Parâmetros de Agendamentos:</label>
                        <label for="qtddaglf">Dias Limite para Agendamento:</label>
                        <input type="text" id="qtddaglf" name="qtddaglf" />
                        <label for="qtmesage">Meses Agendamento Captação:</label>
                        <input type="text" id="qtmesage" name="qtmesage" />
                        <label for="qtddlslf">Dias Limite para Lançamentos Futuros:</label>
                        <input type="text" id="qtddlslf" name="qtddlslf" />
                        <label for="flsgproc">Processo Manual:</label>
                        <select id="flsgproc" name="flsgproc">
                            <option value="NAO">NAO</option>
                            <option value="SIM">SIM</option>
                        </select>
                        <br clear="all" />
                        <br clear="all" />
                    </div>

                    <div id="divAba3" class="clsAbas">
                        <br clear="all" />
                        <label for="vllimapv">Valor de Aprovação do Comitê Local:</label>
                        <input type="text" id="vllimapv" name="vllimapv" />
                        <label for="qtchqprv">Quantidade Máxima de Cheques por Prévia:</label>
                        <input type="text" id="qtchqprv" name="qtchqprv" />
                        <br clear="all" />
                        <br clear="all" />
                        <label for="flgdopgd">Dados do PROGRID: PA participante:</label>
                        <select id="flgdopgd" name="flgdopgd">
                            <option value="0">NAO</option>
                            <option value="1">SIM</option>
                        </select>
                        <label for="cdageagr">PA agrupador:</label>
                        <input type="text" id="cdageagr" name="cdageagr" />
                        <br clear="all" />
                        <br clear="all" />
                        <label for="cddregio">Código da Regional:</label>
                        <input type="text" id="cddregio" name="cddregio" />
                        <a><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"></a>
                        <input type="text" id="dsdregio" name="dsdregio" />
                        <br clear="all" />
                        <br clear="all" />
                        <label for="tpageins">Convênio Sicredi: Agência pioneira:</label>
                        <input type="text" id="tpageins" name="tpageins" />
                        <label for="cdorgins">Órgão pagador:</label>
                        <input type="text" id="cdorgins" name="cdorgins" />
                        <br clear="all" />
                        <br clear="all" />
                        <label for="vlminsgr">Sangria de Caixa: Valor Mínimo:</label>
                        <input type="text" id="vlminsgr" name="vlminsgr" />
                        <label for="vlmaxsgr">Valor Máximo:</label>
                        <input type="text" id="vlmaxsgr" name="vlmaxsgr" />
                        <br clear="all" />
                        <br clear="all" />
                    </div>
                </td>
            </tr>
        </table>
    </div>

</form>