#INCLUDE "RWMAKE.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AGR246   ºAutor  ³Microsiga           º Data ³  04/24/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³  Programa Relatorio Romaneio de Cargas.                    º±±
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

User Function AGR246()

	Private cPerg    := "AGR246"
	Private aTotProd := {}
	
	SetPrvt("cNomMot")
	SetPrvt("cNomeForn")

	cString:="SZB"
	cDesc1:= OemToAnsi("Este programa tem como objetivo, impressao do Romaneio de Cargas")
	cDesc2:= OemToAnsi("Agricopel")
	cDesc3:= ""
	tamanho:="M"
	nTipo  := 18
	aReturn := { "Zebrado", 1,"Administracao", 1, 2, 1, "",1 }
	nomeprog:="AGR246"
	aLinha  := { }
	nLastKey := 0
	lEnd := .f.
	titulo      :="Romaneio de Cargas Agricopel"
	cabec1      :=""
	//cabec1      :="NrNota  Peso Kg  Volumes   Valor R$  Cliente  "
	//             XXXXXX  9999.99      999  99.999.99  XXXXXX  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
	//             12345678901234567890123456789012345678901234567890123456789012345678901234567890
	//                      1         2         3         4         5         6         7         8

	cabec2      :=""
	cCancel := "***** CANCELADO PELO OPERADOR *****"
	nLin  := 80
	m_pag := 0  //Variavel que acumula numero da pagina

	CriaPerg()

	wnrel:="AGR246"            //Nome Default do relatorio em Disco
	SetPrint(cString,wnrel,cPerg,titulo,cDesc1,cDesc2,cDesc3,.F.,"",,tamanho)

	If nLastKey == 27
		Set Filter To
		Return
	Endif

	SetDefault(aReturn,cString)

	If nLastKey == 27
		Set Filter To
		Return
	Endif

	RptStatus({|| RptDetail() })
Return

