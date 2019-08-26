<?php
/*!
 * FONTE        : salvar_dados.php
 * CRIAÇÃO      : Michel Candido Gati Tecnologia
 * DATA CRIAÇÃO : 21/08/2013
 *
 * ALTERACAO    : 08/07/2015 - Adicionado validacao de campos referente a dias da tela de tarifas. (Jorge/Elton) - Emergencial
 *                18/05/2016 - Adicionado o campo dtlimdeb. (Jaison/Marcos)
 *				  20/07/2016 - Corrigi os erros de utilizacao de variaveis nao declaradas. SD 471925 (Carlos R.)	
 *
 */

    session_start();
    require_once('../../includes/config.php');
    require_once('../../includes/funcoes.php');
    require_once('../../includes/controla_secao.php');
    require_once('../../class/xmlfile.php');
    isPostMethod();

	$nmresemp = ( isset($_POST["nmresemp"]) ) ? substr($_POST["nmresemp"],0,15) : '';
    $nmbairro = ( isset($_POST["nmbairro"]) ) ? substr($_POST["nmbairro"],0,15) : '';
    $nrcepend = ( isset($_POST["nrcepend"]) ) ? str_replace(array('-','.'),'',$_POST["nrcepend"]) : '';
    $nrdocnpj = ( isset($_POST["nrdocnpj"]) ) ? trim(str_replace(array('-','.','/'),'',$_POST["nrdocnpj"])) : '';
    $vltrfsal = ( isset($_POST["vltrfsal"]) ) ? str_replace(array('.'),',',$_POST["vltrfsal"]) : '';

    $opcao    = ( isset($_POST["cddopcao"]) ) ? $_POST["cddopcao"] : '';
    $cdempres = ( isset($_POST["cdempres"]) ) ? $_POST["cdempres"] : '';
    $nmextemp = ( isset($_POST["nmextemp"]) ) ? $_POST["nmextemp"] : '';
    $idtpempr = ( isset($_POST["idtpempr"]) ) ? $_POST["idtpempr"] : ''; /* aqui */
    $nrdconta = ( isset($_POST["nrdconta"]) ) ? $_POST["nrdconta"] : ''; /* aqui */
    $nmcontat = ( isset($_POST["nmcontat"]) ) ? $_POST["nmcontat"] : ''; /* aqui */
    $dsendemp = ( isset($_POST["dsendemp"]) ) ? $_POST["dsendemp"] : '';
    $nrendemp = ( isset($_POST["nrendemp"]) ) ? $_POST["nrendemp"] : '';
    $dscomple = ( isset($_POST["dscomple"]) ) ? $_POST["dscomple"] : '';
    $nmcidade = ( isset($_POST["nmcidade"]) ) ? $_POST["nmcidade"] : '';
    $cdufdemp = ( isset($_POST["cdufdemp"]) ) ? $_POST["cdufdemp"] : '';
    $nrfonemp = ( isset($_POST["nrfonemp"]) ) ? $_POST["nrfonemp"] : '';
    $nrfaxemp = ( isset($_POST["nrfaxemp"]) ) ? $_POST["nrfaxemp"] : '';
    $dsdemail = ( isset($_POST["dsdemail"]) ) ? $_POST["dsdemail"] : '';
    $ddmesnov = ( isset($_POST["ddmesnov"]) ) ? $_POST["ddmesnov"] : '';
    $ddpgtmes = ( isset($_POST["ddpgtmes"]) ) ? $_POST["ddpgtmes"] : '';
    $ddpgthor = ( isset($_POST["ddpgthor"]) ) ? $_POST["ddpgthor"] : '';
    $flgpgtib = ( isset($_POST["flgpgtib"]) ) ? $_POST["flgpgtib"] : ''; /* aqui */
    $cdcontar = ( isset($_POST["cdcontar"]) ) ? $_POST["cdcontar"] : ''; /* aqui */
    $vllimfol = ( isset($_POST["vllimfol"]) ) ? $_POST["vllimfol"] : ''; /* aqui */
    $nrlotfol = ( isset($_POST["nrlotfol"]) ) ? $_POST["nrlotfol"] : '';
    $nrlotemp = ( isset($_POST["nrlotemp"]) ) ? $_POST["nrlotemp"] : '';
    $nrlotcot = ( isset($_POST["nrlotcot"]) ) ? $_POST["nrlotcot"] : '';
    $flgvlddv = ( isset($_POST["flgvlddv"]) ) ? $_POST["flgvlddv"] : '';
    $tpconven = ( isset($_POST["tpconven"]) ) ? $_POST["tpconven"] : '';
    $tpdebemp = ( isset($_POST["tpdebemp"]) ) ? $_POST["tpdebemp"] : '';
    $tpdebcot = ( isset($_POST["tpdebcot"]) ) ? $_POST["tpdebcot"] : '';
    $tpdebppr = ( isset($_POST["tpdebppr"]) ) ? $_POST["tpdebppr"] : '';
    $indescsg = ( isset($_POST["indescsg"]) ) ? $_POST["indescsg"] : '';
    $flgpagto = ( isset($_POST["flgpagto"]) ) ? $_POST["flgpagto"] : '';
    $flgarqrt = ( isset($_POST["flgarqrt"]) ) ? $_POST["flgarqrt"] : '';
    $dtfchfol = ( isset($_POST["dtfchfol"]) ) ? $_POST["dtfchfol"] : '';
    $cdempfol = ( isset($_POST["cdempfol"]) ) ? $_POST["cdempfol"] : '';
    $dtavsemp = ( isset($_POST["dtavsemp"]) ) ? $_POST["dtavsemp"] : '';
    $dtavscot = ( isset($_POST["dtavscot"]) ) ? $_POST["dtavscot"] : '';
    $dtavsppr = ( isset($_POST["dtavsppr"]) ) ? $_POST["dtavsppr"] : '';
	$dtlimdeb = ( isset($_POST["dtlimdeb"]) ) ? $_POST["dtlimdeb"] : '';	

    /*VALORES ANTIGOS PARA GRAVAR NO LOG*/
    $old_nrcepend = ( isset($_POST["old_nrcepend"]) ) ? str_replace(array('-','.'),'',$_POST["old_nrcepend"]) : '';
    $old_nrdocnpj = ( isset($_POST["old_nrdocnpj"]) ) ? trim(str_replace(array('-','.','/'),'',$_POST["old_nrdocnpj"])) : '';

    $old_idtpempr = ( isset($_POST["old_idtpempr"]) ) ? $_POST["old_idtpempr"] : ''; /* aqui */
    $old_nrdconta = ( isset($_POST["old_nrdconta"]) ) ? $_POST["old_nrdconta"] : ''; /* aqui */
    $old_nmcontat = ( isset($_POST["old_nmcontat"]) ) ? $_POST["old_nmcontat"] : ''; /* aqui */
    $old_flgpgtib = ( isset($_POST["old_flgpgtib"]) ) ? $_POST["old_flgpgtib"] : ''; /* aqui */
    $old_cdcontar = ( isset($_POST["old_cdcontar"]) ) ? $_POST["old_cdcontar"] : ''; /* aqui */
    $old_vllimfol = ( isset($_POST["old_vllimfol"]) ) ? $_POST["old_vllimfol"] : ''; /* aqui */
    $old_cdempres = ( isset($_POST["old_cdempres"]) ) ? $_POST["old_cdempres"] : '';
    $old_nmextemp = ( isset($_POST["old_nmextemp"]) ) ? $_POST["old_nmextemp"] : '';
    $old_nmresemp = ( isset($_POST["old_nmresemp"]) ) ? $_POST["old_nmresemp"] : '';
    $old_dsendemp = ( isset($_POST["old_dsendemp"]) ) ? $_POST["old_dsendemp"] : '';
    $old_nrendemp = ( isset($_POST["old_nrendemp"]) ) ? $_POST["old_nrendemp"] : '';
    $old_dscomple = ( isset($_POST["old_dscomple"]) ) ? $_POST["old_dscomple"] : '';
    $old_nmbairro = ( isset($_POST["old_nmbairro"]) ) ? $_POST["old_nmbairro"] : '';
    $old_nmcidade = ( isset($_POST["old_nmcidade"]) ) ? $_POST["old_nmcidade"] : '';
    $old_cdufdemp = ( isset($_POST["old_cdufdemp"]) ) ? $_POST["old_cdufdemp"] : '';
    $old_nrfonemp = ( isset($_POST["old_nrfonemp"]) ) ? $_POST["old_nrfonemp"] : '';
    $old_nrfaxemp = ( isset($_POST["old_nrfaxemp"]) ) ? $_POST["old_nrfaxemp"] : '';
    $old_dsdemail = ( isset($_POST["old_dsdemail"]) ) ? $_POST["old_dsdemail"] : '';
    $old_ddmesnov = ( isset($_POST["old_ddmesnov"]) ) ? $_POST["old_ddmesnov"] : '';
    $old_ddpgtmes = ( isset($_POST["old_ddpgtmes"]) ) ? $_POST["old_ddpgtmes"] : '';
    $old_ddpgthor = ( isset($_POST["old_ddpgthor"]) ) ? $_POST["old_ddpgthor"] : '';
    $old_nrlotfol = ( isset($_POST["old_nrlotfol"]) ) ? $_POST["old_nrlotfol"] : '';
    $old_nrlotemp = ( isset($_POST["old_nrlotemp"]) ) ? $_POST["old_nrlotemp"] : '';
    $old_nrlotcot = ( isset($_POST["old_nrlotcot"]) ) ? $_POST["old_nrlotcot"] : '';
    $old_vltrfsal = ( isset($_POST["old_vltrfsal"]) ) ? $_POST["old_vltrfsal"] : '';
    $old_flgvlddv = ( isset($_POST["old_flgvlddv"]) ) ? $_POST["old_flgvlddv"] : '';
    $old_tpconven = ( isset($_POST["old_tpconven"]) ) ? $_POST["old_tpconven"] : '';
    $old_tpdebemp = ( isset($_POST["old_tpdebemp"]) ) ? $_POST["old_tpdebemp"] : '';
    $old_tpdebcot = ( isset($_POST["old_tpdebcot"]) ) ? $_POST["old_tpdebcot"] : '';
    $old_tpdebppr = ( isset($_POST["old_tpdebppr"]) ) ? $_POST["old_tpdebppr"] : '';
    $old_indescsg = ( isset($_POST["old_indescsg"]) ) ? $_POST["old_indescsg"] : '';
    $old_flgpagto = ( isset($_POST["old_flgpagto"]) ) ? $_POST["old_flgpagto"] : '';
    $old_flgarqrt = ( isset($_POST["old_flgarqrt"]) ) ? $_POST["old_flgarqrt"] : '';
    $old_dtfchfol = ( isset($_POST["old_dtfchfol"]) ) ? $_POST["old_dtfchfol"] : '';
    $old_cdempfol = ( isset($_POST["old_cdempfol"]) ) ? $_POST["old_cdempfol"] : '';
    $old_dtavsemp = ( isset($_POST["old_dtavsemp"]) ) ? $_POST["old_dtavsemp"] : '';
    $old_dtavscot = ( isset($_POST["old_dtavscot"]) ) ? $_POST["old_dtavscot"] : '';
    $old_dtavsppr = ( isset($_POST["old_dtavsppr"]) ) ? $_POST["old_dtavsppr"] : '';
	$old_dtultufp = ( isset($_POST["old_dtultufp"]) ) ? $_POST["old_dtultufp"] : '';
	$old_dtlimdeb = ( isset($_POST["old_dtlimdeb"]) ) ? $_POST["old_dtlimdeb"] : '';
    /*VALORES ANTIGOS PARA GRAVAR NO LOG*/

	//remove & (e comercial) da descricao da empresa
	$pattern = '/(&){1,}/';
	$replacement = '';
	$nmextemp = preg_replace($pattern, $replacement, $nmextemp);
	
	//remove & (e comercial) da descricao da empresa
	$pattern = '/(&){1,}/';
	$replacement = '';
	$nmresemp = preg_replace($pattern, $replacement, $nmresemp);

    /* Se a empresa esta adquirindo o servico, verificar se ja exite
    a digitalizacao do DOC. Caso ja tenho o servico de folha, ignora
    essa validacao */
    $dtultufp = "?";
    if ($old_flgpgtib <> $flgpgtib) {
        $flgdgfib = true;   // Flag de digitalizacao: Se for TRUE, deve mudar pra FALSE
    } else {
        $flgdgfib = false;  // Flag de digitalizacao: Se for TRUE, deve mudar pra FALSE
    }

    $auxIndescsg = $indescsg=="2"?"yes":"no";

	$cdcooper = ( isset($glbvars["cdcooper"]) ) ? $glbvars["cdcooper"] : '';
	$cdagenci = ( isset($glbvars["cdagenci"]) ) ? $glbvars["cdagenci"] : '';
	$nrdcaixa = ( isset($glbvars["nrdcaixa"]) ) ? $glbvars["nrdcaixa"] : '';
	$cdoperad = ( isset($glbvars["cdoperad"]) ) ? $glbvars["cdoperad"] : '';
	$dtmvtolt = ( isset($glbvars["dtmvtolt"]) ) ? $glbvars["dtmvtolt"] : '';
	$idorigem = ( isset($glbvars["idorigem"]) ) ? $glbvars["idorigem"] : '';
	$nmdatela = ( isset($glbvars["nmdatela"]) ) ? $glbvars["nmdatela"] : '';
	$cdprogra = ( isset($glbvars["cdprogra"]) ) ? $glbvars["cdprogra"] : '';



    /*VALIDA SE OS DADOS DA EMPRESA ESTAO CORRETOS*/
    $xml  = "";
    $xml.= "<Root>";
    $xml.= "  <Cabecalho>";
    $xml.= "        <Bo>b1wgen0166.p</Bo>";
    $xml.= "        <Proc>Valida_empresa</Proc>";
    $xml.= "  </Cabecalho>";
    $xml.= "  <Dados>";
    $xml .= "        <cdcooper>".$cdcooper."</cdcooper>";
    $xml .= "        <cdagenci>".$cdagenci."</cdagenci>";
    $xml .= "        <nrdcaixa>".$nrdcaixa."</nrdcaixa>";
    $xml .= "        <cdoperad>".$cdoperad."</cdoperad>";
    $xml .= "        <dtmvtolt>".$dtmvtolt."</dtmvtolt>";
    $xml .= "        <idorigem>".$idorigem."</idorigem>";
    $xml .= "        <nmdatela>".$nmdatela."</nmdatela>";
    $xml .= "        <cdprogra>".$cdprogra."</cdprogra>";
    $xml.="         <indescsg>$indescsg</indescsg>";
    $xml.="         <nrdocnpj>$nrdocnpj</nrdocnpj>";
    $xml.="         <dtfchfol>$dtfchfol</dtfchfol>";
    $xml.="         <cdempfol>$cdempfol</cdempfol>";
    $xml.="         <flgpagto>$flgpagto</flgpagto>";
    $xml.="         <old_dtavsemp>$old_dtavsemp</old_dtavsemp>";
    $xml.="         <new_dtavsemp>$dtavsemp</new_dtavsemp>";
    $xml.="         <old_dtavscot>$old_dtavscot</old_dtavscot>";
    $xml.="         <new_dtavscot>$dtavscot</new_dtavscot>";
    $xml.="         <old_dtavsppr>$old_dtavsppr</old_dtavsppr>";
    $xml.="         <new_dtavsppr>$dtavsppr</new_dtavsppr>";
    $xml.= "  </Dados>";
    $xml.= "</Root>";

    // Executa script para envio do XML
    $xmlResult = getDataXML($xml);
    // Cria objeto para classe de tratamento de XML
    $xmlObj = getObjectXML($xmlResult);

    if ( isset($xmlObj->roottag->tags[0]->name) && strtoupper($xmlObj->roottag->tags[0]->name) == 'ERRO' ) {
        exibirErro('error',$xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata,'Alerta - Ayllos','',false);
        die;
    }
    if(isset($xmlObj->roottag->tags[0]->attributes['DSCRITIC'])){
        if(trim($xmlObj->roottag->tags[0]->attributes['DSCRITIC'])){
            if(trim($xmlObj->roottag->tags[0]->attributes['DSCRITIC'] == 'Dia Fechamento Folha deve ser entre 1 e 28.')){
            exibirErro('error',$xmlObj->roottag->tags[0]->attributes['DSCRITIC'],'Alerta - Ayllos','focaCampoErro(\'dtfchfol\', \'frmOpcao\')',false);
            die;
            }else if(trim($xmlObj->roottag->tags[0]->attributes['DSCRITIC'] == "Codigo da Empresa deve ser maior que '0'.")){
                exibirErro('error',$xmlObj->roottag->tags[0]->attributes['DSCRITIC'],'Alerta - Ayllos','focaCampoErro(\'cdempfol\', \'frmOpcao\')',false);
                die;
            }else{
                exibirErro('error',$xmlObj->roottag->tags[0]->attributes['DSCRITIC'],'Alerta - Ayllos','',false);
                die;
            }
        }
    }

    /*VALIDA SE OS DADOS DA EMPRESA ESTAO CORRETOS*/

    $xml  = "";
    $xml .= "<Root>";
    $xml .= "  <Cabecalho>";
    $xml .= "       <Bo>b1wgen0166.p</Bo>";
    $xml .= "        <Proc>Altera_inclui</Proc>";
    $xml .= "  </Cabecalho>";
    $xml .= "  <Dados>";
    $xml.="          <tiptrans>".$opcao."</tiptrans>";
    $xml.="          <inavscot>0</inavscot>";
    $xml.="          <inavsemp>0</inavsemp>";
    $xml.="          <inavsppr>0</inavsppr>";
    $xml.="          <inavsden>0</inavsden>";
    $xml.="          <inavsseg>0</inavsseg>";
    $xml.="          <inavssau>0</inavssau>";
    $xml .= "        <cdcooper>".$cdcooper."</cdcooper>";
    $xml .= "        <cdagenci>".$cdagenci."</cdagenci>";
    $xml .= "        <nrdcaixa>".$nrdcaixa."</nrdcaixa>";
    $xml .= "        <cdoperad>".$cdoperad."</cdoperad>";
    $xml .= "        <dtmvtolt>".$dtmvtolt."</dtmvtolt>";
    $xml .= "        <idorigem>".$idorigem."</idorigem>";
    $xml .= "        <nmdatela>".$nmdatela."</nmdatela>";
    $xml .= "        <cdprogra>".$cdprogra."</cdprogra>";
    $xml.="          <tpdebemp>0</tpdebemp>";
    $xml.="          <tpdebcot>0</tpdebcot>";
    $xml.="          <tpdebppr>0</tpdebppr>";
    $xml.="          <cdempfol>0</cdempfol>";
    $xml.="          <cdempres>$cdempres</cdempres>";
    $xml.="          <nmextemp>$nmextemp</nmextemp>";
    $xml.="          <nmresemp>$nmresemp</nmresemp>";
    $xml.="          <dsendemp>$dsendemp</dsendemp>";
    $xml.="          <nrendemp>$nrendemp</nrendemp>";
    $xml.="          <dscomple>$dscomple</dscomple>";
    $xml.="          <nmbairro>$nmbairro</nmbairro>";
    $xml.="          <nmcidade>$nmcidade</nmcidade>";
    $xml.="          <cdufdemp>$cdufdemp</cdufdemp>";
    $xml.="          <nrcepend>$nrcepend</nrcepend>";
    $xml.="          <nrdocnpj>$nrdocnpj</nrdocnpj>";
    $xml.="          <nrfonemp>$nrfonemp</nrfonemp>";
    $xml.="          <nrfaxemp>$nrfaxemp</nrfaxemp>";
    $xml.="          <dsdemail>$dsdemail</dsdemail>";
    $xml.="          <nrlotfol>$nrlotfol</nrlotfol>";
    $xml.="          <nrlotemp>$nrlotemp</nrlotemp>";
    $xml.="          <nrlotcot>$nrlotcot</nrlotcot>";
    $xml.="          <flgvlddv>$flgvlddv</flgvlddv>";
    $xml.="          <tpconven>$tpconven</tpconven>";
    $xml.="          <tpdebemp>$tpdebemp</tpdebemp>";
    $xml.="          <tpdebcot>$tpdebcot</tpdebcot>";
    $xml.="          <tpdebppr>$tpdebppr</tpdebppr>";
    $xml.="          <indescsg>$indescsg</indescsg>";
    $xml.="          <flgpagto>$flgpagto</flgpagto>";
    $xml.="          <flgarqrt>$flgarqrt</flgarqrt>";
    $xml.="          <dtfchfol>$dtfchfol</dtfchfol>";
    $xml.="          <cdempfol>$cdempfol</cdempfol>";
    $xml.="          <dtavsemp>$dtavsemp</dtavsemp>";
    $xml.="          <dtavscot>$dtavscot</dtavscot>";
    $xml.="          <dtavsppr>$dtavsppr</dtavsppr>";
    $xml.="          <idtpempr>$idtpempr</idtpempr>";
    $xml.="          <nrdconta>$nrdconta</nrdconta>";
    $xml.="          <nmcontat>$nmcontat</nmcontat>";
    $xml.="          <flgpgtib>$flgpgtib</flgpgtib>";
    $xml.="          <flgdgfib>$flgdgfib</flgdgfib>";
    $xml.="          <cdcontar>$cdcontar</cdcontar>";
    $xml.="          <vllimfol>$vllimfol</vllimfol>";
    $xml.="          <dtultufp>$dtultufp</dtultufp>";
    $xml.="          <dtlimdeb>$dtlimdeb</dtlimdeb>";
    $xml.="    </Dados>";
    $xml.="</Root>";

    // Executa script para envio do XML
    $xmlResult = getDataXML($xml);
    // Cria objeto para classe de tratamento de XML
    $xmlObj = getObjectXML($xmlResult);

    if ( isset($xmlObj->roottag->tags[0]->name) && strtoupper($xmlObj->roottag->tags[0]->name) == 'ERRO' ) {
        exibirErro('error',$xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata,'Alerta - Ayllos','estadoInicial();',false);
        die;
    }

    /*salva dados da segunta tela*/
    //campo vltrfsal
    //@todo nao esta completo o xml abaixo, o mesmo nao esta salvado o dado na tabela
    $xml  = "";
    $xml .= "<Root>";
    $xml .= "  <Cabecalho>";
    $xml .= "       <Bo>b1wgen0166.p</Bo>";
    $xml .= "        <Proc>Grava_tabela</Proc>";
    $xml .= "  </Cabecalho>";
    $xml .= "  <Dados>";
    $xml .= "        <cdcooper>".$cdcooper."</cdcooper>";
    $xml .= "        <cdagenci>".$cdagenci."</cdagenci>";
    $xml .= "        <nrdcaixa>".$nrdcaixa."</nrdcaixa>";
    $xml .= "        <cdoperad>".$cdoperad."</cdoperad>";
    $xml .= "        <dtmvtolt>".$dtmvtolt."</dtmvtolt>";
    $xml .= "        <idorigem>".$idorigem."</idorigem>";
    $xml .= "        <nmdatela>".$nmdatela."</nmdatela>";
    $xml .= "        <cdprogra>".$cdprogra."</cdprogra>";
    $xml .= '       <nmsistem>CRED</nmsistem>';
    $xml .= '       <tptabela>USUARI</tptabela>';
    $xml .= '       <cdempres>'.$cdempres.'</cdempres>';
    $xml .= '       <cdacesso>VLTARIF008</cdacesso>';
    $xml .= '       <tpregist>001</tpregist>';
    $xml .= '       <dstextab>'.$vltrfsal.'</dstextab>';
    $xml .= "  </Dados>";
    $xml .= "</Root>";

    // Executa script para envio do XML
    $xmlResult = getDataXML($xml);

    function gravaTabela($glbvars, $cdempres, $dstextab, $cdacesso)
	{

		$cdcooper = ( isset($glbvars["cdcooper"]) ) ? $glbvars["cdcooper"] : '';
		$cdagenci = ( isset($glbvars["cdagenci"]) ) ? $glbvars["cdagenci"] : '';
		$nrdcaixa = ( isset($glbvars["nrdcaixa"]) ) ? $glbvars["nrdcaixa"] : '';
		$cdoperad = ( isset($glbvars["cdoperad"]) ) ? $glbvars["cdoperad"] : '';
		$dtmvtolt = ( isset($glbvars["dtmvtolt"]) ) ? $glbvars["dtmvtolt"] : '';
		$idorigem = ( isset($glbvars["idorigem"]) ) ? $glbvars["idorigem"] : '';
		$nmdatela = ( isset($glbvars["nmdatela"]) ) ? $glbvars["nmdatela"] : '';
		$cdprogra = ( isset($glbvars["cdprogra"]) ) ? $glbvars["cdprogra"] : '';

        $xml  = "";
        $xml .= "<Root>";
        $xml .= "  <Cabecalho>";
        $xml .= "       <Bo>b1wgen0166.p</Bo>";
        $xml .= "        <Proc>Grava_tabela</Proc>";
        $xml .= "  </Cabecalho>";
        $xml .= "  <Dados>";
        $xml .= "        <cdcooper>".$cdcooper."</cdcooper>";
        $xml .= "        <cdagenci>".$cdagenci."</cdagenci>";
        $xml .= "        <nrdcaixa>".$nrdcaixa."</nrdcaixa>";
        $xml .= "        <cdoperad>".$cdoperad."</cdoperad>";
        $xml .= "        <dtmvtolt>".$dtmvtolt."</dtmvtolt>";
        $xml .= "        <idorigem>".$idorigem."</idorigem>";
        $xml .= "        <nmdatela>".$nmdatela."</nmdatela>";
        $xml .= "        <cdprogra>".$cdprogra."</cdprogra>";
        $xml .= '       <nmsistem>CRED</nmsistem>';
        $xml .= '       <tptabela>GENERI</tptabela>';
        $xml .= '       <cdempres>00</cdempres>';
        $xml .= '       <cdacesso>'.$cdacesso.'</cdacesso>';
        $xml .= '       <tpregist>'.$cdempres.'</tpregist>';
        $xml .= '       <dstextab>'.$dstextab.'</dstextab>';
        $xml .= "  </Dados>";
        $xml .= "</Root>";
        // Executa script para envio do XML
        $xmlResult = getDataXML($xml);

    }

    if((strlen(trim($ddmesnov)) == 0) || ($ddmesnov <= 0 || $ddmesnov > 28)){
        exibirErro('error','Dia inv&aacute;lido!','Alerta - Ayllos','focaCampoErro(\'ddmesnov\', \'frmInfTarifa\')',false);
        die;
    }else if((strlen(trim($dtlimdeb)) == 0) || ($dtlimdeb <= 0 || $dtlimdeb > 28)){
        exibirErro('error','Dia inv&aacute;lido!','Alerta - Ayllos','focaCampoErro(\'dtlimdeb\', \'frmInfEmprestimo\')',false);
        die;
    }else if((strlen(trim($ddpgtmes)) == 0) || ($ddpgtmes <= 0 || $ddpgtmes > 28)){
        exibirErro('error','Dia inv&aacute;lido!','Alerta - Ayllos','focaCampoErro(\'ddpgtmes\', \'frmInfTarifa\')',false);
        die;
    }else if((strlen(trim($ddpgthor)) == 0) || ($ddpgthor <= 0 || $ddpgthor > 28)){
        exibirErro('error','Dia inv&aacute;lido!','Alerta - Ayllos','focaCampoErro(\'ddpgthor\', \'frmInfTarifa\')',false);
        die;
    }

    gravaTabela($glbvars, $cdempres,$ddmesnov.' '.$ddpgtmes.' '.$ddpgthor.' 270 0', 'DIADOPAGTO');
    if($opcao == 'I'){
        gravaTabela($glbvars, $cdempres,'90'.$cdempres.'0','NUMLOTEFOL');
        gravaTabela($glbvars, $cdempres,'50'.$cdempres.'0','NUMLOTEEMP');
        gravaTabela($glbvars, $cdempres,'80'.$cdempres.'0','NUMLOTECOT');
    }

    /*salva os logs*/
    $old_indescsg = ($old_indescsg == 2)?'YES':'NO';
    $indescsg = ($indescsg == 2)?'YES':'NO';

    $xml  = "";
    $xml .= "<Root>";
    $xml .= "  <Cabecalho>";
    $xml .= "        <Bo>b1wgen0166.p</Bo>";
    $xml .= "        <Proc>Gera_arquivo_log</Proc>";
    $xml .= "  </Cabecalho>";
    $xml .= "  <Dados>";
    $xml .= "        <cdcooper>".$cdcooper."</cdcooper>";
    $xml .= "        <tiptrans>".$opcao."</tiptrans>";
    $xml .= "        <dtmvtolt>".$dtmvtolt."</dtmvtolt>";
    $xml .= "        <cdoperad>".$cdoperad."</cdoperad>";
    $xml .= "        <cdempres>$cdempres</cdempres>";

    $xml .= "        <old_indescsg>$old_indescsg</old_indescsg>";
    $xml .= "        <new_indescsg>$indescsg</new_indescsg>";

    $xml .= "        <old_dtfchfol>$old_dtfchfol</old_dtfchfol>";
    $xml .= "        <new_dtfchfol>$dtfchfol</new_dtfchfol>";

    $xml .= "        <old_flgpagto>$old_flgpagto</old_flgpagto>";
    $xml .= "        <new_flgpagto>$flgpagto</new_flgpagto>";

    $xml .= "        <old_flgarqrt>$old_flgarqrt</old_flgarqrt>";
    $xml .= "        <new_flgarqrt>$flgarqrt</new_flgarqrt>";

    $xml .= "        <old_flgvlddv>$old_flgvlddv</old_flgvlddv>";
    $xml .= "        <new_flgvlddv>$flgvlddv</new_flgvlddv>";

    $xml .= "        <old_cdempfol>$old_cdempfol</old_cdempfol>";
    $xml .= "        <new_cdempfol>$cdempfol</new_cdempfol>";

    $xml .= "        <old_tpconven>$old_tpconven</old_tpconven>";
    $xml .= "        <new_tpconven>$tpconven</new_tpconven>";

    $xml .= "        <old_tpdebemp>$old_tpdebemp</old_tpdebemp>";
    $xml .= "        <new_tpdebemp>$tpdebemp</new_tpdebemp>";

    $xml .= "        <old_tpdebcot>$old_tpdebcot</old_tpdebcot>";
    $xml .= "        <new_tpdebcot>$tpdebcot</new_tpdebcot>";

    $xml .= "        <old_tpdebppr>$old_tpdebppr</old_tpdebppr>";
    $xml .= "        <new_tpdebppr>$tpdebppr</new_tpdebppr>";

    $xml .= "        <old_cdempres>$cdempres</old_cdempres>";
    $xml .= "        <new_cdempres>$cdempres</new_cdempres>";

    $xml .= "        <old_dtavscot>$old_dtavscot</old_dtavscot>";
    $xml .= "        <new_dtavscot>$dtavscot</new_dtavscot>";

    $xml .= "        <old_dtavsemp>$old_dtavsemp</old_dtavsemp>";
    $xml .= "        <new_dtavsemp>$dtavsemp</new_dtavsemp>";

    $xml .= "        <old_dtavsppr>$old_dtavsppr</old_dtavsppr>";
    $xml .= "        <new_dtavsppr>$dtavsppr</new_dtavsppr>";

    $xml .= "        <old_nmextemp>$old_nmextemp</old_nmextemp>";
    $xml .= "        <new_nmextemp>$nmextemp</new_nmextemp>";

    $xml .= "        <old_nmresemp>$old_nmresemp</old_nmresemp>";
    $xml .= "        <new_nmresemp>$nmresemp</new_nmresemp>";

    $xml .= "        <old_cdufdemp>$old_cdufdemp</old_cdufdemp>";
    $xml .= "        <new_cdufdemp>$cdufdemp</new_cdufdemp>";

    $xml .= "        <old_dscomple>$old_dscomple</old_dscomple>";
    $xml .= "        <new_dscomple>$dscomple</new_dscomple>";

    $xml .= "        <old_dsdemail>$old_dsdemail</old_dsdemail>";
    $xml .= "        <new_dsdemail>$dsdemail</new_dsdemail>";

    $xml .= "        <old_dsendemp>$old_dsendemp</old_dsendemp>";
    $xml .= "        <new_dsendemp>$dsendemp</new_dsendemp>";

    $xml .= "        <old_nmbairro>$old_nmbairro</old_nmbairro>";
    $xml .= "        <new_nmbairro>$nmbairro</new_nmbairro>";

    $xml .= "        <old_nmcidade>$old_nmcidade</old_nmcidade>";
    $xml .= "        <new_nmcidade>$nmcidade</new_nmcidade>";

    $xml .= "        <old_nrcepend>$old_nrcepend</old_nrcepend>";
    $xml .= "        <new_nrcepend>$nrcepend</new_nrcepend>";

    $xml .= "        <old_nrdocnpj>$old_nrdocnpj</old_nrdocnpj>";
    $xml .= "        <new_nrdocnpj>$nrdocnpj</new_nrdocnpj>";

    $xml .= "        <old_nrendemp>$old_nrendemp</old_nrendemp>";
    $xml .= "        <new_nrendemp>$nrendemp</new_nrendemp>";

    $xml .= "        <old_nrfaxemp>$old_nrfaxemp</old_nrfaxemp>";
    $xml .= "        <new_nrfaxemp>$nrfaxemp</new_nrfaxemp>";

    $xml .= "        <old_nrfonemp>$old_nrfonemp</old_nrfonemp>";
    $xml .= "        <new_nrfonemp>$nrfonemp</new_nrfonemp>";

    $xml .= "        <old_idtpempr>$old_idtpempr</old_idtpempr>";
    $xml .= "        <idtpempr>$idtpempr</idtpempr>";

    $xml .= "        <old_nrdconta>$old_nrdconta</old_nrdconta>";
    $xml .= "        <nrdconta>$nrdconta</nrdconta>";

    $xml .= "        <old_nmcontat>$old_nmcontat</old_nmcontat>";
    $xml .= "        <nmcontat>$nmcontat</nmcontat>";

    $xml .= "        <old_flgpgtib>$old_flgpgtib</old_flgpgtib>";
    $xml .= "        <flgpgtib>$flgpgtib</flgpgtib>";

    $xml .= "        <old_cdcontar>$old_cdcontar</old_cdcontar>";
    $xml .= "        <cdcontar>$cdcontar</cdcontar>";

    $xml .= "        <old_vllimfol>$old_vllimfol</old_vllimfol>";
    $xml .= "        <vllimfol>$vllimfol</vllimfol>";

    $xml .= "        <old_dtultufp>$old_dtultufp</old_dtultufp>";
    $xml .= "        <dtultufp>$dtultufp</dtultufp>";

    $xml .= "        <old_dtlimdeb>$old_dtlimdeb</old_dtlimdeb>";
    $xml .= "        <new_dtlimdeb>$dtlimdeb</new_dtlimdeb>";

    $xml .= "    </Dados>";
    $xml .= "</Root>";

    $xmlResult = getDataXML($xml);
    /*salva os logs*/
?>