#INCLUDE "protheus.ch"
#INCLUDE "Rtmsr01.ch"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � RTMSR01  � Autor �Patricia A. Salomao    � Data �14.02.2002���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Conhecimento de Transporte Rodoviario de Carga             ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � RTMSR01                                                    ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Gestao de Transporte                                       ���
����������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function RTMSR01()

LOCAL titulo  := STR0001 //"Impressao do Conhecimento de Transporte"
LOCAL cString := "DTP"
LOCAL wnrel   := "RTMSR01"
LOCAL cDesc1  := STR0002 //"Este programa ira listar o Conhecimento de Transporte"
LOCAL cDesc2  := STR0003 //"Rodoviario de Carga."
LOCAL cDesc3  := ""
LOCAL tamanho := "M"

PRIVATE aReturn  := {STR0004,1,STR0005,2, 2, 1, "",1 } //"Zebrado"###"Administracao"
PRIVATE cPerg    := "RTMR01"
PRIVATE nLastKey := 0
PRIVATE lPosic 	 := .T.
//��������������������������������������������������������������Ŀ
//� Verifica as perguntas                                        �
//����������������������������������������������������������������
//��������������������������������������������������������������Ŀ
//� Variaveis utilizadas para parametros                         �
//� mv_par01        	// Lote Inicial 		                		  �
//� mv_par02        	// Lote Final         	         		     �
//� mv_par03        	// Documento De 		      		           �
//� mv_par04        	// Documento Ate      		                 �
//� mv_par05        	// Serie De     	   		                 �
//� mv_par06        	// Serie Ate            	                 �
//� mv_par07        	// Impressao / Reimpressao                  �
//����������������������������������������������������������������
pergunte("RTMR01",.F.)

wnrel:=SetPrint(cString,wnrel,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,"",,Tamanho)

If nLastKey = 27
	Set Filter To
	Return
Endif

SetDefault(aReturn,cString)

If nLastKey = 27
	Set Filter To
	Return
Endif

RptStatus({|lEnd| RTMSR01Imp(@lEnd,wnRel,titulo,tamanho)},titulo)

Return NIL

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �RTMSR01Imp� Autor �Patricia A. Salomao    � Data �14.02.2002���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Chamada do Relat�rio                                       ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � RTMSR01			                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function RTMSR01Imp(lEnd,wnRel,titulo,tamanho)
//��������������������������������������������������������������Ŀ
//� Define Variaveis                                             �
//����������������������������������������������������������������
Local  cLotNfc      := ""
Local  nLin         := 80
Local  cStatus      := "3/4"
Local  aPicICM      := {}
Local  aEnder       := {}
Local  nTotal       := 0
Local  lAgrega 	  := .F. 
Local  aCompFrete   := Array(14,2)      
Local  cNumNotas    := ""
Local  cNumCot      := ""
Local  bCondDTC     := {|| }
Local  aObservacoes := Array(6)
Private cNomRem     := cEndRem    := cCEPRem    := cMunRem    := cEstRem    := cCGCRem    := cInscRem    := ""
Private cNomDev     := cEndDev    := cCEPDev    := cMunDev    := cEstDev    := cCGCDev    := cInscDev    := ""
Private cNomDes     := cEndDes    := cCEPDes    := cMunDes    := cEstDes    := cCGCDes    := cInscDes    := cEndEnt := ""
Private cNomCONDPC  := cEndCONDPC := cCEPCONDPC := cMunCONDPC := cEstCONDPC := cCGCCONDPC := cInscCONDPC := ""
Private cDevFrete   := cTipFrete  := cDestCalc  := ""

SM0->(MsSeek(cEmpAnt+cFilAnt, .T.))
//��������������������������������������������������������������Ŀ
//� Alimenta Arquivo de Trabalho                                 �
//����������������������������������������������������������������
dbSelectArea("DTP")
dbSetOrder(2)
MsSeek(xFilial("DTP") + cFilAnt + mv_par01, .T.)
SetRegua(LastRec())