Static Function RptDetail

	Local _i := 0 

	DbSelectArea("SZB")
	DbSetOrder(2)  // FILIAL+ROMANEIO+CONDUTOR+DATA SAIDA
	DbGotop()
	SetRegua(RecCount())
	DbSeek(xFilial("SZB")+MV_PAR01,.T.)
	While !Eof() .And. SZB->ZB_FILIAL 	== xFilial("SZB");
	.And. SZB->ZB_NUM    	<= MV_PAR02

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica o cancelamento pelo usuario                                ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lAbortPrint
			@nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
			Exit
		Endif

		If SZB->ZB_MOTORIS < MV_PAR03 .Or. SZB->ZB_MOTORIS > MV_PAR04
			DbSelectArea("SZB")
			SZB->(DbSkip())
			Loop
		EndIf

		If DTOS(SZB->ZB_DTSAIDA) < DTOS(MV_PAR05) .Or. DTOS(SZB->ZB_DTSAIDA) > DTOS(MV_PAR06)
			DbSelectArea("SZB")
			SZB->(DbSkip())
			Loop
		EndIf

		cNomMot := Space(30)
		DbSelectArea("SZ9")
		DbSetOrder(1)
		DbGotop()
		If DbSeek(xFilial("SZ9")+SZB->ZB_MOTORIS,.T.)
			cNomMot := SZ9->Z9_NOME
		EndIf
		DbSelectArea("SZB")

		cNomeForn := Space(30)
        DbSelectArea("SA2")
        DbSetOrder(1)
        DbGotop()
        If DbSeek(xFilial("SA2")+SZB->ZB_FORNECE+SZB->ZB_LOJAFOR,.T.)
            cNomeForn := SA2->A2_NOME
        EndIf
        DbSelectArea("SZB")

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Impressao do cabecalho do relatorio                                 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
		nLin := 6
		Cabecalho()
		nLin := 15

		cNum := SZB->ZB_NUM
		nVista := 0
		nPrazo := 0

		While !Eof() .And. SZB->ZB_NUM == cNum

			nTotPes := 0
			nTotVol := 0
			nTotVal := 0
			DbSelectArea("SZC")
			DbSetOrder(1)
			DbGotop()
			DbSeek(xFilial("SZC")+SZB->ZB_NUM,.T.)
			While !Eof() .And. SZC->ZC_FILIAL == xFilial("SZC");
			.And. SZC->ZC_NUM	 == SZB->ZB_NUM

				//cabec1      "NrNota Ser  Peso Kg  Volumes  Valor R$  Client Lj Nome "
				//             XXXXXX XXX999999.99    999 9999.999.99  XXXXXX XX  XXXXXXXX-30-XXXXXXXXXXXXXXXXX
				//             12345678901234567890123456789012345678901234567890123456789012345678901234567890
				//                      1         2         3         4         5         6         7         8
				//             TOTAL --> 999999.99	  999 9999.999.99

				//Busco nome Cliente
				cNome := ""

				dbSelectArea("SA1")
				dbSetOrder(1)
				If dbSeek(xFilial("SA1")+SZC->ZC_CLIENTE+SZC->ZC_LOJA)
					cNome := A1_NOME
				EndIf
				dbCloseArea()


				//-----------------------------------------------------------------------------------------------------------------
				//Busca nome do estado e municipio de entrega				
				cEstado := ""
				cMunicipio := ""
				
				dbSelectArea("SUA")
				dbSetOrder(2) //UA_FILIAL+UA_SERIE+UA_DOC                                                                                                                                       

				If dbSeek(xFilial("SUA")+SZC->ZC_SERIE+SZC->ZC_DOC)
					cEstado := UA_ESTE
					cMunicipio := UA_MUNE
				EndIf
				dbCloseArea()

				If EMPTY(ALLTRIM( cEstado )) .AND. EMPTY(ALLTRIM( cMunicipio ))
					dbSelectArea("SA1")
					dbSetOrder(1)
					If dbSeek(xFilial("SA1")+SZC->ZC_CLIENTE+SZC->ZC_LOJA)
					cEstado := A1_ESTE
					cMunicipio := A1_MUNE
					EndIf
					dbCloseArea()

				EndIf


				//Busco Condicao de pagamento na nota
				cCond := ""
				If cFilAnt == "06" .AND. SZC->ZC_SERIE = '1'
					cDoc := substr(alltrim(SZC->ZC_DOC),1,6) + "   "
				Else
					cDoc := SZC->ZC_DOC
				EndIf

				dbSelectArea("SF2")
				dbSetOrder(2)
				If dbSeek(xFilial("SF2")+SZC->ZC_CLIENTE+SZC->ZC_LOJA+cDoc+SZC->ZC_SERIE)
					If SF2->F2_COND == "001"
						cCond := "A VISTA"
						nVista := nVista + 1
					Else
						cCond := "A PRAZO"
						nPrazo := nPrazo + 1
					EndIf
				EndIf
				dbCloseArea()

				DbSelectArea("SZC")

				@ nLin,001 PSAY ALLTRIM(SZC->ZC_DOC)
				@ nLin,013 PSAY ALLTRIM(SZC->ZC_SERIE)
				//@ nLin,023 PSAY cCond
				@ nLin,013 PSAY Transform(SZC->ZC_VALOR,"@E 999,999,999.99")
				@ nLin,030 PSAY Transform(SZC->ZC_VOLUME,"@E 99999")
				@ nLin,037 PSAY Transform(SZC->ZC_PESO,"@E 9999999.99")
				@ nLin,050 PSAY SZC->ZC_CLIENTE
				@ nLin,058 PSAY SZC->ZC_LOJA
				@ nLin,062 PSAY cNome
				@ nLin,108 PSAY cEstado
				@ nLin,112 PSAY cMunicipio

				nLin := nLin + 1

				nTotPes := nTotPes + SZC->ZC_PESO
				nTotVol := nTotVol + SZC->ZC_VOLUME
				nTotVal := nTotVal + SZC->ZC_VALOR

				If (!Empty(mv_par07) .And. mv_par07 == 1)
					DbSelectArea("SD2")
					DbSetOrder(3)
					DbGotop()
					DbSeek(xFilial("SD2")+cDoc+SZC->ZC_SERIE+SZC->ZC_CLIENTE+SZC->ZC_LOJA)
					While !Eof() .And. SD2->D2_FILIAL  == xFilial("SD2");
					.And. SD2->D2_DOC     == cDoc;
					.And. SD2->D2_SERIE   == SZC->ZC_SERIE;
					.And. SD2->D2_CLIENTE == SZC->ZC_CLIENTE;
					.And. SD2->D2_LOJA    == SZC->ZC_LOJA

						dbSelectArea("SB1")
						dbsetorder(1)
						dbseek(xFilial("SB1")+SD2->D2_COD)

						@ nLin,013 PSAY ALLTRIM(SD2->D2_COD)
						@ nLin,023 PSAY POSICIONE('SC6',1,xfilial('SC6')+SD2->D2_PEDIDO+SD2->D2_ITEM+SD2->D2_COD,'C6_XCOMPAR')
						@ nLin,052 PSAY ALLTRIM(SB1->B1_DESC)

						If Len(ALLTRIM(SB1->B1_DESC)) < 50
							@ nLin,053 + Len(ALLTRIM(SB1->B1_DESC)) PSAY Replicate("-",103-(053 + Len(ALLTRIM(SB1->B1_DESC))))
						EndIF

						@ nLin,103 PSAY Transform(SD2->D2_QUANT,"@E 99999999.99")
						@ nLin,115 PSAY Transform(SD2->D2_VALBRUT,"@E 99,999,999,999.99")
						@ nLin,135 PSAY Transform(SD2->D2_PESO,"@E 999999.999")
						        
						
					   //	nAchouPRD := ASCAN(aTotProd, { |x||2| UPPER(x) == UPPER(SD2->D2_COD) }) 
						nAchouPRD := aScan(aTotProd,{|x| alltrim(x[2]) == alltrim(SD2->D2_COD)}) 
						
						If nAchouPRD == 0 
							AADD(aTotProd,{ SZB->ZB_NUM , SD2->D2_COD , SB1->B1_DESC , SD2->D2_QUANT})
						Else
							aTotProd[nAchouPRD][4] += SD2->D2_QUANT// - Valor 
						Endif
						//aTotProd[1]// - Numero do romaneio
						//aTotProd[2]// - Codigo do Produto
						//aTotProd[3]// - Descrição 
						//aTotProd[4]// - Valor 				
						
						nLin := nLin + 1
						
						If (nLin > 55)
							If (nLin != 80)
								Roda(0,"","M")
							EndIf
							Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
							nLin := 6
							Cabecalho()
							nLin := 14
						Endif
						
						DbSelectArea("SD2")
						SD2->(DbSkip())
					EndDo
					nLin := nLin + 1
				EndIF

				DbSelectArea("SZC")
				SZC->(DbSkip())  
				
				//Colocar quebra pra romaneio com muitos itens
				If (nLin > 55)
					If (nLin != 80)
						Roda(0,"","M")
					EndIf
					Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
					nLin := 6
					Cabecalho()
					nLin := 14
				Endif
				
			EndDo
                  
			//Quebra de Linha
			If (nLin > 51)
				If (nLin != 80)
					Roda(0,"","M")
		   		EndIf  
				Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
				nLin := 6
				Cabecalho()
				nLin := 14 				
			Endif

			nLin := nLin + 2
			@ nLin,001 PSAY Replicate("-",150)

			nLin := nLin + 1

			@ nLin,001 PSAY "TOTAL ->"
			@ nLin,033 PSAY Transform(nTotVal,"@E 999,999.99")
			@ nLin,050 PSAY Transform(nTotVol,"@E 999999")
			@ nLin,060 PSAY Transform(nTotPes,"@E 999999.99")

			nLin := nLin + 2

			@ nLin,001 PSAY "TOTAL NF A VISTA ->"
			@ nLin,021 PSAY Transform(nVista,"@E 999999")
			@ nLin,031 PSAY "TOTAL NF A PRAZO ->"
			@ nLin,051 PSAY Transform(nPrazo,"@E 999999")
			@ nLin,061 PSAY "TOTAL DE NOTAS ->"
			@ nLin,081 PSAY Transform((nPrazo+nVista),"@E 999999") 
			
			//Quebra de Linha
			If (nLin > 53)
				If (nLin != 80)
					Roda(0,"","M")
		   		EndIf  
				Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
				nLin := 6
				Cabecalho()
				nLin := 14 				
			Endif 
			
			//Chamado [63378] - Total por produto 
			If len(aTotProd) > 0 
				nLin := nLin + 2
				@ nLin,001 PSAY "TOTAL POR PRODUTO: "
				nLin := nLin + 1
				@ nLin,001 PSAY 'Codigo'    // - Codigo do Produto
				@ nLin,013 PSAY 'Descrição' // - Descrição 
				@ nLin,061 PSAY 'Quant.' 	// - Valor 
				nLin := nLin + 1
				For _i := 1 to len(aTotProd)
					//aTotProd[1]// - Numero do romaneio
					@ nLin,001 PSAY aTotProd[_i][2]	// - Codigo do Produto
					@ nLin,013 PSAY aTotProd[_i][3] // - Descrição 
					@ nLin,061 PSAY Transform(aTotProd[_i][4],"@E 99999999.99") // - Valor 	
					             						
					//Quebra de Linha
					If (nLin > 55)
						If (nLin != 80)
							Roda(0,"","M")
						EndIf  
						Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
						nLin := 6
						Cabecalho()
						nLin := 14 
						@ nLin,001 PSAY "TOTAL POR PRODUTO: "
						nLin := nLin + 1
						@ nLin,001 PSAY 'Codigo'    // - Codigo do Produto
						@ nLin,013 PSAY 'Descrição' // - Descrição 
						@ nLin,061 PSAY 'Quant.' 	// - Valor 
						nLin := nLin + 1
						
					Endif
					nLin := nLin + 1
				Next _i 
			Endif
			
			aTotProd := {}
			nTotPes := 0
			nTotVol := 0
			nTotVal := 0

			DbSelectArea("SZB")
			SZB->(DbSkip())
		EndDo

		If (nLin != 80)
			Roda(0,"","M")
		EndIf

	EndDo

	Set Filter To

	SetPgEject(.F.)  //Incluido para corrigir avanco de folha apos atualizacao do sistema em 13.02.04

	If aReturn[5] == 1
		Set Printer To
		Commit
		ourspool(wnrel) //Chamada do Spool de Impressao
	Endif
	MS_FLUSH() //Libera fila de relatorios em spool
