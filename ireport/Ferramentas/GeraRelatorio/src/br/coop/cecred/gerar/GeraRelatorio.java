package br.coop.cecred.gerar;

import br.coop.cecred.comum.Comum;
import br.com.supero.parser.VTDXMLDataSource;
import java.io.File;
import java.util.HashMap;
import java.util.Locale;
import java.util.Map;
import net.sf.jasperreports.engine.DefaultJasperReportsContext;
import net.sf.jasperreports.engine.JRException;
import net.sf.jasperreports.engine.JRExporterParameter;
import net.sf.jasperreports.engine.JRParameter;
import net.sf.jasperreports.engine.JRPropertiesUtil;
import net.sf.jasperreports.engine.JasperFillManager;
import net.sf.jasperreports.engine.JasperPrint;
import net.sf.jasperreports.engine.data.JRXmlDataSource;
import net.sf.jasperreports.engine.export.JRPdfExporter;
import net.sf.jasperreports.engine.export.JRTextExporter;
import net.sf.jasperreports.engine.export.JRTextExporterParameter;
import net.sf.jasperreports.engine.fill.JRAbstractLRUVirtualizer;
import net.sf.jasperreports.engine.fill.JRSwapFileVirtualizer;
import net.sf.jasperreports.engine.util.JRSwapFile;
import net.sf.jasperreports.engine.util.JRXmlUtils;
import org.w3c.dom.Document;

/**
 * Classe que irá consumir o layout do Jasper, recebendo como parâmetro o XML de dados e o próprio layout para então
 * converter em texto.
 * @author Petter - Supero Tecnologia
 * @since  Dezembro/2012
 */
public class GeraRelatorio{
    private Map<String, Object> parametros = new HashMap<>();
    private String controleProcesso = "S";

    /**
     * Método para definir os parâmetros utilizados no relatório.
     * @param paramValues Parâmetros enviados para o relatório
     */
    private void setParametros(String paramValues, Comum comum){
        String[] param;
        String[] valores;

        try{
            if(paramValues.length() > 5){
                param = paramValues.split("@@");

                for(String params : param){
                    valores = params.split("##");
                    
                    try{
                        parametros.put(valores[0], valores[1]);

                        if((valores[0].equals("PR_PARSER"))){
                            controleProcesso = valores[1];
                        }
                    }catch(ArrayIndexOutOfBoundsException e){
                        parametros.put(valores[0], null);
                    }
                }
            }
        } catch (Exception ex){
            comum.setGerarPDF("NOK --> " + ex);
            System.err.print(comum.getGerarPDF());
            System.err.print("Erro: " + ex.getStackTrace());
            
            ex.printStackTrace();
        }
    }
    