Do While !Eof() .And. (DTP_FILIAL+DTP_FILORI==xFilial("DTP")+cFilAnt) .And. (DTP_LOTNFC <= mv_par02)
	
	IncRegua()
	
	If Interrupcao(@lEnd)
		Exit
	Endif
	
	If !(DTP->DTP_STATUS $ cStatus)
		DTP->(dbSkip())
		Loop
	EndIf
	
	cLotNfc := DTP_LOTNFC
	cFilOri := DTP_FILORI
	
	dbSelectArea("DT6")
	dbSetOrder(2)
	MsSeek(xFilial("DT6") + cFilOri + cLotNfc)
	
	Do While !Eof() .And. (DT6_FILIAL+DT6_FILORI+DT6_LOTNFC == xFilial("DT6")+ cFilOri + cLotNfc)
		
		If (DT6_FIMP == '1' .And. mv_par07==1) .Or. DT6_DOCTMS <> "2"
			dbSkip()
			loop
		EndIf
		
		If ((DT6_DOC < MV_PAR03) .Or. (DT6_DOC > MV_PAR04)) .Or. ((DT6_SERIE < MV_PAR05) .Or. (DT6_SERIE > MV_PAR06)) .Or.;
			(DT6_SERIE == "PED")
			dbSkip()
			Loop
		EndIf
		
		// Busca as notas do cliente para o 1o percurso.
		If DT6->DT6_PRIPER == StrZero(1, Len(DT6->DT6_PRIPER))
			bCondDTC := {|| !DTC->(Eof()) .And. DTC->(DTC_FILIAL+DTC_FILDOC+DTC_DOCPER+DTC_SERIE) ==;
			DT6->(DT6_FILIAL+DT6_FILDOC+DT6_DOC+DT6_SERIE)}
			
			RTmsr01NFCli(4, bCondDTC, @cNumNotas, @cNumCot, @aEnder)
			
			// Busca as notas do cliente para o 2o percurso.
		Else
			bCondDTC := {|| !DTC->(Eof()) .And. DTC->(DTC_FILIAL+DTC_FILDOC+DTC_DOC+DTC_SERIE) ==;
			DT6->(DT6_FILIAL+DT6_FILDOC+DT6_DOC+DT6_SERIE)}
			
			RTmsr01NFCli(3, bCondDTC, @cNumNotas, @cNumCot, @aEnder)
		EndIf
		
		//-- Itens da Nota Fiscal de Saida
		SD2->(dbSetOrder(3))
		SD2->(MsSeek(xFilial("SD2")+DT6->(DT6_DOC + DT6_SERIE)))
		cCodPro := SD2->D2_COD
		
		aAreaSD2 := SD2->(GetArea())
		SD2->( DbEval( { || IIF(!SD2->(Eof()) .And. D2_PICM <> 0,AADD(aPicICM, Transform(SD2->D2_PICM,PesqPict('SD2','D2_PICM'))) ,.T.) },, ;
		{ || D2_FILIAL+D2_DOC + D2_SERIE == ;
		xFilial("SD2")+DT6->DT6_DOC + DT6->DT6_SERIE } ) )
		RestArea(aAreaSD2)
		
		//-- Nota Fiscal de Saida
		SF2->(dbSetOrder(1))
		SF2->(MsSeek(xFilial("SF2")+DT6->(DT6_DOC + DT6_SERIE)))
		
		//-- Verifica os dados dos Clientes
		RTMSR01DT6()

		nLin := 1                

		If lPosic
			lPosic := .F.
			SETPRC(0,0)
			@ nLin, 001 PSAY "..."
		End
		
		@ nLin, 001 PSAY Chr(27)+chr(48)    //1/6�
		@ nLin, 001 PSAY Chr(15)
		nLin+=1		
		@ nLin,078 PSay SD2->D2_CF        Picture PesqPict("SD2","D2_CF")
		nLin+=1
		@ nLin, 100 PSay DT6->DT6_DOC
		
		nLin+=1
		@ nLin, 081 PSay StrZero(Day(DT6->DT6_DATEMI),2)
		@ nLin, 091 PSay MesExtenso(Month(DT6->DT6_DATEMI))
		@ nLin, 110 PSay StrZero(Year(DT6->DT6_DATEMI),4)
		//-- Imprime cabecalho com dados do Emitente
		//RTMSR01Cabec(@nLin)
		                                                  
		//-- Imprime dados do Remetente / Devedor do Frete
		nLin+=2
		@ nLin,005 PSay cNomRem  //--Nome Rem
		@ nLin,076 PSay cNomDes  //--Nome Destinatario
		//@ nLin,046 PSay cNomDev    //--Nome Devedor
		
		nLin+=1
		@ nLin,005 PSay cEndRem    //-- Endereco Remetente
		//@ nLin,046 PSay cEndDev	   //-- Endereco Devedor
		@ nLin,076 PSay cEndDes    //--Endereco Destinatario
		nLin+=1
		//@ nLin,000 PSay AllTrim(cMunRem)+"/"+cEstRem  //--Municipio/Est. Remetente
		@ nLin,005 PSay AllTrim(cMunRem) //--Municipio
		@ nLin,064 PSay cEstRem  //--Est. Remetente
		//@ nLin,046 PSay AllTrim(cMunDev)+"/"+cEstDev  //--Municipio/Est. Remetente
		@ nLin,076 PSay AllTrim(cMunDes) //Municipio Dest
		@ nLin,135 PSay cEstDes //Est. Dest
		
		//@ nLin,000 PSay cCEPRem+ "  " + AllTrim(cMunRem)+"/"+cEstRem  //--CEP/Municipio/Est. Remetente
		//@ nLin,046 PSay cCEPDev+ "  " + AllTrim(cMunDev)+"/"+cEstDev  //--CEP/Municipio/Est. Remetente
		nLin+=1
		@ nLin,005 PSay cCGCRem   //-- CGC
		@ nLin,050 PSay cInscRem  //-- Inscricao Remetente
		//@ nLin,046 PSay cCGCDev+ "  " + cInscDev  //-- CGC/Inscricao Devedor
		@ nLin,076 PSay cCGCDes	    //-- CGC
		@ nLin,121 PSay cInscDes	//-- Inscricao Destinatario
		nLin+=2
		
		//@ nLin,000 PSay cNomDes  //--Nome Destinatario
		
		//-- Redespacho / Consignatario
		//If cDevFrete=="4"
		//	@ nLin,046 PSay "XX"
		//ElseIf cDevFrete=="3"
		//	@ nLin,061 PSay "XX"
		//EndIf
		
		//-- CIF / FOB
		If cTipFrete == "1"
			@ nLin,058 PSay "XX"
		Else
			@ nLin,032 PSay "XX"
		EndIf
		@ nLin,078 PSay cDestCalc	//-- Destino de Calculo

		//nLin+=1
		//@ nLin,000 PSay cEndDes     //--Endereco Destinatario
		//@ nLin,046 PSay cNomCONDPC //-- Nome Consignatario ou Despachante
		//nLin+=1
		//@ nLin,000 PSay cCEPDes + "  " + AllTrim(cMunDes)+"/"+cEstDes //--CEP/Municipio/Est.
		//@ nLin,046 PSay cEndCONDPC //-- End. Consignatario ou Despachante
		//nLin+=1
		//@ nLin,000 PSay cCGCDes+ "  " + cInscDes	//-- CGC/Inscricao Destinatario
		//@ nLin,046 PSay cCEPCONDPC + "  " + AllTrim(cMunCONDPC)+" "+cEstCONDPC //--CEP/Municipio/Est. Consig. ou Despach.
		//nLin+=1
		//@ nLin,046 PSay cCGCCONDPC+ "  " + cInscCONDPC	//-- CGC/Inscricao do Consig. ou Despach.
		
		//nLin+=1
		//-- Imprime Endereco para Coleta
		//@ nLin,000 PSay cEndRem    //-- Endereco Coleta
		//-- CIF / FOB
		//If cTipFrete == "1"
		//	@ nLin,048 PSay "XX"
		//Else
		//	@ nLin,057 PSay "XX"
		//EndIf
		//@ nLin,071 PSay cDestCalc	//-- Destino de Calculo
		
		//nLin+=1
		//@ nLin,000 PSay cCEPRem+ "  " + AllTrim(cMunRem)+"/"+cEstRem //-- CEP/Municipio/Est. Coleta
		//nLin+=1
		//@ nLin,000 PSay cCGCRem+ "  " + cInscRem //-- CGC/Inscricao Coleta
		
		//-- Tipo de Transporte : Rodoviario/Aereo
		//If DC5->(MsSeek(xFilial("DC5")+DTC->DTC_SERVIC))
		//	If DC5->DC5_TIPTRA == '1'
		//		@ nLin,047 PSay "XX"
		//	ElseIf DC5->DC5_TIPTRA == '2'
		//		@ nLin,067 PSay "XX"
		//	EndIf
		//EndIf
		
		aEval(aCompFrete, {|x| x[1]:= ""})
		aEval(aCompFrete, {|x| x[2]:=  0})

		
		nX := 1
		DT8->(dbSetOrder(2))
		DT8->(MsSeek(xFilial("DT8")+DT6->(DT6_FILDOC+DT6_DOC+DT6_SERIE)))
		Do While !DT8->(Eof()) .And. DT8->(DT8_FILIAL+DT8_FILDOC+DT8_DOC+DT8_SERIE) == DT6->(DT6_FILIAL+DT6_FILDOC+DT6_DOC+DT6_SERIE)
			If nX > 10
				Exit
			EndIf
			If DT8->DT8_CODPAS <> "TF"
				aCompFrete[nx][1] := DT8->DT8_CODPAS
			EndIf
			nX++
			DT8->(dbSkip())
		EndDo
		
		nX     := 1
		nTotal := 0
		DT8->(MsSeek(xFilial("DT8")+DT6->(DT6_FILDOC+DT6_DOC+DT6_SERIE)))
		Do While !DT8->(Eof()) .And. DT8->(DT8_FILIAL+DT8_FILDOC+DT8_DOC+DT8_SERIE) == DT6->(DT6_FILIAL+DT6_FILDOC+DT6_DOC+DT6_SERIE)
			nZ := nX
			If DT9->(MsSeek(xFilial("DT9")+DT6->DT6_NCONTR+DT8->DT8_CODPAS))
				nX := Ascan(aCompFrete, {|x| x[1] == DT9->DT9_AGRPAS })
				If nX > 0
					lAgrega := .T.
					nX      := Val(DT9->DT9_AGRPAS)
				Else
					lAgrega := .F.
					nX      := nZ
				EndIf
			EndIf
			If DT8->DT8_CODPAS <> "TF"
				If nX <= 10
					aCompFrete[nx][1] := IIf(!lAgrega,DT8->DT8_CODPAS,aCompFrete[nx][1])
					aCompFrete[nx][2] += DT8->DT8_VALTOT
				Else
					aCompFrete[11][1] := "XX"
					aCompFrete[11][2] += DT8->DT8_VALTOT
					nTotal += DT8->DT8_VALTOT
				EndIf 
				
				If DT8->DT8_CODPAS == "05"  
					aCompFrete[13][1] := "05"
					aCompFrete[13][2] +=  DT8->DT8_VALTOT
				Else                                     
					aCompFrete[13][1] := "05"
					aCompFrete[13][2] +=  0
				EndIf

				If DT8->DT8_CODPAS == "06"  
					aCompFrete[14][1] := "06"
					aCompFrete[14][2] +=  DT8->DT8_VALTOT
				Else                                     
					aCompFrete[14][1] := "06"
					aCompFrete[14][2] +=  0
				EndIf				
				
				
				nTotal += DT8->DT8_VALTOT
			Else
				aCompFrete[12][1] := "TF"
				aCompFrete[12][2] :=  nTotal
			EndIf
			nX := nZ
			nX++
			DT8->(dbSkip())
		EndDo
        
		//-- Pesquisa Grupo do Produto
		nLin+=6
		SB1->(dbSetOrder(1))
		If SB1->(dbSeek(xFilial("SB1")+DTC->DTC_CODPRO))
			SBM->(dbSetOrder(1))
			If SBM->(dbSeek(xFilial("SBM")+SB1->B1_GRUPO))
				@ nLin,000 PSay SubStr(SBM->BM_DESC,1,20) Picture PesqPict("SBM","BM_DESC")
			EndIf
		EndIf

		@ nLin,015 PSay cNumNotas // Notas Fiscais
		@ nLin,045 PSay DT6->DT6_VALMER   Picture PesqPict("DT6","DT6_VALMER") // Valor Mercadoria
		@ nLin,094 PSay DT6->DT6_QTDVOL   Picture PesqPict("DT6","DT6_QTDVOL") // Quantidade
		@ nLin,110 PSay DTC->DTC_CODEMB   Picture PesqPict("DTC","DTC_CODEMB") // Especie
		@ nLin,123 PSay DT6->DT6_PESO     Picture PesqPict("DT6","DT6_PESO") // Peso

		nLin+=8                  
		If aCompFrete[13][2] == 0 //componente de frete
			@ nLin,015 PSay aCompFrete[12][2] Picture PesqPict("DT8","DT8_VALPAS")
		else
			@ nLin,015 PSay aCompFrete[13][2] Picture PesqPict("DT8","DT8_VALPAS")		
		EndIf                            

		If aCompFrete[14][2] == 0 //componente de pedagio
			@ nLin,040 PSay aCompFrete[14][2] Picture PesqPict("DT8","DT8_VALPAS")
		else
			@ nLin,040 PSay aCompFrete[14][2] Picture PesqPict("DT8","DT8_VALPAS")		
		EndIf                            
		
		
		@ nLin,085 PSay aCompFrete[12][2] Picture PesqPict("DT8","DT8_VALPAS")
		@ nLin,100 PSay SF2->F2_BASEICM   Picture PesqPict("SF2","F2_BASEICM")
		If Len(aPicICM) > 0
			@ nLin,118 PSay aPicICM[1]
		Else
			@ nLin,118 PSay 0 Picture PesqPict("SD2","D2_PICM")
		EndIf             
		@ nLin,122 PSay SF2->F2_VALICM  Picture PesqPict("SF2","F2_VALICM")
 		
		//-- Imprime Endereco para Coleta
		nLin+=2
		@ nLin,000 PSay cEndRem    //-- Endereco Coleta
		@ nLin,045 PSay cEndEnt
		nLin+=1
		@ nLin,000 PSay cCEPRem+ "  " + AllTrim(cMunRem)+"/"+cEstRem //-- CEP/Municipio/Est. Coleta
		nLin+=1
		@ nLin,000 PSay cCGCRem+ "  " + cInscRem //-- CGC/Inscricao Coleta