Return

Static Function Cabecalho()
	//12345678901234567890123456789012345678901234567890123456789012345678901234567890
	//			  1         2         3         4         5         6         7         8
	//Romaneio: 999999
	//Condutor: XX-6-X XXXXXXXXXXX-30-XXXXXXXXXXXXXX      Veiculo: XX-7-XX
	//Data Saida: 99/99/99                                Km Saida: 999999
	//Data Chegada: 99/99/99										Km Chegada: 999999
	Local nCont := 0 

	@ nLin,001 PSAY "Romaneio:"
	@ nLin,011 PSAY SZB->ZB_NUM
	nLin := nLin + 1
	@ nLin,001 PSAY "Condutor:"
	@ nLin,011 PSAY SZB->ZB_MOTORIS
	@ nLin,018 PSAY Substr(cNomMot,1,30)
	@ nLin,053 PSAY "Veiculo:"
	@ nLin,062 PSAY SZB->ZB_PLACA
	@ nLin,090 PSAY "Fornecedor:"
	@ nLin,105 PSAY SZB->ZB_FORNECE
	@ nLin,115 PSAY Substr(cNomeForn,1,30)
	nLin := nLin + 1
	@ nLin,001 PSAY "Data Saida:"
	@ nLin,013 PSAY SZB->ZB_DTSAIDA
	@ nLin,053 PSAY "KM Saida:"
	If SZB->ZB_KMSAIDA <> 0
		@ nLin,063 PSAY Transform(SZB->ZB_KMSAIDA,"@E 999999")
	Else
		@ nLin,063 PSAY ""
	EndIf
	@ nLin,090 PSAY "Loja Forne:"
	@ nLin,105 PSAY SZB->ZB_LOJAFOR
	nLin := nLin + 1
	@ nLin,001 PSAY "Data Chegada:"
	@ nLin,015 PSAY SZB->ZB_DTCHEGA
	@ nLin,053 PSAY "KM Chegada:"
	If SZB->ZB_KMCHEGA <> 0
		@ nLin,065 PSAY Transform(SZB->ZB_KMCHEGA,"@E 999999")
	Else
		@ nLin,063 PSAY ""
	EndIf
	@ nLin,090 PSAY "NF Entrada:"
	@ nLin,105 PSAY SZB->ZB_DOCENT

	//aDefBase := {"03=BASE","04=IRANI","05=ICARA","02=ARAUCARIA","08=LAGES"} // ITENS DO COMBOBOX BASE DE ORIGEM DA CARGA
	//ADICIONADO PARA INCLUIR CAMPO COMBOBOX NA TELA
	cDescBase := ""
	nCont     := 1
	aDefBase  := RetSX3Box(GetSX3Cache("ZB_BASE","X3_CBOX"),,,1)

	if Alltrim(SZB->ZB_BASE) <> ""
		For nCont := 1 To Len(aDefBase)
			If alltrim(cDescBase) == "" .and. SZB->ZB_BASE == substr(alltrim(aDefBase[nCont][1]),1,2)
				cDescBase := alltrim(aDefBase[nCont][1])
				nCont     := Len(aDefBase)
			Endif
		Next nCont
	EndIf

	nLin := nLin + 1
	@ nLin,001 PSAY "Base Supri:"
	@ nLin,015 PSAY cDescBase
	@ nLin,053 PSAY "KM Rodado:"
	If SZB->ZB_KMSAIDA <> 0	.and.;
	SZB->ZB_KMCHEGA <> 0
		@ nLin,065 PSAY Transform((SZB->ZB_KMCHEGA-SZB->ZB_KMsaida),"@E 999999")
	Else
		@ nLin,063 PSAY ""
	EndIf
	@ nLin,090 PSAY "Serie NF:"
	@ nLin,105 PSAY SZB->ZB_SERIENT
	nLin := nLin + 2

	//NrNota Ser  Peso Kg  Volumes  Valor R$  Client Lj Nome "
	//XXXXXX XXX  9999.99      999  99.999.99 XXXXXX XX XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
	//12345678901234567890123456789012345678901234567890123456789012345678901234567890
	//         1         2         3         4         5         6         7         8

	//		@ nLin,001 PSAY "NrNota      Serie     Cond.Pgto   Peso Kg     Volumes        Valor R$   Client Lj Nome                    "
	@ nLin,001 PSAY "NrNota     Serie   Valor R$    Volumes    Peso    Client  Lj  Nome                                      Estado  Cidade  "
	nLin := nLin + 1
	If (!Empty(mv_par07) .And. mv_par07 == 1) 
	@ nLin,001 PSAY "            Cod.                                  Produto                                                 Quant.          Valor           Peso"
		nLin := nLin + 1
	Endif
	@ nLin,001 PSAY Replicate("-",150)
	nLin := nLin + 1

