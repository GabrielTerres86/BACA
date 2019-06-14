<? 
    /*!
     * FONTE        : form_abas.php
     * CRIAÇÃO      : Odirlei Busana(AMcom)
     * DATA CRIAÇÃO : Novembro/2017 
     * OBJETIVO     : Cabecalho tela HISPES
     * --------------
     * ALTERAÇÕES   :
     * --------------
     *
     */	
 
    
 
?>

<form name="frmAbas" id="frmAbas" class="formulario" >
    <table width="100%" border="0" cellspacing="0" cellpadding="0">
        <tr>
            <td class="pessoaAcesso">
                <fieldset>
                  <legend>Pessoas Visualizadas </legend>
                  <div id="divAcessoPessoa">
                
                  </div>
                </fieldset>  
            </td>
        </tr>    
        <tr>
            <td>
                <table border="0" cellspacing="0" cellpadding="0">
                    <tr style="height:22px;">
                        <!-- Resumo -->	
                        <td width="1px"></td>											
                        <td align="center" style="background-color: #C6C8CA; border-radius:3px;" id="imgAbaCen0">
                            <a href="#" style="display:flex;" id="linkAba0" onClick=<?php echo "acessaOpcaoAbaDados(0);"; ?> class="txtNormalBold">&nbsp; Resumo &nbsp; </a>
                        </td>
                        <td width="1px"></td>
                        <!-- Pessoa -->
                        <td align="center" style="background-color: #C6C8CA; border-radius:3px; " id="imgAbaCen1">
                            <a href="#" style="display:flex;" id="linkAba1" onClick=<?php echo "acessaOpcaoAbaDados(1,'TBCADAST_PESSOA');"; ?> class="txtNormalBold">&nbsp; <? echo utf8ToHtml('Básico'); ?> &nbsp;</a>
                        </td>
                        <td width="1px"></td>
                        <!-- Pessoa Fisica -->
                        <td align="center" style="background-color: #C6C8CA; border-radius:3px; " id="imgAbaCen2" class='abaPessoaFis'>
                            <a href="#" style="display:flex;width: 100%;height: 100%;" id="linkAba2" onClick=<?php echo "acessaOpcaoAbaDados(2,'TBCADAST_PESSOA_FISICA');"; ?> class="txtNormalBold">&nbsp; <? echo utf8ToHtml('Fisica'); ?> &nbsp;</a>
                        </td>
                        <td width="1px"class='abaPessoaFis'></td>
                        <!-- Pessoa Juridica -->
                        <td align="center" style="background-color: #C6C8CA; border-radius:3px; " id="imgAbaCen3" class='abaPessoaJur'>
                            <a href="#" style="display:flex;width: 100%;height: 100%;" id="linkAba3" onClick=<?php echo "acessaOpcaoAbaDados(3,'TBCADAST_PESSOA_JURIDICA');"; ?> class="txtNormalBold">&nbsp; <? echo utf8ToHtml('Juridica'); ?> &nbsp;</a>
                        </td>
                        <td width="1px" class='abaPessoaJur'></td>
                        <!-- Endereço -->
                        <td align="center" style="background-color: #C6C8CA; border-radius:3px; " id="imgAbaCen4" class=''>
                            <a href="#" style="display:flex;" id="linkAba4" onClick=<?php echo "acessaOpcaoAbaDados(4,'TBCADAST_PESSOA_ENDERECO');"; ?> class="txtNormalBold">&nbsp; <? echo utf8ToHtml('Endereço'); ?> &nbsp;</a>
                        </td>
                        <td width="1px"></td>
                        <!-- Telefone -->
                        <td align="center" style="background-color: #C6C8CA; border-radius:3px; " id="imgAbaCen5" class=''>
                            <a href="#" style="display:flex;" id="linkAba5" onClick=<?php echo "acessaOpcaoAbaDados(5,'TBCADAST_PESSOA_TELEFONE');"; ?> class="txtNormalBold">&nbsp; <? echo utf8ToHtml('Telefone'); ?> &nbsp;</a>
                        </td>
                        <td width="1px"></td>
                        <!-- E-mail -->
                        <td align="center" style="background-color: #C6C8CA; border-radius:3px; " id="imgAbaCen6" class=''>
                            <a href="#" style="display:flex;width: 100%;height: 100%;" id="linkAba6" onClick=<?php echo "acessaOpcaoAbaDados(6,'TBCADAST_PESSOA_EMAIL');"; ?> class="txtNormalBold">&nbsp;<? echo utf8ToHtml('E-mail'); ?>&nbsp;</a>
                        </td>
                      
                        <td width="1px"></td>
                        <!-- Bens -->
                        <td align="center" style="background-color: #C6C8CA; border-radius:3px; " id="imgAbaCen7" class=''>
                            <a href="#" style="display:flex;width: 100%;height: 100%;" id="linkAba7" onClick=<?php echo "acessaOpcaoAbaDados(7,'TBCADAST_PESSOA_BEM');"; ?> class="txtNormalBold">&nbsp;<? echo utf8ToHtml('Bens'); ?>&nbsp; </a>
                        </td>
                        <td width="1px"></td>
                        <!-- Renda -->
                        <td align="center" style="background-color: #C6C8CA; border-radius:3px; " id="imgAbaCen8" class='abaPessoaFis'>
                            <a href="#" style="display:flex;" id="linkAba8" onClick=<?php echo "acessaOpcaoAbaDados(8,'TBCADAST_PESSOA_RENDA');"; ?> class="txtNormalBold">&nbsp; <? echo utf8ToHtml('Renda'); ?> &nbsp; </a>
                        </td>
                        <td width="1px" class='abaPessoaFis'></td>
                        <!-- Renda Complementar -->
                        <td align="center" style="background-color: #C6C8CA; border-radius:3px; " id="imgAbaCen9" class='abaPessoaFis'>
                            <a href="#" style="display:flex;" id="linkAba9" onClick=<?php echo "acessaOpcaoAbaDados(9,'TBCADAST_PESSOA_RENDACOMPL');"; ?> class="txtNormalBold">&nbsp; <? echo utf8ToHtml('Renda Compl.'); ?> &nbsp; </a>
                        </td>
                        <td width="1px" class='abaPessoaFis'></td>                                                                    
                        <!-- Pessoa Estrangeira -->
                        <td align="center" style="background-color: #C6C8CA; border-radius:3px; " id="imgAbaCen10" class=''>
                            <a href="#" style="display:flex;" id="linkAba10" onClick=<?php echo "acessaOpcaoAbaDados(10,'TBCADAST_PESSOA_ESTRANGEIRA');"; ?> class="txtNormalBold">&nbsp; <? echo utf8ToHtml('Estrang.'); ?> &nbsp; </a>
                        </td>
                        <td width="1px"></td>                        
                        <!-- Relação -->
                        <td align="center" style="background-color: #C6C8CA; border-radius:3px; " id="imgAbaCen11" class='abaPessoaFis'>
                            <a href="#" style="display:flex;" id="linkAba11" onClick=<?php echo "acessaOpcaoAbaDados(11,'TBCADAST_PESSOA_RELACAO');"; ?> class="txtNormalBold">&nbsp; <? echo utf8ToHtml('Relação'); ?> &nbsp; </a>
                        </td>
                        <td width="1px" class='abaPessoaFis'></td>
                        <!-- Referência -->
                        <td align="center" style="background-color: #C6C8CA; border-radius:3px; " id="imgAbaCen12" class=''>
                            <a href="#" style="display:flex;" id="linkAba12" onClick=<?php echo "acessaOpcaoAbaDados(12,'TBCADAST_PESSOA_REFERENCIA');"; ?> class="txtNormalBold">&nbsp; <? echo utf8ToHtml('Referência'); ?> &nbsp; </a>
                        </td>
                        <td width="1px"></td>
                        <!-- Politicamente Expostos -->
                        <td align="center" style="background-color: #C6C8CA; border-radius:3px; " id="imgAbaCen13" class='abaPessoaFis'>
                            <a href="#" style="display:flex;" id="linkAba13" onClick=<?php echo "acessaOpcaoAbaDados(13,'TBCADAST_PESSOA_POLEXP');"; ?> class="txtNormalBold">&nbsp; <? echo utf8ToHtml('Pol. Expostos'); ?> &nbsp; </a>
                        </td>
                        <td width="1px" class='abaPessoaFis'></td>                        
                        <!-- Responsável Legal -->
                        <td align="center" style="background-color: #C6C8CA; border-radius:3px; " id="imgAbaCen14" class='abaPessoaFis'>
                            <a href="#" style="display:flex;" id="linkAba14" onClick=<?php echo "acessaOpcaoAbaDados(14,'TBCADAST_PESSOA_FISICA_RESP');"; ?> class="txtNormalBold">&nbsp; <? echo utf8ToHtml('Resp. Legal'); ?> &nbsp; </a>
                        </td>
                        <td width="1px" class='abaPessoaFis'></td>
                        <!-- Dependentes -->
                        <td align="center" style="background-color: #C6C8CA; border-radius:3px; " id="imgAbaCen15" class='abaPessoaFis'>
                            <a href="#" style="display:flex;" id="linkAba15" onClick=<?php echo "acessaOpcaoAbaDados(15,'TBCADAST_PESSOA_FISICA_DEP');"; ?> class="txtNormalBold">&nbsp; <? echo utf8ToHtml('Dependente'); ?> &nbsp; </a>
                        </td>
                        <td width="1px" class='abaPessoaFis'></td>                        
                        <!-- Representantes -->
                        <td align="center" style="background-color: #C6C8CA; border-radius:3px; " id="imgAbaCen16" class='abaPessoaJur'>
                            <a href="#" style="display:flex;" id="linkAba16" onClick=<?php echo "acessaOpcaoAbaDados(16,'TBCADAST_PESSOA_JURIDICA_REP');"; ?> class="txtNormalBold">&nbsp; <? echo utf8ToHtml('Represent.'); ?> &nbsp; </a>
                        </td>
                        <td width="1px"></td>
                        <!-- Dados bancários -->
                        <td align="center" style="background-color: #C6C8CA; border-radius:3px; " id="imgAbaCen17" class='abaPessoaJur'>
                            <a href="#" style="display:flex;" id="linkAba17" onClick=<?php echo "acessaOpcaoAbaDados(17,'TBCADAST_PESSOA_JURIDICA_BCO');"; ?> class="txtNormalBold">&nbsp; <? echo utf8ToHtml('Bancários'); ?> &nbsp; </a>
                        </td>
                        <td width="1px"></td>
                        <!-- faturamento -->
                        <td align="center" style="background-color: #C6C8CA; border-radius:3px; " id="imgAbaCen18" class='abaPessoaJur'>
                            <a href="#" style="display:flex;" id="linkAba18" onClick=<?php echo "acessaOpcaoAbaDados(18,'TBCADAST_PESSOA_JURIDICA_FAT');"; ?> class="txtNormalBold">&nbsp; <? echo utf8ToHtml('Faturamento'); ?> &nbsp; </a>
                        </td>
                        <td width="1px"></td>
                        <!-- financeiros -->
                        <td align="center" style="background-color: #C6C8CA; border-radius:3px; " id="imgAbaCen19" class='abaPessoaJur'>
                            <a href="#" style="display:flex;" id="linkAba19" onClick=<?php echo "acessaOpcaoAbaDados(19,'TBCADAST_PESSOA_JURIDICA_FNC');"; ?> class="txtNormalBold">&nbsp; <? echo utf8ToHtml('Financeiros'); ?> &nbsp; </a>
                        </td>
                        <td width="1px"></td>
                        <!-- participação -->
                        <td align="center" style="background-color: #C6C8CA; border-radius:3px; " id="imgAbaCen20" class='abaPessoaJur'>
                            <a href="#" style="display:flex;" id="linkAba20" onClick=<?php echo "acessaOpcaoAbaDados(20,'TBCADAST_PESSOA_JURIDICA_PTP');"; ?> class="txtNormalBold">&nbsp; <? echo utf8ToHtml('Participação'); ?> &nbsp; </a>
                        </td>
                        
                        
                        
                    </tr>
                </table>
            </td>
        </tr>        
        <tr>
            <td align="center" style="border: 2px solid #969FA9; background-color: #F4F3F0; padding: 2px;">
                <div id="divConteudoOpcao"></div>
            </td>
        </tr>
    </table>	
</form>    