//*****		
//		nLin+=3
//		@ nLin,000 PSay "PRONAC 096198 MATERIAL DE INSTRUMENTOS FEMUSC"
		                                        
		
		

		nLin+=14
		@ nLin,000 PSay "  "
		
		//-- Endereco para Entrega
		//@ nLin++,000 PSay cEndEnt
		//nLin++
				
		//@ nLin,048 PSay DTC->DTC_CODEMB   Picture PesqPict("DTC","DTC_CODEMB")
		//@ nLin,071 PSay aCompFrete[1][2]  Picture PesqPict("DT8","DT8_VALPAS")
		//nLin++
		//@ nLin,048 PSay DT6->DT6_QTDVOL   Picture PesqPict("DT6","DT6_QTDVOL")
		//@ nLin,071 PSay aCompFrete[2][2]  Picture PesqPict("DT8","DT8_VALPAS")
		//nLin++
		//@ nLin,000 PSay cNumNotas
		//@ nLin,071 PSay aCompFrete[3][2]  Picture PesqPict("DT8","DT8_VALPAS")
		//nLin++
		//@ nLin,048 PSay DT6->DT6_PESO     Picture PesqPict("DT6","DT6_PESO")
		//@ nLin,071 PSay aCompFrete[4][2]  Picture PesqPict("DT8","DT8_VALPAS")
		//nLin++
		//@ nLin,048 PSay DT6->DT6_PESOM3   Picture PesqPict("DT6","DT6_PESOM3")
		//@ nLin,071 PSay aCompFrete[5][2]  Picture PesqPict("DT8","DT8_VALPAS")
		//nLin++

		//RTMSR01Obs(@aObservacoes)

		//@ nLin,000 PSay aObservacoes[1]
		//@ nLin,048 PSay DT6->DT6_VALMER   Picture PesqPict("DT6","DT6_VALMER")
		//@ nLin,071 PSay aCompFrete[6][2]  Picture PesqPict("DT8","DT8_VALPAS")
		//nLin++
		//@ nLin,000 PSay aObservacoes[2]
		//@ nLin,048 PSay DTC->DTC_BASSEG   Picture PesqPict("DTC","DTC_BASSEG")
		//@ nLin,071 PSay aCompFrete[7][2]  Picture PesqPict("DT8","DT8_VALPAS")
		//nLin++
		//@ nLin,000 PSay aObservacoes[3]
		//@ nLin,048 PSay DT6->DT6_TABFRE+DT6->DT6_TIPTAB+DT6->DT6_SEQTAB
		//@ nLin,071 PSay aCompFrete[8][2]  Picture PesqPict("DT8","DT8_VALPAS")
		//nLin++
		//@ nLin,000 PSay aObservacoes[4]
		//@ nLin,048 PSay DTC->DTC_CTRDPC
		//@ nLin,071 PSay aCompFrete[9][2]  Picture PesqPict("DT8","DT8_VALPAS")
		//nLin++
		//@ nLin,000 PSay aObservacoes[5]
		//@ nLin,071 PSay aCompFrete[10][2] Picture PesqPict("DT8","DT8_VALPAS")
		//nLin++
		//@ nLin,000 PSay aObservacoes[6]
		//@ nLin,071 PSay aCompFrete[11][2] Picture PesqPict("DT8","DT8_VALPAS")
		//nLin+=3
		//@ nLin,080 PSay aCompFrete[12][2] Picture PesqPict("DT8","DT8_VALPAS")
		//nLin+=2
		//@ nLin,071 PSay SD2->D2_CF        Picture PesqPict("SD2","D2_CF")
		//nLin++
		//@ nLin,052 PSay SF2->F2_BASEICM   Picture PesqPict("SF2","F2_BASEICM")
		//If Len(aPicICM) > 0
		//	@ nLin,071 PSay aPicICM[1]
		//Else
		//	@ nLin,071 PSay 0 Picture PesqPict("SD2","D2_PICM")
		//EndIf
		//nLin++
		//@ nLin,052 PSay SF2->F2_VALICM  Picture PesqPict("SF2","F2_VALICM")
		//@ nLin,071 PSay DT6->DT6_DATEMI
		//@ nLin,084 PSay DT6->DT6_HOREMI Picture PesqPict("DT6","DT6_HOREMI")
		//nLin+=2
		//@ nLin,071 PSay cFilAnt
		//@ nLin,080 PSay DT6->DT6_DOC
		//nLin+=2
		//@ nLin,010 PSay "Lote : " + DTP->DTP_LOTNFC
		//@ nLin,026 PSay STR0006 //"Endereco(s) :  "
		//If Len(aEnder) > 0
		//	nCol := 42
		//	For nX := 1 to  Len(aEnder)
		//		@ nLin,nCol PSay aEnder[nX]
		//		nCol+=Len(aEnder[nX])+1
		//	Next
		//EndIf
		
		// Imprime o numero da cotacao.
		//If !Empty(cNumCot)
		//	nLin += 1
		//	@ nLin, 010 PSay "No. Cotacao : " + cNumCot
		//EndIf
		  
		SetPgEject(.F.)
		SETPRC(0,0)
		
		//-- Atualiza campo DT6_FIMP (Flag de Impressao)
		RecLock("DT6", .F.)
		DT6_FIMP := "1"
		MsUnlock()
		
		DT6->(dbSkip())
	EndDo
	
	dbSelectArea("DTP")
	dbSkip()
	
