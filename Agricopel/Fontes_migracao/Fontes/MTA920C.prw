#include "RWmake.ch" 
#Include "Font.ch"
#Include "Colors.ch" 
#Include "cheque.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MTA920C   ºAutor  ³Microsiga           º Data ³  12/08/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³  Gera titulos no contas a receber no documento manual de   º±±
±±º          ³  saida. (MATA920)                                          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function MTA920C()       

	If !ISINCALLSTACK("CNTA120")

		//Informe a placa para lancamentos manuais
		SX3->(dbSetOrder(2))

		//-- SIGAWMS: Ajuste do ComboBox

		If	SX3->(dbSeek("F2_PLACA"))
			aRegistros := {}
			cPerg := "MTA920A"  

			AADD(aRegistros,{cPerg,"01","Placa Veiculo ?","mv_ch1","C",7,0,0,"G","","MV_PAR01","","","","","","","","","","","","","","",""})

			U_CriaPer(cPerg,aRegistros)  

			Pergunte(cPerg,.T.) 
			cPlaca := "" 

			cPlaca := MV_PAR01 

			RecLock("SF2", .F.)
			SF2->F2_PLACA := cPlaca 
			MsUnlock("SF2")       
		EndIf	                        	

		If cEmpAnt == "39" .OR. cEmpAnt == "01" .OR. cEmpAnt == "30" .OR. cEmpAnt == "22" .OR. cEmpAnt == "31" .OR. cEmpAnt == "41" .OR. cEmpAnt == "92" ;
			.OR. cEmpAnt == "50" .OR. cEmpAnt == "02" .OR. cEmpAnt == "03" .OR. cEmpAnt == "59" .OR. cEmpAnt == "43"     //Somente para MCL e Agricopel Icara

			aRegistros := {}
			cPerg := "MTA920"

			AADD(aRegistros,{cPerg,"01","Cond. Pagto ?","mv_ch1","C",3,0,0,"G","","MV_PAR01","","","","","","","","","","","","","","","SE4"})

			U_CriaPer(cPerg,aRegistros)
			lFoi := .F.

			While !lFoi

				Pergunte(cPerg,.T.)
				nValTot := MaFisRet(,"NF_TOTAL")

				cCond := MV_PAR01

				//valida condicao pagamento
				dbSelectArea("SE4")
				dbSetOrder(1)
				If !DbSeek(xFilial("SE4")+cCond)
					Alert("Anteção! Condição de pagamento invalida! Verifique!")
					Loop
				EndIf

				lFoi  := .T.
				aParc := Condicao(nValTot,cCond,,dDataBase)

				For nY := 1 to Len(aParc)

					cmsg      := "1 Parcela: "+Transform(aParc[nY,1],"@E 9,999,999.99")						
					cPref     := AllTrim(cFilAnt) + Substr(C920SERIE,1,3)
					cNumTit   := C920NOTA
					cParcela  := AllTrim(str(nY))
					cNatureza := "101001" 
					cCliente  := C920CLIENT    
					cLoja     := C920LOJA   
					dEmiss    := D920EMIS
					dVencto   := aParc[nY,1]
					nValTit   := aParc[nY,2]

					If (AllTrim(cTipo) == "D")
						cTipoTit := "NDF"
						cHist := "TITULO A REC. FORNE"
					ELSE
						cTipoTit := "NF"
						cHist := "TITULO A RECEBER"
					EndIf

					Begin Transaction

						If (AllTrim(cTipo) == "D")
							aVetor := {{"E2_PREFIXO"     ,cPref               ,Nil},;
										{"E2_NUM"         ,cNumTit             ,Nil},;
										{"E2_PARCELA"     ,cParcela            ,Nil},;
										{"E2_TIPO"        ,cTipoTit            ,Nil},;
										{"E2_NATUREZ"     ,cNatureza           ,Nil},;
										{"E2_FORNECE"     ,cCliente            ,Nil},;
										{"E2_LOJA"        ,cLoja               ,Nil},;
										{"E2_EMISSAO"     ,dEmiss              ,Nil},;
										{"E2_VENCTO"      ,dVencto             ,Nil},;
										{"E2_VENCREA"     ,DataValida(dVencto) ,Nil},;
										{"E2_HIST"        ,cHist               ,Nil},;
										{"E2_MOEDA"       ,1                   ,Nil},;
										{"E2_ORIGEM"      ,"MATA460"           ,Nil},;
										{"E2_FLUXO"       ,"S"                 ,Nil},;
										{"E2_VALOR"       ,nValTit             ,Nil}}
						Else
							aVetor := {{"E1_PREFIXO"     ,cPref               ,Nil},;
										{"E1_NUM"         ,cNumTit             ,Nil},;
										{"E1_PARCELA"     ,cParcela            ,Nil},;
										{"E1_TIPO"        ,cTipoTit            ,Nil},;
										{"E1_NATUREZ"     ,cNatureza           ,Nil},;
										{"E1_CLIENTE"     ,cCliente            ,Nil},;
										{"E1_LOJA"        ,cLoja               ,Nil},;
										{"E1_EMISSAO"     ,dEmiss              ,Nil},;
										{"E1_VENCTO"      ,dVencto             ,Nil},;
										{"E1_VENCREA"     ,DataValida(dVencto) ,Nil},;
										{"E1_HIST"        ,cHist               ,Nil},;
										{"E1_MOEDA"       ,1                   ,Nil},;
										{"E1_ORIGEM"      ,"MATA460"           ,Nil},;
										{"E1_FLUXO"       ,"S"                 ,Nil},;
										{"E1_VALOR"       ,nValTit             ,Nil},;
										{"E1_SERIE"       ,C920SERIE           ,Nil}}
						EndIf             

						lMsErroAuto:= .F.

						If (AllTrim(cTipo) == "D")
							MSExecAuto({|x,y| Fina050(x,y)},aVetor,3)
						ELSE
							MSExecAuto({|x,y| Fina040(x,y)},aVetor,3)
						EndIf   

						DbSelectArea("SF2")
						If DbSeek(xFilial("SF2")+cNumTit+C920SERIE+cCliente+cLoja)

							RecLock("SF2", .F.)
							SF2->F2_PREFIXO := cPref
							SF2->F2_DUPL    := cNumTit
							SF2->F2_COND    := MV_PAR01
							MsUnlock("SF2")

						EndIf

						If lMsErroAuto
							MostraErro() // tela de erro do msexecauto mostra campo com o erro
							DisarmTransaction()
						EndIf

					End Transaction

				Next nY

			EndDo

		EndIf

	EndIf

Return()