Return

Static Function CriaPerg()

	Local aRegistros := {}

	AADD(aRegistros,{cPerg,"01","Romaneio Inicial  ?","mv_ch1","C",06,0,0,"G","","mv_par01","","","","","","","","","","","","","","",""})
	AADD(aRegistros,{cPerg,"02","Romaneio Final    ?","mv_ch2","C",06,0,0,"G","","mv_par02","","","","","","","","","","","","","","",""})
	AADD(aRegistros,{cPerg,"03","Condutor Inicial  ?","mv_ch3","C",06,0,0,"G","","mv_par03","","","","","","","","","","","","","","","SZ9"})
	AADD(aRegistros,{cPerg,"04","Condutor Final	   ?","mv_ch4","C",06,0,0,"G","","mv_par04","","","","","","","","","","","","","","","SZ9"})
	AADD(aRegistros,{cPerg,"05","Data Saida Inicial?","mv_ch5","D",08,0,0,"G","","mv_par05","","","","","","","","","","","","","","",""})
	AADD(aRegistros,{cPerg,"06","Data Saida Final  ?","mv_ch6","D",08,0,0,"G","","mv_par06","","","","","","","","","","","","","","",""})
	AADD(aRegistros,{cPerg,"07","Mostrar Produtos  ?","mv_ch7","C",01,0,3,"C","","mv_par07","Sim","","","Não","","","","","","","","","","",""})

	U_CriaPer(cPerg,aRegistros)
	Pergunte(cPerg, .F.)

Return