EndDo

//��������������������������������������������������������������Ŀ
//� Se em disco, desvia para Spool                               �
//����������������������������������������������������������������
If aReturn[5] == 1
	Set Printer To
	dbCommitAll()
	OurSpool(wnrel)
Endif

MS_FLUSH()

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �RTMSR01Cab� Autor �Patricia A. Salomao    � Data �14.02.2002���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Imprime Cabecalho com os Dados da Empresa                  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � RTMSR01Cabec(ExpN1)                                        ���
�������������������������������������������������������������������������Ĵ��
���Parametro � ExpN1 - No. da Linha                                       ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � RTMSR01			                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function RTMSR01Cabec(nLin)
nLin:=0
@ 00,00 PSAY AvalImp(132)

@nLin++,021 PSay SM0->M0_CODFIL+" "+SM0->M0_FILIAL+" "+SM0->M0_NOME
@nLin++,021 PSay SM0->M0_ENDCOB
@nLin++,021 PSay SM0->M0_CEPCOB+" "+SM0->M0_ENDCOB+" "+SM0->M0_ESTCOB
@nLin++,021 PSay SM0->M0_TEL+" "+SM0->M0_FAX
@nLin++,021 PSay SM0->M0_CGC+" "+SM0->M0_INSC
nLin+=3

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �RTMSR01DT6� Autor �Patricia A. Salomao    � Data �14.02.2002���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Verifica todos os clientes                                 ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � RTMSR01DT6()                                               ���
�������������������������������������������������������������������������Ĵ��
���Parametro � Nenhum                                                     ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � RTMSR01			                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function RTMSR01DT6()

