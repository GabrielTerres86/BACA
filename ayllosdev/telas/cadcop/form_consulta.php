<?php
/* * *********************************************************************

  Fonte: form_consulta.php
  Autor: Andrei - RKAM
  Data : Agosto/2016                       Última Alteração: 17/11/2016

  Objetivo  : Mostrar o form com as informaões da cooperativa.

  Alterações: 17/11/2016 - M172 Atualizacao Telefone - Novo campo (Guilherme/SUPERO)

              03/01/2018 - M307 Solicitação de senha e limite para pagamento (Diogo / MoutS)

              21/11/2017 - Inclusão dos campos flintcdc, tpcdccop, Prj. 402 (Jean Michel)

              26/09/2018 - Inclusão do campo 'Horário mínimo login'. SCTASK0027519 (Mateus Z / Mouts)

 * ********************************************************************* */

    require_once('../../includes/config.php');
    require_once('../../includes/funcoes.php');
    require_once('../../includes/controla_secao.php');
    require_once('../../class/xmlfile.php');
    isPostMethod();

    require_once("../../includes/carrega_permissoes.php");

?>
<form id="frmConsulta" name="frmConsulta" class="formulario" style="display:none;">

    <fieldset id="fsetGeral" name="fsetGeral" style="padding:0px; margin:0px; padding-bottom:10px;">

        <legend>Informa&ccedil;&otilde;es gerais</legend>

        <label for="cdcooper"><?php echo utf8ToHtml("Cooperativa:"); ?></label>
        <input type="text" id="cdcooper" name="cdcooper" value="<?php echo getByTagName($cooperativa->tags,'cdcooper');?>" >

        <label for="nmrescop"></label>
        <input type="text" id="nmrescop" name="nmrescop" value="<?php echo getByTagName($cooperativa->tags,'nmrescop');?>" >

        <br />

        <label for="nrdocnpj"><?php echo utf8ToHtml("CNPJ:"); ?></label>
        <input type="text" id="nrdocnpj" name="nrdocnpj" value="<?php echo getByTagName($cooperativa->tags,'nrdocnpj');?>" >

        <label for="dtcdcnpj"><?php echo utf8ToHtml("Data CNPJ:"); ?></label>
        <input type="text" id="dtcdcnpj" name="dtcdcnpj" value="<?php echo getByTagName($cooperativa->tags,'dtcdcnpj');?>" >

        <br />

        <label for="nmextcop"><?php echo utf8ToHtml("Nome extenso:"); ?></label>
        <input type="text" id="nmextcop" name="nmextcop" value="<?php echo getByTagName($cooperativa->tags,'nmextcop');?>" >

        <br />

        <label for="dsendcop"><?php echo utf8ToHtml("Endere&ccedil;o:"); ?></label>
        <input type="text" id="dsendcop" name="dsendcop" value="<?php echo getByTagName($cooperativa->tags,'dsendcop');?>" >

        <label for="nrendcop"><?php echo utf8ToHtml("N&uacute;mero:"); ?></label>
        <input type="text" id="nrendcop" name="nrendcop" value="<?php echo getByTagName($cooperativa->tags,'nrendcop');?>" >

        <br />

        <label for="dscomple"><?php echo utf8ToHtml("Complemento:"); ?></label>
        <input type="text" id="dscomple" name="dscomple" value="<?php echo getByTagName($cooperativa->tags,'dscomple');?>" >

        <br />

        <label for="nmbairro"><?php echo utf8ToHtml("Bairro:"); ?></label>
        <input type="text" id="nmbairro" name="nmbairro" value="<?php echo getByTagName($cooperativa->tags,'nmbairro');?>" >

        <label for="nrcepend"><?php echo utf8ToHtml("CEP:"); ?></label>
        <input type="text" id="nrcepend" name="nrcepend" value="<?php echo getByTagName($cooperativa->tags,'nrcepend');?>" >

        <br />

        <label for="nmcidade"><?php echo utf8ToHtml("Cidade:"); ?></label>
        <input type="text" id="nmcidade" name="nmcidade" value="<?php echo getByTagName($cooperativa->tags,'nmcidade');?>" >

        <label for="cdufdcop"><?php echo utf8ToHtml("UF:"); ?></label>
        <input type="text" id="cdufdcop" name="cdufdcop" value="<?php echo getByTagName($cooperativa->tags,'cdufdcop');?>" >

        <br />

        <label for="nrcxapst"><?php echo utf8ToHtml("Caixa postal:"); ?></label>
        <input type="text" id="nrcxapst" name="nrcxapst" value="<?php echo getByTagName($cooperativa->tags,'nrcxapst');?>" >

        <br />

        <label for="nrtelvoz"><?php echo utf8ToHtml("Telefone:"); ?></label>
        <input type="text" id="nrtelvoz" name="nrtelvoz" value="<?php echo getByTagName($cooperativa->tags,'nrtelvoz');?>" >

        <label for="nrtelouv"><?php echo utf8ToHtml("Ouvidoria:"); ?></label>
        <input type="text" id="nrtelouv" name="nrtelouv" value="<?php echo getByTagName($cooperativa->tags,'nrtelouv');?>" >

        <br />

        <label for="dsendweb"><?php echo utf8ToHtml("Site:"); ?></label>
        <input type="text" id="dsendweb" name="dsendweb" value="<?php echo getByTagName($cooperativa->tags,'dsendweb');?>" >

        <label for="nrtelura"><?php echo utf8ToHtml("URA:"); ?></label>
        <input type="text" id="nrtelura" name="nrtelura" value="<?php echo getByTagName($cooperativa->tags,'nrtelura');?>" >

        <br />

        <label for="dsdemail"><?php echo utf8ToHtml("E-mail:"); ?></label>
        <input type="text" id="dsdemail" name="dsdemail" value="<?php echo getByTagName($cooperativa->tags,'dsdemail');?>" >

        <label for="nrtelfax"><?php echo utf8ToHtml("FAX:"); ?></label>
        <input type="text" id="nrtelfax" name="nrtelfax" value="<?php echo getByTagName($cooperativa->tags,'nrtelfax');?>" >

        <br />

        <label for="dsdempst"><?php echo utf8ToHtml("E-mail presidente:"); ?></label>
        <input type="text" id="dsdempst" name="dsdempst" value="<?php echo getByTagName($cooperativa->tags,'dsdempst');?>" >

        <label for="nrtelsac"><?php echo utf8ToHtml("SAC:"); ?></label>
        <input type="text" id="nrtelsac" name="nrtelsac" value="<?php echo getByTagName($cooperativa->tags,'nrtelsac');?>" >

    </fieldset>


    <fieldset id="fsetPresidencia" name="fsetPresidencia" style="padding:0px; margin:0px; padding-bottom:10px;">

        <legend>Presid&ecirc;ncia</legend>

        <label for="nmtitcop"><?php echo utf8ToHtml("Presidente da Cooperativa:"); ?></label>
        <input type="text" id="nmtitcop" name="nmtitcop" value="<?php echo getByTagName($cooperativa->tags,'nmtitcop');?>" >

        <br />

        <label for="nrcpftit"><?php echo utf8ToHtml("CPF do Presidente:"); ?></label>
        <input type="text" id="nrcpftit" name="nrcpftit" value="<?php echo getByTagName($cooperativa->tags,'nrcpftit');?>" >

    </fieldset>