    /**
     * Método que irá consumir XML de dados e gerar o relatório em PDF de acordo com o layout do iReport.
     * Controla a string de parâmetros padronizada para criar Map e enviar lista de parametros para o layout.
     * Controla a quebra para eliminar as linhas em branco do cabeçalho, para isso é preciso eliminar o texto no iReport via script Groovy.
     * Irá gerar um arquivo texto com a extensão LST.
     * @param arqXML Arquivo XML que irá prover os dados do relatório
     * @param noItera Nó de iteração do XML
     * @param arqJasper Layout do iReports
     * @param paramValues Array de parâmetros diversos no formato (chave#valor|chave#valor)
     * @param pathXML Path e nome do arquivo
     * @param colunas Número de colunas do relatório
     * @param comum Parâmetro para controle de erros
     * @param quebra Parâmetro para controle se terá ou não quebra
     */
    public void gerarRelatorioTXT(String arqXML, String noItera, String arqJasper, String paramValues, String pathXML, String colunas, Comum comum, int quebra){
        comum.setGerarPDF("OK");
        setParametros(paramValues, comum);
        
        JRSwapFile arquivoSwap = new JRSwapFile("/usr/coop/sistema/ireport/swap", 4096, 100);
        //JRSwapFile arquivoSwap = new JRSwapFile("D:\\", 4096, 100);
        JRAbstractLRUVirtualizer virtualizer = new JRSwapFileVirtualizer(600, arquivoSwap, true);

        Locale local = new Locale("pt", "BR");
        parametros.put(JRParameter.REPORT_LOCALE, local);
        parametros.put(JRParameter.REPORT_VIRTUALIZER, virtualizer);
        parametros.put("PR_XMLPATH", arqXML);
        
        if(quebra != 0){
            parametros.put(JRParameter.IS_IGNORE_PAGINATION, true);
        }else{
            parametros.put(JRParameter.IS_IGNORE_PAGINATION, false);
        }

        try {
            DefaultJasperReportsContext context = DefaultJasperReportsContext.getInstance();
            JRPropertiesUtil.getInstance(context).setProperty("net.sf.jasperreports.xpath.executer.factory", "net.sf.jasperreports.engine.util.xml.JaxenXPathExecuterFactory");
            
           VTDXMLDataSource dataSourceDTC = null;
           JasperPrint jasperPrint = null;
           JRXmlDataSource dataSourceDOM = null;
           
           if(controleProcesso.equals("D")){
               dataSourceDTC = new VTDXMLDataSource(arqXML, noItera);
               dataSourceDTC.setLocale(local);
               jasperPrint = JasperFillManager.fillReport(arqJasper, parametros, dataSourceDTC);
           }else{
               dataSourceDOM = new JRXmlDataSource(arqXML, noItera);
               dataSourceDOM.setLocale(local);
               jasperPrint = JasperFillManager.fillReport(arqJasper, parametros, dataSourceDOM);
           }

           Integer pageHeight = jasperPrint.getPageHeight();
           Integer pageWidth = jasperPrint.getPageWidth();

           JRTextExporter jrTextExporter = new JRTextExporter();
           jrTextExporter.setParameter(JRExporterParameter.JASPER_PRINT, jasperPrint);
            
           if(quebra == 0){
               jrTextExporter.setParameter(JRTextExporterParameter.BETWEEN_PAGES_TEXT, "zwdfgswety4563465*%");
           }

           jrTextExporter.setParameter(JRExporterParameter.OUTPUT_FILE_NAME, pathXML + "1");
           jrTextExporter.setParameter(JRTextExporterParameter.CHARACTER_HEIGHT, Dimensao.getAltura(Integer.parseInt(colunas), pageHeight));
           jrTextExporter.setParameter(JRTextExporterParameter.PAGE_HEIGHT, pageHeight);
           jrTextExporter.setParameter(JRTextExporterParameter.PAGE_WIDTH, pageWidth);
           jrTextExporter.setParameter(JRTextExporterParameter.CHARACTER_WIDTH, Dimensao.getLargura(new Float(pageWidth), Integer.parseInt(colunas)));

           jrTextExporter.exportReport();

           Io.limpaTabu(pathXML, comum);
        } catch (JRException ex) {
            comum.setGerarPDF("NOK --> " + ex);
            System.err.print(comum.getGerarPDF());
            System.err.print("Erro: " + ex.getStackTrace());
            
            ex.printStackTrace();
        } catch (Exception e){
            comum.setGerarPDF("NOK --> " + e);
            System.err.print(comum.getGerarPDF());
            System.err.print("Erro: " + e.getStackTrace());
            
            e.printStackTrace();
        } finally{
            virtualizer.cleanup();
        }
    }
    
     /**
     * Método que irá consumir XML de dados e gerar o relatório em PDF de acordo com o layout do iReport.
     * Controla a string de parâmetros padronizada para criar Map e enviar lista de parametros para o layout.
     * Irá gerar um arquivo PDF.
     * @param arqXML Arquivo XML que irá prover os dados do relatório
     * @param noItera Nó de iteração do XML
     * @param arqJasper Layout do iReports
     * @param paramValues Array de parâmetros diversos no formato (chave#valor|chave#valor)
     * @param pathXML Path e nome do arquivo PDF
     * @param colunas Número de colunas do relatório
     * @param  comum Parâmetro para controle de erros
     */
    public void gerarRelatorioPDF(String arqXML, String noItera, String arqJasper, String paramValues, String pathXML, String colunas, Comum comum){
        comum.setGerarPDF("OK");
        setParametros(paramValues, comum);
        Locale local = new Locale("pt", "BR");
        parametros.put(JRParameter.REPORT_LOCALE, local);

        try {
            Document document = JRXmlUtils.parse(new File(arqXML));
            JRXmlDataSource xmlDataSource = new JRXmlDataSource(document, noItera);
            xmlDataSource.setLocale(local);

            JasperPrint jasperPrint = JasperFillManager.fillReport(arqJasper, parametros, xmlDataSource);

            JRPdfExporter jrPdfExporter = new JRPdfExporter();
            jrPdfExporter.setParameter(JRExporterParameter.JASPER_PRINT, jasperPrint);
            jrPdfExporter.setParameter(JRExporterParameter.OUTPUT_FILE_NAME, pathXML);

            jrPdfExporter.exportReport();
        } catch (JRException ex) {
            comum.setGerarPDF("NOK --> " + ex);
            System.err.print(comum.getGerarPDF());
            System.err.print("Erro: " + ex.getStackTrace());
            
            ex.printStackTrace();
        } catch (Exception e){
            comum.setGerarPDF("NOK --> " + e);
            System.err.print(comum.getGerarPDF());
            System.err.print("Erro: " + e.getStackTrace());
            
            e.printStackTrace();
        } 
    }
  }