Local lConsDesp := .F.  
Local aAreaDT6  := DT6->(GetArea())		
Local aCliCalc  := {}
Local cImpDev   := ""

//-- Dados do Consignatario                         
cNomCONDPC  := cEndCONDPC := cCEPCONDPC := cMunCONDPC := cEstCONDPC := cCGCCONDPC := cInscCONDPC := ""

cDevFrete := DT6->DT6_DEVFRE
cTipFrete := DT6->DT6_TIPFRE

//-- Dados do Remetente
SA1->(dbSetOrder(1))
SA1->(MsSeek(xFilial()+DT6->DT6_CLIREM+DT6->DT6_LOJREM))
cNomRem  := SA1->A1_NOME
cEndRem  := SA1->A1_END
cCEPRem  := SA1->A1_CEP
cMunRem  := SA1->A1_MUN
//cEstRem  := SA1->A1_ESTADO
cEstRem  := SA1->A1_EST
cCGCRem  := SA1->A1_CGC
DV3->(dbSetOrder(1))
If DV3->(MsSeek(xFilial("DV3") + DTC->DTC_CLIREM + DTC->DTC_LOJREM + DTC->DTC_SQIREM))
	cInscRem := DV3->DV3_INSCR
Else
	cInscRem := SA1->A1_INSCR
