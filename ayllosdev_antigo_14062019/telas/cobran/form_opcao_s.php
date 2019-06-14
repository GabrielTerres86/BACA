<? 
/*!
 * FONTE        : form_opcao_s.php
 * CRIAÇÃO      : Odirlei Busana - AMcom
 * DATA CRIAÇÃO : 28/04/2016
 * OBJETIVO     : Formulario que permite pesquisar situação dos convenios
 * --------------
 * ALTERAÇÕES   :
 * --------------
 * 
 *
 */
 
?>

<?php
 	session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');	
	require_once('../../class/xmlfile.php');
	isPostMethod();
	
	include('form_cabecalho.php');
    
    // Buscar nome das cooperativas
    $xml = "<Root>";
    $xml .= " <Dados>";
    //Apenas carregar todas se for coop 3 - cecred
    if ($glbvars["cdcooper"] == 3){
        $xml .= "   <cdcooper>0</cdcooper>";
    }else{
        $xml .= '   <cdcooper>'.$glbvars["cdcooper"].'</cdcooper>';
    }
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
        echo 'showError("error","' . $msgErro . '","Alerta - Aimaro","desbloqueia()");';
        exit();
    }
?>

<form id="frmOpcao" class="formulario" onSubmit="return false;">

	<fieldset>
        <!-- Apresentar div apenas para coop 3 -->
		<div id="divCooper"            
            <? if ($glbvars["cdcooper"] != 3 ){ ?> style="display:none;" <? } ?> 
        >
            <label for="nmrescop"><? echo utf8ToHtml('Cooperativa:') ?></label>
            <select id="nmrescop" name="nmrescop">
            <? if ($glbvars["cdcooper"] == 3 ){ ?> 
              <option value="0"><? echo utf8ToHtml(' Todas') ?></option> <? } ?> 
            
            <?php
            foreach ($registros as $r) {
                
                if ( getByTagName($r->tags, 'cdcooper') <> '' ) {
            ?>
                <option value="<?= getByTagName($r->tags, 'cdcooper');?>"><?= getByTagName($r->tags, 'nmrescop'); ?></option> 
                
                <?php
                }
            }
            ?>
            </select>
        </div>
        
        <br style="clear:both" />   
        
        <label for="cdagenci"><?php echo utf8ToHtml('PA:') ?></label>
        <input name="cdagenci" id="cdagenci" type="text" />
        
        <label for="nrdconta"><?php echo utf8ToHtml('Conta/DV:') ?></label>
        <input name="nrdconta" id="nrdconta" type="text" />
        <a id="lupaConta" style="padding: 3px 0 0 3px;" href="#" onClick="controlaPesquisa(1);return false;">
            <img src="<?php echo $UrlImagens; ?>geral/ico_lupa.gif"/>
        </a>	
        
        <label for="dtinicio"><?php echo utf8ToHtml('Data Inicial:') ?></label>
        <input name="dtinicio" id="dtinicio" type="text" />

        <label for="dtafinal"><?php echo utf8ToHtml('Final:') ?></label>
        <input name="dtafinal" id="dtafinal" type="text" />
        
        
        <br style="clear:both" />        
        
        <label for="nrconven"><?php echo utf8ToHtml('Convênio:') ?></label>
        <input name="nrconven" id="nrconven" type="text" />
        
        <label for="insitceb"><? echo utf8ToHtml('Status:') ?></label>               
        <select name="insitceb" id="insitceb" class="<?php echo $campo; ?>">					 	
          <option value="0"> TODOS        </option>
          <option value="1"> ATIVO        </option>
          <option value="2"> INATIVO      </option> 
          <option value="3"> PENDENTE     </option>
          <option value="4"> BLOQUEADO    </option>
          <option value="5"> APROVADO     </option>
          <option value="6"> <? echo utf8ToHtml('NÃO APROVADO'); ?> </option>          
        </select>
        
        <a href="#" class="botao" id="btpesqui" onclick="EfetuaPesquisaOpS(1,100,0);" ><? echo  utf8ToHtml('Pesquisar'); ?></a>    
        
        <br style="clear:both" />           
        <br style="clear:both" />  

        <div id="divConsOpS" style="display:none"></div>
        <div id="divConteudoOpcao"> 
            <input type="hidden" id= "cdcooper"    name="cdcooper">
            <input type="hidden" id= "cdagenci"    name="cdagenci">
            <input type="hidden" id= "nrdconta"    name="nrdconta">
            <input type="hidden" id= "nrconven"    name="nrconven">
            <input type="hidden" id= "nrcnvceb"    name="nrcnvceb">
            <input type="hidden" id= "dhanalis"    name="dhanalis">
            <input type="hidden" id= "insitceb"    name="insitceb">
        </div>

	    <br style="clear:both" />        
		
	</fieldset>		
	
</form>


<div id="divBotoes" style="padding-bottom:10px">
    
    <a href="#" class="botao" id="btnAprovar"
       onclick="ConfirmaAtualizacao(5); return false;" ><? echo utf8ToHtml('Aprovar'); ?></a>
	<a href="#" class="botao" id="btnReprovar"
       onclick="ConfirmaAtualizacao(6); return false;" ><? echo utf8ToHtml('Reprovar'); ?></a> 
    <a href="#" class="botao" id="btnExportar"
       onclick="buscaExportarOpS(); return false;" ><? echo utf8ToHtml('Exportar'); ?></a>
       
    <a href="#" class="botao" id="btVoltar" onclick="limpaOpS(); return false;">Voltar</a>
	
</div>