</form>

<form id="frmConsulta2" name="frmConsulta2" class="formulario" style="display:none;">

    <fieldset id="fsetContabilidade" name="fsetContabilidade" style="padding:0px; margin:0px; padding-bottom:10px;">

        <legend>Contabilidade</legend>

        <label for="nmctrcop"><?php echo utf8ToHtml("Nome do contador:"); ?></label>
        <input type="text" id="nmctrcop" name="nmctrcop" value="<?php echo getByTagName($cooperativa->tags,'nmctrcop');?>" >

        <br />

        <label for="nrcpfctr"><?php echo utf8ToHtml("CPF do contador:"); ?></label>
        <input type="text" id="nrcpfctr" name="nrcpfctr" value="<?php echo getByTagName($cooperativa->tags,'nrcpfctr');?>" >

        <label for="nrcrcctr"><?php echo utf8ToHtml("CRC:"); ?></label>
        <input type="text" id="nrcrcctr" name="nrcrcctr" value="<?php echo getByTagName($cooperativa->tags,'nrcrcctr');?>" >

        <br />

        <label for="dsemlctr"><?php echo utf8ToHtml("E-mail do contador:"); ?></label>
        <input type="text" id="dsemlctr" name="dsemlctr" value="<?php echo getByTagName($cooperativa->tags,'dsemlctr');?>" >

        <br />

        <label for="nrrjunta"><?php echo utf8ToHtml("Registro na junta:"); ?></label>
        <input type="text" id="nrrjunta" name="nrrjunta" value="<?php echo getByTagName($cooperativa->tags,'nrrjunta');?>" >

        <label for="dtrjunta"><?php echo utf8ToHtml("Data do Registro:"); ?></label>
        <input type="text" id="dtrjunta" name="dtrjunta" value="<?php echo getByTagName($cooperativa->tags,'dtrjunta');?>" >

        <br />

        <label for="nrinsest"><?php echo utf8ToHtml("Inscr. Estadual:"); ?></label>
        <input type="text" id="nrinsest" name="nrinsest" value="<?php echo getByTagName($cooperativa->tags,'nrinsest');?>" >

        <label for="nrinsmun"><?php echo utf8ToHtml("Inscr. Municipal:"); ?></label>
        <input type="text" id="nrinsmun" name="nrinsmun" value="<?php echo getByTagName($cooperativa->tags,'nrinsmun');?>" >

        <br />

        <label for="nrlivapl"><?php echo utf8ToHtml("Livro de aplica&ccedil;&otilde;es:"); ?></label>
        <input type="text" id="nrlivapl" name="nrlivapl" value="<?php echo getByTagName($cooperativa->tags,'nrlivapl');?>" >

        <label for="nrlivcap"><?php echo utf8ToHtml("Livro de Capital:"); ?></label>
        <input type="text" id="nrlivcap" name="nrlivcap" value="<?php echo getByTagName($cooperativa->tags,'nrlivcap');?>" >

        <br />

        <label for="nrlivdpv"><?php echo utf8ToHtml("Livro Dep. &agrave; vista:"); ?></label>
        <input type="text" id="nrlivdpv" name="nrlivdpv" value="<?php echo getByTagName($cooperativa->tags,'nrlivdpv');?>" >

        <label for="nrlivepr"><?php echo utf8ToHtml("Livro de Empr&eacute;stimos:"); ?></label>
        <input type="text" id="nrlivepr" name="nrlivepr" value="<?php echo getByTagName($cooperativa->tags,'nrlivepr');?>" >

    </fieldset>


    <fieldset id="fsetCompe" name="fsetCompe" style="padding:0px; margin:0px; padding-bottom:10px;">

        <legend>Compe</legend>

        <label for="cdbcoctl"><?php echo utf8ToHtml("Cod.COMPE Ailos:"); ?></label>
        <input type="text" id="cdbcoctl" name="cdbcoctl" value="<?php echo getByTagName($cooperativa->tags,'cdbcoctl');?>" >

        <label for="cdagectl"><?php echo utf8ToHtml("C&oacute;digo de Ag&ecirc;ncia:"); ?></label>
        <input type="text" id="cdagectl" name="cdagectl" value="<?php echo getByTagName($cooperativa->tags,'cdagectl');?>" >

        <label for="cddigage">-</label>
        <input type="text" id="cddigage" name="cddigage" value="<?php echo getByTagName($cooperativa->tags,'cddigage');?>" >

        <br />

        <label for="flgdsirc"><?php echo utf8ToHtml("SIRC:"); ?></label>
        <select  id="flgdsirc" name="flgdsirc" value="<?php echo getByTagName($cooperativa->tags,'flgdsirc'); ?>">
            <option value="0" <?php if (getByTagName($cooperativa->tags,'flgdsirc') == "0") { ?> selected <?php } ?> >Interior</option>
            <option value="1" <?php if (getByTagName($cooperativa->tags,'flgdsirc') == "1") { ?> selected <?php } ?> >Capital</option>
        </select>

        <label for="vllimpag">Limite m&aacute;x. - pgto sem autor.</label>
        <input type="text" id="vllimpag" name="vllimpag" value="<?php echo getByTagName($cooperativa->tags,'vllimpag');?>" >

        <br />

        <label for="flgopstr"><?php echo utf8ToHtml("Opera com SPB-STR:"); ?></label>
        <select  id="flgopstr" name="flgopstr" value="<?php echo getByTagName($cooperativa->tags,'flgopstr'); ?>">
            <option value="0" <?php if (getByTagName($cooperativa->tags,'flgopstr') == "0") { ?> selected <?php } ?> >N&atilde;o</option>
            <option value="1" <?php if (getByTagName($cooperativa->tags,'flgopstr') == "1") { ?> selected <?php } ?> >Sim</option>
        </select>

        <label for="iniopstr"><?php echo utf8ToHtml("Hor&aacute;rio:"); ?></label>
        <input type="text" id="iniopstr" name="iniopstr" value="<?php echo getByTagName($cooperativa->tags,'iniopstr');?>" >

        <label for="fimopstr"><?php echo utf8ToHtml("at&eacute;:"); ?></label>
        <input type="text" id="fimopstr" name="fimopstr" value="<?php echo getByTagName($cooperativa->tags,'fimopstr');?>" >

        <br />

        <label for="flgoppag"><?php echo utf8ToHtml("Opera com SPB-PAG:"); ?></label>
        <select  id="flgoppag" name="flgoppag" value="<?php echo getByTagName($cooperativa->tags,'flgoppag'); ?>">
            <option value="0" <?php if (getByTagName($cooperativa->tags,'flgoppag') == "0") { ?> selected <?php } ?> >N&atilde;o</option>
            <option value="1" <?php if (getByTagName($cooperativa->tags,'flgoppag') == "1") { ?> selected <?php } ?> >Sim</option>
        </select>

        <label for="inioppag"><?php echo utf8ToHtml("Hor&aacute;rio:"); ?></label>
        <input type="text" id="inioppag" name="inioppag" value="<?php echo getByTagName($cooperativa->tags,'inioppag');?>" >

        <label for="fimoppag"><?php echo utf8ToHtml("at&eacute;:"); ?></label>
        <input type="text" id="fimoppag" name="fimoppag" value="<?php echo getByTagName($cooperativa->tags,'fimoppag');?>" >

        <br />

        <label for="flgvrbol"><?php echo utf8ToHtml("Pagamento VR-Boleto:"); ?></label>
        <select  id="flgvrbol" name="flgvrbol" value="<?php echo getByTagName($cooperativa->tags,'flgvrbol'); ?>">
            <option value="0" <?php if (getByTagName($cooperativa->tags,'flgvrbol') == "0") { ?> selected <?php } ?> >N&atilde;o</option>
            <option value="1" <?php if (getByTagName($cooperativa->tags,'flgvrbol') == "1") { ?> selected <?php } ?> >Sim</option>
        </select>

        <label for="hhvrbini"><?php echo utf8ToHtml("Hor&aacute;rio:"); ?></label>
        <input type="text" id="hhvrbini" name="hhvrbini" value="<?php echo getByTagName($cooperativa->tags,'hhvrbini');?>" >

        <label for="hhvrbfim"><?php echo utf8ToHtml("at&eacute;:"); ?></label>
        <input type="text" id="hhvrbfim" name="hhvrbfim" value="<?php echo getByTagName($cooperativa->tags,'hhvrbfim');?>" >

        <br />

        <label for="cdagebcb"><?php echo utf8ToHtml("Ag&ecirc;ncia Bancoob:"); ?></label>
        <input type="text" id="cdagebcb" name="cdagebcb" value="<?php echo getByTagName($cooperativa->tags,'cdagebcb');?>" >

        <label for="cdagedbb"><?php echo utf8ToHtml("Ag&ecirc;ncia BB:"); ?></label>
        <input type="text" id="cdagedbb" name="cdagedbb" value="<?php echo getByTagName($cooperativa->tags,'cdagedbb');?>" >

        <br />

        <label for="cdageitg"><?php echo utf8ToHtml("Ag&ecirc;ncia ITG:"); ?></label>
        <input type="text" id="cdageitg" name="cdageitg" value="<?php echo getByTagName($cooperativa->tags,'cdageitg');?>" >

        <label for="cdcnvitg"><?php echo utf8ToHtml("Conv&ecirc;nio ITG:"); ?></label>
        <input type="text" id="cdcnvitg" name="cdcnvitg" value="<?php echo getByTagName($cooperativa->tags,'cdcnvitg');?>" >

        <br />

        <label for="cdmasitg"><?php echo utf8ToHtml("Massificado ITG:"); ?></label>
        <input type="text" id="cdmasitg" name="cdmasitg" value="<?php echo getByTagName($cooperativa->tags,'cdmasitg');?>" >

        <label for="dssigaut"><?php echo utf8ToHtml("Sigla na autentica&ccedil;&atilde;o:"); ?></label>
        <input type="text" id="dssigaut" name="dssigaut" value="<?php echo getByTagName($cooperativa->tags,'dssigaut');?>" >

        <br />

        <label for="nrctabbd"><?php echo utf8ToHtml("Conta conv&ecirc;nio BB:"); ?></label>
        <input type="text" id="nrctabbd" name="nrctabbd" value="<?php echo getByTagName($cooperativa->tags,'nrctabbd');?>" >

        <label for="nrctactl"><?php echo utf8ToHtml("Conta na Ailos:"); ?></label>
        <input type="text" id="nrctactl" name="nrctactl" value="<?php echo getByTagName($cooperativa->tags,'nrctactl');?>" >

        <br />

        <label for="nrctaitg"><?php echo utf8ToHtml("Conta integra&ccedil;&atilde;o:"); ?></label>
        <input type="text" id="nrctaitg" name="nrctaitg" value="<?php echo getByTagName($cooperativa->tags,'nrctaitg');?>" >

        <label for="nrctadbb"><?php echo utf8ToHtml("Conta conv&ecirc;nio no BB:"); ?></label>
        <input type="text" id="nrctadbb" name="nrctadbb" value="<?php echo getByTagName($cooperativa->tags,'nrctadbb');?>" >

        <br />

        <label for="nrctacmp"><?php echo utf8ToHtml("Conta Compe. Ailos:"); ?></label>
        <input type="text" id="nrctacmp" name="nrctacmp" value="<?php echo getByTagName($cooperativa->tags,'nrctacmp');?>" >

        <label for="nrdconta"><?php echo utf8ToHtml("Conta/dv:"); ?></label>
        <input type="text" id="nrdconta" name="nrdconta" value="<?php echo getByTagName($cooperativa->tags,'nrdconta');?>" >

        <br />

        <label for="flgcrmag"><?php echo utf8ToHtml("Cart&atilde;o magn&eacute;tico:"); ?></label>
        <select  id="flgcrmag" name="flgcrmag" value="<?php echo getByTagName($cooperativa->tags,'flgcrmag'); ?>">
            <option value="0" <?php if (getByTagName($cooperativa->tags,'flgcrmag') == "0") { ?> selected <?php } ?> >N&atilde;o</option>
            <option value="1" <?php if (getByTagName($cooperativa->tags,'flgcrmag') == "1") { ?> selected <?php } ?> >Sim</option>
        </select>

        <label for="qtdiaenl"><?php echo utf8ToHtml("Dep.TAA:"); ?></label>
        <input type="text" id="qtdiaenl" name="qtdiaenl" value="<?php echo getByTagName($cooperativa->tags,'qtdiaenl');?>" >

        <br />

        <label for="cdsinfmg"><?php echo utf8ToHtml("Inf.Chegada Cart&atilde;o:"); ?></label>
        <select  id="cdsinfmg" name="cdsinfmg" value="<?php echo getByTagName($cooperativa->tags,'cdsinfmg'); ?>">
            <option value="0" <?php if (getByTagName($cooperativa->tags,'cdsinfmg') == "0") { ?> selected <?php } ?> >N&atilde;o emite</option>
            <option value="1" <?php if (getByTagName($cooperativa->tags,'cdsinfmg') == "1") { ?> selected <?php } ?> >S&oacute na chegada</option>
            <option value="2" <?php if (getByTagName($cooperativa->tags,'cdsinfmg') == "2") { ?> selected <?php } ?> >At&eacute; a retirada</option>
        </select>

        <label for="taamaxer"><?php echo utf8ToHtml("Max.Tentativas TAA:"); ?></label>
        <input type="text" id="taamaxer" name="taamaxer" value="<?php echo getByTagName($cooperativa->tags,'taamaxer');?>" >

				<br />

        <label for="flintcdc"><?php echo utf8ToHtml("Conv&ecirc;nio CDC:"); ?></label>
        <select  id="flintcdc" name="flintcdc" value="<?php echo getByTagName($cooperativa->tags,'cdsinfmg'); ?>">
            <option value="0" <?php if (getByTagName($cooperativa->tags,'flintcdc') == "0") { ?> selected <?php } ?> >N&atilde;o</option>
            <option value="1" <?php if (getByTagName($cooperativa->tags,'flintcdc') == "1") { ?> selected <?php } ?> >Sim</option>
        </select>
				
        <label for="tpcdccop"><?php echo utf8ToHtml("Tipo CDC:"); ?></label>
        <select  id="tpcdccop" name="tpcdccop" value="<?php echo getByTagName($cooperativa->tags,'cdsinfmg'); ?>">
            <option value="1" <?php if (getByTagName($cooperativa->tags,'tpcdccop') == "1") { ?> selected <?php } ?> >Simples</option>
            <option value="2" <?php if (getByTagName($cooperativa->tags,'tpcdccop') == "2") { ?> selected <?php } ?> >Compartilhado</option>
        </select>

    </fieldset>