EndIf		

//-- Dados do Destinatario
SA1->(MsSeek(xFilial()+DT6->DT6_CLIDES+DT6->DT6_LOJDES))
cNomDes  := SA1->A1_NOME
cEndDes  := SA1->A1_END
cCEPDes  := SA1->A1_CEP
cMunDes  := SA1->A1_MUN
//cEstDes  := SA1->A1_ESTADO
cEstDes  := SA1->A1_EST
cCGCDes  := SA1->A1_CGC
cInscDes := SA1->A1_INSCR
cEndEnt  := SA1->A1_ENDENT

//-- Dados do Devedor
SA1->(MsSeek(xFilial()+DT6->DT6_CLIDEV+DT6->DT6_LOJDEV))
cNomDev  := SA1->A1_NOME
cEndDev  := SA1->A1_END
cCEPDev  := SA1->A1_CEP
cMunDev  := SA1->A1_MUN
//cEstDev  := SA1->A1_ESTADO
cEstDev  := SA1->A1_EST
cCGCDev  := SA1->A1_CGC
cInscDev := SA1->A1_INSCR

aCliCalc := TmsCliCalc(DT6->DT6_CLIREM,DT6->DT6_LOJREM,DT6->DT6_CLIDES,DT6->DT6_LOJDES)
		
