#include 'protheus.ch'
#include 'parmtype.ch'
#include 'topconn.ch'

USER FUNCTION PE01NFESEFAZ() 

LOCAL aNfe		:= PARAMIXB 
Local cMensCli	:= PARAMIXB[02]
Local aNota		:= PARAMIXB[05]
LOCAL aAreaSe1	:= SE1->(GetArea()) 
LOCAL lNfSaida	:=.F. 

lNfSaida :=  aNOTA[4]=="1"

If SF2->F2_COND == 'AVC'

	If lNfSaida 
	    If !Empty(SF2->F2_DUPL) // Se a Nota Possuir Financeiro 
            If SE1->(dbSetOrder(1), dbSeek(xFilial("SE1")+SF2->F2_SERIE+SF2->F2_DOC)) 
                While SE1->(!Eof()) .And. SE1->E1_FILIAL == xFilial("SE1") .And. SE1->E1_PREFIXO == SF2->F2_SERIE .And. SE1->E1_NUM == SF2->F2_DOC .And. SE1->E1_CLIENTE == SF2->F2_CLIENTE .And. SE1->E1_LOJA == SF2->F2_LOJA
//	               		cMensCli  += 'Não incidência de ICMS, nos termos da cláusula primeira do Convênio ICMS 117/2004.'+ Chr(13) + Chr(10) 
                    If !Empty(SE1->E1_PIS)                    	
                            cMensCli += " Retenção: PIS: "+LTRIM(TransForm(SE1->E1_PIS,"@E 999,999.99")) + Chr(13) + Chr(10)
                            cMensCli += " COFINS: " 	   + LTRIM(TransForm(SE1->E1_COFINS,"@E 999,999.99")) + Chr(13) + Chr(10)
                            cMensCli += " CSLL: " 		   + LTRIM(TransForm(SE1->E1_CSLL,"@E 999,999.99")) + Chr(13) + Chr(10)
                            cMensCli += " IRPJ: " 		   + LTRIM(TransForm(SE1->E1_IRRF,"@E 999,999.99")) + Chr(13) + Chr(10)
                            If !Empty(SE1->E1_INSS) 
                            cMensCli += " INSS: "		   +LTRIM(TransForm(SE1->E1_INSS,"@E 999,999.99" ))+ Chr(13) + Chr(10)                           
                            Exit 
                            EndIf      
                            cMensCli += "LIQUIDO: "+LTRIM(TransForm(SE1->(E1_VALOR-E1_PIS-E1_COFINS-E1_IRRF-E1_CSLL),"@E 999,999,999.99" ))
                    EndIf 
                    SE1->(dbSkip(1)) 
                Enddo 

            Endif    
	    Endif
	Endif

Else

	cQuery := "SELECT * "
	cQuery += " FROM "+RetSqlName("SC5")+" SC5 "
	cQuery += "   LEFT JOIN "+RetSqlName("CND")+" CND ON (C5_MDCONTR = CND_CONTRA AND C5_MDNUMED = CND_NUMMED)"
	cQuery += "   LEFT JOIN "+RetSqlName("CN9")+" CN9 ON (CND_CONTRA = CN9_NUMERO AND CND_REVISA = CN9_REVISA)"
	cQuery += " WHERE SC5.D_E_L_E_T_ = '' "
	cQuery += "   AND CND.D_E_L_E_T_ = '' "
	cQuery += "   AND CN9.D_E_L_E_T_ = '' "
	cQuery += "   AND C5_FILIAL = '"+xFilial("SC5")+"' "
	cQuery += "   AND C5_NOTA = '"+SF2->F2_DOC+"'"
	cQuery += "   AND C5_SERIE = '"+SF2->F2_SERIE+"'"
	TCQuery cQuery NEW ALIAS "xTemp"

		If !(xTemp->(Eof()))

			cMensCli := "Não incidência de ICMS , nos termos da cláusula primeira do Convênio ICMS 117/2004" + Chr(13) + Chr(10)
			
			If !Empty(xTemp->CN9_DESCRI)

				cMensCli += "Contrato: " + AllTrim(xTemp->CN9_DESCRI) + Chr(13) + Chr(10)

			EndIf

		EndIf

	xTemp->(dbCloseArea())


	If !lNfSaida
		cMensCli += Chr(13) + Chr(10)
		cMensCli += SF1->F1_XMENNOT
	EndIf

Endif

PARAMIXB[2] := cMenscli 

If lNfSaida
	IF EXISTBLOCK("CTLTIT02")
		EXECBLOCK("CTLTIT02",.F.,.F.,aNota)
	ENDIF
EndIf

RestArea(aAreaSe1)
 
RETURN aNfe 