</form>

<form id="frmConsulta3" name="frmConsulta3" class="formulario" style="display:none;">

    <fieldset id="fsetComite" name="fsetComite" style="padding:0px; margin:0px; padding-bottom:10px;">

        <legend>Comit&ecirc;</legend>

        <label for="flgcmtlc"><?php echo utf8ToHtml("Possui Comit&ecirc; Local:"); ?></label>
        <select  id="flgcmtlc" name="flgcmtlc" value="<?php echo getByTagName($cooperativa->tags,'flgcmtlc'); ?>">
            <option value="0" <?php if (getByTagName($cooperativa->tags,'flgcmtlc') == "0") { ?> selected <?php } ?> >N&atilde;o</option>
            <option value="1" <?php if (getByTagName($cooperativa->tags,'flgcmtlc') == "1") { ?> selected <?php } ?> >Sim</option>
        </select>

        <label for="vllimapv"><?php echo utf8ToHtml("Valor Limite Al&ccedil;ada Geral:"); ?></label>
        <input type="text" id="vllimapv" name="vllimapv" value="<?php echo getByTagName($cooperativa->tags,'vllimapv');?>" >

        <br />

        <label for="cdcrdarr"><?php echo utf8ToHtml("Creden.Arrecada&ccedil;&otilde;s:"); ?></label>
        <input type="text" id="cdcrdarr" name="cdcrdarr" value="<?php echo getByTagName($cooperativa->tags,'cdcrdarr');?>" >

        <label for="cdagsede"><?php echo utf8ToHtml("Sede INSS:"); ?></label>
        <input type="text" id="cdagsede" name="cdagsede" value="<?php echo getByTagName($cooperativa->tags,'cdagsede');?>" >

        <br />

        <label for="vlmaxcen"><?php echo utf8ToHtml("Valor Max.Central:"); ?></label>
        <input type="text" id="vlmaxcen" name="vlmaxcen" value="<?php echo getByTagName($cooperativa->tags,'vlmaxcen');?>" >

        <label for="vlmaxleg"><?php echo utf8ToHtml("Valor Max.Legal:"); ?></label>
        <input type="text" id="vlmaxleg" name="vlmaxleg" value="<?php echo getByTagName($cooperativa->tags,'vlmaxleg');?>" >

        <br />

        <label for="vlmaxutl"><?php echo utf8ToHtml("Valor Max.Utilizado:"); ?></label>
        <input type="text" id="vlmaxutl" name="vlmaxutl" value="<?php echo getByTagName($cooperativa->tags,'vlmaxutl');?>" >

        <label for="vlcnsscr"><?php echo utf8ToHtml("Valor consulta SCR:"); ?></label>
        <input type="text" id="vlcnsscr" name="vlcnsscr" value="<?php echo getByTagName($cooperativa->tags,'vlcnsscr');?>" >

        <br />

        <label for="vllimmes"><?php echo utf8ToHtml("Limite Disp. p/ Empr&eacute;stimo:"); ?></label>
        <input type="text" id="vllimmes" name="vllimmes" value="<?php echo getByTagName($cooperativa->tags,'vllimmes');?>" >

        <br />

        <label for="nrctabol"><?php echo utf8ToHtml("Conta Coope Ems. Boleto:"); ?></label>
        <input type="text" id="nrctabol" name="nrctabol" value="<?php echo getByTagName($cooperativa->tags,'nrctabol');?>" >

        <label for="cdlcrbol"><?php echo utf8ToHtml("Linha Cr&eacute;dito Ems. Boleto:"); ?></label>
        <input type="text" id="cdlcrbol" name="cdlcrbol" value="<?php echo getByTagName($cooperativa->tags,'cdlcrbol');?>" >

    </fieldset>

    <fieldset id="fsetContrato" name="fsetContrato" style="padding:0px; margin:0px; padding-bottom:10px;">

        <legend>Cl&aacute;usula do contrato C/C e C/I</legend>

        <textarea id='dsclactr' name="dsclactr"><?php echo getByTagName($cooperativa->tags,'dsclactr') ?></textarea>

    </fieldset>

    <fieldset id="fsetAdesao" name="fsetAdesao" style="padding:0px; margin:0px; padding-bottom:10px;">

        <legend>Termo de ades&atilde;o aos servi&ccedil;os de cobran&ccedil;a banc&aacute;ria</legend>

        <textarea id='dsclaccb' name="dsclaccb"><?php echo getByTagName($cooperativa->tags,'dsclaccb') ?></textarea>

    </fieldset>


    <fieldset id="fsetProcesso" name="fsetProcesso" style="padding:0px; margin:0px; padding-bottom:10px;">

        <legend>Verifica&ccedil;&atilde;o do processo</legend>

        <label for="dsdircop"><?php echo utf8ToHtml("Diret&oacute;rio:"); ?></label>
        <input type="text" id="dsdircop" name="dsdircop" value="<?php echo getByTagName($cooperativa->tags,'dsdircop');?>" >

        <br />

        <label for="nmdireto"><?php echo utf8ToHtml("Diret&oacute;rio:"); ?></label>
        <input type="text" id="nmdireto" name="nmdireto" value="<?php echo getByTagName($cooperativa->tags,'nmdireto');?>" >

        <br />

        <label for="flgdopgd"><?php echo utf8ToHtml("Participa do progrid:"); ?></label>
        <select  id="flgdopgd" name="flgdopgd" value="<?php echo getByTagName($cooperativa->tags,'flgdopgd'); ?>">
            <option value="0" <?php if (getByTagName($cooperativa->tags,'flgdopgd') == "0") { ?> selected <?php } ?> >N&atilde;o</option>
            <option value="1" <?php if (getByTagName($cooperativa->tags,'flgdopgd') == "1") { ?> selected <?php } ?> >Sim</option>
        </select>

        <br />

        <label for="hrproces"><?php echo utf8ToHtml("Hora Inicial:"); ?></label>
        <input type="text" id="hrproces" name="hrproces" value="<?php echo getByTagName($cooperativa->tags,'hrproces');?>" >

        <label for="hrfinprc"><?php echo utf8ToHtml("Hora Final:"); ?></label>
        <input type="text" id="hrfinprc" name="hrfinprc" value="<?php echo getByTagName($cooperativa->tags,'hrfinprc');?>" >

        <br />

        <label for="dsnotifi"><?php echo utf8ToHtml("Nota:"); ?></label>
        <textarea id='dsnotifi' name="dsnotifi"><?php echo getByTagName($cooperativa->tags,'dsnotifi'); ?> </textarea>

    </fieldset>