If !Empty( aCliCalc )
	cImpDev := aCliCalc[3]  // Imprime Devedor do Frete ?
EndIf
                         
//-- Se o Devedor do Frete for o Consignatario ou o Despachante
If cImpDev == StrZero(1, Len(DTI->DTI_IMPDEV)) .And. (cDevFrete  == "3" .Or. cDevFrete  == "4")
    //-- Dados do Consignatario ou Despachante
	If cDevFrete=="4"
		SA1->(MsSeek(xFilial()+DT6->DT6_CLIDPC+DT6->DT6_LOJDPC))
	ElseIf cDevFrete=="3"
		SA1->(MsSeek(xFilial()+DT6->DT6_CLICON+DT6->DT6_LOJCON))
	EndIf
	cNomCONDPC  := SA1->A1_NOME
	cEndCONDPC  := SA1->A1_END
	cCEPCONDPC  := SA1->A1_CEP
	cMunCONDPC  := SA1->A1_MUN
	//cEstCONDPC  := SA1->A1_ESTADO
	cEstCONDPC  := SA1->A1_EST
	cCGCCONDPC  := SA1->A1_CGC
	cInscCONDPC := SA1->A1_INSCR
EndIf

//-- Destino de Calculo
DUY->(dbSetOrder(1))
If DUY->(MsSeek(xFilial("DUY")+ DT6->DT6_CDRCAL ))
	cDestCalc := DUY->DUY_DESCRI+"  "+DUY->DUY_EST
EndIf	          

RestArea(aAreaDT6)

