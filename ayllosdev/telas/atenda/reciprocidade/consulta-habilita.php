<?
/*************************************************************************
	Fonte: consulta-habilita.php
	Autor: Gabriel						Ultima atualizacao: 13/12/2016
	Data : Dezembro/2010
	
	Objetivo: Tela para visualizar a consulta/habilitacao da rotina 
			  de cobranca.
	
	Alteracoes: 19/05/2011 - Tratar cob. regist. (Guilherme).
	
				14/07/2011 - Alterado para layout padrão (Gabriel - DB1).
				
				26/07/2011 - Ajuste para impressao de cobranca registrada
							 (Gabriel)

				08/09/2011 - Ajuste para chamada da lista negra (Adriano).			 
							 
				09/05/2013 - Retirado vampo de valor maximo de boleto. (Jorge)			 
				
				19/09/2013 - Inclusao do campo logico Convenio Homologado,
                             habilitado apenas para o setor COBRANCA (Carlos)
							 
				28/04/2015 - Incluido campos cooperativa emite e expede e
							 cooperado emite e expede. (Reinert)

                24/11/2015 - Inclusao do indicador de negativacao pelo Serasa.
                             (Jaison/Andrino)

				22/02/2016 - PRJ 213 - Reciprocidade. (Jaison/Marcos)

                08/07/2016 - P213 - Correcao no processo de envio ao Serasa (Marcos-Supero)

                11/07/2016 - Ajustes para apenas solicitar senha para as alterações
                             de desconto manuais.
                             PRJ213 - Reciprocidade (odirlei-AMcom) 

                01/08/2016 - Ajuste no teste de qtdfloat pois estava deixando 
                             a opção vazia a ser selecionda (Marcos-Supero)

				04/08/2016 - Adicionado campo de forma de envio de arquivo de cobrança. (Reinert)

				29/11/2016 - P341-Automatização BACENJUD - Realizar as validações pelo código
				             do departamento ao invés da descrição (Renato Darosci - Supero)

				13/12/2016 - PRJ340 - Nova Plataforma de Cobranca - Fase II. (Jaison/Cechet)

				09/04/2018 - Chamada da rotina para verificar se o tipo de conta permite produto 
				             6 - Cobrança Bancária. PRJ366 (Lombardi).

*************************************************************************/

session_start();

// Includes para controle da session, vari&aacute;veis globais de controle, e biblioteca de fun&ccedil;&otilde;es
require_once("../../../includes/config.php");
require_once("../../../includes/funcoes.php");		
require_once("../../../includes/controla_secao.php");

// Verifica se tela foi chamada pelo m&eacute;todo POST
isPostMethod();	

// Classe para leitura do xml de retorno
require_once("../../../class/xmlfile.php");	

$nrdconta    = $_POST["nrdconta"];
$inpessoa    = $_POST["inpessoa"];
$nrcnvceb    = $_POST["nrcnvceb"];
$nrconven    = $_POST["nrconven"];
$dsorgarq    = trim($_POST["dsorgarq"]);
$insitceb    = trim($_POST["insitceb"]);
$inarqcbr    = $_POST["inarqcbr"];
$cddemail    = $_POST["cddemail"];
$dsdemail    = trim($_POST["dsdemail"]);
$flgcruni    = trim($_POST["flgcruni"]);
$flgregis    = trim($_POST["flgregis"]);
$flgregon    = trim($_POST["flgregon"]);
$flgpgdiv    = trim($_POST["flgpgdiv"]);
$flcooexp    = trim($_POST["flcooexp"]);
$flceeexp    = trim($_POST["flceeexp"]);
$flserasa    = trim($_POST["flserasa"]);
$cddbanco	 = trim($_POST["cddbanco"]);
$flgcebhm    = trim($_POST["flgcebhm"]);
$cddopcao    = trim($_POST["cddopcao"]);
$dsdmesag    = $_POST["dsdmesag"];
$titulares   = $_POST["titulares"];
$qtTitulares = $_POST["qtTitulares"];
$emails_titular = $_POST["emails"];
$flsercco    = $_POST["flsercco"];
$qtdfloat    = trim($_POST["qtdfloat"]);
$flprotes    = trim($_POST["flprotes"]);
$qtlimaxp    = trim($_POST["qtlimaxp"]);
$qtlimmip    = trim($_POST["qtlimmip"]);
$flproaut    = trim($_POST["flproaut"]);
$insrvprt    = trim($_POST["insrvprt"]);
$qtdecprz    = trim($_POST["qtdecprz"]);
$idrecipr	 = trim($_POST["idrecipr"]);
$inenvcob	 = trim($_POST["inenvcob"]);

// Monta o xml de requisição
$xml  = "";
$xml .= "<Root>";
$xml .= "	<Dados>";
$xml .= "		<nrdconta>".$nrdconta."</nrdconta>";
$xml .= "		<cdprodut>".    6    ."</cdprodut>";
$xml .= "	</Dados>";
$xml .= "</Root>";

