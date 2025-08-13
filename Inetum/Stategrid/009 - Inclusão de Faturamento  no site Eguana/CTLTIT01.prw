
/*---------------------------------------------------------------------*
 | Func:  CTLTIT01                                                     |
 | Autor: Jader Berto                                                  |
 | Data:  16/08/2024                                                   |
 | Desc:  Função que cria o arquivo XML                                |
 *---------------------------------------------------------------------*/
         
User Function CTLTIT01()
    Local aArea := GetArea()
    Local cArquivo := "titulo_"+Alltrim(SE1->E1_FILIAL) + Alltrim(SE1->E1_PREFIXO) + Alltrim(SE1->E1_NUM) + Alltrim(SE1->E1_PARCELA) + ".xml"
    Local cXML := ""
    Private cPathXML:= "\cci_xml"
     

	DbSelectArea("SA1")
	SA1->(DbSetOrder(1))
	If SA1->(DbSeek(xFilial("SA1") + SE1->(E1_CLIENTE+E1_LOJA)))

    	DbSelectArea("SC5")
        SC5->(DbSetOrder(1))
        If SC5->(DbSeek(xFilial("SC5") + SE1->E1_PEDIDO))
            
            If !ExistDir(cPathXML)
                MakeDir(cPathXML)
            EndIf        
            cPathXML += '\'+ Alltrim(Replace(Replace(Replace(SA1->A1_CGC,'.',''),'-',''),'/',''))
            If !ExistDir(cPathXML)
                MakeDir(cPathXML)
            EndIf
            cPathXML += '\'+ Alltrim(SE1->E1_CLIENTE)+ Alltrim(SE1->E1_LOJA)
            If !ExistDir(cPathXML)
                MakeDir(cPathXML)
            EndIf
            cPathXML += '\'+ Year2Str(SE1->E1_EMISSAO)
            If !ExistDir(cPathXML)
                MakeDir(cPathXML)
            EndIf      
            cPathXML += '\'+ Month2Str(SE1->E1_EMISSAO)
            If !ExistDir(cPathXML)
                MakeDir(cPathXML)
            EndIf  

            If File(cPathXML+'\'+cArquivo)
                FErase(cPathXML+'\'+cArquivo)
            EndIf
            
            //Monta o XML
            cXML += "<?xml version='1.0' encoding='UTF-8' ?>"+CHR(13)+CHR(10)
            cXML += "<dados>"+CHR(13)+CHR(10)
            cXML += "<data>"+dToC(dDataBase)+"</data>"+CHR(13)+CHR(10)
            cXML += "<hora>"+Time()+"</hora>"+CHR(13)+CHR(10)

            cXML += "<cliente>"+CHR(13)+CHR(10)
            cXML += "    <nomecliente>"+Alltrim(SA1->A1_NOME)+"</nomecliente>"+CHR(13)+CHR(10)
            cXML += "    <cnpj>"+Alltrim(Replace(Replace(Replace(SA1->A1_CGC,'.',''),'-',''),'/',''))+"</cnpj>"+CHR(13)+CHR(10)
            cXML += "    <endereco>"+Capital(Alltrim(SA1->A1_END))+"</endereco>"+CHR(13)+CHR(10)
            
            cXML += "    <complemento>"+Capital(Alltrim(SA1->A1_COMPLEM))+"</complemento>"+CHR(13)+CHR(10)
            cXML += "    <bairro>"+Capital(Alltrim(SA1->A1_BAIRRO))+"</bairro>"+CHR(13)+CHR(10)
            cXML += "    <cidade>"+Capital(Alltrim(SA1->A1_MUN))+"</cidade>"+CHR(13)+CHR(10)
            cXML += "    <uf>"+Capital(Alltrim(SA1->A1_EST))+"</uf>"+CHR(13)+CHR(10)
            cXML += "    <cep>"+Alltrim(SA1->A1_CEP)+"</cep>"+CHR(13)+CHR(10)
            
            cXML += "</cliente>"+CHR(13)+CHR(10)
            cXML += "<contrato>"+CHR(13)+CHR(10)
            cXML += "   <nome>"+Alltrim(SC5->C5_MDCONTR)+"</nome>"+CHR(13)+CHR(10)    
            cXML += "   <tipo>"+Alltrim(SE1->E1_PREFIXO)+"</tipo>"+CHR(13)+CHR(10)   
            cXML += "   <dtvencimento>"+dToC(SE1->E1_VENCTO)+"</dtvencimento>"+CHR(13)+CHR(10)    
            cXML += "   <valor>"+cValToChar(SE1->E1_VALOR)+"</valor>"+CHR(13)+CHR(10)     
            cXML += "   <multa>"+cValToChar(SE1->E1_MULTA)+"</multa>"+CHR(13)+CHR(10)    
            cXML += "   <csll>"+cValToChar(SE1->E1_CSLL)+"</csll>"+CHR(13)+CHR(10)    
            cXML += "   <cofins>"+cValToChar(SE1->E1_COFINS)+"</cofins>"+CHR(13)+CHR(10)      
            cXML += "   <pis>"+cValToChar(SE1->E1_PIS)+"</pis>"+CHR(13)+CHR(10)   
            cXML += "   <inss>"+cValToChar(SE1->E1_INSS)+"</inss>"+CHR(13)+CHR(10)   
            cXML += "   <iss>"+cValToChar(SE1->E1_ISS)+"</iss>"+CHR(13)+CHR(10)   
            cXML += "   <juros>"+cValToChar(SE1->E1_JUROS)+"</juros>"+CHR(13)+CHR(10)   
            cXML += "   <irrf>"+cValToChar(SE1->E1_IRRF)+"</irrf>"+CHR(13)+CHR(10)  
            cXML += "   <parcela>"+Alltrim(SE1->E1_PARCELA)+"</parcela>"+CHR(13)+CHR(10)      
            cXML += "</contrato>"+CHR(13)+CHR(10)


            /*
            cXML += "    <filial>"+Alltrim(SE1->E1_FILIAL)+"</filial>"+CHR(13)+CHR(10)
            cXML += "    <prefixo>"+Alltrim(SE1->E1_PREFIXO)+"</prefixo>"+CHR(13)+CHR(10)
            cXML += "    <documento>"+Alltrim(SE1->E1_NUM)+"</documento>"+CHR(13)+CHR(10)
            cXML += "    <parcela>"+Alltrim(SE1->E1_PARCELA)+"</parcela>"+CHR(13)+CHR(10)
            cXML += "    <tipo>"+Alltrim(SE1->E1_TIPO)+"</tipo>"+CHR(13)+CHR(10)
            cXML += "    <natureza>"+Alltrim(SE1->E1_NATUREZ)+"</natureza>"+CHR(13)+CHR(10)
            cXML += "    <codcliente>"+Alltrim(SE1->E1_CLIENTE)+"</codcliente>"+CHR(13)+CHR(10)
            cXML += "    <lojacliente>"+Alltrim(SA1->A1_LOJA)+"</lojacliente>"+CHR(13)+CHR(10)
            cXML += "    <dtemissao>"+DTOC(SE1->E1_EMISSAO)+"</dtemissao>"+CHR(13)+CHR(10)
            cXML += "    <dtvencto>"+DTOC(SE1->E1_VENCTO)+"</dtvencto>"+CHR(13)+CHR(10)
            cXML += "    <dtvenctoreal>"+DTOC(SE1->E1_VENCREA)+"</dtvenctoreal>"+CHR(13)+CHR(10)
            cXML += "    <valor>"+cValToChar(SE1->E1_VALOR)+"</valor>"+CHR(13)+CHR(10)
            cXML += "    <dtbaixa>"+DTOC(SE1->E1_BAIXA)+"</dtbaixa>"+CHR(13)+CHR(10)
            cXML += "    <historico>"+Alltrim(SE1->E1_HIST)+"</historico>"+CHR(13)+CHR(10)
            */
            cXML += "</dados>"+CHR(13)+CHR(10)
            
            //Finalizando o Handle
            MEMOWRITE(cPathXML+'\'+cArquivo, cXML )

        Endif
    Else
        Help(" ",1,"NOMOVADT",,"Cliente não identificado.")
        Return 
    EndIf

         
    //Se houve erro na criação

     
    RestArea(aArea)
Return