</form>

<form id="frmConsulta4" name="frmConsulta4" class="formulario" style="display:none;">


    <fieldset id="fsetCoban" name="fsetCoban" style="padding:0px; margin:0px; padding-bottom:10px;">

        <legend>Coban</legend>

        <label for="nrconven"><?php echo utf8ToHtml("Conv&ecirc;nio:"); ?></label>
        <input type="text" id="nrconven" name="nrconven" value="<?php echo getByTagName($cooperativa->tags,'nrconven');?>" >

        <label for="nrversao"><?php echo utf8ToHtml("Vers&atilde;o:"); ?></label>
        <input type="text" id="nrversao" name="nrversao" value="<?php echo getByTagName($cooperativa->tags,'nrversao');?>" >

        <br />

        <label for="vldataxa"><?php echo utf8ToHtml("Tarifa Pagto.:"); ?></label>
        <input type="text" id="vldataxa" name="vldataxa" value="<?php echo getByTagName($cooperativa->tags,'vldataxa');?>" >

        <label for="vltxinss"><?php echo utf8ToHtml("Tarifa INSS:"); ?></label>
        <input type="text" id="vltxinss" name="vltxinss" value="<?php echo getByTagName($cooperativa->tags,'vltxinss');?>" >

        <br />

        <label for="flgargps"><?php echo utf8ToHtml("Arrecada GPS:"); ?></label>
        <select  id="flgargps" name="flgargps" value="<?php echo getByTagName($cooperativa->tags,'flgargps'); ?>">
            <option value="0" <?php if (getByTagName($cooperativa->tags,'flgargps') == "0") { ?> selected <?php } ?> >N&atilde;o</option>
            <option value="1" <?php if (getByTagName($cooperativa->tags,'flgargps') == "1") { ?> selected <?php } ?> >Sim</option>
        </select>

    </fieldset>

    <fieldset id="fsetDDA" name="fsetDDA" style="padding:0px; margin:0px; padding-bottom:10px;">

        <legend>DDA</legend>

        <label for="dtctrdda"><?php echo utf8ToHtml("Data do Contrato:"); ?></label>
        <input type="text" id="dtctrdda" name="dtctrdda" value="<?php echo getByTagName($cooperativa->tags,'dtctrdda');?>" >

        <label for="nrctrdda"><?php echo utf8ToHtml("Nr.:"); ?></label>
        <input type="text" id="nrctrdda" name="nrctrdda" value="<?php echo getByTagName($cooperativa->tags,'nrctrdda');?>" >

        <br />

        <label for="idlivdda"><?php echo utf8ToHtml("Livro:"); ?></label>
        <input type="text" id="idlivdda" name="idlivdda" value="<?php echo getByTagName($cooperativa->tags,'idlivdda');?>" >

        <label for="nrfoldda"><?php echo utf8ToHtml("Folha:"); ?></label>
        <input type="text" id="nrfoldda" name="nrfoldda" value="<?php echo getByTagName($cooperativa->tags,'nrfoldda');?>" >

        <br />

        <label for="dslocdda"><?php echo utf8ToHtml("Local do Registro:"); ?></label>
        <input type="text" id="dslocdda" name="dslocdda" value="<?php echo getByTagName($cooperativa->tags,'dslocdda');?>" >

        <br />

        <label for="dsciddda"><?php echo utf8ToHtml("Cidade:"); ?></label>
        <input type="text" id="dsciddda" name="dsciddda" value="<?php echo getByTagName($cooperativa->tags,'dsciddda');?>" >

    </fieldset>

    <fieldset id="fsetCobReg" name="fsetCobReg" style="padding:0px; margin:0px; padding-bottom:10px;">

        <legend>Cobran&ccedil;a registrada</legend>

        <label for="dtregcob"><?php echo utf8ToHtml("Data do Contrato:"); ?></label>
        <input type="text" id="dtregcob" name="dtregcob" value="<?php echo getByTagName($cooperativa->tags,'dtregcob');?>" >

        <label for="idregcob"><?php echo utf8ToHtml("Nr.:"); ?></label>
        <input type="text" id="idregcob" name="idregcob" value="<?php echo getByTagName($cooperativa->tags,'idregcob');?>" >

        <br />

        <label for="idlivcob"><?php echo utf8ToHtml("Livro:"); ?></label>
        <input type="text" id="idlivcob" name="idlivcob" value="<?php echo getByTagName($cooperativa->tags,'idlivcob');?>" >

        <label for="nrfolcob"><?php echo utf8ToHtml("Folha:"); ?></label>
        <input type="text" id="nrfolcob" name="nrfolcob" value="<?php echo getByTagName($cooperativa->tags,'nrfolcob');?>" >

        <br />

        <label for="dsloccob"><?php echo utf8ToHtml("Local do Registro:"); ?></label>
        <input type="text" id="dsloccob" name="dsloccob" value="<?php echo getByTagName($cooperativa->tags,'dsloccob');?>" >

        <br />

        <label for="dscidcob"><?php echo utf8ToHtml("Cidade:"); ?></label>
        <input type="text" id="dscidcob" name="dscidcob" value="<?php echo getByTagName($cooperativa->tags,'dscidcob');?>" >

    </fieldset>


