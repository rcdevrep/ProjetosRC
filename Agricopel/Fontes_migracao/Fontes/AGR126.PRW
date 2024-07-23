#INCLUDE "RWMAKE.CH"

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±±Programa  ³AGR126    ± Autor ³Deco                ± Data ³  20/08/04   ±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±±Desc.     ³  Programa para Histor lancamento padrao 530-01 e 530-04    ±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±±Uso       ³ AP                                                         ±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/

User Function AGR126()

	Local _cMvPlnFnm := SuperGetMv("MV_XPLNFNM",.F.,"001")
	Local _cMvPlnJrs := SuperGetMv("MV_XPLNJUR",.F.,"003")
	Private cHistor          

	dbSelectArea("SA2")  // Posiciona Fornecedor  Deco 09/02/2005
	dbSetOrder(1)
	dbSeek(xFilial("SA2")+SE2->E2_FORNECE+SE2->E2_LOJA)

	//"PGTO. DOC. NR. "+SE2->E2_PREFIXO+ " - "+SE2->E2_NUM+" - "+ SA2->A2_NREDUZ
	cHistor := 'PGTO. DOC. NR. '

	// Agricopel 
	If SM0->M0_CODIGO == "01"
		// GCT - SLA (01/03/2018)
		If SE2->E2_PREFIXO == 'MED'
			// Veririca se eh baixa do tipo 001 - Finame / 003 - Juros / demais outros
			If Posicione("CNA",1,xFilial("CNA")+SE2->E2_MDCONTR+SPACE(LEN(CNA->CNA_REVISA))+SE2->E2_MDPLANI,"CNA_TIPPLA") == _cMvPlnFnm
				cHistor := 'PGT FINAME REF. ' + SUBSTR(DTOS(SE2->E2_EMISSAO),5,2) + '/' + SUBSTR(DTOS(SE2->E2_EMISSAO),1,4) +' CONTR. '+SE2->E2_MDCONTR
			ElseIf Posicione("CNA",1,xFilial("CNA")+SE2->E2_MDCONTR+SPACE(LEN(CNA->CNA_REVISA))+SE2->E2_MDPLANI,"CNA_TIPPLA") == _cMvPlnJrs
				cHistor := 'PGT JUROS REF. ' + SUBSTR(DTOS(SE2->E2_EMISSAO),5,2) + '/' + SUBSTR(DTOS(SE2->E2_EMISSAO),1,4) +' CONTR. '+SE2->E2_MDCONTR
			Else
				cHistor := 'PGT PARC. REF. ' + SUBSTR(DTOS(SE2->E2_EMISSAO),5,2) + '/' + SUBSTR(DTOS(SE2->E2_EMISSAO),1,4) +' CONTR. '+SE2->E2_MDCONTR
			EndIf
		EndIf
		// DEMAIS
		If Alltrim(SA2->A2_CONTA) == '215020001' 
			cHistor := 'QUIT.GUIA INSS REF. '
		EndIf
		If Alltrim(SA2->A2_CONTA) == '215020002' 
			cHistor := 'QUIT.GUIA FGTS REF. '
		EndIf
		If Alltrim(SA2->A2_CONTA) == '215020003' 
			cHistor := 'QUIT.GUIA PIS S/FAT. '
		EndIf
		If Alltrim(SA2->A2_CONTA) == '215020004' 
			cHistor := 'QUIT.GUIA COFINS S/FAT. '
		EndIf
		If Alltrim(SA2->A2_CONTA) == '215020005' 
			cHistor := 'QUIT.GUIA MENS.SINDICAL. '
		EndIf
		If Alltrim(SA2->A2_CONTA) == '215020007' 
			cHistor := 'PAGO PENSAO JUDICIAL REF. '
		EndIf
		If Alltrim(SA2->A2_CONTA) == '215020009' 
			cHistor := 'PAGO CONT. CONFED. REF. '
		EndIf
		If Alltrim(SA2->A2_CONTA) == '215030001' 
			cHistor := 'QUIT.GUIA ICMS S/FAT. '
		EndIf
		If Alltrim(SA2->A2_CONTA) == '215030004' 
			cHistor := 'QUIT.GUIA IRRF REF. '
		EndIf
		If Alltrim(SA2->A2_CONTA) == '215030005' 
			cHistor := 'QUIT.GUIA IRRF REF. '
		EndIf
		If Alltrim(SA2->A2_CONTA) == '215030006' 
			cHistor := 'QUIT.GUIA IRRF REF. '
		EndIf
		If Alltrim(SA2->A2_CONTA) == '215030007' 
			cHistor := 'QUIT. PIS/COFINS/CSLL REF. '
		EndIf
		If Alltrim(SA2->A2_CONTA) == '215030008' 
			cHistor := 'QUIT.GUIA IRRF REF. '
		EndIf
		If Alltrim(SA2->A2_CONTA) == '215030009' 
			cHistor := 'PAGO ISS SERVICOS REF. '
		EndIf
	EndIf

	// Mime Distrib.
	If SM0->M0_CODIGO == "02"
		If Alltrim(SA2->A2_CONTA) == '215020001' 
			cHistor := 'QUIT.GUIA INSS REF. '
		EndIf
		If Alltrim(SA2->A2_CONTA) == '215020002' 
			cHistor := 'QUIT.GUIA FGTS REF. '
		EndIf
		If Alltrim(SA2->A2_CONTA) == '215020003' 
			cHistor := 'QUIT.GUIA PIS S/FAT. '
		EndIf
		If Alltrim(SA2->A2_CONTA) == '215020004' 
			cHistor := 'QUIT.GUIA COFINS S/FAT. '
		EndIf
		If Alltrim(SA2->A2_CONTA) == '215020005' 
			cHistor := 'QUIT.GUIA MENS.SINDICAL. '
		EndIf
		If Alltrim(SA2->A2_CONTA) == '215020008' 
			cHistor := 'PAGO CONT. CONFED. REF. '
		EndIf
		If Alltrim(SA2->A2_CONTA) == '215030001' 
			cHistor := 'QUIT.GUIA ICMS S/FAT. '
		EndIf
		If Alltrim(SA2->A2_CONTA) == '215030004' 
			cHistor := 'QUIT.GUIA IRRF REF. '
		EndIf
		If Alltrim(SA2->A2_CONTA) == '215030005' 
			cHistor := 'QUIT.GUIA IRRF REF. '
		EndIf
		If Alltrim(SA2->A2_CONTA) == '215030006' 
			cHistor := 'QUIT.GUIA IRRF REF. '
		EndIf
		If Alltrim(SA2->A2_CONTA) == '215030007' 
			cHistor := 'QUIT. PIS/COFINS/CSLL REF. '
		EndIf
		If Alltrim(SA2->A2_CONTA) == '215030008' 
			cHistor := 'PAGO ISS SERVICOS REF. '
		EndIf
	EndIf

	// Postos Mime
	If SM0->M0_CODIGO == "20"
		If Alltrim(SA2->A2_CONTA) == '215020001' 
			cHistor := 'QUIT.GUIA INSS REF. '
		EndIf
		If Alltrim(SA2->A2_CONTA) == '215020002' 
			cHistor := 'QUIT.GUIA FGTS REF. '
		EndIf
		If Alltrim(SA2->A2_CONTA) == '215020003' 
			cHistor := 'QUIT.GUIA PIS S/FAT. '
		EndIf
		If Alltrim(SA2->A2_CONTA) == '215020004' 
			cHistor := 'QUIT.GUIA COFINS S/FAT. '
		EndIf
		If Alltrim(SA2->A2_CONTA) == '215020007' 
			cHistor := 'PAGO PENSAO JUDICIAL REF. '
		EndIf
		If Alltrim(SA2->A2_CONTA) == '215020008' 
			cHistor := 'QUIT.GUIA INSS (2631) '
		EndIf
		If Alltrim(SA2->A2_CONTA) == '215020009' 
			cHistor := 'QUIT.GUIA IMP.SINDICAL. '
		EndIf
		If Alltrim(SA2->A2_CONTA) == '215020010' 
			cHistor := 'QUIT.GUIA MENS.SINDICAL. '
		EndIf
		If Alltrim(SA2->A2_CONTA) == '215030001' 
			cHistor := 'QUIT.GUIA ICMS S/FAT '
		EndIf
		If Alltrim(SA2->A2_CONTA) == '215030002' 
			cHistor := 'QUIT.GUIA IRPJ REF TRIM. '
		EndIf
		If Alltrim(SA2->A2_CONTA) == '215030003' 
			cHistor := 'QUIT.CONTR.SOCIAL REF TRIM. '
		EndIf
		If Alltrim(SA2->A2_CONTA) == '215030004' 
			cHistor := 'QUIT.GUIA IRRF REF. '
		EndIf
		If Alltrim(SA2->A2_CONTA) == '215030005' 
			cHistor := 'QUIT.GUIA IRRF REF. '
		EndIf
		If Alltrim(SA2->A2_CONTA) == '215030007' 
			cHistor := 'QUIT.GUIA I.S.S REF MES '
		EndIf
		If Alltrim(SA2->A2_CONTA) == '215030008' 
			cHistor := 'QUIT.GUIA PIS/COFINS/CSLL. '
		EndIf
		If Alltrim(SA2->A2_CONTA) == '215030009' 
			cHistor := 'QUIT.GUIA INSS (2631) '
		EndIf
	EndIf

	cHistor := cHistor+"  "+ALLTRIM(SE2->E2_NUM)+"  "+SA2->A2_NREDUZ

Return(cHistor)