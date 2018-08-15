<? 
    /*!
     * FONTE        : form_cabecalho.php
     * CRIAÇÃO      : Odirlei Busana(AMcom)
     * DATA CRIAÇÃO : Novembro/2017 
     * OBJETIVO     : Cabecalho tela HISPES
     * --------------
     * ALTERAÇÕES   :
     * --------------
     *
     */	
 
    $xml = "<Root>";
    $xml .= " <Dados>";
    $xml .= "   <cdcooper>0</cdcooper>";
    $xml .= "   <flgativo>1</flgativo>";
    $xml .= " </Dados>";
    $xml .= "</Root>";

    $xmlResult = mensageria($xml, "CADA0001", "LISTA_COOPERATIVAS", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
    $xmlObj = getObjectXML($xmlResult);

    if (strtoupper($xmlObj->roottag->tags[0]->name) == "ERRO") {
        $msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
        if ($msgErro == "") {
            $msgErro = $xmlObj->roottag->tags[0]->cdata;
        }

        exibeErroNew($msgErro);
        exit();
    }

    $registros = $xmlObj->roottag->tags[0]->tags;

    function exibeErroNew($msgErro) {
        echo 'hideMsgAguardo();';
        echo 'showError("error","' . $msgErro . '","Alerta - Ayllos","desbloqueia()");';
        exit();
    }
 
 
?>
<form name="frmCab" id="frmCab" class="formulario cabecalho">
	<fieldset>
		<legend>Filtros</legend>
        
        <div id="divCooper" style="left-padding:2x">
            <label for="nmrescop"><? echo utf8ToHtml('Cooperativa:') ?></label>
            <select id="nmrescop" name="nmrescop">            
            <?php
            foreach ($registros as $r) {
                
                if ( getByTagName($r->tags, 'cdcooper') <> '' ) {
            ?>
                <option value="<?= getByTagName($r->tags, 'cdcooper'); ?>" 
                        <?  if (getByTagName($r->tags, 'cdcooper')== $glbvars['cdcooper']){ echo ' selected';} ?> > <?= getByTagName($r->tags, 'nmrescop'); ?></option> 
                
            <?php
                }
            }
            ?>
            </select>
        </div>
        
        <input name="idpessoa" id="idpessoa" type="hidden" />
        <input name="tppessoa" id="tppessoa" type="hidden" />
        
        <br>
        <label for="nrdconta">Conta/dv:</label>
        <input name="nrdconta" id="nrdconta" type="text" />
        <a><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif" /></a>        
        
        <label for="idseqttl">Seq.Titular:</label>
        <select id="idseqttl" name="idseqttl">
            <option value="1"></option>
        </select>
        
        <br>
        <label for="nrcpfcgc">CPF/CNPJ:</label>
        <input name="nrcpfcgc" id="nrcpfcgc" type="text" />
        
        <label for="nmpessoa">Nome da pessoa:</label>
        <input name="nmpessoa" id="nmpessoa" type="text" />


        <input type="image" src="<? echo $UrlImagens; ?>/botoes/ok.gif" onClick="carregaResumo();return false;" />					
	</fieldset>
</form>