</form>

<form id="frmConsulta5" name="frmConsulta5" class="formulario" style="display:none;">

    <fieldset id="fsetCentralRisco" name="fsetCentralRisco" style="padding:0px; margin:0px; padding-bottom:10px;">

        <legend>Central de risco</legend>

        <label for="dsnomscr"><?php echo utf8ToHtml("Nome do Respons&aacute;vel:"); ?></label>
        <input type="text" id="dsnomscr" name="dsnomscr" value="<?php echo getByTagName($cooperativa->tags,'dsnomscr');?>" >

        <br />

        <label for="dsemascr"><?php echo utf8ToHtml("E-mail do Respons&aacute;vel:"); ?></label>
        <input type="text" id="dsemascr" name="dsemascr" value="<?php echo getByTagName($cooperativa->tags,'dsemascr');?>" >

        <br />

        <label for="dstelscr"><?php echo utf8ToHtml("Telefone do Respons&aacute;vel:"); ?></label>
        <input type="text" id="dstelscr" name="dstelscr" value="<?php echo getByTagName($cooperativa->tags,'dstelscr');?>" >

    </fieldset>

    <fieldset id="fsetSicredi" name="fsetSicredi" style="padding:0px; margin:0px; padding-bottom:10px;">

        <legend>SICREDI</legend>

        <label for="cdagesic"><?php echo utf8ToHtml("Ag&ecirc;ncia Sicredi:"); ?></label>
        <input type="text" id="cdagesic" name="cdagesic" value="<?php echo getByTagName($cooperativa->tags,'cdagesic');?>" >

        <label for="nrctasic"><?php echo utf8ToHtml("Conta Sicredi:"); ?></label>
        <input type="text" id="nrctasic" name="nrctasic" value="<?php echo getByTagName($cooperativa->tags,'nrctasic');?>" >

        <br />

        <label for="cdcrdins"><?php echo utf8ToHtml("Creden. Arrecada&ccedil;&otilde;es:"); ?></label>
        <input type="text" id="cdcrdins" name="cdcrdins" value="<?php echo getByTagName($cooperativa->tags,'cdcrdins');?>" >

        <label for="vltarsic"><?php echo utf8ToHtml("Tarifa INSS:"); ?></label>
        <input type="text" id="vltarsic" name="vltarsic" value="<?php echo getByTagName($cooperativa->tags,'vltarsic');?>" >

        <br />

        <label for="vltardrf"><?php echo utf8ToHtml("Tarifa Tributo Federal:"); ?></label>
        <input type="text" id="vltardrf" name="vltardrf" value="<?php echo getByTagName($cooperativa->tags,'vltardrf');?>" >

        <br />

        <label for="vltfcxsb"><?php echo utf8ToHtml("Tarifa GPS Caixa Sem Cod.Barras:"); ?></label>
        <input type="text" id="vltfcxsb" name="vltfcxsb" value="<?php echo getByTagName($cooperativa->tags,'vltfcxsb');?>" >

        <label for="vltfcxcb"><?php echo utf8ToHtml("Tarifa GPS Caixa Com Cod.Barras:"); ?></label>
        <input type="text" id="vltfcxcb" name="vltfcxcb" value="<?php echo getByTagName($cooperativa->tags,'vltfcxcb');?>" >

        <br />

        <label for="vlrtrfib"><?php echo utf8ToHtml("Tarifa GPS Internet Banking/Mobile:"); ?></label>
        <input type="text" id="vlrtrfib" name="vlrtrfib" value="<?php echo getByTagName($cooperativa->tags,'vlrtrfib');?>" >

        <label for="hrinigps"><?php echo utf8ToHtml("Hor&aacute;rio Pagamento GPS:"); ?></label>
        <input type="text" id="hrinigps" name="hrinigps" value="<?php echo getByTagName($cooperativa->tags,'hrinigps');?>" >

        <label for="hrfimgps"><?php echo utf8ToHtml("at&eacute;:"); ?></label>
        <input type="text" id="hrfimgps" name="hrfimgps" value="<?php echo getByTagName($cooperativa->tags,'hrfimgps');?>" >

        <label for="hrlimsic"><?php echo utf8ToHtml("Hor&aacute;rio Limite Pagamento:"); ?></label>
        <input type="text" id="hrlimsic" name="hrlimsic" value="<?php echo getByTagName($cooperativa->tags,'hrlimsic');?>" >


    </fieldset>

    <fieldset id="fsetBancoob" name="fsetBancoob" style="padding:0px; margin:0px; padding-bottom:10px;">

        <legend>BANCOOB</legend>

        <label for="nrctabcb"><?php echo utf8ToHtml("Conta Bancoob:"); ?></label>
        <input type="text" id="nrctabcb" name="nrctabcb" value="<?php echo getByTagName($cooperativa->tags,'nrctabcb');?>" >
        
        <label for="nrouvbcb"><?php echo utf8ToHtml("Telefone Ouvidoria:"); ?></label>
        <input type="text" id="nrouvbcb" name="nrouvbcb" value="<?php echo getByTagName($cooperativa->tags,'nrouvbcb');?>" >
                
        <br />
        <label for="vltarbcb"><?php echo utf8ToHtml("Tarifa Arrecadação:"); ?></label>
        <input type="text" id="vltarbcb" name="vltarbcb" value="<?php echo getByTagName($cooperativa->tags,'vltarbcb');?>" >
        
        <label for="nrsacbcb"><?php echo utf8ToHtml("SAC:"); ?></label>
        <input type="text" id="nrsacbcb" name="nrsacbcb" value="<?php echo getByTagName($cooperativa->tags,'nrsacbcb');?>" >        
        
        <br />
        
        <?php // campo vlgarbcb será exibido apenas na cecred 
        if (getByTagName($cooperativa->tags,'cdcooper') == 3 ){ ?>
            
            <label for="vlgarbcb"><?php echo utf8ToHtml("Garantia para arrecadação de convênios:"); ?></label>
            <input type="text" id="vlgarbcb" name="vlgarbcb" value="<?php echo getByTagName($cooperativa->tags,'vlgarbcb');?>" >
            
            <br />
        <?php }?>

    </fieldset> 
    
    <fieldset id="fsetSangria" name="fsetSangria" style="padding:0px; margin:0px; padding-bottom:10px;">

        <!-- Alterado legend de 'Sangria de CAIXA' para 'Parâmetros Caixa Online' - SCTASK0027519 (Mateus Z / Mouts)  -->
        <legend>Par&acirc;metros Caixa Online</legend>

        <!-- Criado novo campo 'Horário mínimo login' - SCTASK0027519 (Mateus Z / Mouts)  -->
        <label for="hrinicxa"><?php echo utf8ToHtml("Horário mínimo login:"); ?></label>
        <input type="text" id="hrinicxa" name="hrinicxa" value="<?php echo getByTagName($cooperativa->tags,'hrinicxa');?>" >

        <!-- Alterado label de 'Intervalo de Tempo' para 'Intervalo de Tempo Sangria' - SCTASK0027519 (Mateus Z / Mouts)  -->
        <label for="qttmpsgr"><?php echo utf8ToHtml("Intervalo de Tempo Sangria:"); ?></label>
        <input type="text" id="qttmpsgr" name="qttmpsgr" value="<?php echo getByTagName($cooperativa->tags,'qttmpsgr');?>" >

    </fieldset>

    <fieldset id="fsetServicos" name="fsetServicos" style="padding:0px; margin:0px; padding-bottom:10px;">

        <legend>Servi&ccedil;os ofertados</legend>

        <label for="flgkitbv"><?php echo utf8ToHtml("Oferece Kit Boas Vinda:"); ?></label>
        <select  id="flgkitbv" name="flgkitbv" value="<?php echo getByTagName($cooperativa->tags,'flgkitbv'); ?>">
            <option value="0" <?php if (getByTagName($cooperativa->tags,'flgkitbv') == "0") { ?> selected <?php } ?> >N&atilde;o</option>
            <option value="1" <?php if (getByTagName($cooperativa->tags,'flgkitbv') == "1") { ?> selected <?php } ?> >Sim</option>
        </select>

    </fieldset>

    <fieldset id="fsetDebFacil" name="fsetDebFacil" style="padding:0px; margin:0px; padding-bottom:10px;">

        <legend>D&eacute;bito f&aacute;cil</legend>

        <label for="qtdiasus"><?php echo utf8ToHtml("Prazo m&aacute;ximo para suspens&atilde;o do d&eacute;bito (dias):"); ?></label>
        <input type="text" id="qtdiasus" name="qtdiasus" value="<?php echo getByTagName($cooperativa->tags,'qtdiasus');?>" >

        <br />

        <label for="hriniatr"><?php echo utf8ToHtml("Hor&aacute;rio para autoriza&ccedil;&atilde;o do d&eacute;bito:"); ?></label>
        <input type="text" id="hriniatr" name="hriniatr" value="<?php echo getByTagName($cooperativa->tags,'hriniatr');?>" >

        <label for="hrfimatr"><?php echo utf8ToHtml("&agrave;s:"); ?></label>
        <input type="text" id="hrfimatr" name="hrfimatr" value="<?php echo getByTagName($cooperativa->tags,'hrfimatr');?>" >

        <br />

        <label for="flgofatr"><?php echo utf8ToHtml("Oferta pro ativa"); ?></label>
        <select  id="flgofatr" name="flgofatr" value="<?php echo getByTagName($cooperativa->tags,'flgofatr'); ?>">
            <option value="0" <?php if (getByTagName($cooperativa->tags,'flgofatr') == "0") { ?> selected <?php } ?> >N&atilde;o</option>
            <option value="1" <?php if (getByTagName($cooperativa->tags,'flgofatr') == "1") { ?> selected <?php } ?> >Sim</option>
        </select>

    </fieldset>

    <fieldset id="fsetSerasa" name="fsetSerasa" style="padding:0px; margin:0px; padding-bottom:10px;">

        <legend>Serasa</legend>

        <label for="cdcliser"><?php echo utf8ToHtml("Codigo na SERASA:"); ?></label>
        <input type="text" id="cdcliser" name="cdcliser" value="<?php echo getByTagName($cooperativa->tags,'cdcliser');?>" >

    </fieldset>

    <fieldset id="fsetCotas" name="fsetCotas" style="padding:0px; margin:0px; padding-bottom:10px;">

        <legend>Plano de cotas</legend>

        <label for="vlmiplco"><?php echo utf8ToHtml("Valor minimo para contratacao:"); ?></label>
        <input type="text" id="vlmiplco" name="vlmiplco" value="<?php echo getByTagName($cooperativa->tags,'vlmiplco');?>" >

        <br />

        <label for="vlmidbco"><?php echo utf8ToHtml("Valor minimo para debito de cotas:"); ?></label>
        <input type="text" id="vlmidbco" name="vlmidbco" value="<?php echo getByTagName($cooperativa->tags,'vlmidbco');?>" >

    </fieldset>

    <fieldset id="fsetGravames" name="fsetGravames" style="padding:0px; margin:0px; padding-bottom:10px;">

        <legend>Gravames</legend>

        <label for="cdfingrv"><?php echo utf8ToHtml("C&oacute;digo da financeira:"); ?></label>
        <input type="text" id="cdfingrv" name="cdfingrv" value="<?php echo getByTagName($cooperativa->tags,'cdfingrv');?>" >

        <label for="cdsubgrv"><?php echo utf8ToHtml("Subc&oacute;digo do usu&aacute;rio:"); ?></label>
        <input type="text" id="cdsubgrv" name="cdsubgrv" value="<?php echo getByTagName($cooperativa->tags,'cdsubgrv');?>" >

        <br />

        <label for="cdloggrv"><?php echo utf8ToHtml("Login do usu&aacute;rio:"); ?></label>
        <input type="text" id="cdloggrv" name="cdloggrv" value="<?php echo getByTagName($cooperativa->tags,'cdloggrv');?>" >

    </fieldset>

    <fieldset id="fsetTarifa" name="fsetTarifa" style="padding:0px; margin:0px; padding-bottom:10px;">

        <legend>Tarifa</legend>

        <label for="flsaqpre"><?php echo utf8ToHtml("Saque Presencial:"); ?></label>
        <select  id="flsaqpre" name="flsaqpre" value="<?php echo getByTagName($cooperativa->tags,'flsaqpre'); ?>">
            <option value="0" <?php if (getByTagName($cooperativa->tags,'flsaqpre') == "0") { ?> selected <?php } ?> >N&atilde;o Isentar</option>
            <option value="1" <?php if (getByTagName($cooperativa->tags,'flsaqpre') == "1") { ?> selected <?php } ?> >Isentar</option>
        </select>

    </fieldset>

    <fieldset id="fsetPacoteTarifa" name="fsetPacoteTarifa" style="padding:0px; margin:0px; padding-bottom:10px;">

        <legend>Pacote de tarifas</legend>

        <label for="permaxde"><?php echo utf8ToHtml("Percentual m&aacute;ximo de desconto manual:"); ?></label>
        <input type="text" id="permaxde" name="permaxde" value="<?php echo getByTagName($cooperativa->tags,'permaxde');?>" >

        <br />

        <label for="qtmaxmes"><?php echo utf8ToHtml("Qtd. m&aacute;xima meses de desconto:"); ?></label>
        <input type="text" id="qtmaxmes" name="qtmaxmes" value="<?php echo getByTagName($cooperativa->tags,'qtmaxmes');?>" >

        <label for="flrecpct"><?php echo utf8ToHtml("Permitir reciprocidade:"); ?></label>
        <select  id="flrecpct" name="flrecpct" value="<?php echo getByTagName($cooperativa->tags,'flrecpct'); ?>">
            <option value="0" <?php if (getByTagName($cooperativa->tags,'flrecpct') == "0") { ?> selected <?php } ?> >N&atilde;o</option>
            <option value="1" <?php if (getByTagName($cooperativa->tags,'flrecpct') == "1") { ?> selected <?php } ?> >Sim</option>
        </select>

    </fieldset>

    <fieldset id="fsetAutoAtendimento" name="fsetAutoAtendimento" style="padding:0px; margin:0px; padding-bottom:10px;">

        <legend>Auto Atendimento</legend>

        <label for="qtmeatel"><?php echo utf8ToHtml("Qtd. meses para atualiza&ccedil;&atilde;o do telefone:"); ?></label>
        <input type="text" id="qtmeatel" name="qtmeatel" value="<?php echo getByTagName($cooperativa->tags,'qtmeatel');?>" >

    </fieldset>

    <fieldset id="fsetAtendimento" name="fsetAtendimento" style="padding:0px; margin:0px; padding-bottom:10px;">

        <legend>Hor&aacute;rios de atendimento</legend>

        <label for="hrinisac"><?php echo utf8ToHtml("SAC:"); ?></label>
        <input type="text" id="hrinisac" name="hrinisac" value="<?php echo getByTagName($cooperativa->tags,'hrinisac');?>" >

        <label for="hrfimsac"><?php echo utf8ToHtml("&agrave;s:"); ?></label>
        <input type="text" id="hrfimsac" name="hrfimsac" value="<?php echo getByTagName($cooperativa->tags,'hrfimsac');?>" >

        <br />

        <label for="hriniouv"><?php echo utf8ToHtml("OUVIDORIA:"); ?></label>
        <input type="text" id="hriniouv" name="hriniouv" value="<?php echo getByTagName($cooperativa->tags,'hriniouv');?>" >

        <label for="hrfimouv"><?php echo utf8ToHtml("&agrave;s:"); ?></label>
        <input type="text" id="hrfimouv" name="hrfimouv" value="<?php echo getByTagName($cooperativa->tags,'hrfimouv');?>" >

        <br style="clear:both" />


    </fieldset>

    <fieldset id="fsetAssembleias" name="fsetAssembleias" style="padding:0px; margin:0px; padding-bottom:10px;">

        <legend>Novo Modelo de Representa&ccedil;&atilde;o do Quadro Social</legend>

      <label for="flgrupos">
        <?php echo utf8ToHtml("Situa&ccedil;&atilde;o:"); ?>
      </label>
      <select  id="flgrupos" name="flgrupos" value=""
        <?php echo getByTagName($cooperativa->tags,'flgrupos'); ?>">
        <option value="0"
          <?php if (getByTagName($cooperativa->tags,'flgrupos') == "0") { ?> selected <?php } ?> >INATIVO
        </option>
        <option value="1"
          <?php if (getByTagName($cooperativa->tags,'flgrupos') == "1") { ?> selected <?php } ?> >ATIVO
        </option>
      </select>

    </fieldset>

</form>

<div id="divBotoesConsulta" style='text-align:center; margin-bottom: 10px; margin-top: 10px; display:none;' >

    <a href="#" class="botao" id="btVoltar">Voltar</a>
    <a href="#" class="botao" id="btProsseguir" >Prosseguir</a>
    <a href="#" class="botao" id="btConcluir" >Concluir</a>

</div>

<script type="text/javascript">

    $('#divBotoes').css('display','none');
    $('#divTabela').css('display','block');
    formataFormularioConsulta();

</script>