// Executa script para envio do XML
$xmlResult = mensageria($xml, "CADA0006", "VALIDA_ADESAO_PRODUTO", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
$xmlObj = getObjectXML($xmlResult);

// Se ocorrer um erro, mostra crítica
if (strtoupper($xmlObj->roottag->tags[0]->name) == "ERRO") {
	$msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
	exibeErro(utf8_encode($msgErro));
}

// Função para exibir erros na tela através de javascript
function exibeErro($msgErro) { 
	echo '<script type="text/javascript">';
	echo 'hideMsgAguardo();';
	echo 'showError("error","'.$msgErro.'","Alerta - Ayllos","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
	echo '</script>';
	exit();
}	

// Titulo de tela dependendo a opcao de CONSULTA/HABILITACAO
$dstitulo = ($cddopcao == "C")? "CONSULTA" : "HABILITA&Ccedil;&Atilde;O"; 

$dstitulo .= " - COBRAN&Ccedil;A";

if ($nrcnvceb > 0 ) {
	$dstitulo .= " ( CEB $nrcnvceb )";
}

$campo = ($cddopcao == "C" ) ? "campoTelaSemBorda" : "campo";

// Montar o xml de Requisicao
$xml  = "";
$xml .= "<Root>";
$xml .= " <Dados>";	
$xml .= "   <nrconven>".$nrconven."</nrconven>";
$xml .= " </Dados>";
$xml .= "</Root>";

$xmlResult = mensageria($xml, "TELA_ATENDA_COBRAN", "BUSCA_CONFIG_CONV", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
$xmlObject = getObjectXML($xmlResult);
$xmlDados  = $xmlObject->roottag->tags[0];

$cco_cddbanco = getByTagName($xmlDados->tags,"CDDBANCO");
$cco_qtdfloat = getByTagName($xmlDados->tags,"QTDFLOAT");
$cco_qtfltate = getByTagName($xmlDados->tags,"QTFLTATE");
$cco_flprotes = getByTagName($xmlDados->tags,"FLPROTES");
$cco_insrvprt = getByTagName($xmlDados->tags,"INSRVPRT");
$cco_flproaut = getByTagName($xmlDados->tags,"FLPROAUT");
$cco_flserasa = getByTagName($xmlDados->tags,"FLSERASA");
$cco_qtdecini = getByTagName($xmlDados->tags,"QTDECINI");
$cco_qtdecate = getByTagName($xmlDados->tags,"QTDECATE");
$cco_flrecipr = getByTagName($xmlDados->tags,"FLRECIPR");
$cco_fldctman = getByTagName($xmlDados->tags,"FLDCTMAN");
$cco_flgregis = getByTagName($xmlDados->tags,"FLGREGIS");
$cco_perdctmx = getByTagName($xmlDados->tags,"PERDCTMX");
$cco_flgapvco = getByTagName($xmlDados->tags,"FLGAPVCO");
$cco_idprmrec = getByTagName($xmlDados->tags,"IDPRMREC");
$cco_dcmaxrec = getByTagName($xmlDados->tags,"PERDESCONTO_MAXIMO_RECIPRO");
$cco_qtlimmip = getByTagName($xmlDados->tags,"QTLIMITEMIN_TOLERANCIA");
$cco_qtlimaxp = getByTagName($xmlDados->tags,"QTLIMITEMAX_TOLERANCIA");
	
$insrvprt = $cco_insrvprt;
	
if ($cddopcao == "I") {
    $qtdecprz = $cco_qtdecini;
    $flgregis = $cco_flgregis == 1 ? 'SIM' : 'NAO';
}

if ($cco_flprotes == 1 && $cco_insrvprt == 1 && ($qtlimmip == 0 || $qtlimaxp == 0)){
    $qtlimmip   = $cco_qtlimmip;
    $qtlimaxp   = $cco_qtlimaxp;
}

// Montar o xml de Requisicao
$xml  = "";
$xml .= "<Root>";
$xml .= " <Dados>";
$xml .= "   <nrdconta>".$nrdconta."</nrdconta>";
$xml .= "   <nrconven>".$nrconven."</nrconven>";
$xml .= " </Dados>";
$xml .= "</Root>";

$xmlResult = mensageria($xml, "TELA_ATENDA_COBRAN", "BUSCA_CATEGORIA", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
$xmlObject = getObjectXML($xmlResult);
$xmlSubGru = $xmlObject->roottag->tags[0]->tags;

$xmlResult = mensageria($xml, "TELA_ATENDA_COBRAN", "VERIFICA_APURACAO", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
$xmlObject = getObjectXML($xmlResult);
$xmlDados  = $xmlObject->roottag->tags[0];
$qtapurac  = getByTagName($xmlDados->tags,"QTAPURAC");
?>
<style type="text/css">
.popbox {
    position: absolute;
    z-index: 99999;
    width: 400px;
    padding: 5px;
    background: #CED3C6;
    color: #000000;
    margin: 0px;
    -webkit-box-shadow: 0px 0px 5px 0px rgba(164, 164, 164, 1);
    box-shadow: 0px 0px 5px 0px rgba(164, 164, 164, 1);
}
</style>
<form action="" name="frmConsulta" id="frmConsulta" method="post">
	<input type="hidden" name="flsercco"                   id="flsercco" />
    <input type="hidden" name="cddopcao"                   id="cddopcao"                   value="<?php echo $cddopcao; ?>" />
    <input type="hidden" name="cco_cddbanco"               id="cco_cddbanco"               value="<?php echo $cco_cddbanco; ?>" />
    <input type="hidden" name="idrecipr"                   id="idrecipr"                   value="<?php echo (int) $idrecipr; ?>" />
    <input type="hidden" name="idreciprold"                id="idreciprold"                value="<?php echo (int) $idrecipr; ?>" />
    <input type="hidden" name="idprmrec"                   id="idprmrec"                   value="<?php echo (int) $cco_idprmrec; ?>" />
    <input type="hidden" name="flgapvco"                   id="flgapvco"                   value="<?php echo (int) $cco_flgapvco; ?>" />
    <input type="hidden" name="perdesconto_maximo_recipro" id="perdesconto_maximo_recipro" value="<?php echo $cco_dcmaxrec; ?>" />
    <input type="hidden" name="glb_desmensagem"            id="glb_desmensagem" />
    <input type="hidden" name="glb_perdesconto"            id="glb_perdesconto" />
    <input type="hidden" name="glb_idreciproci"            id="glb_idreciproci" />
	<fieldset>
		<legend><? echo utf8ToHtml($dstitulo) ?></legend>
		
        <?php
            // Selecionar o convenio
            if ($cddopcao == 'S') {
                ?>
                <label for="nrconven"><? echo utf8ToHtml('Convênio:') ?></label>
                <input name="nrconven" id="nrconven" class="campo" />
                <a id="linkLupa" style="float:left"><img src="<?php echo $UrlImagens; ?>geral/ico_lupa.gif" ></a>
                <br />
                <label for="dsorgarq"><? echo utf8ToHtml('Origem:') ?></label>
                <input name= "dsorgarq" id="dsorgarq" class="campoTelaSemBorda" readonly />
                <?php
            } else {
                ?>
                <div id="divAba0" class="clsAbas">
                    <label for="nrconven"><? echo utf8ToHtml('Convênio:') ?></label>
                    <input name="nrconven" id="nrconven" class="campoTelaSemBorda" readonly value="<?php echo formataNumericos("zz.zzz.zz9",$nrconven,'.'); ?>" />
                    <br />
            
                    <label for="dsorgarq"><? echo utf8ToHtml('Origem Convênio:') ?></label>
                    <input name= "dsorgarq" id="dsorgarq" class="campoTelaSemBorda" readonly value = " <?php echo $dsorgarq; ?>" />
                    <br />
                    
                    <label for="insitceb"><? echo utf8ToHtml('Situação Cobrança:') ?></label>               
                    <select name="insitceb" id="insitceb" class="<?php echo $campo; ?>">					 	
                      <option value="1" <?php if ($insitceb == "1")  { ?> selected <?php } ?> > ATIVO        </option>
                      <option value="2" <?php if ($insitceb == "2" ) { ?> selected <?php } ?> > INATIVO      </option>  													
                      
                    <?php
                      // Nao deve exibir opcoes na tela de alterar
                      if ($cddopcao != "A") { ?>
                          <option value="3" <?php if ($insitceb == "3" ) { ?> selected <?php } ?> > PENDENTE     </option>
                          <option value="4" <?php if ($insitceb == "4" ) { ?> selected <?php } ?> > BLOQUEADO    </option>
                          <option value="5" <?php if ($insitceb == "5" ) { ?> selected <?php } ?> > APROVADO     </option>
                          <option value="6" <?php if ($insitceb == "6" ) { ?> selected <?php } ?> > <? echo utf8ToHtml('NÃO APROVADO'); ?> </option>
                      <?php } else if ($insitceb == "5"){ // se for sit aprovado, deve carregar?>
                          <option value="5" <?php if ($insitceb == "5" ) { ?> selected <?php } ?> > APROVADO     </option>
                      <?php  }?>
                    </select>
                    
                    <?php
                      // se nao for consulta e a situacao for aprovado ou inativo, habilita botao
                      if ($cddopcao != "C" && ($insitceb == 5 || $insitceb == 2)) { ?>
                          <input type="image" src="<? echo $UrlImagens; ?>botoes/ativar.gif" onClick="confirmaAtivacao(); return false;" id="btnAtivar" />
                    <?php  }
                    ?>
                    <br />
                            
                    <label for="flgregis"><? echo utf8ToHtml('Registrada:') ?></label>
                    <input name= "flgregis" id="flgregis" class="campoTelaSemBorda" readonly value = " <?php echo $flgregis; ?>" />		
                    <br />	

                    <?php
                        if ($cco_cddbanco == 85) {
                            ?>
                            <label for="flgregon"><? echo utf8ToHtml('Registrar Online na CIP:') ?></label>
                            <input name="flgregon" id="flgregon" type="checkbox" class="checkbox" readonly <?php if ($flgregon == "SIM" ) { ?> checked <?php } ?> />		
                            <br />

                            <label for="flgpgdiv"><? echo utf8ToHtml('Autorizar Pagamento Divergente:') ?></label>		
                            <input name="flgpgdiv" id="flgpgdiv" type="checkbox" class="checkbox" readonly <?php if ($flgpgdiv == "SIM" ) { ?> checked <?php } ?> />		
                            <br />

                            <label for="flcooexp"><? echo utf8ToHtml('Cooperado Emite e Expede:') ?></label>
                            <input name="flcooexp" id="flcooexp" type="checkbox" class="checkbox" readonly <?php if ($flcooexp == "SIM" ) { ?> checked <?php } ?> />		
                            <br />
                            
                            <label for="flceeexp"><? echo utf8ToHtml('Cooperativa Emite e Expede:') ?></label>		
                            <input name="flceeexp" id="flceeexp" type="checkbox" class="checkbox" readonly <?php if ($flceeexp == "SIM" ) { ?> checked <?php } ?> />		
                            <br />	
                            
                            <label for="qtdfloat"><? echo utf8ToHtml('Float a aplicar:') ?></label>
                            <select name="qtdfloat" id="qtdfloat" class="<?php echo $campo; ?>">
                              <?php
                                  if ($qtdfloat != "" && $qtdfloat < $cco_qtdfloat) {
                                      echo '<option value="'.$qtdfloat.'" selected>'.$qtdfloat.'</option>';
                                  }                                  
                                  for ($i = $cco_qtdfloat; $i <= $cco_qtfltate; $i++) {
                                      echo '<option value="'.$i.'" '.($qtdfloat == $i ? 'selected' : '').'>'.$i.'</option>';
                                  }
                                  if ($qtdfloat != "" && $qtdfloat > $cco_qtfltate) {
                                      echo '<option value="'.$qtdfloat.'" selected>'.$qtdfloat.'</option>';
                                  }
                              ?>
                            </select>
                            <label style="margin-left:10px;">dias</label>
                            <br />
                            
                            <div id="divOpcaoSerasaProtesto">
                                <label for="flserasa"><? echo utf8ToHtml('Negativação via Serasa:') ?></label>
                                <input name="flserasa" id="flserasa" type="checkbox" class="checkbox" readonly <?php if ($flserasa == "SIM" ) { ?> checked <?php } ?> />
                                <br />
                                <label for="flprotes"><? echo utf8ToHtml('Envio de Protesto:') ?></label>		
                                <input name="flprotes" id="flprotes" onchange="onChangeProtesto()" type="checkbox" class="checkbox" readonly <?php if ($flprotes == "SIM" ) { ?> checked <?php } ?> />
                                <br />
		                        <input type="hidden" id="insrvprt" value="<?php echo $insrvprt; ?>" />
		
		                        <label for="qtlimmip"><? echo utf8ToHtml('Intervalo de Protesto:') ?></label>
		                        <input name= "qtlimmip" id="qtlimmip" class="<?php echo $campo; ?>" value = " <?php echo $qtlimmip; ?>" <?php if ($flprotes != "SIM" ) { ?> readonly <?php } ?>/>
		
		                        <label for="qtlimaxp" style="margin-left:10px;"><? echo utf8ToHtml('At&eacute;:') ?></label>		
		                        <input name= "qtlimaxp" id="qtlimaxp" class="<?php echo $campo; ?>" value = " <?php echo $qtlimaxp; ?>" <?php if ($flprotes != "SIM" ) { ?> readonly <?php } ?>/>
		                        <label style="margin-left:10px;">dias</label>
                            </div>
                        
                            <label for="qtdecprz"><? echo utf8ToHtml('Decurso de Prazo:') ?></label>
                            <input name= "qtdecprz" id="qtdecprz" class="<?php echo $campo; ?>" value = " <?php echo $qtdecprz; ?>" />
                            <label style="margin-left:10px;">dias</label>
                            <br />
                            <?php
                        }
                    ?>
                    
                    <label for="inarqcbr"><? echo utf8ToHtml('Recebe Arquivo Retorno:') ?></label>
                    <select name="inarqcbr" id="inarqcbr" class="<?php echo $campo; ?>">	
                        <option id="inarqcbr" value="0" <?php if ($inarqcbr == 0) { ?> selected <?php } ?> > N&Atilde;O RECEBE </option>
                        <option id="inarqcbr" value="1" <?php if ($inarqcbr == 1) { ?> selected <?php } ?> > OUTROS </option>
                        <option id="inarqcbr" value="2" <?php if ($inarqcbr == 2) { ?> selected <?php } ?> > FEBRABAN 240 </option>					   
                        <option id="inarqcbr" value="3" <?php if ($inarqcbr == 3) { ?> selected <?php } ?> > CNAB 400 </option>
                    </select>
                    <br />
                    
					<label for="inenvcob"><? echo utf8ToHtml('Forma Envio Arquivo Cobrança:') ?></label>
					<select name="inenvcob" id="inenvcob" <?php if ($dsorgarq != 'IMPRESSO PELO SOFTWARE') { ?> disabled class="campoTelaSemBorda" <?php }else{ ?> class="<?php echo $campo; ?>" <?php } ?>>
						<option id="inenvcob" value="1" <?php if ($dsorgarq == 'IMPRESSO PELO SOFTWARE' && $inenvcob == 1) { ?> selected <?php }elseif($dsorgarq != 'IMPRESSO PELO SOFTWARE'){ ?> selected <?php } ?>> INTERNET BANK </option>
                        <option id="inenvcob" value="2" <?php if ($dsorgarq == 'IMPRESSO PELO SOFTWARE' && $inenvcob == 2) { ?> selected <?php } ?> > FTP </option>					   
					</select >
                    <label for="dsdemail"><? echo utf8ToHtml('E-mail Arquivo Retorno:') ?></label>
                    <select name="dsdemail" id="dsdemail" class="<?php echo $campo; ?>">
                     
                        <?php if ($dsdemail != "") {  $valor = $cddemail; ?>
                                <option value="<?php echo "0"; ?>" > <?php echo "SELECIONE O E-MAIL"; ?> </option>							
                        <?php } else { 									
                                $dsdemail = "SELECIONE O E-MAIL";
                                $valor    = "0";									
                        } ?>
                        
                        <option value="<?php echo $valor; ?>" selected > <? echo $dsdemail; ?> </option>
                                             
                        <?php   $emails = explode("|",$emails_titular); // Dividir os emails
                        
                         foreach ($emails as $email) { 
                         
                            $email = explode(",",$email);
                            $contador = 0;
                          
                            foreach ($email as $tag)  {								
                                if ($contador == 0) 
                                    $cddemail = $tag; 									
                                else
                                    $descricao = $tag;										
                                $contador++;									
                            }	
                            
                            if ($descricao != $dsdemail) { ?>
                              <option id="dsdemail" value="<?php echo $cddemail;?>">  <?php echo $descricao; ?> </option>							
                        <?  } 
                        
                        } ?>
                    </select>		
                    <br />
                    
                    <label for="flgcruni"><? echo utf8ToHtml('Utiliza Crédito Unificado:') ?></label>
                    <select name="flgcruni" id="flgcruni" class="<?php echo $campo; ?>">
                        <option id="flgcruni" value="yes" <? if ($flgcruni == "SIM") { ?> selected <? } ?> >   SIM </option>
                        <option id="flgcruni" value="no"  <? if ($flgcruni == "NAO") { ?> selected <? } ?> >  N&Atilde;O </option>
                    </select>
                    
                    <div id="divCnvHomol" style="display:<?php echo $dsorgarq == 'IMPRESSO PELO SOFTWARE' ? 'block' : 'none'; ?>;">
                        <script>
                            habilitaSetor('<?php echo $glbvars['cddepart'] ?>');
                        </script>
                        <br />
                        <label for="flgcebhm"><? echo utf8ToHtml('Convênio Homologado:') ?></label>
                        <select name="flgcebhm" id="flgcebhm" class="<?php echo $campo; ?>">
                            <option value="yes" <? if ($flgcebhm == "SIM") { ?> selected <? } ?> >   SIM </option>
                            <option value="no"  <? if ($flgcebhm == "NAO") { ?> selected <? } ?> >  N&Atilde;O </option>
                        </select>
                    </div>
                </div>

                <div id="divAba1" class="clsAbas">
                    <fieldset>
                        <legend align="left">Reciprocidade</legend>
                        <div align="center">
                            <a href="#" class="botao" style="float:none; padding: 3px 6px;" id="btnCalculo">C&aacute;lculo</a>
                            <a href="#" class="botao" style="float:none; padding: 3px 6px;" id="btnAcompanhamento">Acompanhamento</a>
                            <a href="#" class="botao" style="float:none; padding: 3px 6px;" id="btnAjuda" onClick="gera_ajuda();return false;">Ajuda</a>
                        </div>
                    </fieldset>
                    <?php
                        // Listagem dos subgrupos
                        $cont = 0;
                        $tot_percdesc = 0;
                        foreach ($xmlSubGru as $sgr) {
                            $cat_dssubgru = $sgr->attributes['DSSUBGRU'];
                            ?>
                            <fieldset>
                                <legend align="left"><?php echo $cat_dssubgru; ?></legend>
                                <table width="100%" id="tabSgrCat">
                                    <thead>
                                        <tr>
                                            <td class="txtNormal" width="60%">&nbsp;</td>
                                            <td class="txtNormal" width="40%">%Desconto</td>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <?php
                                        // Listagem das categorias
                                        foreach ($sgr->tags as $cat) {
                                            $cat_cdcatego = getByTagName($cat->tags,'CDCATEGO');
                                            $cat_dscatego = getByTagName($cat->tags,'DSCATEGO');
                                            $cat_flcatcoo = getByTagName($cat->tags,'FLCATCOO');
                                            $cat_flcatcee = getByTagName($cat->tags,'FLCATCEE');
                                            $cat_fldesman = getByTagName($cat->tags,'FLDESMAN');
                                            $cat_flrecipr = getByTagName($cat->tags,'FLRECIPR');
                                            $cat_percdesc = getByTagName($cat->tags,'PERDESCONTO');
                                            ?>
                                            <tr id="<?php echo 'linCat'.$cont.'_'.$cat_flcatcoo.'_'.$cat_flcatcee; ?>">
                                                <td class="txtNormal clsDesCategoria" numLinha="<?php echo $cont; ?>">
                                                    <?php echo $cat_dscatego; ?>
                                                    <span class='clsTarifas<?php echo $cont; ?>' style="display:none;">
                                                        <table cellspacing="1" cellpadding="0">
                                                            <tr style="background-color:#6B7984;">
                                                                <td class="txtBrancoBold" width="76%" style="padding:2px;">Tarifa:</td>
                                                                <td class="txtBrancoBold" width="12%" style="padding:2px;">Tarifa Original:</td>
                                                                <td class="txtBrancoBold" width="12%" style="padding:2px;">Tarifa c/ Desc.:</td>
                                                            </tr>
                                                            <?php
                                                                // Se foi informado convenio
                                                                if ($nrconven > 0) {
                                                                    // Montar o xml de Requisicao
                                                                    $xml  = "";
                                                                    $xml .= "<Root>";
                                                                    $xml .= " <Dados>";	
                                                                    $xml .= "   <nrconven>".$nrconven."</nrconven>";
                                                                    $xml .= "   <cdcatego>".$cat_cdcatego."</cdcatego>";
                                                                    $xml .= "   <inpessoa>".$inpessoa."</inpessoa>";
                                                                    $xml .= " </Dados>";
                                                                    $xml .= "</Root>";

                                                                    $xmlResult = mensageria($xml, "TELA_ATENDA_COBRAN", "BUSCA_TARIFAS", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
                                                                    $xmlObject = getObjectXML($xmlResult);
                                                                    $xmlTarifa = $xmlObject->roottag->tags[0]->tags;

                                                                    // Listagem das tarifas
                                                                    $contTar = 0;
                                                                    foreach ($xmlTarifa as $tar) {
                                                                        $tar_cdtarifa = getByTagName($tar->tags,'CDTARIFA');
                                                                        $tar_dstarifa = getByTagName($tar->tags,'DSTARIFA');
                                                                        $tar_vltarifa = getByTagName($tar->tags,'VLTARIFA');
                                                                        ?>
                                                                        <tr style="background-color:#FFFFFF;" class="clsTar<?php echo $cont; ?>">
                                                                            <td class="txtNormal"><?php echo $tar_cdtarifa.' - '.$tar_dstarifa; ?></td>
                                                                            <td class="txtNormal clsTarValorOri<?php echo $cont.$contTar; ?>"><?php echo formataMoeda($tar_vltarifa); ?></td>
                                                                            <td class="txtNormal clsTarValorDes<?php echo $cont.$contTar; ?>">0,00</td>
                                                                        </tr>
                                                                        <?php
                                                                        $contTar++;
                                                                    }
                                                                }
                                                            ?>
                                                        </table>
                                                    </span>
                                                </td>
                                                <td>
                                                    <input name="perdesconto_<?php echo $cont; ?>" id="perdesconto_<?php echo $cont; ?>" cdcatego="<?php echo $cat_cdcatego; ?>" class="<?php echo $campo; ?> clsPerDesconto clsCatFlrecipr<?php echo $cat_flrecipr; ?>" value="<?php echo formataMoeda($cat_percdesc); ?>" onblur="validaPerDesconto('<?php echo $cont; ?>','<?php echo $cco_perdctmx; ?>','<?php echo $cat_dscatego; ?>');" /> 
                                                    <?php
                                                        // Caso nao tenha permissao de desconto manual na categoria ou convenio
                                                        if ($cat_fldesman == 0 || $cco_fldctman == 0) {
                                                            ?>
                                                            <script>
                                                                $("#perdesconto_<?php echo $cont; ?>").prop("disabled",true).addClass("campoTelaSemBorda");
                                                            </script>
                                                            <?php
                                                        }
                                                    ?>
                                                </td>
                                            </tr>
                                            <?php
                                            $tot_percdesc = $tot_percdesc + $cat_percdesc;
                                            $cont++;
                                        }
                                        ?>
                                    </tbody>
                                </table>
                            </fieldset>
                            <?php
                        }
                    ?>
                    <input type="hidden" id="tot_percdesc" value="<?php echo $tot_percdesc; ?>" />
					<input type="hidden" id="tot_percdesc_recipr" value="<?php echo $tot_percdesc_recipr; ?>" />
					<div align="left">
						<span style="line-height:25px; margin-left:5px;" class="txtNormal">* Desconto via c&aacute;lculo Reciprocidade</span>
						<br>
						<span style="line-height:25px; margin-left:5px;" class="txtNormal">** N&atilde;o permite desconto</span>
					</div>
                </div>
                <?php
            }
        ?>
	</fieldset>
</form>

<form id="frmImprimir" name="frmImprimir">
    <input type="hidden" name="sidlogin" id="sidlogin" value="<?php echo $glbvars["sidlogin"]; ?>" />
    <input type="hidden" name="nmarquiv" id="nmarquiv" />
</form>

<div id="divBotoes">
    
    <?php
        // Selecionar convenio
        if ($cddopcao == 'S') {
            ?><input src="<? echo $UrlImagens; ?>botoes/continuar.gif" onClick="consulta('I','','','true','','');return false;" id="btnContinuar" type="image" /><?php
        } else {
            ?><input src="<? echo $UrlImagens; ?>botoes/continuar.gif" id="btnContinuar" onClick="return false;" type="image" /><?php
        }

        // Se convenio INTERNET e tem mais titulares
        if ($dsorgarq == "INTERNET" && $qtTitulares > 0 && $dsdmesag == "") {
            ?><input type="image" src="<? echo $UrlImagens; ?>botoes/outros_titulares.gif" onClick="titulares('<? echo $cddopcao; ?> ' , ' <? echo $titulares; ?> ');return false;" /><?php
        }
    ?>
	<input type="image" src="<? echo $UrlImagens; ?>botoes/voltar.gif" onClick="voltarParaDesconto();" id="btnVoltar" />
</div>

<script type="text/javascript">
controlaLayout('frmConsulta');

$("#divConteudoOpcao").css("display","none");
$("#divOpcaoIncluiAltera").css("display","none");

$("#divOpcaoConsulta").css("display","block");

blockBackground(parseInt($("#divRotina").css("z-index")));

// Se for pessoa fisica esconde indicador Serasa
if (inpessoa == 1) {
    $("#divOpcaoSerasaProtesto").hide();
}

<?php
// Se o convenio possui reciprocidade
if ($cco_flrecipr == 1 || $qtapurac > 0) {
    ?>
    // Habilita
    $("#btnCalculo").prop("disabled",false).removeClass("botaoDesativado").attr('onClick','abrirReciprocidadeCalculo();');
    $("#btnAcompanhamento").prop("disabled",false).removeClass("botaoDesativado").attr('onClick','abrirReciprocidadeAcompanhamento();');
    <?php
    if ($cddopcao == "C" || $cddopcao == "A") { // Consulta/Alteracao
        ?>
        // Se NAO possui reciprocidade
        if (parseInt($("#idrecipr","#frmConsulta").val()) == 0) {
            var qtapurac = '<?php echo $qtapurac; ?>';            
            // Se NAO tiver apuracao
            if (parseInt(qtapurac) == 0) {
                $("#btnAcompanhamento").prop("disabled",true).addClass("botaoDesativado").attr("onClick","return false;"); // Desabilita
            }
            <?php
            if ($cddopcao == "C") { // Consulta
                echo '$("#btnCalculo").prop("disabled",true).addClass("botaoDesativado").attr("onClick","return false;");'; // Desabilita
            }
            ?>
        }
        <?php
    } else if ($cddopcao == "I") { // Inclusao
        echo '$("#btnAcompanhamento").prop("disabled",true).addClass("botaoDesativado").attr("onClick","return false;");'; // Desabilita
    }
} else { // Desabilita
    echo '$("#btnCalculo").prop("disabled",true).addClass("botaoDesativado").attr("onClick","return false;");';
    echo '$("#btnAcompanhamento").prop("disabled",true).addClass("botaoDesativado").attr("onClick","return false;");';
}
?>

// Div flutuante com as tarifas
$(".clsDesCategoria").hover(
  function() {
    var numLinha = $(this).attr('numLinha');
    var qtdTarif = $('.clsTar' + numLinha).length;
    for (indTar = 0; indTar < qtdTarif; indTar++) {
        var vlTarSemDesc = converteMoedaFloat($('.clsTarValorOri' + numLinha + '' + indTar).html());
        var vlPerDesconto = converteMoedaFloat($('#perdesconto_' + numLinha).val());
        var vlTarComDesc = vlTarSemDesc * (vlPerDesconto / 100);
        vlTarComDesc = number_format((vlTarComDesc == 0 ? vlTarSemDesc : (vlTarSemDesc - vlTarComDesc)),2,',','.');
        $('.clsTarValorDes' + numLinha + '' + indTar).html(vlTarComDesc);
    }
    $(this).append("<div class='popbox'>" + $(".clsTarifas" + numLinha).html() + "</div>");
  }, function() {
    $(this).find( "div:last" ).remove();
  }
);

// Se foi clicado no Envio de Protesto
$("#flprotes","#frmConsulta").unbind('click').bind('click', function(e) {
    if ($(this).is(':checked')) {
        var cco_flprotes = '<?php echo (int) $cco_flprotes; ?>';
        if (cco_flprotes == '0') {
            showError('error', 'Conv&ecirc;nio n&atilde;o permite envio de Protesto!', 'Alerta - Ayllos', 'bloqueiaFundo(divRotina)');
            return false;
        }
    }
});

$("#qtlimmip","#frmConsulta").unbind('blur').bind('blur', function(e) {
    var cco_qtlimmip = '<?php echo $cco_qtlimmip; ?>';
    if ($(this).val() == '' ||
        $(this).val() < parseInt(cco_qtlimmip)) {
        $(this).val(cco_qtlimmip);
        showError('error', 'Intervalo protesto inv&aacute;lido! Favor selecionar um per&iacute;odo de <?php echo $cco_qtlimmip; ?> at&eacute; <?php echo $cco_qtlimaxp; ?>!', 'Alerta - Ayllos', 'bloqueiaFundo(divRotina);$("#qtlimmip","#frmConsulta").focus();');
        return false;
    }
});
			
$("#qtlimaxp","#frmConsulta").unbind('blur').bind('blur', function(e) {
    var cco_qtlimaxp = '<?php echo $cco_qtlimaxp; ?>';
    if ($(this).val() == '' ||
        $(this).val() > parseInt(cco_qtlimaxp)) {
        $(this).val(cco_qtlimaxp);
        showError('error', 'Intervalo protesto inv&aacute;lido! Favor selecionar um per&iacute;odo de <?php echo $cco_qtlimmip; ?> at&eacute; <?php echo $cco_qtlimaxp; ?>!', 'Alerta - Ayllos', 'bloqueiaFundo(divRotina);$("#qtlimaxp","#frmConsulta").focus();');
        return false;
    }
});

// Se foi informado Decurso de Prazo
$("#qtdecprz","#frmConsulta").unbind('blur').bind('blur', function(e) {
    var cco_qtdecini = '<?php echo $cco_qtdecini; ?>';
    var cco_qtdecate = '<?php echo $cco_qtdecate; ?>';
    if ($(this).val() == '' ||
        $(this).val() < parseInt(cco_qtdecini) || 
        $(this).val() > parseInt(cco_qtdecate)) {
        $(this).val('');
        showError('error', 'Decurso de Prazo inv&aacute;lido! Favor selecionar um per&iacute;odo de <?php echo $cco_qtdecini; ?> at&eacute; <?php echo $cco_qtdecate; ?>!', 'Alerta - Ayllos', 'bloqueiaFundo(divRotina);$("#qtdecprz","#frmConsulta").focus();');
        return false;
    }
});

<?php 
    if ($cddopcao == "S") { // Selecionar o convenio
        ?>
        $("#nrconven","#frmConsulta").focus();
        $("#nrconven","#frmConsulta").addClass('pesquisa').css({'width':'66px'}).attr('maxlength','8').setMask("INTEGER","zzzzz.zz9",".","");
        $("#nrconven","#frmConsulta").unbind('keydown').bind('keydown', function(e) {
            if ( divError.css('display') == 'block' ) { return false; }		
            if ( e.keyCode == 118 ) {
                pesquisaConvenio();
            } else {
                $("#nrconven","#frmConsulta").unbind('blur').bind('blur', function(e) {
                    buscaDescricaoConvenio($(this).attr('name'),$(this).val());
                });
            }
        });
        <?php
    } else { // Exibe a aba inicial
        ?>
        // Esconde as abas
        $('.clsAbas','#frmConsulta').hide();
        // Mostra a aba
        acessaAba('0','<?php echo $cddopcao; ?>');
        <?php
    }

    if ($cddopcao == "I") { // Se eh inclusao
        ?>
        $("#insitceb","#divOpcaoConsulta").prop("disabled",true);
        $("#flceeexp","#divOpcaoConsulta").prop("checked",false);

        $("#dsorgarq","#frmConsulta").css({'width':'150px','background-color':'F3F3F3','font-size':'11px','padding':'2px 4px 1px 4px'});
        <?php
    }

    if ($cddopcao == "C") { // Se consulta, desabilita
        ?>
        $("#insitceb","#divOpcaoConsulta").prop("disabled",true);
        $("#inarqcbr","#divOpcaoConsulta").prop("disabled",true);
        $("#dsdemail","#divOpcaoConsulta").prop("disabled",true);
        $("#flgregis","#divOpcaoConsulta").prop("disabled",true);
        $("#flgregon","#divOpcaoConsulta").prop("disabled",true);
        $("#flgpgdiv","#divOpcaoConsulta").prop("disabled",true);
        $("#flcooexp","#divOpcaoConsulta").prop("disabled",true);
        $("#flceeexp","#divOpcaoConsulta").prop("disabled",true);
        $("#flgcruni","#divOpcaoConsulta").prop("disabled",true);
        $("#flgcebhm","#divOpcaoConsulta").prop("disabled",true);
        $("#cddbanco","#divOpcaoConsulta").prop("disabled",true);
        $("#flserasa","#divOpcaoConsulta").prop("disabled",true);
        $("#qtdfloat","#divOpcaoConsulta").prop("disabled",true);
        $("#flprotes","#divOpcaoConsulta").prop("disabled",true);
        $("#qtdecprz","#divOpcaoConsulta").prop("disabled",true);
        $("#inenvcob","#divOpcaoConsulta").prop("disabled",true);
        $("#qtlimmip","#divOpcaoConsulta").prop("disabled",true);
		$("#insrvprt","#divOpcaoConsulta").prop("disabled",true);
		$("#qtlimaxp","#divOpcaoConsulta").prop("disabled",true);
        $(".clsPerDesconto","#divOpcaoConsulta").prop("disabled",true);
        <?php
    } else if ($dsdmesag != "" && $dsorgarq == "INTERNET" ) { // Nao tem senha liberada para Internet
        ?>
        showError("inform","<?php echo $dsdmesag; ?>","Alerta - Ayllos","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");
        <?php
    }
	
?>
</script>