#INCLUDE "RWMAKE.CH"  
#Include "topconn.ch"   

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AGR245B   ºAutor  ³Microsiga           º Data ³  04/24/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³  Programa para Manutencao Romaneio (Incl/Excl/Alter).      º±±
±±º          ³                                                            º±±
±±º          ³  Criar Arquivos:                                           º±±
±±º          ³  SZB - Cabecalho Romaneio de Cargas.                       º±±
±±º          ³  SZC - Itens Romaneio de Cargas.                           º±±
±±º          ³                                                            º±±
±±º          ³  Criar Indices:                                            º±±
±±º          ³  SZB - (1) ZB_FILIAL+ZB_NUM                                º±±
±±º          ³  SZB - (2) ZB_FILIAL+ZB_NUM+ZB_MOTORIS+DTOS(ZB_DTSAIDA)    º±±
±±º          ³  SZC - (1) ZC_FILIAL+ZC_NUM+ZC_DOC                         º±±
±±º          ³                                                            º±±
±±º          ³  Criar Campos                                              º±±
±±º          ³  SF2 - F2_ROMANE 6 C                                       º±±
±±º          ³                                                            º±±
±±º          ³  Appendar o SF2 E SZ9 para o SXB.                          º±±
±±º          ³  Incluir Gatilho                                           º±±
±±º          ³  SZC ZC_SERIE 001                                          º±±
±±º          ³  EXECBLOCK("AGR245D",.F.,.F.)                              º±±
±±º          ³  ZC_COD                                                    º±±
±±º          ³  P                                                         º±±
±±º          ³  N                                                         º±±
±±º          ³                                                            º±±
±±º          ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function AGR245B()
   //ADICIONADO PARA INCLUIR CAMPO COMBOBOX NA TELA
   Local aArray2 := {}
   Local cNomeMot := "" //Chamado 74984
   cForaCombo    := ""
   nLenGrava     := 1

   aHeader  := {}
   nOpc    := 3
  
	DbSelectArea("SX3")
	DbSetOrder(1)
	DbGotop()
	DbSeek("SZC",.T.)
	While !Eof() .And. (SX3->X3_arquivo == "SZC")
		If (Alltrim(SX3->X3_CAMPO) <> "ZC_FILIAL") .And.;
			(Alltrim(SX3->X3_CAMPO) <> "ZC_NUM")
			If X3USO(SX3->X3_USADO)
				nUsado++
				Aadd(aHeader,{Trim(SX3->X3_TITULO),SX3->X3_CAMPO,SX3->X3_PICTURE,;
									SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VLDUSER,;
									SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_ARQUIVO,SX3->X3_CONTEXT,SX3->X3_F3})
			Endif
		EndIf
		
		DbSelectArea("SX3")
		DbSkip()
	Enddo      

	aGetQtd := {}
    Aadd(aGetQtd ,"ZC_DOC")
    Aadd(aGetQtd ,"ZC_SERIE")   
   
	cNum  := SZB->ZB_NUM
	aCols := {}

	DbSelectArea("SZC")
	DbSetOrder(1)
	DbGotop()
	DbSeek(xFilial("SZC")+SZB->ZB_NUM,.T.)
	While !Eof() .And. SZC->ZC_FILIAL == xFilial("SZC");
					 .And. SZC->ZC_NUM	 == SZB->ZB_NUM

      Aadd(aCols,{SZC->ZC_DOC,;
    				SZC->ZC_SERIE,;
      				SZC->ZC_PESO,;
      				SZC->ZC_VOLUME,;
      				SZC->ZC_VALOR,;
      				SZC->ZC_CLIENTE,;
      				SZC->ZC_LOJA,;
      				SZC->ZC_NOME,.F.})

		DbSelectArea("SZC")
		SZC->(DbSkip())
	End		
	
     
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Titulo da Janela                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cTitulo:="Manutencao Romaneio de Cargas"

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Chamada do comando browse                                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	@ 000,000 TO 400,800 DIALOG oDlgQtd TITLE cTitulo

	cMotoris := SZB->ZB_MOTORIS
	DbSelectArea("SZ9")
	DbSetOrder(1)
	DbGotop()
	If DbSeek(xFilial("SZ9")+SZB->ZB_MOTORIS,.T.)
		cNomeMot := SZ9->Z9_NOME
	EndIf	                     	
	DbSelectArea("SZB")
	cPlaca   := SZB->ZB_PLACA
	dDtSaida := SZB->ZB_DTSAIDA
	cKMSaida := SZB->ZB_KMSAIDA
	dDtChega := SZB->ZB_DTCHEGA
	cKmChega := SZB->ZB_KMCHEGA
    cDefBase := SZB->ZB_BASE

    //aDefBase := {"03=BASE","04=IRANI","05=ICARA","02=ARAUCARIA","08=LAGES"} // ITENS DO COMBOBOX BASE DE ORIGEM DA CARGA
    //ADICIONADO PARA INCLUIR CAMPO COMBOBOX NA TELA    

	nCont    := 1
	aDefBase := RetSX3Box(GetSX3Cache("ZB_BASE","X3_CBOX"),,,1)
    
    For nCont := 1 To Len(aDefBase)
       If cForaCombo <> "" .And. Left(aDefBase[nCont][1], nLenGrava) $ cForaCombo
          Loop
       Endif
       AADD(aArray2,aDefBase[nCont][1])
    Next nCont
	
	@ 004,005 Say "Romaneio:" 
	@ 004,050 Get cNum  SIZE 40,10 Pict "@!" When .F.
	
	@ 004,130 Say "Condutor :" 
	@ 004,175 Get cMotoris   SIZE 40,10 F3 "SZ9"

	@ 004,255 Say "Nome Cond:"      	
	@ 004,300 Get cNomeMot   SIZE 70,10 When .F.

	@ 015,005 Say "Placa :"      	
	@ 015,050 Get cPlaca   SIZE 40,10
	
	@ 015,130 Say "Dt Saida:"
	@ 015,175 Get dDtSaida SIZE 40,10
	
   @ 015,255 Say "KM Saida:"
   @ 015,300 Get cKMSaida SIZE 40,10 Pict "@E 999999"
   
	@ 026,005 Say "Dt Chegada:"
	@ 026,050 Get dDtChega SIZE 40,10
	
	@ 026,130 Say "KM Chegada:"
	@ 026,175 Get cKmChega SIZE 40,10 Pict "@E 999999"
	
	@ 026,255 Say "Base Supri:"
    @ 026,300 Combobox cDefBase Items aArray2 Size 50,30 	

	oBrowQtd := MsGetDados():New(043,005,170,390,nOpc,"AllwaysTrue","AllwaysTrue",,.T.,aGetQtd,,,999)
	oBrowQtd:oBrowse:bWhen := {||(len(aCols),.T.)}
	oBrowQtd:oBrowse:Refresh()
    
	@ 180,300 BUTTON "_Gravar" SIZE 38,12 ACTION oGrava()
	@ 180,340 BUTTON "_Sair"   SIZE 38,12 ACTION Close(oDlgQtd) 
	@ 180,10  BUTTON "_Importar" SIZE 38,12 ACTION U_AGR245AI()//Close(oDlgQtd)

	ACTIVATE DIALOG oDlgQtd CENTERED       

  
