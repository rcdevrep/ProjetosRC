#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "PROTHEUS.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AGX618    ºAutor  ³Thiago Padilha      º Data ³  21/07/17   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Retorna tabela atendimento Call Center                    º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function AGX618(lGatilho)
   
   LOCAL cVend    := TKOPERADOR()       
   LOCAL lInicio  := .T.

   Private cTabela := M->UA_TABELA
   Default lGatilho := .F.   
   
   // OBSERVAÇÃO:
   // Cadastrar na validacao do campo UB_PRODUTO: U_AGX618()
   // Criar Gatilho no campo UB_PRODUTO com contra dominio UA_TABElA e a regra U_AGX618(.T.)
   
   //Se for gatilho apenas atualiza a tela e retorna
   If lGatilho
		oGettlv:Enable()
		lTlvhabilita := .T.
		//oEnchtlv:Enable() 
		GETDREFRESH()  
		Return
   Endif	
   
   
   If cEmpAnt == "01" .and. cFilAnt == "06"
         /*
          * regra inserida para buscar a tabela de preços que possui o vinculo com cliente pelo codigo e loja.
          */
         cQuery := ""
         cQuery := "SELECT DA0_CODTAB  "
         cQuery += "  FROM " + RetSqlName("DA0") +" (nolock), " + RetSqlName("DA1") +" (nolock) "
         cQuery += " WHERE DA0_FILIAL  = '" + xFilial("DA0") + "' " 
         cQuery += "   AND DA0_CLIENT  = '" + SA1->A1_COD  + "' " 
         cQuery += "   AND DA0_LOJA    = '" + SA1->A1_LOJA + "' " 
         cQuery += "   AND DA1_CODTAB = DA0_CODTAB "
         cQuery += "   AND DA1_FILIAL = DA0_FILIAL "
         cQuery += "   AND DA1_CODPRO =  '" + SB1->B1_COD + "' " 
         cQuery += "   AND " + RetSqlName("DA0") +".D_E_L_E_T_ <> '*' "
         cQuery += "   AND " + RetSqlName("DA1") +".D_E_L_E_T_ <> '*' "         

         cQuery := ChangeQuery(cQuery)
         If Select("QRY_DA0") <> 0
            dbSelectArea("QRY_DA0")
            dbCloseArea()
         Endif
         TCQuery cQuery NEW ALIAS "QRY_DA0"
		                     
         dbSelectArea("QRY_DA0")
         dbGoTop()
         If ALLTRIM(QRY_DA0->DA0_CODTAB) <> ""
            cTabela      := QRY_DA0->DA0_CODTAB
            M->UA_TABELA := QRY_DA0->DA0_CODTAB
         Else  
           /*
            * regra inserida para buscar a tabela de preços que possui o vinculo com cliente pelo grupo de vendas.
            */
            If ALLTRIM(SA1->A1_GRPVEN) <> "" 
               cQuery := ""
               cQuery := "SELECT DA0_CODTAB FROM " + RetSqlName("DA0") 
               cQuery += " WHERE DA0_FILIAL  = '" + xFilial("DA0") + "' " 
               cQuery += "   AND DA0_GRPCLI  = '" + SA1->A1_GRPVEN + "' " 
               cQuery += "   AND D_E_L_E_T_ <> '*' "

               cQuery := ChangeQuery(cQuery)
               If Select("QRY_DA0") <> 0
                  dbSelectArea("QRY_DA0")
                  dbCloseArea()
               Endif
               TCQuery cQuery NEW ALIAS "QRY_DA0"

               dbSelectArea("QRY_DA0")
               dbGoTop()
               If ALLTRIM(QRY_DA0->DA0_CODTAB) <> ""
                  cTabela      := QRY_DA0->DA0_CODTAB
                  M->UA_TABELA := QRY_DA0->DA0_CODTAB
               Else
                  Alert("Tabela de preço não encontrada para grupo de vendas! Entre em contato com a coordenação de vendas!")
                  cTabela := ""
               EndIf
            EndIf
         EndIf
	EndIf  
	
    //Atualiza Preço    
	TK273CALCULA("UB_PRODUTO")
	MAFISREF("IT_PRODUTO","TK273",M->UB_PRODUTO)

Return .T.