Return


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �RTmsr01NfC� Autor �Robson Alves           � Data �09.10.2002���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Busca as Nf's do Cliente.                                  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � ExpA1:=TmsPesoVge(ExpC1,ExpC2)                             ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpN1 = Indice do DTC.                                     ���
���          � ExpB1 = Bloco com a condicao do While.                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������*/
Static Function RTmsr01NFCli(nOrdem, bBloco, cNumNotas, cNumCot, aEnder)
Local aAreaDTC := {}
Local aAreaDUH := {}

//-- Notas Fiscais do Cliente
DTC->(dbSetOrder(nOrdem))
DTC->(MsSeek(xFilial("DTC")+DT6->(DT6_FILDOC+DT6_DOC+DT6_SERIE)))

aAreaDTC  := DTC->(GetArea())
cNumNotas := ""

While Eval(bBloco)
	//-- Enderecamento de Notas Fiscais
	DUH->(dbSetOrder(1))
	DUH->(MsSeek(xFilial("DUH")+DTC->(DTC_FILORI+DTC_NUMNFC+DTC_SERNFC+DTC_CLIREM+DTC_LOJREM)))
	
	aAreaDUH := DUH->(GetArea())
	DUH->( DbEval( { || IIf(Ascan(aEnder, {|x| x == AllTrim(DUH->DUH_LOCALI)+"/" })== 0,AADD(aEnder,AllTrim(DUH_LOCALI)+"/" ),.T.) },, ;
	{ || DUH_FILIAL+DUH_FILORI+DUH_NUMNFC+DUH_SERNFC+DUH_CLIREM+DUH_LOJREM == ;
	xFilial("DTC")+DTC->(DTC_FILORI+DTC_NUMNFC+DTC_SERNFC+DTC_CLIREM+DTC_LOJREM) } ) )
	RestArea(aAreaDUH)
	
	cNumNotas += "/"+DTC->DTC_NUMNFC
	cNumCot   := DTC->DTC_NUMCOT // Numero da cotacao.
	
	DTC->(dbSkip())
EndDo
RestArea(aAreaDTC)

Return Nil
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �RTMSR01Obs� Autor � Robson Alves          � Data �19.11.02  ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Obtem as observacoes.                                      ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �RTMSR01Obs(ExpA1)                                           ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpA1 = Array para devolver as observacoes.                ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
���Programador � Data   � BOPS �  Motivo da Alteracao                     ���
�������������������������������������������������������������������������Ĵ��
���            �        �      �                                          ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function RTMSR01Obs(aObservacoes)
Local cObs  := ""
Local cObs1 := ""
Local cObs2 := ""
Local nI    := 1

AFill(aObservacoes, Space(40))

/* Obtem a observacao fiscal. */
cObs  := StrTran(MsMM(DT6->DT6_CODMSG,80),Chr(13),"")
cObs  := StrTran(cObs, Chr(10),"")
cObs1 := SubStr(cObs,  1, 40)
cObs2 := SubStr(cObs, 41, 40)
If !Empty(cObs1)
	aObservacoes[nI] := cObs1
	nI += 1
	If !Empty(cObs2)
		aObservacoes[nI] := cObs2
		nI += 1
	EndIf	
EndIf

/* Obtem a observacao do conhecimento. */
DUO->(dbSetOrder(1))
If DUO->(MsSeek(xFilial("DUO") + DTC->DTC_CLIREM + DTC->DTC_LOJREM))
	cObs  := StrTran(MsMM(DUO->DUO_CDOCTR,80),Chr(13),"")
	cObs  := StrTran(cObs, Chr(10),"")
	cObs1 := SubStr(cObs,  1, 40)
	cObs2 := SubStr(cObs, 41, 40)
	If !Empty(cObs1)
		aObservacoes[nI] := cObs1
		nI += 1
		If !Empty(cObs2)
			aObservacoes[nI] := cObs2
			nI += 1
		EndIf	
	EndIf
EndIf	

/* Obtem a observacao do cliente. */
cObs  := StrTran(MsMM(DTC->DTC_CODOBS,80),Chr(13),"")
cObs  := StrTran(cObs, Chr(10),"")
cObs1 := SubStr(cObs,  1, 40)
cObs2 := SubStr(cObs, 41, 40)
If !Empty(cObs1)
	aObservacoes[nI] := cObs1
	nI += 1
	If !Empty(cObs2)
		aObservacoes[nI] := cObs2
		nI += 1
	EndIf	
EndIf

Return Nil