Return        

Static Function oGrava()

	DbSelectArea("SZB")
	DbSetOrder(1)
	DbGotop()
	If DbSeek(xFilial("SZB")+cNum,.T.)

		DbSelectArea("SZC")
		DbSetOrder(1)
		DbGotop()
		DbSeek(xFilial("SZC")+cNum,.T.)
		While !Eof() .And. SZC->ZC_FILIAL == xFilial("SZC");
					    .And. SZC->ZC_NUM	 == SZB->ZB_NUM
	
			DbSelectArea("SF2")
			DbSetOrder(1)
			DbGotop()
			If DbSeek(xFilial("SF2")+SZC->ZC_DOC+SZC->ZC_SERIE+SZC->ZC_CLIENTE+SZC->ZC_LOJA,.T.)
				DbSelectArea("SF2")
				RecLock("SF2",.F.)
					SF2->F2_ROMANE := ""
				MsUnLock("SF2")
			EndIf
	
			RecLock("SZC",.F.)
				DBDELETE()
			MsUnLock("SZC")
					    
			DbSelectArea("SZC")
			SZC->(DbSkip())					    
		End					    

		DbSelectArea("SZB")
		RecLock("SZB",.F.)
			DBDELETE()			
		MsUnLock("SZB")

	EndIf   
	
    //Validação para alertar sobre itens pendentes de execução. Cesar-SLA 16/03/2018
	If (cEmpAnt == "01" .And. cFilAnt == "06")

		For i:=1 to Len(aCols) 
		                         
			If aCols[i,1] <> " "
			
				cQuery := ""
				cQuery += " SELECT C9_PEDIDO "
				cQuery += " FROM "+RetSqlName("SC9")+" SC9 "
				cQuery += " WHERE SC9.D_E_L_E_T_ = '' "
				cQuery += " AND C9_FILIAL = '06'"
				cQuery += " AND C9_LOCAL = '02'"  
				cQuery += " AND C9_NFISCAL = '"+aCols[i,1]+"'"
				cQuery += " AND C9_SERIENF   = '"+aCols[i,2]+"'"
				cQuery += " AND C9_SERVIC <> ''" 
				cQuery += " AND C9_PEDIDO IN (SELECT DCF_DOCTO FROM DCF010 DCF WHERE DCF.D_E_L_E_T_ = '' AND DCF_STSERV <> '3' GROUP BY DCF_DOCTO ) "  
				cQuery += " GROUP BY C9_PEDIDO "
				cQuery := ChangeQuery(cQuery) 
									
				If (Select("QRYT1") <> 0)
					dbSelectArea("QRYT1")
					dbCloseArea()
				Endif
				TCQuery cQuery NEW ALIAS "QRYT1"
				
				DBSELECTAREA("QRYT1")
				QRYT1->(DBGOTOP())  
				
				If !QRYT1->(EOF())
		
					WHILE !QRYT1->(EOF()) 
						Alert("Pedido: "+Alltrim(QRYT1->C9_PEDIDO)+" não esta totalmente executado!")
					QRYT1->(DBSKIP())
					ENDDO	
					
				EndIf	
				
			EndIf  
						
		Next 
	
	EndIf


   _q := 0  // Contador para gravar a quantidade.  
   nCont := 0
	For _q := 1 to Len(aCols)

      If ( !aCols[_q][Len(aCols[_q])] ) //Deletado    
			If !Empty(aCols[_q,1]) .And. !Empty(aCols[_q,2])
				
				nCont := nCont + 1
				
				DbSelectArea("SZC")
				RecLock("SZC",.T.)
					SZC->ZC_FILIAL		:= xFilial("SZC")
					SZC->ZC_NUM			:= cNum
					SZC->ZC_DOC			:= aCols[_q,1]
					SZC->ZC_SERIE		:= aCols[_q,2]
					SZC->ZC_PESO		:= aCols[_q,3]
					SZC->ZC_VOLUME		:= aCols[_q,4]
					SZC->ZC_VALOR		:= aCols[_q,5]
					SZC->ZC_CLIENTE	:= aCols[_q,6]
					SZC->ZC_LOJA		:= aCols[_q,7]
					SZC->ZC_NOME		:= aCols[_q,8]
				MsUnLock("SZC")
				
				DbSelectArea("SF2")
				DbSetOrder(1)
				DbGotop()
				If DbSeek(xFilial("SF2")+aCols[_q,1]+aCols[_q,2]+aCols[_q,6]+aCols[_q,7],.T.)
					DbSelectArea("SF2")
					RecLock("SF2",.F.)
						SF2->F2_ROMANE := cNum
					MsUnLock("SF2")
				EndIf
			EndIf
		EndIf	
   Next

	If nCont > 0
		RecLock("SZB",.T.)          
			SZB->ZB_FILIAL  := xFilial("SZB")
			SZB->ZB_NUM		:= cNum
			SZB->ZB_MOTORIS	:= cMotoris
			SZB->ZB_PLACA   := cPlaca
			SZB->ZB_DTSAIDA := dDtSaida
			SZB->ZB_KMSAIDA := cKMSaida
			SZB->ZB_DTCHEGA	:= dDtChega
			SZB->ZB_KMCHEGA	:= cKMChega
            SZB->ZB_BASE    := cDefBase
		MsUnLock("SZB")
	EndIf
	   
	Close(oDlgQtd)

Return